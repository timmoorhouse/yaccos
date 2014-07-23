
local oo = require("oo")

local Options = oo.class("cl.Options")

local defaults = {
	h = {
		name = "help",
		help = "Print help information and exit",
	},
}

function Options.new(spec, self, klass)
   	self = self or {}
    Options.super.new(self, klass or Options)
    self._spec = defaults
    for k,v in pairs(spec) do
    	self._spec[k] = v
    end
    self._value = {}
    return self
end

--[[
	spec format:

	{
		key = {
			name=string (defaults to key),
			default=value (defaults to nil),
			arg="number"|"string" (defaults to bool),
			help=string,
		}, ...
	}
]]

function Options._set(self, key, value)
	local name = self._spec[key].name or key
	local arg  = self._spec[key].arg

	if arg == "number" then
		value = tonumber(value)
	elseif arg == "key" then
		value = keys[value] or value
	end
	self._value[name] = value
end

function Options.set(self, args)

	if not args then
		error("missing args", 2)
	end

	self._value = {}
	for k,spec in pairs(self._spec) do
		if spec.default then
			self:_set(k, spec.default)
		end
	end

	while #args > 0 do

		if args[1] == "--" or string.sub(args[1],1,1) ~= "-" then
			break
		end

		local key = string.sub(args[1],2)
		local spec = self._spec[key]

		if not spec then
			error("invalid argument "..args[1])
		end

		if spec.arg then
			self:_set(key, args[2])
			table.remove(args, 1)
		else
			self:_set(key, true)
		end
		table.remove(args, 1)

	end

	--[[
	for i,v in ipairs(args) do
		print("i="..tostring(i).. " "..v)
	end
	]]

end

function Options.get(self, name)
	return self._value[name]
end

function Options.usage(self)
	print("Options:")
	for k,spec in pairs(self._spec) do
		write("  -"..k)
		if spec.arg then
			write(" a")
		else
			write("  ")
		end
		write("    ")
		if spec.help then
			write(" "..spec.help)
		end
		if spec.default then
			write(" (default=")
			    if spec.arg == "key" then
			    	write(keys.getName(spec.default))
			    else
			    	write(tostring(spec.default))
			    end
			write(")")
		end
		write("\n")
	end
end

return Options
