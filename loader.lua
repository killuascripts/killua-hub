if _G._KilluaLoader then return end
_G._KilluaLoader = true
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
repeat task.wait() until game:IsLoaded() and Players.LocalPlayer
local plr = Players.LocalPlayer

--================ CONFIG ================
local HUB    = "https://raw.githubusercontent.com/killuascripts/killua-hub/refs/heads/main/killuahub.lua"
local LOGO   = ""
local WALL   = "rbxassetid://16073585738"
local TITLE  = "KILLUA HUB"
local ACCENT = Color3.fromRGB(124,58,237)
local BG     = Color3.fromRGB(16,10,24)
--========================================

local TI = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
local gui = Instance.new("ScreenGui")
gui.Name = "KilluaLoader"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9999
gui.Parent = plr:WaitForChild("PlayerGui")

local intro = Instance.new("CanvasGroup")
intro.Size = UDim2.new(0,430,0,250); intro.Position = UDim2.new(0.5,0,0.5,0); intro.AnchorPoint = Vector2.new(0.5,0.5)
intro.BackgroundColor3 = BG; intro.BorderSizePixel = 0; intro.GroupTransparency = 1; intro.Parent = gui
Instance.new("UICorner", intro).CornerRadius = UDim.new(0,20)
local is = Instance.new("UIStroke", intro); is.Color = ACCENT; is.Thickness = 1.5
local wall = Instance.new("ImageLabel"); wall.Size = UDim2.new(1,0,1,0); wall.BackgroundTransparency = 1; wall.ScaleType = Enum.ScaleType.Crop; wall.Image = WALL; wall.ImageTransparency = 0.55; wall.Parent = intro
Instance.new("UICorner", wall).CornerRadius = UDim.new(0,20)
if LOGO ~= "" then
  local logo = Instance.new("ImageLabel"); logo.Size = UDim2.new(0,140,0,140); logo.Position = UDim2.new(0.5,-70,0,22); logo.BackgroundTransparency = 1; logo.Image = LOGO; logo.ScaleType = Enum.ScaleType.Fit; logo.Parent = intro
else
  local bolt = Instance.new("TextLabel"); bolt.Size = UDim2.new(1,0,0,110); bolt.Position = UDim2.new(0,0,0,30); bolt.BackgroundTransparency = 1; bolt.Text = "⚡"; bolt.TextColor3 = ACCENT; bolt.Font = Enum.Font.GothamBlack; bolt.TextSize = 80; bolt.Parent = intro
end
local name = Instance.new("TextLabel"); name.Size = UDim2.new(1,0,0,26); name.Position = UDim2.new(0,0,0,166); name.BackgroundTransparency = 1; name.Text = TITLE; name.TextColor3 = Color3.fromRGB(210,180,255); name.Font = Enum.Font.GothamBlack; name.TextSize = 19; name.Parent = intro
local status = Instance.new("TextLabel"); status.Size = UDim2.new(1,-40,0,18); status.Position = UDim2.new(0,20,0,194); status.BackgroundTransparency = 1; status.Text = "Preparando..."; status.TextColor3 = Color3.fromRGB(160,140,185); status.Font = Enum.Font.Gotham; status.TextSize = 12; status.Parent = intro
local track = Instance.new("Frame"); track.Size = UDim2.new(1,-40,0,8); track.Position = UDim2.new(0,20,0,220); track.BackgroundColor3 = Color3.fromRGB(40,28,60); track.BorderSizePixel = 0; track.Parent = intro
Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
local fill = Instance.new("Frame"); fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = ACCENT; fill.BorderSizePixel = 0; fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
local fg = Instance.new("UIGradient", fill); fg.Color = ColorSequence.new(ACCENT, Color3.fromRGB(34,211,238))
local skip = Instance.new("TextButton"); skip.Size = UDim2.new(1,-40,0,16); skip.Position = UDim2.new(0,20,0,230); skip.BackgroundTransparency = 1; skip.Text = "clique para pular"; skip.TextColor3 = Color3.fromRGB(110,95,135); skip.Font = Enum.Font.Gotham; skip.TextSize = 10; skip.Parent = intro

local loaded = false
local function launch()
  if loaded then return end
  loaded = true
  TweenService:Create(intro, TI, {GroupTransparency = 1}):Play()
  task.delay(0.25, function() gui:Destroy(); _G._KilluaLoader = nil end)
  task.wait(0.2)
  local okGet, src = pcall(function() return game:HttpGet(HUB) end)
  if not okGet or type(src) ~= "string" or #src < 20 then
    warn("[Killua] falha no HttpGet:", src); return
  end
  local fn, err = loadstring(src)
  if not fn then warn("[Killua] erro de sintaxe:", err); return end
  local okRun, err2 = pcall(fn)
  if not okRun then warn("[Killua] erro ao executar:", err2) end
end
intro.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then launch() end end)

task.spawn(function()
  pcall(function() ContentProvider:PreloadAsync({ wall }) end)
  TweenService:Create(intro, TI, {GroupTransparency = 0}):Play()
  task.wait(0.5)
  for i = 1, 100 do
    status.Text = (i < 40 and "Carregando assets...") or (i < 80 and "Aplicando interface...") or "Finalizando..."
    TweenService:Create(fill, TweenInfo.new(0.08), {Size = UDim2.new(i/100,0,1,0)}):Play()
    task.wait(math.random(6,14)/1000 + 0.008)
  end
  status.Text = "Pronto!"
  task.wait(0.3)
  launch()
end)
