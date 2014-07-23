
local oo   = require("oo")
local task = require("task")
local log  = require("log")

Daemon = oo.class("task.Daemon", task.Task)

function Daemon.new(self, klass)
    self = self or {}
    klass = klass or Daemon
    Daemon.super.new(self, klass)
    return self
end

function Daemon.start(self)
end

function Daemon.status(self)
	return false
end

function Daemon.stop(self)
end

function Daemon.run(self, ...)
	self:start(...)
	event.loop()
	self:stop()
end

-- Class methods for Daemon and subclasses

function Daemon.cmd(klass, op, ...)

	local self = klass:instance()
	local name = klass.name

	if not op or op == "start" then

	    if not self:status() then
	        self:start(...)
	        if self:status() then
	            log.init_success(name.." started")
	        else
	            log.init_failure(name.." failed")
	        end
	    end

	elseif op == "stop" then

	    if self:status() then
	        self:stop(...)
	        if self:status() then
	            log.init_failure(name.." failed")
	        else
	            log.init_success(name.." stopped")
	        end
	    end

	elseif op == "status" then

	    if self:status() then
	        print(name.." running")
	    else
	        print(name.." not running")
	    end

	elseif op == "run" then

	    self:run(...)

	else

	    error("Unsupported operation "..op)

	end
end

return Daemon
