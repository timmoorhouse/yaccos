
local oo   = require("oo")
local net  = require("net")
local task = require("task")

local Server = oo.class("net.echo.Server", task.Daemon)

function Server.new(self, klass)
    self = self or {}
    Server.super.new(self, klass or Server)
    return self
end

local function onMessage(protocol, src, msg)
    net.send(src, msg:msg(), net.echo.protocols.echor, msg:msg())
    return true
end

function Server.status(self)
    return net.handlers(net.echo.protocols.echo) > 0
end

function Server.start(self)
    net.listen(net.echo.protocols.echo, onMessage)
    net.dns.host(net.echo.protocols.echo, net.hostname())
end

function Server.stop(self)
    net.dns.unhost(net.echo.protocols.echo)
    net.ignore(net.echo.protocols.echo, onMessage)
end

return Server
