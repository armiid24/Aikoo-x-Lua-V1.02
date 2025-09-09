--[[
    Nama Skrip: Personal Power-Tool UI v3 (Fitur Tambahan)
    Deskripsi: UI multifungsi dengan fitur player, server, dan scanning.
    Versi 3+: Ditambahkan Fly Mode & Server-Side Dupe.
    PERINGATAN: Skrip ini mengandung fungsi exploit. Gunakan dengan risiko Anda sendiri.
]]

--// PEMBERSIHAN UI LAMA //--
if game:GetService("CoreGui"):FindFirstChild("PowerTool_UI_v3") then
    game:GetService("CoreGui"):FindFirstChild("PowerTool_UI_v3"):Destroy()
end
if game:GetService("Lighting"):FindFirstChild("PowerTool_Blur") then
    game:GetService("Lighting"):FindFirstChild("PowerTool_Blur"):Destroy()
end
pcall(function() game:GetService("CoreGui"):FindFirstChild("FlyControlsGui"):Destroy() end) -- Pembersihan untuk UI Fly

--// VARIABEL & LAYANAN PENTING //--
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Variabel status untuk fitur on/off
local noclipActive, infiniteJumpActive, godModeActive, flyActive = false, false, false, false
local noclipConnection, flyConnection
local isMinimized = false
local flySpeed = 50 -- Atur kecepatan terbang di sini

--// OBJEK UTAMA UI //--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PowerTool_UI_v3"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Tambahkan di sini, setelah ScreenGui dibuat:
MinimizeIcon = Instance.new("ImageButton", ScreenGui)
MinimizeIcon.Name = "MinimizeIcon"
MinimizeIcon.Size = UDim2.new(0, 40, 0, 40)
MinimizeIcon.Position = UDim2.new(0, 20, 0, 20)
MinimizeIcon.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
MinimizeIcon.BackgroundTransparency = 0.2
MinimizeIcon.Image = "rbxassetid://6031094678"
MinimizeIcon.Visible = false
Instance.new("UICorner", MinimizeIcon).CornerRadius = UDim.new(1, 0)
MinimizeIcon.ZIndex = 100

-- ...lanjutkan kode pembuatan MainFrame, dst...

local BlurEffect = Instance.new("BlurEffect", Lighting)
BlurEffect.Name = "PowerTool_Blur"
BlurEffect.Size = 14

--// PENGATURAN TEMA //--
local Themes = {
    ["Glassy Dark"] = { Background = Color3.fromRGB(20, 20, 25), BackgroundTransparency = 0.3, Accent = Color3.fromRGB(80, 80, 255), AccentSecondary = Color3.fromRGB(40, 40, 60), Text = Color3.fromRGB(255, 255, 255), Border = Color3.fromRGB(150, 150, 170) },
    ["Light"] = { Background = Color3.fromRGB(240, 240, 240), BackgroundTransparency = 0.4, Accent = Color3.fromRGB(0, 120, 255), AccentSecondary = Color3.fromRGB(200, 200, 210), Text = Color3.fromRGB(10, 10, 10), Border = Color3.fromRGB(200, 200, 200) },
    ["Ocean Blue"] = { Background = Color3.fromRGB(10, 25, 40), BackgroundTransparency = 0.25, Accent = Color3.fromRGB(0, 191, 255), AccentSecondary = Color3.fromRGB(15, 40, 60), Text = Color3.fromRGB(230, 240, 255), Border = Color3.fromRGB(60, 120, 180) },
    ["Crimson Red"] = { Background = Color3.fromRGB(30, 10, 10), BackgroundTransparency = 0.3, Accent = Color3.fromRGB(220, 20, 60), AccentSecondary = Color3.fromRGB(60, 20, 25), Text = Color3.fromRGB(255, 220, 220), Border = Color3.fromRGB(150, 80, 80) }
}
local currentThemeName = "Glassy Dark"

--// STRUKTUR DASAR UI //--
local originalSize = UDim2.new(0, 550, 0, 420) -- <--- Ukuran diperbesar untuk tombol baru
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = originalSize
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.5

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundTransparency = 0.5
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -80, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Font = Enum.Font.GothamSemibold; TitleLabel.Text = "Personal Tool v3+"; TitleLabel.TextSize = 18; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", Header)
CloseButton.Size = UDim2.new(0, 35, 1, 0); CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Font = Enum.Font.GothamBold; CloseButton.Text = "X"; CloseButton.TextSize = 20; CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

local MinimizeButton = Instance.new("TextButton", Header)
MinimizeButton.Size = UDim2.new(0, 35, 1, 0); MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
MinimizeButton.Font = Enum.Font.GothamBold; MinimizeButton.Text = "_"; MinimizeButton.TextSize = 20
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 8)

-- Wadah Navigasi & Halaman
local NavContainer = Instance.new("Frame", MainFrame)
NavContainer.Size = UDim2.new(0, 100, 1, -45); NavContainer.Position = UDim2.new(0, 10, 0, 45); NavContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", NavContainer).Padding = UDim.new(0, 10)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -130, 1, -55); PageContainer.Position = UDim2.new(1, -10, 0, 45); PageContainer.AnchorPoint = Vector2.new(1, 0)
PageContainer.BackgroundTransparency = 0.7; Instance.new("UICorner", PageContainer).CornerRadius = UDim.new(0, 6)
local PageStroke = Instance.new("UIStroke", PageContainer)

--// PEMBUATAN HALAMAN-HALAMAN //--
local function createPage(name) local page = Instance.new("Frame", PageContainer); page.Name = name; page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false; return page end
local PlayerPage, ServerPage, ScannerPage, ScannerObjectPage, SettingsPage, LogConsolePage =
    createPage("Player"), createPage("Server"),
    createPage("Scanner"), createPage("ScannerObject"),
    createPage("Settings"), createPage("LogConsole")

ServerPage.ClipsDescendants = true

--// KONTEN HALAMAN-HALAMAN //--
-- ================== HALAMAN PLAYER (DIPERBAIKI DENGAN SCROLL) ==================
do
    -- [[ PERUBAHAN 1: Tambahkan ScrollingFrame sebagai wadah utama ]]
    local ScrollContainer = Instance.new("ScrollingFrame", PlayerPage)
    ScrollContainer.Name = "ScrollContainer"
    ScrollContainer.Size = UDim2.new(1, 0, 1, 0) -- Memenuhi seluruh halaman
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.ScrollBarThickness = 6
    ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Kanvas otomatis membesar

    -- [[ PERUBAHAN 2: Pindahkan layout dan padding ke dalam ScrollingFrame ]]
    local pageLayout = Instance.new("UIListLayout", ScrollContainer)
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    
    local pagePadding = Instance.new("UIPadding", ScrollContainer)
    pagePadding.PaddingTop = UDim.new(0, 10)
    pagePadding.PaddingLeft = UDim.new(0, 10)
    pagePadding.PaddingRight = UDim.new(0, 10)

    -- Fungsi createToggleButton tetap sama
    local function createToggleButton(parent, text, callback)
        local button = Instance.new("TextButton", parent)
        button.Size, button.Font, button.Text = UDim2.new(1, 0, 0, 35), Enum.Font.Gotham, text
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
        button.MouseButton1Click:Connect(function() callback(button) end)
        return button
    end

    -- [[ PERUBAHAN 3: Ubah parent dari semua elemen menjadi ScrollContainer, bukan PlayerPage ]]
    local SpeedFrame = Instance.new("Frame", ScrollContainer) -- Diubah ke ScrollContainer
    SpeedFrame.BackgroundTransparency = 1
    SpeedFrame.Size = UDim2.new(1, 0, 0, 35)
    
    local SpeedLayout = Instance.new("UIListLayout", SpeedFrame)
    SpeedLayout.FillDirection = Enum.FillDirection.Horizontal
    SpeedLayout.Padding = UDim.new(0, 10)
    
    local SpeedInput = Instance.new("TextBox", SpeedFrame)
    SpeedInput.Size, SpeedInput.Font, SpeedInput.PlaceholderText, SpeedInput.ClearTextOnFocus = UDim2.new(0.6, 0, 1, 0), Enum.Font.Gotham, "Input speed...", false
    Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 6)
    
    local SpeedButton = Instance.new("TextButton", SpeedFrame)
    SpeedButton.Size, SpeedButton.Font, SpeedButton.Text = UDim2.new(0.4, -10, 1, 0), Enum.Font.Gotham, "Set Speed"
    Instance.new("UICorner", SpeedButton).CornerRadius = UDim.new(0, 6)
    SpeedButton.MouseButton1Click:Connect(function() local speed = tonumber(SpeedInput.Text); if speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = speed end end)
    
    -- Semua tombol sekarang dimasukkan ke dalam ScrollContainer
    createToggleButton(ScrollContainer, "Noclip [OFF]", function(b) noclipActive = not noclipActive; b.Text = "Noclip ["..(noclipActive and "ON" or "OFF").."]"; if noclipActive then noclipConnection = RunService.Stepped:Connect(function() if LocalPlayer.Character then for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) elseif noclipConnection then noclipConnection:Disconnect() end end)
    createToggleButton(ScrollContainer, "Infinite Jump [OFF]", function(b) infiniteJumpActive = not infiniteJumpActive; b.Text = "Infinite Jump ["..(infiniteJumpActive and "ON" or "OFF").."]"; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then UserInputService.JumpRequest:Connect(function() if infiniteJumpActive then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) end end)
    createToggleButton(ScrollContainer, "God Mode [OFF]", function(b) godModeActive = not godModeActive; b.Text = "God Mode ["..(godModeActive and "ON" or "OFF").."]"; local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid"); if h then h.MaxHealth = godModeActive and math.huge or 100; h.Health = h.MaxHealth end end)
    
    -- ⬇️ Tambahkan di sini script baru

    -- ⬇️ Tambahkan di sini script baru

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local espActive = false
local espLabels = {}
local espConnection = nil

createToggleButton(ScrollContainer, "ESP Username [OFF]", function(btn)
    espActive = not espActive
    btn.Text = "ESP Username [" .. (espActive and "ON" or "OFF") .. "]"

    if espActive then
        espConnection = RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    if not espLabels[player] then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ESP_" .. player.Name
                        billboard.Adornee = head
                        billboard.Size = UDim2.new(0, 120, 0, 20)
                        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                        billboard.AlwaysOnTop = true
                        billboard.LightInfluence = 0
                        billboard.Parent = head

                        local text = Instance.new("TextLabel", billboard)
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.Text = player.Name
                        text.TextColor3 = Color3.fromRGB(255, 255, 0)
                        text.Font = Enum.Font.GothamBold
                        text.TextScaled = true
                        text.TextStrokeTransparency = 0.5

                        espLabels[player] = billboard
                    elseif espLabels[player].Adornee ~= head then
                        espLabels[player].Adornee = head
                    end
                elseif espLabels[player] then
                    espLabels[player]:Destroy()
                    espLabels[player] = nil
                end
            end
        end)
    else
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        for _, label in pairs(espLabels) do
            if label and label.Parent then
                label:Destroy()
            end
        end
        espLabels = {}
    end
end)


    --move objek

-- Simpan posisi awal semua SpawnLocation
local originalSpawnPositions = {}

-- Tombol utama: Move SpawnLocation
local MoveSpawnerBtn = Instance.new("TextButton", ScrollContainer)
MoveSpawnerBtn.Size = UDim2.new(0.8, 0, 0, 35)
MoveSpawnerBtn.Text = "📍 Move All SpawnLocation to Player"
MoveSpawnerBtn.Font = Enum.Font.Gotham
MoveSpawnerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MoveSpawnerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", MoveSpawnerBtn).CornerRadius = UDim.new(0, 6)

-- Tombol reset: Balikin ke posisi awal
local ResetBtn = Instance.new("TextButton", ScrollContainer)
ResetBtn.Size = UDim2.new(0.8, 0, 0, 35)
ResetBtn.Text = "🔁 Reset SpawnLocation"
ResetBtn.Font = Enum.Font.Gotham
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

-- Fungsi pindah semua SpawnLocation ke player
local function moveAllSpawnToPlayer()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") or (obj:IsA("BasePart") and (obj.Name == "SpawnLocation" or obj.Name == "GeneratorPoint1" or obj.Name == "GeneratorPoint2" or obj.Name == "GeneratorPoint3" or obj.Name == "GeneratorPoint4")) then
            if not originalSpawnPositions[obj] then
                originalSpawnPositions[obj] = obj.CFrame
            end
            obj.CFrame = root.CFrame + Vector3.new(0, 5 + count * 2, 0)
            count = count + 1
        end
    end

    MoveSpawnerBtn.Text = "Moved " .. count .. " Spawn ✅"
    task.delay(2, function()
        MoveSpawnerBtn.Text = "📍 Move All SpawnLocation to Player"
    end)
end

-- Fungsi reset posisi semua SpawnLocation
local function resetAllSpawn()
    local count = 0
    for obj, cframe in pairs(originalSpawnPositions) do
        if obj and obj:IsA("BasePart") then
            obj.CFrame = cframe
            count = count + 1
        end
    end

    ResetBtn.Text = "Reset " .. count .. " Spawn ✅"
    task.delay(2, function()
        ResetBtn.Text = "🔁 Reset SpawnLocation"
    end)
end

-- Klik kiri → pindah
MoveSpawnerBtn.MouseButton1Click:Connect(moveAllSpawnToPlayer)

-- Klik kanan → trigger langsung
MoveSpawnerBtn.MouseButton2Click:Connect(moveAllSpawnToPlayer)

-- Tombol reset
ResetBtn.MouseButton1Click:Connect(resetAllSpawn)



    -- 🌊 Water Walker [ON/OFF]
local waterWalkActive = false
local waterPlatform = nil

createToggleButton(ScrollContainer, "Water Walker [OFF]", function(btn)
    waterWalkActive = not waterWalkActive
    btn.Text = "Water Walker [" .. (waterWalkActive and "ON" or "OFF") .. "]"

    if not waterWalkActive and waterPlatform then
        waterPlatform:Destroy()
        waterPlatform = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not waterWalkActive then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local pos = char.HumanoidRootPart.Position
    local rayOrigin = pos
    local rayDir = Vector3.new(0, -10, 0)

    local ray = Ray.new(rayOrigin, rayDir)
    local hit, hitPos = workspace:FindPartOnRay(ray, char)

    if hit and hit.Name:lower():find("water") then
        if not waterPlatform then
            waterPlatform = Instance.new("Part")
            waterPlatform.Size = Vector3.new(6, 0.5, 6)
            waterPlatform.Anchored = true
            waterPlatform.CanCollide = true
            waterPlatform.Transparency = 0.8
            waterPlatform.Material = Enum.Material.SmoothPlastic
            waterPlatform.Color = Color3.fromRGB(0, 150, 255)
            waterPlatform.Name = "WaterWalkPlatform"
            waterPlatform.Parent = workspace
        end
        waterPlatform.Position = Vector3.new(pos.X, hitPos.Y + 0.5, pos.Z)
    elseif waterPlatform then
        waterPlatform:Destroy()
        waterPlatform = nil
    end
end)


    -- 🛡️ Shield Anti-Air Death [ON/OFF]
local shieldActive = false
local shieldPart = nil
local blockDeathEvents = false

createToggleButton(ScrollContainer, "Shield Anti-Air [OFF]", function(btn)
    shieldActive = not shieldActive
    btn.Text = "Shield Anti-Air [" .. (shieldActive and "ON" or "OFF") .. "]"
    blockDeathEvents = shieldActive

    if shieldActive then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        shieldPart = Instance.new("Part")
        shieldPart.Size = Vector3.new(10, 10, 10)
        shieldPart.Transparency = 0.6
        shieldPart.Anchored = true
        shieldPart.CanCollide = false
        shieldPart.CanTouch = false
        shieldPart.Material = Enum.Material.ForceField
        shieldPart.Name = "ShieldBubble"
        shieldPart.Parent = workspace

        RunService.RenderStepped:Connect(function()
            if shieldActive and shieldPart and char:FindFirstChild("HumanoidRootPart") then
                shieldPart.Position = char.HumanoidRootPart.Position
            end
        end)
    else
        if shieldPart then
            shieldPart:Destroy()
            shieldPart = nil
        end
    end
end)

-- 🚫 Noclip Radius 30 Stud dari pusat player
local RunService = game:GetService("RunService")
local radius = 30
local noclipActive = false

createToggleButton(ScrollContainer, "Noclip Radius [OFF]", function(button)
    noclipActive = not noclipActive
    button.Text = "Noclip Radius [" .. (noclipActive and "ON" or "OFF") .. "]"
end)

RunService.RenderStepped:Connect(function()
    if not noclipActive then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local center = char.HumanoidRootPart.Position

    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            local dist = (part.Position - center).Magnitude
            if dist <= radius then
                part.CanCollide = false
            end
        end
    end
end)


    
    -- 🔁 Rejoin ke server dengan avatar R15

createToggleButton(ScrollContainer, "Rejoin (R15)", function()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local placeId = game.PlaceId
    local teleportData = {
        rig = "R15"
    }

    TeleportService:Teleport(placeId, LocalPlayer, teleportData)
end)


   -- ESP Dinamis: BasePart + Nama Objek (Fix Toggle OFF)
local espActive = false
local espElements = {}
local espConnection = nil
local RunService = game:GetService("RunService")

createToggleButton(ScrollContainer, "ESP Objek + Nama [OFF]", function(button)
    espActive = not espActive
    button.Text = "ESP Objek + Nama [" .. (espActive and "ON" or "OFF") .. "]"

    -- Fungsi untuk bersihkan semua ESP
    local function clearESP()
        for _, pair in ipairs(espElements) do
            if pair.highlight and pair.highlight.Parent then pair.highlight:Destroy() end
            if pair.label and pair.label.Parent then pair.label:Destroy() end
        end
        espElements = {}
    end

    if espActive then
        espConnection = RunService.RenderStepped:Connect(function()
            clearESP()

            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Position - hrp.Position).Magnitude <= 30 then
                    -- Highlight
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = obj
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = obj

                    -- BillboardGui untuk nama
                    local billboard = Instance.new("BillboardGui")
                    billboard.Adornee = obj
                    billboard.Size = UDim2.new(0, 100, 0, 20)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = obj

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = obj.Name
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextStrokeTransparency = 0
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = billboard

                    table.insert(espElements, {highlight = highlight, label = billboard})
                end
            end
        end)
    else
        -- Matikan koneksi dan bersihkan semua ESP
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        clearESP()
    end
end)




    -- Status fall damage
local fallDamageActive = true

-- RemoteEvent dari ReplicatedStorage.Events
local fallDamageRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("ServerFallDamage")

-- Tombol Fall Damage Toggle
createToggleButton(ScrollContainer, "Fall Damage [ON]", function(button)
    fallDamageActive = not fallDamageActive
    button.Text = "Fall Damage [" .. (fallDamageActive and "ON" or "OFF") .. "]"

    if fallDamageRemote then
        fallDamageRemote:FireServer(fallDamageActive)
        print("📡 ServerFallDamage dikirim:", fallDamageActive)
    else
        warn("❌ RemoteEvent 'ServerFallDamage' tidak ditemukan.")
    end
end)

    -- Tombol Fly Mode
    createToggleButton(ScrollContainer, "Fly [OFF]", function(button)
        flyActive = not flyActive
        button.Text = "Fly [" .. (flyActive and "ON" or "OFF") .. "]"
        toggleFly(flyActive) -- Memanggil fungsi fly
    end)
    
    -- Tombol Duplikasi
    createToggleButton(ScrollContainer, "Dupe Held (Client)", function(button)
        local char = LocalPlayer.Character; local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then local clone = tool:Clone(); clone.Parent = LocalPlayer.Backpack; button.Text = "Duplicated: " .. tool.Name else button.Text = "No item held!" end
        task.wait(2); button.Text = "Dupe Held (Client)"
    end)
    createToggleButton(ScrollContainer, "Dupe Held (Server)", function(button)
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then button.Text = "No item held!"; task.wait(2); button.Text = "Dupe Held (Server)"; return end

    local remote = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents", 5) and game:GetService("ReplicatedStorage").GameEvents:WaitForChild("DuplicateItem_RE", 5)

    if remote then
        button.Text = "Firing remote..."; remote:FireServer(tool.Name)
        button.Text = "Fired for: " .. tool.Name
    else
        button.Text = "Remote not found!"
    end
    task.wait(2); button.Text = "Dupe Held (Server)"
end)


    -- Tombol Langit Siang
    local clearDayActive = false -- Variabel lokal untuk tombol ini
    createToggleButton(ScrollContainer, "Langit Siang [OFF]", function(button)
        clearDayActive = not clearDayActive
        button.Text = "Langit Siang [" .. (clearDayActive and "ON" or "OFF") .. "]"

        local lighting = game:GetService("Lighting")
        if clearDayActive then
            lighting.ClockTime = 12 
            lighting.Brightness = 3
            lighting.Ambient = Color3.fromRGB(200, 200, 200)
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            lighting.FogEnd = 100000
            lighting.FogColor = Color3.fromRGB(255, 255, 255)
            lighting.TimeOfDay = "12:00:00"
        else
            lighting.ClockTime = 18 
            lighting.Brightness = 1
            lighting.Ambient = Color3.fromRGB(80, 80, 80)
            lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
            lighting.FogEnd = 500
            lighting.FogColor = Color3.fromRGB(120, 120, 120)
            lighting.TimeOfDay = "18:00:00"
        end
    end)
end
-- HALAMAN LAIN (Sama seperti V3)
do -- Server Page
    local PlayerListFrame = Instance.new("ScrollingFrame", ServerPage)
    PlayerListFrame.Size = UDim2.new(1, -20, 1, -60)
    PlayerListFrame.Position = UDim2.new(0.5, 0, 0.5, 10)
    PlayerListFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    PlayerListFrame.BackgroundTransparency = 0.5
    PlayerListFrame.BorderSizePixel = 0
    PlayerListFrame.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", PlayerListFrame)
    layout.Padding = UDim.new(0, 5)

    -- 🔍 Search Box
    local SearchBox = Instance.new("TextBox", ServerPage)
    SearchBox.Size = UDim2.new(1, -20, 0, 40)
    SearchBox.Position = UDim2.new(0.5, 0, 0, 10)
    SearchBox.AnchorPoint = Vector2.new(0.5, 0)
    SearchBox.PlaceholderText = "Cari username..."
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 16
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

    local function addPlayerButton(player)
        if PlayerListFrame:FindFirstChild(player.Name) then return end
        local button = Instance.new("TextButton", PlayerListFrame)
        button.Name = player.Name
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

        button.MouseButton1Click:Connect(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and targetRoot then
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
            end
        end)
    end

    -- 🔁 Update visibility saat search berubah
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local keyword = SearchBox.Text:lower()
        for _, button in ipairs(PlayerListFrame:GetChildren()) do
            if button:IsA("TextButton") then
                button.Visible = keyword == "" or button.Name:lower():find(keyword)
            end
        end
    end)

    Players.PlayerAdded:Connect(addPlayerButton)
    Players.PlayerRemoving:Connect(function(p)
        local b = PlayerListFrame:FindFirstChild(p.Name)
        if b then b:Destroy() end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            addPlayerButton(player)
        end
    end
end

-- 🔍 Remote Scanner Page
do
    local pageLayout = Instance.new("UIListLayout", ScannerPage)
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Tombol Scan
    local ScanButton = Instance.new("TextButton", ScannerPage)
    ScanButton.Size = UDim2.new(0.8, 0, 0, 40)
    ScanButton.Position = UDim2.new(0.5, 0, 0, 10)
    ScanButton.AnchorPoint = Vector2.new(0.5, 0)
    ScanButton.Font = Enum.Font.Gotham
    ScanButton.Text = "Scan Remotes"
    Instance.new("UICorner", ScanButton).CornerRadius = UDim.new(0, 6)

    -- Search Box
    local SearchBox = Instance.new("TextBox", ScannerPage)
    SearchBox.Size = UDim2.new(0.8, 0, 0, 30)
    SearchBox.Position = UDim2.new(0.5, 0, 0, 55)
    SearchBox.AnchorPoint = Vector2.new(0.5, 0)
    SearchBox.PlaceholderText = "Search Remote..."
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

    -- Copy All Button
    local CopyAllButton = Instance.new("TextButton", ScannerPage)
    CopyAllButton.Size = UDim2.new(0.8, 0, 0, 30)
    CopyAllButton.Position = UDim2.new(0.5, 0, 0, 90)
    CopyAllButton.AnchorPoint = Vector2.new(0.5, 0)
    CopyAllButton.Font = Enum.Font.Gotham
    CopyAllButton.Text = "Copy All Results"
    Instance.new("UICorner", CopyAllButton).CornerRadius = UDim.new(0, 6)

    -- Results Frame
    local ResultsFrame = Instance.new("ScrollingFrame", ScannerPage)
    ResultsFrame.Size = UDim2.new(1, -20, 1, -130)
    ResultsFrame.Position = UDim2.new(0.5, 0, 0, 130)
    ResultsFrame.AnchorPoint = Vector2.new(0.5, 0)
    ResultsFrame.BackgroundTransparency = 0.5
    ResultsFrame.BorderSizePixel = 0
    ResultsFrame.CanvasSize = UDim2.new(0,0,0,0)

    local resultsLayout = Instance.new("UIListLayout", ResultsFrame)
    resultsLayout.Padding = UDim.new(0, 2)

    -- Variabel hasil scan
    local allResults = {}

    -- Fungsi scan semua RemoteEvent & RemoteFunction
    local function ScanRemotes()
        for _, v in ipairs(ResultsFrame:GetChildren()) do
            if not v:IsA("UIListLayout") then v:Destroy() end
        end
        allResults = {}

        ScanButton.Text = "Scanning..."
        task.wait()

        local count = 0
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                count = count + 1
                table.insert(allResults, v:GetFullName())

                local resultButton = Instance.new("TextButton", ResultsFrame)
                resultButton.Size = UDim2.new(1, 0, 0, 20)
                resultButton.Text = v:GetFullName()
                resultButton.Font = Enum.Font.Code
                resultButton.TextSize = 12
                resultButton.TextXAlignment = Enum.TextXAlignment.Left
                resultButton.BackgroundTransparency = 1

                resultButton.MouseButton1Click:Connect(function()
                    if setclipboard then
                        setclipboard(resultButton.Text)
                        local oldText = resultButton.Text
                        resultButton.Text = "Path Copied!"
                        task.wait(1.5)
                        resultButton.Text = oldText
                    else
                        warn("Fungsi 'setclipboard' tidak tersedia di executor ini.")
                    end
                end)
            end
        end

        ResultsFrame.CanvasSize = UDim2.new(0,0,0,resultsLayout.AbsoluteContentSize.Y)
        ScanButton.Text = "Scan Complete ("..count.." found)"
        task.wait(2)
        ScanButton.Text = "Scan Remotes"
    end

    -- Event tombol scan
    ScanButton.MouseButton1Click:Connect(ScanRemotes)

    -- Event tombol copy all
    CopyAllButton.MouseButton1Click:Connect(function()
        if setclipboard and #allResults > 0 then
            setclipboard(table.concat(allResults, "\n"))
            CopyAllButton.Text = "All Copied!"
            task.wait(1.5)
            CopyAllButton.Text = "Copy All Results"
        end
    end)

    -- Event search filter
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local keyword = string.lower(SearchBox.Text)
        for _, child in ipairs(ResultsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                if keyword == "" or string.find(string.lower(child.Text), keyword) then
                    child.Visible = true
                else
                    child.Visible = false
                end
            end
        end
        ResultsFrame.CanvasSize = UDim2.new(0,0,0,resultsLayout.AbsoluteContentSize.Y)
    end)
end; do -- Settings Page
    local pageLayout = Instance.new("UIGridLayout", SettingsPage); pageLayout.CellPadding, pageLayout.CellSize, pageLayout.HorizontalAlignment = UDim2.new(0, 10, 0, 10), UDim2.new(0, 150, 0, 35), Enum.HorizontalAlignment.Center; Instance.new("UIPadding", SettingsPage).PaddingTop = UDim.new(0, 10); for themeName, _ in pairs(Themes) do local ThemeButton = Instance.new("TextButton", SettingsPage); ThemeButton.Font, ThemeButton.Text = Enum.Font.Gotham, themeName; Instance.new("UICorner", ThemeButton).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", ThemeButton).Thickness = 1; ThemeButton.MouseButton1Click:Connect(function() applyTheme(themeName) end) end
end; do -- ScannerObject Page
    local layout = Instance.new("UIListLayout", ScannerObjectPage)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Instance.new("UIPadding", ScannerObjectPage).PaddingTop = UDim.new(0, 10)

    -- Tombol Scan Object
    local ScanBtn = Instance.new("TextButton", ScannerObjectPage)
    ScanBtn.Size = UDim2.new(0.8, 0, 0, 35)
    ScanBtn.Text = "🔍 Scan Object"
    ScanBtn.Font = Enum.Font.Gotham
    Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)

    local TeleportedObjects = {}

-- Tombol Delete Unused
local DeleteBtn = Instance.new("TextButton", ScannerObjectPage)
DeleteBtn.Size = UDim2.new(0.8, 0, 0, 35)
DeleteBtn.Text = "🗑️ Delete Unused"
DeleteBtn.Font = Enum.Font.Gotham
DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DeleteBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", DeleteBtn).CornerRadius = UDim.new(0, 6)

    

    -- TextBox Search
    local SearchBox = Instance.new("TextBox", ScannerObjectPage)
    SearchBox.Size = UDim2.new(0.9, 0, 0, 30)
    SearchBox.PlaceholderText = "🔎 Cari object..."
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = false
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

    -- Scroll Container
    local Scroll = Instance.new("ScrollingFrame", ScannerObjectPage)
    Scroll.Size = UDim2.new(0.9, 0, 1, -140) -- dikurangin karena ada search bar
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.ScrollBarThickness = 6
    Scroll.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 6)
    local ListLayout = Instance.new("UIListLayout", Scroll)
    ListLayout.Padding = UDim.new(0, 5)

    -- Simpan semua button object biar gampang difilter
    local ObjectButtons = {}

    -- Fungsi buat nambah object ke list + teleport
    local function addObjectToList(obj)
        local btn = Instance.new("TextButton", Scroll)
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Text = obj.Name
        btn.Font = Enum.Font.Gotham
        btn.Name = obj.Name
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        table.insert(ObjectButtons, btn)

        btn.MouseButton1Down:Connect(function()
    local holdTime = 0.5
    local held = true

    task.delay(holdTime, function()
        if held then
            -- Tahan cukup lama → buka rename box
            local renameBox = Instance.new("TextBox", btn)
            renameBox.Size = UDim2.new(1, 0, 1, 0)
            renameBox.Text = btn.Text
            renameBox.Font = Enum.Font.Gotham
            renameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            renameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            renameBox.ClearTextOnFocus = false
            renameBox.TextScaled = true
            renameBox.ZIndex = 2
            Instance.new("UICorner", renameBox).CornerRadius = UDim.new(0, 6)

            renameBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and renameBox.Text ~= "" then
                    btn.Text = renameBox.Text
                end
                renameBox:Destroy()
            end)

            renameBox:CaptureFocus()
        end
    end)

    btn.MouseButton1Up:Connect(function()
        held = false
        -- Kalau gak tahan lama → teleport
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        TeleportedObjects[btn] = true
        if root and obj:IsA("BasePart") then
            root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end)

    end; 

    -- Event tombol scan
    ScanBtn.MouseButton1Click:Connect(function()
        ObjectButtons = {}
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                addObjectToList(v)
            end
        end
    end)

    DeleteBtn.MouseButton1Click:Connect(function()
    local deleted = 0
    for _, btn in ipairs(ObjectButtons) do
        if not TeleportedObjects[btn] then
            btn:Destroy()
            deleted = deleted + 1
        end
    end
    DeleteBtn.Text = "Deleted " .. deleted .. " Unused ✅"
    task.delay(2, function()
        DeleteBtn.Text = "🗑️ Delete Unused"
    end)
end)


    -- Event filter search
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local keyword = SearchBox.Text:lower()
        for _, btn in ipairs(ObjectButtons) do
            if btn.Name:lower():find(keyword) then
                btn.Visible = true
            else
                btn.Visible = false
            end
        end
    end)
end

-- 🔧 Search & Move Objek di LogConsolePage

local originalPositions = {}

-- Frame container
local Container = Instance.new("Frame", LogConsolePage)
Container.Size = UDim2.new(1, 0, 0, 80)
Container.BackgroundTransparency = 1
Container.LayoutOrder = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.FillDirection = Enum.FillDirection.Vertical
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Search box
local SearchBox = Instance.new("TextBox", Container)
SearchBox.Size = UDim2.new(1, 0, 0, 35)
SearchBox.PlaceholderText = "🔎 Nama objek..."
SearchBox.Font = Enum.Font.Gotham
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

-- Tombol Move
local MoveBtn = Instance.new("TextButton", Container)
MoveBtn.Size = UDim2.new(1, 0, 0, 35)
MoveBtn.Text = "📍 Move Objek"
MoveBtn.Font = Enum.Font.Gotham
MoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MoveBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", MoveBtn).CornerRadius = UDim.new(0, 6)

-- Tombol Reset
local ResetBtn = Instance.new("TextButton", Container)
ResetBtn.Size = UDim2.new(1, 0, 0, 35)
ResetBtn.Text = "🔁 Reset Objek"
ResetBtn.Font = Enum.Font.Gotham
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

-- Tombol Interact
local InteractBtn = Instance.new("TextButton", Container)
InteractBtn.Size = UDim2.new(1, 0, 0, 35)
InteractBtn.Text = "🛠️ Interact Objek"
InteractBtn.Font = Enum.Font.Gotham
InteractBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InteractBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Instance.new("UICorner", InteractBtn).CornerRadius = UDim.new(0, 6)



-- Fungsi Move
MoveBtn.MouseButton1Click:Connect(function()
    local keyword = SearchBox.Text:lower()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or keyword == "" then return end

    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(keyword) then
            if not originalPositions[obj] then
                originalPositions[obj] = obj.CFrame
            end
            obj.CFrame = root.CFrame + Vector3.new(0, 5 + count * 2, 0)
            count = count + 1
        end
    end

    MoveBtn.Text = "Moved " .. count .. " Objek ✅"
    task.delay(2, function()
        MoveBtn.Text = "📍 Move Objek"
    end)
end)

-- Fungsi Reset
ResetBtn.MouseButton1Click:Connect(function()
    local count = 0
    for obj, cframe in pairs(originalPositions) do
        if obj and obj:IsA("BasePart") then
            obj.CFrame = cframe
            count = count + 1
        end
    end

    ResetBtn.Text = "Reset " .. count .. " Objek ✅"
    task.delay(2, function()
        ResetBtn.Text = "🔁 Reset Objek"
    end)
end)

-- Fungsi Interact
InteractBtn.MouseButton1Click:Connect(function()
    local keyword = SearchBox.Text:lower()
    if keyword == "" then return end

    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(keyword) then
            -- Interact via ClickDetector
            local click = obj:FindFirstChildOfClass("ClickDetector")
            if click then
                pcall(function()
                    click:Click()
                    count = count + 1
                end)
            end

            -- Interact via ProximityPrompt
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                pcall(function()
                    prompt:InputHoldBegin()
                    task.wait(0.2)
                    prompt:InputHoldEnd()
                    count = count + 1
                end)
            end

            -- Interact via RemoteEvent (optional)
            local remote = obj:FindFirstChildOfClass("RemoteEvent")
            if remote then
                pcall(function()
                    remote:FireServer()
                    count = count + 1
                end)
            end
        end
    end

    InteractBtn.Text = "Interacted " .. count .. " Objek ✅"
    task.delay(2, function()
        InteractBtn.Text = "🛠️ Interact Objek"
    end)
end)



--// FUNGSI GLOBAL UI (NAVIGASI, TEMA, DLL) //--
function switchPage(pageName) for _, page in pairs(PageContainer:GetChildren()) do if page:IsA("Frame") then page.Visible = (page.Name == pageName) end end; local theme = Themes[currentThemeName]; for _, button in pairs(NavContainer:GetChildren()) do if button:IsA("TextButton") then button.BackgroundColor3 = (button.Name == pageName.."Nav") and theme.Accent or theme.AccentSecondary end end end
function applyTheme(themeName) currentThemeName = themeName; local theme = Themes[themeName]; MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, UIStroke.Color = theme.Background, theme.BackgroundTransparency, theme.Border; TitleLabel.TextColor3 = theme.Text; PageContainer.BackgroundColor3, PageStroke.Color = theme.AccentSecondary, theme.Border; MinimizeButton.BackgroundColor3, MinimizeButton.TextColor3 = theme.AccentSecondary, theme.Text; local function themeInteractive(e) if e:IsA("TextButton") then e.BackgroundColor3, e.TextColor3 = theme.Accent, theme.Text elseif e:IsA("TextBox") then e.BackgroundColor3, e.TextColor3, e.PlaceholderColor3 = theme.AccentSecondary, theme.Text, Color3.new(theme.Text.r,theme.Text.g,theme.Text.b)*0.7 end if e:FindFirstChildOfClass("UIStroke") then e.UIStroke.Color=theme.Border end end; for _, p in ipairs({PlayerPage,ServerPage,ScannerPage,SettingsPage}) do for _,c in ipairs(p:GetDescendants()) do if c:IsA("TextButton") or c:IsA("TextBox") then themeInteractive(c) end end end; for _,c in ipairs(NavContainer:GetChildren()) do if c:IsA("TextButton") then c.TextColor3 = theme.Text end end; for _,p in ipairs(PageContainer:GetChildren()) do if p.Visible then switchPage(p.Name) break end end end
local navButtons = {"Player", "Server", "Scanner", "Settings", "ScannerObject", "LogConsole"}
for i, name in ipairs(navButtons) do
    local NavButton = Instance.new("TextButton", NavContainer)
    NavButton.Name, NavButton.Size, NavButton.Font, NavButton.Text =
        name.."Nav", UDim2.new(1,0,0,40), Enum.Font.GothamSemibold,
        (name=="ScannerObject" and "Scanner Object" or name)
    Instance.new("UICorner", NavButton).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", NavButton).Thickness = 1
    NavButton.MouseButton1Click:Connect(function()
        switchPage(name)
    end)
end


-- <<< FUNGSI INTI UNTUK FITUR FLY >>>
function toggleFly(enabled)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp, humanoid = char.HumanoidRootPart, char.Humanoid

    if enabled then
        local FlyGui = Instance.new("ScreenGui", CoreGui); FlyGui.Name = "FlyControlsGui"
        local UpButton = Instance.new("TextButton", FlyGui)
        UpButton.Size = UDim2.new(0,30,0,30)
        UpButton.Position = UDim2.new(1, -960,1,-220)
        UpButton.Text = "Up"
        UpButton.Font = Enum.Font.GothamBold
        UpButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
        UpButton.BackgroundTransparency = 0.5
        UpButton.TextColor3 = Color3.fromRGB(255,255,255)

        local DownButton = Instance.new("TextButton", FlyGui)
        DownButton.Size = UDim2.new(0,30,0,30)
        DownButton.Position = UDim2.new(1, -960,1,-110)
        DownButton.Text = "Down"
        DownButton.Font = Enum.Font.GothamBold
        DownButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
        DownButton.BackgroundTransparency = 0.5
        DownButton.TextColor3 = Color3.fromRGB(255,255,255)

        local ForwardButton = Instance.new("TextButton", FlyGui)
        ForwardButton.Size = UDim2.new(0,30,0,30)
        ForwardButton.Position = UDim2.new(1,-1019,1,-170)
        ForwardButton.Text = "Forward"
        ForwardButton.Font = Enum.Font.GothamBold
        ForwardButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
        ForwardButton.BackgroundTransparency = 0.5
        ForwardButton.TextColor3 = Color3.fromRGB(255,255,255)

        local BackwardButton = Instance.new("TextButton", FlyGui)
        BackwardButton.Size = UDim2.new(0,30,0,30)
        BackwardButton.Position = UDim2.new(1,-906,1,-170)
        BackwardButton.Text = "Backward"
        BackwardButton.Font = Enum.Font.GothamBold
        BackwardButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
        BackwardButton.BackgroundTransparency = 0.5
        BackwardButton.TextColor3 = Color3.fromRGB(255,255,255)

        local gyro = Instance.new("BodyGyro", hrp); gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); gyro.D = 100
        local vel = Instance.new("BodyVelocity", hrp); vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        humanoid.PlatformStand = true

        local movingUp, movingDown = false, false
        local movingForward, movingBackward = false, false

        UpButton.MouseButton1Down:Connect(function() movingUp = true end)
        UpButton.MouseButton1Up:Connect(function() movingUp = false end)
        DownButton.MouseButton1Down:Connect(function() movingDown = true end)
        DownButton.MouseButton1Up:Connect(function() movingDown = false end)
        ForwardButton.MouseButton1Down:Connect(function() movingForward = true end)
        ForwardButton.MouseButton1Up:Connect(function() movingForward = false end)
        BackwardButton.MouseButton1Down:Connect(function() movingBackward = true end)
        BackwardButton.MouseButton1Up:Connect(function() movingBackward = false end)

        flyConnection = RunService.RenderStepped:Connect(function()
            local camCF = workspace.CurrentCamera.CFrame; gyro.CFrame = camCF
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or movingForward then direction = direction + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) or movingBackward then direction = direction - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camCF.RightVector end
            if movingUp then direction = direction + Vector3.new(0, 1, 0) end
            if movingDown then direction = direction - Vector3.new(0, 1, 0) end
            vel.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.new()
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        humanoid.PlatformStand = false
        pcall(function() hrp.BodyGyro:Destroy(); hrp.BodyVelocity:Destroy() end)
        pcall(function() CoreGui.FlyControlsGui:Destroy() end)
    end
end

-- ...existing code...

-- FUNGSI CLOSE & MINIMIZE
-- ...existing code...

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Visible = false
        BlurEffect.Enabled = false
        MinimizeIcon.Visible = true
    else
        MainFrame.Visible = true
        BlurEffect.Enabled = true
        MinimizeIcon.Visible = false
    end
end)

MinimizeIcon.MouseButton1Click:Connect(function()
    isMinimized = false
    MainFrame.Visible = true
    BlurEffect.Enabled = true
    MinimizeIcon.Visible = false
end)

-- FUNGSI CLOSE
CloseButton.MouseButton1Click:Connect(function()
    toggleFly(false)
    ScreenGui:Destroy()
    if Lighting:FindFirstChild("PowerTool_Blur") then
        Lighting.PowerTool_Blur:Destroy()
    end
end)

-- ...existing code...

--// INISIALISASI //--
switchPage("Player")
applyTheme(currentThemeName)
print("Personal Power-Tool UI v3+ Berhasil Dimuat!")
