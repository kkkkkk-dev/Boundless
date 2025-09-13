-- // MyUILib Final Version
local MyUILib = {}
MyUILib.__index = MyUILib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ===== Constructor =====
function MyUILib:NewWindow(title)
    local self = setmetatable({}, MyUILib)

    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MyUILib"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game:GetService("CoreGui")

    -- Main Frame
    self.MainFrame = Instance.new("Frame", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 400, 0, 250)
    self.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Visible = true
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0,8)

    -- Title Bar
    self.TitleBar = Instance.new("Frame", self.MainFrame)
    self.TitleBar.Size = UDim2.new(1,0,0,28)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    self.TitleBar.BorderSizePixel = 0
    Instance.new("UICorner", self.TitleBar).CornerRadius = UDim.new(0,8)

    local titleLabel = Instance.new("TextLabel", self.TitleBar)
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0,8,0,0)
    titleLabel.Text = title or "MyUILib"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.BackgroundTransparency = 1

    -- Minimize / Maximize button
    self.ToggleBtn = Instance.new("TextButton", self.TitleBar)
    self.ToggleBtn.Size = UDim2.new(0,50,1,0)
    self.ToggleBtn.Position = UDim2.new(1,-52,0,0)
    self.ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    self.ToggleBtn.Text = "-"
    self.ToggleBtn.Font = Enum.Font.GothamBold
    self.ToggleBtn.TextSize = 14
    self.ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", self.ToggleBtn).CornerRadius = UDim.new(0,6)

    -- Content holder
    self.ContentFrame = Instance.new("Frame", self.MainFrame)
    self.ContentFrame.Size = UDim2.new(1,-10,1,-40)
    self.ContentFrame.Position = UDim2.new(0,5,0,35)
    self.ContentFrame.BackgroundTransparency = 1

    -- State
    self.Minimized = false
    self.Elements = {}
    self.Tabs = {}
    self.CurrentTab = nil

    -- Toggle minimize
    self.ToggleBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            self.ContentFrame.Visible = false
            self.ToggleBtn.Text = "+"
            self.MainFrame.Size = UDim2.new(0,400,0,28)
        else
            self.ContentFrame.Visible = true
            self.ToggleBtn.Text = "-"
            self.MainFrame.Size = UDim2.new(0,400,0,250)
        end
    end)

    return self
end

-- ===== Helper untuk UI Elemen =====
local function makeBase(parent, height)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, height)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0,5,0, (#parent:GetChildren()-1) * (height + 6))
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    return frame
end

-- ===== KeySystem =====
function MyUILib:_AddKeySystem(correctKey)
    local Lighting = game:GetService("Lighting")
    local blur = Instance.new("BlurEffect")
    blur.Size = 20
    blur.Enabled = true
    blur.Parent = Lighting

    local keyFrame = Instance.new("Frame")
    keyFrame.AnchorPoint = Vector2.new(0.5,0.5)
    keyFrame.Position = UDim2.new(0.5,0,0.5,0)
    keyFrame.Size = UDim2.new(0,280,0,140)
    keyFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    keyFrame.BackgroundTransparency = 0.2
    keyFrame.BorderSizePixel = 0
    keyFrame.Active = true
    keyFrame.Parent = self.ScreenGui
    Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0,10)

    local header = Instance.new("TextLabel", keyFrame)
    header.Size = UDim2.new(1,0,0,30)
    header.BackgroundColor3 = Color3.fromRGB(20,20,20)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.Text = "Enter Key"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,10)

    local box = Instance.new("TextBox", keyFrame)
    box.Size = UDim2.new(0.8,0,0,30)
    box.Position = UDim2.new(0.1,0,0,50)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    box.PlaceholderText = "Paste your key..."
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    local submit = Instance.new("TextButton", keyFrame)
    submit.Size = UDim2.new(0.5,0,0,28)
    submit.Position = UDim2.new(0.25,0,0,90)
    submit.BackgroundColor3 = Color3.fromRGB(50,150,50)
    submit.Text = "Submit"
    submit.Font = Enum.Font.GothamBold
    submit.TextSize = 12
    submit.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", submit).CornerRadius = UDim.new(0,8)

    local notif = Instance.new("TextLabel", keyFrame)
    notif.Size = UDim2.new(1,0,0,20)
    notif.Position = UDim2.new(0,0,1,-20)
    notif.BackgroundTransparency = 1
    notif.Text = ""
    notif.Font = Enum.Font.Gotham
    notif.TextSize = 12
    notif.TextColor3 = Color3.fromRGB(255,100,100)

    -- Submit action
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
            blur:Destroy()
            task.wait(1)
            self.MainFrame.Visible = true
            if self._AddCredits then
                self:_AddCredits()
            end
        else
            notif.Text = "Wrong key!"
        end
    end)

    self.MainFrame.Visible = false
end

-- ===== Credits =====
function MyUILib:_AddCredits()
    if self.CreditsAdded then return end
    self.CreditsAdded = true

    local credits = Instance.new("TextLabel", self.MainFrame)
    credits.Size = UDim2.new(1, -20, 0, 20)
    credits.Position = UDim2.new(0,10,1,-24)
    credits.BackgroundTransparency = 1
    credits.Text = "Exploiters & UI by kkkkkk"
    credits.Font = Enum.Font.Gotham
    credits.TextSize = 12
    credits.TextColor3 = Color3.fromRGB(200,200,200)
end

-- ===== Tabs =====
function MyUILib:AddTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}
    self.Tabs[name] = tab
    if not self.CurrentTab then
        self.CurrentTab = tab
    end
    return tab
end

-- ===== Toggle =====
function MyUILib:AddToggle(text, default, callback)
    local toggleFrame = makeBase(self.ContentFrame, 30)

    local label = Instance.new("TextLabel", toggleFrame)
    label.Size = UDim2.new(0.7,0,1,0)
    label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255,255,255)

    local button = Instance.new("TextButton", toggleFrame)
    button.Size = UDim2.new(0.2,0,0.8,0)
    button.Position = UDim2.new(0.75,0,0.1,0)
    button.BackgroundColor3 = default and Color3.fromRGB(50,150,50) or Color3.fromRGB(100,100,100)
    button.Text = default and "ON" or "OFF"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0,6)

    local state = default or false
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Color3.fromRGB(50,150,50) or Color3.fromRGB(100,100,100)
        if callback then
            pcall(callback, state)
        end
    end)
end

-- ===== Slider =====
function MyUILib:AddSlider(text, min, max, default, callback)
    local sliderFrame = makeBase(self.ContentFrame, 40)

    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255,255,255)

    local bar = Instance.new("Frame", sliderFrame)
    bar.Size = UDim2.new(0.9,0,0,6)
    bar.Position = UDim2.new(0.05,0,0,28)
    bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(50,150,250)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor(min + (max-min)*rel)
            label.Text = text .. ": " .. tostring(val)
            if callback then
                pcall(callback, val)
            end
        end
    end)
end

-- ===== TextBox =====
function MyUILib:AddTextBox(placeholder, callback)
    local boxFrame = makeBase(self.ContentFrame, 30)

    local box = Instance.new("TextBox", boxFrame)
    box.Size = UDim2.new(1,-20,1,0)
    box.Position = UDim2.new(0,10,0,0)
    box.BackgroundColor3 = Color3.fromRGB(45,45,45)
    box.PlaceholderText = placeholder or "Enter text..."
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    box.FocusLost:Connect(function()
        if callback then
            pcall(callback, box.Text)
        end
    end)
end

-- ===== Dropdown =====
function MyUILib:AddDropdown(text, options, callback)
    local dropFrame = makeBase(self.ContentFrame, 30)

    local label = Instance.new("TextLabel", dropFrame)
    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Dropdown"
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(255,255,255)

    local button = Instance.new("TextButton", dropFrame)
    button.Size = UDim2.new(0.35,0,0.8,0)
    button.Position = UDim2.new(0.62,0,0.1,0)
    button.BackgroundColor3 = Color3.fromRGB(60,60,60)
    button.Text = "Select"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0,6)

    local listFrame = Instance.new("Frame", dropFrame)
    listFrame.Size = UDim2.new(1, -20, 0, #options * 28)
    listFrame.Position = UDim2.new(0,10,1,4)
    listFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,6)

    for _,opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", listFrame)
        optBtn.Size = UDim2.new(1,0,0,28)
        optBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        optBtn.Text = opt
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 12
        optBtn.TextColor3 = Color3.fromRGB(255,255,255)

        optBtn.MouseButton1Click:Connect(function()
            button.Text = opt
            listFrame.Visible = false
            if callback then
                pcall(callback, opt)
            end
        end)
    end

    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
end

return MyUILib
