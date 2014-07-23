
local oo    = require("oo")
local bt    = require("bt")
local types = require("types")

--[[
	Base class for composite behaviours
]]

local Composite = oo.class("bt.Composite", bt.Behaviour)

function Composite.new(children, self, klass)
    self = self or {}
    Composite.super.new(self, klass or Composite)
    self._children = types.List.new()
    if children then
    	self:add(unpack(children))
    end
    return self
end

function Composite._onInitialize(self)
	self._current = 1
end

function Composite.add(self, ...)
    local children = {...}
    for k,b in pairs(children) do
        self._children:push_back(b)
        b._parent = self
    end
end

function Composite.remove(self, ...)
    local children = {...}
    for k,b in pairs(children) do
    	--b:abort()
        self._children:remove(b)
    end
end

function Composite.clear(self, ...)
    -- TODO
end

return Composite
