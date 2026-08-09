--[[
    AERI HUB - DIAGNOSTICO XENO (ROBLOX SAFE)
    No usa os.getenv. Usa rutas seguras para Roblox/Xeno.
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
    local paths = {
        "AeriHub_Diagnostico.txt",
        "AeriHub_Diagnostico.txt",
        "AeriHub_Diagnostico.txt",
    }
    
    local saved = false
    for i = 1, #paths do
        local path = paths[i]
        diag("Probando guardar en: " .. path)
        local content = ""
        for j = 1, #log_lines do
            if j > 1 then content = content .. "\n" end
            content = content .. log_lines[j]
        end
        local ok, err = pcall(function()
            if writefile then
                writefile(path, content)
            end
        end)
        if ok then
            diag("EXITO: Log guardado en: " .. path)
            saved = true
            break
        else
            diag("FALLO en " .. path .. ": " .. tostring(err))
        end
    end
    
    if not saved then
        diag("ERROR: No se pudo guardar el log en ninguna ruta")
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

-- DIAG 4: Probar game.HttpGet
diag("DIAG 4: Probar game.HttpGet")
if game and game.HttpGet then
    local ok, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua", true)
    end)
    diag("  game.HttpGet resultado: " .. tostring(ok))
    if ok then
        diag("  game.HttpGet tamaño respuesta: " .. tostring(result and #result or 0))
        diag("  game.HttpGet primeros 100 chars: " .. tostring(result and string.sub(result, 1, 100) or "nil"))
    else
        diag("  game.HttpGet error: " .. tostring(result))
    end
else
    diag("  game.HttpGet NO disponible")
end

-- DIAG 5: Probar HttpService.RequestAsync
if HttpService and HttpService.RequestAsync then
    diag("DIAG 5: Probar HttpService.RequestAsync")
    local ok, result = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua",
            Method = "GET"
        })
    end)
    diag("  RequestAsync resultado: " .. tostring(ok))
    if ok and result then
        diag("  RequestAsync StatusCode: " .. tostring(result.StatusCode))
        diag("  RequestAsync Body tamaño: " .. tostring(result.Body and #result.Body or 0))
        diag("  RequestAsync Body primeros 100 chars: " .. tostring(result.Body and string.sub(result.Body, 1, 100) or "nil"))
    else
        diag("  RequestAsync error: " .. tostring(result))
    end
else
    diag("DIAG 5: HttpService.RequestAsync NO disponible")
end

-- DIAG 6: Verificar contenido del script original
diag("DIAG 6: Verificar contenido del script original")

local script_url = "https://raw.githubusercontent.com/sergisava/A/refs/heads/master/script.lua"
local script_content = nil

-- Intentar con game.HttpGet primero
if game and game.HttpGet then
    local ok, res = pcall(function()
        script_content = game:HttpGet(script_url, true)
    end)
    if ok and script_content and #script_content > 100 then
        diag("  Script descargado por game.HttpGet: " .. tostring(#script_content) .. " chars")
    else
        diag("  game.HttpGet fallo o respuesta muy corta: " .. tostring(#script_content or 0) .. " chars")
        script_content = nil
    end
end

-- Si fallo, intentar con RequestAsync
if not script_content and HttpService and HttpService.RequestAsync then
    local ok, res = pcall(function()
        local response = HttpService:RequestAsync({
            Url = script_url,
            Method = "GET"
        })
        if response and response.Success then
            script_content = response.Body
        end
    end)
    if ok and script_content and #script_content > 100 then
        diag("  Script descargado por RequestAsync: " .. tostring(#script_content) .. " chars")
    else
        diag("  RequestAsync tambien fallo: " .. tostring(#script_content or 0) .. " chars")
    end
end

if script_content and #script_content > 100 then
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
    
    -- Buscar URLs de jnkie
    if string.find(script_content, "jnkie", 1, true) then
        diag("  jnkie.com: ENCONTRADO en el script")
    else
        diag("  jnkie.com: NO ENCONTRADO en el script")
    end
else
    diag("  No se pudo descargar el script completo")
end

diag("========================================")
diag("DIAGNOSTICO XENO - FIN")
diag("========================================")

save_diag()
