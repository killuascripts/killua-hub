--=====================================================
--  KILLUA HUB v2.0  |  professional build
--  executor: firetouchinterest / getconnections / Drawing
--=====================================================
if _G.KilluaHub then pcall(function() _G.KilluaHub:Destroy() end) end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TPS = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local plr = Players.LocalPlayer

--==== config persist ====
local CFG = "killuahub_config.json"
local C = {
  speed = 16, jump = 50,
  farm = false, aura = false, bring = false, autoquest = false,
  espPlayers = false, espChests = false, espFruits = false, espBosses = false,
  npcFilter = "",
}
if pcall(function() return readfile end) and isfile(CFG) then
  pcall(function() local d = Http:JSONDecode(readfile(CFG)); for k, v in pairs(d) do C[k] = v end end)
end
local function saveCfg() pcall(function() writefile(CFG, Http:JSONEncode(C)) end) end

local function alive()
  local c = plr.Character
  return c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid") and c:FindFirstChildOfClass("Humanoid").Health > 0
end
local function tp(p) if alive() then plr.Character.HumanoidRootPart.CFrame = CFrame.new(p) end end
local function notify(t) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Killua Hub", Text = t, Duration = 2 }) end) end

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
win.Size = UDim2.new(0, 440, 0, 300); win.Position = UDim2.new(0.5, -220, 0.5, -150)
win.BackgroundColor3 = Color3.fromRGB(10, 14, 20); win.BorderSizePixel = 0
win.Active = true; win.Draggable = true; win.Visible = false; win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", win); stroke.Color = Color3.fromRGB(24, 40, 52); stroke.Thickness = 1

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44); header.BackgroundColor3 = Color3.fromRGB(12, 18, 26)
header.BorderSizePixel = 0; header.Parent = win
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 120, 1, 0); logo.Position = UDim2.new(0, 14, 0, 0)
logo.BackgroundTransparency = 1; logo.Text = "KILLUA HUB"
logo.TextColor3 = Color3.fromRGB(34, 211, 238); logo.Font = Enum.Font.GothamBlack
logo.TextSize = 15; logo.TextXAlignment = Enum.TextXAlignment.Left; logo.Parent = header

local ver = Instance.new("TextLabel")
ver.Size = UDim2.new(0, 60, 1, 0); ver.Position = UDim2.new(0, 128, 0, 0)
ver.BackgroundTransparency = 1; ver.Text = "v2.0"; ver.TextColor3 = Color3.fromRGB(80, 96, 110)
ver.Font = Enum.Font.Gotham; ver.TextSize = 11; ver.TextXAlignment = Enum.TextXAlignment.Left; ver.Parent = header

local function hdrBtn(txt, x, cb)
  local b = Instance.new("TextButton")
  b.Size = UDim2.new(0, 30, 0, 30); b.Position = UDim2.new(1, x, 0, 7)
  b.BackgroundColor3 = Color3.fromRGB(20, 30, 40); b.Text = txt
  b.TextColor3 = Color3.fromRGB(200, 220, 235); b.Font = Enum.Font.GothamBold; b.TextSize = 14
  b.Parent = header; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
  b.MouseButton1Click:Connect(function() cb(b) end)
end
hdrBtn("_", -76, function() win.Visible = false end)
hdrBtn("X", -40, function() gui:Destroy(); _G.KilluaHub = nil end)
open.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)
UIS.InputBegan:Connect(function(k, g) if not g and k.KeyCode == Enum.KeyCode.RightShift then win.Visible = not win.Visible end end)

-- busca
local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -28, 0, 30); search.Position = UDim2.new(0, 14, 0, 52)
search.BackgroundColor3 = Color3.fromRGB(16, 24, 32); search.PlaceholderText = "buscar função..."
search.Text = ""; search.TextColor3 = Color3.fromRGB(220, 235, 245)
search.PlaceholderColor3 = Color3.fromRGB(80, 96, 110); search.Font = Enum.Font.Gotham; search.TextSize = 12
search.ClearTextOnFocus = false; search.Parent = win
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 8)

-- sidebar
local side = Instance.new("Frame")
side.Size = UDim2.new(0, 108, 1, -132); side.Position = UDim2.new(0, 14, 0, 90)
side.BackgroundTransparency = 1; side.Parent = win

local pagesWrap = Instance.new("Frame")
pagesWrap.Size = UDim2.new(1, -140, 1, -132); pagesWrap.Position = UDim2.new(0, 126, 0, 90)
pagesWrap.BackgroundTransparency = 1; pagesWrap.Parent = win

local status = Instance.new("Frame")
status.Size = UDim2.new(1, 0, 0, 26); status.Position = UDim2.new(0, 0, 1, -26)
status.BackgroundColor3 = Color3.fromRGB(12, 18, 26); status.BorderSizePixel = 0; status.Parent = win
local stxt = Instance.new("TextLabel")
stxt.Size = UDim2.new(1, -20, 1, 0); stxt.Position = UDim2.new(0, 14, 0, 0)
stxt.BackgroundTransparency = 1; stxt.TextColor3 = Color3.fromRGB(90, 108, 124)
stxt.Font = Enum.Font.Gotham; stxt.TextSize = 10; stxt.TextXAlignment = Enum.TextXAlignment.
