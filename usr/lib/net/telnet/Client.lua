-- -*- lua -*-

local oo    = require("oo")
local net   = require("net")
local cl    = require("cl")
local event = require("event")
local task  = require("task")

local Client = oo.class("net.telnet.Client", task.Task)

local opt = cl.Options.new({
        q = {
            name    = "quit",
            arg     = "key",
            default = keys.pause,
            help    = "Key to end session",
        },
        t = {
            name    = "timeout",
            arg     = "number",
            default = 2,
            help    = "Timeout in seconds",
        },
    })

function Client.new(self, klass)
    self = self or {}
    Client.super.new(self, klass or Client)
    return self
end

local function onMessage(win, protocol, src, msg)
    local m = msg:msg()
    if type(m) == "table" and m.op then
        if m.op == "quit" then
            os.queueEvent(event.quit)
        elseif win[m.op] then
            --print(m.op)
            win[m.op](unpack(m.args))
        end
    end
    return true
end

function Client.rpc(self, ...)
    return net.rpc.rpc(net.telnet.protocol, self.host, { timeout=opt:get("timeout"), }, ...)
end

function Client.transmit(self, msg)
    net.send(self.host, msg, net.telnet.protocol)
end

function Client.onEvent(self, ...)
    local ev = {...}

    if ev[1] == event.key and ev[2] == opt:get("quit") then
        print("DONE WITH SESSION") -- TODO
        _rpc("stop")
        os.queueEvent(event.quit) -- fall out of event.loop()
        return true
    end

    self:transmit({ op="event", ev=ev, })

    return true
end

function Client.run(self, ...)
    local args = {...}
    opt:set(args)

    if opt:get("help") or #args < 1 then
        opt:usage()
        return
    end

    local win  = term.current() -- TODO
    self.host = net.dns.resolve(net.telnet.protocol, args[1])
    if not self.host then
    	error("could not resolve hostname")
    end

    net.listen(net.telnet.protocol, onMessage, win)
    event.listen(event.char,           Client.onEvent, self)
    event.listen(event.key,            Client.onEvent, self)
    event.listen(event.mouse_click,    Client.onEvent, self)
    event.listen(event.mouse_scroll,   Client.onEvent, self)
    event.listen(event.mouse_drag,     Client.onEvent, self)
    event.listen(event.monitor_touch,  Client.onEvent, self)
    event.listen(event.monitor_resize, Client.onEvent, self)
    net.rpc.register(net.telnet.protocol, "getSize",      win.getSize)
    net.rpc.register(net.telnet.protocol, "getCursorPos", win.getCursorPos)
    net.rpc.register(net.telnet.protocol, "isColor",      win.isColor)

    -- self:rpc("start")
    self:transmit({ op="start" })

    event.loop()

    print("telnet session ended")

    net.ignore(net.telnet.protocol, onMessage)
    event.ignore(event.char,           Client.onEvent)
    event.ignore(event.key,            Client.onEvent)
    event.ignore(event.mouse_click,    Client.onEvent)
    event.ignore(event.mouse_scroll,   Client.onEvent)
    event.ignore(event.mouse_drag,     Client.onEvent)
    event.ignore(event.monitor_touch,  Client.onEvent)
    event.ignore(event.monitor_resize, Client.onEvent)
    net.rpc.unregister(net.telnet.protocol)

end

return Client
