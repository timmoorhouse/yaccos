
local oo  = require("oo")
local log = require("log")

local tasks = {}
setmetatable(tasks, {
    __mode = "kv", -- Use weak references
})

Task = oo.class("task.Task")

function Task.new(self, klass)
    self = self or {}
    klass = klass or Task
    Task.super.new(self, klass)
    tasks[klass] = self
    return self
end

function Task.gc(self)
	tasks[getmetatable(self)] = nil
end

function Task.run(self, ...)
end

-- Class methods for Task and subclasses

function Task.instance(klass)
	return tasks[klass] or klass.new()
end

function Task.cmd(klass, op, ...)

	local self = klass:instance()
	local name = klass.name

	if not op or op == "run" then

	    self:run(...)

	else

	    error("Unsupported operation "..op)

	end
end

return Task
