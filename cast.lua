-- Cast UI v2: Sleek Cheat Menu Framework
-- Optimized for Roblox cheat menus with modern styling

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Modern Cyber/Neon Theme
local Theme = {
    -- Backgrounds
    WindowBg = Color3.fromRGB(13, 17, 23),
    ChildBg = Color3.fromRGB(22, 27, 34),
    PopupBg = Color3.fromRGB(30, 35, 42),
    FrameBg = Color3.fromRGB(33, 38, 45),
    
    -- Borders
    Border = Color3.fromRGB(48, 54, 61),
    BorderHover = Color3.fromRGB(88, 166, 255),
    
    -- Text
    Text = Color3.fromRGB(230, 237, 243),
    TextDisabled = Color3.fromRGB(139, 148, 158),
    TextHighlight = Color3.fromRGB(88, 166, 255),
    
    -- Interactive Elements
    Primary = Color3.fromRGB(88, 166, 255),
    PrimaryHover = Color3.fromRGB(105, 180, 255),
    PrimaryActive = Color3.fromRGB(66, 150, 255),
    
    Secondary = Color3.fromRGB(48, 54, 61),
    SecondaryHover = Color3.fromRGB(64, 72, 80),
    
    -- Special Elements
    Accent = Color3.fromRGB(255, 123, 123),
    Success = Color3.fromRGB(56, 217, 169),
    Warning = Color3.fromRGB(255, 184, 108),
    
    -- Transparency
    Transparency = {
        Window = 0.95,
        Child = 0.9,
        Popup = 0.95
    }
}

-- Animation Config
local Animation = {
    Speed = 0.15,
    Easing = Enum.EasingStyle.Quint,
    HoverGlow = 0.1
}

-- CastUI Class
local Cast = {}
Cast.__index = Cast

-- Layout Manager (local to each instance)
local function createLayoutManager()
    return {
        cursor = {x = 16, y = 16},
        indent = 0,
        sameLine = false,
        lastWidth = 0,
        lineHeight = 0,
        groupStack = {},
        padding = 8,
        
        BeginGroup = function(self, padding)
            table.insert(self.groupStack, {
                x = self.cursor.x,
                y = self.cursor.y,
                indent = self.indent
            })
            
            local pad = padding or self.padding
            self.cursor.x = self.cursor.x + pad
            self.cursor.y = self.cursor.y + pad
            self.indent = self.indent + pad
            
            return #self.groupStack
        end,
        
        EndGroup = function(self)
            if #self.groupStack > 0 then
                local last = table.remove(self.groupStack)
                self.cursor.x = last.x
                self.cursor.y = last.y + self.lineHeight + self.padding
                self.indent = last.indent
                self.lineHeight = 0
            end
        end,
        
        SameLine = function(self, spacing)
            self.sameLine = true
            if spacing then
                self.cursor.x = self.cursor.x + spacing
            end
        end,
        
        AdvanceCursor = function(self, width, height)
            if not self.sameLine then
                self.lastWidth = width
                self.lineHeight = math.max(self.lineHeight, height)
                self.cursor.y = self.cursor.y + height + 4
            else
                self.cursor.x = self.cursor.x + width + 4
                self.lineHeight = math.max(self.lineHeight, height)
                self.sameLine = false
            end
        end,
        
        GetCursorPos = function(self)
            return UDim2.new(0, self.cursor.x, 0, self.cursor.y)
        end,
        
        Reset = function(self)
            self.cursor = {x = 16, y = 16}
            self.indent = 0
            self.sameLine = false
            self.lastWidth = 0
            self.lineHeight = 0
            self.groupStack = {}
        end
    }
end

-- UI Element Creation
local function createRoundedFrame()
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    return frame
end

local function createGlowEffect(parent, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 16, 1, 16)
    glow.Position = UDim2.new(0, -8, 0, -8)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://8992230671"
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.9
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(49, 49, 450, 450)
    glow.ZIndex = -1
    glow.Parent = parent
    
    return glow
end

-- Cast UI Constructor
function Cast.new(title, options)
    options = options or {}
    
    local self = setmetatable({}, Cast)
    
    self.title = title or "Cast UI"
    self.open = true
    self.minimized = false
    self.watermark = options.watermark or "CAST UI"
    
    -- Create layout manager for this instance
    self.layout = createLayoutManager()
    
    -- Create main GUI
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "CastUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.DisplayOrder = 999
    self.gui.Parent = PlayerGui
    
    -- Main window with blur effect
    self.window = createRoundedFrame()
    self.window.Size = UDim2.new(0, 500, 0, 600)
    self.window.Position = UDim2.new(0.5, -250, 0.5, -300)
    self.window.BackgroundColor3 = Theme.WindowBg
    self.window.BackgroundTransparency = Theme.Transparency.Window
    self.window.ClipsDescendants = true
    self.window.Parent = self.gui
    
    -- Subtle border glow
    local border = Instance.new("UIStroke")
    border.Color = Theme.Border
    border.Thickness = 1
    border.Transparency = 0.5
    border.Parent = self.window
    
    -- Title bar with gradient
    self.titleBar = createRoundedFrame()
    self.titleBar.Size = UDim2.new(1, 0, 0, 36)
    self.titleBar.BackgroundColor3 = Color3.fromRGB(20, 25, 32)
    self.titleBar.BackgroundTransparency = 0.1
    self.titleBar.Parent = self.window
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 166, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 25, 32))
    })
    titleGradient.Rotation = 90
    titleGradient.Parent = self.titleBar
    
    -- Title text with shadow
    local titleShadow = Instance.new("TextLabel")
    titleShadow.Size = UDim2.new(1, 0, 1, 0)
    titleShadow.Position = UDim2.new(0, 1, 0, 1)
    titleShadow.BackgroundTransparency = 1
    titleShadow.Text = self.title
    titleShadow.TextColor3 = Color3.new(0, 0, 0)
    titleShadow.TextTransparency = 0.5
    titleShadow.TextSize = 16
    titleShadow.Font = Enum.Font.GothamBold
    titleShadow.TextXAlignment = Enum.TextXAlignment.Left
    titleShadow.TextYAlignment = Enum.TextYAlignment.Center
    titleShadow.Parent = self.titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = self.titleBar
    
    -- Window controls
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(0, 96, 1, 0)
    controls.Position = UDim2.new(1, -96, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = self.titleBar
    
    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(0, 8, 0.5, -12)
    minBtn.BackgroundColor3 = Theme.Secondary
    minBtn.BackgroundTransparency = 0.5
    minBtn.Text = "_"
    minBtn.TextColor3 = Theme.Text
    minBtn.TextSize = 18
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.Parent = controls
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 4)
    minCorner.Parent = minBtn
    
    -- Close button with glow
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0.5, -12)
    closeBtn.BackgroundColor3 = Theme.Accent
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = controls
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    createGlowEffect(closeBtn, Theme.Accent)
    
    -- Content area
    self.content = Instance.new("ScrollingFrame")
    self.content.Size = UDim2.new(1, -16, 1, -52)
    self.content.Position = UDim2.new(0, 8, 0, 44)
    self.content.BackgroundTransparency = 1
    self.content.ScrollBarThickness = 4
    self.content.ScrollBarImageColor3 = Theme.Border
    self.content.ScrollBarImageTransparency = 0.5
    self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.content.Parent = self.window
    
    self.canvas = Instance.new("Frame")
    self.canvas.Size = UDim2.new(1, 0, 0, 0)
    self.canvas.BackgroundTransparency = 1
    self.canvas.Parent = self.content
    
    -- Bottom watermark
    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(1, 0, 0, 20)
    watermark.Position = UDim2.new(0, 0, 1, -20)
    watermark.BackgroundTransparency = 1
    watermark.Text = self.watermark
    watermark.TextColor3 = Theme.TextDisabled
    watermark.TextTransparency = 0.7
    watermark.TextSize = 12
    watermark.Font = Enum.Font.GothamMedium
    watermark.TextXAlignment = Enum.TextXAlignment.Right
    watermark.TextYAlignment = Enum.TextYAlignment.Center
    watermark.Parent = self.window
    
    -- Interactive effects
    local hoverAnim = function(btn, targetColor)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(Animation.Speed, Animation.Easing), {
                BackgroundTransparency = 0.3,
                BackgroundColor3 = targetColor
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(Animation.Speed, Animation.Easing), {
                BackgroundTransparency = 0.5
            }):Play()
        end)
        
        btn.MouseButton1Down:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Animation.Easing), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        btn.MouseButton1Up:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Animation.Easing), {
                BackgroundTransparency = 0.3
            }):Play()
        end)
    end
    
    hoverAnim(minBtn, Theme.SecondaryHover)
    hoverAnim(closeBtn, Color3.fromRGB(255, 100, 100))
    
    -- Button functionality
    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Window dragging
    self:SetupDragging()
    
    return self
end

-- Window Dragging
function Cast:SetupDragging()
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self.window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- UI Elements
function Cast:Begin()
    self.layout:Reset()
end

function Cast:Section(name, collapsed)
    local pos = self.layout:GetCursorPos()
    
    local section = createRoundedFrame()
    section.Size = UDim2.new(1, -16, 0, 40)
    section.Position = pos
    section.BackgroundColor3 = Theme.ChildBg
    section.BackgroundTransparency = Theme.Transparency.Child
    section.Parent = self.canvas
    
    local border = Instance.new("UIStroke")
    border.Color = Theme.Border
    border.Thickness = 1
    border.Transparency = 0.3
    border.Parent = section
    
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = section
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -32, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name or "Section"
    title.TextColor3 = Theme.Text
    title.TextSize = 15
    title.Font = Enum.Font.GothamSemiBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.Parent = section
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -24, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = collapsed and "▸" or "▾"
    arrow.TextColor3 = Theme.TextDisabled
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamBold
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.Parent = section
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 40)
    content.BackgroundTransparency = 1
    content.Visible = not collapsed
    content.Parent = section
    
    local isCollapsed = collapsed or false
    local groupId = self.layout:BeginGroup(8)
    self.layout.cursor.y = self.layout.cursor.y + 40
    
    header.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        arrow.Text = isCollapsed and "▸" or "▾"
        content.Visible = not isCollapsed
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
        local targetSize = isCollapsed and 40 or (40 + content.AbsoluteSize.Y + 8)
        
        TweenService:Create(section, tweenInfo, {
            Size = UDim2.new(1, -16, 0, targetSize)
        }):Play()
    end)
    
    self.layout:AdvanceCursor(section.AbsoluteSize.X, section.AbsoluteSize.Y)
    
    return {
        frame = content,
        toggle = header,
        collapsed = isCollapsed
    }
end

function Cast:Button(label, options)
    options = options or {}
    local pos = self.layout:GetCursorPos()
    
    local btn = createRoundedFrame()
    btn.Size = options.size or UDim2.new(0, 0, 0, 36)
    btn.Position = pos
    btn.BackgroundColor3 = options.color or Theme.Primary
    btn.BackgroundTransparency = 0.5
    btn.Parent = self.canvas
    
    if not options.size then
        local textSize = TextService:GetTextSize(label, 14, Enum.Font.GothamMedium, Vector2.new(1000, 100))
        btn.Size = UDim2.new(0, textSize.X + 32, 0, 36)
    end
    
    local btnText = Instance.new("TextButton")
    btnText.Size = UDim2.new(1, 0, 1, 0)
    btnText.BackgroundTransparency = 1
    btnText.Text = label
    btnText.TextColor3 = Theme.Text
    btnText.TextSize = 14
    btnText.Font = Enum.Font.GothamMedium
    btnText.AutoButtonColor = false
    btnText.Parent = btn
    
    createGlowEffect(btn, btn.BackgroundColor3)
    
    -- Hover effects
    btnText.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(Animation.Speed, Animation.Easing), {
            BackgroundTransparency = 0.3,
            BackgroundColor3 = options.color and options.color:Lerp(Color3.new(1, 1, 1), 0.1) or Theme.PrimaryHover
        }):Play()
    end)
    
    btnText.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(Animation.Speed, Animation.Easing), {
            BackgroundTransparency = 0.5,
            BackgroundColor3 = options.color or Theme.Primary
        }):Play()
    end)
    
    btnText.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1, Animation.Easing), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    btnText.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1, Animation.Easing), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    self.layout:AdvanceCursor(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)
    
    -- Return the button with click event
    local buttonObj = {
        instance = btnText,
        onClick = function(callback)
            btnText.MouseButton1Click:Connect(callback)
            return buttonObj
        end
    }
    
    return buttonObj
end

function Cast:Toggle(label, initialState, options)
    options = options or {}
    local pos = self.layout:GetCursorPos()
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 24)
    container.Position = pos
    container.BackgroundTransparency = 1
    container.Parent = self.canvas
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -40, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextYAlignment = Enum.TextYAlignment.Center
    labelText.Parent = container
    
    local toggleBg = createRoundedFrame()
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBg.BackgroundColor3 = initialState and (options.color or Theme.Success) or Theme.Secondary
    toggleBg.BackgroundTransparency = 0.6
    toggleBg.Parent = container
    
    local toggleKnob = createRoundedFrame()
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleKnob.Parent = toggleBg
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = container
    
    local state = initialState or false
    
    local function updateToggle()
        local targetColor = state and (options.color or Theme.Success) or Theme.Secondary
        local targetPosition = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            BackgroundColor3 = targetColor
        }):Play()
        
        TweenService:Create(toggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Position = targetPosition
        }):Play()
    end
    
    updateToggle()
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)
    
    self.layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
    
    return {
        button = toggleBtn,
        getState = function() return state end,
        setState = function(newState)
            state = newState
            updateToggle()
        end,
        onToggle = function(callback)
            toggleBtn.MouseButton1Click:Connect(callback)
        end
    }
end

function Cast:Slider(label, min, max, defaultValue, options)
    options = options or {}
    local pos = self.layout:GetCursorPos()
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 60)
    container.Position = pos
    container.BackgroundTransparency = 1
    container.Parent = self.canvas
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextYAlignment = Enum.TextYAlignment.Center
    labelText.Parent = header
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.4, 0, 1, 0)
    valueText.Position = UDim2.new(0.6, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = string.format(options.format or "%.1f", defaultValue)
    valueText.TextColor3 = Theme.TextHighlight
    valueText.TextSize = 14
    valueText.Font = Enum.Font.GothamMedium
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.TextYAlignment = Enum.TextYAlignment.Center
    valueText.Parent = header
    
    local track = createRoundedFrame()
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 32)
    track.BackgroundColor3 = Theme.Secondary
    track.BackgroundTransparency = 0.6
    track.Parent = container
    
    local fill = createRoundedFrame()
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = options.color or Theme.Primary
    fill.BackgroundTransparency = 0.4
    fill.Parent = track
    
    local knob = createRoundedFrame()
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.ZIndex = 2
    knob.Parent = track
    
    createGlowEffect(knob, fill.BackgroundColor3)
    
    local dragging = false
    local currentValue = defaultValue
    
    local function updateSlider(value)
        currentValue = math.clamp(value, min, max)
        local ratio = (currentValue - min) / (max - min)
        
        valueText.Text = string.format(options.format or "%.1f", currentValue)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -8, 0.5, -8)
    end
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            
            TweenService:Create(knob, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 20, 0, 20)
            }):Play()
        end
    end
    
    track.InputBegan:Connect(onInput)
    knob.InputBegan:Connect(onInput)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position
            local trackPos = track.AbsolutePosition
            local trackSize = track.AbsoluteSize
            
            local relativeX = (mousePos.X - trackPos.X) / trackSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            local newValue = min + (max - min) * relativeX
            updateSlider(newValue)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            
            TweenService:Create(knob, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 16, 0, 16)
            }):Play()
        end
    end)
    
    self.layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
    
    return {
        getValue = function() return currentValue end,
        setValue = updateSlider,
        onChange = function(callback)
            -- This would need event system implementation
        end
    }
end

function Cast:ComboBox(label, items, defaultIndex)
    local pos = self.layout:GetCursorPos()
    
    local container = createRoundedFrame()
    container.Size = UDim2.new(1, -16, 0, 36)
    container.Position = pos
    container.BackgroundColor3 = Theme.FrameBg
    container.BackgroundTransparency = 0.6
    container.Parent = self.canvas
    
    local comboBtn = Instance.new("TextButton")
    comboBtn.Size = UDim2.new(1, 0, 1, 0)
    comboBtn.BackgroundTransparency = 1
    comboBtn.Text = ""
    comboBtn.AutoButtonColor = false
    comboBtn.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -40, 1, 0)
    labelText.Position = UDim2.new(0, 12, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = items[defaultIndex or 1] or label or "Select..."
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextYAlignment = Enum.TextYAlignment.Center
    labelText.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -24, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▾"
    arrow.TextColor3 = Theme.TextDisabled
    arrow.TextSize = 12
    arrow.Font = Enum.Font.GothamBold
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.Parent = container
    
    local dropdownOpen = false
    local dropdown
    
    local function closeDropdown()
        if dropdown then
            TweenService:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            task.wait(0.2)
            dropdown:Destroy()
            dropdownOpen = false
        end
    end
    
    local selectedIndex = defaultIndex or 1
    
    comboBtn.MouseButton1Click:Connect(function()
        if dropdownOpen then
            closeDropdown()
            return
        end
        
        dropdownOpen = true
        
        dropdown = createRoundedFrame()
        dropdown.Size = UDim2.new(1, 0, 0, 0)
        dropdown.Position = UDim2.new(0, 0, 1, 4)
        dropdown.BackgroundColor3 = Theme.PopupBg
        dropdown.BackgroundTransparency = Theme.Transparency.Popup
        dropdown.ClipsDescendants = true
        dropdown.ZIndex = 10
        dropdown.Parent = container
        
        for i, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, -8, 0, 32)
            itemBtn.Position = UDim2.new(0, 4, 0, 4 + (i-1)*36)
            itemBtn.BackgroundColor3 = Theme.FrameBg
            itemBtn.BackgroundTransparency = 0.6
            itemBtn.Text = item
            itemBtn.TextColor3 = Theme.Text
            itemBtn.TextSize = 13
            itemBtn.Font = Enum.Font.GothamMedium
            itemBtn.AutoButtonColor = false
            itemBtn.ZIndex = 11
            itemBtn.Parent = dropdown
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = itemBtn
            
            itemBtn.MouseEnter:Connect(function()
                TweenService:Create(itemBtn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.4,
                    BackgroundColor3 = Theme.Primary
                }):Play()
            end)
            
            itemBtn.MouseLeave:Connect(function()
                TweenService:Create(itemBtn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.6,
                    BackgroundColor3 = Theme.FrameBg
                }):Play()
            end)
            
            itemBtn.MouseButton1Click:Connect(function()
                labelText.Text = item
                selectedIndex = i
                closeDropdown()
            end)
        end
        
        TweenService:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 0, #items * 36 + 8)
        }):Play()
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if dropdownOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local dropdownAbsPos = dropdown and dropdown.AbsolutePosition
            local dropdownSize = dropdown and dropdown.AbsoluteSize
            
            if dropdown and dropdownAbsPos then
                if not (mousePos.X >= dropdownAbsPos.X and mousePos.X <= dropdownAbsPos.X + dropdownSize.X and
                       mousePos.Y >= dropdownAbsPos.Y and mousePos.Y <= dropdownAbsPos.Y + dropdownSize.Y) then
                    closeDropdown()
                end
            end
        end
    end)
    
    self.layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
    
    return {
        button = comboBtn,
        getSelection = function() return labelText.Text end,
        getIndex = function() return selectedIndex end,
        onChange = function(callback)
            -- Event system would be needed
        end
    }
end

function Cast:Label(text, options)
    options = options or {}
    local pos = self.layout:GetCursorPos()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 20)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.color or Theme.Text
    label.TextTransparency = options.transparency or 0
    label.TextSize = options.size or 14
    label.Font = options.font or Enum.Font.GothamMedium
    label.TextXAlignment = options.align or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = self.canvas
    
    self.layout:AdvanceCursor(label.AbsoluteSize.X, label.AbsoluteSize.Y)
    
    return label
end

function Cast:Separator()
    local pos = self.layout:GetCursorPos()
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -16, 0, 1)
    line.Position = pos
    line.BackgroundColor3 = Theme.Border
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.Parent = self.canvas
    
    self.layout:AdvanceCursor(line.AbsoluteSize.X, 8)
    
    return line
end

function Cast:Spacing(height)
    local pos = self.layout:GetCursorPos()
    
    local space = Instance.new("Frame")
    space.Size = UDim2.new(1, 0, 0, height or 8)
    space.Position = pos
    space.BackgroundTransparency = 1
    space.Parent = self.canvas
    
    self.layout:AdvanceCursor(space.AbsoluteSize.X, space.AbsoluteSize.Y)
end

function Cast:SameLine(spacing)
    self.layout:SameLine(spacing)
end

-- Utility Methods
function Cast:ToggleMinimize()
    self.minimized = not self.minimized
    
    local targetSize = self.minimized and UDim2.new(1, 0, 0, 36) or UDim2.new(0, 500, 0, 600)
    local targetPos = self.minimized and UDim2.new(0, 8, 0, 8) or UDim2.new(0.5, -250, 0.5, -300)
    
    TweenService:Create(self.window, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Size = targetSize,
        Position = targetPos
    }):Play()
    
    self.content.Visible = not self.minimized
end

function Cast:SetVisibility(visible)
    self.window.Visible = visible
end

function Cast:Destroy()
    if self.gui then
        self.gui:Destroy()
    end
end

return Cast
