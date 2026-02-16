-- Este script se ejecuta directamente, SIN loadstring anidado
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Cargar configuración directamente (URL raw de GitHub)
local configScript = game:HttpGet("https://raw.githubusercontent.com/denzells/verified.series/main/config.lua")
local KeyAuth = loadstring(configScript)()

-- Verificar HTTP
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    return
end

-- [AQUI VA TODO EL CÓDIGO DEL PANEL - IGUAL QUE ANTES PERO USANDO KeyAuth.Verify]
-- ...

-- Ejemplo de cómo usar la verificación:
verifyBtn.MouseButton1Click:Connect(function()
    local username = getUsernameText()
    local key = getKeyText()
    
    tween(verifyBtn, 0.08, {Size = UDim2.new(0.5, -9, 0, 30)})
    task.delay(0.08, function()
        tween(verifyBtn, 0.12, {Size = UDim2.new(0.5, -5, 0, 34)})
    end)
    
    verifyBtn.Active = false
    verifyBtn.Text = "Verifying..."
    
    KeyAuth.Verify(username, key, function(success, message)
        verifyBtn.Active = true
        verifyBtn.Text = "Verify"
        
        if username == "" or key == "" then
            animateCircles(C.RED)
        elseif success then
            animateCircles(C.GREEN)
            task.delay(2, function()
                SG:Destroy()
                -- Ejecutar script principal
                local mainScript = game:HttpGet("https://raw.githubusercontent.com/denzells/serios.gg/main/main.lua")
                loadstring(mainScript)()
            end)
        else
            animateCircles(C.YELLOW)
        end
    end, httpRequest, HttpService) -- Pasamos httpRequest y HttpService como parámetros
end)
