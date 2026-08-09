--[[
    AERI HUB - DIAGNOSTICO XENO (SAFE)
    No usa writefile si no esta disponible.
    Solo diagnostica.
]]

-- Logging basico
local log_lines = {}
_G.AERI_DIAG = log_lines

local function diag(msg)
    local line = "[" .. tostring(os.time()) .. "] " .. tostring(msg)
    table.insert(log_lines, line)
    pcall(function() warn("[AERI DIAG]", line) end)
end

local function save_diag()
    -- Intentar guardar solo si writefile existe
    if not writefile then
        diag("writefile NO disponible - log solo en consola")
        return
    end
    
    local path = "AeriHub_Diagnostico.txt"
    local content = ""
    for i = 1, #log_lines do
        if i > 1 then content = content .. "\n" end
        content = content .. log_lines[i]
    end
    
    local ok, err = pcall(function()
        writefile(path, content)
    end)
    
    if ok then
        diag("Log guardado en: " .. path)
    else
        diag("FALLO guardando log: " .. tostring(err))
    end
end

diag("========================================")
diag("DIAGNOSTICO XENO - INICIO")
diag("========================================")

-- DIAG 1: Entorno basico
diag("DIAG 1: Entorno basico")
diag("  game: " .. tostring(game ~= nil))
diag("  game.HttpGet: " .. tostring(game and game.HttpGet ~= nil))
diag("  pcall: " .. tostring(pcall ~= nil))
diag("  loadstring: " .. tostring(loadstring ~= nil))
diag("  tostring: " .. tostring(tostring ~= nil))
diag("  string: " .. tostring(string ~= nil))
diag("  _G: " .. tostring(_G ~= nil))
diag("  getgenv: " .. tostring(getgenv ~= nil))
diag("  identifyexecutor: " .. tostring(identifyexecutor ~= nil))
diag("  writefile: " .. tostring(writefile ~= nil))

-- DIAG 2: Servicios Roblox
diag("DIAG 2: Servicios Roblox")
local function check_service(name)
    local ok, svc = pcall(function() return game:GetService(name) end)
    diag("  " .. name .. ": " .. tostring(ok and svc ~= nil))
    return ok and svc or nil
end

local HttpService = check_service("HttpService")
local RbxAnalyticsService = check_service("RbxAnalyticsService")
local UserInputService = check_service("UserInputService")
local GuiService = check_service("GuiService")

if HttpService then
    diag("  HttpService.RequestAsync: " .. tostring(HttpService.RequestAsync ~= nil))
end

-- DIAG 3: Ejecutor detectado
diag("DIAG 3: Ejecutor detectado")
if identifyexecutor and type(identifyexecutor) == "function" then
    local ok, name, version = pcall(identifyexecutor)
    diag("  identifyexecutor(): " .. tostring(ok) .. " | " .. tostring(name) .. " | " .. tostring(version))
else
    diag("  identifyexecutor no disponible")
end

-- DIAG 4: Probar RequestAsync (PRINCIPAL en Xeno)
diag("DIAG 4: Probar HttpService.RequestAsync")
if HttpService and HttpService.RequestAsync then
    local ok, result = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua",
            Method = "GET"
        })
    end)
    diag("  RequestAsync resultado: " .. tostring(ok))
    if ok and result then
        diag("  RequestAsync Success: " .. tostring(result.Success))
        diag("  RequestAsync StatusCode: " .. tostring(result.StatusCode))
        diag("  RequestAsync Body tamaño: " .. tostring(result.Body and #result.Body or 0))
        if result.Body and #result.Body > 100 then
            diag("  RequestAsync Body primeros 100 chars: " .. tostring(string.sub(result.Body, 1, 100)))
        end
    else
        diag("  RequestAsync error: " .. tostring(result))
    end
else
    diag("  RequestAsync NO disponible")
end

-- DIAG 5: Probar game.HttpGet (si existe)
diag("DIAG 5: Probar game.HttpGet")
if game and game.HttpGet then
    local ok, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua", true)
    end)
    diag("  game.HttpGet resultado: " .. tostring(ok))
    if ok then
        diag("  game.HttpGet tamaño: " .. tostring(result and #result or 0))
        if result and #result > 0 then
            diag("  game.HttpGet contenido: " .. tostring(result))
        end
    else
        diag("  game.HttpGet error: " .. tostring(result))
    end
else
    diag("  game.HttpGet NO disponible")
end

diag("========================================")
diag("DIAGNOSTICO XENO - FIN")
diag("========================================")

save_diag()
