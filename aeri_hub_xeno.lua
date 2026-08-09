--[[
    AERI HUB - XENO ONE-FILE WRAPPER
    Todo en un solo archivo: bypass Luraph, HTTP, HWID, descarga y ejecucion.
    Optimizado para Xeno v1.3.x
]]

-- ============================================
-- LOGGING
-- ============================================
local AERI_LOG = {}
_G.AERI_LOG = AERI_LOG

local function log(msg)
    local line = "[" .. tostring(os.time()) .. "] " .. tostring(msg)
    table.insert(AERI_LOG, line)
    pcall(function() warn("[AERI]", line) end)
end

local function save_log()
    local path = "AeriHub_Xeno_Log.txt"
    local content = ""
    for i = 1, #AERI_LOG do
        if i > 1 then content = content .. "\n" end
        content = content .. AERI_LOG[i]
    end
    pcall(function()
        if writefile then
            writefile(path, content)
        end
    end)
end

log("========================================")
log("AERI HUB - XENO ONE-FILE WRAPPER")
log("========================================")

-- ============================================
-- DETECTAR XENO
-- ============================================
local xeno_version = "Unknown"
if identifyexecutor and type(identifyexecutor) == "function" then
    local ok, name, version = pcall(identifyexecutor)
    if ok then
        xeno_version = tostring(name or "Xeno") .. " " .. tostring(version or "")
    end
end
log("Executor: " .. xeno_version)

-- ============================================
-- GUARDAR REFERENCIAS
-- ============================================
local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
local _RequestAsync = HttpService and HttpService.RequestAsync or nil
local _syn_request = syn and syn.request or nil

-- ============================================
-- BYPASS LURAPH v14.7
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
        log("BYPASS: loadstring Luraph interceptado")
        return function() end
    end
    return original_loadstring(expr, env)
end

local original_pcall = _pcall
pcall = function(f, ...)
    if f == original_loadstring or f == loadstring or (type(f) == "string" and is_luraph_check(f)) then
        log("BYPASS: pcall Luraph interceptado")
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

log("Bypass Luraph aplicado")

-- ============================================
-- BYPASS HTTP
-- ============================================
local function should_block(url)
    url = string.lower(tostring(url or ""))
    local patterns = {
        "jnkie", "sakura", "key", "verify", "check", "auth",
        "license", "hwid", "hardware", "device", "fingerprint",
        "bloxfruit", "ale", "provider", "launch"
    }
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
            log("BYPASS HTTP: game.HttpGet bloqueada: " .. tostring(url))
            return fake_response()
        end
        return _HttpGet(self, url, ...)
    end
end

if HttpService and _RequestAsync then
    HttpService.RequestAsync = function(self, options)
        local url = tostring(options and options.Url or "")
        if should_block(url) then
            log("BYPASS HTTP: RequestAsync bloqueada: " .. url)
            return {Success = true, StatusCode = 200, Body = fake_response(), StatusMessage = "OK"}
        end
        return _RequestAsync(self, options)
    end
end

if syn and _syn_request then
    syn.request = function(options)
        local url = tostring(options and options.Url or "")
        if should_block(url) then
            log("BYPASS HTTP: syn.request bloqueada: " .. url)
            return {Success = true, StatusCode = 200, Body = fake_response(), StatusMessage = "OK"}
        end
        return _syn_request(options)
    end
end

log("Bypass HTTP aplicado")

-- ============================================
-- BYPASS HWID
-- ============================================
local function safe_service(name)
    local ok, svc = pcall(function() return game:GetService(name) end)
    return ok and svc or nil
end

local RbxAnalyticsService = safe_service("RbxAnalyticsService")
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    RbxAnalyticsService.GetClientId = function() return "BYPASSED-" .. tostring(os.time()) end
    log("BYPASS HWID: RbxAnalyticsService.GetClientId")
end

local UserInputService = safe_service("UserInputService")
if UserInputService and UserInputService.GetPlatform then
    UserInputService.GetPlatform = function() return Enum.Platform.Windows end
    log("BYPASS HWID: UserInputService.GetPlatform")
end

local GuiService = safe_service("GuiService")
if GuiService and GuiService.GetPlatform then
    GuiService.GetPlatform = function() return Enum.Platform.Windows end
    log("BYPASS HWID: GuiService.GetPlatform")
end

log("Bypass HWID aplicado")

-- ============================================
-- VARIABLES DE ENTORNO
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
    getgenv and getgenv().identifyexecutor = function() return "Xeno", xeno_version end
end

log("Variables de entorno aplicadas")

-- ============================================
-- DESCARGAR SCRIPT ORIGINAL
-- ============================================
local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua"
log("Descargando script...")
log("URL: " .. SCRIPT_URL)

local script_content = nil

-- Metodo 1: RequestAsync (PRINCIPAL en Xeno)
if HttpService and _RequestAsync then
    log("Probando RequestAsync...")
    local ok, result = pcall(function()
        return HttpService:RequestAsync({
            Url = SCRIPT_URL,
            Method = "GET"
        })
    end)
    if ok and result and result.Success and result.Body and #result.Body > 1000 then
        script_content = result.Body
        log("RequestAsync EXITO: " .. tostring(#script_content) .. " chars")
    else
        log("RequestAsync fallo o respuesta corta: " .. tostring(result and result.Body and #result.Body or 0) .. " chars")
    end
end

-- Metodo 2: syn.request
if not script_content and syn and _syn_request then
    log("Probando syn.request...")
    local ok, result = pcall(function()
        return _syn_request({
            Url = SCRIPT_URL,
            Method = "GET"
        })
    end)
    if ok and result and result.Body and #result.Body > 1000 then
        script_content = result.Body
        log("syn.request EXITO: " .. tostring(#script_content) .. " chars")
    else
        log("syn.request fallo")
    end
end

-- Metodo 3: game.HttpGet (ULTIMO - trunca en Xeno)
if not script_content and _HttpGet then
    log("Probando game.HttpGet...")
    local ok, result = pcall(function()
        return _HttpGet(game, SCRIPT_URL, true)
    end)
    if ok and result and #result > 1000 then
        script_content = result
        log("game.HttpGet EXITO: " .. tostring(#script_content) .. " chars")
    else
        log("game.HttpGet fallo o respuesta corta: " .. tostring(#result or 0) .. " chars")
    end
end

if not script_content then
    log("ERROR: No se pudo descargar el script por ningun metodo")
    save_log()
    return
end

-- ============================================
-- PARCHE: KeylessUI = false -> true
-- ============================================
if string.find(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", 1, true) then
    script_content = string.gsub(
        script_content,
        "Sakura%.Options%.KeylessUI%s*=%s*false",
        "Sakura.Options.KeylessUI = true"
    )
    log("PARCHE: KeylessUI=false -> true")
else
    log("KeylessUI=false no encontrado")
end

-- ============================================
-- EJECUCION
-- ============================================
log("Compilando y ejecutando...")

local compile_success, compiled = pcall(original_loadstring, script_content)
if not compile_success or not compiled then
    log("ERROR compilacion: " .. tostring(compiled))
    save_log()
    return
end

log("Compilado OK")

local exec_success, exec_error = pcall(compiled)
if exec_success then
    log("Script ejecutado OK")
else
    log("ERROR ejecucion: " .. tostring(exec_error))
end

save_log()
