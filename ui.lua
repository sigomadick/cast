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
    self.elements = {}
    self.visible = true
    self.connections = {}
    
    self.screen_gui = Instance.new("ScreenGui")
    self.screen_gui.Name = "CastUI"
    self.screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screen_gui.ResetOnSpawn = false
    self.screen_gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    self:create_main_frame()
    self:create_header()
    self:create_tab_container()
    self:create_content_area()
    
    return self
end

function Cast:create_main_frame()
    self.main_frame = Instance.new("Frame")
    self.main_frame.Size = UDim2.new(0, 800, 0, 600)
    self.main_frame.Position = UDim2.new(0.5, -400, 0.5, -300)
    self.main_frame.BackgroundColor3 = self.palette.primary
    self.main_frame.BorderSizePixel = 0
    self.main_frame.Parent = self.screen_gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.main_frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.palette.border
    stroke.Thickness = 2
    stroke.Parent = self.main_frame
    
    self:draggable(self.main_frame)
end

function Cast:create_header()
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -20, 0, 50)
    header.Position = UDim2.new(0, 10, 0, 10)
    header.BackgroundColor3 = self.palette.secondary
    header.BorderSizePixel = 0
    header.Parent = self.main_frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.title
    title.TextColor3 = self.palette.text
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local close_btn = Instance.new("TextButton")
    close_btn.Size = UDim2.new(0, 30, 0, 30)
    close_btn.Position = UDim2.new(1, -40, 0.5, -15)
    close_btn.BackgroundTransparency = 1
    close_btn.Text = "X"
    close_btn.TextColor3 = self.palette.text
    close_btn.TextSize = 18
    close_btn.Font = Enum.Font.GothamBold
    close_btn.Parent = header
    
    close_btn.MouseButton1Click:Connect(function()
        self:toggle_visibility()
    end)
    
    local minimize_btn = Instance.new("TextButton")
    minimize_btn.Size = UDim2.new(0, 30, 0, 30)
    minimize_btn.Position = UDim2.new(1, -80, 0.5, -15)
    minimize_btn.BackgroundTransparency = 1
    minimize_btn.Text = "_"
    minimize_btn.TextColor3 = self.palette.text
    minimize_btn.TextSize = 18
    minimize_btn.Font = Enum.Font.GothamBold
    minimize_btn.Parent = header
    
    minimize_btn.MouseButton1Click:Connect(function()
        self:minimize()
    end)
end

function Cast:create_tab_container()
    self.tab_container = Instance.new("Frame")
    self.tab_container.Size = UDim2.new(1, -20, 0, 50)
    self.tab_container.Position = UDim2.new(0, 10, 0, 70)
    self.tab_container.BackgroundColor3 = self.palette.secondary
    self.tab_container.BorderSizePixel = 0
    self.tab_container.Parent = self.main_frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.tab_container
    
    self.tab_list = Instance.new("Frame")
    self.tab_list.Size = UDim2.new(1, 0, 0, 40)
    self.tab_list.BackgroundTransparency = 1
    self.tab_list.Parent = self.tab_container
    
    local list_layout = Instance.new("UIListLayout")
    list_layout.FillDirection = Enum.FillDirection.Horizontal
    list_layout.Padding = UDim.new(0, 5)
    list_layout.Parent = self.tab_list
end

function Cast:create_content_area()
    self.content_area = Instance.new("Frame")
    self.content_area.Size = UDim2.new(1, -20, 1, -140)
    self.content_area.Position = UDim2.new(0, 10, 0, 130)
    self.content_area.BackgroundColor3 = self.palette.secondary
    self.content_area.BorderSizePixel = 0
    self.content_area.ClipsDescendants = true
    self.content_area.Parent = self.main_frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.content_area
    
    self.content_scrolling = Instance.new("ScrollingFrame")
    self.content_scrolling.Size = UDim2.new(1, -20, 1, -20)
    self.content_scrolling.Position = UDim2.new(0, 10, 0, 10)
    self.content_scrolling.BackgroundTransparency = 1
    self.content_scrolling.BorderSizePixel = 0
    self.content_scrolling.ScrollBarThickness = 8
    self.content_scrolling.ScrollBarImageColor3 = self.palette.accent
    self.content_scrolling.Parent = self.content_area
    
    local content_layout = Instance.new("UIListLayout")
    content_layout.Padding = UDim.new(0, 15)
    content_layout.Parent = self.content_scrolling
    
    content_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.content_scrolling.CanvasSize = UDim2.new(0, 0, 0, content_layout.AbsoluteContentSize.Y)
    end)
end

function Cast:draggable(frame)
    local dragging = false
    local drag_input, mouse_pos, frame_pos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mouse_pos = input.Position
            frame_pos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            drag_input = input
        end
    end)
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if input == drag_input and dragging then
            local delta = input.Position - mouse_pos
            frame.Position = UDim2.new(
                frame_pos.X.Scale, 
                frame_pos.X.Offset + delta.X,
                frame_pos.Y.Scale,
                frame_pos.Y.Offset + delta.Y
            )
        end
    end))
end

function Cast:add_tab(name)
    local tab = {
        name = name,
        sections = {},
        content = nil
    }
    
    table.insert(self.tabs, tab)
    
    local tab_button = Instance.new("TextButton")
    tab_button.Size = UDim2.new(0, 120, 0, 40)
    tab_button.BackgroundColor3 = self.palette.tab_inactive
    tab_button.Text = name
    tab_button.TextColor3 = self.palette.text
    tab_button.TextSize = 14
    tab_button.Font = Enum.Font.Gotham
    tab_button.Parent = self.tab_list
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tab_button
    
    if #self.tabs == 1 then
        tab_button.BackgroundColor3 = self.palette.tab_active
        self.current_tab = tab
        self:switch_tab(tab)
    end
    
    tab_button.MouseButton1Click:Connect(function()
        for _, other_tab in ipairs(self.tabs) do
        end
        tab_button.BackgroundColor3 = self.palette.tab_active
        self.current_tab = tab
        self:switch_tab(tab)
    end)
    
    return tab
end

function Cast:add_section(tab_name, title, collapsible)
    local tab = self:get_tab(tab_name)
    if not tab then return end
    
    local section = {
        title = title,
        collapsible = collapsible or false,
        expanded = true,
        elements = {}
    }
    
    table.insert(tab.sections, section)
    
    if not tab.content then
        tab.content = Instance.new("Frame")
        tab.content.Size = UDim2.new(1, 0, 1, 0)
        tab.content.BackgroundTransparency = 1
        tab.content.Parent = self.content_scrolling
    end
    
    local section_frame = Instance.new("Frame")
    section_frame.Size = UDim2.new(1, 0, 0, 50)
    section_frame.Position = UDim2.new(0, 0, 0, #tab.sections * 60 - 60)
    section_frame.BackgroundColor3 = self.palette.primary
    section_frame.BorderSizePixel = 0
    section_frame.Parent = tab.content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = section_frame
    
    local section_title = Instance.new("TextLabel")
    section_title.Size = UDim2.new(1, -40, 0, 30)
    section_title.Position = UDim2.new(0, 20, 0, 10)
    section_title.BackgroundTransparency = 1
    section_title.Text = title
    section_title.TextColor3 = self.palette.text
    section_title.TextSize = 16
    section_title.Font = Enum.Font.GothamBold
    section_title.TextXAlignment = Enum.TextXAlignment.Left
    section_title.Parent = section_frame
    
    if collapsible then
        local toggle_btn = Instance.new("TextButton")
        toggle_btn.Size = UDim2.new(0, 30, 0, 30)
        toggle_btn.Position = UDim2.new(1, -40, 0, 10)
        toggle_btn.BackgroundTransparency = 1
        toggle_btn.Text = "V"
        toggle_btn.TextColor3 = self.palette.text
        toggle_btn.TextSize = 16
        toggle_btn.Font = Enum.Font.GothamBold
        toggle_btn.Parent = section_frame
        
        section.content_frame = Instance.new("Frame")
        section.content_frame.Size = UDim2.new(1, -20, 0, 0)
        section.content_frame.Position = UDim2.new(0, 10, 0, 50)
        section.content_frame.BackgroundColor3 = self.palette.secondary
        section.content_frame.BorderSizePixel = 0
        section.content_frame.Visible = true
        section.content_frame.Parent = section_frame
        
        local content_corner = Instance.new("UICorner")
        content_corner.CornerRadius = UDim.new(0, 6)
        content_corner.Parent = section.content_frame
        
        toggle_btn.MouseButton1Click:Connect(function()
            section.expanded = not section.expanded
            section.content_frame.Visible = section.expanded
            toggle_btn.Text = section.expanded and "V" or ">"
        end)
    else
        section.content_frame = Instance.new("Frame")
        section.content_frame.Size = UDim2.new(1, -20, 1, -60)
        section.content_frame.Position = UDim2.new(0, 10, 0, 50)
        section.content_frame.BackgroundColor3 = self.palette.secondary
        section.content_frame.BorderSizePixel = 0
        section.content_frame.Parent = section_frame
        
        local content_corner = Instance.new("UICorner")
        content_corner.CornerRadius = UDim.new(0, 6)
        content_corner.Parent = section.content_frame
    end
    
    return section
end

function Cast:add_label(section, text, is_secondary)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, #section.elements * 30 + 10)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = is_secondary and self.palette.text_secondary or self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section.content_frame
    
    table.insert(section.elements, label)
    return label
end

function Cast:add_button(section, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Position = UDim2.new(0, 10, 0, #section.elements * 45 + 10)
    button.BackgroundColor3 = self.palette.accent
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = section.content_frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = self.palette.accent:Lerp(Color3.new(1, 1, 1), 0.2)
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

function Cast:add_toggle(section, text, default_value, callback)
    local toggle_frame = Instance.new("Frame")
    toggle_frame.Size = UDim2.new(1, -20, 0, 35)
    toggle_frame.Position = UDim2.new(0, 10, 0, #section.elements * 45 + 10)
    toggle_frame.BackgroundTransparency = 1
    toggle_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle_frame
    
    local toggle_button = Instance.new("TextButton")
    toggle_button.Size = UDim2.new(0, 50, 0, 25)
    toggle_button.Position = UDim2.new(1, -60, 0.5, -12.5)
    toggle_button.BackgroundColor3 = default_value and self.palette.success or self.palette.secondary
    toggle_button.Text = ""
    toggle_button.Parent = toggle_frame
    
    local toggle_corner = Instance.new("UICorner")
    toggle_corner.CornerRadius = UDim.new(0, 12)
    toggle_corner.Parent = toggle_button
    
    local toggle_knob = Instance.new("Frame")
    toggle_knob.Size = UDim2.new(0, 21, 0, 21)
    toggle_knob.Position = default_value and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    toggle_knob.BackgroundColor3 = Color3.new(1, 1, 1)
    toggle_knob.Parent = toggle_button
    
    local knob_corner = Instance.new("UICorner")
    knob_corner.CornerRadius = UDim.new(0, 10)
    knob_corner.Parent = toggle_knob
    
    local state = default_value or false
    
    toggle_button.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(toggle_knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
        }):Play()
        
        TweenService:Create(toggle_button, TweenInfo.new(0.2), {
            BackgroundColor3 = state and self.palette.success or self.palette.secondary
        }):Play()
        
        if callback then
            callback(state)
        end
    end)
    
    table.insert(section.elements, toggle_frame)
    return toggle_frame
end

function Cast:add_status(section, label_text, get_value_func, update_interval)
    local status_frame = Instance.new("Frame")
    status_frame.Size = UDim2.new(1, -20, 0, 30)
    status_frame.Position = UDim2.new(0, 10, 0, #section.elements * 40 + 10)
    status_frame.BackgroundTransparency = 1
    status_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = label_text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = status_frame
    
    local status_dot = Instance.new("Frame")
    status_dot.Size = UDim2.new(0, 12, 0, 12)
    status_dot.Position = UDim2.new(1, -40, 0.5, -6)
    status_dot.BackgroundColor3 = self.palette.error
    status_dot.Parent = status_frame
    
    local dot_corner = Instance.new("UICorner")
    dot_corner.CornerRadius = UDim.new(0, 6)
    dot_corner.Parent = status_dot
    
    local status_text = Instance.new("TextLabel")
    status_text.Size = UDim2.new(0, 50, 1, 0)
    status_text.Position = UDim2.new(1, -25, 0, 0)
    status_text.BackgroundTransparency = 1
    status_text.Text = "Offline"
    status_text.TextColor3 = self.palette.error
    status_text.TextSize = 12
    status_text.Font = Enum.Font.Gotham
    status_text.TextXAlignment = Enum.TextXAlignment.Right
    status_text.Parent = status_frame
    
    if get_value_func then
        local interval = update_interval or 0.1
        table.insert(self.connections, RunService.Heartbeat:Connect(function()
            local value = get_value_func()
            if value then
                status_dot.BackgroundColor3 = self.palette.success
                status_text.Text = "Online"
                status_text.TextColor3 = self.palette.success
            else
                status_dot.BackgroundColor3 = self.palette.error
                status_text.Text = "Offline"
                status_text.TextColor3 = self.palette.error
            end
        end))
    end
    
    table.insert(section.elements, status_frame)
    return status_frame
end

function Cast:add_slider(section, label_text, min_value, max_value, default_value, callback)
    local slider_frame = Instance.new("Frame")
    slider_frame.Size = UDim2.new(1, -20, 0, 50)
    slider_frame.Position = UDim2.new(0, 10, 0, #section.elements * 55 + 10)
    slider_frame.BackgroundTransparency = 1
    slider_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = label_text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider_frame
    
    local value_label = Instance.new("TextLabel")
    value_label.Size = UDim2.new(0, 60, 0, 20)
    value_label.Position = UDim2.new(1, -60, 0, 0)
    value_label.BackgroundTransparency = 1
    value_label.Text = tostring(default_value or min_value)
    value_label.TextColor3 = self.palette.text_secondary
    value_label.TextSize = 14
    value_label.Font = Enum.Font.Gotham
    value_label.TextXAlignment = Enum.TextXAlignment.Right
    value_label.Parent = slider_frame
    
    local slider_back = Instance.new("Frame")
    slider_back.Size = UDim2.new(1, 0, 0, 6)
    slider_back.Position = UDim2.new(0, 0, 0, 25)
    slider_back.BackgroundColor3 = self.palette.secondary
    slider_back.BorderSizePixel = 0
    slider_back.Parent = slider_frame
    
    local back_corner = Instance.new("UICorner")
    back_corner.CornerRadius = UDim.new(0, 3)
    back_corner.Parent = slider_back
    
    local slider_fill = Instance.new("Frame")
    local percent = ((default_value or min_value) - min_value) / (max_value - min_value)
    slider_fill.Size = UDim2.new(percent, 0, 1, 0)
    slider_fill.Position = UDim2.new(0, 0, 0, 0)
    slider_fill.BackgroundColor3 = self.palette.accent
    slider_fill.BorderSizePixel = 0
    slider_fill.Parent = slider_back
    
    local fill_corner = Instance.new("UICorner")
    fill_corner.CornerRadius = UDim.new(0, 3)
    fill_corner.Parent = slider_fill
    
    local slider_knob = Instance.new("TextButton")
    slider_knob.Size = UDim2.new(0, 16, 0, 16)
    slider_knob.Position = UDim2.new(percent, -8, 0.5, -8)
    slider_knob.BackgroundColor3 = Color3.new(1, 1, 1)
    slider_knob.Text = ""
    slider_knob.Parent = slider_back
    
    local knob_corner = Instance.new("UICorner")
    knob_corner.CornerRadius = UDim.new(0, 8)
    knob_corner.Parent = slider_knob
    
    local dragging = false
    
    local function update_slider(x_pos)
        local relative_x = math.clamp(x_pos - slider_back.AbsolutePosition.X, 0, slider_back.AbsoluteSize.X)
        local percent = relative_x / slider_back.AbsoluteSize.X
        local value = min_value + (max_value - min_value) * percent
        value = math.floor(value)
        
        slider_fill.Size = UDim2.new(percent, 0, 1, 0)
        slider_knob.Position = UDim2.new(percent, -8, 0.5, -8)
        value_label.Text = tostring(value)
        
        if callback then
            callback(value)
        end
    end
    
    slider_knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update_slider(input.Position.X)
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    
    slider_back.MouseButton1Down:Connect(function(x, y)
        update_slider(x)
    end)
    
    table.insert(section.elements, slider_frame)
    return slider_frame
end

function Cast:switch_tab(tab)
    if self.current_content then
        self.current_content.Visible = false
    end
    
    if tab.content then
        tab.content.Visible = true
        self.current_content = tab.content
    end
end

function Cast:get_tab(name)
    for _, tab in ipairs(self.tabs) do
        if tab.name == name then
            return tab
        end
    end
    return nil
end

function Cast:toggle_visibility()
    self.visible = not self.visible
    self.main_frame.Visible = self.visible
    
    if self.visible then
        TweenService:Create(self.main_frame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 800, 0, 600)
        }):Play()
    end
end

function Cast:minimize()
    TweenService:Create(self.main_frame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 800, 0, 70)
    }):Play()
end

function Cast:changetheme(palette_name)
    self.palette = Palettes[palette_name] or Palettes.Base
    
    local function apply_theme(element)
        if element:IsA("Frame") then
            if element.Name == "MainFrame" or element.Name == "CastUI" then
                element.BackgroundColor3 = self.palette.primary
            else
                element.BackgroundColor3 = self.palette.secondary
            end
        elseif element:IsA("TextLabel") then
            if string.find(element.Text, "Offline") or string.find(element.Text, "Online") then
            else
                element.TextColor3 = self.palette.text
            end
        elseif element:IsA("UIStroke") then
            element.Color = self.palette.border
        elseif element:IsA("ScrollingFrame") then
            element.ScrollBarImageColor3 = self.palette.accent
        end
        
        for _, child in ipairs(element:GetChildren()) do
            apply_theme(child)
        end
    end
    
    apply_theme(self.screen_gui)
end

function Cast:destroy()
    for _, connection in ipairs(self.connections) do
        connection:Disconnect()
    end
    
    if self.screen_gui then
        self.screen_gui:Destroy()
    end
end

return Cast
