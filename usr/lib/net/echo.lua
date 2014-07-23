
local echo = {
	protocols = {
		echo  = "echo",
		echor = "echor",
	}
}

autoload(echo, "net.echo", "Server")

return echo
