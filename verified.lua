-- ARCHIVO ÚNICO: todo.lua (sube esto a GitHub)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- CONFIGURACIÓN DIRECTA (no necesita cargar otro archivo)
local KeyAuthConfig = {
    Name = "serios.gg",
    OwnerID = "UPGTkUDkee",
    Version = "1.0"
}
local KeyAuthURL = "https://keyauth.win/api/1.2/"

-- Verificar HTTP
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    return
end

-- Función de verificación
local function verifyWithKeyAuth(username, key, callback)
    if username == "" or key == "" then
        callback(false, "empty")
        return
    end
    
    local initData = "type=init&name=" .. KeyAuthConfig.Name .. "&ownerid=" .. KeyAuthConfig.OwnerID .. "&version=" .. KeyAuthConfig.Version
    
    local initSuccess, initResponse = pcall(function()
        return httpRequest({
            Url = KeyAuthURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
            Body = initData
        })
    end)
    
    if not initSuccess or not initResponse or not initResponse.Body then
        callback(false, "connection_error")
        return
    end
    
    local initData
    local parseSuccess = pcall(function()
        initData = HttpService:JSONDecode(initResponse.Body)
    end)
    
    if not parseSuccess or not initData.success or not initData.sessionid then
        callback(false, "init_failed")
        return
    end
    
    local loginData = "type=login&username=" .. username .. "&pass=" .. key .. "&sessionid=" .. initData.sessionid .. "&name=" .. KeyAuthConfig.Name .. "&ownerid=" .. KeyAuthConfig.OwnerID
    
    local loginSuccess, loginResponse = pcall(function()
        return httpRequest({
            Url = KeyAuthURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
            Body = loginData
        })
    end)
    
    if not loginSuccess or not loginResponse or not loginResponse.Body then
        callback(false, "connection_error")
        return
    end
    
    local loginData
    parseSuccess = pcall(function()
        loginData = HttpService:JSONDecode(loginResponse.Body)
    end)
    
    if not parseSuccess then
        callback(false, "parse_error")
        return
    end
    
    callback(loginData.success, loginData.message or (loginData.success and "Verified" or "invalid"))
end

-- Crear GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end

local old = PlayerGui:FindFirstChild("PanelBase")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = "PanelBase"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = PlayerGui

-- Colors
local C = {
    WIN = Color3.fromRGB(12, 12, 12),
    TBAR = Color3.fromRGB(8, 8, 8),
    LINE = Color3.fromRGB(42, 42, 42),
    RED = Color3.fromRGB(205, 30, 30),
    WHITE = Color3.fromRGB(235, 235, 235),
    GRAY = Color3.fromRGB(110, 110, 110),
    MUTED = Color3.fromRGB(55, 55, 55),
    INPUT = Color3.fromRGB(18, 18, 18),
    GREEN = Color3.fromRGB(50, 200, 80),
    YELLOW = Color3.fromRGB(255, 200, 50),
}

-- Funciones helper
local function mk(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
    if parent then obj.Parent = parent end
    return obj
end

local function rnd(radius, parent)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function tween(obj, time, props, easing, direction)
    local tweenInfo = TweenInfo.new(time, easing or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- Ventana
local WW, WH = 320, 260
local TH = 42

local Win = mk("Frame", {
    Size = UDim2.new(0, WW, 0, WH),
    Position = UDim2.new(0.5, -WW/2, 0.5, -WH/2),
    BackgroundColor3 = C.WIN,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ClipsDescendants = false,
    ZIndex = 3,
}, SG)
rnd(14, Win)

local WinStroke = mk("UIStroke", {
    Color = C.LINE,
    Thickness = 1,
    Transparency = 0.4
}, Win)

-- Titlebar
local TBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, TH),
    BackgroundColor3 = C.TBAR,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 6,
    ClipsDescendants = false,
    Active = true,
}, Win)
rnd(14, TBar)

mk("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = C.TBAR,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 5,
    Active = false,
}, TBar)

local rdot = mk("Frame", {
    Size = UDim2.new(0, 10, 0, 10),
    Position = UDim2.new(0, 14, 0.5, -5),
    BackgroundColor3 = C.RED,
    BorderSizePixel = 0,
    ZIndex = 8
}, TBar)
rnd(5, rdot)

-- Títulos
local title1 = mk("TextLabel", {
    Text = "serios.gg",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = C.WHITE,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 100, 0, TH),
    Position = UDim2.new(0, 30, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 8
}, TBar)

local title2 = mk("TextLabel", {
    Text = "|",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = C.RED,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 14, 0, TH),
    Position = UDim2.new(0, 133, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 8
}, TBar)

-- Botones control
local MinB = mk("TextButton", {
    Text = "─",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = C.GRAY,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 36, 0, TH),
    Position = UDim2.new(0, WW-72, 0, 0),
    ZIndex = 8,
    AutoButtonColor = false
}, TBar)

local ClsB = mk("TextButton", {
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = C.GRAY,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 36, 0, TH),
    Position = UDim2.new(0, WW-36, 0, 0),
    ZIndex = 8,
    AutoButtonColor = false
}, TBar)

ClsB.MouseEnter:Connect(function() tween(ClsB, 0.1, {TextColor3 = C.RED}) end)
ClsB.MouseLeave:Connect(function() tween(ClsB, 0.1, {TextColor3 = C.GRAY}) end)
MinB.MouseEnter:Connect(function() tween(MinB, 0.1, {TextColor3 = C.WHITE}) end)
MinB.MouseLeave:Connect(function() tween(MinB, 0.1, {TextColor3 = C.GRAY}) end)

-- Body
local Body = mk("Frame", {
    Size = UDim2.new(1, -40, 1, -TH-60),
    Position = UDim2.new(0, 20, 0, TH+20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 4,
}, Win)

-- Input creator
local function CreateInput(parent, labelText, yPos, isPassword)
    local container = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        Position = UDim2.new(0, 0, 0, yPos),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5
    }, parent)
    
    mk("TextLabel", {
        Text = labelText,
        Font = Enum.Font.GothamSemibold,
        TextSize = 10,
        TextColor3 = C.WHITE,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    }, container)
    
    local inputBg = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = C.INPUT,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 6
    }, container)
    rnd(6, inputBg)
    mk("UIStroke", {Color = C.LINE, Thickness = 1, Transparency = 0.6}, inputBg)
    
    local input = mk("TextBox", {
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.WHITE,
        PlaceholderText = labelText,
        PlaceholderColor3 = C.MUTED,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 7
    }, inputBg)
    
    local realText = ""
    
    if isPassword then
        input.TextEditable = true
        input.FocusLost:Connect(function()
            input.Text = string.rep("•", #realText)
        end)
        input:GetPropertyChangedSignal("Text"):Connect(function()
            if input:IsFocused() then
                realText = input.Text
            end
        end)
    end
    
    input.Focused:Connect(function()
        tween(inputBg, 0.15, {BackgroundColor3 = Color3.fromRGB(22, 22, 22), BackgroundTransparency = 0.1})
        local stroke = inputBg:FindFirstChildOfClass("UIStroke")
        if stroke then tween(stroke, 0.15, {Color = C.RED, Transparency = 0.4}) end
    end)
    
    input.FocusLost:Connect(function()
        tween(inputBg, 0.15, {BackgroundColor3 = C.INPUT, BackgroundTransparency = 0.2})
        local stroke = inputBg:FindFirstChildOfClass("UIStroke")
        if stroke then tween(stroke, 0.15, {Color = C.LINE, Transparency = 0.6}) end
    end)
    
    local function getRealText()
        if isPassword then
            return realText
        else
            return input.Text
        end
    end
    
    return input, container, getRealText
end

-- Inputs
local usernameInput, userContainer, getUsernameText = CreateInput(Body, "Username", 0, false)
local keyInput, keyContainer, getKeyText = CreateInput(Body, "Key", 66, true)

-- Botón verify
local verifyBtn = mk("TextButton", {
    Text = "Verify",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = C.WHITE,
    BackgroundColor3 = C.RED,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 6,
    Size = UDim2.new(0.5, -5, 0, 34),
    Position = UDim2.new(0.25, 0, 0, 145),
    AutoButtonColor = false
}, Body)
rnd(6, verifyBtn)
mk("UIStroke", {Color = Color3.fromRGB(255, 50, 50), Thickness = 1, Transparency = 0.4}, verifyBtn)

-- Status circles
local statusContainer = mk("Frame", {
    Size = UDim2.new(0, 46, 0, 10),
    Position = UDim2.new(0, 149, 0.5, -5),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 8
}, TBar)

local circles = {}
for i = 1, 3 do
    local circle = mk("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, (i-1)*18, 0, 0),
        BackgroundColor3 = C.WHITE,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 9
    }, statusContainer)
    rnd(5, circle)
    circles[i] = circle
end

local function resetCircles()
    for i, circle in ipairs(circles) do
        tween(circle, 0.2, {BackgroundColor3 = C.WHITE, BackgroundTransparency = 0.3})
    end
end

local function animateCircles(color)
    for i, circle in ipairs(circles) do
        task.delay((i-1) * 0.08, function()
            tween(circle, 0.3, {BackgroundColor3 = color, BackgroundTransparency = 0})
        end)
    end
    task.delay(1, resetCircles)
end

-- Verify logic
verifyBtn.MouseButton1Click:Connect(function()
    local username = getUsernameText()
    local key = getKeyText()
    
    tween(verifyBtn, 0.08, {Size = UDim2.new(0.5, -9, 0, 30)})
    task.delay(0.08, function()
        tween(verifyBtn, 0.12, {Size = UDim2.new(0.5, -5, 0, 34)})
    end)
    
    verifyBtn.Active = false
    verifyBtn.Text = "Verifying..."
    
    verifyWithKeyAuth(username, key, function(success, message)
        verifyBtn.Active = true
        verifyBtn.Text = "Verify"
        
        if username == "" or key == "" then
            animateCircles(C.RED)
        elseif success then
            animateCircles(C.GREEN)
            task.delay(2, function()
                SG:Destroy()
                -- Aquí puedes poner tu script principal directamente
                print("✅ Verificado correctamente")
                -- loadstring(game:HttpGet("URL_DE_TU_SCRIPT"))()
            end)
        else
            animateCircles(C.YELLOW)
        end
    end)
end)

-- Drag system
do
    local dragging = false
    local mStart = Vector2.new()
    local wStart = Vector2.new()
    
    local DragHit = mk("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -72, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 50,
        AutoButtonColor = false,
    }, TBar)
    
    DragHit.MouseButton1Down:Connect(function()
        local mp = UIS:GetMouseLocation()
        dragging = true
        mStart = mp
        wStart = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
    end)
    
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mp = UIS:GetMouseLocation()
        local d = mp - mStart
        local tx = wStart.X + d.X
        local ty = wStart.Y + d.Y
        local cx = Win.Position.X.Offset
        local cy = Win.Position.Y.Offset
        local nx = cx + (tx - cx) * 0.5
        local ny = cy + (ty - cy) * 0.5
        if math.abs(nx - tx) < 0.3 then nx = tx end
        if math.abs(ny - ty) < 0.3 then ny = ty end
        Win.Position = UDim2.new(0.5, nx, 0.5, ny)
    end)
end

-- Body animation
local function animateBodyElements(show)
    local targetTransparency = show and 0 or 1
    
    for _, child in ipairs(userContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            tween(child, 0.2, {TextTransparency = targetTransparency})
        end
    end
    
    for _, child in ipairs(keyContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            tween(child, 0.2, {TextTransparency = targetTransparency})
        end
    end
    
    local function animateInputBg(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") then
                local targetBgTransparency = show and 0.2 or 1
                tween(child, 0.2, {BackgroundTransparency = targetBgTransparency})
                local stroke = child:FindFirstChildOfClass("UIStroke")
                if stroke then
                    tween(stroke, 0.2, {Transparency = show and 0.6 or 1})
                end
                local textbox = child:FindFirstChildOfClass("TextBox")
                if textbox then
                    tween(textbox, 0.2, {
                        TextTransparency = targetTransparency,
                        PlaceholderColor3 = show and C.MUTED or Color3.fromRGB(0, 0, 0)
                    })
                end
            end
        end
    end
    
    animateInputBg(userContainer)
    animateInputBg(keyContainer)
    
    local btnTargetTransparency = show and 0.1 or 1
    tween(verifyBtn, 0.2, {
        BackgroundTransparency = btnTargetTransparency,
        TextTransparency = targetTransparency,
        Size = show and UDim2.new(0.5, -5, 0, 34) or UDim2.new(0.5, -5, 0, 0)
    })
    
    local btnStroke = verifyBtn:FindFirstChildOfClass("UIStroke")
    if btnStroke then
        tween(btnStroke, 0.2, {Transparency = show and 0.4 or 1})
    end
end

-- Minimize/Close
local minimized = false
local animating = false

MinB.MouseButton1Click:Connect(function()
    if animating then return end
    animating = true
    minimized = not minimized
    
    if minimized then
        animateBodyElements(false)
        tween(Body, 0.3, {Size = UDim2.new(1, -40, 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(Win, 0.3, {Size = UDim2.new(0, WW, 0, TH), BackgroundTransparency = 0.15}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(WinStroke, 0.25, {Transparency = 0.5})
        tween(title1, 0.2, {TextTransparency = 0.5})
        task.delay(0.35, function() animating = false end)
    else
        tween(Win, 0.35, {Size = UDim2.new(0, WW, 0, WH), BackgroundTransparency = 0.15}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(Body, 0.35, {Size = UDim2.new(1, -40, 1, -TH-60)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(WinStroke, 0.3, {Transparency = 0.4})
        tween(title1, 0.25, {TextTransparency = 0})
        task.delay(0.15, function() animateBodyElements(true) end)
        task.delay(0.5, function() animating = false end)
    end
    MinB.Text = minimized and "□" or "─"
end)

local function doClose()
    if animating then return end
    animating = true
    Win.Active = false
    
    animateBodyElements(false)
    tween(Body, 0.3, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0, TH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(rdot, 0.2, {BackgroundTransparency = 1})
    tween(title1, 0.2, {TextTransparency = 1})
    tween(title2, 0.2, {TextTransparency = 1})
    tween(MinB, 0.2, {TextTransparency = 1})
    tween(ClsB, 0.2, {TextTransparency = 1})
    
    for _, circle in ipairs(circles) do
        tween(circle, 0.2, {BackgroundTransparency = 1})
    end
    
    task.delay(0.4, function()
        tween(Win, 0.35, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(WinStroke, 0.3, {Transparency = 1})
    end)
    task.delay(0.8, function() SG:Destroy() end)
end

ClsB.MouseButton1Click:Connect(doClose)

-- Hotkeys
local hidden = false
UIS.InputBegan:Connect(function(i, gp)
    if gp or animating then return end
    
    if i.KeyCode == Enum.KeyCode.RightShift then
        hidden = not hidden
        if hidden then
            tween(Win, 0.2, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine)
            tween(WinStroke, 0.2, {Transparency = 1})
            animateBodyElements(false)
            for _, circle in ipairs(circles) do
                tween(circle, 0.2, {BackgroundTransparency = 1})
            end
            task.delay(0.2, function() Win.Visible = false end)
        else
            Win.Visible = true
            Win.BackgroundTransparency = 1
            WinStroke.Transparency = 1
            tween(Win, 0.25, {BackgroundTransparency = 0.15}, Enum.EasingStyle.Sine)
            tween(WinStroke, 0.25, {Transparency = 0.4})
            for _, circle in ipairs(circles) do
                tween(circle, 0.25, {BackgroundTransparency = 0.3})
            end
            task.delay(0.15, function() animateBodyElements(true) end)
        end
    end
    
    if i.KeyCode == Enum.KeyCode.End then
        doClose()
    end
end)

-- Open animation
Win.Size = UDim2.new(0, WW/3, 0, TH)
Win.BackgroundTransparency = 1
WinStroke.Transparency = 1
Body.Size = UDim2.new(1, -40, 0, 0)
Body.Position = UDim2.new(0, 20, 0, TH+20)
rdot.BackgroundTransparency = 1
title1.TextTransparency = 1
title2.TextTransparency = 1
MinB.TextTransparency = 1
ClsB.TextTransparency = 1

for _, circle in ipairs(circles) do
    circle.BackgroundTransparency = 1
end

animateBodyElements(false)

tween(Win, 0.4, {Size = UDim2.new(0, WW, 0, TH), BackgroundTransparency = 0.15}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
tween(WinStroke, 0.35, {Transparency = 0.4})

task.delay(0.1, function()
    tween(rdot, 0.3, {BackgroundTransparency = 0}, Enum.EasingStyle.Sine)
    task.delay(0.05, function() tween(title1, 0.3, {TextTransparency = 0}, Enum.EasingStyle.Sine) end)
    task.delay(0.08, function() tween(title2, 0.3, {TextTransparency = 0}, Enum.EasingStyle.Sine) end)
    task.delay(0.11, function()
        for i, circle in ipairs(circles) do
            task.delay((i-1) * 0.05, function()
                tween(circle, 0.25, {BackgroundTransparency = 0.3}, Enum.EasingStyle.Sine)
            end)
        end
    end)
    task.delay(0.2, function()
        tween(MinB, 0.25, {TextTransparency = 0}, Enum.EasingStyle.Sine)
        tween(ClsB, 0.25, {TextTransparency = 0}, Enum.EasingStyle.Sine)
    end)
end)

task.delay(0.25, function()
    tween(Win, 0.45, {Size = UDim2.new(0, WW, 0, WH), BackgroundTransparency = 0.15}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(Body, 0.45, {Size = UDim2.new(1, -40, 1, -TH-60)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    task.delay(0.3, function() animateBodyElements(true) end)
end)
