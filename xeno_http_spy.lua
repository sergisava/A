--[[
    XENO HTTP SPY - CAPTURA DE LLAMADAS
    Script separado para capturar todas las llamadas HTTP
    Ejecutar ESTE primero para ver qué URLs intenta cargar el script
]]

warn("[HTTP SPY] Iniciando captura de llamadas HTTP...")

-- Configuracion
local SPY_LOG = {}
_G.AERI_SPY = SPY_LOG

local function log_spy(msg)
    local entry = "[" .. tostring(os.time()) .. "] " .. tostring(msg)
    table.insert(SPY_LOG, entry)
    warn("[HTTP SPY]", entry)
end

local function save_spy_log()
    local path = "AeriHub_HTTP_Spy.txt"
    local content = table.concat(SPY_LOG, "\n")
    pcall(function()
        if writefile then
            writefile(path, content)
            log_spy("Log guardado en: " .. path)
        end
    end)
end

-- Activar HttpSpy de Xeno
if Xeno and Xeno.HttpSpy then
    Xeno.HttpSpy(true)
    log_spy("Xeno.HttpSpy activado")
else
    log_spy("Xeno.HttpSpy no disponible")
end

-- Interceptar game.HttpGet
local _HttpGet = game.HttpGet
game.HttpGet = function(self, url, ...)
    url = tostring(url or "")
    log_spy("game.HttpGet: " .. url)
    return _HttpGet(self, url, ...)
end

-- Interceptar RequestAsync
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
if HttpService and HttpService.RequestAsync then
    local _RequestAsync = HttpService.RequestAsync
    HttpService.RequestAsync = function(self, options)
        local url = tostring(options and options.Url or "")
        log_spy("RequestAsync: " .. url)
        return _RequestAsync(self, options)
    end
end

-- Interceptar syn.request
if syn and syn.request then
    local _syn_request = syn.request
    syn.request = function(options)
        local url = tostring(options and options.Url or "")
        log_spy("syn.request: " .. url)
        return _syn_request(options)
    end
end

log_spy("Captura activa. Ejecuta el script ahora.")
log_spy("El log se guardara en: AeriHub_HTTP_Spy.txt")

-- Guardar log automaticamente despues de 30 segundos
wait(30)
save_spy_log()
log_spy("Captura finalizada. Revisa AeriHub_HTTP_Spy.txt")
