-- AERI HUB - XENO CHUNKED LOADER
-- Descarga el script en chunks pequeños para evitar truncado
-- Cargar ESTE script primero en Xeno

local CHUNK_SIZE = 2000
local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script_original.lua"

local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
local _RequestAsync = HttpService and HttpService.RequestAsync or nil

local function is_luraph_check(expr)
    expr = tostring(expr or "")
    return string.find(expr, "45700", 1, true) ~= nil
        or string.find(expr, "0x1B,0x4C,0x75,0x61,0x50", 1, true) ~= nil
end

local original_loadstring = _loadstring
loadstring = function(expr, env)
    if is_luraph_check(expr) then
        return function() end
    end
    return original_loadstring(expr, env)
end

local original_pcall = _pcall
pcall = function(f, ...)
    if f == original_loadstring or f == loadstring or (type(f) == "string" and is_luraph_check(f)) then
        return true, function() end
    end
    return original_pcall(f, ...)
end

local original_tostring = _tostring
tostring = function(v)
    if v == original_pcall or v == pcall or v == original_loadstring or v == loadstring then
        return "LuP"
    end
    return original_tostring(v)
end

local function should_block(url)
    url = string.lower(tostring(url or ""))
    local patterns = {"jnkie", "sakura", "key", "verify", "check", "auth", "license", "hwid", "hardware", "device"}
    for i = 1, #patterns do
        if string.find(url, patterns[i], 1, true) then
            return true
        end
    end
    return false
end

local function fake_response()
    return '{"status":"success","verified":true,"hwid":"BYPASSED","key":"BYPASSED"}'
end

if _HttpGet then
    game.HttpGet = function(self, url, ...)
        if should_block(url) then
            return fake_response()
        end
        return _HttpGet(self, url, ...)
    end
end

if HttpService and _RequestAsync then
    HttpService.RequestAsync = function(self, options)
        local url = tostring(options and options.Url or "")
        if should_block(url) then
            return {Success = true, StatusCode = 200, Body = fake_response(), StatusMessage = "OK"}
        end
        return _RequestAsync(self, options)
    end
end

if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().HWID = "BYPASSED-HWID"
    getgenv().SakuraVerified = true
end

if _G then
    _G.KeyVerified = true
    _G.LicenseKey = "BYPASSED"
    _G.HWID = "BYPASSED-HWID"
    _G.SakuraVerified = true
end

if identifyexecutor then
    getgenv and getgenv().identifyexecutor = function() return "Xeno", "1.3.60" end
end

local RbxAnalyticsService = pcall(function() return game:GetService("RbxAnalyticsService") end) and game:GetService("RbxAnalyticsService") or nil
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    RbxAnalyticsService.GetClientId = function() return "BYPASSED-" .. tostring(os.time()) end
end

local UserInputService = pcall(function() return game:GetService("UserInputService") end) and game:GetService("UserInputService") or nil
if UserInputService and UserInputService.GetPlatform then
    UserInputService.GetPlatform = function() return Enum.Platform.Windows end
end

local GuiService = pcall(function() return game:GetService("GuiService") end) and game:GetService("GuiService") or nil
if GuiService and GuiService.GetPlatform then
    GuiService.GetPlatform = function() return Enum.Platform.Windows end
end

warn("[AERI] Bypass aplicado. Descargando script por chunks...")

local chunks = {}
local total_size = 0
local offset = 1

for i = 1, 500 do
    local url = SCRIPT_URL .. "?chunk=" .. offset .. "&size=" .. CHUNK_SIZE
    local chunk = nil
    
    if HttpService and _RequestAsync then
        local ok, result = _pcall(function()
            return _RequestAsync(HttpService, {Url = url, Method = "GET"})
        end)
        if ok and result and result.Success and result.Body then
            chunk = result.Body
        end
    end
    
    if not chunk and _HttpGet then
        local ok, result = _pcall(function()
            return _HttpGet(game, url, true)
        end)
        if ok and result and #result > 0 then
            chunk = result
        end
    end
    
    if not chunk or chunk == "" or chunk == "EOF" then
        break
    end
    
    table.insert(chunks, chunk)
    total_size = total_size + #chunk
    offset = offset + CHUNK_SIZE
    
    if #chunk < CHUNK_SIZE then
        break
    end
end

local full_script = table.concat(chunks)
warn("[AERI] Descargado:", total_size, "chars")

if #full_script < 1000 then
    warn("[AERI] Error: script muy corto")
    return
end

if string.find(full_script, "Sakura%.Options%.KeylessUI%s*=%s*false", 1, true) then
    full_script = string.gsub(full_script, "Sakura%.Options%.KeylessUI%s*=%s*false", "Sakura.Options.KeylessUI = true")
    warn("[AERI] Parche aplicado")
end

local compiled, err = _pcall(original_loadstring, full_script)
if not compiled then
    warn("[AERI] Error compilando:", err)
    return
end

local success, exec_err = _pcall(compiled)
if not success then
    warn("[AERI] Error ejecutando:", exec_err)
else
    warn("[AERI] Script ejecutado OK")
end
