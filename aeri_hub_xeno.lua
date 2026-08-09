--[[
    AERI HUB - XENO OPTIMIZED WRAPPER
    Compatible con Xeno v1.3.x
    Usa multiples metodos HTTP porque game.HttpGet puede truncar respuestas.
]]

-- ============================================
-- LOGGING
-- ============================================
local log_lines = {}
_G.AERI_LOG = log_lines

local function log(msg)
    local line = "[" .. tostring(os.time()) .. "] " .. tostring(msg)
    table.insert(log_lines, line)
    pcall(function() warn("[AERI]", line) end)
end

local function save_log()
    local path = "AeriHub_Xeno_Log.txt"
    local content = ""
    for i = 1, #log_lines do
        if i > 1 then content = content .. "\n" end
        content = content .. log_lines[i]
    end
    pcall(function()
        if writefile then
            writefile(path, content)
            log("Log guardado en: " .. path)
        else
            log("writefile NO disponible")
        end
    end)
end

log("========================================")
log("AERI HUB - XENO OPTIMIZED WRAPPER")
log("========================================")

-- ============================================
-- STEP 1: Detectar Xeno y sus funciones
-- ============================================
log("STEP 1: Detectando Xeno...")

local is_xeno = false
local xeno_version = "Unknown"

if identifyexecutor and type(identifyexecutor) == "function" then
    local ok, name, version = pcall(identifyexecutor)
    if ok and name and string.find(string.lower(name), "xeno", 1, true) then
        is_xeno = true
        xeno_version = tostring(version or "Unknown")
    end
end

if Xeno and type(Xeno) == "table" then
    is_xeno = true
    if Xeno.version then xeno_version = tostring(Xeno.version) end
end

log("Xeno detectado: " .. tostring(is_xeno))
log("Version: " .. xeno_version)

-- Funciones HTTP disponibles
local http_methods = {
    game_HttpGet = game.HttpGet,
    RequestAsync = nil,
    syn_request = nil,
    xeno_http = nil,
    xeno_request = nil,
}

if HttpService and HttpService.RequestAsync then
    http_methods.RequestAsync = HttpService.RequestAsync
end

if syn and syn.request then
    http_methods.syn_request = syn.request
end

if Xeno and type(Xeno) == "table" then
    http_methods.xeno_http = Xeno.HttpSpy or Xeno.http or nil
    http_methods.xeno_request = Xeno.request or nil
end

log("Metodos HTTP disponibles:")
for name, func in pairs(http_methods) do
    log("  " .. name .. ": " .. tostring(func ~= nil))
end

-- ============================================
-- STEP 2: Guardar referencias originales
-- ============================================
log("STEP 2: Guardando referencias...")

local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
local _RequestAsync = HttpService and HttpService.RequestAsync or nil
local _syn_request = syn and syn.request or nil

log("Referencias guardadas")

-- ============================================
-- BYPASS 1: Luraph v14.7
-- ============================================
log("STEP 3: Aplicando bypass Luraph...")

local function is_luraph_check(expr)
    expr = tostring(expr or "")
    return string.find(expr, "45700", 1, true) ~= nil
        or string.find(expr, "0x1B,0x4C,0x75,0x61,0x50", 1, true) ~= nil
        or string.find(expr, "LuP", 1, true) ~= nil
end

local original_loadstring = _loadstring
loadstring = function(expr, env)
    if is_luraph_check(expr) then
        log("BYPASS Luraph: loadstring interceptado")
        return function() end
    end
    return original_loadstring(expr, env)
end

local original_pcall = _pcall
pcall = function(f, ...)
    if f == original_loadstring or f == loadstring or (type(f) == "string" and is_luraph_check(f)) then
        log("BYPASS Luraph: pcall interceptado")
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
-- BYPASS 2: HTTP verification (Xeno optimizado)
-- ============================================
log("STEP 4: Aplicando bypass HTTP...")

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

-- game.HttpGet
game.HttpGet = function(self, url, ...)
    if should_block(url) then
        log("BYPASS HTTP: game.HttpGet bloqueada: " .. tostring(url))
        return fake_response()
    end
    return _HttpGet(self, url, ...)
end

-- RequestAsync
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

-- syn.request
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
-- BYPASS 3: HWID / Roblox services
-- ============================================
log("STEP 5: Aplicando bypass HWID...")

local function safe_service(name)
    local ok, svc = pcall(function() return game:GetService(name) end)
    return ok and svc or nil
end

local RbxAnalyticsService = safe_service("RbxAnalyticsService")
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    RbxAnalyticsService.GetClientId = function() return "BYPASSED-" .. tostring(os.time()) end
    log("BYPASS HWID: RbxAnalyticsService.GetClientId falsificado")
end

local UserInputService = safe_service("UserInputService")
if UserInputService and UserInputService.GetPlatform then
    UserInputService.GetPlatform = function() return Enum.Platform.Windows end
    log("BYPASS HWID: UserInputService.GetPlatform falsificado")
end

local GuiService = safe_service("GuiService")
if GuiService and GuiService.GetPlatform then
    GuiService.GetPlatform = function() return Enum.Platform.Windows end
    log("BYPASS HWID: GuiService.GetPlatform falsificado")
end

log("Bypass HWID aplicado")

-- ============================================
-- BYPASS 4: Environment
-- ============================================
log("STEP 6: Inyectando variables de entorno...")

if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().AutoExecute = true
    getgenv().HWID = "BYPASSED-HWID"
    getgenv().DeviceID = "BYPASSED-DEVICE"
    getgenv().SakuraVerified = true
    log("Variables inyectadas en getgenv")
end

if _G then
    _G.KeyVerified = true
    _G.LicenseKey = "BYPASSED"
    _G.AutoExecute = true
    _G.HWID = "BYPASSED-HWID"
    _G.DeviceID = "BYPASSED-DEVICE"
    _G.SakuraVerified = true
    log("Variables inyectadas en _G")
end

if identifyexecutor then
    getgenv and getgenv().identifyexecutor = function() return "Xeno", xeno_version end
end

log("Variables de entorno aplicadas")

-- ============================================
-- DESCARGAR SCRIPT ORIGINAL (XENO OPTIMIZADO)
-- ============================================
log("STEP 7: Descargando script original...")

local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua"
log("URL: " .. SCRIPT_URL)

local script_content = nil

-- Metodo 1: game.HttpGet con timeout largo
if game.HttpGet then
    log("Intentando descargar con game.HttpGet...")
    local ok, result = pcall(function()
        return game:HttpGet(SCRIPT_URL, true)
    end)
    if ok and result and #result > 1000 then
        script_content = result
        log("game.HttpGet EXITO: " .. tostring(#script_content) .. " chars")
    else
        log("game.HttpGet fallo o respuesta muy corta: " .. tostring(#result or 0) .. " chars")
        script_content = nil
    end
end

-- Metodo 2: HttpService.RequestAsync
if not script_content and HttpService and HttpService.RequestAsync then
    log("Intentando descargar con RequestAsync...")
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
        log("RequestAsync fallo")
        script_content = nil
    end
end

-- Metodo 3: syn.request
if not script_content and syn and syn.request then
    log("Intentando descargar con syn.request...")
    local ok, result = pcall(function()
        return syn.request({
            Url = SCRIPT_URL,
            Method = "GET"
        })
    end)
    if ok and result and result.Body and #result.Body > 1000 then
        script_content = result.Body
        log("syn.request EXITO: " .. tostring(#script_content) .. " chars")
    else
        log("syn.request fallo")
        script_content = nil
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
log("STEP 8: Aplicando parches...")

if string.find(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", 1, true) then
    script_content = string.gsub(
        script_content,
        "Sakura%.Options%.KeylessUI%s*=%s*false",
        "Sakura.Options.KeylessUI = true"
    )
    log("PARCHE: KeylessUI=false -> true aplicado")
else
    log("PARCHE: KeylessUI=false no encontrado")
end

-- ============================================
-- EJECUCION FINAL
-- ============================================
log("STEP 9: Ejecutando script...")

local compile_success, compiled = pcall(original_loadstring, script_content)
if not compile_success or not compiled then
    log("ERROR: Fallo al compilar: " .. tostring(compiled))
    save_log()
    return
end

log("Script compilado OK")

local exec_success, exec_error = pcall(compiled)
if exec_success then
    log("Script ejecutado OK")
else
    log("ERROR en ejecucion: " .. tostring(exec_error))
end

save_log()
