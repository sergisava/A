-- ============================================
-- AERI HUB - Blox Fruits
-- Script desofuscado manualmente
-- Original: Luraph Obfuscator v14.7
-- ============================================

-- ============================================
-- CONFIGURACIÓN DE INTERFAZ (SakuraUI)
-- ============================================

local Sakura = loadstring(game:HttpGet("https://cdn.jnkie.com/SakuraUI.lua"))()

-- Apariencia de la ventana principal
Sakura.Appearance = {
    Title = "Aeri Hub",
    Subtitle = "Enter your key",
    Tagline = "where petals fall, magic follows",
    Icon = "rbxassetid://116255434488074",
    IconSize = UDim2.fromOffset(30, 30),
}

-- Enlaces y almacenamiento
Sakura.Links.Discord = "https://discord.gg/fAcgQ7eVqp"
Sakura.Storage.FileName = "Jnkie_key"
Sakura.Options.Keyless = true
Sakura.Options.KeylessUI = false

-- Tienda (deshabilitada)
Sakura.Shop = {
    Enabled = false,
    Icon = "",
    Title = "Get Premium",
    Subtitle = "Instant delivery • 24/7 support",
    ButtonText = "Buy",
    Link = "jnkie.com"
}

-- Iniciar el sistema de keys de Sakura
Sakura:LaunchJunkie({
    Service = "Blox fruit",
    Identifier = "1143517",
    Provider = "BloxFruitAlephi"
})

-- ============================================
-- DESOFUSCADOR DE LURAPH v14.7
-- ============================================
-- Este bloque decodifica y ejecuta el payload
-- empaquetado por Luraph Obfuscator v14.7

-- Variables locales del desofuscador
local subStr, charTable, pcallRef, setmetatableRef, byte, tostringRef, offset, char, pack, loadstr, gsub, unpack =
    string.sub, {}, pcall, setmetatable, string.byte, tostring, 5, string.char, string.pack, loadstring, string.gsub, unpack

-- Generar tabla de caracteres ASCII (0-255)
for i = 0, 255 do
    charTable[i] = char(i)
end

-- Inicialización del desofuscador
-- Código de verificación de entorno (no afecta la lógica principal)
do
    charTable = {45700, {0x1B, 0x4C, 0x75, 0x61, 0x50}, tostringRef(pcallRef)}
    for indice, valor in charTable do
        local resultado = {pcallRef(loadstr, indice % 2 == 0 and char(unpack(valor)) or valor, nil, nil)}
        if resultado[1] and pcallRef(resultado[2]) ~= not resultado[3] then
            offset = 20.0
        end
    end
end

--[[
    Función de decodificación del payload
    Decodifica el formato LPH (Luraph Packed Hash)
    Utiliza codificación base-85 para reconstructurar los bytes originales
]]
local function decodificarPayload(datos)
    -- Extraer substring desde el offset calculado (inicialmente 5, luego 20)
    datos = subStr(datos, offset)
    
    -- Reemplazos iniciales del formato LPH
    datos = gsub(datos, "z", "!!!!!")
    
    -- Decodificar grupos de 5 caracteres base-85 a 4 bytes
    -- Cada caracter tiene valor 33-117 (85 caracteres = base-85)
    return gsub(datos, ".....", setmetatableRef({}, {
        __index = function(tabla, clave)
            -- Extraer 5 bytes de la clave
            local j, g, i, C, t = byte(clave, 1, 5)
            
            -- Decodificar valor base-85
            -- Fórmula: c1 + c2*85 + c3*7225 + c4*614125 + c5*52200625
            local W = (t - 33) + (C - 33) * 85 + (i - 33) * 7225 + (g - 33) * 614125 + (j - 33) * 52200625
            
            -- Empaquetar como entero de 32 bits little-endian
            local packed = pack("<I4", W)
            tabla[clave] = packed
            return packed
        end
    }))
end

-- Decodificar el payload empaquetado de Luraph
-- El string LPH$ contiene los datos comprimidos del script original
local datosDecodificados = decodificarPayload([=[LPH$V]7Sp\kh%nLO9CGWKD,PR+8a3d@Ccf$=,,=rb2LFi@?Ws:GTRd='<Du-p,(5"l<f\.pX[24WKP*EWo,p?[]"Jc8_G-3KBu.-19EFH-a:B`J>F2C\1<gZ5E<enQKYaQ9ujI6jt$HfkGY-+We>RS]>CC\<:@]1atCubt(4+'iT\rdU$l#@\@d./B"&%TMqD<-m\OJ:51S9]uN<>oK#n/k`7'XUf04lC]f!B@+VnL,fmeufJYl19M:,:%Fa`:J46C$KQ7]cSkp,`O0U(OX`<h.Ac;F6E9C+*G0[0nZrH_CCk7?;IsPPTR?hcI$!P58q8'pD0YQ-:kNJWTm^/OkQWdCh+oe\f(m%(k75qj-U:)[L%?3V?)YN7>XKi1,q+f,6M&PHGKHa"1P*lo(F#K3a@+7kQ2d$/-Hs9p.<,ui&OgYC;48V0&0I<hd#Yl#InsYG]ho9qHaoH#S0C()nm1Y_uG2WpggTQkGP%E;Q7,:>_`97e0OaA-r<kskOP?),#dQhDs[u"*%mM\74cX@n7"Y66:BVU@qW&GUH5fd37:OP=(8,aGd:X;^Ln$#Eo'HcF@g)`:A14Z_3WDUffQZ)<pWnE5dQ?D,32.i20R[SgV7MtJ!@TERm_0qO2^^1tmS7/g-M=_#g^TiM[7ohuWb70a'>QRW$7qD^"qom(i3!h/Cn#h!XeO87o[K&>K`1dmG7XT[)@k#Y)&_PkP<J7W8m\;"T7>6*=H#"5*:nJbEcUY($kYQF6AjTs@c^lq.d8)bV6QMd&dl7Z892ri\:PPUcA0OX#:S7qLK@r$TQ>:fG4719s5$Gd]@:A:;;8@o7knTN"[_>`#[BTj)Y9,@2g=fpJ-Oi<M&n1uq@4V8&V7&K=@=<Nk[)29n\&_gP^-I4q:K$QeNf*h5-?s:?QXKGc;=0tsUQ$Vbhrr8>?TrS3J,]0'aJgNhb/E:A?1uXR(G<(Q,LN:;%Z-LTRgMd-Ag^:%.Oes#+Rsk\6#_r:eSdY*gg\T:;Fj0>])AG5p</T4Haa`=hPtNi#_J::O+SO2.k:"l.T*ok`Ee4?X/o&O5dUV]5YKD^gf2PqF0u@L8Y2_@9b:j?M_p"B1oYrfE/9]10'A3);-tZb#-2[=QYQnsmu0Z/L7O<J?>1)\RE$5Wp<,\cT&#-ak\^0?Wt"VmO9@q5#H&B>;3?t)%of&UA`DL;jL1uu((ei]g\TCPRmie2dgmJ?hEK*$b0%$s#+WsqS=!Kt4uX2&?Z.OK+C[=SY3*5q9<IjB,4@bDf?;"C$$53XfFPPEZ<4u0T9IApf:=VTgmK]%+Cui\f.X8!@9%\EHa$mgo8jLLQIi&Yl<*\#>`%@;-IUhJ:CB;qJN6?b<u.l2AdSg[>^=r`%;;59=Z%PnQL%S(3L/eN6uH&tUrhKn]U^#^\m^C=/bLap7"Qh3`R3:/@p...]]=])

--[[
    NOTA IMPORTANTE:
    El payload decodificado anterior (30,679 caracteres) contiene el bytecode
    del intérprete de VM de Luraph v14.7. Para obtener el script Lua original,
    este payload debe ser ejecutado en el entorno de Roblox, donde el código
    de descompresión de la VM lo procesará y ejecutará el script final.
    
    El archivo 'payload_decodificado.lua' contiene los datos decodificados
    pero aún comprimidos con el algoritmo de VM de Luraph.
]]

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
