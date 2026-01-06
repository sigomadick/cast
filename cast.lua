local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Palettes = {
    Base = {
        primary = Color3.fromRGB(38, 38, 48),
        secondary = Color3.fromRGB(48, 48, 58),
        accent = Color3.fromRGB(65, 105, 225),
        text = Color3.fromRGB(240, 240, 245),
        text_secondary = Color3.fromRGB(180, 180, 200),
        border = Color3.fromRGB(60, 60, 75),
        success = Color3.fromRGB(76, 175, 80),
        warning = Color3.fromRGB(255, 193, 7),
        error = Color3.fromRGB(244, 67, 54),
        tab_active = Color3.fromRGB(65, 105, 225),
        tab_inactive = Color3.fromRGB(55, 55, 70)
    },
    Midnight = {
        primary = Color3.fromRGB(25, 25, 35),
        secondary = Color3.fromRGB(35, 35, 45),
        accent = Color3.fromRGB(0, 200, 255),
        text = Color3.fromRGB(230, 230, 240),
        text_secondary = Color3.fromRGB(160, 160, 180),
        border = Color3.fromRGB(50, 50, 65),
        success = Color3.fromRGB(0, 200, 100),
        warning = Color3.fromRGB(255, 150, 0),
        error = Color3.fromRGB(255, 50, 50),
        tab_active = Color3.fromRGB(0, 200, 255),
        tab_inactive = Color3.fromRGB(40, 40, 55)
    },
    Carbon = {
        primary = Color3.fromRGB(20, 20, 25),
        secondary = Color3.fromRGB(30, 30, 35),
        accent = Color3.fromRGB(255, 87, 34),
        text = Color3.fromRGB(235, 235, 245),
        text_secondary = Color3.fromRGB(170, 170, 190),
        border = Color3.fromRGB(50, 50, 55),
        success = Color3.fromRGB(76, 175, 80),
        warning = Color3.fromRGB(255, 193, 7),
        error = Color3.fromRGB(244, 67, 54),
        tab_active = Color3.fromRGB(255, 87, 34),
        tab_inactive = Color3.fromRGB(40, 40, 45)
    }
}

local Cast = {}
Cast.__index = Cast

function Cast.new(title, palette_name)
    local self = setmetatable({}, Cast)
    
    self.title = title or "Cast"
    self.palette = Palettes[palette_name] or Palettes.Base
    self.tabs = {}
    self.current_tab = nil
    self.visible = true
    self.minimized = false
    self.connections = {}
    
    self.screen_gui = Instance.new("ScreenGui")
    self.screen_gui.Name = "CastUI"
    self.screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screen_gui.ResetOnSpawn = false
    self.screen_gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    self:createMainFrame()
    self:createHeader()
    self:createTabContainer()
    self:createContentArea()
    
    return self
end

function Cast:createMainFrame()
    self.main_frame = Instance.new("Frame")
    self.main_frame.Size = UDim2.new(0, 800, 0, 600)
    self.main_frame.Position = UDim2.new(0.5, -400, 0.5, -300)
    self.main_frame.BackgroundColor3 = self.palette.primary
    self.main_frame.BorderSizePixel = 0
    self.main_frame.ClipsDescendants = true
    self.main_frame.Parent = self.screen_gui
    
    Instance.new("UICorner", self.main_frame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", self.main_frame).Color = self.palette.border
    
    self:makeDraggable(self.main_frame)
end

function Cast:createHeader()
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = self.palette.secondary
    header.Parent = self.main_frame
    
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.title
    title.TextColor3 = self.palette.text
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = self.palette.text
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function() self:toggleVisibility() end)
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -80, 0.5, -15)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = self.palette.text
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    minimizeBtn.MouseButton1Click:Connect(function() self:toggleMinimize() end)
end

function Cast:createTabContainer()
    self.tab_container = Instance.new("Frame")
    self.tab_container.Size = UDim2.new(1, 0, 0, 50)
    self.tab_container.Position = UDim2.new(0, 0, 0, 50)
    self.tab_container.BackgroundColor3 = self.palette.secondary
    self.tab_container.Parent = self.main_frame
    
    Instance.new("UICorner", self.tab_container).CornerRadius = UDim.new(0, 6)
    
    self.tab_scrolling = Instance.new("ScrollingFrame")
    self.tab_scrolling.Size = UDim2.new(1, -10, 1, -10)
    self.tab_scrolling.Position = UDim2.new(0, 5, 0, 5)
    self.tab_scrolling.BackgroundTransparency = 1
    self.tab_scrolling.ScrollBarThickness = 0
    self.tab_scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.tab_scrolling.Parent = self.tab_container
    
    local tab_layout = Instance.new("UIListLayout")
    tab_layout.FillDirection = Enum.FillDirection.Horizontal
    tab_layout.Padding = UDim.new(0, 5)
    tab_layout.Parent = self.tab_scrolling
    
    tab_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.tab_scrolling.CanvasSize = UDim2.new(0, tab_layout.AbsoluteContentSize.X, 0, 0)
    end)
end

function Cast:createContentArea()
    self.content_area = Instance.new("Frame")
    self.content_area.Size = UDim2.new(1, 0, 1, -100)
    self.content_area.Position = UDim2.new(0, 0, 0, 100)
    self.content_area.BackgroundColor3 = self.palette.secondary
    self.content_area.ClipsDescendants = true
    self.content_area.Parent = self.main_frame
    
    Instance.new("UICorner", self.content_area).CornerRadius = UDim.new(0, 6)
    
    self.content_scrolling = Instance.new("ScrollingFrame")
    self.content_scrolling.Size = UDim2.new(1, 0, 1, 0)
    self.content_scrolling.BackgroundTransparency = 1
    self.content_scrolling.ScrollBarThickness = 6
    self.content_scrolling.ScrollBarImageColor3 = self.palette.border
    self.content_scrolling.Parent = self.content_area
    
    self.content_layout = Instance.new("UIListLayout")
    self.content_layout.Padding = UDim.new(0, 10)
    self.content_layout.Parent = self.content_scrolling
    
    self.content_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.content_scrolling.CanvasSize = UDim2.new(0, 0, 0, self.content_layout.AbsoluteContentSize.Y)
    end)
end

function Cast:makeDraggable(frame)
    local dragging, dragInput, startPos, startMouse
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = frame.Position
            local conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

function Cast:addTab(name)
    local tab = {name = name, sections = {}, content = nil, button = nil}
    table.insert(self.tabs, tab)
    
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 120, 1, 0)
    tabButton.BackgroundColor3 = self.palette.tab_inactive
    tabButton.Text = name
    tabButton.TextColor3 = self.palette.text
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.tab_scrolling
    
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)
    
    tab.button = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        self:switchTab(tab)
    end)
    
    if #self.tabs == 1 then
        self:switchTab(tab)
    end
    
    return tab
end

function Cast:switchTab(tab)
    if self.current_tab then
        self.current_tab.button.BackgroundColor3 = self.palette.tab_inactive
        if self.current_tab.content then
            self.current_tab.content.Parent = nil
        end
    end
    
    tab.button.BackgroundColor3 = self.palette.tab_active
    self.current_tab = tab
    
    if not tab.content then
        tab.content = Instance.new("Frame")
        tab.content.Size = UDim2.new(1, 0, 0, 0)
        tab.content.BackgroundTransparency = 1
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 10)
        tabLayout.Parent = tab.content
        
        tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.content.Size = UDim2.new(1, 0, 0, tabLayout.AbsoluteContentSize.Y)
        end)
    end
    
    tab.content.Parent = self.content_scrolling
end

function Cast:getTab(name)
    for _, tab in ipairs(self.tabs) do
        if tab.name == name then return tab end
    end
end

function Cast:addSection(tabName, title, collapsible)
    local tab = self:getTab(tabName)
    if not tab then return end
    
    local section = {
        title = title,
        collapsible = collapsible or false,
        expanded = true,
        elements = {},
        frame = nil,
        content_frame = nil
    }
    table.insert(tab.sections, section)
    
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 40)
    sectionFrame.BackgroundColor3 = self.palette.primary
    sectionFrame.Parent = tab.content
    
    Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, -40, 0, 40)
    sectionTitle.Position = UDim2.new(0, 10, 0, 0)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = title
    sectionTitle.TextColor3 = self.palette.text
    sectionTitle.TextSize = 16
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = sectionFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 0, 0)
    contentFrame.Position = UDim2.new(0, 10, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = sectionFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.Parent = contentFrame
    
    section.frame = sectionFrame
    section.content_frame = contentFrame
    
    local function updateSectionSize()
        local height = 40 + (section.expanded and contentLayout.AbsoluteContentSize.Y + 10 or 0)
        sectionFrame.Size = UDim2.new(1, 0, 0, height)
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
    
    if collapsible then
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 30, 0, 40)
        toggleBtn.Position = UDim2.new(1, -40, 0, 0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = "▼"
        toggleBtn.TextColor3 = self.palette.text
        toggleBtn.TextSize = 16
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = sectionFrame
        
        toggleBtn.MouseButton1Click:Connect(function()
            section.expanded = not section.expanded
            toggleBtn.Text = section.expanded and "▼" or "▶"
            TweenService:Create(contentFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(1, -20, 0, section.expanded and contentLayout.AbsoluteContentSize.Y or 0)
            }):Play()
            updateSectionSize()
        end)
    end
    
    updateSectionSize()
    return section
end

function Cast:addLabel(section, text, isSecondary)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = isSecondary and self.palette.text_secondary or self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section.content_frame
    
    table.insert(section.elements, label)
    return label
end

function Cast:addButton(section, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = self.palette.accent
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = section.content_frame
    
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    
    button.MouseButton1Click:Connect(function()
        pcall(callback or function() end)
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = self.palette.accent:Lerp(Color3.new(1, 1, 1), 0.1)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = self.palette.accent
        }):Play()
    end)
    
    table.insert(section.elements, button)
    return button
end

function Cast:addToggle(section, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    toggleButton.BackgroundColor3 = self.palette.border
    toggleButton.Parent = toggleFrame
    
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = defaultValue and UDim2.new(1, -19, 0.5, -9) or UDim2.new(0, 1, 0.5, -9)
    toggleKnob.BackgroundColor3 = self.palette.text
    toggleKnob.Parent = toggleButton
    
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)
    
    local state = defaultValue or false
    toggleButton.BackgroundColor3 = state and self.palette.success or self.palette.border
    
    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = toggleFrame
    
    clickButton.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggleKnob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -19, 0.5, -9) or UDim2.new(0, 1, 0.5, -9)
        }):Play()
        TweenService:Create(toggleButton, TweenInfo.new(0.15), {
            BackgroundColor3 = state and self.palette.success or self.palette.border
        }):Play()
        pcall(callback, state)
    end)
    
    table.insert(section.elements, toggleFrame)
    return toggleFrame
end

function Cast:addDropdown(section, text, options, defaultValue, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(0, 150, 0, 30)
    selectedText.Position = UDim2.new(1, -150, 0, 0)
    selectedText.BackgroundColor3 = self.palette.secondary
    selectedText.Text = defaultValue or options[1] or ""
    selectedText.TextColor3 = self.palette.text
    selectedText.TextSize = 14
    selectedText.Font = Enum.Font.Gotham
    selectedText.TextXAlignment = Enum.TextXAlignment.Center
    selectedText.Parent = dropdownFrame
    
    Instance.new("UICorner", selectedText).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", selectedText).Color = self.palette.border
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(0, 150, 0, 0)
    dropdownList.Position = UDim2.new(1, -150, 0, 30)
    dropdownList.BackgroundColor3 = self.palette.secondary
    dropdownList.BorderSizePixel = 0
    dropdownList.ScrollBarThickness = 4
    dropdownList.ScrollBarImageColor3 = self.palette.border
    dropdownList.Visible = false
    dropdownList.ClipsDescendants = true
    dropdownList.Parent = dropdownFrame
    
    Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 6)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList
    
    local function updateListSize()
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        TweenService:Create(dropdownList, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 150, 0, math.min(150, listLayout.AbsoluteContentSize.Y))
        }):Play()
    end
    
    for _, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(0, 150, 0, 25)
        optionBtn.BackgroundColor3 = self.palette.secondary
        optionBtn.Text = option
        optionBtn.TextColor3 = self.palette.text
        optionBtn.TextSize = 14
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.Parent = dropdownList
        
        optionBtn.MouseButton1Click:Connect(function()
            selectedText.Text = option
            dropdownList.Visible = false
            pcall(callback, option)
        end)
        
        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundColor3 = self.palette.accent
        end)
        
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundColor3 = self.palette.secondary
        end)
    end
    
    updateListSize()
    
    selectedText.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dropdownList.Visible = not dropdownList.Visible
        end
    end)
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownList.Visible then
            if not dropdownFrame:IsAncestorOf(Mouse.Target) and not dropdownList:IsAncestorOf(Mouse.Target) then
                dropdownList.Visible = false
            end
        end
    end))
    
    table.insert(section.elements, dropdownFrame)
    return dropdownFrame
end

function Cast:addColorPicker(section, text, defaultColor, callback)
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Size = UDim2.new(1, 0, 0, 30)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorPickerFrame
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 40, 0, 20)
    preview.Position = UDim2.new(1, -40, 0.5, -10)
    preview.BackgroundColor3 = defaultColor or Color3.new(1, 1, 1)
    preview.Parent = colorPickerFrame
    
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", preview).Color = self.palette.border
    
    local pickerModal = Instance.new("Frame")
    pickerModal.Size = UDim2.new(0, 250, 0, 220)
    pickerModal.Position = UDim2.new(0.5, -125, 0.5, -110)
    pickerModal.BackgroundColor3 = self.palette.primary
    pickerModal.Visible = false
    pickerModal.ZIndex = 10
    pickerModal.Parent = self.screen_gui
    
    Instance.new("UICorner", pickerModal).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", pickerModal).Color = self.palette.border
    
    local svSquare = Instance.new("Frame")
    svSquare.Size = UDim2.new(0, 200, 0, 150)
    svSquare.Position = UDim2.new(0, 25, 0, 25)
    svSquare.BackgroundColor3 = Color3.new(1, 1, 1)
    svSquare.Parent = pickerModal
    
    Instance.new("UICorner", svSquare).CornerRadius = UDim.new(0, 4)
    
    local svGradientH = Instance.new("UIGradient")
    svGradientH.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 0, 0))
    svGradientH.Rotation = 0
    svGradientH.Parent = svSquare
    
    local svGradientV = Instance.new("UIGradient")
    svGradientV.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
    svGradientV.Transparency = NumberSequence.new(0, 1)
    svGradientV.Rotation = 90
    svGradientV.Parent = svSquare
    
    local svKnob = Instance.new("Frame")
    svKnob.Size = UDim2.new(0, 10, 0, 10)
    svKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    svKnob.BorderSizePixel = 2
    svKnob.BorderColor3 = Color3.new(0, 0, 0)
    svKnob.Parent = svSquare
    
    Instance.new("UICorner", svKnob).CornerRadius = UDim.new(1, 0)
    
    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(0, 200, 0, 15)
    hueSlider.Position = UDim2.new(0, 25, 0, 185)
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.Parent = pickerModal
    
    Instance.new("UICorner", hueSlider).CornerRadius = UDim.new(0, 4)
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.new(1, 1, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
        ColorSequenceKeypoint.new(0.667, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
    }
    hueGradient.Parent = hueSlider
    
    local hueKnob = Instance.new("Frame")
    hueKnob.Size = UDim2.new(0, 4, 1, 4)
    hueKnob.Position = UDim2.new(0, 0, 0, -2)
    hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    hueKnob.BorderSizePixel = 2
    hueKnob.BorderColor3 = Color3.new(0, 0, 0)
    hueKnob.Parent = hueSlider
    
    Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 2)
    
    local currentColor = defaultColor or Color3.new(1, 0, 0)
    local h, s, v = currentColor:ToHSV()
    
    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)
        preview.BackgroundColor3 = currentColor
        svGradientH.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
    end
    
    local function setKnobs()
        svKnob.Position = UDim2.new(s, -5, 1 - v, -5)
        hueKnob.Position = UDim2.new(h, -2, 0, -2)
    end
    
    setKnobs()
    
    local svDragging = false
    svSquare.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
        end
    end)
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = Vector2.new(
                math.clamp((input.Position.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1),
                math.clamp((input.Position.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
            )
            s = rel.X
            v = 1 - rel.Y
            setKnobs()
            updateColor()
            pcall(callback, currentColor)
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
    end))
    
    local hueDragging = false
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
        end
    end)
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            h = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
            setKnobs()
            updateColor()
            pcall(callback, currentColor)
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
    end))
    
    preview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            pickerModal.Visible = not pickerModal.Visible
        end
    end)
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and pickerModal.Visible then
            if not pickerModal:IsAncestorOf(Mouse.Target) then
                pickerModal.Visible = false
            end
        end
    end))
    
    table.insert(section.elements, colorPickerFrame)
    return colorPickerFrame
end

function Cast:addStatus(section, labelText, getValueFunc, updateInterval)
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 30)
    statusFrame.BackgroundTransparency = 1
    statusFrame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = statusFrame
    
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 12, 0, 12)
    statusDot.Position = UDim2.new(1, -30, 0.5, -6)
    statusDot.BackgroundColor3 = self.palette.error
    statusDot.Parent = statusFrame
    
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
    
    if getValueFunc then
        local function update()
            local success, value = pcall(getValueFunc)
            if success then
                statusDot.BackgroundColor3 = value and self.palette.success or self.palette.error
            else
                statusDot.BackgroundColor3 = self.palette.warning
            end
        end
        update()
        local conn = RunService.Heartbeat:Connect(function(dt)
            local timer = (statusFrame:GetAttribute("timer") or 0) + dt
            if timer >= (updateInterval or 1) then
                update()
                timer = 0
            end
            statusFrame:SetAttribute("timer", timer)
        end)
        table.insert(self.connections, conn)
    end
    
    table.insert(section.elements, statusFrame)
    return statusFrame
end

function Cast:addSlider(section, labelText, minValue, maxValue, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or minValue)
    valueLabel.TextColor3 = self.palette.text_secondary
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, 0, 0, 6)
    sliderBack.Position = UDim2.new(0, 0, 1, -15)
    sliderBack.BackgroundColor3 = self.palette.border
    sliderBack.Parent = sliderFrame
    
    Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = self.palette.accent
    sliderFill.Parent = sliderBack
    
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local value = defaultValue or minValue
    local function updateVisuals()
        local percent = (value - minValue) / (maxValue - minValue)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(value)
    end
    
    updateVisuals()
    
    local dragging = false
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relative = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            value = math.round(minValue + (maxValue - minValue) * relative)
            updateVisuals()
            pcall(callback, value)
        end
    end)
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relative = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            value = math.round(minValue + (maxValue - minValue) * relative)
            updateVisuals()
            pcall(callback, value)
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    
    table.insert(section.elements, sliderFrame)
    return sliderFrame
end

function Cast:addKeybindDisplay(section, text)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 0, 30)
    keybindFrame.BackgroundTransparency = 1
    keybindFrame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybindFrame
    
    local heldKeysLabel = Instance.new("TextLabel")
    heldKeysLabel.Size = UDim2.new(0, 150, 0, 30)
    heldKeysLabel.Position = UDim2.new(1, -150, 0, 0)
    heldKeysLabel.BackgroundColor3 = self.palette.secondary
    heldKeysLabel.Text = "|"
    heldKeysLabel.TextColor3 = self.palette.text
    heldKeysLabel.TextSize = 14
    heldKeysLabel.Font = Enum.Font.Gotham
    heldKeysLabel.TextXAlignment = Enum.TextXAlignment.Center
    heldKeysLabel.Parent = keybindFrame
    
    Instance.new("UICorner", heldKeysLabel).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", heldKeysLabel).Color = self.palette.border
    
    local heldKeys = {}
    local inputBlacklist = {["R"] = true, ["T"] = true, ["F"] = true, ["G"] = true, ["E"] = true}
    
    local function updateDisplay()
        heldKeysLabel.Text = "|"
        for key, _ in pairs(heldKeys) do
            heldKeysLabel.Text = heldKeysLabel.Text .. key .. "|"
        end
    end
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = input.KeyCode.Name
            if not inputBlacklist[keyName] then
                heldKeys[keyName] = true
                updateDisplay()
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            heldKeys["MB1"] = true
            updateDisplay()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            heldKeys["MB2"] = true
            updateDisplay()
        elseif input.UserInputType == Enum.UserInputType.MouseWheel then
            if input.Position.Z > 0 then
                heldKeys["WheelUp"] = true
            else
                heldKeys["WheelDown"] = true
            end
            updateDisplay()
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = input.KeyCode.Name
            heldKeys[keyName] = nil
            updateDisplay()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            heldKeys["MB1"] = nil
            updateDisplay()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            heldKeys["MB2"] = nil
            updateDisplay()
        elseif input.UserInputType == Enum.UserInputType.MouseWheel then
            heldKeys["WheelUp"] = nil
            heldKeys["WheelDown"] = nil
            updateDisplay()
        end
    end))
    
    table.insert(section.elements, keybindFrame)
    return keybindFrame
end

function Cast:toggleVisibility()
    self.visible = not self.visible
    self.screen_gui.Enabled = self.visible
end

function Cast:toggleMinimize()
    self.minimized = not self.minimized
    local targetHeight = self.minimized and 100 or 600
    TweenService:Create(self.main_frame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 800, 0, targetHeight)
    }):Play()
end

function Cast:changeTheme(paletteName)
    self.palette = Palettes[paletteName] or Palettes.Base
    
    local function apply(element)
        if element:IsA("Frame") then
            if element == self.main_frame then
                element.BackgroundColor3 = self.palette.primary
            elseif element.BackgroundColor3 == self.old_palette.secondary then
                element.BackgroundColor3 = self.palette.secondary
            elseif element.BackgroundColor3 == self.old_palette.accent then
                element.BackgroundColor3 = self.palette.accent
            elseif element.BackgroundColor3 == self.old_palette.success then
                element.BackgroundColor3 = self.palette.success
            elseif element.BackgroundColor3 == self.old_palette.error then
                element.BackgroundColor3 = self.palette.error
            elseif element.BackgroundColor3 == self.old_palette.border then
                element.BackgroundColor3 = self.palette.border
            end
        elseif element:IsA("TextLabel") or element:IsA("TextButton") then
            if element.TextColor3 == self.old_palette.text then
                element.TextColor3 = self.palette.text
            elseif element.TextColor3 == self.old_palette.text_secondary then
                element.TextColor3 = self.palette.text_secondary
            elseif element.TextColor3 == self.old_palette.success then
                element.TextColor3 = self.palette.success
            elseif element.TextColor3 == self.old_palette.error then
                element.TextColor3 = self.palette.error
            end
        elseif element:IsA("UIStroke") then
            element.Color = self.palette.border
        elseif element:IsA("ScrollingFrame") then
            element.ScrollBarImageColor3 = self.palette.border
        end
        
        for _, child in ipairs(element:GetChildren()) do
            apply(child)
        end
    end
    
    self.old_palette = self.palette
    apply(self.screen_gui)
    
    for _, tab in ipairs(self.tabs) do
        tab.button.BackgroundColor3 = (tab == self.current_tab) and self.palette.tab_active or self.palette.tab_inactive
    end
end

function Cast:destroy()
    for _, conn in ipairs(self.connections) do 
        pcall(function() conn:Disconnect() end) 
    end
    self.screen_gui:Destroy()
end

return Cast
