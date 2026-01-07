local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Theme = {
    WindowBg = Color3.fromRGB(30, 30, 35),
    ChildBg = Color3.fromRGB(25, 25, 28),
    PopupBg = Color3.fromRGB(35, 35, 40),
    FrameBg = Color3.fromRGB(40, 40, 45),
    Border = Color3.fromRGB(60, 60, 65),
    BorderHover = Color3.fromRGB(0, 120, 215),
    Text = Color3.fromRGB(240, 240, 240),
    TextDisabled = Color3.fromRGB(120, 120, 120),
    TextHighlight = Color3.fromRGB(0, 150, 255),
    Primary = Color3.fromRGB(0, 120, 215),
    PrimaryHover = Color3.fromRGB(0, 150, 255),
    PrimaryActive = Color3.fromRGB(0, 100, 180),
    Secondary = Color3.fromRGB(50, 50, 55),
    SecondaryHover = Color3.fromRGB(70, 70, 75),
    Accent = Color3.fromRGB(220, 50, 50),
    Success = Color3.fromRGB(50, 180, 130),
    Warning = Color3.fromRGB(230, 150, 70),
}

local Cast = {}
Cast.__index = Cast

local function createLayout()
    return {
        cursor = {x = 10, y = 10},
        indent = 0,
        sameLine = false,
        lastWidth = 0,
        lineHeight = 0,
        groupStack = {},
        padding = 8,
        
        BeginGroup = function(self, padding)
            table.insert(self.groupStack, {x = self.cursor.x, y = self.cursor.y, indent = self.indent})
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
                self.cursor.y = last.y + self.lineHeight + 4
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
            self.cursor = {x = 10, y = 10}
            self.indent = 0
            self.sameLine = false
            self.lastWidth = 0
            self.lineHeight = 0
            self.groupStack = {}
        end
    }
end

function Cast.new(title, options)
    options = options or {}
    
    local self = setmetatable({}, Cast)
    
    self.title = title or "Cast UI"
    self.minimized = false
    
    self.layout = createLayout()
    
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "CastUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.DisplayOrder = 999
    self.gui.Parent = PlayerGui
    
    self.window = Instance.new("Frame")
    self.window.Size = UDim2.new(0, 450, 0, 550)
    self.window.Position = UDim2.new(0.5, -225, 0.5, -275)
    self.window.BackgroundColor3 = Theme.WindowBg
    self.window.BorderSizePixel = 0
    self.window.ClipsDescendants = true
    self.window.Parent = self.gui
    
    local windowBorder = Instance.new("UIStroke")
    windowBorder.Color = Theme.Border
    windowBorder.Thickness = 1
    windowBorder.Parent = self.window
    
    self.titleBar = Instance.new("Frame")
    self.titleBar.Size = UDim2.new(1, 0, 0, 30)
    self.titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.window
    
    local titleBorder = Instance.new("Frame")
    titleBorder.Size = UDim2.new(1, 0, 0, 1)
    titleBorder.Position = UDim2.new(0, 0, 1, 0)
    titleBorder.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    titleBorder.BorderSizePixel = 0
    titleBorder.Parent = self.titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = self.titleBar
    
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(0, 40, 1, 0)
    controls.Position = UDim2.new(1, -40, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = self.titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0, 5, 0, 0)
    closeBtn.BackgroundColor3 = Theme.Accent
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = controls
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(240, 70, 70)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Theme.Accent
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.content = Instance.new("ScrollingFrame")
    self.content.Size = UDim2.new(1, -16, 1, -46)
    self.content.Position = UDim2.new(0, 8, 0, 38)
    self.content.BackgroundTransparency = 1
    self.content.ScrollBarThickness = 4
    self.content.ScrollBarImageColor3 = Theme.Border
    self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.content.Parent = self.window
    
    self.canvas = Instance.new("Frame")
    self.canvas.Size = UDim2.new(1, 0, 0, 0)
    self.canvas.BackgroundTransparency = 1
    self.canvas.Parent = self.content
    
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
    
    return self
end

function Cast:Destroy()
    if self.gui then
        self.gui:Destroy()
    end
end

function Cast:Begin()
    self.layout:Reset()
end

function Cast:Button(label, options)
    options = options or {}
    local pos = self.layout:GetCursorPos()
    
    local btn = Instance.new("TextButton")
    btn.Size = options.size or UDim2.new(1, -16, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = options.color or Theme.Primary
    btn.Text = label
    btn.TextColor3 = Theme.Text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = false
    btn.Parent = self.canvas
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Theme.PrimaryHover
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = options.color or Theme.Primary
    end)
    
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = Theme.PrimaryActive
    end)
    
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundColor3 = Theme.PrimaryHover
    end)
    
    self.layout:AdvanceCursor(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)
    
    local buttonObj = {
        instance = btn,
        onClick = function(callback)
            btn.MouseButton1Click:Connect(callback)
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
    labelText.Size = UDim2.new(1, -50, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextYAlignment = Enum.TextYAlignment.Center
    labelText.Parent = container
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBg.BackgroundColor3 = initialState and (options.color or Theme.Success) or Theme.Secondary
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleKnob.BorderSizePixel = 0
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
        
        toggleBg.BackgroundColor3 = targetColor
        toggleKnob.Position = targetPosition
    end
    
    updateToggle()
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)
    
    toggleBtn.MouseEnter:Connect(function()
        toggleBg.BackgroundColor3 = state and (options.color or Theme.Success):Lerp(Color3.new(1,1,1), 0.2) or Theme.SecondaryHover
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        toggleBg.BackgroundColor3 = state and (options.color or Theme.Success) or Theme.Secondary
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
    container.Size = UDim2.new(1, -16, 0, 44)
    container.Position = pos
    container.BackgroundTransparency = 1
    container.Parent = self.canvas
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -50, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextYAlignment = Enum.TextYAlignment.Center
    labelText.Parent = header
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0, 50, 1, 0)
    valueText.Position = UDim2.new(1, -50, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = string.format(options.format or "%.1f", defaultValue)
    valueText.TextColor3 = Theme.TextHighlight
    valueText.TextSize = 13
    valueText.Font = Enum.Font.GothamMedium
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.TextYAlignment = Enum.TextYAlignment.Center
    valueText.Parent = header
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -4)
    track.BackgroundColor3 = Theme.Secondary
    track.BorderSizePixel = 0
    track.Parent = container
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = options.color or Theme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultValue - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    
    local dragging = false
    local currentValue = defaultValue
    
    local function updateSlider(value)
        currentValue = math.clamp(value, min, max)
        local ratio = (currentValue - min) / (max - min)
        
        valueText.Text = string.format(options.format or "%.1f", currentValue)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -6, 0.5, -6)
    end
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new((currentValue - min) / (max - min), -8, 0.5, -8)
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
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = UDim2.new((currentValue - min) / (max - min), -6, 0.5, -6)
        end
    end)
    
    self.layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
    
    return {
        getValue = function() return currentValue end,
        setValue = updateSlider
    }
end

function Cast:ComboBox(label, items, defaultIndex)
    local pos = self.layout:GetCursorPos()
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 30)
    container.Position = pos
    container.BackgroundColor3 = Theme.FrameBg
    container.BorderSizePixel = 0
    container.Parent = self.canvas
    
    local comboBtn = Instance.new("TextButton")
    comboBtn.Size = UDim2.new(1, 0, 1, 0)
    comboBtn.BackgroundTransparency = 1
    comboBtn.Text = ""
    comboBtn.AutoButtonColor = false
    comboBtn.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -30, 1, 0)
    labelText.Position = UDim2.new(0, 8, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = items[defaultIndex or 1] or label or "Select..."
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextYAlignment = Enum.TextYAlignment.Center
    labelText.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextDisabled
    arrow.TextSize = 12
    arrow.Font = Enum.Font.GothamMedium
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.Parent = container
    
    local dropdownOpen = false
    local dropdown
    
    local function closeDropdown()
        if dropdown then
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
        
        dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(1, 0, 0, #items * 30)
        dropdown.Position = UDim2.new(0, 0, 1, 1)
        dropdown.BackgroundColor3 = Theme.PopupBg
        dropdown.BorderSizePixel = 0
        dropdown.ClipsDescendants = true
        dropdown.ZIndex = 10
        dropdown.Parent = container
        
        for i, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*30)
            itemBtn.BackgroundColor3 = Theme.FrameBg
            itemBtn.Text = item
            itemBtn.TextColor3 = Theme.Text
            itemBtn.TextSize = 13
            itemBtn.Font = Enum.Font.GothamMedium
            itemBtn.AutoButtonColor = false
            itemBtn.ZIndex = 11
            itemBtn.Parent = dropdown
            
            itemBtn.MouseEnter:Connect(function()
                itemBtn.BackgroundColor3 = Theme.Primary
            end)
            
            itemBtn.MouseLeave:Connect(function()
                itemBtn.BackgroundColor3 = Theme.FrameBg
            end)
            
            itemBtn.MouseButton1Click:Connect(function()
                labelText.Text = item
                selectedIndex = i
                closeDropdown()
            end)
        end
    end)
    
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
        getIndex = function() return selectedIndex end
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
    line.BorderSizePixel = 0
    line.Parent = self.canvas
    
    self.layout:AdvanceCursor(line.AbsoluteSize.X, 4)
    
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

function Cast:SetVisibility(visible)
    self.window.Visible = visible
end

return Cast
