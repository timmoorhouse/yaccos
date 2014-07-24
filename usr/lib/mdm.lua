
local event = require("event")

local mdm = {}

function mdm.modem()
	-- TODO: do we need the isWireless? wired modems may not show up in the getNames list
	return peripheral.find("modem", function(n,p) return p.isWireless() end)
end

local _handlers = event.HandlerList.new()

function mdm.listen(ch, handler, arg)
	-- TODO: auto open
	return _handlers:add(ch, handler, arg)
end

function mdm.ignore(ch, handler)
	_handlers:remove(ch, handler)
end

function mdm.handlers(ch)
	return _handlers:handlers(ch)
end

local function onModemMessage(ev, side, sch, rch, raw, distance)
	_handlers:fire(sch, rch, raw, side, distance)
	return true
end

event.listen(event.modem_message, onModemMessage)

return mdm
