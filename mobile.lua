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
	1.5, 
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	-1, 
	false,
	2.5 
), {Offset = Vector2.new(1, 0)})
shineTween:Play()

-- =================================================================
-- 6. CLAMP + AUTO SNAP VÀO CẠNH MÀN HÌNH
-- =================================================================

-- Lấy kích thước màn hình (cập nhật khi resize)
local function getScreenSize()
	return MobileGui.AbsoluteSize
end

-- =================================================================
-- SAFE ZONE: tránh navbar Roblox (góc trên trái ~120px x 80px)
-- Nếu nút snap vào cạnh trái mà Y < NAVBAR_HEIGHT thì bị che
-- =================================================================
local NAVBAR_HEIGHT = 90   -- chiều cao vùng navbar (px), chỉnh nếu cần
local NAVBAR_WIDTH  = 130  -- chiều rộng vùng navbar bên trái

-- Clamp vị trí nút trong màn hình (tính theo offset tuyệt đối)
local function clampPosition(x, y)
	local screen = getScreenSize()
	local padding = 5
	x = math.clamp(x, padding, screen.X - BUTTON_SIZE - padding)
	y = math.clamp(y, padding, screen.Y - BUTTON_SIZE - padding)
	return x, y
end

-- Snap nút vào cạnh trái hoặc phải gần nhất, tránh navbar
local SNAP_PADDING = 8

local function snapToEdge()
	local screen = getScreenSize()
	local currentX = MobileButton.Position.X.Offset
	local currentY = MobileButton.Position.Y.Offset

	local _, clampedY = clampPosition(currentX, currentY)

	local centerX = screen.X / 2

	local targetX
	if currentX + BUTTON_SIZE / 2 < centerX then
		-- Muốn snap cạnh TRÁI
		targetX = SNAP_PADDING

		-- Nếu Y nằm trong vùng navbar → đẩy xuống dưới navbar
		if clampedY < NAVBAR_HEIGHT then
			clampedY = NAVBAR_HEIGHT + SNAP_PADDING
		end
	else
		-- Snap cạnh PHẢI → navbar không ảnh hưởng
		targetX = screen.X - BUTTON_SIZE - SNAP_PADDING
	end

	TweenService:Create(MobileButton, TweenInfo.new(
		0.35,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	), {
		Position = UDim2.new(0, targetX, 0, clampedY)
	}):Play()
end

-- =================================================================
-- 7. Click & Kéo Thả
-- =================================================================
local clickTweenIn  = TweenService:Create(MobileButton, TweenInfo.new(0.1), {Size = UDim2.new(0, BUTTON_SIZE - 5, 0, BUTTON_SIZE - 5)})
local clickTweenOut = TweenService:Create(MobileButton, TweenInfo.new(0.1), {Size = UDim2.new(0, BUTTON_SIZE, 0, BUTTON_SIZE)})

local dragging    = false
local dragInput   = nil
local mousePos    = nil
local framePos    = nil
local dragMoved   = false  -- phân biệt click vs drag
local DRAG_THRESHOLD = 6   -- pixel tối thiểu để coi là đang kéo

MobileButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging   = true
		dragMoved  = false
		mousePos   = input.Position
		framePos   = MobileButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				if dragging then
					dragging = false
					-- Snap vào cạnh sau khi thả
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

		-- Chỉ tính là kéo nếu đã vượt ngưỡng
		if not dragMoved and delta.Magnitude >= DRAG_THRESHOLD then
			dragMoved = true
		end

		if dragMoved then
			local newX = framePos.X.Offset + delta.X
			local newY = framePos.Y.Offset + delta.Y

			-- Clamp không cho ra ngoài màn hình
			local cx, cy = clampPosition(newX, newY)

			MobileButton.Position = UDim2.new(0, cx, 0, cy)
		end
	end
end)

-- Chỉ kích hoạt Window:Minimize nếu không phải đang kéo
MobileButton.Activated:Connect(function()
	if dragMoved then return end  -- bỏ qua nếu vừa kéo xong

	clickTweenIn:Play()
	task.wait(0.1)
	clickTweenOut:Play()

	if Window and typeof(Window.Minimize) == "function" then 
		Window:Minimize() 
	end
end)
