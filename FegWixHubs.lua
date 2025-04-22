local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FakeCrash"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "🛠️ ROBLOX CRITICAL ERROR\\nPlease restart your client..."
label.TextColor3 = Color3.new(1, 0, 0)
label.TextScaled = true
label.Font = Enum.Font.Code
label.BackgroundTransparency = 1

local sound = Instance.new("Sound", game.Workspace)
sound.SoundId = "rbxassetid://9118823102"
sound.Volume = 1
sound:Play()
