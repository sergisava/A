--[[
    DIAGNOSTICO MINIMO - SOLO DESCARGAR SCRIPT
    Sin bypasses, sin log, sin nada.
    Solo descarga con RequestAsync y muestra el tamaño.
]]

warn("[DIAG MIN] Inicio")

if HttpService and HttpService.RequestAsync then
    warn("[DIAG MIN] RequestAsync disponible")
    
    local ok, result = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua",
            Method = "GET"
        })
    end)
    
    warn("[DIAG MIN] pcall resultado: " .. tostring(ok))
    if ok and result then
        warn("[DIAG MIN] result type: " .. type(result))
        if result.Body then
            warn("[DIAG MIN] Body length: " .. #result.Body)
            warn("[DIAG MIN] Body primeros 50 chars: " .. string.sub(result.Body, 1, 50))
        else
            warn("[DIAG MIN] result.Body es nil")
            warn("[DIAG MIN] result keys: " .. tostring(result.Success) .. ", " .. tostring(result.StatusCode))
        end
    else
        warn("[DIAG MIN] Error en pcall: " .. tostring(result))
    end
else
    warn("[DIAG MIN] RequestAsync NO disponible")
end

warn("[DIAG MIN] Fin")
