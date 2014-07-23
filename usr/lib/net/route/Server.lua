
local oo   = require("oo")
local net  = require("net")
local task = require("task")

local Server = oo.class("net.route.Server", task.Daemon)

function Server.new(self, klass)
    self = self or {}
    Server.super.new(self, klass or Server)
    return self
end

function Server.status()
    return net.relaying()
end

function Server.start()
    net.relay(true)
end

function Server.stop()
	net.relay(false)
end

return Server
