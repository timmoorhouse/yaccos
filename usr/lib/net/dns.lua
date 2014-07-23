
local event = require("event")
local net   = require("net")

local dns = {
    protocol = "dns",
}

local _hostnames = {}

local types = {
	lookup   = "lookup",
	response = "lookup response",
}

local function onMessage(protocol, src, msg)
	local m = msg:msg()
    if m.sType == types.lookup then
	    --print("dns request")
	    --print(textutils.serialize(m))
    	local hostname = _hostnames[m.sProtocol]
    	--print("existing=["..tostring(hostname).."]")
        if hostname ~= nil and (m.sHostname == nil or m.sHostname == hostname) then
        	--print("FOUND")
    		net.send(src, {
                	sType     = types.response,
                	sHostname = hostname,
                	sProtocol = m.sProtocol,
                }, protocol)
		end
	else
		os.queueEvent(event.dns, m.sProtocol, m.sHostname, src)
    end
    return true
end

net.listen(dns.protocol, onMessage)

-- TODO
function dns.lookup(proto, hostname)
    if type(proto) ~= "string" then
        error("expected string", 2)
    end

    -- Build list of host IDs
    local results = nil
    if hostname == nil then
        results = {}
    end

    -- Check localhost first
    if _hostnames[proto] then
        if hostname == nil then
            table.insert(results, os.getComputerID())
        elseif hostname == "localhost" or hostname == _hostnames[proto] then
            return os.getComputerID()
        end
    end

    if not rednet.isOpen() then
        if results then
            return unpack(results)
        end
        return nil
    end

    -- Broadcast a lookup packet
    net.broadcast({
        sType     = types.lookup,
        sProtocol = proto,
        sHostname = hostname,
    }, dns.protocol)

    local timeout = 2 -- TODO
    local timeout_id = os.startTimer(timeout)
    while true do
    	local ev = { event.pull(event.dns, timeout_id) }
    	-- TODO: check that this is our query
    	if ev[1] == event.dns then
    		local addr = tonumber(ev[4])
    		--print("GOT "..tostring(addr))
    		if hostname == nil then
    			table.insert(results, addr)
    		else
    			return addr
    		end
    	else
    		net.syslog.log("DNS lookup of "..tostring(proto)..":"..tostring(hostname).." timed out")
    		--error("DNS timeout")
    		break
    	end
    end

    --print(textutils.serialize(results))
    if results then
        return unpack(results)
    end
    return nil
end

function dns.resolve(protocol, hostname)
    if hostname == nil then
        return dns.lookup(protocol, hostname)
    elseif type(hostname) == "number" then
        return hostname
    elseif type(hostname) == "string" then
        local id = tonumber(hostname)
        if id then
            return id
        else
            return dns.lookup(protocol, hostname)
        end
    else
        error("expected number or string for hostname", 2)
    end
    return nil
end

function dns.host(protocol, hostname)
    if type(protocol) ~= "string" or type(hostname) ~= "string" then
        error("expected string, string", 2)
    end
    if hostname == "localhost" then
        error("Reserved hostname", 2)
    end
    if _hostnames[protocol] ~= hostname then
        if dns.lookup(protocol, hostname) ~= nil then
            error("Hostname in use", 2)
        end
        _hostnames[protocol] = hostname
    end
end

function dns.unhost(protocol)
    if type(protocol) ~= "string" then
        error("expected string", 2)
    end
    _hostnames[protocol] = nil
end

return dns
