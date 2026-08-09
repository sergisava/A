--[[
    AERI HUB - BYPASS WRAPPER (DEFENSIVE MODE)
    Cargar ESTE archivo por loadstring/URL primero.
    Versión con validación paso a paso y logging detallado.
]]

-- ============================================
-- LOGGING SYSTEM
-- ============================================

local AERI_LOG = {}
_AERI_LOG = AERI_LOG
_G.AERI_LOG = AERI_LOG

local function log(msg)
    local timestamp = os.time()
    local entry = string.format("[%d] %s", timestamp, tostring(msg))
    table.insert(AERI_LOG, entry)
    warn("[AERI LOG]", entry)
end

local function save_log()
    if writefile then
        local log_path = "C:\\Users\\sergisava\\AppData\\Local\\Xeno\\AeriHub_Bypass_Log.txt"
        local content = table.concat(AERI_LOG, "\n")
        pcall(function()
            writefile(log_path, content)
            log("Log guardado en: " .. log_path)
        end)
    end
end

local function print_log()
    log("========== LOG COMPLETO ==========")
    for i, entry in ipairs(AERI_LOG) do
        warn(entry)
    end
    log("========== FIN DEL LOG ==========")
end

log("========================================")
log("AERI HUB BYPASS WRAPPER - INICIO")
log("========================================")

-- ============================================
-- STEP 1: Validar entorno básico
-- ============================================

log("STEP 1: Validando entorno basico...")

local environment_ok = true

if not game then
    log("ERROR: game no disponible")
    environment_ok = false
end

if not game:GetService then
    log("ERROR: game:GetService no disponible")
    environment_ok = false
end

if not game.HttpGet then
    log("ERROR: game.HttpGet no disponible")
    environment_ok = false
end

if not pcall then
    log("ERROR: pcall no disponible")
    environment_ok = false
end

if not loadstring then
    log("ERROR: loadstring no disponible")
    environment_ok = false
end

if not tostring then
    log("ERROR: tostring no disponible")
    environment_ok = false
end

if not string then
    log("ERROR: string library no disponible")
    environment_ok = false
end

if environment_ok then
    log("STEP 1: Entorno basico OK")
else
    log("STEP 1: Entorno basico FALLO - abortando")
    print_log()
    save_log()
    return
end

-- ============================================
-- STEP 2: Guardar referencias originales
-- ============================================

log("STEP 2: Guardando referencias originales...")

local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
local _RequestAsync = HttpService and HttpService.RequestAsync or nil
local _syn_request = syn and syn.request or nil

log("STEP 2: Referencias guardadas")
log("  - game.HttpGet: " .. tostring(_HttpGet ~= nil))
log("  - HttpService: " .. tostring(HttpService ~= nil))
log("  - RequestAsync: " .. tostring(_RequestAsync ~= nil))
log("  - syn.request: " .. tostring(_syn_request ~= nil))

-- ============================================
-- BYPASS 1: Luraph v14.7 internal packed-hash check
-- ============================================

log("STEP 3: Aplicando bypass Luraph v14.7...")

local function is_luraph_check(expr)
    expr = tostring(expr or "")
    local found = expr:find("45700", 1, true)
        or expr:find("0x1B,0x4C,0x75,0x61,0x50", 1, true)
        or expr:find("LuP", 1, true)
    return found
end

-- Reemplazar loadstring de forma segura
local original_loadstring = _loadstring
loadstring = function(expr, env)
    if is_luraph_check(expr) then
        log("BYPASS1: loadstring Luraph interceptado")
        return function() end
    end
    return original_loadstring(expr, env)
end

-- Reemplazar pcall de forma segura
local original_pcall = _pcall
pcall = function(f, ...)
    if f == original_loadstring or f == loadstring or (type(f) == "string" and is_luraph_check(f)) then
        log("BYPASS1: pcall Luraph interceptado")
        return true, function() end
    end
    return original_pcall(f, ...)
end

-- Reemplazar tostring de forma segura
local original_tostring = _tostring
tostring = function(v)
    if v == original_pcall or v == pcall or v == original_loadstring or v == loadstring then
        log("BYPASS1: tostring pcall/loadstring falsificado")
        return "LuP"
    end
    return original_tostring(v)
end

log("STEP 3: Bypass Luraph aplicado")

-- ============================================
-- BYPASS 2: HTTP verification (keys / HWID)
-- ============================================

log("STEP 4: Aplicando bypass HTTP...")

game.HttpGet = function(self, url, ...)
    url = tostring(url or "")
    local blocked = {
        "jnkie.com", "sakura", "key", "verify", "check", "auth",
        "license", "hwid", "hardware", "device", "fingerprint",
        "bloxfruit", "ale", "provider", "launch"
    }
    for _, p in ipairs(blocked) do
        if url:lower():find(p, 1, true) then
            log("BYPASS2: game.HttpGet bloqueada: " .. url)
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
                log("BYPASS2: RequestAsync bloqueada: " .. url)
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
                log("BYPASS2: syn.request bloqueada: " .. url)
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

log("STEP 4: Bypass HTTP aplicado")

-- ============================================
-- BYPASS 3: HWID / Roblox device services
-- ============================================

log("STEP 5: Aplicando bypass servicios Roblox...")

local function safe_get_service(name)
    local ok, service = original_pcall(function() return game:GetService(name) end)
    return ok and service or nil
end

local RbxAnalyticsService = safe_get_service("RbxAnalyticsService")
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    local originalGetClientId = RbxAnalyticsService.GetClientId
    RbxAnalyticsService.GetClientId = function()
        return "BYPASSED-CLIENT-ID-12345"
    end
    log("BYPASS3: RbxAnalyticsService.GetClientId falsificado")
else
    log("BYPASS3: RbxAnalyticsService no disponible o sin GetClientId")
end

local UserInputService = safe_get_service("UserInputService")
if UserInputService and UserInputService.GetPlatform then
    local originalGetPlatform = UserInputService.GetPlatform
    UserInputService.GetPlatform = function()
        return Enum.Platform.Windows
    end
    log("BYPASS3: UserInputService.GetPlatform falsificado")
else
    log("BYPASS3: UserInputService no disponible o sin GetPlatform")
end

local GuiService = safe_get_service("GuiService")
if GuiService and GuiService.GetPlatform then
    local originalGetPlatform = GuiService.GetPlatform
    GuiService.GetPlatform = function()
        return Enum.Platform.Windows
    end
    log("BYPASS3: GuiService.GetPlatform falsificado")
else
    log("BYPASS3: GuiService no disponible o sin GetPlatform")
end

log("STEP 5: Bypass servicios Roblox aplicado")

-- ============================================
-- BYPASS 4: Fake environment values
-- ============================================

log("STEP 6: Inyectando variables de entorno falsas...")

if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().AutoExecute = true
    getgenv().HWID = "BYPASSED-HWID"
    getgenv().DeviceID = "BYPASSED-DEVICE"
    getgenv().SakuraVerified = true
    log("BYPASS4: Variables inyectadas en getgenv")
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
    log("BYPASS4: Variables inyectadas en _G")
else
    log("BYPASS4: _G no disponible")
end

if identifyexecutor then
    getgenv and getgenv().identifyexecutor = function() return "None", "1.0.0" end
    log("BYPASS4: identifyexecutor ocultado")
else
    log("BYPASS4: identifyexecutor no disponible")
end

log("STEP 6: Variables de entorno aplicadas")

-- ============================================
-- CARGA Y PARCHE DEL SCRIPT ORIGINAL
-- ============================================

log("STEP 7: Cargando script original...")

local SCRIPT_URL = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua"
log("URL: " .. SCRIPT_URL)

local script_content = nil
local download_success, download_error = original_pcall(function()
    script_content = game:HttpGet(SCRIPT_URL)
end)

if not download_success or not script_content or script_content == "" then
    log("ERROR: Fallo al descargar script. Error: " .. tostring(download_error))
    print_log()
    save_log()
    return
end

log("Script descargado. Tamaño: " .. tostring(#script_content) .. " caracteres")

-- Parche en caliente: cambiar KeylessUI = false -> true
local original_count = select(2, string.gsub(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", "Sakura.Options.KeylessUI = true"))
script_content = string.gsub(
    script_content,
    "Sakura%.Options%.KeylessUI%s*=%s*false",
    "Sakura.Options.KeylessUI = true"
)

if original_count > 0 then
    log("PARCHE: KeylessUI=false cambiado a true (" .. tostring(original_count) .. " reemplazo(s))")
else
    log("PARCHE: No se encontro KeylessUI=false en el script original")
end

-- ============================================
-- EJECUCION FINAL
-- ============================================

log("STEP 8: Compilando y ejecutando script...")

local compile_success, compiled = original_pcall(original_loadstring, script_content)
if not compile_success or not compiled then
    log("ERROR: Fallo al compilar script: " .. tostring(compiled))
    print_log()
    save_log()
    return
end

log("Script compilado exitosamente")

local exec_success, exec_error = original_pcall(compiled)
if exec_success then
    log("EJECUCION: Script ejecutado sin errores")
else
    log("EJECUCION: Error durante ejecucion: " .. tostring(exec_error))
end

print_log()
save_log()
