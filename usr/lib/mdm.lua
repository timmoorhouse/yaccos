
local event = require("event")

local mdm = {}

-- TODO: use peripheral.find("modem")
function mdm.modem()
	for i,side in ipairs(rs.getSides()) do
		if peripheral.getType(side) == "modem" and peripheral.call(side, "isWireless") then
			return peripheral.wrap(side)
		end
	end
	return nil
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
