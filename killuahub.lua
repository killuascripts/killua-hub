--=====================================================
--  KILLUA HUB v4.1  |  mobile + PC  |  corrigido
--=====================================================
if _G.KilluaHub then pcall(function() _G.KilluaHub:Destroy() end) end
print("[Killua] carregando v4.1")

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TPS = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VU = game:GetService("VirtualUser")
local Tween = game:GetService("TweenService")
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
if hasFS then pcall(function() if isfile(CFG) then local d = Http:JSONDecode(readfile(CFG)); for k, v in pairs(d) do C[k] = v end end end) end
local function saveCfg() if hasFS then pcall(function() writefile(CFG, Http:JSONEncode(C)) end) end end

--================ HELPERS (todos antes da UI) ================
local function alive()
  local c = plr.Character
  local h = c and c:FindFirstChildOfClass("Humanoid")
  return c and c:FindFirstChild("HumanoidRootPart") and h and h.Health > 0
end
local function tp(p) if alive() then plr.Character.HumanoidRootPart.CFrame = CFrame.new(p) end end
local function notify(t) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Killua Hub", Text=t, Duration=2}) end) end
local function invoke(a, b, c2) pcall(function() RS.Remotes.CommF_:InvokeServer(a, b, c2) end) end
local function teleport(name, coord)
  if not alive() then return end
  local before = plr.Character.HumanoidRootPart.Position
  pcall(function() RS.Remotes.CommF_:InvokeServer("Teleport", name) end)
  task.delay(1.3, function()
    if alive() then local now = plr.Character.HumanoidRootPart.Position
      if (now - before).Magnitude < 8 and coord then plr.Character.HumanoidRootPart.CFrame = CFrame.new(coord) end end
  end)
end
local function equipWeapon(name)
  if not alive() or name == "" then return end
  for _, t in pairs(plr.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name == name then t.Parent = plr.Character; break end end
end
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
local questTable = {{1,"Bandit"},{15,"Monkey"},{30,"Brute"},{60,"Pirate"},{90,"Brute"},{120,"Brute"},{150,"Brute"},{200,"Brute"},{250,"Brute"},{300,"Brute"},{350,"Brute"},{400,"Brute"},{450,"Brute"},{500,"Brute"},{550,"Brute"},{600,"Brute"},{650,"Brute"},{700,"Brute"}}
local function pickQuest()
  local lvl = 1; pcall(function() lvl = plr.Data.Level.Value end)
  local pick = questTable[1]; for _, q in ipairs(questTable) do if lvl >= q[1] then pick = q end end; return pick
end
local enemyList, bossList, weaponList = {}, {}, {}
local function refreshEnemies()
  enemyList, bossList = {}, {}
  local e = workspace:FindFirstChild("Enemies")
  if e then for _, m in pairs(e:GetChildren()) do local h = m:FindFirstChild("Humanoid"); if h then table.insert(enemyList, m.Name); if h.MaxHealth >= 1000 then table.insert(bossList, m.Name) end end end end
end
local function refreshWeapons() weaponList = {}; for _, t in pairs(plr.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(weaponList, t.Name) end end end
local espObjs = {}
local function clearEsp(tag)
  for _, o in pairs(espObjs) do if o.Tag == tag then pcall(function() o.Gui:Destroy() end) end end
  for i = #espObjs, 1, -1 do if espObjs[i].Tag == tag then table.remove(espObjs, i) end end
end
local function addEsp(obj, color, tag)
  local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"); if not hrp then return end
  local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0,100,0,24); bb.AlwaysOnTop = true; bb.Adornee = hrp; bb.Parent = hrp
  local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Text = obj.Name
  t.TextColor3 = color; t.TextStrokeTransparency = 0.4; t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.Parent = bb
  table.insert(espObjs, {Gui = bb, Tag = tag})
end
local function espLoop(getOn, scan, tag, color)
  task.spawn(function() while getOn() do clearEsp(tag); for _, o in pairs(scan()) do pcall(function() addEsp(o, color, tag) end) end; task.wait(1) end end)
end

--================ PALETA ================
local P1 = Color3.fromRGB(124,58,237); local P2 = Color3.fromRGB(168,85,247)
local BG = Color3.fromRGB(14,8,22); local CARD = Color3.fromRGB(24,16,38); local CARD2 = Color3.fromRGB(32,22,50)
local TXT = Color3.fromRGB(235,228,245); local MUT = Color3.fromRGB(150,130,175)

--================ GUI ================
local gui = Instance.new("ScreenGui")
gui.Name = "KilluaHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.Parent = plr:WaitForChild("PlayerGui"); _G.KilluaHub = gui

local open = Instance.new("TextButton")
open.Size = UDim2.new(0,54,0,54); open.Position = UDim2.new(0,16,0,140)
open.BackgroundColor3 = P2; open.Text = "K"; open.TextColor3 = Color3.fromRGB(20,10,30)
open.Font = Enum.Font.GothamBlack; open.TextSize = 24; open.Parent = gui
Instance.new("UICorner", open).CornerRadius = UDim.new(0,14)
local og = Instance.new("UIGradient", open); og.Color = ColorSequence.new(P2, P1)

local win = Instance.new("Frame")
win.Size = UDim2.new(0,500,0,380); win.Position = UDim2.new(0.5,-250,0.5,-190)
win.BackgroundColor3 = BG; win.BorderSizePixel = 0; win.Active = true; win.Visible = false; win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0,16)
local ws = Instance.new("UIStroke", win); ws.Color = Color3.fromRGB(60,36,90); ws.Thickness = 1.5
do
  local drag, start, init = false, nil, nil
  win.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; start = i.Position; init = win.Position end end)
  win.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
  UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - start; win.Position = UDim2.new(init.X.Scale, init.X.Offset + d.X, init.Y.Scale, init.Y.Offset + d.Y) end end)
end
local header = Instance.new("Frame"); header.Size = UDim2.new(1,0,0,46); header.BackgroundColor3 = P1; header.BorderSizePixel = 0; header.Parent = win
Instance.new("UICorner", header).CornerRadius = UDim.new(0,16)
local hg = Instance.new("UIGradient", header); hg.Color = ColorSequence.new(P1, P2); hg.Rotation = 20
local hname = Instance.new("TextLabel"); hname.Size = UDim2.new(0,260,1,0); hname.Position = UDim2.new(0,16,0,0); hname.BackgroundTransparency = 1
hname.Text = "⌁ Killua Hub"; hname.TextColor3 = Color3.fromRGB(255,255,255); hname.Font = Enum.Font.GothamBlack; hname.TextSize = 17; hname.TextXAlignment = Enum.TextXAlignment.Left; hname.Parent = header
local hsub = Instance.new("TextLabel"); hsub.Size = UDim2.new(0,130,1,0); hsub.Position = UDim2.new(0,132,0,0); hsub.BackgroundTransparency = 1
hsub.Text = "• Blox Fruits"; hsub.TextColor3 = Color3.fromRGB(230,215,250); hsub.Font = Enum.Font.Gotham; hsub.TextSize = 12; hsub.TextXAlignment = Enum.TextXAlignment.Left; hsub.Parent = header
local function hb(txt,x,cb) local b=Instance.new("TextButton"); b.Size=UDim2.new(0,28,0,28); b.Position=UDim2.new(1,x,0,9); b.BackgroundTransparency=1; b.Text=txt; b.TextColor3=Color3.fromRGB(245,240,255); b.Font=Enum.Font.GothamBold; b.TextSize=16; b.Parent=header; b.MouseButton1Click:Connect(cb) end
hb("–",-72,function() win.Visible=false end)
hb("✕",-34,function() gui:Destroy(); _G.KilluaHub=nil end)
open.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)
if not mobile then UIS.InputBegan:Connect(function(k,g) if not g and k.KeyCode == Enum.KeyCode.RightShift then win.Visible = not win.Visible end end) end

local side = Instance.new("Frame"); side.Size = UDim2.new(0,132,1,-52); side.Position = UDim2.new(0,10,0,58); side.BackgroundTransparency = 1; side.Parent = win
local body = Instance.new("Frame"); body.Size = UDim2.new(1,-156,1,-66); body.Position = UDim2.new(0,146,0,58); body.BackgroundTransparency = 1; body.Parent = win
local status = Instance.new("Frame"); status.Size = UDim2.new(1,0,0,24); status.Position = UDim2.new(0,0,1,-24); status.BackgroundColor3 = Color3.fromRGB(10,6,16); status.BorderSizePixel = 0; status.Parent = win
local stxt = Instance.new("TextLabel"); stxt.Size = UDim2.new(1,-20,1,0); stxt.Position = UDim2.new(0,14,0,0); stxt.BackgroundTransparency = 1
stxt.TextColor3 = MUT; stxt.Font = Enum.Font.Gotham; stxt.TextSize = 10; stxt.TextXAlignment = Enum.TextXAlignment.Left; stxt.Text = "pronto"; stxt.Parent = status

local pages, buttons, Y = {}, {}, {}
local function page(name)
  local f = Instance.new("ScrollingFrame"); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; f.BorderSizePixel = 0
  f.ScrollBarThickness = 3; f.CanvasSize = UDim2.new(0,0,0,0); f.Visible = false; f.Parent = body; pages[name] = f; return f
end
local function showTab(n)
  for k,p in pairs(pages) do p.Visible = (k==n) end
  for k,b in pairs(buttons) do b.BackgroundColor3 = (k==n) and P1 or Color3.fromRGB(20,13,32); b.TextColor3 = (k==n) and Color3.fromRGB(255,255,255) or MUT; if b.Grad then b.Grad.Enabled = (k==n) end end
end
local function tab(icon, name, y)
  local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,34); b.Position = UDim2.new(0,0,0,y); b.BackgroundColor3 = Color3.fromRGB(20,13,32); b.Text = ""; b.AutoButtonColor = false; b.Parent = side
  Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
  local g = Instance.new("UIGradient", b); g.Color = ColorSequence.new(P1,P2); g.Enabled = false; b.Grad = g
  local ic = Instance.new("TextLabel"); ic.Size = UDim2.new(0,26,1,0); ic.Position = UDim2.new(0,8,0,0); ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextColor3 = TXT; ic.Font = Enum.Font.GothamBold; ic.TextSize = 15; ic.Parent = b
  local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1,-36,1,0); lb.Position = UDim2.new(0,34,0,0); lb.BackgroundTransparency = 1; lb.Text = name; lb.TextColor3 = MUT; lb.Font = Enum.Font.Gotham; lb.TextSize = 12; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Parent = b
  b.MouseButton1Click:Connect(function() showTab(name); lb.TextColor3 = Color3.fromRGB(255,255,255) end)
  buttons[name] = b
end
tab("⌂","Main",0); tab("✚","Farm",36); tab("☘","Sea Event",72); tab("≡","Quest",108)
tab("▮","Stats",144); tab("⌖","Teleport",180); tab("☠","Devil Fruit",216); tab("⛨","Shop",252); tab("⚙","Settings",288)

local function nextY(p,h) Y[p] = (Y[p] or 4); local v = Y[p]; Y[p] = v + (h or 34); p.CanvasSize = UDim2.new(0,0,0,Y[p]+10); return v end
local function section(p,txt)
  local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,20); l.Position = UDim2.new(0,4,0,nextY(p,22)); l.BackgroundTransparency = 1
  l.Text = txt; l.TextColor3 = P2; l.Font = Enum.Font.GothamBold; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = p
end
local function btn(p,txt,cb)
  local b = Instance.new("TextButton"); b.Size = UDim2.new(1,-8,0,30); b.Position = UDim2.new(0,0,0,nextY(p,34)); b.BackgroundColor3 = CARD; b.Text = txt; b.TextColor3 = TXT; b.Font = Enum.Font.Gotham; b.TextSize = 12; b.Parent = p
  Instance.new("UICorner", b).CornerRadius = UDim.new(0,7); b.MouseButton1Click:Connect(function() cb(b) end); return b
end
local function switch(p,txt,get,set)
  local row = Instance.new("Frame"); row.Size = UDim2.new(1,-8,0,40); row.Position = UDim2.new(0,0,0,nextY(p,44)); row.BackgroundColor3 = CARD; row.BorderSizePixel = 0; row.Parent = p
  Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
  local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,14,0,0); lbl.BackgroundTransparency = 1; lbl.Text = txt; lbl.TextColor3 = TXT; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
  local track = Instance.new("Frame"); track.Size = UDim2.new(0,44,0,22); track.Position = UDim2.new(1,-54,0.5,-11); track.BackgroundColor3 = CARD2; track.BorderSizePixel = 0; track.Parent = row
  Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
  local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,18,0,18); knob.Position = UDim2.new(0,2,0.5,-9); knob.BackgroundColor3 = Color3.fromRGB(240,235,250); knob.BorderSizePixel = 0; knob.Parent = track
  Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
  local function render(on)
    Tween:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = on and P2 or CARD2}):Play()
    Tween:Create(knob, TweenInfo.new(0.15), {Position = on and UDim2.new(0,24,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
  end
  local function flip() set(not get()); render(get()); saveCfg() end
  track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then flip() end end)
  row.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then flip() end end)
  render(get())
end
local function slider(p,txt,min,max,get,set)
  local wrap = Instance.new("Frame"); wrap.Size = UDim2.new(1,-8,0,44); wrap.Position = UDim2.new(0,0,0,nextY(p,48)); wrap.BackgroundColor3 = CARD; wrap.BorderSizePixel = 0; wrap.Parent = p
  Instance.new("UICorner", wrap).CornerRadius = UDim.new(0,8)
  local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-16,0,18); lbl.Position = UDim2.new(0,10,0,4); lbl.BackgroundTransparency = 1; lbl.Text = txt..": "..get(); lbl.TextColor3 = TXT; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = wrap
  local bar = Instance.new("Frame"); bar.Size = UDim2.new(1,-20,0,8); bar.Position = UDim2.new(0,10,0,27); bar.BackgroundColor3 = CARD2; bar.BorderSizePixel = 0; bar.Parent = wrap
  Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)
  local fill = Instance.new("Frame"); fill.Size = UDim2.new((get()-min)/(max-min),0,1,0); fill.BackgroundColor3 = P2; fill.BorderSizePixel = 0; fill.Parent = bar; Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
  local dragging = false
  local function upd(x) local rel = math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); local val = math.floor(min+(max-min)*rel); fill.Size = UDim2.new(rel,0,1,0); lbl.Text = txt..": "..val; set(val) end
  bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; upd(i.Position.X) end end)
  UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
  UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
end
local function dropdown(p,txt,list,getList,cb)
  btn(p, txt.." ▾", function(self)
    if self.Expanded then for _, c in pairs(p:GetChildren()) do if c:GetAttribute("dd") then c:Destroy() end end; self.Expanded = false; return end
    self.Expanded = true; local y = 0
    for _, item in ipairs(getList()) do
      local o = Instance.new("TextButton"); o.Size = UDim2.new(1,-8,0,26); o.Position = UDim2.new(0,4,0,self.AbsolutePosition.Y - p.AbsolutePosition.Y + self.AbsoluteSize.Y + y)
      o.BackgroundColor3 = CARD2; o.Text = item; o.TextColor3 = TXT; o.Font = Enum.Font.Gotham; o.TextSize = 11; o.Parent = p; o:SetAttribute("dd", true)
      Instance.new("UICorner", o).CornerRadius = UDim.new(0,5)
      o.MouseButton1Click:Connect(function() cb(item); self.Text = txt..": "..item; for _, c in pairs(p:GetChildren()) do if c:GetAttribute("dd") then c:Destroy() end end; self.Expanded = false end)
      y += 28
    end
  end)
end

--================ MAIN ================
local mp = page("Main")
section(mp, "Main")
switch(mp, "Auto Farm Level", function() return C.farmLevel end, function(v) C.farmLevel = v; if v then task.spawn(function() while C.farmLevel do doAttack(C.npcFilter,false); task.wait(0.25) end end) end end)
switch(mp, "Auto Farm Mastery", function() return C.farmMastery end, function(v) C.farmMastery = v; if v then task.spawn(function() while C.farmMastery do doAttack(C.npcFilter,false); task.wait(0.25) end end) end end)
switch(mp, "Auto Farm Money", function() return C.farmMoney end, function(v) C.farmMoney = v; if v then task.spawn(function() while C.farmMoney do doAttack(C.npcFilter,false); task.wait(0.25) end end) end end)
switch(mp, "Auto Farm Boss", function() return C.farmBoss end, function(v) C.farmBoss = v; if v then task.spawn(function() while C.farmBoss do if C.bossFilter == "" then task.wait(0.5) else doAttack(C.bossFilter,true) end; task.wait(0.3) end end) end end)
switch(mp, "Auto Quest", function() return C.autoquest end, function(v) C.autoquest = v; if v then task.spawn(function() while C.autoquest do local q = pickQuest(); invoke("StartQuest", q[2], q[1]); task.wait(2) end end) end end)
switch(mp, "Auto Haki", function() return C.buso end, function(v) C.buso = v; if v then task.spawn(function() while C.buso do invoke("Buso"); task.wait(1) end end) end end)
switch(mp, "Auto Raid", function() return C.autorad end, function(v) C.autorad = v; if v then task.spawn(function() while C.autorad do invoke("Raids","1"); task.wait(6) end end) end end)
switch(mp, "Bring Mob", function() return C.bring end, function(v) C.bring = v; if v then task.spawn(function() while C.bring do if alive() then local e = workspace:FindFirstChild("Enemies"); if e then for _, m in pairs(e:GetChildren()) do local h = m:FindFirstChild("HumanoidRootPart"); if h then h.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-8,8),0,math.random(-8,8)) end end end end; task.wait(0.4) end end) end end)
btn(mp, "Select Weapon ▾", function(self)
  refreshWeapons()
  if self.Expanded then for _, c in pairs(mp:GetChildren()) do if c:GetAttribute("dd") then c:Destroy() end end; self.Expanded = false; return end
  self.Expanded = true; local y = 0
  for _, w in ipairs(weaponList) do
    local o = Instance.new("TextButton"); o.Size = UDim2.new(1,-8,0,26); o.Position = UDim2.new(0,4,0,self.AbsolutePosition.Y - mp.AbsolutePosition.Y + self.AbsoluteSize.Y + y)
    o.BackgroundColor3 = CARD2; o.Text = w; o.TextColor3 = TXT; o.Font = Enum.Font.Gotham; o.TextSize = 11; o.Parent = mp; o:SetAttribute("dd", true)
    Instance.new("UICorner", o).CornerRadius = UDim.new(0,5)
    o.MouseButton1Click:Connect(function() C.weapon = w; equipWeapon(w); self.Text = "Select Weapon: "..w; for _, c in pairs(mp:GetChildren()) do if c:GetAttribute("dd") then c:Destroy() end end; self.Expanded = false end)
    y += 28
  end
end)

--================ FARM ================
local fp = page("Farm")
section(fp, "Farm")
switch(fp, "Kill Aura", function() return C.aura end, function(v)
  C.aura = v
  if v then task.spawn(function() while C.aura do if alive() then
    local tool = plr.Character:FindFirstChildOfClass("Tool"); local e = workspace:FindFirstChild("Enemies")
    if tool and tool:FindFirstChild("Handle") and e then for _, m in pairs(e:GetChildren()) do local h = m:FindFirstChild("HumanoidRootPart")
      if h and m:FindFirstChild("Humanoid").Health > 0 and (h.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 45 then pcall(function() firetouchinterest(tool.Handle,h,0); task.wait(); firetouchinterest(tool.Handle,h,1) end) end end end
  end task.wait(0.15) end end) end
end)
switch(fp, "Chest Farm", function() return C.chestFarm end, function(v) C.chestFarm = v; if v then task.spawn(function() while C.chestFarm do if alive() then for _, c in pairs(workspace:GetDescendants()) do if c:IsA("BasePart") and string.find(c.Name,"Chest") and (c.Position-plr.Character.HumanoidRootPart.Position).Magnitude < 400 then tp(c.Position); task.wait(0.35) end end end; task.wait(0.4) end end) end end)
switch(fp, "Fruit Farm", function() return C.fruitFarm end, function(v) C.fruitFarm = v; if v then task.spawn(function() while C.fruitFarm do if alive() then for _, t in pairs(workspace:GetDescendants()) do if t:IsA("Tool") and t:FindFirstChild("Handle") then tp(t.Handle.Position); pcall(function() firetouchinterest(plr.Character.HumanoidRootPart,t.Handle,0); task.wait(); firetouchinterest(plr.Character.HumanoidRootPart,t.Handle,1) end); task.wait(0.3) end end end; task.wait(0.4) end end) end end)
section(fp, "alvo")
dropdown(fp, "NPC", enemyList, function() return enemyList end, function(v) C.npcFilter = v end)
btn(fp, "Limpar filtro", function() C.npcFilter = "" end)
section(fp, "boss")
dropdown(fp, "Boss", bossList, function() return bossList end, function(v) C.bossFilter = v end)
btn(fp, "Atualizar listas", function() refreshEnemies(); notify("Listas atualizadas") end)

--================ SEA EVENT ================
local se = page("Sea Event")
section(se, "eventos")
switch(se, "Auto Sea Beast", function() return C.seaBeast or false end, function(v) C.seaBeast = v; if v then task.spawn(function() while C.seaBeast do if alive() then doAttack("Sea Beast",true) end; task.wait(0.5) end end) end end)
switch(se, "Auto Chest Event", function() return C.eventChest or false end, function(v) C.eventChest = v; if v then task.spawn(function() while C.eventChest do if alive() then for _, c in pairs(workspace:GetDescendants()) do if c:IsA("BasePart") and (c.Name:find("Chest") or c.Name:find("Present")) then tp(c.Position); task.wait(0.3) end end end; task.wait(0.4) end end) end end)
btn(se, "TP Kitsune Island", function() teleport("Kitsune Island", Vector3.new(-2000,30,9000)) end)
btn(se, "TP Sea of Treats", function() teleport("Sea of Treats", Vector3.new(3500,30,2000)) end)
btn(se, "TP Tiki Outpost", function() teleport("Tiki Outpost", Vector3.new(-1000,20,7000)) end)

--================ QUEST ================
local qp = page("Quest")
section(qp, "Quest")
switch(qp, "Auto Quest", function() return C.autoquest end, function(v) C.autoquest = v; if v then task.spawn(function() while C.autoquest do local q = pickQuest(); invoke("StartQuest", q[2], q[1]); task.wait(2) end end) end end)
btn(qp, "Entregar quest", function() invoke("CompleteQuest") end)
btn(qp, "Reroll quest", function() invoke("BlackbeardReward","Reroll","1") end)
section(qp, "Raid")
btn(qp, "Iniciar raid", function() invoke("Raids","1") end)
btn(qp, "Status da raid", function() invoke("Raids","0") end)

--================ STATS ================
local stp = page("Stats")
section(stp, "Stats")
dropdown(stp, "Atributo", {"Melee","Defense","Sword","Gun","Blox Fruit"}, function() return {"Melee","Defense","Sword","Gun","Blox Fruit"} end, function(v) C.statName = v end)
switch(stp, "Auto Stats", function() return C.autostats end, function(v) C.autostats = v; if v then task.spawn(function() while C.autostats do invoke("AddPoint",C.statName,"1"); task.wait(0.3) end end) end end)
btn(stp, "1 ponto manual", function() invoke("AddPoint",C.statName,"1") end)
section(stp, "Haki")
switch(stp, "Auto Buso", function() return C.buso end, function(v) C.buso = v; if v then task.spawn(function() while C.buso do invoke("Buso"); task.wait(1) end end) end end)
switch(stp, "Auto Ken", function() return C.ken end, function(v) C.ken = v; if v then task.spawn(function() while C.ken do invoke("Ken"); task.wait(1) end end) end end)

--================ TELEPORT ================
local tpP = page("Teleport"); tpP.CanvasSize = UDim2.new(0,0,0,0)
local subBar = Instance.new("Frame"); subBar.Size = UDim2.new(1,0,0,26); subBar.BackgroundTransparency = 1; subBar.Parent = tpP
local seaData = {
  ["Sea 1"] = {{"Bandits",Vector3.new(-1300,12,4600)},{"Marines",Vector3.new(0,30,1000)},{"Jungle",Vector3.new(-1200,20,-300)},{"Desert",Vector3.new(1000,20,2000)},{"Snow Island",Vector3.new(1200,50,-1300)},{"Sky",Vector3.new(-4700,600,-1300)},{"Underwater City",Vector3.new(-4700,500,2000)},{"Fountain City",Vector3.new(500,50,-3500)},{"Pirate Village",Vector3.new(900,50,-1500)},{"Marine Fortress",Vector3.new(-3000,20,2500)},{"Prison",Vector3.new(-2000,20,1000)},{"Magma Village",Vector3.new(-4700,30,3000)},{"Colosseum",Vector3.new(-1500,30,-3000)},{"Frozen Village",Vector3.new(-4700,700,-3200)}},
  ["Sea 2"] = {{"Kingdom of Rose",Vector3.new(1000,50,1000)},{"Green Zone",Vector3.new(1500,50,-1000)},{"Graveyard",Vector3.new(2000,50,500)},{"Dark Arena",Vector3.new(2500,50,0)},{"Snow Mountain",Vector3.new(1500,50,-2000)},{"Ice Castle",Vector3.new(2000,100,-3000)},{"Cursed Ship",Vector3.new(900,20,-4000)},{"Haunted Castle",Vector3.new(1200,50,-3000)},{"Barren Island",Vector3.new(2500,50,-1000)},{"Middle Town",Vector3.new(1000,50,500)},{"Mansion",Vector3.new(2000,50,-2000)},{"Upper Sky",Vector3.new(1500,600,1000)},{"Forgotten Island",Vector3.new(3000,50,2000)},{"Musketeer Island",Vector3.new(3500,50,3000)},{"Bounty Island",Vector3.new(2500,50,3000)}},
  ["Sea 3"] = {{"Port Town",Vector3.new(-500,20,5000)},{"Hydra Island",Vector3.new(1000,30,6000)},{"Great Tree",Vector3.new(2500,50,5000)},{"Castle on the Sea",Vector3.new(3000,50,3000)},{"Haunted Castle",Vector3.new(2000,50,4000)},{"Sea of Treats",Vector3.new(3500,30,2000)},{"Tiki Outpost",Vector3.new(-1000,20,7000)},{"Kitsune Island",Vector3.new(-2000,30,9000)},{"Floating Turtle",Vector3.new(4000,100,4000)},{"Sunken City",Vector3.new(4500,-100,3000)},{"Temple of Time",Vector3.new(5000,50,2000)}},
}
local seaFrames, seaBtns = {}, {}
local function showSea(n) for k,f in pairs(seaFrames) do f.Visible = (k==n) end; for k,b in pairs(seaBtns) do b.BackgroundColor3 = (k==n) and P1 or CARD; b.TextColor3 = (k==n) and Color3.fromRGB(255,255,255) or MUT end end
for i,n in ipairs({"Sea 1","Sea 2","Sea 3"}) do
  local sb = Instance.new("TextButton"); sb.Size = UDim2.new(0,90,0,24); sb.Position = UDim2.new(0,(i-1)*94,0,0); sb.BackgroundColor3 = CARD; sb.Text = n; sb.TextColor3 = MUT; sb.Font = Enum.Font.GothamBold; sb.TextSize = 11; sb.Parent = subBar
  Instance.new("UICorner", sb).CornerRadius = UDim.new(0,6); sb.MouseButton1Click:Connect(function() showSea(n) end); seaBtns[n] = sb
  local f = Instance.new("ScrollingFrame"); f.Size = UDim2.new(1,0,0,250); f.Position = UDim2.new(0,0,0,30); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ScrollBarThickness = 3
  f.CanvasSize = UDim2.new(0,0,0,(#seaData[n])*34+10); f.Visible = false; f.Parent = tpP; seaFrames[n] = f
  for j,isl in ipairs(seaData[n]) do
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1,-8,0,28); b.Position = UDim2.new(0,0,0,(j-1)*34); b.BackgroundColor3 = CARD; b.Text = isl[1]; b.TextColor3 = TXT; b.Font = Enum.Font.Gotham; b.TextSize = 12; b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6); b.MouseButton1Click:Connect(function() teleport(isl[1], isl[2]) end)
  end
end
showSea("Sea 1")

--================ DEVIL FRUIT ================
local dfp = page("Devil Fruit")
section(dfp, "Devil Fruit")
switch(dfp, "Fruit Sniper", function() return C.sniper end, function(v) C.sniper = v; if v then task.spawn(function() while C.sniper do local name = C.sniperName; if name ~= "" then for _, t in pairs(workspace:GetDescendants()) do if t:IsA("Tool") and t.Name:lower():find(name:lower()) then invoke("PurchaseRawFruit", t.Name); break end end end; task.wait(1) end end) end end)
local box = Instance.new("TextBox"); box.Size = UDim2.new(1,-8,0,30); box.Position = UDim2.new(0,0,0,nextY(dfp,34))
box.BackgroundColor3 = CARD; box.PlaceholderText = "nome da fruta (ex: Dragon)"; box.Text = C.sniperName; box.TextColor3 = TXT; box.PlaceholderColor3 = MUT; box.Font = Enum.Font.Gotham; box.TextSize = 12; box.Parent = dfp
Instance.new("UICorner", box).CornerRadius = UDim.new(0,7); box:GetPropertyChangedSignal("Text"):Connect(function() C.sniperName = box.Text; saveCfg() end)
btn(dfp, "Comprar fruta aleatoria", function() invoke("Cousin","Buy") end)
btn(dfp, "TP Blox Fruit Dealer", function() teleport("Fountain City", Vector3.new(500,50,-3500)) end)

--================ SHOP ================
local shp = page("Shop")
section(shp, "Shop")
btn(shp, "Comprar Sword (random)", function() invoke("BuySword") end)
btn(shp, "Comprar Gun (random)", function() invoke("BuyGun") end)
btn(shp, "Comprar Haki (Buso)", function() invoke("BuyHaki","Buso") end)
btn(shp, "Comprar Haki (Ken)", function() invoke("BuyHaki","Ken") end)
btn(shp, "Comprar estilo de luta", function() invoke("BuyStyle") end)

--================ SETTINGS ================
local setp = page("Settings")
section(setp, "movimento")
slider(setp, "Speed", 16, 400, function() return C.speed end, function(v) C.speed = v; if alive() then plr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end; saveCfg() end)
slider(setp, "Jump", 50, 300, function() return C.jump end, function(v) C.jump = v; if alive() then plr.Character:FindFirstChildOfClass("Humanoid").JumpPower = v end; saveCfg() end)
section(setp, "visual")
switch(setp, "ESP Jogadores", function() return C.espPlayers end, function(v) C.espPlayers = v; if v then espLoop(function() return C.espPlayers end, function() local t={}; for _,p in pairs(Players:GetPlayers()) do if p~=plr and p.Character then table.insert(t,p.Character) end end; return t end, "p", P2) else clearEsp("p") end end)
switch(setp, "ESP Baús", function() return C.espChests end, function(v) C.espChests = v; if v then espLoop(function() return C.espChests end, function() local t={}; for _,c in pairs(workspace:GetDescendants()) do if c:IsA("BasePart") and string.find(c.Name,"Chest") then table.insert(t,c) end end; return t end, "c", Color3.fromRGB(250,204,21)) else clearEsp("c") end end)
switch(setp, "ESP Frutas", function() return C.espFruits end, function(v) C.espFruits = v; if v then espLoop(function() return C.espFruits end, function() local t={}; for _,c in pairs(workspace:GetDescendants()) do if c:IsA("Tool") and c:FindFirstChild("Handle") then table.insert(t,c) end end; return t end, "f", Color3.fromRGB(239,68,68)) else clearEsp("f") end end)
section(setp, "servidor")
btn(setp, "Rejoin", function() pcall(function() TPS:Teleport(game.PlaceId, plr) end) end)
btn(setp, "Server Hop", function() task.spawn(function() local o,r = pcall(function() return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")) end); if o then for _, s in pairs(r.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then pcall(function() TPS:TeleportToPlaceInstance(game.PlaceId,s.id,plr) end); break end end end end) end)
btn(setp, "Reset Character", function() if alive() then plr.Character:BreakJoints() end end)
switch(setp, "Anti-AFK", function() return C.antiAfk end, function(v) C.antiAfk = v end)
plr.Idled:Connect(function() if C.antiAfk then pcall(function() VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end end)
section(setp, "config")
btn(setp, "Salvar config", function() saveCfg(); notify("Config salva") end)
btn(setp, "Resetar config", function() C.speed = 16; C.jump = 50; C.npcFilter = ""; saveCfg(); notify("Resetada") end)

--================ STATUS / INIT ================
task.spawn(function() while gui.Parent do RunService.Heartbeat:Wait(); local dt = RunService.RenderStepped:Wait(); stxt.Text = string.format("fps %d | level %s | quest %s", math.floor(1/math.max(dt,0.001)), C.farmLevel and "on" or "off", C.autoquest and "on" or "off") end end)
refreshEnemies()
showTab("Main")
notify("Killua Hub v4.1 carregado")
print("[Killua] v4.1 carregado com sucesso")
