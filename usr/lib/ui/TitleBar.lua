
local oo  = require("oo")
local ui  = require("ui")
local log = require("log")

local TitleBar = oo.class("ui.TitleBar", ui.Window)

function TitleBar.new(parent, x, y, w, h, self, klass)
    self = self or {}
    TitleBar.super.new(parent, x, y, w, h, self, klass or TitleBar)
    --if self:isColour() then
    	self:setBackgroundColour(colours.purple)
    	self:setTextColour(colours.orange)
    --else
    	self:setBackgroundColour(colours.white)
    	self:setTextColour(colours.black)
    --end
    self._title = "Title"
    return self
end

function TitleBar.onRedraw(self)
	local w, h = self:getSize()

	local pad = math.max(0, w-#self._title)
	self:setCursorPos(1, 1)
	self:write(string.rep(" ", pad/2)..self._title..string.rep(" ", (pad+1)/2))

	self:setCursorPos(w-2, 1)
	self:write("_^X")

	self:setCursorPos(1, 1)
	self:write("*")
end

function TitleBar.onClick(self, x, y, button)
	log.debug("TitleBar.onClick!!! x="..tostring(x).." y="..tostring(y))
	self._click = { x, y }
	local w, h = self:getSize()
	if y == 1 then
		if x == 1 then
			self._title = "MENU"
		elseif x == w then
			self._title = "CLOSE"
		elseif x == w-1 then
			self._title = "MAXIMIZE"
		elseif x == w-2 then
			self._title = "MINIMIZE"
		else
			self._parent:raise() -- TODO
			self._title = "Title"
		end
		log.debug("title now "..self._title)
		self:redraw()
	end
end

function TitleBar.onDrag(self, x, y, button)
	log.debug("TitleBar.onDrag x="..tostring(x).." y="..tostring(y))
	if button == 1 and self._parent then
		local px, py = self._parent:getPosition()
		self._parent:reposition(px+x-self._click[1], py+y-self._click[2])
		self._parent:_invalidate()
	end
end

return TitleBar

