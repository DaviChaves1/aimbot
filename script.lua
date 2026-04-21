local _Players = game:GetService('Players')
local _RunService = game:GetService('RunService')
local _LocalPlayer = _Players.LocalPlayer
local _UserInputService = game:GetService('UserInputService')

-- Configuration
local u4 = false 
local u5 = 0.165 -- Base Prediction
local u19 = nil  
local TargetPart = "HumanoidRootPart"
local BlatantMode = false 
getgenv().Key = 'c'

-- Cores Atualizadas
local COLORS = {
    Background = Color3.fromRGB(0, 0, 0), -- Fundo Preto
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(50, 50, 50),
    BtnGradientStart = Color3.fromRGB(40, 40, 40), -- Cinza Escuro
    BtnGradientEnd = Color3.fromRGB(255, 255, 255) -- Branco
}

-- [SOUND HANDLER]
local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://7293523910"
ClickSound.Volume = 1
ClickSound.Parent = game:GetService("SoundService")

local function PlayClick()
    if ClickSound.IsPlaying then ClickSound:Stop() end
    ClickSound:Play()
end

local function GetPredictedPosition(target)
    local part = target.Character[TargetPart]
    local velocity = part.Velocity
    if velocity.Magnitude < 1 then return part.Position end
    return part.Position + (velocity * u5)
end

function FindNearestEnemy()
    local _huge = math.huge
    local v9 = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    local v13 = nil
    for _, v14 in ipairs(_Players:GetPlayers()) do
        if v14 ~= _LocalPlayer and v14.Character and v14.Character:FindFirstChild(TargetPart) then
            local hum = v14.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local v16, v17 = workspace.CurrentCamera:WorldToViewportPoint(v14.Character[TargetPart].Position)
                if v17 then
                    local _Magnitude = (v9 - Vector2.new(v16.X, v16.Y)).Magnitude
                    if _Magnitude < _huge then
                        v13 = v14
                        _huge = _Magnitude
                    end
                end
            end
        end
    end
    return v13
end

-- GUI CONSTRUCTION (Compacta)
local _ScreenGui = Instance.new('ScreenGui')
_ScreenGui.Name = 'TheButtonCamLock'
_ScreenGui.ResetOnSpawn = false
pcall(function() _ScreenGui.Parent = game:GetService("CoreGui") end)

local _MainFrame = Instance.new('Frame', _ScreenGui)
_MainFrame.BackgroundColor3 = COLORS.Background
_MainFrame.Position = UDim2.new(0.5, -70, 0.5, -70)
_MainFrame.Size = UDim2.new(0, 140, 0, 140) -- Tamanho reduzido
_MainFrame.Active = true
_MainFrame.Draggable = true

local _UICorner = Instance.new('UICorner', _MainFrame)
_UICorner.CornerRadius = UDim.new(0, 8)

local _UIStroke = Instance.new("UIStroke", _MainFrame)
_UIStroke.Thickness = 1.5
_UIStroke.Color = COLORS.Stroke

local _Title = Instance.new("TextLabel", _MainFrame)
_Title.Size = UDim2.new(1, 0, 0, 25)
_Title.BackgroundTransparency = 1
_Title.Text = "CAMLOCK"
_Title.TextColor3 = COLORS.Text
_Title.Font = Enum.Font.GothamBold
_Title.TextSize = 10

-- "By 777" no cantinho
local _Credits = Instance.new("TextLabel", _MainFrame)
_Credits.Size = UDim2.new(0, 40, 0, 15)
_Credits.Position = UDim2.new(1, -45, 1, -15)
_Credits.BackgroundTransparency = 1
_Credits.Text = "by 777"
_Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
_Credits.Font = Enum.Font.Gotham
_Credits.TextSize = 8
_Credits.TextXAlignment = Enum.TextXAlignment.Right

local function CreateBtn(text, pos)
    local b = Instance.new('TextButton', _MainFrame)
    b.Position = pos
    b.Size = UDim2.new(0.85, 0, 0, 26)
    b.AnchorPoint = Vector2.new(0.5, 0)
    b.Position = UDim2.new(0.5, 0, pos.Y.Scale, 0)
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(0, 0, 0) -- Texto preto para contrastar com o branco do degradê
    b.TextSize = 9
    b.AutoButtonColor = true
    
    local grad = Instance.new("UIGradient", b)
    grad.Color = ColorSequence.new(COLORS.BtnGradientStart, COLORS.BtnGradientEnd)
    grad.Rotation = 45

    Instance.new('UICorner', b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(PlayClick)
    return b
end

local _LockBtn = CreateBtn("STATUS: OFF", UDim2.new(0, 0, 0.22, 0))
local _PartBtn = CreateBtn("TARGET: TORSO", UDim2.new(0, 0, 0.45, 0))
local _ModeBtn = CreateBtn("MODE: LEGIT", UDim2.new(0, 0, 0.68, 0))

local function UpdateUI()
    _LockBtn.Text = u4 and "STATUS: ON" or "STATUS: OFF"
    _UIStroke.Color = u4 and Color3.fromRGB(255, 255, 255) or COLORS.Stroke
end

_LockBtn.MouseButton1Click:Connect(function()
    u4 = not u4
    if u4 then u19 = FindNearestEnemy() end
    UpdateUI()
end)

_PartBtn.MouseButton1Click:Connect(function()
    TargetPart = (TargetPart == "HumanoidRootPart") and "Head" or "HumanoidRootPart"
    _PartBtn.Text = (TargetPart == "Head") and "TARGET: HEAD" or "TARGET: TORSO"
end)

_ModeBtn.MouseButton1Click:Connect(function()
    BlatantMode = not BlatantMode
    _ModeBtn.Text = BlatantMode and "MODE: BLATANT" or "MODE: LEGIT"
end)

_UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode[getgenv().Key:upper()] then
        u4 = not u4
        if u4 then u19 = FindNearestEnemy() end
        UpdateUI()
        PlayClick()
    end
end)

_RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if u4 and u19 and u19.Character and u19.Character:FindFirstChild(TargetPart) then
        local predictedPos = GetPredictedPosition(u19)
        if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
        if BlatantMode then
            cam.CFrame = CFrame.new(cam.CFrame.Position, predictedPos)
        else
            local lookAt = CFrame.new(cam.CFrame.Position, predictedPos)
            cam.CFrame = cam.CFrame:Lerp(lookAt, 0.40)
        end
    elseif u4 then
        u4 = false
        u19 = nil
        UpdateUI()
    end
end)

