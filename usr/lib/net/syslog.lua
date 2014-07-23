
local net = require("net")
local log = require("log")

local syslog = {
	protocol = "syslog",
}

autoload(syslog, "net.syslog", "Server")

function syslog.log(msg)
	log.debug(textutils.serialize(msg))
    net.broadcast({ src=net.hostname(), msg=msg, }, syslog.protocol)
	--print(msg)
end

return syslog
