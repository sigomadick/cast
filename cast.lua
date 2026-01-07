local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Theme = {
window_bg = Color3.new(0.06, 0.06, 0.08),
child_bg = Color3.new(0.08, 0.08, 0.1),
popup_bg = Color3.new(0.1, 0.1, 0.12),
border = Color3.new(0.16, 0.16, 0.2),
frame_bg = Color3.new(0.12, 0.12, 0.16),
frame_bg_hovered = Color3.new(0.16, 0.16, 0.22),
frame_bg_active = Color3.new(0.18, 0.18, 0.24),
title_bg = Color3.new(0.1, 0.1, 0.14),
title_bg_active = Color3.new(0.12, 0.12, 0.18),
button = Color3.new(0.14, 0.14, 0.2),
button_hovered = Color3.new(0.2, 0.2, 0.28),
button_active = Color3.new(0.18, 0.18, 0.26),
text = Color3.new(0.86, 0.86, 0.86),
text_disabled = Color3.new(0.47, 0.47, 0.47),
header = Color3.new(0.16, 0.16, 0.22),
separator = Color3.new(0.2, 0.2, 0.26),
slider_grab = Color3.new(0.24, 0.47, 0.78),
slider_grab_active = Color3.new(0.27, 0.55, 0.86),
check_mark = Color3.new(0.24, 0.47, 0.78),
}
local Imgui = {}
Imgui.__index = Imgui
local layout = {
cursor = {x = 8, y = 8},
indent = 0,
same_line = false,
last_width = 0,
line_height = 0,
group_stack = {}
}
function layout:begin_group(padding)
table.insert(self.group_stack, {x = self.cursor.x, y = self.cursor.y, indent = self.indent})
self.cursor.x = self.cursor.x + (padding or 8)
self.cursor.y = self.cursor.y + (padding or 4)
self.indent = self.indent + 8
return #self.group_stack
end
function layout:end_group()
if #self.group_stack > 0 then
local last = table.remove(self.group_stack)
self.cursor.x = last.x
self.cursor.y = last.y + self.line_height + 8
self.indent = last.indent
self.line_height = 0
end
end
function layout:same_line(spacing)
if spacing then
self.cursor.x = self.cursor.x + spacing
end
self.same_line = true
end
function layout:get_cursor_pos()
if self.same_line then
self.same_line = false
return UDim2.new(0, self.cursor.x + self.last_width + 4, 0, self.cursor.y)
end
return UDim2.new(0, self.cursor.x, 0, self.cursor.y)
end
function layout:advance_cursor(width, height)
if not self.same_line then
self.last_width = width
if height > self.line_height then
self.line_height = height
end
self.cursor.y = self.cursor.y + height + 4
else
self.cursor.x = self.cursor.x + width + 4
if height > self.line_height then
self.line_height = height
end
end
end
function Imgui.new(title)
local self = setmetatable({}, Imgui)
self.title = title or "Menu"
self.open = true
self.alpha = 1
self.gui = Instance.new("ScreenGui")
self.gui.Name = "MenuGui"
self.gui.ResetOnSpawn = false
self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
self.gui.Parent = PlayerGui
self.window = Instance.new("Frame")
self.window.Size = UDim2.new(0, 450, 0, 500)
self.window.Position = UDim2.new(0.5, -225, 0.5, -250)
self.window.BackgroundColor3 = Theme.window_bg
self.window.BorderSizePixel = 0
self.window.ClipsDescendants = true
self.window.Parent = self.gui
local frame_stroke = Instance.new("UIStroke")
frame_stroke.Color = Theme.border
frame_stroke.Thickness = 1
frame_stroke.Parent = self.window
self.title_bar = Instance.new("Frame")
self.title_bar.Size = UDim2.new(1, 0, 0, 24)
self.title_bar.BackgroundColor3 = Theme.title_bg
self.title_bar.BorderSizePixel = 0
self.title_bar.Parent = self.window
local title_label = Instance.new("TextLabel")
title_label.Size = UDim2.new(1, -40, 1, 0)
title_label.Position = UDim2.new(0, 8, 0, 0)
title_label.BackgroundTransparency = 1
title_label.Text = self.title
title_label.TextColor3 = Theme.text
title_label.TextSize = 14
title_label.Font = Enum.Font.SourceSans
title_label.TextXAlignment = Enum.TextXAlignment.Left
title_label.TextYAlignment = Enum.TextYAlignment.Center
title_label.Parent = self.title_bar
local close_btn = Instance.new("TextButton")
close_btn.Size = UDim2.new(0, 24, 0, 24)
close_btn.Position = UDim2.new(1, -24, 0, 0)
close_btn.BackgroundColor3 = Color3.new(0.78, 0.2, 0.2)
close_btn.Text = "×"
close_btn.TextColor3 = Color3.new(1,1,1)
close_btn.TextSize = 16
close_btn.Font = Enum.Font.SourceSansBold
close_btn.Parent = self.title_bar
close_btn.MouseButton1Click:Connect(function()
self:destroy()
end)
self.content = Instance.new("ScrollingFrame")
self.content.Size = UDim2.new(1, -16, 1, -40)
self.content.Position = UDim2.new(0, 8, 0, 32)
self.content.BackgroundTransparency = 1
self.content.ScrollBarThickness = 4
self.content.ScrollBarImageColor3 = Theme.border
self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
self.content.Parent = self.window
self.canvas = Instance.new("Frame")
self.canvas.Size = UDim2.new(1, 0, 0, 0)
self.canvas.BackgroundTransparency = 1
self.canvas.Parent = self.content
local dragging = false
local start_pos
local start_mouse
self.window.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
start_mouse = input.Position
start_pos = self.window.Position
end
end)
self.window.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
local delta = input.Position - start_mouse
self.window.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
end
end)
return self
end
function Imgui:begin()
layout.cursor = {x = 8, y = 8}
layout.indent = 0
layout.same_line = false
layout.last_width = 0
layout.line_height = 0
layout.group_stack = {}
end
function Imgui:begin_child(name, size, border)
local group_id = layout:begin_group(4)
local pos = layout:get_cursor_pos()
local child = Instance.new("Frame")
child.Size = size or UDim2.new(1, -16, 0, 100)
child.Position = pos
child.BackgroundColor3 = Theme.child_bg
if border then
local stroke = Instance.new("UIStroke")
stroke.Color = Theme.border
stroke.Thickness = 1
stroke.Parent = child
end
if name then
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -8, 0, 18)
label.Position = UDim2.new(0, 4, 0, 2)
label.BackgroundTransparency = 1
label.Text = name
label.TextColor3 = Theme.text
label.TextSize = 12
label.Font = Enum.Font.SourceSans
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = child
layout.cursor.y = layout.cursor.y + 20
end
child.Parent = self.canvas
layout:advance_cursor(child.Size.X.Offset, child.Size.Y.Offset)
return child
end
function Imgui:end_child()
layout:end_group()
end
function Imgui:separator()
local pos = layout:get_cursor_pos()
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -16, 0, 1)
line.Position = pos
line.BackgroundColor3 = Theme.separator
line.BorderSizePixel = 0
line.Parent = self.canvas
layout:advance_cursor(line.Size.X.Offset, 2)
end
function Imgui:spacing()
local pos = layout:get_cursor_pos()
local space = Instance.new("Frame")
space.Size = UDim2.new(1, 0, 0, 8)
space.Position = pos
space.BackgroundTransparency = 1
space.Parent = self.canvas
layout:advance_cursor(space.Size.X.Offset, 8)
end
function Imgui:text(text)
local pos = layout:get_cursor_pos()
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -16, 0, 20)
label.Position = pos
label.BackgroundTransparency = 1
label.Text = text
label.TextColor3 = Theme.text
label.TextSize = 14
label.Font = Enum.Font.SourceSans
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.Parent = self.canvas
layout:advance_cursor(label.Size.X.Offset, 20)
return label
end
function Imgui:button(label, size)
local pos = layout:get_cursor_pos()
local btn = Instance.new("TextButton")
btn.Size = size or UDim2.new(0, 0, 0, 24)
btn.Position = pos
btn.BackgroundColor3 = Theme.button
btn.Text = label
btn.TextColor3 = Theme.text
btn.TextSize = 14
btn.Font = Enum.Font.SourceSans
btn.AutoButtonColor = false
btn.Parent = self.canvas
if not size then
local text_size = TextService:GetTextSize(label, 14, Enum.Font.SourceSans, Vector2.new(1000, 100))
btn.Size = UDim2.new(0, text_size.X + 16, 0, 24)
end
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.button_hovered}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.button}):Play()
end)
btn.MouseButton1Down:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3 = Theme.button_active}):Play()
end)
btn.MouseButton1Up:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.button_hovered}):Play()
end)
layout:advance_cursor(btn.Size.X.Offset, btn.Size.Y.Offset)
return btn
end
function Imgui:checkbox(label, checked)
local pos = layout:get_cursor_pos()
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -16, 0, 20)
frame.Position = pos
frame.BackgroundTransparency = 1
frame.Parent = self.canvas
local checked = checked or false
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 18, 0, 18)
btn.Position = UDim2.new(0, 0, 0.5, -9)
btn.BackgroundColor3 = checked and Theme.slider_grab or Theme.frame_bg
btn.Text = checked and "✓" or ""
btn.TextColor3 = Theme.check_mark
btn.TextSize = 14
btn.Font = Enum.Font.SourceSansBold
btn.AutoButtonColor = false
btn.Parent = frame
btn.MouseButton1Click:Connect(function()
checked = not checked
btn.Text = checked and "✓" or ""
btn.BackgroundColor3 = checked and Theme.slider_grab or Theme.frame_bg
end)
local text_label = Instance.new("TextLabel")
text_label.Size = UDim2.new(1, -24, 1, 0)
text_label.Position = UDim2.new(0, 24, 0, 0)
text_label.BackgroundTransparency = 1
text_label.Text = label
text_label.TextColor3 = Theme.text
text_label.TextSize = 14
text_label.Font = Enum.Font.SourceSans
text_label.TextXAlignment = Enum.TextXAlignment.Left
text_label.TextYAlignment = Enum.TextYAlignment.Center
text_label.Parent = frame
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {
BackgroundColor3 = checked and Theme.slider_grab_active or Theme.frame_bg_hovered
}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {
BackgroundColor3 = checked and Theme.slider_grab or Theme.frame_bg
}):Play()
end)
layout:advance_cursor(frame.Size.X.Offset, frame.Size.Y.Offset)
return btn, function() return checked end
end
function Imgui:input_text(label, text, width)
local pos = layout:get_cursor_pos()
if label then
local label_frame = Instance.new("TextLabel")
label_frame.Size = UDim2.new(1, -16, 0, 18)
label_frame.Position = pos
label_frame.BackgroundTransparency = 1
label_frame.Text = label
label_frame.TextColor3 = Theme.text
label_frame.TextSize = 14
label_frame.Font = Enum.Font.SourceSans
label_frame.TextXAlignment = Enum.TextXAlignment.Left
label_frame.Parent = self.canvas
layout:advance_cursor(label_frame.Size.X.Offset, 18)
pos = layout:get_cursor_pos()
end
local input = Instance.new("TextBox")
input.Size = width or UDim2.new(1, -16, 0, 24)
input.Position = pos
input.BackgroundColor3 = Theme.frame_bg
input.Text = text or ""
input.PlaceholderText = label or "Enter text..."
input.PlaceholderColor3 = Theme.text_disabled
input.TextColor3 = Theme.text
input.TextSize = 14
input.Font = Enum.Font.SourceSans
input.ClearTextOnFocus = false
input.Parent = self.canvas
local stroke = Instance.new("UIStroke")
stroke.Color = Theme.border
stroke.Thickness = 1
stroke.Parent = input
input.Focused:Connect(function()
TweenService:Create(stroke, TweenInfo.new(0.1), {Color = Theme.slider_grab}):Play()
TweenService:Create(input, TweenInfo.new(0.1), {BackgroundColor3 = Theme.frame_bg_hovered}):Play()
end)
input.FocusLost:Connect(function()
TweenService:Create(stroke, TweenInfo.new(0.1), {Color = Theme.border}):Play()
TweenService:Create(input, TweenInfo.new(0.1), {BackgroundColor3 = Theme.frame_bg}):Play()
end)
layout:advance_cursor(input.Size.X.Offset, input.Size.Y.Offset)
return input, function() return input.Text end
end
function Imgui:slider_float(label, value, min, max, format)
local pos = layout:get_cursor_pos()
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 40)
container.Position = pos
container.BackgroundTransparency = 1
container.Parent = self.canvas
local text_label = Instance.new("TextLabel")
text_label.Size = UDim2.new(1, 0, 0, 18)
text_label.Position = UDim2.new(0, 0, 0, 0)
text_label.BackgroundTransparency = 1
text_label.Text = label
text_label.TextColor3 = Theme.text
text_label.TextSize = 14
text_label.Font = Enum.Font.SourceSans
text_label.TextXAlignment = Enum.TextXAlignment.Left
text_label.Parent = container
local value_label = Instance.new("TextLabel")
value_label.Size = UDim2.new(0, 60, 0, 18)
value_label.Position = UDim2.new(1, -60, 0, 0)
value_label.BackgroundTransparency = 1
value_label.Text = string.format(format or "%.2f", value)
value_label.TextColor3 = Theme.text
value_label.TextSize = 14
value_label.Font = Enum.Font.SourceSans
value_label.TextXAlignment = Enum.TextXAlignment.Right
value_label.Parent = container
local slider_track = Instance.new("Frame")
slider_track.Size = UDim2.new(1, 0, 0, 4)
slider_track.Position = UDim2.new(0, 0, 0, 26)
slider_track.BackgroundColor3 = Theme.frame_bg
slider_track.BorderSizePixel = 0
slider_track.Parent = container
local slider_fill = Instance.new("Frame")
slider_fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
slider_fill.BackgroundColor3 = Theme.slider_grab
slider_fill.BorderSizePixel = 0
slider_fill.Parent = slider_track
local slider_btn = Instance.new("TextButton")
slider_btn.Size = UDim2.new(0, 12, 0, 12)
slider_btn.Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6)
slider_btn.BackgroundColor3 = Color3.new(1,1,1)
slider_btn.Text = ""
slider_btn.Parent = slider_track
local dragging = false
local current_value = value
local function update_slider(mouse_x)
local relative_x = (mouse_x - slider_track.AbsolutePosition.X) / slider_track.AbsoluteSize.X
relative_x = math.clamp(relative_x, 0, 1)
current_value = min + (max - min) * relative_x
current_value = math.floor(current_value * 100) / 100
slider_fill.Size = UDim2.new(relative_x, 0, 1, 0)
slider_btn.Position = UDim2.new(relative_x, -6, 0.5, -6)
value_label.Text = string.format(format or "%.2f", current_value)
end
slider_btn.MouseButton1Down:Connect(function()
dragging = true
TweenService:Create(slider_btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16)}):Play()
TweenService:Create(slider_btn, TweenInfo.new(0.1), {Position = UDim2.new((current_value - min) / (max - min), -8, 0.5, -8)}):Play()
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
TweenService:Create(slider_btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 12)}):Play()
TweenService:Create(slider_btn, TweenInfo.new(0.1), {Position = UDim2.new((current_value - min) / (max - min), -6, 0.5, -6)}):Play()
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
update_slider(input.Position.X)
end
end)
slider_track.MouseButton1Down:Connect(function()
local mouse = UserInputService:GetMouseLocation()
update_slider(mouse.X)
dragging = true
end)
layout:advance_cursor(container.Size.X.Offset, container.Size.Y.Offset)
return function() return current_value end
end
function Imgui:combo(label, current_item, items)
local pos = layout:get_cursor_pos()
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 24)
container.Position = pos
container.BackgroundTransparency = 1
container.Parent = self.canvas
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 1, 0)
btn.BackgroundColor3 = Theme.button
btn.Text = items[current_item or 1] or label or "Select..."
btn.TextColor3 = Theme.text
btn.TextSize = 14
btn.Font = Enum.Font.SourceSans
btn.AutoButtonColor = false
btn.Parent = container
local arrow = Instance.new("TextLabel")
arrow.Size = UDim2.new(0, 16, 1, 0)
arrow.Position = UDim2.new(1, -20, 0, 0)
arrow.BackgroundTransparency = 1
arrow.Text = "▼"
arrow.TextColor3 = Theme.text_disabled
arrow.TextSize = 12
arrow.Font = Enum.Font.SourceSans
arrow.TextYAlignment = Enum.TextYAlignment.Center
arrow.Parent = container
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 24)
padding.Parent = btn
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.button_hovered}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.button}):Play()
end)
local dropdown_open = false
local dropdown
btn.MouseButton1Click:Connect(function()
if dropdown_open then
if dropdown then dropdown:Destroy() end
dropdown_open = false
return
end
dropdown_open = true
dropdown = Instance.new("Frame")
dropdown.Size = UDim2.new(1, 0, 0, #items * 24 + 4)
dropdown.Position = UDim2.new(0, 0, 1, 2)
dropdown.BackgroundColor3 = Theme.popup_bg
dropdown.BorderSizePixel = 0
dropdown.ZIndex = 10
dropdown.Parent = container
for i, item in ipairs(items) do
local item_btn = Instance.new("TextButton")
item_btn.Size = UDim2.new(1, -4, 0, 22)
item_btn.Position = UDim2.new(0, 2, 0, 2 + (i-1)*24)
item_btn.BackgroundColor3 = Theme.button
item_btn.Text = item
item_btn.TextColor3 = Theme.text
item_btn.TextSize = 14
item_btn.Font = Enum.Font.SourceSans
item_btn.AutoButtonColor = false
item_btn.ZIndex = 11
item_btn.Parent = dropdown
local item_padding = Instance.new("UIPadding")
item_padding.PaddingLeft = UDim.new(0, 8)
item_padding.Parent = item_btn
item_btn.MouseEnter:Connect(function()
TweenService:Create(item_btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.button_hovered}):Play()
end)
item_btn.MouseLeave:Connect(function()
TweenService:Create(item_btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.button}):Play()
end)
item_btn.MouseButton1Click:Connect(function()
btn.Text = item
dropdown:Destroy()
dropdown_open = false
end)
end
end)
layout:advance_cursor(container.Size.X.Offset, container.Size.Y.Offset)
return btn, function() return btn.Text end
end
function Imgui:color_edit3(label, color)
local pos = layout:get_cursor_pos()
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 20)
container.Position = pos
container.BackgroundTransparency = 1
container.Parent = self.canvas
local text_label = Instance.new("TextLabel")
text_label.Size = UDim2.new(1, -60, 1, 0)
text_label.Position = UDim2.new(0, 0, 0, 0)
text_label.BackgroundTransparency = 1
text_label.Text = label
text_label.TextColor3 = Theme.text
text_label.TextSize = 14
text_label.Font = Enum.Font.SourceSans
text_label.TextXAlignment = Enum.TextXAlignment.Left
text_label.TextYAlignment = Enum.TextYAlignment.Center
text_label.Parent = container
local color_btn = Instance.new("TextButton")
color_btn.Size = UDim2.new(0, 40, 0, 16)
color_btn.Position = UDim2.new(1, -42, 0.5, -8)
color_btn.BackgroundColor3 = color or Color3.new(1,1,1)
color_btn.Text = ""
color_btn.Parent = container
layout:advance_cursor(container.Size.X.Offset, container.Size.Y.Offset)
return color_btn, function() return color_btn.BackgroundColor3 end
end
function Imgui:collapsing_header(label)
local pos = layout:get_cursor_pos()
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -16, 0, 24)
frame.Position = pos
frame.BackgroundColor3 = Theme.header
frame.Parent = self.canvas
local opened = false
local arrow = Instance.new("TextLabel")
arrow.Size = UDim2.new(0, 16, 1, 0)
arrow.Position = UDim2.new(0, 4, 0, 0)
arrow.BackgroundTransparency = 1
arrow.Text = "►"
arrow.TextColor3 = Theme.text
arrow.TextSize = 14
arrow.Parent = frame
local text_label = Instance.new("TextLabel")
text_label.Size = UDim2.new(1, -24, 1, 0)
text_label.Position = UDim2.new(0, 24, 0, 0)
text_label.BackgroundTransparency = 1
text_label.Text = label
text_label.TextColor3 = Theme.text
text_label.TextSize = 14
text_label.Font = Enum.Font.SourceSans
text_label.TextXAlignment = Enum.TextXAlignment.Left
text_label.TextYAlignment = Enum.TextYAlignment.Center
text_label.Parent = frame
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 1, 0)
btn.BackgroundTransparency = 1
btn.Text = ""
btn.Parent = frame
btn.MouseButton1Click:Connect(function()
opened = not opened
arrow.Text = opened and "▼" or "►"
end)
layout:advance_cursor(frame.Size.X.Offset, frame.Size.Y.Offset)
return function() return opened end
end
function Imgui:destroy()
if self.gui then
self.gui:Destroy()
end
end
