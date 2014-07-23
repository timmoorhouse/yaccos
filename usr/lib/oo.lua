
--[[
    A simple OOP framework supporting single inheritance.
    All classes share a common base class of Object.

    Conventions:
    * All class names should be capitalized.
    * Classes should generally have a new(self, klass) method.

    TODO:
    * Turn class into a class??
]]

local oo = {}

local Object = nil

local last_oid = 0

local oid_map = {}
setmetatable(oid_map, { __mode = "kv" }) -- weak references

local function serialize(v, visited)
    visited = visited or {}
    local t = type(v)
    if t == "table" then
        if visited[v] then
	        return "..."
	        --error("cannot serialize recursive tables")
        end
        visited[v] = true
        local r = "{"
        for k,v in pairs(v) do
	        r = r .. "[" .. serialize(k,visited) .. "]=" .. serialize(v,visited) .. ","
        end
        r = r .. "}"
        return r
    elseif t == "string" then
        return string.format("%q",v)
    elseif t == "number" or t == "boolean" or t == "nil" then
        return tostring(v)
    elseif t == "function" then
        return "<function>"
    else
        error("cannot serialize type "..t, 2)
    end
end

-- TODO: weak references for classes?
local classes = {}
setmetatable(classes, { __mode = "kv" }) -- weak references

function oo.class(name, super)
    if classes[name] then
        --error("class "..name.." already defined", 2)
    end
    local c = {
        name  = name or "undefined",
        super = super or Object,
        __index =
            function(t,k)
 	            return getmetatable(t)[k]
 	      end,
        __tostring =
            function(self)
                return self:tostring()
            end,
        -- TODO: copy entries from super so that operators work?
        __gc =
            function(self)
                if self.gc then
                    self:gc()
                end
            end,
    }
    c.new =
        function(self, klass)
 	        self = self or {}
            last_oid = last_oid + 1
            self._oid = last_oid
            setmetatable(self, klass)
            oid_map[self._oid] = self
 	        return self
        end
    setmetatable(c, {
        __index =
            function(t,k)
                while true do
                    t = rawget(t, "super")
                    if not t then
                        return nil
                    end
                    local f = rawget(t, k)
                    if f then
                        return f
                    end
                end
            end,
        })
    classes[name] = c
    return c
end

Object = oo.class("Object")

function oo.find(name)
    return classes[name]
end

function Object.tostring(self)
    --return serialize(self)
    return getmetatable(self).name
end

function Object.serialize(self)
    return serialize(self)
end

function Object.oid(self)
    return self._oid
end

function Object.isa(self, klass)
    local t = getmetatable(self)
    while t do
       if t == klass then
	       return true
       end
       t = t.super
    end
    return false
end

oo.Object = Object

function oo.isa(obj, klass)
    if type(obj) ~= "table" or not obj.isa then
        return false
    end
    return obj:isa(klass)
end

function oo.object(oid)
    return oid_map[oid]
end

return oo
