-- KILLUA HUB | estilo hub (abas: Farm / Teleport / Player / Misc)
-- Feito pra executor com firetouchinterest + getconnections (Delta, Fluxus, Codex, Hydrogen)

if _G.KilluaHub then pcall(function() _G.KilluaHub:Destroy() end) end

local plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

local S = { farm=false, chest=false, fast=false, autoquest=false, kills=0 }

local function ok() return plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 end
local function tp(p) if ok() then plr.Character.HumanoidRootPart.CFrame = CFrame.new(p) end end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "KilluaHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.Parent = plr:WaitForChild("PlayerGui")
_G.KilluaHub = gui

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 50)
toggle.Position = UDim2.new(0, 18, 0, 140)
toggle.BackgroundColor3 = Color3.fromRGB(34, 211, 238)
toggle.Text = "K"; toggle.TextColor3 = Color3.fromRGB(10, 14, 20)
toggle.Font = Enum.Font.GothamBold; toggle.TextSize = 22
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 340)
main.Position = UDim2.new(0, 78, 0, 140)
main.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true
main.Visible = false; main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

toggle.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

local head = Instance.new("TextLabel")
head.Size = UDim2.new(1, 0, 0, 38)
head.BackgroundColor3 = Color3.fromRGB(34, 211, 238)
head.Text = "KILLUA HUB"; head.TextColor3 = Color3.fromRGB(10, 14, 20)
head.Font = Enum.Font.GothamBold; head.TextSize = 15
head.Parent = main
Instance.new("UICorner", head).CornerRadius = UDim.new(0, 12)

-- abas
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 26); tabBar.Position = UDim2.new(0, 8, 0, 44)
tabBar.BackgroundTransparency = 1; tabBar.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -16, 1, -86); content.Position = UDim2.new(0, 8, 0, 76)
content.BackgroundTransparency = 1; content.Parent = main

local pages = {}
local function makePage(name)
  local f = Instance.new("ScrollingFrame")
  f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1
  f.BorderSizePixel = 0; f.ScrollBarThickness = 4
  f.Visible = false; f.Parent = content
  pages[name] = f
  return f
end

local function showTab(name)
  for n, p in pairs(pages) do p.Visible = (n == name) end
end

local function tabBtn(name, x)
  local b = Instance.new("TextButton")
  b.Size = UDim2.new(0, 58, 1, 0); b.Position = UDim2.new(0, x, 0, 0)
  b.BackgroundColor3 = Color3.fromRGB(18, 28, 38)
  b.Text = name; b.TextColor3 = Color3.fromRGB(230, 237, 243)
  b.Font = Enum.Font.Gotham; b.TextSize = 11; b.Parent = tabBar
  Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
  b.MouseButton1Click:Connect(function() showTab(name) end)
end

tabBtn("Farm", 0); tabBtn("Teleport", 62); tabBtn("Player", 124); tabBtn("Misc", 186)

local function btn(parent, text, y, cb)
  local b = Instance.new("TextButton")
  b.Size = UDim2.new(1, 0, 0, 30); b.Position = UDim2.new(0, 0, 0, y)
  b.BackgroundColor3 = Color3.fromRGB(18, 28, 38)
  b.Text = text; b.TextColor3 = Color3.fromRGB(230, 237, 243)
  b.Font = Enum.Font.Gotham; b.TextSize = 12; b.Parent = parent
  Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
  b.MouseButton1Click:Connect(function() cb(b) end)
  return b
end

local function toggleBtn(parent, label, y, get, set)
  local b = btn(parent, label .. ": OFF", y, function(self)
    set(not get())
    local on = get()
    self.Text = label .. ": " .. (on and "ON" or "OFF")
    self.BackgroundColor3 = on and Color3.fromRGB(34, 211, 238) or Color3.fromRGB(18, 28, 38)
    self.TextColor3 = on and Color3.fromRGB(10, 14, 20) or Color3.fromRGB(230, 237, 243)
  end)
  return b
end

-- ===== Farm =====
local farmPage = makePage("Farm")
local function doAttack()
  if not ok() then return end
  local tool = plr.Character:FindFirstChildOfClass("Tool")
  if not tool then
    for _, t in pairs(plr.Backpack:GetChildren()) do if t:IsA("Tool") then tool = t break end end
    if tool then tool.Parent = plr.Character end
  end
  local en = workspace:FindFirstChild("Enemies")
  if not en then return end
  for _, e in pairs(en:GetChildren()) do
    local hrp, hum = e:FindFirstChild("HumanoidRootPart"), e:FindFirstChild("Humanoid")
    if hrp and hum and hum.Health > 0 then
      tp(hrp.Position)
      if tool and tool:FindFirstChild("Handle") then
        pcall(function() firetouchinterest(tool.Handle, hrp, 0); task.wait(); firetouchinterest(tool.Handle, hrp, 1) end)
      end
      if S.fast then pcall(function() RS.Remotes.CommF_:InvokeServer("attack", e.Name) end) end
      task.wait(0.12)
    end
  end
end

toggleBtn(farmPage, "Auto Farm", 6, function() return S.farm end, function(v)
  S.farm = v
  if v then task.spawn(function() while S.farm do doAttack(); task.wait(0.25) end end) end
end)

toggleBtn(farmPage, "Chest Farm", 44, function() return S.chest end, function(v)
  S.chest = v
  if v then task.spawn(function()
    while S.chest do
      for _, c in pairs(workspace:GetDescendants()) do
        if c:IsA("MeshPart") and string.find(c.Name, "Chest") then tp(c.Position); task.wait(0.35) end
      end
      task.wait(0.5)
    end
  end) end
end)

toggleBtn(farmPage, "Fast Attack", 82, function() return S.fast end, function(v) S.fast = v end)

toggleBtn(farmPage, "Auto Quest", 120, function() return S.autoquest end, function(v)
  S.autoquest = v
  if v then task.spawn(function()
    while S.autoquest do
      pcall(function() RS.Remotes.CommF_:InvokeServer("StartQuest", "Bandit", 1) end)
      task.wait(1)
    end
  end) end
end)

local killLbl = Instance.new("TextLabel")
killLbl.Size = UDim2.new(1, 0, 0, 20); killLbl.Position = UDim2.new(0, 0, 0, 160)
killLbl.BackgroundTransparency = 1; killLbl.TextColor3 = Color3.fromRGB(140, 160, 175)
killLbl.Font = Enum.Font.Gotham; killLbl.TextSize = 11; killLbl.Text = "kills: 0"; killLbl.Parent = farmPage

-- ===== Teleport =====
local tpPage = makePage("Teleport")
local islands = {
  {"Bandits", Vector3.new(-1300, 12, 4600)},
  {"Marines", Vector3.new(0, 30, 1000)},
  {"Snow", Vector3.new(1200, 50, -1300)},
  {"Desert", Vector3.new(1000, 20, 2000)},
  {"Jungle", Vector3.new(-1200, 20, -300)},
  {"Sky", Vector3.new(-4700, 600, -1300)},
  {"Underwater", Vector3.new(-4700, 500, 2000)},
  {"Second Sea", Vector3.new(1500, 50, 1000)},
}
for i, isl in ipairs(islands) do
  btn(tpPage, isl[1], (i - 1) * 34, function() tp(isl[2]) end)
end

-- ===== Player =====
local plrPage = makePage("Player")
btn(plrPage, "Speed 200", 6, function()
  if ok() then plr.Character.Humanoid.WalkSpeed = 200 end
end)
btn(plrPage, "Jump 150", 40, function()
  if ok() then plr.Character.Humanoid.JumpPower = 150 end
end)
btn(plrPage, "Reset Speed/Jump", 74, function()
  if ok() then plr.Character.Humanoid.WalkSpeed = 16; plr.Character.Humanoid.JumpPower = 50 end
end)
btn(plrPage, "Heal (restaurar)", 108, function()
  pcall(function() plr.Character.Humanoid.Health = plr.Character.Humanoid.MaxHealth end)
end)

-- ===== Misc =====
local miscPage = makePage("Misc")
btn(miscPage, "Rejoin", 6, function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, plr) end) end)
btn(miscPage, "Server Hop", 40, function()
  task.spawn(function()
    local ok2, list = pcall(function()
      return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=50")
    end)
    if ok2 then
      local data = game:GetService("HttpService"):JSONDecode(list)
      for _, s in pairs(data.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
          pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, plr) end)
          break
        end
      end
    end
  end)
end)
btn(miscPage, "Fechar Hub", 74, function() gui:Destroy(); _G.KilluaHub = nil end)

showTab("Farm")
print("Killua Hub carregado")
