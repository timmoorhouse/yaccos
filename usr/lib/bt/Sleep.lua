
local oo = require("oo")
local bt = require("bt")

local Sleep = oo.class("bt.Sleep", bt.Behaviour)

function Sleep.new(delay, self, klass)
    self = self or {}
    Sleep.super.new(self, klass or Sleep)
    self._delay = delay
    return self
end

function Sleep._update(self, pad)
	--print("pre-sleep")
	os.sleep(self._delay)
	--print("post-sleep")
	return bt.Status.success
end

return Sleep
