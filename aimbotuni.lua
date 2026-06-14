-- Oyunu ve PlayerGui'yi güvenli bir şekilde bekle (Kodun takılmasını önler)
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local ESP_Settings = {
    Box = false,        -- 2D Kutu ESP
    Highlight = false,  -- Highlight ESP (Chams)
    RainbowChams = false,-- Gökkuşağı Chams Modu
    Skeleton = false,   -- 3D İskelet ESP
    Aimbot = false,     -- Kafaya Kilitlenme
    AimMode = "Instant", -- "Instant" veya "Smooth"
    AimKey = Enum.KeyCode.E,
    AimRange = 800,
    Smoothness = 0.15,
    SpinBot = false,     -- Spin Bot Açma/Kapama
    SpinSpeed = 25,      -- Başlangıç Spin Hızı (Orta)
    ScreenFOV = 70,      -- Varsayılan Minecraft tarzı ekran FOV açısı
    BunnyHop = false,    -- BunnyHop Açma/Kapama
    InfiniteJump = false,-- Sonsuz Zıplama
    Noclip = false       -- Duvarlardan Geçme
}

local Aimbot_Active = false
local currentSpinAngle = 0 -- Spin Botun anlık açısını tutar
local rainbowHue = 0       -- Rainbow Efekti için anlık renk tonu değeri

-- [[ MODERN NEBULO UI OLUŞTURMA ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NebuloMenu_Official"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999999
ScreenGui.Parent = PlayerGui

-- Parlayan Dış Çerçeve ve Ana Panel
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 340)
local targetMenuPos = UDim2.new(0.5, -240, 0.4, -140)
MainFrame.Position = targetMenuPos 
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BackgroundTransparency = 0 
MainFrame.Visible = true
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

-- Mor Parlama Efekti (UIStroke)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(75, 55, 130)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Transparency = 0 
UIStroke.Parent = MainFrame

-- Sol Logo Alanı
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 120, 0, 40)
LogoLabel.Position = UDim2.new(0, 0, 0, 5)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "NEBULO V1.9"
LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 16
LogoLabel.TextTransparency = 0
LogoLabel.ZIndex = 6
LogoLabel.Parent = MainFrame

-- Sol Seçim Sekme Paneli (Tabs Frame)
local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 120, 1, -50)
TabPanel.Position = UDim2.new(0, 0, 0, 50)
TabPanel.BackgroundTransparency = 1
TabPanel.ZIndex = 6
TabPanel.Parent = MainFrame

-- Sağ İçerik Panelleri
local AimbotContent = Instance.new("Frame")
AimbotContent.Size = UDim2.new(1, -135, 1, -20)
AimbotContent.Position = UDim2.new(0, 125, 0, 10)
AimbotContent.BackgroundTransparency = 1
AimbotContent.Visible = true
AimbotContent.ZIndex = 6
AimbotContent.Parent = MainFrame

local VisualsContent = Instance.new("Frame")
VisualsContent.Size = UDim2.new(1, -135, 1, -20)
VisualsContent.Position = UDim2.new(0, 125, 0, 10)
VisualsContent.BackgroundTransparency = 1
VisualsContent.Visible = false
VisualsContent.ZIndex = 6
VisualsContent.Parent = MainFrame

-- Menü Açılış/Kapanış Sistemi
local menuOpen = true
local function ToggleMenu(state)
    menuOpen = state
    if menuOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetMenuPos, BackgroundTransparency = 0}):Play()
        TweenService:Create(UIStroke, TweenInfo.new(0.25), {Transparency = 0}):Play()
        TweenService:Create(LogoLabel, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
        
        for _, child in pairs(TabPanel:GetChildren()) do
            if child:IsA("TextButton") then
                child.Visible = true
                TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 0, BackgroundTransparency = 0.5}):Play()
            end
        end
    else
        local hidePos = UDim2.new(0.5, -240, 0.2, -140)
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = hidePos, BackgroundTransparency = 1}):Play()
        TweenService:Create(UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        TweenService:Create(LogoLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        
        for _, child in pairs(TabPanel:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.15), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
            end
        end
        task.wait(0.2)
        if not menuOpen then MainFrame.Visible = false end
    end
end

-- Sekme Değiştirme
local function SwitchTab(tabName)
    if tabName == "Aimbot" then
        AimbotContent.Visible = true
        VisualsContent.Visible = false
    elseif tabName == "Visuals" then
        VisualsContent.Visible = true
        AimbotContent.Visible = false
    end
end

-- Sol Sekme Butonlarını Oluşturma
local function CreateTabButton(text, posIndex, tabTarget)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 10, 0, (posIndex - 1) * 40)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = "  " .. text
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    TabBtn.TextTransparency = 0
    TabBtn.ZIndex = 7
    TabBtn.Parent = TabPanel
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 4)
    TCorner.Parent = TabBtn
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Thickness = 1
    ButtonStroke.Color = Color3.fromRGB(40, 40, 50)
    ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ButtonStroke.Transparency = 0
    ButtonStroke.Parent = TabBtn
    
    TabBtn.MouseEnter:Connect(function()
        TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 30, 80), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(120, 85, 200)}):Play()
    end)
    TabBtn.MouseLeave:Connect(function()
        TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 35), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        SwitchTab(tabTarget)
    end)
end

CreateTabButton("Aimbot", 1, "Aimbot")
CreateTabButton("Visuals", 2, "Visuals")

-- Menü Toggle Elemanları Yapısı
local btnCounts = {Aimbot = 0, Visuals = 0}
local function CreateMenuToggle(text, settingName, parentFrame, specialType)
    local section = parentFrame == AimbotContent and "Aimbot" or "Visuals"
    btnCounts[section] = btnCounts[section] + 1
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 26)
    Container.Position = UDim2.new(0, 0, 0, (btnCounts[section] - 1) * 28)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 6
    Container.Parent = parentFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 7
    Label.Parent = Container
    
    local ActionButton = Instance.new("TextButton")
    ActionButton.Size = UDim2.new(0, 110, 0, 20)
    ActionButton.Position = UDim2.new(1, -110, 0.5, -10)
    ActionButton.BorderSizePixel = 0
    ActionButton.Font = Enum.Font.GothamBold
    ActionButton.TextSize = 10
    ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionButton.ZIndex = 7
    ActionButton.Parent = Container
    
    local ACorner = Instance.new("UICorner")
    ACorner.CornerRadius = UDim.new(0, 4)
    ACorner.Parent = ActionButton

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Thickness = 1
    ToggleStroke.Color = Color3.fromRGB(50, 50, 60)
    ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ToggleStroke.Parent = ActionButton

    ActionButton.MouseEnter:Connect(function()
        local highlightColor = Color3.fromRGB(120, 85, 200)
        if specialType == nil and not ESP_Settings[settingName] then
            highlightColor = Color3.fromRGB(55, 55, 70)
        elseif specialType == "Mode" then
            highlightColor = Color3.fromRGB(110, 65, 140)
        elseif specialType == "SpinSpeed" then
            highlightColor = Color3.fromRGB(65, 95, 140)
        elseif specialType == "ScreenFOV" then
            highlightColor = Color3.fromRGB(140, 95, 45)
        end
        TweenService:Create(ActionButton, TweenInfo.new(0.15), {BackgroundColor3 = highlightColor}):Play()
    end)
    ActionButton.MouseLeave:Connect(function()
        local normalColor = Color3.fromRGB(35, 35, 40)
        if specialType == nil and ESP_Settings[settingName] then
            normalColor = Color3.fromRGB(100, 65, 165)
        elseif specialType == "Mode" then
            normalColor = (ESP_Settings.AimMode == "Instant" and Color3.fromRGB(55, 45, 90) or Color3.fromRGB(90, 45, 120))
        elseif specialType == "SpinSpeed" then
            normalColor = Color3.fromRGB(45, 75, 110)
        elseif specialType == "ScreenFOV" then
            normalColor = Color3.fromRGB(100, 65, 30)
        end
        TweenService:Create(ActionButton, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
    end)

    local function UpdateVisualState()
        if specialType == nil then
            if ESP_Settings[settingName] then
                ActionButton.BackgroundColor3 = Color3.fromRGB(100, 65, 165)
                ActionButton.Text = "ENABLED"
            else
                ActionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                ActionButton.Text = "DISABLED"
            end
        end
    end

    if specialType == "Mode" then
        ActionButton.BackgroundColor3 = Color3.fromRGB(55, 45, 90)
        ActionButton.Text = "INSTANT"
        ActionButton.MouseButton1Click:Connect(function()
            if ESP_Settings.AimMode == "Instant" then
                ESP_Settings.AimMode = "Smooth"
                ActionButton.Text = "SMOOTH"
                ActionButton.BackgroundColor3 = Color3.fromRGB(90, 45, 120)
            else
                ESP_Settings.AimMode = "Instant"
                ActionButton.Text = "INSTANT"
                ActionButton.BackgroundColor3 = Color3.fromRGB(55, 45, 90)
            end
        end)
    elseif specialType == "SpinSpeed" then
        ActionButton.BackgroundColor3 = Color3.fromRGB(45, 75, 110)
        ActionButton.Text = "SPEED: ORTA"
        ActionButton.MouseButton1Click:Connect(function()
            if ESP_Settings.SpinSpeed == 10 then
                ESP_Settings.SpinSpeed = 25
                ActionButton.Text = "SPEED: ORTA"
            elseif ESP_Settings.SpinSpeed == 25 then
                ESP_Settings.SpinSpeed = 50
                ActionButton.Text = "SPEED: HIZLI"
            elseif ESP_Settings.SpinSpeed == 50 then
                ESP_Settings.SpinSpeed = 120
                ActionButton.Text = "SPEED: ÇILGIN"
            else
                ESP_Settings.SpinSpeed = 10
                ActionButton.Text = "SPEED: YAVAŞ"
            end
        end)
    elseif specialType == "ScreenFOV" then
        ActionButton.BackgroundColor3 = Color3.fromRGB(100, 65, 30)
        ActionButton.Text = "FOV: " .. tostring(ESP_Settings.ScreenFOV)
        ActionButton.MouseButton1Click:Connect(function()
            if ESP_Settings.ScreenFOV == 70 then ESP_Settings.ScreenFOV = 90
            elseif ESP_Settings.ScreenFOV == 90 then ESP_Settings.ScreenFOV = 110
            elseif ESP_Settings.ScreenFOV == 110 then ESP_Settings.ScreenFOV = 120
            else ESP_Settings.ScreenFOV = 70 end
            ActionButton.Text = "FOV: " .. tostring(ESP_Settings.ScreenFOV)
            if Camera then Camera.FieldOfView = ESP_Settings.ScreenFOV end
        end)
    else
        UpdateVisualState()
        ActionButton.MouseButton1Click:Connect(function()
            ESP_Settings[settingName] = not ESP_Settings[settingName]
            UpdateVisualState()
        end)
    end
end

-- Menü Elemanları Tanımlamaları
CreateMenuToggle("Aimbot Master Switch", "Aimbot", AimbotContent, nil)
CreateMenuToggle("Aimbot Method / Mode", nil, AimbotContent, "Mode")
CreateMenuToggle("Anti-Aim / Spin Bot", "SpinBot", AimbotContent, nil)
CreateMenuToggle("Spin Rotation Velocity", nil, AimbotContent, "SpinSpeed")
CreateMenuToggle("Minecraft Screen FOV", nil, AimbotContent, "ScreenFOV")
CreateMenuToggle("Auto BunnyHop (Arsenal)", "BunnyHop", AimbotContent, nil)
CreateMenuToggle("Infinite Jump Engine", "InfiniteJump", AimbotContent, nil)
CreateMenuToggle("Noclip Physical Bypass", "Noclip", AimbotContent, nil)

CreateMenuToggle("2D Box Frame ESP", "Box", VisualsContent, nil)
CreateMenuToggle("Highlight ESP (Chams)", "Highlight", VisualsContent, nil)
CreateMenuToggle("Gökkuşağı Rainbow Chams", "RainbowChams", VisualsContent, nil)
CreateMenuToggle("3D Skeleton ESP", "Skeleton", VisualsContent, nil)

-- [[ 🎬 VİDEO EDİT TARZI SÜPER SAYJAM KUTUSUZ WATERMARK ]]
local WLabel = Instance.new("TextLabel")
WLabel.Name = "NebuloCleanWatermark"
WLabel.Size = UDim2.new(0, 300, 0, 40)
WLabel.Position = UDim2.new(0.5, -150, 1, -65)
WLabel.BackgroundTransparency = 1 
WLabel.Text = "@NebuloHere"
WLabel.Font = Enum.Font.GothamBold
WLabel.TextSize = 20 
WLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WLabel.TextTransparency = 0.65 
WLabel.TextStrokeTransparency = 0.8 
WLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
WLabel.ZIndex = 1000000
WLabel.Parent = ScreenGui

-- Tuş Algılayıcıları (V Tuşu Aç/Kapat)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.V then
            ToggleMenu(not menuOpen)
        elseif input.KeyCode == ESP_Settings.AimKey then
            Aimbot_Active = true
        elseif input.KeyCode == Enum.KeyCode.Space then
            if ESP_Settings.InfiniteJump then
                local myChar = LocalPlayer.Character
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
                if myHumanoid and myHumanoid.Health > 0 then
                    myHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
    elseif input.KeyCode == ESP_Settings.AimKey then
        Aimbot_Active = false
    end
end)

-- Agresif FOV Sabitleyici Motor
local fovConnection = nil
local function HookCameraFOV(cam)
    if fovConnection then fovConnection:Disconnect() end
    if not cam then return end
    cam.FieldOfView = ESP_Settings.ScreenFOV
    fovConnection = cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        if cam.FieldOfView ~= ESP_Settings.ScreenFOV then
            cam.FieldOfView = ESP_Settings.ScreenFOV
        end
    end)
end
HookCameraFOV(workspace.CurrentCamera)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
    HookCameraFOV(Camera)
end)

-- [BÜYÜK FPS OPTİMİZASYONU: NPC'LER SİLİNDİ & SADECE GERÇEK OYUNCULAR ALINIYOR]
local cachedTargets = {}
local lastScanTime = 0

local function GetValidTargets()
    return cachedTargets
end

-- Akıllı Hedef Bulucu (Aimbot için)
local function GetClosestHeadToMouse()
    local closestHead = nil
    local lowestScore = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local allTargets = GetValidTargets()

    for _, target in pairs(allTargets) do
        local char = target.Character
        local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if head and hum and hum.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local worldDistance = (head.Position - Camera.CFrame.Position).Magnitude
                if worldDistance < ESP_Settings.AimRange then
                    local headScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                    local mouseDistance = (headScreenPos - mousePos).Magnitude
                    local targetScore = mouseDistance + (worldDistance * 0.4)
                    
                    if targetScore < lowestScore then
                        lowestScore = targetScore
                        closestHead = head
                    end
                end
            end
        end
    end
    return closestHead
end

-- ESP Altyapısı
local Cache = {}
local function ClearESP(id)
    if Cache[id] then
        pcall(function() Cache[id].Folder:Destroy() end)
        Cache[id] = nil
    end
end

local function CreateAdornmentLine()
    local a = Instance.new("BoxHandleAdornment")
    a.AlwaysOnTop = true
    a.ZIndex = 10
    a.Transparency = 0
    a.Color3 = Color3.fromRGB(0, 255, 255)
    a.Size = Vector3.new(0.15, 0.15, 1)
    a.Adornee = workspace.Terrain
    return a
end

local function CreateBoxGuiElement(parent)
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.new(1, 0, 1, 0)
    box.Visible = false
    box.Parent = parent
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = box
    return box, stroke
end

local function CreateESPForTarget(id, name, char)
    ClearESP(id)
    local humanoid = char:WaitForChild("Humanoid", 5) or char:FindFirstChildOfClass("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    local folder = Instance.new("Folder", ScreenGui)
    folder.Name = id .. "_ESP_Root"
    
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Adornee = root
    bb.ClipsDescendants = false
    bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    bb.Parent = folder
    
    local boxElement, boxStroke = CreateBoxGuiElement(bb)
    
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(140, 65, 255)
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Enabled = false
    hl.Parent = folder

    local skLines = {}
    for i = 1, 15 do
        local line = CreateAdornmentLine()
        line.Parent = folder
        table.insert(skLines, line)
    end
    
    Cache[id] = {
        Folder = folder, Billboard = bb, BoxFrame = boxElement, BoxStroke = boxStroke, Highlight = hl,
        SkeletonLines = skLines, Character = char, Humanoid = humanoid, RootPart = root, DisplayName = name
    }
end

-- BunnyHop Ayarı
local stateConnection = nil
local function SetupBunnyHopListener(character)
    if stateConnection then stateConnection:Disconnect() end
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not root then return end

    stateConnection = humanoid.StateChanged:Connect(function(oldState, newState)
        if ESP_Settings.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if newState == Enum.HumanoidStateType.Landed then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    local currentVel = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(moveDirection.X * (humanoid.WalkSpeed + 6.5), currentVel.Y, moveDirection.Z * (humanoid.WalkSpeed + 6.5))
                end
            end
        end
    end)
end
if LocalPlayer.Character then SetupBunnyHopListener(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupBunnyHopListener)

-- Ana Döngü
RunService.RenderStepped:Connect(function()
    rainbowHue = (rainbowHue + 0.004) % 1 
    local currentRainbowColor = Color3.fromHSV(rainbowHue, 1, 1)
    
    if menuOpen then UIStroke.Color = currentRainbowColor end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")

    if ESP_Settings.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and myHumanoid and myHumanoid.Health > 0 and myRoot then
        if myHumanoid.FloorMaterial ~= Enum.Material.Air and myHumanoid.FloorMaterial ~= Enum.Material.None then
            myHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        else
            local moveDirection = myHumanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                local currentVel = myRoot.AssemblyLinearVelocity
                myRoot.AssemblyLinearVelocity = Vector3.new(moveDirection.X * (myHumanoid.WalkSpeed + 6.5), currentVel.Y, moveDirection.Z * (myHumanoid.WalkSpeed + 6.5))
            end
        end
    end

    if ESP_Settings.Noclip and myChar then
        for _, part in pairs(myChar:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if ESP_Settings.SpinBot and myRoot and myHumanoid and myHumanoid.Health > 0 then
        local targetHead = GetClosestHeadToMouse()
        if not (Aimbot_Active and ESP_Settings.Aimbot and targetHead) then
            currentSpinAngle = (currentSpinAngle + ESP_Settings.SpinSpeed) % 360
            myRoot.CFrame = CFrame.new(myRoot.Position) * CFrame.Angles(0, math.rad(currentSpinAngle), 0)
        end
    end

    if Aimbot_Active and ESP_Settings.Aimbot and Camera then
        local targetHead = GetClosestHeadToMouse()
        if targetHead then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
            if ESP_Settings.AimMode == "Instant" then Camera.CFrame = targetCFrame
            else Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, ESP_Settings.Smoothness) end
        end
    end

    -- [ZAMANLAYICI: GetDescendants FPS yükünü engellemek için 0.15 saniyede bir hafifçe tarar ve NPC'leri tamamen eler]
    local currentTime = os.clock()
    if currentTime - lastScanTime >= 0.15 then
        lastScanTime = currentTime
        local newTargets = {}
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    table.insert(newTargets, {Type = "Player", Object = p, Character = char})
                end
            end
        end
        cachedTargets = newTargets
    end

    local activeTargets = GetValidTargets()
    local currentIds = {}

    for _, target in pairs(activeTargets) do
        local id = target.Object.Name
        local name = target.Object.Name
        currentIds[id] = true
        
        local char = target.Character
        if char and char.Parent then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not Cache[id] or Cache[id].Character ~= char then
                    CreateESPForTarget(id, name, char)
                end
            else ClearESP(id) end
        else ClearESP(id) end
    end

    for cachedId, _ in pairs(Cache) do
        if not currentIds[cachedId] then
            ClearESP(cachedId)
        end
    end

    -- Render İşleme Adımı
    for id, esp in pairs(Cache) do
        local char = esp.Character
        local humanoid = esp.Humanoid
        local root = esp.RootPart
        
        if char and char.Parent and humanoid and humanoid.Health > 0 and root and Camera then
            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            
            local sizeX = math.clamp(4.5 * (100 / distance), 1.5, 12)
            local sizeY = math.clamp(6.0 * (100 / distance), 2.5, 16)
            
            esp.Billboard.Size = UDim2.new(sizeX, 0, sizeY, 0)
            esp.BoxFrame.Visible = ESP_Settings.Box
            if ESP_Settings.Box and esp.BoxStroke then
                esp.BoxStroke.Color = ESP_Settings.RainbowChams and currentRainbowColor or Color3.fromRGB(255, 0, 0)
            end
            
            if esp.Highlight then
                esp.Highlight.Enabled = ESP_Settings.Highlight
                esp.Highlight.Adornee = char
                esp.Highlight.FillColor = ESP_Settings.RainbowChams and currentRainbowColor or Color3.fromRGB(140, 65, 255)
            end
            
            if ESP_Settings.Skeleton then
                local activeLines = 0
                local connections = humanoid.RigType == Enum.HumanoidRigType.R15 and {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
                    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
                    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                } or {
                    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
                }
                
                for _, pair in ipairs(connections) do
                    local p1 = char:FindFirstChild(pair[1])
                    local p2 = char:FindFirstChild(pair[2])
                    if p1 and p2 then
                        activeLines = activeLines + 1
                        local adorn = esp.SkeletonLines[activeLines]
                        if adorn then
                            adorn.Size = Vector3.new(0.15, 0.15, (p1.Position - p2.Position).Magnitude)
                            adorn.CFrame = CFrame.lookAt((p1.Position + p2.Position) / 2, p2.Position)
                            adorn.Color3 = ESP_Settings.RainbowChams and currentRainbowColor or Color3.fromRGB(0, 255, 255)
                            adorn.Visible = true
                        end
                    end
                end
                for i = activeLines + 1, #esp.SkeletonLines do esp.SkeletonLines[i].Visible = false end
            else
                for _, adorn in ipairs(esp.SkeletonLines) do adorn.Visible = false end
            end
        else ClearESP(id) end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player.Name)
end)
