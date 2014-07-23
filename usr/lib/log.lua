
local log = {}

function log.debug(msg)
	if os.log then
		os.log(msg)
	end
	--print(msg)
end

function log.init_success(msg)
	term.setTextColour(colours.white)
	write("[")
	term.setTextColour(colours.green)
	write(" ok ")
	term.setTextColour(colours.white)
	write("] "..msg)
	write("\n")
end

function log.init_failure(msg)
	term.setTextColour(colours.white)
	write("[")
	term.setTextColour(colours.red)
	write("FAIL")
	term.setTextColour(colours.white)
	write("] "..msg)
	write("\n")
end

return log
