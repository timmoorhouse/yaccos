
local oo = require("oo")

local Handler = oo.class("event.Handler")

function Handler.new(handler, event, args, self, klass)
	if not handler then
		error("handler missing", 2)
	end
    self = self or {}
    Handler.super.new(self, klass or Handler)
    self._handler = handler
    self._event   = event
    self._args    = args
    return self
end

function Handler.fire(self, ...)
	if #self._args then
		local p = {}
		for i,v in pairs(self._args) do
			table.insert(p, v)
		end
		for i,v in pairs({...}) do
			table.insert(p, v)
		end
		return self._handler(unpack(p))

	else
		return self._handler(...)
	end
end

function Handler.event(self)
	return self._event
end

return Handler
