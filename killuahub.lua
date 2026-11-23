--=====================================================
--  KILLUA HUB v4.2  |  Mobile + PC  |  UI CORRIGIDA
--=====================================================
if _G.KilluaHub then pcall(function() _G.KilluaHub:Destroy() end) end
print("[Killua] Carregando v4.2...")

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService)
local UIS = game:GetService("UserInputService)
local Http = game:GetService("HttpService)
local TweenService = game:GetService("TweenService)
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
                    firetouchinterest(tool.Handle, hrp, 1) 
                end) 
            end
            task.wait(0.1) 
            if one then break end
        end
    end
end

-- ===================== QUEST TABLE COMPLETA =====================
local questTable = {
    {1,"Bandit"},{15,"Monkey"},{30,"Brute"},{60,"Pirate"},{90,"Brute"},{120,"Brute"},
    {150,"Brute"},{200,"Brute"},{250,"Brute"},{300,"Brute"},{350,"Brute"},{400,"Brute"},
    {450,"Brute"},{500,"Brute"},{550,"Swan"},{600,"Vista"},{675,"Don Swan"},{725,"King Buu"},
    {750,"Thatch"},{800,"Arlong"},{850,"Foxy"},{900,"Dalmatian"},{950,"Admiral Aokiji"},
    {1000,"Captain Elephant"},{1050,"General Shanks"},{1100,"Island Queen"},{1150,"Saber"},
    {1200,"Warden"},{1250,"Ice Admiral"},{1300,"Marine Captain"},{1350,"Marine General"},
    {1400,"Madhead"},{1450,"Jungle Pirate"},{1500,"Magma Admiral"}
}

-- ===================== INTERFACE (UI) HOHO STYLE =====================
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "KilluaHubUI"
MainGui.ZIndexBehavior = ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 280, 0, 450)
Frame.Position = UDim2.new(0.5, -140, 0.5, -225)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "KILLUA HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = Frame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.Text = "✕"
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Bold
CloseBtn.TextSize = 16
CloseBtn.Parent = Frame

CloseBtn.MouseButton1Click:Connect(function()
    MainGui.Enabled = not MainGui.Enabled
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = ScrollFrame

-- Função para criar botões modernos
local function createButton(text, action)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = btn
    
    -- Hover Effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(action)
end

-- Lista de Botões da UI
createButton("Teleport: Marineford", function() teleport("Marineford", Vector3.new(-2795, 20, 250)) end)
createButton("Teleport: Paradise", function() teleport("Paradise", Vector3.new(-2795, 20, 250)) end)
createButton("Speed Hack", function() 
    C.speed = (C.speed == 16 and 50 or 16)
    if alive() then plr.Character.Humanoid.WalkSpeed = C.speed end
    notify("Speed: " .. tostring(C.speed))
end)
createButton("Auto Quest", function() 
    C.autoquest = not C.autoquest
    notify("Auto Quest: " .. tostring(C.autoquest))
    saveCfg()
end)
createButton("Infinite Stamina", function() 
    C.farmLevel = not C.farmLevel -- Usando flag existente como exemplo
    notify("Stamina Hack: " .. tostring(C.farmLevel))
end)
createButton("Buy All Stats", function() 
    if alive() then
        local char = plr.Character
        local stats = char:FindFirstChild("stats")
        if stats then
            for _, stat in pairs(stats:GetChildren()) do
                if stat:IsA("IntValue") then
                    invoke("StatPoints", "Add", 1)
                end
            end
            notify("Stats Maxed!")
        end
    end
end)

-- Adicionar UI ao Player
MainGui.Parent = plr:WaitForChild("PlayerGui")

-- Animação de Entrada
Frame.Position = UDim2.new(0.5, -140, 0.5, -250)
local Goal = {}
Goal.Position = UDim2.new(0.5, -140, 0.5, -225)
local TweenIn = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Goal)
TweenIn:Play()

-- ===================== LOOPS AUTOMATICO =====================
task.spawn(function()
    while true do
        wait(1)
        
        -- Auto Quest Logic
        if C.autoquest and alive() then
            local level = plr.Character:FindFirstChild("stats") and plr.Character.stats.Level.Value or 1
            for _, q in pairs(questTable) do
                if level >= q[1] then
                    -- Tenta atacar o NPC da quest
                    doAttack(q[2], false)
                    break
                end
            end
        end
        
        -- Infinite Stamina Logic
        if C.farmLevel and alive() then
            local stamina = plr.Character:FindFirstChild("Stamina")
            if stamina then stamina.Value = 100 end
        end
    end
end)

-- Toggle Key (Right Shift)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainGui.Enabled = not MainGui.Enabled
    end
end)

print("[Killua] Hub Carregado com Sucesso!")
_G.KilluaHub = MainGui
