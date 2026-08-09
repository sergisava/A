--[[
    AERI HUB - DIAGNOSTICO XENO
    Solo diagnostica. NO carga el script ofuscado.
    Usalo primero para ver donde se rompe.
]]

-- Logging basico sin dependencias
local log_lines = {}
_G.AERI_DIAG = log_lines

local function diag(msg)
    local line = "[" .. tostring(os.time()) .. "] " .. tostring(msg)
    table.insert(log_lines, line)
    pcall(function() warn("[AERI DIAG]", line) end)
end

local function save_diag()
    local path = "C:\\Users\\sergisava\\AppData\\Local\\Xeno\\AeriHub_Diagnostico.txt"
    local content = ""
    for i = 1, #log_lines do
        if i > 1 then content = content .. "\n" end
        content = content .. log_lines[i]
    end
    pcall(function()
        if writefile then
            writefile(path, content)
            diag("Diagnostico guardado en: " .. path)
        else
            diag("writefile NO disponible")
        end
    end)
end

diag("========================================")
diag("DIAGNOSTICO XENO - INICIO")
diag("========================================")

-- ============================================
-- DIAG 1: Entorno basico
-- ============================================
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

-- ============================================
-- DIAG 2: Servicios Roblox
-- ============================================
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

-- ============================================
-- DIAG 3: Librerias de executor
-- ============================================
diag("DIAG 3: Librerias de executor")

diag("  syn: " .. tostring(syn ~= nil))
if syn then
    diag("  syn.request: " .. tostring(syn.request ~= nil))
    diag("  syn.iscclosure: " .. tostring(syn.iscclosure ~= nil))
end

diag("  Krnl: " .. tostring(Krnl ~= nil))
if Krnl then
    diag("  Krnl.request: " .. tostring(Krnl.request ~= nil))
    diag("  Krnl.version: " .. tostring(Krnl.version ~= nil))
end

diag("  fluxus: " .. tostring(fluxus ~= nil))
if fluxus then
    diag("  fluxus.request: " .. tostring(fluxus.request ~= nil))
    diag("  fluxus.version: " .. tostring(fluxus.version ~= nil))
end

diag("  xenon: " .. tostring(xenon ~= nil))
if xenon then
    diag("  xenon.request: " .. tostring(xenon.request ~= nil))
end

diag("  Electron: " .. tostring(Electron ~= nil))
if Electron then
    diag("  Electron.request: " .. tostring(Electron.request ~= nil))
end

-- ============================================
-- DIAG 4: Ejecutor detectado
-- ============================================
diag("DIAG 4: Ejecutor detectado")

if identifyexecutor and type(identifyexecutor) == "function" then
    local ok, name, version = pcall(identifyexecutor)
    diag("  identifyexecutor(): " .. tostring(ok) .. " | " .. tostring(name) .. " | " .. tostring(version))
elseif getexecutorname and type(getexecutorname) == "function" then
    local ok, name = pcall(getexecutorname)
    diag("  getexecutorname(): " .. tostring(ok) .. " | " .. tostring(name))
else
    diag("  No se pudo detectar el executor")
end

-- ============================================
-- DIAG 5: Probar game.HttpGet
-- ============================================
diag("DIAG 5: Probar game.HttpGet")

if game and game.HttpGet then
    local ok, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua", true)
    end)
    diag("  game.HttpGet resultado: " .. tostring(ok))
    if ok then
        diag("  game.HttpGet tamaño respuesta: " .. tostring(result and #result or 0))
    else
        diag("  game.HttpGet error: " .. tostring(result))
    end
else
    diag("  game.HttpGet NO disponible")
end

-- ============================================
-- DIAG 6: Verificar script original sin modificar nada
-- ============================================
diag("DIAG 6: Verificar contenido del script original")

local script_url = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua"
local script_content = nil

if game and game.HttpGet then
    local ok, res = pcall(function()
        script_content = game:HttpGet(script_url)
    end)
    if ok and script_content then
        diag("  Script descargado: " .. tostring(#script_content) .. " chars")
        
        -- Contar ocurrencias de KeylessUI
        local count = 0
        local s = script_content
        while true do
            local pos = string.find(s, "KeylessUI", 1, true)
            if not pos then break end
            count = count + 1
            s = string.sub(s, pos + 1)
        end
        diag("  KeylessUI encontrado: " .. tostring(count))
        
        -- Buscar Sakura.Options.KeylessUI = false
        if string.find(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", 1, true) then
            diag("  Sakura.Options.KeylessUI = false: ENCONTRADO")
        else
            diag("  Sakura.Options.KeylessUI = false: NO ENCONTRADO")
        end
    else
        diag("  Error descargando script: " .. tostring(res))
    end
else
    diag("  game.HttpGet no disponible, no se puede descargar")
end

-- ============================================
-- FIN DIAGNOSTICO
-- ============================================
diag("========================================")
diag("DIAGNOSTICO XENO - FIN")
diag("========================================")

save_diag()
