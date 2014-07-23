
local event = require("event")
local mdm   = require("mdm")
local types = require("types")

local net = {}

autoload(net, "net",
         "dns",
         "echo",
         "gps",
         "Message",
         "nfs",
         "route",
         "rpc",
         "status",
         "syslog",
         "telnet")

-- Sequence numbers for messages, part of globally unique message identifiers

local last_seqno = 0

local function seqno()
	last_seqno = last_seqno + 1
	return last_seqno
end

-- Find a wireless modem if one is available

-- TODO: obsolete
function net.modem()
	return mdm.modem()
end

function net.hostname()
	return os.getComputerLabel() or "<"..tostring(os.getComputerID())..">"
end

-- **************************************************************************

local _handlers = event.HandlerList.new()

-- Track whether or not a message has already been seen (using UUIDs)
-- Only 100 previous messages are tracked

local _seen = {}
local _uuid_queue = types.List.new()
local function seen(id)
	if not id then
		return false
	end

	if _seen[id] then
		return true
	end

	while _uuid_queue:size() > 100 do
		_seen[_uuid_queue:pop_front()] = nil
	end

	_seen[id] = true
	_uuid_queue:push_back(id)

	return false
end

local _relaying = false

function net.relay(enable)
	-- TODO: open modem, open channel !?!?!?!
	if enable then
		local m = net.modem()
		if m then
			m.open(rednet.CHANNEL_REPEAT)
		end
	end
	_relaying = enable
end

function net.relaying(ch)
	return _relaying
end

local function onModemMessage(sch, rch, raw, side, distance)
	--print("raw="..textutils.serialize(raw))
	--print("modem message to "..tostring(sch))

	if sch == os.getComputerID() or sch == rednet.CHANNEL_BROADCAST then
		--log.debug("my id="..tostring(os.getComputerID()))
		--log.debug("received sch="..tostring(sch).." rch="..tostring(rch).." msg="..textutils.serialize(raw))
    	if type(raw) == "table" and raw.nMessageID and not seen(raw.nMessageID) then -- TODO
		   	os.queueEvent(event.rednet_message, rch, raw.message, raw.sProtocol)
	    end
	end

	return true
end

local function onRepeatMessage(sch, rch, raw, side, distance)
	if type(raw) == "table" and raw.nMessageID and raw.nRecipient then
		if not seen(raw.nMessageID) then
			peripheral.call(side, "transmit", rednet.CHANNEL_REPEAT, rch, raw)
			peripheral.call(side, "transmit", raw.nRecipient, rch, raw)
		end
	end
	return true
end

mdm.listen(os.getComputerID(),       onModemMessage)
mdm.listen(rednet.CHANNEL_BROADCAST, onModemMessage)
mdm.listen(rednet.CHANNEL_REPEAT,    onRepeatMessage)

local function onRednetMessage(ev, src, raw, protocol)
	log.debug("rednet msg from "..tostring(src).." on "..tostring(protocol))
	_handlers:fire(protocol, src, net.Message.unserialize(raw))
	return true
end

event.listen(event.rednet_message, onRednetMessage)

function net.listen(protocol, callback, arg)
	return _handlers:add(protocol, callback, arg)
end

function net.ignore(protocol, callback)
	_handlers:remove(protocol, callback)
end

function net.handlers(protocol)
	return _handlers:handlers(protocol)
end

-- following API of rednet.send
function net.send(dest, msg, protocol)
	local m = net.Message.new(protocol, msg, dest)
	seen(m)
	local modem = mdm.modem()
	if modem then
		modem.transmit(dest, os.getComputerID(), m:serialize())
	end
end

-- following API of rednet.broadcast
function net.broadcast(msg, protocol)
	net.send(rednet.CHANNEL_BROADCAST, msg, protocol)
end

-- TODO
function net.open(modem)
	modem.open(os.getComputerID())
	modem.open(rednet.CHANNEL_BROADCAST)
end

return net
