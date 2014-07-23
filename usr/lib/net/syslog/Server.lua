
local oo    = require("oo")
local task  = require("task")
local net   = require("net")
local types = require("types")

local syslogd = oo.class("net.syslogd", task.Daemon)

function syslogd.new(self, klass)
    self = self or {}
    syslogd.super.new(self, klass or syslogd)
    self._windows = types.List.new()
    return self
end

local function onMessage(self, protocol, src, msg)
    local m = msg:msg()
    for win in self._windows:iterator() do
        local x, y = win.getCursorPos()
        if x > 1 then
            local maxx, maxy = win.getSize()
            if y == maxy then
                win.scroll(1)
                win.setCursorPos(1, y)
            else
                win.setCursorPos(1, y+1)
            end
        end
        win.setTextColour(colours.yellow)
        win.write(string.format("%04d:%s", os.day(), textutils.formatTime(os.time(),true)))
        win.setTextColour(colours.green)
        win.write(string.format(" %-4s ", m.src))
        win.setTextColour(colours.white)
        win.write(m.msg)
    end
    return true
end

function syslogd.start(self, ...)
    local args = {...}

    if not self:status() then
        net.listen(net.syslog.protocol, onMessage, self)
        net.dns.host(net.syslog.protocol, net.hostname())
    end

    local win
    if args[1] and type(args[1]) == "table" then
        win = args[1]
    else
        local p = peripheral.find("monitor")
        if not p then
            p = term.current()
        end
        local w, h = p.getSize()
        win =  window.create(p, 1, 1, w, h)
    end

    self._windows:push_back(win)
end

function syslogd.status(self)
    return net.handlers(net.syslog.protocol) > 0
end

function syslogd.stop(self)
    if self:status() then
        net.dns.unhost(net.syslog.protocol)
        net.ignore(net.syslog.protocol, onMessage)
    end
end

return syslogd
