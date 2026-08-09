--[[
    AERI HUB - HWID/KEY BYPASS WRAPPER
    Cargar ESTE archivo por loadstring/URL primero.
    El wrapper aplica los bypasses y luego carga el script ofuscado original.
]]

-- Guardar referencias originales PRIMERO
local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet
local HttpService = game:GetService("HttpService")
local _RequestAsync = HttpService.RequestAsync
local _syn_request = syn and syn.request

-- ============================================
-- BYPASS 1: Luraph v14.7 internal packed-hash check
-- ============================================

pcall = function(f, ...)
    if f == _loadstring or (type(f) == "string" and f:find("loadstring", 1, true)) then
        return true, function() end
    end
    return _pcall(f, ...)
end

loadstring = function(expr, env)
    expr = tostring(expr or "")
    if expr:find("45700") or expr:find("0x1B,0x4C,0x75,0x61,0x50") or expr:find("LuP") then
        return function() end
    end
    return _loadstring(expr, env)
end

tostring = function(v)
    if v == _pcall then
        return "LuP"
    end
    return _tostring(v)
end

-- ============================================
-- BYPASS 2: HTTP verification (keys / HWID)
-- ============================================

game.HttpGet = function(self, url, ...)
    url = tostring(url or "")
    local blocked = {
        "jnkie.com", "sakura", "key", "verify", "check", "auth",
        "license", "hwid", "hardware", "device", "fingerprint",
        "bloxfruit", "ale", "provider", "launch"
    }
    for _, p in ipairs(blocked) do
        if url:lower():find(p, 1, true) then
            return '{"status":"success","verified":true,"hwid":"BYPASSED","key":"BYPASSED"}'
        end
    end
    return _HttpGet(self, url, ...)
end

if HttpService and _RequestAsync then
    HttpService.RequestAsync = function(self, options)
        local url = tostring(options and options.Url or "")
        local blocked = {
            "jnkie.com", "sakura", "key", "verify", "check", "auth",
            "license", "hwid", "hardware", "device", "fingerprint"
        }
        for _, p in ipairs(blocked) do
            if url:lower():find(p, 1, true) then
                return {
                    Success = true,
                    StatusCode = 200,
                    Body = '{"status":"success","verified":true,"hwid":"BYPASSED"}',
                    StatusMessage = "OK"
                }
            end
        end
        return _RequestAsync(self, options)
    end
end

if syn and _syn_request then
    syn.request = function(options)
        local url = tostring(options and options.Url or "")
        local blocked = {
            "jnkie.com", "sakura", "key", "verify", "check", "auth",
            "license", "hwid", "hardware", "device", "fingerprint"
        }
        for _, p in ipairs(blocked) do
            if url:lower():find(p, 1, true) then
                return {
                    Success = true,
                    StatusCode = 200,
                    Body = '{"status":"success","verified":true,"hwid":"BYPASSED"}',
                    StatusMessage = "OK"
                }
            end
        end
        return _syn_request(options)
    end
end

-- ============================================
-- BYPASS 3: Fake environment values
-- ============================================

if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().AutoExecute = true
    getgenv().HWID = "BYPASSED-HWID"
    getgenv().DeviceID = "BYPASSED-DEVICE"
    getgenv().SakuraVerified = true
end

if _G then
    _G.KeyVerified = true
    _G.LicenseKey = "BYPASSED"
    _G.AutoExecute = true
    _G.HWID = "BYPASSED-HWID"
    _G.DeviceID = "BYPASSED-DEVICE"
    _G.SakuraVerified = true
end

if identifyexecutor then
    getgenv and getgenv().identifyexecutor = function() return "None", "1.0.0" end
end

warn("[AERI BYPASS] Bypasses aplicados. Cargando script ofuscado original...")

-- ============================================
-- CARGA DEL SCRIPT OFUSCADO ORIGINAL
-- ============================================
-- Opción A: cargar desde URL raw de GitHub
local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/AeriHub-Desofuscado/main/script_original.lua"

-- Opción B: pegar el script ofuscado completo dentro de [[ ... ]]
-- (descomenta la opción que prefieras)

local script_content = game:HttpGet(SCRIPT_URL)
local success, result = _pcall(_loadstring, script_content)
if success and result then
    result()
else
    warn("[AERI BYPASS] Error cargando script:", result)
end
