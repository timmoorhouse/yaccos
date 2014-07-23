
local oo   = require("oo")
local task = require("task")
local net  = require("net")
local cl   = require("cl")

local Server = oo.class("net.telnet.Server", task.Daemon)

function Server.new(self, klass)
    self = self or {}
    Server.super.new(self, klass or Server)
    return self
end

local opt = cl.Options.new({
        t = {
            name    = "timeout",
            arg     = "number",
            default = 2,
            help    = "Timeout in seconds",
        },
    })

local proxy = {}
--[[
   TODO: maintain list of active clients, send/rpc to latest?
]]
function proxy.session(self, dest)
    print("telnet session active from "..tostring(dest))
    self._dest    = dest
    self._opts    = { timeout=opt:get("timeout"), }
    self._proxy   = net.rpc.proxy(net.telnet.protocol, dest, self._opts)
    self.getCursorPos = self._proxy.getCursorPos
    self.getSize      = self._proxy.getSize
    self.isColor      = self._proxy.isColor
    self.isColour     = self.isColor

    for i,v in ipairs({ "clear",
                        "clearLine",
                        "scroll",
                        "setBackgroundColor",
                        "setCursorBlink",
                        "setCursorPos",
                        "setTextColor",
                        "setTextScale",
                        "write",
                      }) do
        self[v] =
            function(...)
                net.send(self._dest, { op=v, args={...}, }, net.telnet.protocol)
            end
    end
    self.setBackgroundColour = self.setBackgroundColor
    self.setTextColour = self.setTextColor

    self._term = term.redirect(self)
    self.clear()
    self.setCursorPos(1,1)
    --os.run(_G, "rom/programs/shell")
    local f, err = loadfile("rom/programs/shell", nil, _G)
    --f("shell") -- skips rom/startup
    f() -- uses rom/startup
    net.send(self._dest, { op="quit" }, net.telnet.protocol)
    term.redirect(self._term)
    print("telnet session completed")
end

local function onMessage(proxy, protocol, src, msg)
    local m = msg:msg()
    if type(m) == "table" then
        if m.op == "event" then
	       os.queueEvent(unpack(m.ev))
        elseif m.op == "start" then
            proxy:session(src)
        end
    end
    return true
end

function Server.status(self)
    return net.handlers(net.telnet.protocol) > 0
end

function Server.start(self, ...)

    opt:set({...})

    --net.rpc.register(net.telnet.protocol, "start",
    --                 function()
    --                     print("STARTING TELNET SESSION")
    --                     local keys = {}
    --                     for k,v in pairs(_G) do
    --                        table.insert(keys, k)
    --                     end
    --                     print(table.concat(keys, " "))
    --                     proxy:start(net.rpc.rpcinfo())
    --                 end)
    net.rpc.register(net.telnet.protocol, "stop",
                     function()
                         print("STOPPING TELNET SESSION")
                         proxy:stop()
                     end)
    net.listen(net.telnet.protocol, onMessage, proxy)
    net.dns.host(net.telnet.protocol, net.hostname())
end

function Server.stop(self)
    net.dns.unhost(net.telnet.protocol)
    net.rpc.unregister(net.telnet.protocol)
    net.ignore(net.telnet.protocol, onMessage)
end

return Server
