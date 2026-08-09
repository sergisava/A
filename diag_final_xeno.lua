--[[
    DIAGNOSTICO FINAL XENO - SIN game.HttpGet
    Confirma si game.HttpGet existe y prueba metodos alternativos.
]]

warn("[DIAG FINAL] Inicio")

-- 1. Verificar si game.HttpGet existe de verdad
warn("[DIAG FINAL] game.HttpGet existe:", game.HttpGet ~= nil)
if game.HttpGet then
    warn("[DIAG FINAL] game.HttpGet tipo:", type(game.HttpGet))
    warn("[DIAG FINAL] game.HttpGet es funcion:", type(game.HttpGet) == "function")
end

-- 2. Verificar game:GetService
warn("[DIAG FINAL] game:GetService existe:", game.GetService ~= nil)
if game.GetService then
    local ok, hs = pcall(function() return game:GetService("HttpService") end)
    warn("[DIAG FINAL] HttpService:", ok and "disponible" or "NO disponible")
    if hs then
        warn("[DIAG FINAL] HttpService.RequestAsync:", hs.RequestAsync ~= nil)
    end
end

-- 3. Verificar librerias del executor
warn("[DIAG FINAL] syn:", syn ~= nil)
warn("[DIAG FINAL] Krnl:", Krnl ~= nil)
warn("[DIAG FINAL] fluxus:", fluxus ~= nil)
warn("[DIAG FINAL] Xeno:", Xeno ~= nil)
if Xeno then
    warn("[DIAG FINAL] Xeno tipo:", type(Xeno))
    if type(Xeno) == "table" then
        for k, v in pairs(Xeno) do
            warn("[DIAG FINAL] Xeno." .. tostring(k) .. ":", type(v))
        end
    end
end

-- 4. Probar si loadstring puede compilar algo basico
warn("[DIAG FINAL] Probando loadstring basico...")
local test_script = 'warn("[TEST] loadstring funciona") return true'
local compiled, err = loadstring(test_script)
warn("[DIAG FINAL] loadstring compilado:", compiled ~= nil)
if compiled then
    local ok, result = pcall(compiled)
    warn("[DIAG FINAL] loadstring ejecutado:", ok, result)
end

-- 5. Intentar leer el script localmente como ultimo recurso
warn("[DIAG FINAL] Intentando leer script local...")
local script_path = "AeriHub_Desofuscado/script_original.lua"
if readfile then
    local ok, content = pcall(readfile, script_path)
    warn("[DIAG FINAL] readfile:", ok and "EXITO (" .. #content .. " chars)" or "FALLO: " .. tostring(content))
else
    warn("[DIAG FINAL] readfile NO disponible")
end

warn("[DIAG FINAL] Fin del diagnostico")
