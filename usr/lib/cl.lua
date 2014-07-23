
local cl = {}

autoload(cl, "cl", "Options")

-- For standalone tests
if not write then
	write = io.write
end

-- Command line support

return cl
