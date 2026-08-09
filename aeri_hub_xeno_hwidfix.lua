--[[
    AERI HUB - XENO HWID FIX
    Intercepta TODO antes de ejecutar el script:
    - HTTP (game.HttpGet, RequestAsync)
    - Servicios Roblox (RbxAnalyticsService, UserInputService, GuiService)
    - Variables de entorno (_G, getgenv)
    - Detecta executor (Xeno)
]]

-- ============================================
-- PASO 1: Guardar referencias ORIGINALES
-- ============================================
local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
local _RequestAsync = HttpService and HttpService.RequestAsync or nil
local _syn_request = syn and syn.request or nil

-- Detectar Xeno
local is_xeno = false
local xeno_version = "Unknown"
if identifyexecutor and type(identifyexecutor) == "function" then
    local ok, name, version = pcall(identifyexecutor)
    if ok and name and string.find(string.lower(name), "xeno", 1, true) then
        is_xeno = true
        xeno_version = tostring(version or "Unknown")
    end
end

warn("[AERI] Xeno detectado: " .. tostring(is_xeno) .. " v" .. xeno_version)

-- ============================================
-- PASO 2: BYPASS HTTP (antes de cargar el script)
-- ============================================
local blocked_domains = {
    "jnkie.com", "sakura", "key", "verify", "check", "auth",
    "license", "hwid", "hardware", "device", "fingerprint",
    "bloxfruit", "ale", "provider", "launch"
}

local function should_block(url)
    url = string.lower(tostring(url or ""))
    for i = 1, #blocked_domains do
        if string.find(url, blocked_domains[i], 1, true) then
            return true
        end
    end
    return false
end

local function fake_response()
    return '{"status":"success","verified":true,"hwid":"BYPASSED","key":"BYPASSED","device":"BYPASSED"}'
end

-- Interceptar game.HttpGet
game.HttpGet = function(self, url, ...)
    if should_block(url) then
        warn("[AERI] HTTP BLOQUEADO (HttpGet): " .. tostring(url))
        return fake_response()
    end
    return _HttpGet(self, url, ...)
end

-- Interceptar RequestAsync
if HttpService and _RequestAsync then
    HttpService.RequestAsync = function(self, options)
        local url = tostring(options and options.Url or "")
        if should_block(url) then
            warn("[AERI] HTTP BLOQUEADO (RequestAsync): " .. url)
            return {Success = true, StatusCode = 200, Body = fake_response(), StatusMessage = "OK"}
        end
        return _RequestAsync(self, options)
    end
end

-- Interceptar syn.request
if syn and _syn_request then
    syn.request = function(options)
        local url = tostring(options and options.Url or "")
        if should_block(url) then
            warn("[AERI] HTTP BLOQUEADO (syn.request): " .. url)
            return {Success = true, StatusCode = 200, Body = fake_response(), StatusMessage = "OK"}
        end
        return _syn_request(options)
    end
end

warn("[AERI] HTTP interceptado")

-- ============================================
-- PASO 3: BYPASS SERVICIOS ROBLOX (ANTES de cargar el script)
-- ============================================
local function safe_service(name)
    local ok, svc = _pcall(function() return game:GetService(name) end)
    return ok and svc or nil
end

-- RbxAnalyticsService.GetClientId - FINGERPRINT PRINCIPAL
local RbxAnalyticsService = safe_service("RbxAnalyticsService")
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    local original_GetClientId = RbxAnalyticsService.GetClientId
    RbxAnalyticsService.GetClientId = function()
        warn("[AERI] HWID BLOQUEADO: RbxAnalyticsService.GetClientId")
        return "BYPASSED-CLIENT-" .. tostring(os.time())
    end
    warn("[AERI] RbxAnalyticsService.GetClientId falsificado")
else
    warn("[AERI] RbxAnalyticsService no disponible")
end

-- UserInputService.GetPlatform
local UserInputService = safe_service("UserInputService")
if UserInputService and UserInputService.GetPlatform then
    UserInputService.GetPlatform = function()
        return Enum.Platform.Windows
    end
    warn("[AERI] UserInputService.GetPlatform falsificado")
end

-- GuiService.GetPlatform
local GuiService = safe_service("GuiService")
if GuiService and GuiService.GetPlatform then
    GuiService.GetPlatform = function()
        return Enum.Platform.Windows
    end
    warn("[AERI] GuiService.GetPlatform falsificado")
end

-- RunService:IsStudio() - algunos scripts verifican si no estás en Roblox
local RunService = safe_service("RunService")
if RunService and RunService.IsStudio then
    RunService.IsStudio = function()
        return false
    end
    warn("[AERI] RunService.IsStudio falsificado")
end

warn("[AERI] Servicios Roblox interceptados")

-- ============================================
-- PASO 4: BYPASS LURAPH v14.7
-- ============================================
local function is_luraph_check(expr)
    expr = tostring(expr or "")
    return string.find(expr, "45700", 1, true) ~= nil
        or string.find(expr, "0x1B,0x4C,0x75,0x61,0x50", 1, true) ~= nil
        or string.find(expr, "LuP", 1, true) ~= nil
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

warn("[AERI] Luraph bypass aplicado")

-- ============================================
-- PASO 5: VARIABLES DE ENTORNO FALSAS
-- ============================================
if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().AutoExecute = true
    getgenv().HWID = "BYPASSED-HWID"
    getgenv().DeviceID = "BYPASSED-DEVICE"
    getgenv().SakuraVerified = true
    getgenv().ExecutorName = "Xeno"
    getgenv().ExecutorVersion = xeno_version
end

if _G then
    _G.KeyVerified = true
    _G.LicenseKey = "BYPASSED"
    _G.AutoExecute = true
    _G.HWID = "BYPASSED-HWID"
    _G.DeviceID = "BYPASSED-DEVICE"
    _G.SakuraVerified = true
    _G.ExecutorName = "Xeno"
    _G.ExecutorVersion = xeno_version
end

if identifyexecutor then
    getgenv and getgenv().identifyexecutor = function() return "Xeno", xeno_version end
end

warn("[AERI] Variables de entorno inyectadas")

-- ============================================
-- PASO 6: CARGAR SCRIPT ORIGINAL
-- ============================================
local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script_original.lua"
warn("[AERI] Descargando script desde: " .. SCRIPT_URL)

local script_content = nil

-- Metodo 1: game.HttpGet (en Xeno trunca, pero lo intentamos)
if _HttpGet then
    warn("[AERI] Intentando game.HttpGet...")
    local ok, result = _pcall(function()
        return _HttpGet(game, SCRIPT_URL, true)
    end)
    if ok and result and #result > 1000 then
        script_content = result
        warn("[AERI] game.HttpGet EXITO: " .. tostring(#script_content) .. " chars")
    else
        warn("[AERI] game.HttpGet fallo o respuesta corta: " .. tostring(#result or 0) .. " chars")
        script_content = nil
    end
end

-- Metodo 2: RequestAsync
if not script_content and HttpService and _RequestAsync then
    warn("[AERI] Intentando RequestAsync...")
    local ok, result = _pcall(function()
        return _RequestAsync(HttpService, {Url = SCRIPT_URL, Method = "GET"})
    end)
    if ok and result and result.Success and result.Body and #result.Body > 1000 then
        script_content = result.Body
        warn("[AERI] RequestAsync EXITO: " .. tostring(#script_content) .. " chars")
    else
        warn("[AERI] RequestAsync fallo")
        script_content = nil
    end
end

-- Metodo 3: syn.request
if not script_content and syn and _syn_request then
    warn("[AERI] Intentando syn.request...")
    local ok, result = _pcall(function()
        return _syn_request({Url = SCRIPT_URL, Method = "GET"})
    end)
    if ok and result and result.Body and #result.Body > 1000 then
        script_content = result.Body
        warn("[AERI] syn.request EXITO: " .. tostring(#script_content) .. " chars")
    else
        warn("[AERI] syn.request fallo")
        script_content = nil
    end
end

if not script_content then
    warn("[AERI] ERROR: No se pudo descargar el script")
    return
end

-- ============================================
-- PASO 7: PARCHE Y EJECUCION
-- ============================================
warn("[AERI] Parcheando script...")

if string.find(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", 1, true) then
    script_content = string.gsub(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", "Sakura.Options.KeylessUI = true")
    warn("[AERI] Parche KeylessUI aplicado")
else
    warn("[AERI] KeylessUI=false no encontrado")
end

warn("[AERI] Compilando script...")

local compiled, err = _pcall(original_loadstring, script_content)
if not compiled then
    warn("[AERI] Error compilando:", err)
    return
end

warn("[AERI] Ejecutando script...")

local success, exec_err = _pcall(compiled)
if not success then
    warn("[AERI] Error ejecutando:", exec_err)
else
    warn("[AERI] Script ejecutado correctamente")
end
