-- =================================================================
-- CẤU HÌNH LOGO
-- =================================================================
local YOUR_LOGO_ID = "rbxassetid://96946975520738" 
local BUTTON_SIZE = 50
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local UI_NAME = "NemoHubMobileV5_Aqua"

local targetParent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui

if targetParent:FindFirstChild(UI_NAME) then
	targetParent[UI_NAME]:Destroy()
end

-- 1. Tạo ScreenGui
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = UI_NAME
MobileGui.Parent = targetParent
MobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MobileGui.ResetOnSpawn = false
MobileGui.IgnoreGuiInset = true 

-- 2. Tạo nút chính
local MobileButton = Instance.new("TextButton")
MobileButton.Name = "MainButtonCircle"
MobileButton.Parent = MobileGui
MobileButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MobileButton.Position = UDim2.new(0, 30, 0.5, -35)
MobileButton.Size = UDim2.new(0, BUTTON_SIZE, 0, BUTTON_SIZE)
MobileButton.Text = ""
MobileButton.AutoButtonColor = false
MobileButton.ClipsDescendants = true 

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(1, 0) 
MainCorner.Parent = MobileButton

-- 3. Viền Gradient Động (MÀU AQUA)
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MobileButton
UIStroke.Thickness = 4
UIStroke.Color = Color3.new(1, 1, 1)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local BorderGradient = Instance.new("UIGradient")
BorderGradient.Parent = UIStroke
BorderGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 150, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 255))
})

local rotationSpeed = 150
local currentRotation = 0
local rotationConnection

rotationConnection = RunService.Heartbeat:Connect(function(deltaTime)
	if BorderGradient and BorderGradient.Parent then
		currentRotation = (currentRotation + rotationSpeed * deltaTime) % 360
		BorderGradient.Rotation = currentRotation
	else
		rotationConnection:Disconnect()
	end
end)

-- 4. Logo
local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "LogoIconLayer"
LogoImage.Parent = MobileButton
LogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
LogoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoImage.Size = UDim2.new(1, 0, 1, 0) 
LogoImage.BackgroundTransparency = 1
LogoImage.Image = YOUR_LOGO_ID
LogoImage.ScaleType = Enum.ScaleType.Crop 
LogoImage.ZIndex = 2 

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0) 
LogoCorner.Parent = LogoImage

-- 5. Hiệu ứng Shine
local ShineFrame = Instance.new("Frame")
ShineFrame.Name = "ShineEffectLayer"
ShineFrame.Parent = MobileButton
ShineFrame.Size = UDim2.new(1, 0, 1, 0)
ShineFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShineFrame.BorderSizePixel = 0
ShineFrame.ZIndex = 3 

local ShineCorner = Instance.new("UICorner")
ShineCorner.CornerRadius = UDim.new(1, 0)
ShineCorner.Parent = ShineFrame

local ShineGradient = Instance.new("UIGradient")
ShineGradient.Parent = ShineFrame
ShineGradient.Rotation = 45
ShineGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.4, 1),
	NumberSequenceKeypoint.new(0.5, 0.4), 
	NumberSequenceKeypoint.new(0.6, 1),
	NumberSequenceKeypoint.new(1, 1)
})
ShineGradient.Offset = Vector2.new(-1, 0)

local shineTween = TweenService:Create(ShineGradient, TweenInfo.new(
	1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 2.5
), {Offset = Vector2.new(1, 0)})
shineTween:Play()

-- =================================================================
-- CLAMP + AUTO SNAP VÀO CẠNH MÀN HÌNH
-- =================================================================
local function getScreenSize()
	return MobileGui.AbsoluteSize
end

local NAVBAR_HEIGHT = 90
local SNAP_PADDING  = 8

local function clampPosition(x, y)
	local screen = getScreenSize()
	local padding = 5
	x = math.clamp(x, padding, screen.X - BUTTON_SIZE - padding)
	y = math.clamp(y, padding, screen.Y - BUTTON_SIZE - padding)
	return x, y
end

local function snapToEdge()
	local screen   = getScreenSize()
	local currentX = MobileButton.Position.X.Offset
	local currentY = MobileButton.Position.Y.Offset
	local _, clampedY = clampPosition(currentX, currentY)
	local centerX  = screen.X / 2
	local targetX

	if currentX + BUTTON_SIZE / 2 < centerX then
		targetX = SNAP_PADDING
		if clampedY < NAVBAR_HEIGHT then
			clampedY = NAVBAR_HEIGHT + SNAP_PADDING
		end
	else
		targetX = screen.X - BUTTON_SIZE - SNAP_PADDING
	end

	TweenService:Create(MobileButton, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, targetX, 0, clampedY)
	}):Play()
end

-- =================================================================
-- CLICK & KÉO THẢ
-- =================================================================
local clickTweenIn  = TweenService:Create(MobileButton, TweenInfo.new(0.1), {Size = UDim2.new(0, BUTTON_SIZE - 5, 0, BUTTON_SIZE - 5)})
local clickTweenOut = TweenService:Create(MobileButton, TweenInfo.new(0.1), {Size = UDim2.new(0, BUTTON_SIZE, 0, BUTTON_SIZE)})

local dragging       = false
local dragInput      = nil
local mousePos       = nil
local framePos       = nil
local dragMoved      = false
local DRAG_THRESHOLD = 6

MobileButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging  = true
		dragMoved = false
		mousePos  = input.Position
		framePos  = MobileButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				if dragging then
					dragging = false
					snapToEdge()
				end
			end
		end)
	end
end)

MobileButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
		dragInput = input 
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		if not dragMoved and delta.Magnitude >= DRAG_THRESHOLD then
			dragMoved = true
		end
		if dragMoved then
			local cx, cy = clampPosition(
				framePos.X.Offset + delta.X,
				framePos.Y.Offset + delta.Y
			)
			MobileButton.Position = UDim2.new(0, cx, 0, cy)
		end
	end
end)

-- =================================================================
-- BẬT/TẮT UI KHI BẤM LOGO
-- Fluent không có hàm Minimize() trực tiếp — cách đúng là
-- fire giả lập phím MinimizeKey mà Window đang lắng nghe
-- =================================================================
MobileButton.Activated:Connect(function()
	if dragMoved then return end

	clickTweenIn:Play()
	task.wait(0.1)
	clickTweenOut:Play()

	-- Lấy key từ _G (được gán trong main script)
	local key = _G.NemoMinimizeKey
	if key then
		-- Fire InputBegan giả để Fluent nhận phím tắt
		local vInputService = game:GetService("VirtualInputManager")
		if vInputService then
			pcall(function()
				vInputService:SendKeyEvent(true,  key, false, game)
				task.wait(0.05)
				vInputService:SendKeyEvent(false, key, false, game)
			end)
		else
			-- Fallback: dùng UserInputService fire thủ công
			pcall(function()
				local fakeInput = {
					KeyCode        = key,
					UserInputType  = Enum.UserInputType.Keyboard,
					UserInputState = Enum.UserInputState.Begin,
				}
				UserInputService.InputBegan:Fire(fakeInput, false)
			end)
		end
	end
end)
