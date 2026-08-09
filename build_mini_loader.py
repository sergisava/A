import sys

with open('C:/Users/sergisava/Desktop/AeriHub-Desofuscado/script_original.lua', 'r', encoding='utf-8') as f:
    original = f.read()

mini_wrapper = '''-- AERI HUB - MINI LOADER
local _pcall = pcall
local _loadstring = loadstring
local _tostring = tostring
local _HttpGet = game.HttpGet

local function is_luraph_check(expr)
    expr = _tostring(expr or "")
    return string.find(expr, "45700", 1, true) ~= nil
        or string.find(expr, "0x1B,0x4C,0x75,0x61,0x50", 1, true) ~= nil
end

loadstring = function(expr, env)
    if is_luraph_check(expr) then
        return function() end
    end
    return _loadstring(expr, env)
end

pcall = function(f, ...)
    if f == _loadstring or f == loadstring or (type(f) == "string" and is_luraph_check(f)) then
        return true, function() end
    end
    return _pcall(f, ...)
end

tostring = function(v)
    if v == _pcall or v == pcall or v == _loadstring or v == loadstring then
        return "LuP"
    end
    return _tostring(v)
end

game.HttpGet = function(self, url, ...)
    url = _tostring(url or "")
    if string.find(string.lower(url), "jnkie", 1, true) or string.find(string.lower(url), "sakura", 1, true) or string.find(string.lower(url), "key", 1, true) or string.find(string.lower(url), "hwid", 1, true) then
        return '{"status":"success","verified":true,"hwid":"BYPASSED","key":"BYPASSED"}'
    end
    return _HttpGet(self, url, ...)
end

if getgenv then
    getgenv().KeyVerified = true
    getgenv().LicenseKey = "BYPASSED"
    getgenv().HWID = "BYPASSED-HWID"
end

if _G then
    _G.KeyVerified = true
    _G.LicenseKey = "BYPASSED"
    _G.HWID = "BYPASSED-HWID"
end

local RbxAnalyticsService = pcall(function() return game:GetService("RbxAnalyticsService") end) and game:GetService("RbxAnalyticsService") or nil
if RbxAnalyticsService and RbxAnalyticsService.GetClientId then
    RbxAnalyticsService.GetClientId = function() return "BYPASSED-" .. tostring(os.time()) end
end

local UserInputService = pcall(function() return game:GetService("UserInputService") end) and game:GetService("UserInputService") or nil
if UserInputService and UserInputService.GetPlatform then
    UserInputService.GetPlatform = function() return Enum.Platform.Windows end
end

local GuiService = pcall(function() return game:GetService("GuiService") end) and game:GetService("GuiService") or nil
if GuiService and GuiService.GetPlatform then
    GuiService.GetPlatform = function() return Enum.Platform.Windows end
end

local script_content = [[SCRIPT_PLACEHOLDER]]

if string.find(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", 1, true) then
    script_content = string.gsub(script_content, "Sakura%.Options%.KeylessUI%s*=%s*false", "Sakura.Options.KeylessUI = true")
end

local compiled, err = _pcall(_loadstring, script_content)
if not compiled then
    warn("[AERI] Error:", err)
    return
end

local success, exec_err = _pcall(compiled)
if not success then
    warn("[AERI] Error:", exec_err)
end
'''

final = mini_wrapper.replace('SCRIPT_PLACEHOLDER', original)

with open('C:/Users/sergisava/Desktop/AeriHub-Desofuscado/aeri_hub_xeno_mini.lua', 'w', encoding='utf-8') as f:
    f.write(final)

print('Mini-loader creado:', len(final), 'chars')
print('Script original embebido:', len(original), 'chars')
print('')
print('INSTRUCCIONES:')
print('1. Abrir C:\\Users\\sergisava\\Desktop\\AeriHub-Desofuscado\\aeri_hub_xeno_mini.lua')
print('2. Copiar TODO el contenido')
print('3. Pegar en Xeno')
print('4. Ejecutar desde Xeno')
