
local oo   = require("oo")
local net  = require("net")
local cl   = require("cl")
local log  = require("log")
local task = require("task")

local Server = oo.class("net.status.Server", task.Daemon)

function Server.new(self, klass)
    self = self or {}
    Server.super.new(self, klass or Server)
    return self
end

--[[
    location?
    completion percentage?
    status flag (error, etc)?
    action required flag?
    status text
    uptime?
    time
]]

local opt = cl.Options.new({
--        c = {
--            name    = "channel",
--            arg     = "number",
--            default = net.channels.status,
--            help    = "Channel to listen on",
--        },
    })

local function onMessage(protocol, src, msg)
    --print("got echo message, replying on "..tostring(rch))
    --net.transmit(modem, rch, 0, msg:msg())
    --return true
end

function Server.status(self)
    return net.handlers(net.status.protocol) > 0
end

function Server.start(self, ...)
    opt:set({...})
    net.listen(net.status.protocol, onMessage)
    net.dns.host(net.status.protocol, net.hostname())
end

function Server.stop(self)
    net.dns.unhost(net.status.protocol)
    net.ignore(net.status.protocol, onMessage)
end

return Server
