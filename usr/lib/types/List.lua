
local oo = require("oo")

local List = oo.class("types.List")

function List.new(self, klass)
    self = self or {}
    List.super.new(self, klass or List)
    self:clear()
    return self
end

function List.clear(self)
    self._begin = 0
    self._end   = 0
    self._list  = {} -- elements in use are [begin,end)
end

function List.push_back(self, e)
	self._list[self._end] = e
	self._end = self._end + 1
end

function List.push_front(self, e)
	self._begin = self._begin - 1
	self._list[self._begin] = e
end

function List.pop_front(self)
	if self:empty() then
		error("pop on empty list", 2)
	end
	self._begin = self._begin + 1
	return self._list[self._begin-1]
end

function List.pop_back(self)
	if self:empty() then
		error("pop on empty list", 2)
	end
	self._end = self._end - 1
	return self._list[self._end]
end

function List.front(self)
	if self:empty() then
		return nil
	end
	return self._list[self._begin]
end

function List.back(self)
	if self:empty() then
		return nil
	end
	return self._list[self._end-1]
end

function List.size(self)
	return self._end - self._begin
end

List.__len = List.size

function List.empty(self)
	return self:size() == 0
end

function List.find(self, e)
	for i = 1,self:size()-1 do
		if self:element(i) == e then
			return i
		end
	end
end

function List.remove_if(self, f)
	local ni = self._begin
	for i = self._begin, self._end-1, 1 do
		if not f(self._list[i]) then
			self._list[ni] = self._list[i]
			ni = ni + 1
		end
	end
	for i = ni+1, self._end-1, 1 do
		self._list[i] = nil
	end
	self._end = ni
end

function List.remove(self, e)
	self:remove_if(function(elt) return elt == e end)
end

-- TODO: add index to metatable so we can just use list[idx]
function List.element(self, idx)
	local size = self:size()
	if idx == 0 or idx > size or idx < -size then
		error("invalid index", 2)
	end
	if idx > 0 then
		return self._list[self._begin+idx-1]
	else
		return self._list[self._end+idx]
	end
end

--function List.__index2(self, v)
--	if type(v) == "number" then
--		return List.element(self, v)
--	else
--		return List.super[v]
--	end
--end

--List.__index = List.element

function List.iterator(self)
	-- return iterator function, invariant state, initial value
	-- iterator called with invariant state, current value
	local iter =
		function(st, cur)
			if st.i < st.l._end then
				local elt = st.l._list[st.i]
				st.i = st.i+1
				return elt
			end
		end
	return iter, { l=self, i=self._begin }
end

function List.reverse_iterator(self)
	local iter =
		function(st, cur)
			if st.i > st.l._begin then
				st.i = st.i-1
				local elt = st.l._list[st.i]
				return elt
			end
		end
	return iter, { l=self, i=self._end }
end

function List.__ipairs(self)
	local iter =
		function(self, cur)
			if cur < self:size() then
				return cur+1, self:element(cur+1)
			end
		end
	return iter, self, 0
end

return List
