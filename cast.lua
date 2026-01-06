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
    
    self.create_main_frame()
    self.create_header()
    self.create_tab_container()
    self.create_content_area()
    
    return self
end

function Cast:createframe()
self.main_frame = Instance.new("Frame")
self.main_frame.Size = UDim2.new(0, 800, 0, 600)
self.main_frame.Position = UDim2.new(0.5, -400, 0.5, -300)
self.main_frame.BackgroundColor3 = self.palette.primary
self.main_frame.BorderSizePixel = 0
self.main_frame.ClipsDescendants = true
self.main_frame.Parent = self.screen_gui
Instance.new("UICorner", self.main_frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", self.main_frame).Color = self.palette.border
self:dragify(self.main_frame)
end

function Cast:create_header()
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
    
    local close_btn = Instance.new("TextButton")
    close_btn.Size = UDim2.new(0, 30, 0, 30)
    close_btn.Position = UDim2.new(1, -40, 0.5, -15)
    close_btn.BackgroundTransparency = 1
    close_btn.Text = "X"
    close_btn.TextColor3 = self.palette.text
    close_btn.TextSize = 18
    close_btn.Font = Enum.Font.GothamBold
    close_btn.Parent = header
    close_btn.MouseButton1Click:Connect(function() self:toggle_visibility() end)
    
    local minimize_btn = Instance.new("TextButton")
    minimize_btn.Size = UDim2.new(0, 30, 0, 30)
    minimize_btn.Position = UDim2.new(1, -80, 0.5, -15)
    minimize_btn.BackgroundTransparency = 1
    minimize_btn.Text = "_"
    minimize_btn.TextColor3 = self.palette.text
    minimize_btn.TextSize = 18
    minimize_btn.Font = Enum.Font.GothamBold
    minimize_btn.Parent = header
    minimize_btn.MouseButton1Click:Connect(function() self:toggle_minimize() end)
end

function Cast:create_tab_container()
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

function Cast:create_content_area()
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

function Cast:make_draggable(frame)
    local dragging, drag_input, start_pos, start_mouse
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start_mouse = input.Position
            start_pos = frame.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
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
        if dragging and input == drag_input then
            local delta = input.Position - start_mouse
            frame.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
        end
    end))
end

function Cast:add_tab(name)
    local tab = {name = name, sections = {}, content = nil, button = nil}
    table.insert(self.tabs, tab)
    
    local tab_button = Instance.new("TextButton")
    tab_button.Size = UDim2.new(0, 120, 1, 0)
    tab_button.BackgroundColor3 = self.palette.tab_inactive
    tab_button.Text = name
    tab_button.TextColor3 = self.palette.text
    tab_button.TextSize = 14
    tab_button.Font = Enum.Font.Gotham
    tab_button.Parent = self.tab_scrolling
    
    Instance.new("UICorner", tab_button).CornerRadius = UDim.new(0, 6)
    
    tab.button = tab_button
    
    tab_button.MouseButton1Click:Connect(function()
        self:switch_tab(tab)
    end)
    
    if #self.tabs == 1 then
        self:switch_tab(tab)
    end
    
    return tab
end

function Cast:switch_tab(tab)
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
        local tab_layout = Instance.new("UIListLayout")
        tab_layout.Padding = UDim.new(0, 10)
        tab_layout.Parent = tab.content
        tab_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.content.Size = UDim2.new(1, 0, 0, tab_layout.AbsoluteContentSize.Y)
        end)
    end
    
    tab.content.Parent = self.content_scrolling
end

function Cast:get_tab(name)
    for _, tab in ipairs(self.tabs) do
        if tab.name == name then return tab end
    end
end

function Cast:add_section(tab_name, title, collapsible)
    local tab = self:get_tab(tab_name)
    if not tab then return end
    
    local section = {title = title, collapsible = collapsible or false, expanded = true, elements = {}, frame = nil, content_frame = nil}
    table.insert(tab.sections, section)
    
    local section_frame = Instance.new("Frame")
    section_frame.Size = UDim2.new(1, 0, 0, 40)
    section_frame.BackgroundColor3 = self.palette.primary
    section_frame.Parent = tab.content
    
    Instance.new("UICorner", section_frame).CornerRadius = UDim.new(0, 6)
    
    local section_title = Instance.new("TextLabel")
    section_title.Size = UDim2.new(1, -40, 0, 40)
    section_title.Position = UDim2.new(0, 10, 0, 0)
    section_title.BackgroundTransparency = 1
    section_title.Text = title
    section_title.TextColor3 = self.palette.text
    section_title.TextSize = 16
    section_title.Font = Enum.Font.GothamBold
    section_title.TextXAlignment = Enum.TextXAlignment.Left
    section_title.Parent = section_frame
    
    local content_frame = Instance.new("Frame")
    content_frame.Size = UDim2.new(1, -20, 0, 0)
    content_frame.Position = UDim2.new(0, 10, 0, 40)
    content_frame.BackgroundTransparency = 1
    content_frame.ClipsDescendants = true
    content_frame.Parent = section_frame
    
    local content_layout = Instance.new("UIListLayout")
    content_layout.Padding = UDim.new(0, 5)
    content_layout.Parent = content_frame
    
    section.frame = section_frame
    section.content_frame = content_frame
    
    local function update_section_size()
        local height = 40 + (section.expanded and content_layout.AbsoluteContentSize.Y + 10 or 0)
        section_frame.Size = UDim2.new(1, 0, 0, height)
    end
    
    content_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_section_size)
    
    if collapsible then
        local toggle_btn = Instance.new("TextButton")
        toggle_btn.Size = UDim2.new(0, 30, 0, 40)
        toggle_btn.Position = UDim2.new(1, -40, 0, 0)
        toggle_btn.BackgroundTransparency = 1
        toggle_btn.Text = "▼"
        toggle_btn.TextColor3 = self.palette.text
        toggle_btn.TextSize = 16
        toggle_btn.Font = Enum.Font.GothamBold
        toggle_btn.Parent = section_frame
        
        toggle_btn.MouseButton1Click:Connect(function()
            section.expanded = not section.expanded
            toggle_btn.Text = section.expanded and "▼" or "▶"
            TweenService:Create(content_frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, section.expanded and content_layout.AbsoluteContentSize.Y or 0)}):Play()
            update_section_size()
        end)
    end
    update_section_size()
    
    return section
end

function Cast:add_label(section, text, is_secondary)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
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
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.palette.accent:Lerp(Color3.new(1,1,1), 0.1)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = self.palette.accent}):Play()
    end)
    
    table.insert(section.elements, button)
    return button
end

function Cast:add_toggle(section, text, default_value, callback)
    local toggle_frame = Instance.new("Frame")
    toggle_frame.Size = UDim2.new(1, 0, 0, 30)
    toggle_frame.BackgroundTransparency = 1
    toggle_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle_frame
    
    local toggle_button = Instance.new("Frame")
    toggle_button.Size = UDim2.new(0, 40, 0, 20)
    toggle_button.Position = UDim2.new(1, -40, 0.5, -10)
    toggle_button.BackgroundColor3 = self.palette.border
    toggle_button.Parent = toggle_frame
    
    Instance.new("UICorner", toggle_button).CornerRadius = UDim.new(1, 0)
    
    local toggle_knob = Instance.new("Frame")
    toggle_knob.Size = UDim2.new(0, 18, 0, 18)
    toggle_knob.Position = default_value and UDim2.new(1, -19, 0.5, -9) or UDim2.new(0, 1, 0.5, -9)
    toggle_knob.BackgroundColor3 = self.palette.text
    toggle_knob.Parent = toggle_button
    
    Instance.new("UICorner", toggle_knob).CornerRadius = UDim.new(1, 0)
    
    local state = default_value or false
    toggle_button.BackgroundColor3 = state and self.palette.success or self.palette.border
    
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = toggle_frame
    
    click.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle_knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -19, 0.5, -9) or UDim2.new(0, 1, 0.5, -9)}):Play()
        TweenService:Create(toggle_button, TweenInfo.new(0.15), {BackgroundColor3 = state and self.palette.success or self.palette.border}):Play()
        pcall(callback, state)
    end)
    
    table.insert(section.elements, toggle_frame)
    return toggle_frame
end

function Cast:add_dropdown(section, text, options, default_value, callback)
    local dropdown_frame = Instance.new("Frame")
    dropdown_frame.Size = UDim2.new(1, 0, 0, 30)
    dropdown_frame.BackgroundTransparency = 1
    dropdown_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdown_frame
    
    local selected_text = Instance.new("TextLabel")
    selected_text.Size = UDim2.new(0, 150, 0, 30)
    selected_text.Position = UDim2.new(1, -150, 0, 0)
    selected_text.BackgroundColor3 = self.palette.secondary
    selected_text.Text = default_value or options[1] or ""
    selected_text.TextColor3 = self.palette.text
    selected_text.TextSize = 14
    selected_text.Font = Enum.Font.Gotham
    selected_text.TextXAlignment = Enum.TextXAlignment.Center
    selected_text.Parent = dropdown_frame
    
    Instance.new("UICorner", selected_text).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", selected_text).Color = self.palette.border
    
    local dropdown_list = Instance.new("ScrollingFrame")
    dropdown_list.Size = UDim2.new(0, 150, 0, 0)
    dropdown_list.Position = UDim2.new(1, -150, 0, 30)
    dropdown_list.BackgroundColor3 = self.palette.secondary
    dropdown_list.BorderSizePixel = 0
    dropdown_list.ScrollBarThickness = 4
    dropdown_list.ScrollBarImageColor3 = self.palette.border
    dropdown_list.Visible = false
    dropdown_list.ClipsDescendants = true
    dropdown_list.Parent = dropdown_frame
    
    Instance.new("UICorner", dropdown_list).CornerRadius = UDim.new(0, 6)
    
    local list_layout = Instance.new("UIListLayout")
    list_layout.Padding = UDim.new(0, 2)
    list_layout.Parent = dropdown_list
    
    local function update_list_size()
        dropdown_list.CanvasSize = UDim2.new(0, 0, 0, list_layout.AbsoluteContentSize.Y)
        TweenService:Create(dropdown_list, TweenInfo.new(0.2), {Size = UDim2.new(0, 150, 0, math.min(150, list_layout.AbsoluteContentSize.Y))}):Play()
    end
    
    for _, option in ipairs(options) do
        local option_btn = Instance.new("TextButton")
        option_btn.Size = UDim2.new(0, 150, 0, 25)
        option_btn.BackgroundColor3 = self.palette.secondary
        option_btn.Text = option
        option_btn.TextColor3 = self.palette.text
        option_btn.TextSize = 14
        option_btn.Font = Enum.Font.Gotham
        option_btn.Parent = dropdown_list
        
        option_btn.MouseButton1Click:Connect(function()
            selected_text.Text = option
            dropdown_list.Visible = false
            pcall(callback, option)
        end)
        
        option_btn.MouseEnter:Connect(function()
            option_btn.BackgroundColor3 = self.palette.accent
        end)
        
        option_btn.MouseLeave:Connect(function()
            option_btn.BackgroundColor3 = self.palette.secondary
        end)
    end
    
    update_list_size()
    
    selected_text.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dropdown_list.Visible = not dropdown_list.Visible
        end
    end)
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdown_list.Visible then
            if not dropdown_frame:IsAncestorOf(Mouse.Target) and not dropdown_list:IsAncestorOf(Mouse.Target) then
                dropdown_list.Visible = false
            end
        end
    end))
    
    table.insert(section.elements, dropdown_frame)
    return dropdown_frame
end

function Cast:add_color_picker(section, text, default_color, callback)
    local color_picker_frame = Instance.new("Frame")
    color_picker_frame.Size = UDim2.new(1, 0, 0, 30)
    color_picker_frame.BackgroundTransparency = 1
    color_picker_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = color_picker_frame
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 40, 0, 20)
    preview.Position = UDim2.new(1, -40, 0.5, -10)
    preview.BackgroundColor3 = default_color or Color3.new(1, 1, 1)
    preview.Parent = color_picker_frame
    
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", preview).Color = self.palette.border
    
    local picker_modal = Instance.new("Frame")
    picker_modal.Size = UDim2.new(0, 250, 0, 220)
    picker_modal.Position = UDim2.new(0.5, -125, 0.5, -110)
    picker_modal.BackgroundColor3 = self.palette.primary
    picker_modal.Visible = false
    picker_modal.ZIndex = 10
    picker_modal.Parent = self.screen_gui
    
    Instance.new("UICorner", picker_modal).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", picker_modal).Color = self.palette.border
    
    local sv_square = Instance.new("Frame")
    sv_square.Size = UDim2.new(0, 200, 0, 150)
    sv_square.Position = UDim2.new(0, 25, 0, 25)
    sv_square.BackgroundColor3 = Color3.new(1, 1, 1)
    sv_square.Parent = picker_modal
    
    Instance.new("UICorner", sv_square).CornerRadius = UDim.new(0, 4)
    
    local sv_gradient_h = Instance.new("UIGradient")
    sv_gradient_h.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 0, 0))
    sv_gradient_h.Rotation = 0
    sv_gradient_h.Parent = sv_square
    
    local sv_gradient_v = Instance.new("UIGradient")
    sv_gradient_v.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
    sv_gradient_v.Transparency = NumberSequence.new(0, 1)
    sv_gradient_v.Rotation = 90
    sv_gradient_v.Parent = sv_square
    
    local sv_knob = Instance.new("Frame")
    sv_knob.Size = UDim2.new(0, 10, 0, 10)
    sv_knob.BackgroundColor3 = Color3.new(1, 1, 1)
    sv_knob.BorderSizePixel = 2
    sv_knob.BorderColor3 = Color3.new(0, 0, 0)
    sv_knob.Parent = sv_square
    
    Instance.new("UICorner", sv_knob).CornerRadius = UDim.new(1, 0)
    
    local hue_slider = Instance.new("Frame")
    hue_slider.Size = UDim2.new(0, 200, 0, 15)
    hue_slider.Position = UDim2.new(0, 25, 0, 185)
    hue_slider.BackgroundColor3 = Color3.new(1, 1, 1)
    hue_slider.Parent = picker_modal
    
    Instance.new("UICorner", hue_slider).CornerRadius = UDim.new(0, 4)
    
    local hue_gradient = Instance.new("UIGradient")
    hue_gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.new(1, 1, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
        ColorSequenceKeypoint.new(0.667, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
    }
    hue_gradient.Parent = hue_slider
    
    local hue_knob = Instance.new("Frame")
    hue_knob.Size = UDim2.new(0, 4, 1, 4)
    hue_knob.Position = UDim2.new(0, 0, 0, -2)
    hue_knob.BackgroundColor3 = Color3.new(1, 1, 1)
    hue_knob.BorderSizePixel = 2
    hue_knob.BorderColor3 = Color3.new(0, 0, 0)
    hue_knob.Parent = hue_slider
    
    Instance.new("UICorner", hue_knob).CornerRadius = UDim.new(0, 2)
    
    local current_color = default_color or Color3.new(1, 0, 0)
    local h, s, v = current_color:ToHSV()
    
    local function update_color()
        current_color = Color3.fromHSV(h, s, v)
        preview.BackgroundColor3 = current_color
        sv_gradient_h.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
    end
    
    local function set_knobs()
        sv_knob.Position = UDim2.new(s, -5, 1 - v, -5)
        hue_knob.Position = UDim2.new(h, -2, 0, -2)
    end
    set_knobs()
    
    local sv_dragging = false
    sv_square.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sv_dragging = true
        end
    end)
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if sv_dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = Vector2.new(
                math.clamp((input.Position.X - sv_square.AbsolutePosition.X) / sv_square.AbsoluteSize.X, 0, 1),
                math.clamp((input.Position.Y - sv_square.AbsolutePosition.Y) / sv_square.AbsoluteSize.Y, 0, 1)
            )
            s = rel.X
            v = 1 - rel.Y
            set_knobs()
            update_color()
            pcall(callback, current_color)
        end
    end))
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sv_dragging = false end
    end))
    
    local hue_dragging = false
    hue_slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hue_dragging = true
        end
    end)
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if hue_dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            h = math.clamp((input.Position.X - hue_slider.AbsolutePosition.X) / hue_slider.AbsoluteSize.X, 0, 1)
            set_knobs()
            update_color()
            pcall(callback, current_color)
        end
    end))
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then hue_dragging = false end
    end))
    
    preview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            picker_modal.Visible = not picker_modal.Visible
        end
    end)
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and picker_modal.Visible then
            if not picker_modal:IsAncestorOf(Mouse.Target) then
                picker_modal.Visible = false
            end
        end
    end))
    
    table.insert(section.elements, color_picker_frame)
    return color_picker_frame
end

function Cast:add_status(section, label_text, get_value_func, update_interval)
    local status_frame = Instance.new("Frame")
    status_frame.Size = UDim2.new(1, 0, 0, 30)
    status_frame.BackgroundTransparency = 1
    status_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = label_text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = status_frame
    
    local status_dot = Instance.new("Frame")
    status_dot.Size = UDim2.new(0, 12, 0, 12)
    status_dot.Position = UDim2.new(1, -30, 0.5, -6)
    status_dot.BackgroundColor3 = self.palette.error
    status_dot.Parent = status_frame
    
    Instance.new("UICorner", status_dot).CornerRadius = UDim.new(1, 0)
    
    if get_value_func then
        local function update()
            local success, value = pcall(get_value_func)
            if success then
                status_dot.BackgroundColor3 = value and self.palette.success or self.palette.error
            else
                status_dot.BackgroundColor3 = self.palette.warning
            end
        end
        update()
        local conn = RunService.Heartbeat:Connect(function(dt)
            local timer = (status_frame:GetAttribute("timer") or 0) + dt
            if timer >= (update_interval or 1) then
                update()
                timer = 0
            end
            status_frame:SetAttribute("timer", timer)
        end)
        table.insert(self.connections, conn)
    end
    
    table.insert(section.elements, status_frame)
    return status_frame
end

function Cast:add_slider(section, label_text, min_value, max_value, default_value, callback)
    local slider_frame = Instance.new("Frame")
    slider_frame.Size = UDim2.new(1, 0, 0, 50)
    slider_frame.BackgroundTransparency = 1
    slider_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
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
    slider_back.Position = UDim2.new(0, 0, 1, -15)
    slider_back.BackgroundColor3 = self.palette.border
    slider_back.Parent = slider_frame
    
    Instance.new("UICorner", slider_back).CornerRadius = UDim.new(1, 0)
    
    local slider_fill = Instance.new("Frame")
    slider_fill.Size = UDim2.new(0, 0, 1, 0)
    slider_fill.BackgroundColor3 = self.palette.accent
    slider_fill.Parent = slider_back
    
    Instance.new("UICorner", slider_fill).CornerRadius = UDim.new(1, 0)
    
    local value = default_value or min_value
    local function update_visuals()
        local percent = (value - min_value) / (max_value - min_value)
        slider_fill.Size = UDim2.new(percent, 0, 1, 0)
        value_label.Text = tostring(value)
    end
    update_visuals()
    
    local dragging = false
    slider_back.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relative = math.clamp((input.Position.X - slider_back.AbsolutePosition.X) / slider_back.AbsoluteSize.X, 0, 1)
            value = math.round(min_value + (max_value - min_value) * relative)
            update_visuals()
            pcall(callback, value)
        end
    end)
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relative = math.clamp((input.Position.X - slider_back.AbsolutePosition.X) / slider_back.AbsoluteSize.X, 0, 1)
            value = math.round(min_value + (max_value - min_value) * relative)
            update_visuals()
            pcall(callback, value)
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    
    table.insert(section.elements, slider_frame)
    return slider_frame
end

function Cast:add_keybind_display(section, text)
    local keybind_frame = Instance.new("Frame")
    keybind_frame.Size = UDim2.new(1, 0, 0, 30)
    keybind_frame.BackgroundTransparency = 1
    keybind_frame.Parent = section.content_frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.palette.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybind_frame
    
    local held_keys_label = Instance.new("TextLabel")
    held_keys_label.Size = UDim2.new(0, 150, 0, 30)
    held_keys_label.Position = UDim2.new(1, -150, 0, 0)
    held_keys_label.BackgroundColor3 = self.palette.secondary
    held_keys_label.Text = "|"
    held_keys_label.TextColor3 = self.palette.text
    held_keys_label.TextSize = 14
    held_keys_label.Font = Enum.Font.Gotham
    held_keys_label.TextXAlignment = Enum.TextXAlignment.Center
    held_keys_label.Parent = keybind_frame
    
    Instance.new("UICorner", held_keys_label).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", held_keys_label).Color = self.palette.border
    
    local held_keys = {}
    local input_blacklist = {["R"] = true, ["T"] = true, ["F"] = true, ["G"] = true, ["E"] = true}
    
    local function update_display()
        held_keys_label.Text = "|"
        for key, _ in pairs(held_keys) do
            held_keys_label.Text = held_keys_label.Text .. key .. "|"
        end
    end
    
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key_name = input.KeyCode.Name
            if not input_blacklist[key_name] then
                held_keys[key_name] = true
                update_display()
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            held_keys["MB1"] = true
            update_display()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            held_keys["MB2"] = true
            update_display()
        elseif input.UserInputType == Enum.UserInputType.MouseWheel then
            if input.Position.Z > 0 then
                held_keys["WheelUp"] = true
            else
                held_keys["WheelDown"] = true
            end
            update_display()
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key_name = input.KeyCode.Name
            held_keys[key_name] = nil
            update_display()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            held_keys["MB1"] = nil
            update_display()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            held_keys["MB2"] = nil
            update_display()
        elseif input.UserInputType == Enum.UserInputType.MouseWheel then
            held_keys["WheelUp"] = nil
            held_keys["WheelDown"] = nil
            update_display()
        end
    end))
    
    table.insert(section.elements, keybind_frame)
    return keybind_frame
end

function Cast:toggle_visibility()
    self.visible = not self.visible
    self.screen_gui.Enabled = self.visible
end

function Cast:toggle_minimize()
    self.minimized = not self.minimized
    local target_height = self.minimized and 100 or 600
    TweenService:Create(self.main_frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 800, 0, target_height)}):Play()
end

function Cast:change_theme(palette_name)
    self.palette = Palettes[palette_name] or Palettes.Base
    
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
