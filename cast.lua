local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

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
    }
}

local Cast = {}
Cast.__index = Cast

print("Cast UI Loaded")

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

function Cast:addCheckbox(section, text, defaultValue, callback)
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Size = UDim2.new(1, 0, 0, 30)
    checkboxFrame.BackgroundTransparency = 1
    checkboxFrame.Parent = section.content_frame
   
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkboxFrame
   
    local checkboxButton = Instance.new("TextButton")
    checkboxButton.Size = UDim2.new(0, 40, 0, 20)
    checkboxButton.Position = UDim2.new(1, -50, 0.5, -10)
    checkboxButton.BackgroundColor3 = self.palette.border
    checkboxButton.Text = ""
    checkboxButton.Parent = checkboxFrame
   
    Instance.new("UICorner", checkboxButton).CornerRadius = UDim.new(0, 4)
   
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = self.palette.text
    checkmark.TextSize = 14
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Visible = defaultValue or false
    checkmark.Parent = checkboxButton
   
    local state = defaultValue or false
   
    if state then
        checkboxButton.BackgroundColor3 = self.palette.accent
    end
   
    checkboxButton.MouseButton1Click:Connect(function()
        state = not state
        checkmark.Visible = state
        if state then
            checkboxButton.BackgroundColor3 = self.palette.accent
        else
            checkboxButton.BackgroundColor3 = self.palette.border
        end
        pcall(callback, state)
    end)
   
    table.insert(section.elements, checkboxFrame)
    return checkboxFrame
end

function Cast:addTextBox(section, placeholder, callback)
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Size = UDim2.new(1, 0, 0, 35)
    textboxFrame.BackgroundTransparency = 1
    textboxFrame.Parent = section.content_frame
   
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.BackgroundColor3 = self.palette.primary
    textBox.Text = ""
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = self.palette.text
    textBox.PlaceholderColor3 = self.palette.text_secondary
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.Parent = textboxFrame
   
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", textBox).Color = self.palette.border
   
    textBox.Focused:Connect(function()
        TweenService:Create(textBox, TweenInfo.new(0.1), {
            BackgroundColor3 = self.palette.primary:Lerp(Color3.new(1, 1, 1), 0.1)
        }):Play()
    end)
   
    textBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textBox, TweenInfo.new(0.1), {
            BackgroundColor3 = self.palette.primary
        }):Play()
        if enterPressed then
            pcall(callback, textBox.Text)
        end
    end)
   
    table.insert(section.elements, textboxFrame)
    return textboxFrame
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

function Cast:destroy()
    for _, conn in ipairs(self.connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.screen_gui:Destroy()
end

return Cast
