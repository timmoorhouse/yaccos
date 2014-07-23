
local telnet = {
	protocol = "telnet",
}

autoload(telnet, "net.telnet", "Client", "Server")

return telnet
