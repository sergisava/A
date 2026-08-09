--[[
    AERI HUB - BYPASS WRAPPER
    Cargar ESTE archivo por loadstring/URL primero.
    Parchea el script original en caliente:
      - KeylessUI = false -> true
      - Bypass HWID/keys
      - Bypass verificación interna Luraph v14.7
]]

-- Guardar referencias ORIGINALES antes de tocar nada
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

local function is_luraph_check(expr)
    expr = tostring(expr or "")
    return expr:find("45700", 1, true)
        or expr:find("0x1B,0x4C,0x75,0x61,0x50", 1, true)
        or expr:find("LuP", 1, true)
end

loadstring = function(expr, env)
    if is_luraph_check(expr) then
        return function() end
    end
    return _loadstring(expr, env)
end

pcall = function(f, ...)
    if f == _loadstring or f == loadstring or (type(f) == "string" and is_luraph_check(f)) then
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
-- BYPASS 3: HWID / Roblox device services
-- ============================================

local function safe_get_service(name)
    local ok, service = _pcall(function() return game:GetService(name) end)
    return ok and service or nil
end

local RbxAnalyticsService = safe_get_service("RbxAnalyticsService")
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    local originalGetClientId = RbxAnalyticsService.GetClientId
    RbxAnalyticsService.GetClientId = function()
        return "BYPASSED-CLIENT-ID-12345"
    end
end

local UserInputService = safe_get_service("UserInputService")
if UserInputService and UserInputService.GetPlatform then
    local originalGetPlatform = UserInputService.GetPlatform
    UserInputService.GetPlatform = function()
        return Enum.Platform.Windows
    end
end

local GuiService = safe_get_service("GuiService")
if GuiService and GuiService.GetPlatform then
    local originalGetPlatform = GuiService.GetPlatform
    GuiService.GetPlatform = function()
        return Enum.Platform.Windows
    end
end

-- ============================================
-- BYPASS 4: Fake environment values
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

warn("[AERI BYPASS] Bypasses aplicados. Cargando script original...")

-- ============================================
-- CARGA Y PARCHE DEL SCRIPT ORIGINAL
-- ============================================

local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script_original.lua"

local script_content = game:HttpGet(SCRIPT_URL)

-- Parche en caliente: cambiar KeylessUI = false -> true
script_content = string.gsub(
    script_content,
    "Sakura%.Options%.KeylessUI%s*=%s*false",
    "Sakura.Options.KeylessUI = true"
)

warn("[AERI BYPASS] Script cargado y parcheado.")

-- Ejecutar con loadstring usando la referencia original
local success, result = _pcall(_loadstring, script_content)
if success and result then
    result()
else
    warn("[AERI BYPASS] Error cargando script:", result)
end
