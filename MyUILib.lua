local MyUILib = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CAS = game:GetService("ContextActionService")

-- ===== UI State =====
local uiState = {
    Toggles = {},
    Sliders = {},
    Dropdowns = {},
    Texts = {}
}

-- ===== Private UI Objects =====
local uiBlur
local screenGui
local mainFrame
local optionsFrame
local headerTitle -- Objek TextLabel untuk judul
local creditsLabel -- Objek TextLabel untuk credits
local isMinimized = true

-- ===== Helper Function =====
local function makeUI(parent, class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

-- ===== CORE UI SETUP FUNCTION =====
function MyUILib.init(correctKey)
    -- Private UI Objects
    uiBlur = makeUI(Lighting, "BlurEffect", {Size = 20, Enabled = false})
    screenGui = makeUI(LocalPlayer:WaitForChild("PlayerGui"), "ScreenGui", {Name = "MyUI", ResetOnSpawn = false})

    -- Main Frame
    mainFrame = makeUI(screenGui, "Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.2, 0),
        Size = UDim2.new(0, 260, 0, 40),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Active = true
    })
    makeUI(mainFrame, "UICorner", {CornerRadius = UDim.new(0, 12)})
    local shadow = makeUI(mainFrame, "ImageLabel", {BackgroundTransparency = 1, Image = "rbxassetid://5028857084", ImageTransparency = 0.75, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276), Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), ZIndex = -1})
    local stroke = makeUI(mainFrame, "UIStroke", {Color = Color3.fromRGB(70, 70, 70), Thickness = 1.2, Transparency = 0.2})
    
    -- Header
    local header = makeUI(mainFrame, "Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 0.2, BorderSizePixel = 0, Active = true})
    makeUI(header, "UICorner", {CornerRadius = UDim.new(0, 12)})
    makeUI(header, "UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6)})
    
    headerTitle = makeUI(header, "TextLabel", {Text = "Boundless", Font = Enum.Font.GothamSemibold, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -46, 1, 0), TextXAlignment = Enum.TextXAlignment.Left})

    -- Minimize Button
    local minimizeButton = makeUI(header, "TextButton", {Text = "+", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(50, 50, 50), Size = UDim2.new(0, 24, 0, 24)})
    makeUI(minimizeButton, "UICorner", {CornerRadius = UDim.new(1, 0)})

    -- Scrollable Options
    optionsFrame = makeUI(mainFrame, "ScrollingFrame", {Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 1, -28), BackgroundTransparency = 1, ScrollBarThickness = 6, CanvasSize = UDim2.new(0, 0, 0, 0), VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar, Active = true})
    local layout = makeUI(optionsFrame, "UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        optionsFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)
    optionsFrame.Visible = false

    -- Credits Label
    creditsLabel = makeUI(mainFrame, "TextLabel", {
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1, -10, 1, -10),
        Size = UDim2.new(0, 200, 0, 20),
        BackgroundTransparency = 1,
        Text = "exploiters & ui by kkkkkk",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(180,180,180),
        TextXAlignment = Enum.TextXAlignment.Right,
        Visible = false
    })

    -- Tweens & Sizes
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local minimizedSize = UDim2.new(0, 260, 0, 40)
    local maximizedSize = UDim2.new(0, 260, 0, 360)
    mainFrame.Size = minimizedSize
    TweenService:Create(shadow, tweenInfo, {Size = minimizedSize, ImageTransparency = 0.75}):Play()
    TweenService:Create(stroke, tweenInfo, {Transparency = 0.2, Thickness = 1.2}):Play()

    -- Dragging Logic
    local dragging, dragStart, startPos
    local function disableControls() return Enum.ContextActionResult.Sink end
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            CAS:BindAction("DisableControls", disableControls, false, unpack(Enum.UserInputType:GetEnumItems()))
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; CAS:UnbindAction("DisableControls") end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Minimize/Maximize Logic
    local function toggleMinimize()
        if isMinimized then
            isMinimized = false
            minimizeButton.Text = "-"
            uiBlur.Enabled = true
            optionsFrame.Visible = true
            creditsLabel.Visible = true
            TweenService:Create(mainFrame, tweenInfo, {Size = maximizedSize}):Play()
            TweenService:Create(shadow, tweenInfo, {Size = maximizedSize, ImageTransparency = 0.6}):Play()
            TweenService:Create(stroke, tweenInfo, {Transparency = 0, Thickness = 1.8}):Play()
        else
            isMinimized = true
            minimizeButton.Text = "+"
            uiBlur.Enabled = false
            optionsFrame.Visible = false
            creditsLabel.Visible = false
            TweenService:Create(mainFrame, tweenInfo, {Size = minimizedSize}):Play()
            TweenService:Create(shadow, tweenInfo, {Size = minimizedSize, ImageTransparency = 0.75}):Play()
            TweenService:Create(stroke, tweenInfo, {Transparency = 0.2, Thickness = 1.2}):Play()
        end
    end
    minimizeButton.MouseButton1Click:Connect(toggleMinimize)

    -- Key System
    if correctKey then
        mainFrame.Visible = false

        local keyFrame = makeUI(screenGui, "Frame", {
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0,280,0,140),
            BackgroundColor3 = Color3.fromRGB(30,30,30),
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Active = true
        })
        makeUI(keyFrame, "UICorner", {CornerRadius = UDim.new(0,10)})

        local header = makeUI(keyFrame, "TextLabel", {
            Size = UDim2.new(1,0,0,30),
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Text = "Enter Key",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255,255,255)
        })
        makeUI(header, "UICorner", {CornerRadius = UDim.new(0,10)})

        local box = makeUI(keyFrame, "TextBox", {
            Size = UDim2.new(0.8,0,0,30),
            Position = UDim2.new(0.1,0,0,50),
            BackgroundColor3 = Color3.fromRGB(40,40,40),
            PlaceholderText = "Paste your key...",
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            BorderSizePixel = 0
        })
        makeUI(box, "UICorner", {CornerRadius = UDim.new(0,6)})

        local submit = makeUI(keyFrame, "TextButton", {
            Size = UDim2.new(0.5,0,0,28),
            Position = UDim2.new(0.25,0,0,90),
            BackgroundColor3 = Color3.fromRGB(50,150,50),
            Text = "Submit",
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255,255,255)
        })
        makeUI(submit, "UICorner", {CornerRadius = UDim.new(0,8)})

        local notif = makeUI(keyFrame, "TextLabel", {
            Size = UDim2.new(1,0,0,20),
            Position = UDim2.new(0,0,1,-20),
            BackgroundTransparency = 1,
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255,100,100)
        })

        -- Atur blur
        uiBlur.Enabled = true

        -- Tombol submit
        submit.MouseButton1Click:Connect(function()
            if box.Text == correctKey then
                notif.Text = "Correct! Loading..."
                TweenService:Create(keyFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                for _,v in ipairs(keyFrame:GetChildren()) do
                    if v:IsA("GuiObject") then
                        TweenService:Create(v, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                    end
                end
                task.wait(0.5)
                keyFrame:Destroy()
                uiBlur.Enabled = false
                task.wait(0.2) -- waktu tunggu sebentar untuk transisi
                mainFrame.Visible = true
            else
                notif.Text = "Wrong key!"
            end
        end)
    end
end

-- ===== Public Option Creators =====
function MyUILib.createToggle(name, text)
    local frame = makeUI(optionsFrame, "Frame", {Size = UDim2.new(0.95, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(40, 40, 40), BackgroundTransparency = 0.2, BorderSizePixel = 0})
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0, 6)})
    makeUI(frame, "TextLabel", {Text = text, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(0.55, 0, 1, 0), Position = UDim2.new(0.03, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
    local toggle = makeUI(frame, "TextButton", {Text = "OFF", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(150, 50, 50), Size = UDim2.new(0.35, 0, 0.75, 0), Position = UDim2.new(0.62, 0, 0.125, 0), Active = true})
    makeUI(toggle, "UICorner", {CornerRadius = UDim.new(0, 6)})
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(150, 50, 50)}):Play()
        uiState.Toggles[name] = state
    end)
    uiState.Toggles[name] = state
end

function MyUILib.createSlider(name, min, max, default, step)
    step = step or 1
    local frame = makeUI(optionsFrame, "Frame", {Size = UDim2.new(0.95, 0, 0, 36), BackgroundColor3 = Color3.fromRGB(40, 40, 40), BackgroundTransparency = 0.2, BorderSizePixel = 0})
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0, 6)})
    makeUI(frame, "TextLabel", {Text = name, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(0.03, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
    local sliderFrame = makeUI(frame, "Frame", {Size = UDim2.new(0.55, 0, 0.35, 0), Position = UDim2.new(0.42, 0, 0.35, 0), BackgroundColor3 = Color3.fromRGB(60, 60, 60), Active = true})
    makeUI(sliderFrame, "UICorner", {CornerRadius = UDim.new(0, 4)})
    local handle = makeUI(sliderFrame, "Frame", {Size = UDim2.new(0, 12, 1, 0), BackgroundColor3 = Color3.fromRGB(50, 150, 50), Active = true})
    makeUI(handle, "UICorner", {CornerRadius = UDim.new(0, 6)})
    local valueLabel = makeUI(frame, "TextLabel", {Text = tostring(default), Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(0.15, 0, 1, 0), Position = UDim2.new(0.88, 0, 0, 0)})
    local rel = (default-min)/(max-min)
    handle.Position = UDim2.new(rel, 0, 0, 0)
    local function valueToColor(val)
        local t = (val-min)/(max-min)
        if t < 0.5 then
            local f = t/0.5
            return Color3.fromRGB(50 + 205*f, 150 + 105*f, 50)
        else
            local f = (t-0.5)/0.5
            return Color3.fromRGB(255, 255 - 255*f, 50)
        end
    end
    handle.BackgroundColor3 = valueToColor(default)
    local dragging = false
    local function updateSlider(input)
        local rel = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        local value = min + rel * (max - min)
        value = math.floor(value / step + 0.5) * step
        local newRel = (value - min) / (max - min)
        handle.Position = UDim2.new(newRel, 0, 0, 0)
        valueLabel.Text = tostring(math.floor(value))
        handle.BackgroundColor3 = valueToColor(value)
        uiState.Sliders[name] = value
    end
    handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end end)
    handle.InputEnded:Connect(function(input) dragging = false end)
    sliderFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end end)
    sliderFrame.InputEnded:Connect(function(input) dragging = false end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
    uiState.Sliders[name] = default
end

function MyUILib.createTextBox(name, placeholder, callback, autoClear)
    local frame = makeUI(optionsFrame, "Frame", {Size = UDim2.new(0.95, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0})
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0, 8)})
    makeUI(frame, "TextLabel", {Text = name, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(0.03, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
    local box = makeUI(frame, "TextBox", {Size = UDim2.new(0.6, 0, 0.75, 0), Position = UDim2.new(0.38, 0, 0.125, 0), BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(150, 150, 150), PlaceholderText = placeholder, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, BorderSizePixel = 0, TextWrapped = false})
    makeUI(box, "UICorner", {CornerRadius = UDim.new(0, 6)})
    local defaultText = placeholder
    box.Text = defaultText
    box.Focused:Connect(function()
        TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        if box.Text == defaultText then
            box.Text = ""
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.Touch then
            if box:IsFocused() and box.Text == defaultText then
                box.Text = ""
                box.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end)
    box.FocusLost:Connect(function(enterPressed)
        TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        if enterPressed and callback then
            callback(box.Text)
            if autoClear then
                box.Text = defaultText
                box.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        if box.Text == "" then
            box.Text = defaultText
            box.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        uiState.Texts[name] = box.Text
    end)
    box.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            box:CaptureFocus()
        end
    end)
    uiState.Texts[name] = ""
end

function MyUILib.createDropdown(name, options)
    local frame = makeUI(optionsFrame, "Frame", {Size = UDim2.new(0.95, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(40, 40, 40), BackgroundTransparency = 0.2, BorderSizePixel = 0})
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0, 6)})
    makeUI(frame, "TextLabel", {Text = name, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(0.55, 0, 1, 0), Position = UDim2.new(0.03, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
    local button = makeUI(frame, "TextButton", {Text = "Select", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(0.35, 0, 0.75, 0), Position = UDim2.new(0.62, 0, 0.125, 0), Active = true})
    makeUI(button, "UICorner", {CornerRadius = UDim.new(0, 6)})

    local dropFrame = makeUI(optionsFrame, "ScrollingFrame", {Size = UDim2.new(0.95, 0, 0, #options * 28), Position = UDim2.new(0.025, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(50, 50, 50), Visible = false, CanvasSize = UDim2.new(0, 0, 0, #options * 28)})
    makeUI(dropFrame, "UIListLayout", {Padding = UDim.new(0, 1), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder})

    for i, opt in ipairs(options) do
        local btn = makeUI(dropFrame, "TextButton", {Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28)})
        btn.MouseButton1Click:Connect(function()
            button.Text = opt
            dropFrame.Visible = false
            uiState.Dropdowns[name] = opt
        end)
    end

    button.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
        local absPos = button.AbsolutePosition
        local relativeY = absPos.Y - mainFrame.AbsolutePosition.Y + button.AbsoluteSize.Y
        local relativeX = absPos.X - mainFrame.AbsolutePosition.X
        dropFrame.Position = UDim2.new(0, relativeX, 0, relativeY)
    end)
    uiState.Dropdowns[name] = options[1]
end

-- ===== GET STATE FUNCTION =====
function MyUILib.getState()
    return uiState
end

-- ===== SET TITLE FUNCTION =====
function MyUILib.setTitle(newTitle)
    if headerTitle then
        headerTitle.Text = newTitle
    end
end

return MyUILib
