-- Полный скрипт телепорта и auto-телепорта с вкладками, speed для Evade и полоской скорости с индикатором

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("TeleportGui") then
  LocalPlayer.PlayerGui.TeleportGui:Destroy()
end

local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportGui"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 480)
frame.Position = UDim2.new(0, 50, 0, 100)
frame.BackgroundTransparency = 0.25
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local gradient = Instance.new("UIGradient", frame)
gradient.Rotation = 45
gradient.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 128)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 64, 0))
})

local tabHolder = Instance.new("Frame", frame)
tabHolder.Size = UDim2.new(1, 0, 0, 40)
tabHolder.Position = UDim2.new(0, 0, 0, 0)
tabHolder.BackgroundTransparency = 1

local function createTabButton(name, pos)
  local button = Instance.new("TextButton", tabHolder)
  button.Size = UDim2.new(0.5, -2, 1, 0)
  button.Position = UDim2.new(pos, pos == 0 and 0 or 2, 0, 0)
  button.Text = name
  button.Font = Enum.Font.GothamBold
  button.TextSize = 16
  button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
  button.TextColor3 = Color3.new(1, 1, 1)
  button.BorderSizePixel = 0
  local grad = Instance.new("UIGradient", button)
  grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
  })
  local corner = Instance.new("UICorner", button)
  corner.CornerRadius = UDim.new(0, 10)
  return button
end

local teleportTab = Instance.new("Frame", frame)
teleportTab.Position = UDim2.new(0, 0, 0, 40)
teleportTab.Size = UDim2.new(1, 0, 1, -40)
teleportTab.BackgroundTransparency = 1
teleportTab.Visible = true

local speedTab = Instance.new("Frame", frame)
speedTab.Position = UDim2.new(0, 0, 0, 40)
speedTab.Size = UDim2.new(1, 0, 1, -40)
speedTab.Visible = false
speedTab.BackgroundTransparency = 1

local tpButton = createTabButton("Телепорт", 0)
tpButton.MouseButton1Click:Connect(function()
  teleportTab.Visible = true
  speedTab.Visible = false
end)

local spdButton = createTabButton("Скорость", 0.5)
spdButton.MouseButton1Click:Connect(function()
  teleportTab.Visible = false
  speedTab.Visible = true
end)

-- === СКОРОСТЬ ===
local speedSlider = Instance.new("Frame", speedTab)
speedSlider.Size = UDim2.new(0.8, 0, 0, 25)
speedSlider.Position = UDim2.new(0.1, 0, 0, 60)
speedSlider.BackgroundTransparency = 0.3
speedSlider.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
local sliderCorner = Instance.new("UICorner", speedSlider)
sliderCorner.CornerRadius = UDim.new(0, 10)

local sliderBar = Instance.new("Frame", speedSlider)
sliderBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
sliderBar.Size = UDim2.new(0.3, 0, 1, 0)
sliderBar.Position = UDim2.new(0, 0, 0, 0)
local barCorner = Instance.new("UICorner", sliderBar)
barCorner.CornerRadius = UDim.new(0, 10)
sliderBar.Parent = speedSlider

local speedLabel = Instance.new("TextLabel", speedTab)
speedLabel.Position = UDim2.new(0.1, 0, 0, 30)
speedLabel.Size = UDim2.new(0.8, 0, 0, 30)
speedLabel.Text = "Скорость: 30"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 18

local dragging = false
local maxWalkSpeed = 100
local currentSpeed = 30

speedSlider.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)

speedSlider.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputChanged:Connect(function(input)
  if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
    local rel = input.Position.X - speedSlider.AbsolutePosition.X
    local pct = math.clamp(rel / speedSlider.AbsoluteSize.X, 0, 1)
    sliderBar.Size = UDim2.new(pct, 0, 1, 0)
    currentSpeed = math.floor(pct * maxWalkSpeed)
    speedLabel.Text = "Скорость: " .. currentSpeed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
    end
  end
end)

-- === ТЕЛЕПОРТ ===
local scroll = Instance.new("ScrollingFrame", teleportTab)
scroll.Position = UDim2.new(0, 10, 0, 10)
scroll.Size = UDim2.new(1, -20, 1, -20)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.Name
layout.Padding = UDim.new(0, 6)

local autoModes = {}

local function updatePlayers()
  for _, child in ipairs(scroll:GetChildren()) do
    if child:IsA("Frame") then child:Destroy() end
  end

  for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
      autoModes[player.Name] = autoModes[player.Name] or false
      local entry = Instance.new("Frame", scroll)
      entry.Size = UDim2.new(1, -10, 0, 40)
      entry.BackgroundTransparency = 1

      local tpButton = Instance.new("TextButton", entry)
      tpButton.Size = UDim2.new(0.6, -5, 1, 0)
      tpButton.Position = UDim2.new(0, 0, 0, 0)
      tpButton.Text = player.Name
      tpButton.Font = Enum.Font.GothamSemibold
      tpButton.TextSize = 16
      tpButton.TextColor3 = Color3.new(1, 1, 1)
      tpButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
      tpButton.BorderSizePixel = 0
      local btnGradient = Instance.new("UIGradient", tpButton)
      btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
      })
      local corner = Instance.new("UICorner", tpButton)
      corner.CornerRadius = UDim.new(0, 12)
      tpButton.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
          LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
      end)

      local autoButton = Instance.new("TextButton", entry)
      autoButton.Size = UDim2.new(0.4, -5, 1, 0)
      autoButton.Position = UDim2.new(0.6, 5, 0, 0)
      autoButton.Text = autoModes[player.Name] and "Auto (on)" or "Auto (off)"
      autoButton.Font = Enum.Font.Gotham
      autoButton.TextSize = 14
      autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
      autoButton.BackgroundColor3 = Color3.fromRGB(50, 100, 0)
      local abGrad = Instance.new("UIGradient", autoButton)
      abGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 255, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 0))
      })
      local abCorner = Instance.new("UICorner", autoButton)
      abCorner.CornerRadius = UDim.new(0, 12)

      autoButton.MouseButton1Click:Connect(function()
        autoModes[player.Name] = not autoModes[player.Name]
        autoButton.Text = autoModes[player.Name] and "Auto (on)" or "Auto (off)"
      end)
    end
  end
  scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(function(player)
  autoModes[player.Name] = autoModes[player.Name] or false
end)

Players.PlayerRemoving:Connect(function(player)
  autoModes[player.Name] = nil
end)

RunService.Heartbeat:Connect(function()
  for name, enabled in pairs(autoModes) do
    local player = Players:FindFirstChild(name)
    if enabled and player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
  end
end)

coroutine.wrap(function()
  while true do
    updatePlayers()
    task.wait(2)
  end
end)()

local visible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
  if gameProcessed then return end
  if input.KeyCode == Enum.KeyCode.LeftAlt then
    visible = not visible
    frame.Visible = visible
    UserInputService.MouseIconEnabled = visible
  end
end)

RunService.RenderStepped:Connect(function()
  if frame.Visible then
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
  else
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
  end
end)
