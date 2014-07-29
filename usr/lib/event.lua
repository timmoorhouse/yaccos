
--[[
	Event handling support

	listen() and ignore() work much like in the OpenComputers event library,
	with the exception that a parameter can be passed to listen to be used
	as the first parameter when the callback function is invoked.  We make
	it the first parameter so that a "self" value can be passed through in
	the appropriate way.

	If the handler returns false, the handler is deregistered.  Handlers
	must return true to receive notifications of further events.

]]

local event = {

	-- Standard events
	alarm             = "alarm",
	char              = "char",
	disk              = "disk",
	disk_eject        = "disk_eject",
	http_failure      = "http_failure",
	http_success      = "http_success",
	key               = "key",
	modem_message     = "modem_message",
	monitor_resize    = "monitor_resize",
	monitor_touch     = "monitor_touch",
	mouse_click       = "mouse_click",
	mouse_drag        = "mouse_drag",
	mouse_scroll      = "mouse_scroll",
	paste             = "paste",
	peripheral        = "peripheral",
	peripheral_detach = "peripheral_detach",
	rednet_message    = "rednet_message",
	redstone          = "redstone",
	term_resize       = "term_resize",
	terminate         = "terminate",
	timer             = "timer",
	turtle_inventory  = "turtle_inventory",
	turtle_response   = "turtle_response", -- TODO: obsolete?

	-- Locally added events
	dns               = "dns",
	idle              = "idle",
	quit              = "quit",
	rpc               = "rpc",
	timeout           = "timeout",
}

autoload(event, "event",
         "Event",
         "Handler",
         "KeyedEvent")

local hl = event.KeyedEvent.new()

function event.listen(ev, callback, ...)
	return hl:listen(ev, callback, ...)
end

function event.ignore(ev, callback)
	hl:ignore(ev, callback)
end

local idlePending = false
local depth = 0

function event.pull(filter, timeout_id)
	local ev
	depth = depth + 1
	while true do

        if not idlePending and hl:handlers(event.idle) > 0 and depth == 1 then
            os.queueEvent(event.idle)
            idlePending = true
        end

        ev = { os.pullEventRaw() }
        --if os.log then
        --	os.log("event.pull "..ev[1])
        --end

        -- Usually handled by os.pullEvent(), but we'll likely replace it
        -- TODO: leave this for os.pullEvent()???
        if ev[1] == event.terminate then
            error("Terminated", 0)
        end

        if ev[1] == event.timer and ev[2] == timeout_id then
        	ev = { timeout }
        	break
        end

        if ev[1] == event.quit then
            break
        end

        if ev[1] == event.idle then
            idlePending = false
        end

        hl:fire(unpack(ev))

        if not filter or filter == ev[1] then
        	break
        end

	end
	depth = depth - 1
	--print("returning "..ev[1])
	return unpack(ev)
end

function event.loop(timeout_id)
	return event.pull(event.quit, timeout_id)
end

return event
