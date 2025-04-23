
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")


local Blur = Instance.new("BlurEffect")
Blur.Size = 12
Blur.Enabled = false
Blur.Parent = Lighting

local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "FegWixHub"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 350, 0, 230)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -115)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Text = "spermadlc FegWix"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local toggleButton = Instance.new("TextButton", mainFrame)
toggleButton.Size = UDim2.new(1, -40, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 50)
toggleButton.Text = "Noclip: OFF"
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextScaled = true
Instance.new("UICorner", toggleButton)

local setGuiKey = Instance.new("TextButton", mainFrame)
setGuiKey.Size = UDim2.new(1, -40, 0, 30)
setGuiKey.Position = UDim2.new(0, 20, 0, 100)
setGuiKey.Text = "Set GUI Toggle Key"
setGuiKey.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
setGuiKey.TextColor3 = Color3.new(1, 1, 1)
setGuiKey.Font = Enum.Font.Gotham
setGuiKey.TextScaled = true
Instance.new("UICorner", setGuiKey)

local setNoclipKey = Instance.new("TextButton", mainFrame)
setNoclipKey.Size = UDim2.new(1, -40, 0, 30)
setNoclipKey.Position = UDim2.new(0, 20, 0, 140)
setNoclipKey.Text = "Set Noclip Toggle Key"
setNoclipKey.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
setNoclipKey.TextColor3 = Color3.new(1, 1, 1)
setNoclipKey.Font = Enum.Font.Gotham
setNoclipKey.TextScaled = true
Instance.new("UICorner", setNoclipKey)


local noclip = false
local noclipConnection = nil
local waitingForKey = nil
local guiToggleKey = nil
local noclipToggleKey = nil


local function setNoclip(state)
    if state and not noclip then

        noclip = true
        toggleButton.Text = "Noclip: ON"
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RS.Stepped:Connect(function()
            local char = Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif not state and noclip then

        noclip = false
        toggleButton.Text = "Noclip: OFF"
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
    
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 0.1, 0))
                task.wait()
                hrp.CFrame = CFrame.new(pos)
            end
        end
    end
end

local function toggleGui()
    screenGui.Enabled = not screenGui.Enabled
    Blur.Enabled = screenGui.Enabled
end


toggleButton.MouseButton1Click:Connect(function()
    setNoclip(not noclip)
end)

setGuiKey.MouseButton1Click:Connect(function()
    setGuiKey.Text = "Press any key..."
    waitingForKey = "gui"
end)

setNoclipKey.MouseButton1Click:Connect(function()
    setNoclipKey.Text = "Press any key..."
    waitingForKey = "noclip"
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if waitingForKey then
        if waitingForKey == "gui" then
            guiToggleKey = input.KeyCode
            setGuiKey.Text = "GUI Key: " .. tostring(guiToggleKey.Name)
        elseif waitingForKey == "noclip" then
            noclipToggleKey = input.KeyCode
            setNoclipKey.Text = "Noclip Key: " .. tostring(noclipToggleKey.Name)
        end
        waitingForKey = nil
        return
    end
    if input.KeyCode == guiToggleKey then
        toggleGui()
    elseif input.KeyCode == noclipToggleKey then
        setNoclip(not noclip)
    end
end)
