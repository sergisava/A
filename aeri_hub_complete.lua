-- AERI HUB - COMPLETE WRAPPER
local _pcall, _loadstring, _tostring, _HttpGet = pcall, loadstring, tostring, game.HttpGet
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
local _RequestAsync = HttpService and HttpService.RequestAsync

local function is_luraph(expr)
    return string.find(_tostring(expr or ""), "45700", 1, true) ~= nil
end

loadstring = function(expr, env)
    if is_luraph(expr) then return function() end end
    return _loadstring(expr, env)
end

pcall = function(f, ...)
    if f == _loadstring or f == loadstring or (type(f) == "string" and is_luraph(f)) then
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

local function block(url)
    url = string.lower(_tostring(url or ""))
    return string.find(url, "jnkie", 1, true) or string.find(url, "sakura", 1, true) or string.find(url, "key", 1, true) or string.find(url, "hwid", 1, true)
end

if _HttpGet then
    game.HttpGet = function(self, url, ...)
        if block(url) then return '{"status":"success"}' end
        return _HttpGet(self, url, ...)
    end
end

if _RequestAsync then
    HttpService.RequestAsync = function(self, options)
        local url = _tostring(options and options.Url or "")
        if block(url) then return {Success = true, StatusCode = 200, Body = '{"status":"success"}', StatusMessage = "OK"} end
        return _RequestAsync(self, options)
    end
end

if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().HWID = "BYPASSED"
end

if _G then
    _G.KeyVerified = true
    _G.LicenseKey = "BYPASSED"
    _G.HWID = "BYPASSED"
end

local RbxAnalyticsService = pcall(function() return game:GetService("RbxAnalyticsService") end) and game:GetService("RbxAnalyticsService") or nil
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    RbxAnalyticsService.GetClientId = function() return "BYPASSED" end
end

local UserInputService = pcall(function() return game:GetService("UserInputService") end) and game:GetService("UserInputService") or nil
if UserInputService and UserInputService.GetPlatform then
    UserInputService.GetPlatform = function() return Enum.Platform.Windows end
end

local GuiService = pcall(function() return game:GetService("GuiService") end) and game:GetService("GuiService") or nil
if GuiService and GuiService.GetPlatform then
    GuiService.GetPlatform = function() return Enum.Platform.Windows end
end

local script_content = game:HttpGet("https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script_original.lua", true)

if string.find(script_content, "KeylessUI%s*=%s*false", 1, true) then
    script_content = string.gsub(script_content, "KeylessUI%s*=%s*false", "KeylessUI = true")
end

local compiled, err = _pcall(_loadstring, script_content)
if not compiled then
    warn("[AERI] Error:", err)
    return
end

local success, exec_err = _pcall(compiled)
if not success then
    warn("[AERI] Error:", exec_err)
end

