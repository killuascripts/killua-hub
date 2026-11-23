--=====================================================
--  KILLUA HUB v3.1  |  mobile + PC  |  sea 1 / 2 / 3
--=====================================================
if _G.KilluaHub then pcall(function() _G.KilluaHub:Destroy() end) end
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TPS = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VU = game:GetService("VirtualUser")
local plr = Players.LocalPlayer
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local CFG = "killuahub_config.json"
local hasFS = pcall(function() return readfile and writefile and isfile end)
local C = {
  speed = 16, jump = 50, farm = false, aura = false, bring = false, autoquest = false, autorad = false,
  espPlayers = false, espChests = false, espFruits = false, espBosses = false,
  buso = false, ken = false, autostats = false, statName = "Melee", antiAfk = false, fullbright = false,
  chestFarm = false, fruitFarm = false, bossFarm = false,
  npcFilter = "", bossFilter = "", sniper = false, sniperName = "",
}
if hasFS then pcall(function() if isfile(CFG) then local d = Http:JSONDecode(readfile(CFG)); for k, v in pairs(d) do C[k] = v end end end) end
local function saveCfg() if hasFS then pcall(function() writefile(CFG, Http:JSONEncode(C)) end) end end

local function alive()
  local c = plr.Character
  local h = c and c:FindFirstChildOfClass("Humanoid")
  return c and c:FindFirstChild("HumanoidRootPart") and h and h.Health > 0
end
local function tp(p) if alive() then plr.Character.HumanoidRootPart.CFrame = CFrame.new(p) end end
local function notify(t) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Killua Hub", Text=t, Duration=2}) end) end
local function invoke(a, b, c2) pcall(function() RS.Remotes.CommF_:InvokeServer(a, b, c2) end) end

-- TELEPORT: remote do jogo + coordenada de reserva
local function teleport(name, coord)
  if not alive() then return end
  local before = plr.Character.HumanoidRootPart.Position
  pcall(function() RS.Remotes.CommF_:InvokeServer("Teleport", name) end)
  task.delay(1.3, function()
    if alive() then
      local now = plr.Character.HumanoidRootPart.Position
      if (now - before).Magnitude < 8 and coord then plr.Character.HumanoidRootPart.CFrame = CFrame.new(coord) end
    end
  end)
end

--==== GUI ====
local gui = Instance.new("ScreenGui")
gui.Name = "KilluaHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.Parent = plr:WaitForChild("PlayerGui"); _G.KilluaHub = gui

local open = Instance.new("TextButton")
open.Size = UDim2.new(0, 54, 0, 54); open.Position = UDim2.new(0, 16, 0, 140)
open.BackgroundColor3 = Color3.fromRGB(34, 211, 238); open.Text = "K"
open.TextColor3 = Color3.fromRGB(8, 12, 16); open.Font = Enum.Font.GothamBlack; open.TextSize = 24
open.Parent = gui; Instance.new("UICorner", open).CornerRadius = UDim.new(0, 14)

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 480, 0, 360); win.Position = UDim2.new(0.5, -240, 0.5, -180)
win.BackgroundColor3 = Color3.fromRGB(10, 14, 20); win.BorderSizePixel = 0
win.Active = true; win.Visible = false; win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", win).Color = Color3.fromRGB(24, 40, 52)
do
  local drag, start, init = false, nil, nil
  win.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; start = i.Position; init = win.Position end end)
  win.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
  UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - start; win.Position = UDim2.new(init.X.Scale, init.X.Offset + d.X, init.Y.Scale, init.Y.Offset + d.Y) end end)
end
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44); header.BackgroundColor3 = Color3.fromRGB(12, 18, 26); header.BorderSizePixel = 0; header.Parent = win
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 220, 1, 0); logo.Position = UDim2.new(0, 14, 0, 0); logo.BackgroundTransparency = 1
logo.Text = "KILLUA HUB  v3.1"; logo.TextColor3 = Color3.fromRGB(34, 211, 238); logo.Font = Enum.Font.GothamBlack
logo.TextSize = 15; logo.TextXAlignment = Enum.TextXAlignment.Left; logo.Parent = header
local function hdrBtn(txt, x, cb)
  local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 30, 0, 30); b.Position = UDim2.new(1, x, 0, 7)
  b.BackgroundColor3 = Color3.fromRGB(20, 30, 40); b.Text = txt; b.TextColor3 = Color3.fromRGB(200, 220, 235)
  b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.Parent = header; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
  b.MouseButton1Click:Connect(function() cb(b) end)
end
hdrBtn("_", -76, function() win.Visible = false end)
hdrBtn("X", -40, function() gui:Destroy(); _G.KilluaHub = nil end)
open.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)
if not mobile then UIS.InputBegan:Connect(function(k, g) if not g and k.KeyCode == Enum.KeyCode.RightShift then win.Visible = not win.Visible end end) end

local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -28, 0, 30); search.Position = UDim2.new(0, 14, 0, 52)
search.BackgroundColor3 = Color3.fromRGB(16, 24, 32); search.PlaceholderText = "buscar função..."
search.Text = ""; search.TextColor3 = Color3.fromRGB(220, 235, 245); search.PlaceholderColor3 = Color3.fromRGB(80, 96, 110)
search.Font = Enum.Font.Gotham; search.TextSize = 12; search.ClearTextOnFocus = false; search.Parent = win
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 8)

local side = Instance.new("Frame"); side.Size = UDim2.new(0, 108, 1, -132); side.Position = UDim2.new(0, 14, 0, 90); side.BackgroundTransparency = 1; side.Parent = win
local pagesWrap = Instance.new("Frame"); pagesWrap.Size = UDim2.new(1, -140, 1, -132); pagesWrap.Position = UDim2.new(0, 126, 0, 90); pagesWrap.BackgroundTransparency = 1; pagesWrap.Parent = win
local status = Instance.new("Frame"); status.Size = UDim2.new(1, 0, 0, 26); status.Position = UDim2.new(0, 0, 1, -26); status.BackgroundColor3 = Color3.fromRGB(12, 18, 26); status.BorderSizePixel = 0; status.Parent = win
local stxt = Instance.new("TextLabel"); stxt.Size = UDim2.new(1, -20, 1, 0); stxt.Position = UDim2.new(0, 14, 0, 0); stxt.BackgroundTransparency = 1; stxt.TextColor3 = Color3.fromRGB(90, 108, 124); stxt.Font = Enum.Font.Gotham; stxt.TextSize = 10; stxt.TextXAlignment = Enum.TextXAlignment.Left; stxt.Text = "pronto"; stxt.Parent = status

local pages, buttons, Y = {}, {}, {}
local function page(name)
  local f = Instance.new("ScrollingFrame")
  f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ScrollBarThickness = 3
  f.CanvasSize = UDim2.new(0, 0, 0, 0); f.Visible = false; f.Parent = pagesWrap; pages[name] = f; return f
end
local function showTab(n)
  for k, p in pairs(pages) do p.Visible = (k == n) end
  for k, b in pairs(buttons) do b.BackgroundColor3 = (k == n) and Color3.fromRGB(34, 211, 238) or Color3.fromRGB(16, 24, 32); b.TextColor3 = (k == n) and Color3.fromRGB(8, 12, 16) or Color3.fromRGB(190, 210, 225) end
end
local function tab(name, y)
  local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 28); b.Position = UDim2.new(0, 0, 0, y)
  b.BackgroundColor3 = Color3.fromRGB(16, 24, 32); b.Text = name; b.TextColor3 = Color3.fromRGB(190, 210, 225)
  b.Font = Enum.Font.Gotham; b.TextSize = 12; b.Parent = side; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
  b.MouseButton1Click:Connect(function() showTab(name) end); buttons[name] = b
end
tab("Farm", 0); tab("Quest", 34); tab("Teleport", 68); tab("Player", 102); tab("Visual", 136); tab("Stats", 170); tab("Misc", 204)

local function nextY(p) Y[p] = (Y[p] or 4); local v = Y[p]; Y[p] = v + 34; p.CanvasSize = UDim2.new(0, 0, 0, Y[p] + 10); return v end
local function section(p, txt)
  local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 0, 18); l.Position = UDim2.new(0, 2, 0, nextY(p))
  l.BackgroundTransparency = 1; l.Text = string.upper(txt); l.TextColor3 = Color3.fromRGB(70, 88, 102); l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = p
end
local function baseBtn(p, txt, cb)
  local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -8, 0, 28); b.Position = UDim2.new(0, 0, 0, nextY(p))
  b.BackgroundColor3 = Color3.fromRGB(16, 24, 32); b.Text = txt; b.TextColor3 = Color3.fromRGB(215, 230, 240); b.Font = Enum.Font.Gotham; b.TextSize = 12; b.Parent = p
  Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); b.MouseButton1Click:Connect(function() cb(b) end); return b
end
local function toggle(p, txt, get, set)
  local b = baseBtn(p, txt .. "  [OFF]", function(self)
    set(not get()); local on = get(); self.Text = txt .. "  [" .. (on and "ON" or "OFF") .. "]"
    self.BackgroundColor3 = on and Color3.fromRGB(20, 52, 60) or Color3.fromRGB(16, 24, 32); self.TextColor3 = on and Color3.fromRGB(34, 211, 238) or Color3.fromRGB(215, 230, 240); saveCfg()
  end)
  if get() then b.Text = txt .. "  [ON]"; b.BackgroundColor3 = Color3.fromRGB(20, 52, 60); b.TextColor3 = Color3.fromRGB(34, 211, 238) end
  return b
end
local function slider(p, txt, min, max, get, set)
  local wrap = Instance.new("Frame"); wrap.Size = UDim2.new(1, -8, 0, 42); wrap.Position = UDim2.new(0, 0, 0, nextY(p))
  wrap.BackgroundColor3 = Color3.fromRGB(16, 24, 32); wrap.BorderSizePixel = 0; wrap.Parent = p; Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 6)
  local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -12, 0, 18); lbl.Position = UDim2.new(0, 8, 0, 3); lbl.BackgroundTransparency = 1
  lbl.Text = txt .. ": " .. get(); lbl.TextColor3 = Color3.fromRGB(215, 230, 240); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = wrap
  local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, -16, 0, 8); bar.Position = UDim2.new(0, 8, 0, 25); bar.BackgroundColor3 = Color3.fromRGB(28, 40, 52); bar.BorderSizePixel = 0; bar.Parent = wrap
  Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
  local fill = Instance.new("Frame"); fill.Size = UDim2.new((get() - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(34, 211, 238); fill.BorderSizePixel = 0; fill.Parent = bar; Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
  local dragging = false
  local function upd(x) local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); local val = math.floor(min + (max - min) * rel); fill.Size = UDim2.new(rel, 0, 1, 0); lbl.Text = txt .. ": " .. val; set(val) end
  bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; upd(i.Position.X) end end)
  UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
  UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
end
local function dropdown(p, txt, list, cb)
  baseBtn(p, txt .. " ▾", function(self)
    if self.Expanded then for _, c in pairs(p:GetChildren()) do if c:GetAttribute("dd") then c:Destroy() end end; self.Expanded = false; return end
    self.Expanded = true; local y = 0
    for _, item in ipairs(list) do
      local o = Instance.new("TextButton"); o.Size = UDim2.new(1, -8, 0, 26); o.Position = UDim2.new(0, 4, 0, self.AbsolutePosition.Y - p.AbsolutePosition.Y + self.AbsoluteSize.Y + y)
      o.BackgroundColor3 = Color3.fromRGB(20, 30, 40); o.Text = item; o.TextColor3 = Color3.fromRGB(210, 225, 235); o.Font = Enum.Font.Gotham; o.TextSize = 11; o.Parent = p; o:SetAttribute("dd", true)
      Instance.new("UICorner", o).CornerRadius = UDim.new(0, 5)
      o.MouseButton1Click:Connect(function() cb(item); self.Text = txt .. ": " .. item; for _, c in pairs(p:GetChildren()) do if c:GetAttribute("dd") then c:Destroy() end end; self.Expanded = false end)
      y += 28
    end
  end)
end

--==== FARM ====
local fp = page("Farm")
local enemyList, bossList = {}, {}
task.spawn(function()
  local e = workspace:FindFirstChild("Enemies")
  if e then for _, m in pairs(e:GetChildren()) do local h = m:FindFirstChild("Humanoid"); if h then table.insert(enemyList, m.Name); if h.MaxHealth >= 1000 then table.insert(bossList, m.Name) end end end end
end)
local function doAttack(filter, one)
  if not alive() then return end
  local c = plr.Character
  local tool = c:FindFirstChildOfClass("Tool")
  if not tool then for _, t in pairs(plr.Backpack:GetChildren()) do if t:IsA("Tool") then tool = t break end end; if tool then tool.Parent = c end end
  local e = workspace:FindFirstChild("Enemies"); if not e then return end
  for _, m in pairs(e:GetChildren()) do
    local hrp, hum = m:FindFirstChild("HumanoidRootPart"), m:FindFirstChild("Humanoid")
    if hrp and hum and hum.Health > 0 and (filter == "" or m.Name == filter) then
      tp(hrp.Position)
      if tool and tool:FindFirstChild("Handle") then pcall(function() firetouchinterest(tool.Handle, hrp, 0); task.wait(); firetouchinterest(tool.Handle, hrp, 1) end) end
      task.wait(0.1); if one then break end
    end
  end
end
section(fp, "combate")
toggle(fp, "Auto Farm", function() return C.farm end, function(v) C.farm = v; if v then task.spawn(function() while C.farm do doAttack(C.npcFilter, false); task.wait(0.25) end end) end end)
toggle(fp, "Kill Aura", function() return C.aura end, function(v)
  C.aura = v
  if v then task.spawn(function() while C.aura do
    if alive() then
      local tool = plr.Character:FindFirstChildOfClass("Tool"); local e = workspace:FindFirstChild("Enemies")
      if tool and tool:FindFirstChild("Handle") and e then
        for _, m in pairs(e:GetChildren()) do local h = m:FindFirstChild("HumanoidRootPart")
          if h and m:FindFirstChild("Humanoid").Health > 0 and (h.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 45 then
            pcall(function() firetouchinterest(tool.Handle, h, 0); task.wait(); firetouchinterest(tool.Handle, h, 1) end)
          end end
      end end
    task.wait(0.15)
  end end) end
end)
toggle(fp, "Bring Mobs", function() return C.bring end, function(v)
  C.bring = v
  if v then task.spawn(function() while C.bring do
    if alive() then local e = workspace:FindFirstChild("Enemies"); if e then for _, m in pairs(e:GetChildren()) do local h = m:FindFirstChild("HumanoidRootPart"); if h then h.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-8,8),0,math.random(-8,8)) end end end end
    task.wait(0.4)
  end end) end
end)
section(fp, "alvo")
dropdown(fp, "NPC", enemyList, function(v) C.npcFilter = v end)
baseBtn(fp, "Limpar filtro", function() C.npcFilter = "" end)
section(fp, "boss")
dropdown(fp, "Boss", bossList, function(v) C.bossFilter = v end)
toggle(fp, "Auto Boss Farm", function() return C.bossFarm end, function(v)
  C.bossFarm = v
  if v then task.spawn(function() while C.bossFarm do
    if C.bossFilter == "" then task.wait(0.5) else doAttack(C.bossFilter, true) end
    task.wait(0.3)
  end end) end
end)
section(fp, "coleta")
toggle(fp, "Chest Farm", function() return C.chestFarm end, function(v)
  C.chestFarm = v
  if v then task.spawn(function() while C.chestFarm do
    if alive() then
      for _, c in pairs(workspace:GetDescendants()) do
        if c:IsA("BasePart") and string.find(c.Name, "Chest") and (c.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 400 then tp(c.Position); task.wait(0.35) end
      end
    end
    task.wait(0.4)
  end end) end
end)
toggle(fp, "Fruit Farm", function() return C.fruitFarm end, function(v)
  C.fruitFarm = v
  if v then task.spawn(function() while C.fruitFarm do
    if alive() then
      for _, t in pairs(workspace:GetDescendants()) do
        if t:IsA("Tool") and t:FindFirstChild("Handle") then
          tp(t.Handle.Position)
          pcall(function() firetouchinterest(plr.Character.HumanoidRootPart, t.Handle, 0); task.wait(); firetouchinterest(plr.Character.HumanoidRootPart, t.Handle, 1) end)
          task.wait(0.3)
        end
      end
    end
    task.wait(0.4)
  end end) end
end)

--==== QUEST ====
local qp = page("Quest")
local questTable = { {1,"Bandit"},{15,"Monkey"},{30,"Brute"},{60,"Pirate"},{90,"Brute"},{120,"Brute"},{150,"Brute"},{175,"Brute"},{200,"Brute"},{225,"Brute"},{250,"Brute"},{275,"Brute"},{300,"Brute"},{325,"Brute"},{350,"Brute"},{375,"Brute"},{400,"Brute"},{425,"Brute"},{450,"Brute"},{475,"Brute"},{500,"Brute"},{525,"Brute"},{550,"Brute"},{575,"Brute"},{600,"Brute"},{625,"Brute"},{650,"Brute"},{675,"Brute"},{700,"Brute"} }
local function pickQuest()
  local lvl = 1
  pcall(function() lvl = plr.Data.Level.Value end)
  local pick = questTable[1]
  for _, q in ipairs(questTable) do if lvl >= q[1] then pick = q end end
  return pick
end
section(qp, "missao")
toggle(qp, "Auto Quest", function() return C.autoquest end, function(v)
  C.autoquest = v
  if v then task.spawn(function() while C.autoquest do
    local q = pickQuest(); invoke("StartQuest", q[2], q[1]); task.wait(2)
  end end) end
end)
baseBtn(qp, "Entregar quest", function() invoke("CompleteQuest") end)
baseBtn(qp, "Reroll quest", function() invoke("BlackbeardReward", "Reroll", "1") end)
section(qp, "raid")
baseBtn(qp, "Iniciar raid", function() invoke("Raids", "1") end)
baseBtn(qp, "Status da raid", function() invoke("Raids", "0") end)
toggle(qp, "Auto Raid", function() return C.autorad end, function(v)
  C.autorad = v
  if v then task.spawn(function() while C.autorad do invoke("Raids", "1"); task.wait(6) end end) end
end)

--==== TELEPORT ====
local tpp = page("Teleport"); tpp.CanvasSize = UDim2.new(0, 0, 0, 0)
local subBar = Instance.new("Frame"); subBar.Size = UDim2.new(1, 0, 0, 26); subBar.BackgroundTransparency = 1; subBar.Parent = tpp
local seaData = {
  ["Sea 1"] = {
    {"Bandits", Vector3.new(-1300,12,4600)},{"Marines", Vector3.new(0,30,1000)},{"Jungle", Vector3.new(-1200,20,-300)},
    {"Desert", Vector3.new(1000,20,2000)},{"Snow Island", Vector3.new(1200,50,-1300)},{"Sky", Vector3.new(-4700,600,-1300)},
    {"Underwater City", Vector3.new(-4700,500,2000)},{"Fountain City", Vector3.new(500,50,-3500)},{"Pirate Village", Vector3.new(900,50,-1500)},
    {"Marine Fortress", Vector3.new(-3000,20,2500)},{"Prison", Vector3.new(-2000,20,1000)},{"Magma Village", Vector3.new(-4700,30,3000)},
    {"Colosseum", Vector3.new(-1500,30,-3000)},{"Frozen Village", Vector3.new(-4700,700,-3200)},
  },
  ["Sea 2"] = {
    {"Kingdom of Rose", Vector3.new(1000,50,1000)},{"Green Zone", Vector3.new(1500,50,-1000)},{"Graveyard", Vector3.new(2000,50,500)},
    {"Dark Arena", Vector3.new(2500,50,0)},{"Snow Mountain", Vector3.new(1500,50,-2000)},{"Ice Castle", Vector3.new(2000,100,-3000)},
    {"Cursed Ship", Vector3.new(900,20,-4000)},{"Haunted Castle", Vector3.new(1200,50,-3000)},{"Barren Island", Vector3.new(2500,50,-1000)},
    {"Middle Town", Vector3.new(1000,50,500)},{"Mansion", Vector3.new(2000,50,-2000)},{"Upper Sky", Vector3.new(1500,600,1000)},
    {"Forgotten Island", Vector3.new(3000,50,2000)},{"Musketeer Island", Vector3.new(3500,50,3000)},{"Bounty Island", Vector3.new(2500,50,3000)},
  },
  ["Sea 3"] = {
    {"Port Town", Vector3.new(-500,20,5000)},{"Hydra Island", Vector3.new(1000,30,6000)},{"Great Tree", Vector3.new(2500,50,5000)},
    {"Castle on the Sea", Vector3.new(3000,50,3000)},{"Haunted Castle", Vector3.new(2000,50,4000)},{"Sea of Treats", Vector3.new(3500,30,2000)},
    {"Tiki Outpost", Vector3.new(-1000,20,7000)},{"Kitsune Island", Vector3.new(-2000,30,9000)},{"Floating Turtle", Vector3.new(4000,100,4000)},
    {"Sunken City", Vector3.new(4500,-100,3000)},{"Temple of Time", Vector3.new(5000,50,2000)},
  },
}
local seaFrames, seaBtns = {}, {}
local function showSea(n)
  for k, f in pairs(seaFrames) do f.Visible = (k == n) end
  for k, b in pairs(seaBtns) do b.BackgroundColor3 = (k == n) and Color3.fromRGB(34, 211, 238) or Color3.fromRGB(20, 30, 40); b.TextColor3 = (k == n) and Color3.fromRGB(8, 12, 16) or Color3.fromRGB(190, 210, 225) end
end
for i, n in ipairs({"Sea 1","Sea 2","Sea 3"}) do
  local sb = Instance.new("TextButton"); sb.Size = UDim2.new(0, 100, 0, 24); sb.Position = UDim2.new(0, (i-1)*104, 0, 0)
  sb.BackgroundColor3 = Color3.fromRGB(20, 30, 40); sb.Text = n; sb.TextColor3 = Color3.fromRGB(190, 210, 225); sb.Font = Enum.Font.GothamBold; sb.TextSize = 11; sb.Parent = subBar
  Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 6); sb.MouseButton1Click:Connect(function() showSea(n) end); seaBtns[n] = sb
  local f = Instance.new("ScrollingFrame"); f.Size = UDim2.new(1, 0, 0, 250); f.Position = UDim2.new(0, 0, 0, 30); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ScrollBarThickness = 3
  f.CanvasSize = UDim2.new(0, 0, 0, (#seaData[n]) * 34 + 10); f.Visible = false; f.Parent = tpp; seaFrames[n] = f
  for j, isl in ipairs(seaData[n]) do
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -8, 0, 28); b.Position = UDim2.new(0, 0, 0, (j-1)*34)
    b.BackgroundColor3 = Color3.fromRGB(16, 24, 32); b.Text = isl[1]; b.TextColor3 = Color3.fromRGB(215, 230, 240); b.Font = Enum.Font.Gotham; b.TextSize = 12; b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); b.MouseButton1Click:Connect(function() teleport(isl[1], isl[2]) end)
  end
end
showSea("Sea 1")

--==== PLAYER ====
local pp = page("Player")
section(pp, "movimento")
slider(pp, "Speed", 16, 400, function() return C.speed end, function(v) C.speed = v; if alive() then plr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end; saveCfg() end)
slider(pp, "Jump", 50, 300, function() return C.jump end, function(v) C.jump = v; if alive() then plr.Character:FindFirstChildOfClass("Humanoid").JumpPower = v end; saveCfg() end)
local flyDir = {f=false,b=false,u=false,d=false,l=false,r=false}
local bv, bg, flyPad
toggle(pp, "Fly", function() return _G.kfly or false end, function(v)
  _G.kfly = v
  if v then
    if alive() then bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = plr.Character.HumanoidRootPart; bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.P = 1e4; bg.Parent = plr.Character.HumanoidRootPart end
    if mobile and not flyPad then
      flyPad = Instance.new("Frame"); flyPad.Size = UDim2.new(0, 150, 0, 90); flyPad.Position = UDim2.new(0, 16, 1, -170); flyPad.BackgroundTransparency = 0.2; flyPad.BackgroundColor3 = Color3.fromRGB(10,14,20); flyPad.Parent = gui
      Instance.new("UICorner", flyPad).CornerRadius = UDim.new(0, 10)
      local function fb(txt, x, y, key)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 40, 0, 30); b.Position = UDim2.new(0, x, 0, y); b.BackgroundColor3 = Color3.fromRGB(20,52,60); b.Text = txt; b.TextColor3 = Color3.fromRGB(34,211,238); b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.Parent = flyPad
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); b.MouseButton1Down:Connect(function() flyDir[key] = true end); b.MouseButton1Up:Connect(function() flyDir[key] = false end)
      end
      fb("^", 55, 8, "f"); fb("v", 55, 46, "b"); fb("^", 105, 27, "u"); fb("v", 5, 27, "d")
    end
    task.spawn(function() while _G.kfly do
      RunService.Heartbeat:Wait()
      if bv and alive() then
        local cam = workspace.CurrentCamera.CFrame; local dir = Vector3.new()
        if mobile then
          if flyDir.f then dir += cam.LookVector end; if flyDir.b then dir -= cam.LookVector end; if flyDir.u then dir += Vector3.new(0,1,0) end; if flyDir.d then dir -= Vector3.new(0,1,0) end; if flyDir.l then dir -= cam.RightVector end; if flyDir.r then dir += cam.RightVector end
        else
          if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end; if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end; if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end; if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end; if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end; if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        end
        bv.Velocity = dir * 90; bg.CFrame = cam
      end
    end end)
  else if bv then bv:Destroy(); bv = nil end; if bg then bg:Destroy(); bg = nil end; if flyPad then flyPad:Destroy(); flyPad = nil end end
end)
toggle(pp, "Noclip", function() return _G.knoclip or false end, function(v)
  _G.knoclip = v
  if v then task.spawn(function() while _G.knoclip do RunService.Stepped:Wait(); if plr.Character then for _, p in pairs(plr.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end end) end
end)
toggle(pp, "Infinite Jump", function() return _G.kinf or false end, function(v) _G.kinf = v end)
UIS.JumpRequest:Connect(function() if _G.kinf and alive() then plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

--==== VISUAL ====
local vp = page("Visual")
local espObjs = {}
local function clearEsp(tag) for _, o in pairs(espObjs) do if o.Tag == tag then pcall(function() o.Gui:Destroy() end) end end; for i = #espObjs, 1, -1 do if espObjs[i].Tag == tag then table.remove(espObjs, i) end end end
local function addEsp(obj, text, color, tag)
  local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"); if not hrp then return end
  local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 100, 0, 24); bb.AlwaysOnTop = true; bb.Adornee = hrp; bb.Parent = hrp
  local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Text = text; t.TextColor3 = color; t.TextStrokeTransparency = 0.4; t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.Parent = bb
  table.insert(espObjs, {Gui = bb, Tag = tag})
end
local function loopEsp(getOn, scan, tag, color) task.spawn(function() while getOn() do clearEsp(tag); for _, o in pairs(scan()) do pcall(function() addEsp(o, o.Name, color, tag) end) end; task.wait(1) end end) end
toggle(vp, "ESP Jogadores", function() return C.espPlayers end, function(v) C.espPlayers = v; if v then loopEsp(function() return C.espPlayers end, function() local t={}; for _,p in pairs(Players:GetPlayers()) do if p~=plr and p.Character then table.insert(t,p.Character) end end; return t end, "p", Color3.fromRGB(34,211,238)) else clearEsp("p") end end)
toggle(vp, "ESP Chests", function() return C.espChests end, function(v) C.espChests = v; if v then loopEsp(function() return C.espChests end, function() local t={}; for _,c in pairs(workspace:GetDescendants()) do if c:IsA("BasePart") and string.find(c.Name,"Chest") then table.insert(t,c) end end; return t end, "c", Color3.fromRGB(250,204,21)) else clearEsp("c") end end)
toggle(vp, "ESP Fruits", function() return C.espFruits end, function(v) C.espFruits = v; if v then loopEsp(function() return C.espFruits end, function() local t={}; for _,c in pairs(workspace:GetDescendants()) do if c:IsA("Tool") and c:FindFirstChild("Handle") then table.insert(t,c) end end; return t end, "f", Color3.fromRGB(239,68,68)) else clearEsp("f") end end)
toggle(vp, "ESP Bosses", function() return C.espBosses end, function(v) C.espBosses = v; if v then loopEsp(function() return C.espBosses end, function() local t={}; local e=workspace:FindFirstChild("Enemies"); if e then for _,m in pairs(e:GetChildren()) do local h=m:FindFirstChild("Humanoid"); if h and h.MaxHealth>=1000 then table.insert(t,m) end end end; return t end, "b", Color3.fromRGB(255,80,80)) else clearEsp("b") end end)
section(vp, "ambiente")
local orig = { b = Lighting.Brightness, a = Lighting.Ambient, o = Lighting.OutdoorAmbient, f = Lighting.FogEnd }
toggle(vp, "Fullbright", function() return C.fullbright end, function(v) C.fullbright = v; if v then Lighting.Brightness = 3; Lighting.Ambient = Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200); Lighting.FogEnd = 1e5 else Lighting.Brightness = orig.b; Lighting.Ambient = orig.a; Lighting.OutdoorAmbient = orig.o; Lighting.FogEnd = orig.f end end)

--==== STATS ====
local sp = page("Stats")
section(sp, "distribuicao")
dropdown(sp, "Atributo", {"Melee","Defense","Sword","Gun","Blox Fruit"}, function(v) C.statName = v end)
toggle(sp, "Auto Stats", function() return C.autostats end, function(v) C.autostats = v; if v then task.spawn(function() while C.autostats do invoke("AddPoint", C.statName, "1"); task.wait(0.3) end end) end end)
baseBtn(sp, "1 ponto manual", function() invoke("AddPoint", C.statName, "1") end)
section(sp, "haki")
toggle(sp, "Auto Buso", function() return C.buso end, function(v) C.buso = v; if v then task.spawn(function() while C.buso do invoke("Buso"); task.wait(1) end end) end end)
toggle(sp, "Auto Ken", function() return C.ken end, function(v) C.ken = v; if v then task.spawn(function() while C.ken do invoke("Ken"); task.wait(1) end end) end end)

--==== MISC ====
local mp = page("Misc")
section(mp, "fruta")
toggle(mp, "Fruit Sniper", function() return C.sniper end, function(v)
  C.sniper = v
  if v then task.spawn(function() while C.sniper do
    local name = C.sniperName
    if name ~= "" then for _, t in pairs(workspace:GetDescendants()) do if t:IsA("Tool") and t.Name:lower():find(name:lower()) then invoke("PurchaseRawFruit", t.Name); break end end end
    task.wait(1)
  end end) end
end)
local sniperBox = Instance.new("TextBox"); sniperBox.Size = UDim2.new(1, -8, 0, 28); sniperBox.Position = UDim2.new(0, 0, 0, nextY(mp))
sniperBox.BackgroundColor3 = Color3.fromRGB(16, 24, 32); sniperBox.PlaceholderText = "nome da fruta (ex: Dragon)"; sniperBox.Text = C.sniperName; sniperBox.TextColor3 = Color3.fromRGB(215, 230, 240); sniperBox.PlaceholderColor3 = Color3.fromRGB(80, 96, 110)
sniperBox.Font = Enum.Font.Gotham; sniperBox.TextSize = 12; sniperBox.Parent = mp; Instance.new("UICorner", sniperBox).CornerRadius = UDim.new(0, 6)
sniperBox:GetPropertyChangedSignal("Text"):Connect(function() C.sniperName = sniperBox.Text; saveCfg() end)
section(mp, "servidor")
baseBtn(mp, "Rejoin", function() pcall(function() TPS:Teleport(game.PlaceId, plr) end) end)
baseBtn(mp, "Server Hop", function() task.spawn(function() local ok2, r = pcall(function() return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")) end); if ok2 then for _, s in pairs(r.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then pcall(function() TPS:TeleportToPlaceInstance(game.PlaceId, s.id, plr) end); break end end end end) end)
baseBtn(mp, "Reset Character", function() if alive() then plr.Character:BreakJoints() end end)
toggle(mp, "Anti-AFK", function() return C.antiAfk end, function(v) C.antiAfk = v end)
plr.Idled:Connect(function() if C.antiAfk then pcall(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end end)
section(mp, "config")
baseBtn(mp, "Salvar config", function() saveCfg(); notify("Config salva") end)
baseBtn(mp, "Resetar config", function() C.speed = 16; C.jump = 50; C.npcFilter = ""; saveCfg(); notify("Resetada") end)

--==== status + busca ====
task.spawn(function() while gui.Parent do RunService.Heartbeat:Wait(); local dt = RunService.RenderStepped:Wait(); stxt.Text = string.format("fps %d | farm %s | aura %s", math.floor(1/math.max(dt,0.001)), C.farm and "on" or "off", C.aura and "on" or "off") end end)
search:GetPropertyChangedSignal("Text"):Connect(function() local q = search.Text:lower(); for _, p in pairs(pages) do for _, el in pairs(p:GetDescendants()) do if el:IsA("TextButton") then el.Visible = (q == "" or string.find(el.Text:lower(), q) ~= nil) end end end end)

showTab("Farm")
notify("Killua Hub v3.1 carregado")
