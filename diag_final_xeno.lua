--[[
    DIAGNOSTICO FINAL XENO - CON LOG A ARCHIVO
    Guarda el log en el escritorio para revision facil.
]]

warn("[DIAG FINAL] Inicio")

local LOG_PATH = "AeriHub_Diagnostico_Final.txt"
local log_lines = {}
_G.AERI_DIAG_FINAL = log_lines

local function diag(msg)
    local line = "[" .. tostring(os.time()) .. "] " .. tostring(msg)
    table.insert(log_lines, line)
    warn("[DIAG FINAL]", line)
end

local function save_log()
    local content = table.concat(log_lines, "\n")
    pcall(function()
        if writefile then
            writefile(LOG_PATH, content)
            diag("Log guardado en: " .. LOG_PATH)
        else
            diag("writefile NO disponible")
        end
    end)
end

diag("========================================")
diag("DIAGNOSTICO FINAL XENO")
diag("========================================")

-- 1. Verificar game.HttpGet
diag("game.HttpGet existe: " .. tostring(game.HttpGet ~= nil))
if game.HttpGet then
    diag("game.HttpGet tipo: " .. type(game.HttpGet))
    diag("game.HttpGet es funcion: " .. tostring(type(game.HttpGet) == "function"))
end

-- 2. Verificar HttpService
local HttpService = pcall(function() return game:GetService("HttpService") end) and game:GetService("HttpService") or nil
diag("HttpService disponible: " .. tostring(HttpService ~= nil))
if HttpService then
    diag("HttpService.RequestAsync: " .. tostring(HttpService.RequestAsync ~= nil))
end

-- 3. Verificar librerias del executor
diag("syn: " .. tostring(syn ~= nil))
diag("Krnl: " .. tostring(Krnl ~= nil))
diag("fluxus: " .. tostring(fluxus ~= nil))
diag("Xeno: " .. tostring(Xeno ~= nil))
if Xeno and type(Xeno) == "table" then
    for k, v in pairs(Xeno) do
        diag("Xeno." .. tostring(k) .. ": " .. type(v))
    end
end

-- 4. Probar loadstring
diag("Probando loadstring basico...")
local test_script = 'warn("[TEST] loadstring funciona") return true'
local compiled, err = loadstring(test_script)
diag("loadstring compilado: " .. tostring(compiled ~= nil))
if compiled then
    local ok, result = pcall(compiled)
    diag("loadstring ejecutado: " .. tostring(ok) .. " " .. tostring(result))
end

-- 5. Probar game.HttpGet con URL real
diag("========================================")
diag("PRUEBA DE DESCARGA REAL")
diag("========================================")

if game.HttpGet then
    diag("Intentando descargar script con game.HttpGet...")
    local ok, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script_original.lua", true)
    end)
    diag("game.HttpGet pcall: " .. tostring(ok))
    if ok and result then
        diag("game.HttpGet tamaño: " .. tostring(#result))
        diag("game.HttpGet primeros 100 chars: " .. tostring(string.sub(result, 1, 100)))
    else
        diag("game.HttpGet error: " .. tostring(result))
    end
end

-- 6. Probar RequestAsync
if HttpService and HttpService.RequestAsync then
    diag("Intentando descargar con RequestAsync...")
    local ok, result = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script_original.lua",
            Method = "GET"
        })
    end)
    diag("RequestAsync pcall: " .. tostring(ok))
    if ok and result then
        diag("RequestAsync Success: " .. tostring(result.Success))
        diag("RequestAsync StatusCode: " .. tostring(result.StatusCode))
        diag("RequestAsync Body tamaño: " .. tostring(result.Body and #result.Body or 0))
        if result.Body and #result.Body > 100 then
            diag("RequestAsync Body primeros 100 chars: " .. tostring(string.sub(result.Body, 1, 100)))
        end
    else
        diag("RequestAsync error: " .. tostring(result))
    end
end

-- 7. Probar readfile local
diag("========================================")
diag("PRUEBA DE LECTURA LOCAL")
diag("========================================")

if readfile then
    diag("Intentando leer script local...")
    local ok, content = pcall(readfile, "AeriHub_Desofuscado/script_original.lua")
    diag("readfile resultado: " .. tostring(ok))
    if ok and content then
        diag("readfile tamaño: " .. tostring(#content))
    else
        diag("readfile error: " .. tostring(content))
    end
else
    diag("readfile NO disponible")
end

diag("========================================")
diag("DIAGNOSTICO FINAL XENO - FIN")
diag("========================================")

save_log()
