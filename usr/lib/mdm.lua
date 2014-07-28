
local event = require("event")

local mdm = {}

function mdm.modem()
	-- TODO: do we need the isWireless? wired modems may not show up in the getNames list
	return peripheral.find("modem", function(n,p) return p.isWireless() end)
end

local hl = event.KeyedEvent.new()

function mdm.listen(ch, handler, arg)
	if hl:handlers(ch) == 0 then
		local m = mdm.modem()
		if m then
			m.open(ch)
		end
	end
	return hl:listen(ch, handler, arg)
end

function mdm.ignore(ch, handler)
	hl:ignore(ch, handler)
	if hl:handlers(ch) == 0 then
		local m = mdm.modem()
		if m then
			m.close(ch)
		end
	end
end

function mdm.handlers(ch)
	return hl:handlers(ch)
end

local function onModemMessage(ev, side, sch, rch, raw, distance)
	hl:fire(sch, rch, raw, side, distance)
	return true
end

event.listen(event.modem_message, onModemMessage)

return mdm
