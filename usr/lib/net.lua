
local event = require("event")
local mdm   = require("mdm")
local types = require("types")
local log   = require("log")

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

function net.hostname()
	return os.getComputerLabel() or "<"..tostring(os.getComputerID())..">"
end

-- **************************************************************************

local hl = event.KeyedEvent.new()

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

local function onRepeatMessage(sch, rch, raw, side, distance)
	if type(raw) == "table" and raw.nMessageID and raw.nRecipient then
		if not seen(raw.nMessageID) then
			peripheral.call(side, "transmit", rednet.CHANNEL_REPEAT, rch, raw)
			peripheral.call(side, "transmit", raw.nRecipient, rch, raw)
		end
	end
	return true
end

local _relaying = false

function net.relay(enable)
	if enable and not _relaying then
		mdm.listen(rednet.CHANNEL_REPEAT, onRepeatMessage)
	elseif _relaying and not enable then
		mdm.ignore(rednet.CHANNEL_REPEAT, onRepeatMessage)
	end
	_relaying = enable
end

function net.relaying()
	return _relaying
end

local function onModemMessage(sch, rch, raw, side, distance)
    if type(raw) == "table" and raw.nMessageID and not seen(raw.nMessageID) then -- TODO
	   	os.queueEvent(event.rednet_message, rch, raw.message, raw.sProtocol)
	end

	return true
end

mdm.listen(os.getComputerID(),       onModemMessage)
mdm.listen(rednet.CHANNEL_BROADCAST, onModemMessage)

local function onRednetMessage(ev, src, raw, protocol)
	--log.debug("rednet msg from "..tostring(src).." on "..tostring(protocol))
	hl:fire(protocol, src, net.Message.unserialize(raw))
	return true
end

event.listen(event.rednet_message, onRednetMessage)

function net.listen(protocol, callback, arg)
	return hl:listen(protocol, callback, arg)
end

function net.ignore(protocol, callback)
	hl:ignore(protocol, callback)
end

function net.handlers(protocol)
	return hl:handlers(protocol)
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

return net
