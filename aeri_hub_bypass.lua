--[[
    AERI HUB - MULTI-EXECUTOR BYPASS WRAPPER (XENO COMPATIBLE)
    Espera activa del entorno antes de tocar Roblox.
    Compatible con: Synapse X, Krnl, Fluxus, Xeno, Electron, Delta, Wave, etc.
]]

-- ============================================
-- LOGGING SYSTEM (Lua 5.1 safe)
-- ============================================

local AERI_LOG = {}
_AERI_LOG = AERI_LOG
_G.AERI_LOG = AERI_LOG

local function log(msg)
    local timestamp = os.time()
    local entry = "[" .. tostring(timestamp) .. "] " .. tostring(msg)
    table.insert(AERI_LOG, entry)
    if warn and type(warn) == "function" then
        pcall(warn, "[AERI LOG]", entry)
    elseif print and type(print) == "function" then
        pcall(print, "[AERI LOG]", entry)
    end
end

local function save_log()
    if writefile then
        local log_path = "C:\\Users\\sergisava\\AppData\\Local\\Xeno\\AeriHub_Bypass_Log.txt"
        local content = ""
        for i = 1, #AERI_LOG do
            if i > 1 then
                content = content .. "\n"
            end
            content = content .. AERI_LOG[i]
        end
        pcall(function()
            writefile(log_path, content)
            log("Log guardado en: " .. log_path)
        end)
    end
end

local function print_log()
    log("========== LOG COMPLETO ==========")
    for i = 1, #AERI_LOG do
        warn(AERI_LOG[i])
    end
    log("========== FIN DEL LOG ==========")
end

log("========================================")
log("AERI HUB BYPASS WRAPPER - MULTI-EXECUTOR")
log("========================================")

-- ============================================
-- STEP 1: Esperar entorno de Roblox
-- ============================================

log("STEP 1: Esperando entorno de Roblox...")

local function wait_for_game()
    local attempts = 0
    while attempts < 50 do
        attempts = attempts + 1
        if game and type(game) == "table" then
            return true
        end
        wait(0.1)
    end
    return false
end

local function wait_for_HttpGet()
    local attempts = 0
    while attempts < 50 do
        attempts = attempts + 1
        if game and game.HttpGet and type(game.HttpGet) == "function" then
            return true
        end
        wait(0.1)
    end
    return false
end

local function wait_for_pcall()
    local attempts = 0
    while attempts < 50 do
        attempts = attempts + 1
        if pcall and type(pcall) == "function" then
            return true
        end
        wait(0.1)
    end
    return false
end

local function wait_for_loadstring()
    local attempts = 0
    while attempts < 50 do
        attempts = attempts + 1
        if loadstring and type(loadstring) == "function" then
            return true
        end
        wait(0.1)
    end
    return false
end

local game_ready = wait_for_game()
if not game_ready then
    log("ERROR: game no disponible despues de esperar")
    print_log()
    save_log()
    return
end
log("STEP 1: game disponible")

local http_ready = wait_for_HttpGet()
if not http_ready then
    log("ERROR: game.HttpGet no disponible despues de esperar")
    print_log()
    save_log()
    return
end
log("STEP 1: game.HttpGet disponible")

local pcall_ready = wait_for_pcall()
if not pcall_ready then
    log("ERROR: pcall no disponible despues de esperar")
    print_log()
    save_log()
    return
end
log("STEP 1: pcall disponible")

local loadstring_ready = wait_for_loadstring()
if not loadstring_ready then
    log("ERROR: loadstring no disponible despues de esperar")
    print_log()
    save_log()
    return
end
log("STEP 1: loadstring disponible")

-- ============================================
-- STEP 2: Detectar executor (multi-ejecutor)
-- ============================================

log("STEP 2: Detectando executor...")

local executor_name = "Unknown"
local executor_version = "Unknown"

if syn and syn.request and type(syn.request) == "function" then
    executor_name = "Synapse X"
elseif Krnl and type(Krnl) == "table" then
    executor_name = "Krnl"
    executor_version = tostring(Krnl.version or "Unknown")
elseif fluxus and type(fluxus) == "table" then
    executor_name = "Fluxus"
    executor_version = tostring(fluxus.version or "Unknown")
elseif identifyexecutor and type(identifyexecutor) == "function" then
    local ok, name, version = pcall(identifyexecutor)
    if ok then
        executor_name = tostring(name or "Unknown")
        executor_version = tostring(version or "Unknown")
    end
elseif getexecutorname and type(getexecutorname) == "function" then
    local ok, name = pcall(getexecutorname)
    if ok then
        executor_name = tostring(name or "Unknown")
    end
end

log("Executor detectado: " .. executor_name .. " v" .. executor_version)

-- ============================================
-- STEP 3: Guardar referencias originales
-- ============================================

log("STEP 3: Guardando referencias originales...")

local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet
local HttpService = nil
local _RequestAsync = nil

local ok_service, http_service = pcall(function()
    return game:GetService("HttpService")
end)
if ok_service and http_service then
    HttpService = http_service
    _RequestAsync = http_service.RequestAsync
end

local _syn_request = nil
if syn and syn.request and type(syn.request) == "function" then
    _syn_request = syn.request
end

local _krnl_request = nil
if Krnl and Krnl.request and type(Krnl.request) == "function" then
    _krnl_request = Krnl.request
end

local _fluxus_request = nil
if fluxus and fluxus.request and type(fluxus.request) == "function" then
    _fluxus_request = fluxus.request
end

log("STEP 3: Referencias guardadas")

-- ============================================
-- STEP 4: Analizar script original (AUTO-DETECT)
-- ============================================

log("STEP 4: Analizando script para detectar verificaciones...")

local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua"
log("URL: " .. SCRIPT_URL)

local script_content = nil
local download_success, download_error = pcall(function()
    script_content = game:HttpGet(SCRIPT_URL)
end)

if not download_success or not script_content or script_content == "" then
    log("ERROR: Fallo al descargar script. Error: " .. tostring(download_error))
    print_log()
    save_log()
    return
end

log("Script descargado. Tamaño: " .. tostring(#script_content) .. " caracteres")

-- Detectar URLs de verificacion
local detected_urls = {}
local script_lower = string.lower(script_content)

for url in string.gmatch(script_lower, "https?://[^%s\"'%[%]]+") do
    if string.find(url, "jnkie", 1, true) or
       string.find(url, "sakura", 1, true) or
       string.find(url, "key", 1, true) or
       string.find(url, "verify", 1, true) or
       string.find(url, "auth", 1, true) or
       string.find(url, "hwid", 1, true) or
       string.find(url, "bloxfruit", 1, true) or
       string.find(url, "ale", 1, true) then
        table.insert(detected_urls, url)
        log("DETECTADO URL: " .. url)
    end
end

if #detected_urls == 0 then
    log("AUTO-DETECT: No se detectaron URLs especificas")
else
    log("AUTO-DETECT: URLs detectadas: " .. tostring(#detected_urls))
end

-- Detectar variables de verificacion
local detected_vars = {}
local var_keywords = {
    "KeyVerified", "LicenseKey", "AutoExecute", "HWID", "DeviceID",
    "SakuraVerified", "Keyless", "KeylessUI"
}

for i = 1, #var_keywords do
    local var = var_keywords[i]
    if string.find(script_lower, string.lower(var), 1, true) then
        table.insert(detected_vars, var)
        log("DETECTADO VAR: " .. var)
    end
end

log("AUTO-DETECT: Variables detectadas: " .. tostring(#detected_vars))

-- ============================================
-- BYPASS 1: Luraph v14.7 internal packed-hash check
-- ============================================

log("STEP 5: Aplicando bypass Luraph v14.7...")

local function is_luraph_check(expr)
    expr = tostring(expr or "")
    return string.find(expr, "45700", 1, true) ~= nil
        or string.find(expr, "0x1B,0x4C,0x75,0x61,0x50", 1, true) ~= nil
        or string.find(expr, "LuP", 1, true) ~= nil
end

local original_loadstring = _loadstring
loadstring = function(expr, env)
    if is_luraph_check(expr) then
        log("BYPASS1: loadstring Luraph interceptado")
        return function() end
    end
    return original_loadstring(expr, env)
end

local original_pcall = _pcall
pcall = function(f, ...)
    if f == original_loadstring or f == loadstring or (type(f) == "string" and is_luraph_check(f)) then
        log("BYPASS1: pcall Luraph interceptado")
        return true, function() end
    end
    return original_pcall(f, ...)
end

local original_tostring = _tostring
tostring = function(v)
    if v == original_pcall or v == pcall or v == original_loadstring or v == loadstring then
        log("BYPASS1: tostring pcall/loadstring falsificado")
        return "LuP"
    end
    return original_tostring(v)
end

log("STEP 5: Bypass Luraph aplicado")

-- ============================================
-- BYPASS 2: HTTP verification (AUTO-DETECT)
-- ============================================

log("STEP 6: Aplicando bypass HTTP automatico...")

local function should_block_url(url)
    url = tostring(url or "")
    local url_lower = string.lower(url)
    
    for i = 1, #detected_urls do
        if string.find(url_lower, detected_urls[i], 1, true) ~= nil then
            return true, "URL detectada"
        end
    end
    
    local generic_patterns = {
        "jnkie.com", "sakura", "key", "verify", "check", "auth",
        "license", "hwid", "hardware", "device", "fingerprint",
        "bloxfruit", "ale", "provider", "launch"
    }
    for i = 1, #generic_patterns do
        if string.find(url_lower, generic_patterns[i], 1, true) ~= nil then
            return true, "Patron generico"
        end
    end
    
    return false, ""
end

local function block_http_response()
    return '{"status":"success","verified":true,"hwid":"BYPASSED","key":"BYPASSED"}'
end

-- game.HttpGet
game.HttpGet = function(self, url, ...)
    local blocked, reason = should_block_url(url)
    if blocked then
        log("BYPASS2: game.HttpGet bloqueada (" .. reason .. "): " .. tostring(url))
        return block_http_response()
    end
    return _HttpGet(self, url, ...)
end

-- RequestAsync
if HttpService and _RequestAsync then
    HttpService.RequestAsync = function(self, options)
        local url = tostring(options and options.Url or "")
        local blocked, reason = should_block_url(url)
        if blocked then
            log("BYPASS2: RequestAsync bloqueada (" .. reason .. "): " .. url)
            return {
                Success = true,
                StatusCode = 200,
                Body = '{"status":"success","verified":true,"hwid":"BYPASSED"}',
                StatusMessage = "OK"
            }
        end
        return _RequestAsync(self, options)
    end
end

-- syn.request
if syn and _syn_request then
    syn.request = function(options)
        local url = tostring(options and options.Url or "")
        local blocked, reason = should_block_url(url)
        if blocked then
            log("BYPASS2: syn.request bloqueada (" .. reason .. "): " .. url)
            return {
                Success = true,
                StatusCode = 200,
                Body = '{"status":"success","verified":true,"hwid":"BYPASSED"}',
                StatusMessage = "OK"
            }
        end
        return _syn_request(options)
    end
end

-- Krnl.request
if Krnl and _krnl_request then
    Krnl.request = function(options)
        local url = tostring(options and options.Url or "")
        local blocked, reason = should_block_url(url)
        if blocked then
            log("BYPASS2: Krnl.request bloqueada (" .. reason .. "): " .. url)
            return {
                Success = true,
                StatusCode = 200,
                Body = '{"status":"success","verified":true,"hwid":"BYPASSED"}',
                StatusMessage = "OK"
            }
        end
        return _krnl_request(options)
    end
end

-- fluxus.request
if fluxus and _fluxus_request then
    fluxus.request = function(options)
        local url = tostring(options and options.Url or "")
        local blocked, reason = should_block_url(url)
        if blocked then
            log("BYPASS2: fluxus.request bloqueada (" .. reason .. "): " .. url)
            return {
                Success = true,
                StatusCode = 200,
                Body = '{"status":"success","verified":true,"hwid":"BYPASSED"}',
                StatusMessage = "OK"
            }
        end
        return _fluxus_request(options)
    end
end

log("STEP 6: Bypass HTTP automatico aplicado")

-- ============================================
-- BYPASS 3: HWID / Roblox device services
-- ============================================

log("STEP 7: Aplicando bypass servicios Roblox...")

local function safe_get_service(name)
    local ok, service = pcall(function()
        return game:GetService(name)
    end)
    if ok and service then
        return service
    end
    return nil
end

-- RbxAnalyticsService.GetClientId
local RbxAnalyticsService = safe_get_service("RbxAnalyticsService")
if RbxAnalyticsService and RbxAnalyticsService.GetClientId and type(RbxAnalyticsService.GetClientId) == "function" then
    RbxAnalyticsService.GetClientId = function()
        return "BYPASSED-CLIENT-" .. tostring(os.time())
    end
    log("BYPASS3: RbxAnalyticsService.GetClientId falsificado")
else
    log("BYPASS3: RbxAnalyticsService no disponible o sin GetClientId")
end

-- UserInputService.GetPlatform
local UserInputService = safe_get_service("UserInputService")
if UserInputService and UserInputService.GetPlatform and type(UserInputService.GetPlatform) == "function" then
    UserInputService.GetPlatform = function()
        return Enum.Platform.Windows
    end
    log("BYPASS3: UserInputService.GetPlatform falsificado")
else
    log("BYPASS3: UserInputService no disponible o sin GetPlatform")
end

-- GuiService.GetPlatform
local GuiService = safe_get_service("GuiService")
if GuiService and GuiService.GetPlatform and type(GuiService.GetPlatform) == "function" then
    GuiService.GetPlatform = function()
        return Enum.Platform.Windows
    end
    log("BYPASS3: GuiService.GetPlatform falsificado")
else
    log("BYPASS3: GuiService no disponible o sin GetPlatform")
end

log("STEP 7: Bypass servicios Roblox aplicado")

-- ============================================
-- BYPASS 4: Fake environment values
-- ============================================

log("STEP 8: Inyectando variables de entorno falsas...")

if getgenv and type(getgenv) == "function" then
    local env = getgenv()
    if env then
        env.KeyVerified = true
        env.LicenseKey = "BYPASSED"
        env.AutoExecute = true
        env.HWID = "BYPASSED-HWID"
        env.DeviceID = "BYPASSED-DEVICE"
        env.SakuraVerified = true
        env.ExecutorName = executor_name
        env.ExecutorVersion = executor_version
        log("BYPASS4: Variables inyectadas en getgenv")
    else
        log("BYPASS4: getgenv devolvio nil")
    end
else
    log("BYPASS4: getgenv no disponible")
end

if _G then
    _G.KeyVerified = true
    _G.LicenseKey = "BYPASSED"
    _G.AutoExecute = true
    _G.HWID = "BYPASSED-HWID"
    _G.DeviceID = "BYPASSED-DEVICE"
    _G.SakuraVerified = true
    _G.ExecutorName = executor_name
    _G.ExecutorVersion = executor_version
    log("BYPASS4: Variables inyectadas en _G")
else
    log("BYPASS4: _G no disponible")
end

if identifyexecutor and type(identifyexecutor) == "function" then
    pcall(function()
        getgenv and getgenv().identifyexecutor = function()
            return executor_name, executor_version
        end
    end)
    log("BYPASS4: identifyexecutor seteado a: " .. executor_name)
else
    log("BYPASS4: identifyexecutor no disponible")
end

log("STEP 8: Variables de entorno aplicadas")

-- ============================================
-- PARCHE: KeylessUI = false -> true
-- ============================================

log("STEP 9: Aplicando parches al script...")

local patch_count = 0

if string.find(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", 1, true) ~= nil then
    script_content = string.gsub(
        script_content,
        "Sakura%.Options%.KeylessUI%s*=%s*false",
        "Sakura.Options.KeylessUI = true"
    )
    patch_count = patch_count + 1
    log("PARCHE: KeylessUI=false -> true")
end

if string.find(script_content, "Sakura%.Options%.KeylessUI%s*=%s*true", 1, true) ~= nil then
    log("PARCHE: KeylessUI ya es true")
else
    log("PARCHE: KeylessUI no encontrado")
end

log("STEP 9: Parches aplicados: " .. tostring(patch_count))

-- ============================================
-- EJECUCION FINAL
-- ============================================

log("STEP 10: Compilando y ejecutando script...")

local compile_success, compiled = pcall(original_loadstring, script_content)
if not compile_success or not compiled then
    log("ERROR: Fallo al compilar script: " .. tostring(compiled))
    print_log()
    save_log()
    return
end

log("Script compilado exitosamente")

local exec_success, exec_error = pcall(compiled)
if exec_success then
    log("EJECUCION: Script ejecutado sin errores")
else
    log("EJECUCION: Error durante ejecucion: " .. tostring(exec_error))
end

print_log()
save_log()
