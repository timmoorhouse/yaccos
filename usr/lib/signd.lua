
local oo    = require("oo")
local task  = require("task")
local net   = require("net")
local event = require("event")
local types = require("types")

local signd = oo.class("signd", task.Daemon)

function signd.new(self, klass)
    self = self or {}
    signd.super.new(self, klass or signd)

    self._panes    = types.List.new()
    self._idx      = 1
    self._timer_id = -1
    self._delay    = 5

    return self
end

local function onTimer(self, ev, id)
    if id == self._timer_id then
        --print("TIMER")

        if self._idx <= self._panes:size() then
            local win = self._panes:element(self._idx)
            win.setVisible(false)
        end

        self._idx = self._idx + 1
        if self._idx > self._panes:size() then
            self._idx = 1
        end

        if self._idx <= self._panes:size() then
            local win = self._panes:element(self._idx)
            win.setVisible(true)
        end

        self._timer_id = os.startTimer(self._delay)
    end
    return true
end

function signd.status(self)
    return self._panes:size() > 0
end

function signd.start(self)
    local p = peripheral.find("monitor")
    if not p then
        p = term.current()
    end

    local w, h = p.getSize()
    win = window.create(p, 1, 1, w, h, false)
    net.syslog.Server:instance():start(win)
    self._panes:push_back(win)

    win = window.create(p, 1, 1, w, h, false)
    win.write("pane #2")
    self._panes:push_back(win)

    event.listen(event.timer, onTimer, self)

    self._timer_id = os.startTimer(self._delay)
end

function signd.stop()



end

return signd
