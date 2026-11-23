--=====================================================
--  KILLUA HUB v4.2  |  MOBILE FIX
--=====================================================
if _G.KilluaHub then pcall(function() _G.KilluaHub:Destroy() end) end
print("[Killua] Carregando...")

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") -- CORRIGIDO
local UIS = game:GetService("UserInputService") -- CORRIGIDO
local Http = game:GetService("HttpService") -- CORRIGIDO
local TweenService = game:GetService("TweenService") -- CORRIGIDO
local plr = Players.LocalPlayer
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

--================ CONFIG ================
local CFG = "killuahub_config.json"
local C = {
    speed = 16, jump = 50, farmLevel = false, farmMastery = false, farmMoney = false, farmBoss = false,
    autoquest = false, buso = false, ken = false, autorad = false, bring = false, aura = false,
    chestFarm = false, fruitFarm = false, espPlayers = false, espChests = false, espFruits = false,
    autostats = false, statName = "Melee", antiAfk = false, fullbright = false, sniper = false, sniperName = "",
    weapon = "", npcFilter = "", bossFilter = "",
}
local hasFS = pcall(function() return readfile and writefile and isfile end)
if hasFS then
    pcall(function()
        if isfile(CFG) then
            local d = Http:JSONDecode(readfile(CFG))
            for k, v in pairs(d) do C[k] = v end
        end
    end)
end
local function saveCfg()
    if hasFS then
        pcall(function() writefile(CFG, Http:JSONEncode(C)) end)
    end
end

--================ HELPERS ================
local function alive()
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return c and c:FindFirstChild("HumanoidRootPart") and h and h.Health > 0
end

local function tp(p)
    if alive() then
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(p)
    end
end

local function notify(t)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Killua Hub", Text=t, Duration=2})
    end)
end

local function invoke(a, b, c2)
    pcall(function() RS.Remotes.CommF_:InvokeServer(a, b, c2) end)
end

local function teleport(name, coord)
    if not alive() then return end
    local before = plr.Character.HumanoidRootPart.Position
    pcall(function() RS.Remotes.CommF_:InvokeServer("Teleport", name) end)
    task.delay(1.3, function()
        if alive() then
            local now = plr.Character.HumanoidRootPart.Position
            if (now - before).Magnitude < 8 and coord then
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(coord)
            end
        end
    end)
end

local function equipWeapon(name)
    if not alive() or name == "" then return end
    for _, t in pairs(plr.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == name then
            t.Parent = plr.Character; break
        end
    end
end

local function doAttack(filter, one)
    if not alive() then return end
    local c = plr.Character
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then
        for _, t in pairs(plr.Backpack:GetChildren()) do
            if t:IsA("Tool") then tool = t break end
        end
        if tool then tool.Parent = c end
    end

    local e = workspace:FindFirstChild("Enemies")
    if not e then return end

    for _, m in pairs(e:GetChildren()) do
        local hrp, hum = m:FindFirstChild("HumanoidRootPart"), m:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 and (filter == "" or m.Name == filter) then
            tp(hrp.Position)
            if tool and tool:FindFirstChild("Handle") then
                pcall(function()
                    firetouchinterest(tool.Handle, hrp, 0)
                    task.wait()
                    firetouchinterest(tool.Handle, hrp, 1) -- CORRIGIDO: Handle ao invés de Hand
                end)
            end
            if one then break end
        end
    end
end

--================ MAIN LOOP ================
spawn(function()
    while task.wait(0.1) do
        if not alive() then continue end
        
        -- Farm Logic Simplificada para Mobile
        if C.farmBoss or C.farmMoney or C.farmLevel then
            doAttack(C.bossFilter or "")
        end
        
        -- Auto Equip Weapon
        if C.weapon ~= "" then
            equipWeapon(C.weapon)
        end
    end
end)

--================ UI SIMPLES (MOBILE) ================
spawn(function()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KilluaHubUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Frame = Instance.new("Frame")
    Frame.Name = "MainFrame"
    Frame.Size = UDim2.new(0, 300, 0, 400)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Visible = true
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "KILLUA HUB V4.2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    
    local Layout = Instance.new("UICodeContext") -- Placeholder layout
    
    -- Adiciona botões básicos
    local buttons = {
        {name = "Speed: "..tostring(C.speed), action = function() C.speed = C.speed + 2; saveCfg() end},
        {name = "Jump: "..tostring(C.jump), action = function() C.jump = C.jump + 5; saveCfg() end},
        {name = "Farm Boss: "..tostring(C.farmBoss), action = function() C.farmBoss = not C.farmBoss; saveCfg() end},
        {name = "Auto Quest: "..tostring(C.autoquest), action = function() C.autoquest = not C.autoquest; saveCfg() end},
        {name = "Close", action = function() Frame.Visible = false end},
    }
    
    for i, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Name = "Btn"..i
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, (i-1)*35)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = btnData.name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        
        btn.MouseButton1Click:Connect(btnData.action)
        btn.Parent = Container
    end
    
    Title.Parent = Frame
    Container.Parent = Frame
    Frame.Parent = ScreenGui
    ScreenGui.Parent = plr.PlayerGui
    
    -- Drag simples
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end)

print("[Killua] Pronto!")
