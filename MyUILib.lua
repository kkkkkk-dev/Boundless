-- // MyUILib : Modern Tab System Version
local MyUILib = {}
MyUILib.__index = MyUILib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Buat Window
function MyUILib:NewWindow(title)
    local self = setmetatable({}, MyUILib)

    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MyUILib"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game:GetService("CoreGui")

    -- Main Frame
    self.MainFrame = Instance.new("Frame", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 480, 0, 300)
    self.MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Visible = true
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0,10)

    -- Title Bar
    self.TitleBar = Instance.new("Frame", self.MainFrame)
    self.TitleBar.Size = UDim2.new(1,0,0,32)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    self.TitleBar.BorderSizePixel = 0
    Instance.new("UICorner", self.TitleBar).CornerRadius = UDim.new(0,10)

    local titleLabel = Instance.new("TextLabel", self.TitleBar)
    titleLabel.Size = UDim2.new(1,-60,1,0)
    titleLabel.Position = UDim2.new(0,10,0,0)
    titleLabel.Text = title or "MyUILib"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.BackgroundTransparency = 1

    -- Toggle button minimize/maximize
    self.ToggleBtn = Instance.new("TextButton", self.TitleBar)
    self.ToggleBtn.Size = UDim2.new(0,50,1,0)
    self.ToggleBtn.Position = UDim2.new(1,-52,0,0)
    self.ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    self.ToggleBtn.Text = "-"
    self.ToggleBtn.Font = Enum.Font.GothamBold
    self.ToggleBtn.TextSize = 14
    self.ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", self.ToggleBtn).CornerRadius = UDim.new(0,6)

    -- Sidebar (Tab buttons)
    self.Sidebar = Instance.new("Frame", self.MainFrame)
    self.Sidebar.Size = UDim2.new(0,120,1,-40)
    self.Sidebar.Position = UDim2.new(0,0,0,36)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(30,30,30)
    self.Sidebar.BorderSizePixel = 0

    -- Content Area
    self.ContentFrame = Instance.new("Frame", self.MainFrame)
    self.ContentFrame.Size = UDim2.new(1,-130,1,-40)
    self.ContentFrame.Position = UDim2.new(0,125,0,36)
    self.ContentFrame.BackgroundTransparency = 1

    -- State
    self.Minimized = false
    self.Tabs = {}
    self.ActiveTab = nil

    -- Toggle minimize
    self.ToggleBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            self.ContentFrame.Visible = false
            self.Sidebar.Visible = false
            self.ToggleBtn.Text = "+"
            self.MainFrame.Size = UDim2.new(0,480,0,32)
        else
            self.ContentFrame.Visible = true
            self.Sidebar.Visible = true
            self.ToggleBtn.Text = "-"
            self.MainFrame.Size = UDim2.new(0,480,0,300)
        end
    end)

    return self
end

-- Buat Tab
function MyUILib:AddTab(tabName)
    local tabButton = Instance.new("TextButton", self.Sidebar)
    tabButton.Size = UDim2.new(1,0,0,30)
    tabButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    tabButton.Text = tabName
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 12
    tabButton.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0,6)

    local tabContent = Instance.new("Frame", self.ContentFrame)
    tabContent.Size = UDim2.new(1,0,1,0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false

    self.Tabs[tabName] = tabContent

    tabButton.MouseButton1Click:Connect(function()
        for _,content in pairs(self.Tabs) do
            content.Visible = false
        end
        tabContent.Visible = true
        self.ActiveTab = tabContent
    end)

    -- Set tab pertama sebagai aktif
    if not self.ActiveTab then
        self.ActiveTab = tabContent
        tabContent.Visible = true
    end

    return tabContent
end

-- Helper: styling base elemen
local function makeBase(parent, height)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, height)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0,5,0, #parent:GetChildren() * (height + 6))
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    return frame
end

-- Toggle
function MyUILib:AddToggle(text, default, callback)
    local parent = self.ActiveTab or self.ContentFrame
    local toggleFrame = makeBase(parent, 30)

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

-- Slider
function MyUILib:AddSlider(text, min, max, default, callback)
    local parent = self.ActiveTab or self.ContentFrame
    local sliderFrame = makeBase(parent, 40)

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

-- TextBox
function MyUILib:AddTextBox(placeholder, callback)
    local parent = self.ActiveTab or self.ContentFrame
    local boxFrame = makeBase(parent, 30)

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

-- Dropdown
function MyUILib:AddDropdown(text, options, callback)
    local parent = self.ActiveTab or self.ContentFrame
    local dropFrame = makeBase(parent, 30)

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

-- KeySystem
function MyUILib:_AddKeySystem(correctKey)
    local Lighting = game:GetService("Lighting")
    local TweenService = game:GetService("TweenService")

    -- blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 20
    blur.Enabled = true
    blur.Parent = Lighting

    -- frame key
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

    -- header
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

    -- text box
    local box = Instance.new("TextBox", keyFrame)
    box.Size = UDim2.new(0.8,0,0,30)
    box.Position = UDim2.new(0.1,0,0,50)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    box.PlaceholderText = "Paste your key..."
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    -- submit button
    local submit = Instance.new("TextButton", keyFrame)
    submit.Size = UDim2.new(0.5,0,0,28)
    submit.Position = UDim2.new(0.25,0,0,90)
    submit.BackgroundColor3 = Color3.fromRGB(50,150,50)
    submit.Text = "Submit"
    submit.Font = Enum.Font.GothamBold
    submit.TextSize = 12
    submit.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", submit).CornerRadius = UDim.new(0,8)

    -- notification
    local notif = Instance.new("TextLabel", keyFrame)
    notif.Size = UDim2.new(1,0,0,20)
    notif.Position = UDim2.new(0,0,1,-20)
    notif.BackgroundTransparency = 1
    notif.Text = ""
    notif.Font = Enum.Font.Gotham
    notif.TextSize = 12
    notif.TextColor3 = Color3.fromRGB(255,100,100)

    -- tombol submit
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
            task.wait(1) -- delay sebelum UI utama muncul
            self.MainFrame.Visible = true
            if self._AddCredits then
                self:_AddCredits() -- tampilkan credits saat maximize
            end
        else
            notif.Text = "Wrong key!"
        end
    end)

    self.MainFrame.Visible = false -- sembunyikan UI utama sampai key benar
end

-- Credits
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

-- Menambahkan Tab
function MyUILib:AddTab(tabName)
    if not self.Tabs then
        self.Tabs = {}
        self.ActiveTab = nil

        -- Tab buttons frame
        self.TabButtonsFrame = Instance.new("Frame", self.MainFrame)
        self.TabButtonsFrame.Size = UDim2.new(1,-10,0,28)
        self.TabButtonsFrame.Position = UDim2.new(0,5,0,35)
        self.TabButtonsFrame.BackgroundTransparency = 1

        -- Content frame untuk tab
        self.TabContentFrame = Instance.new("Frame", self.MainFrame)
        self.TabContentFrame.Size = UDim2.new(1,-10,1,-70)
        self.TabContentFrame.Position = UDim2.new(0,5,0,70)
        self.TabContentFrame.BackgroundTransparency = 1
    end

    local tabFrame = Instance.new("Frame", self.TabContentFrame)
    tabFrame.Size = UDim2.new(1,0,1,0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false

    local button = Instance.new("TextButton", self.TabButtonsFrame)
    button.Size = UDim2.new(0,100,1,0)
    button.Position = UDim2.new(0, (#self.Tabs)*105,0,0)
    button.BackgroundColor3 = Color3.fromRGB(60,60,60)
    button.Text = tabName
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0,6)

    -- Saat tab dipilih
    button.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do
            t.Frame.Visible = false
        end
        tabFrame.Visible = true
        self.ActiveTab = tabFrame
    end)

    table.insert(self.Tabs, {Name = tabName, Frame = tabFrame, Button = button})
    if #self.Tabs == 1 then
        button:CaptureFocus() -- tab pertama aktif default
        tabFrame.Visible = true
        self.ActiveTab = tabFrame
    end

    return tabFrame
end

-- Helper baru untuk menentukan parent elemen
local function getActiveParent(self)
    if self.ActiveTab then
        return self.ActiveTab
    else
        return self.ContentFrame
    end
end

-- Override AddToggle
local oldAddToggle = MyUILib.AddToggle
function MyUILib:AddToggle(text, default, callback)
    local parent = getActiveParent(self)
    oldAddToggle(self, text, default, callback)
    local toggleFrame = parent:GetChildren()[#parent:GetChildren()] -- elemen terakhir adalah toggle baru
    toggleFrame.Parent = parent
end

-- Override AddSlider
local oldAddSlider = MyUILib.AddSlider
function MyUILib:AddSlider(text, min, max, default, callback)
    local parent = getActiveParent(self)
    oldAddSlider(self, text, min, max, default, callback)
    local sliderFrame = parent:GetChildren()[#parent:GetChildren()]
    sliderFrame.Parent = parent
end

-- Override AddTextBox
local oldAddTextBox = MyUILib.AddTextBox
function MyUILib:AddTextBox(placeholder, callback)
    local parent = getActiveParent(self)
    oldAddTextBox(self, placeholder, callback)
    local boxFrame = parent:GetChildren()[#parent:GetChildren()]
    boxFrame.Parent = parent
end

-- Override AddDropdown
local oldAddDropdown = MyUILib.AddDropdown
function MyUILib:AddDropdown(text, options, callback)
    local parent = getActiveParent(self)
    oldAddDropdown(self, text, options, callback)
    local dropFrame = parent:GetChildren()[#parent:GetChildren()]
    dropFrame.Parent = parent
end

-- Dragging
do
    local dragging = false
    local dragStart, startPos

    MyUILib.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MyUILib.MainFrame.Position
        end
    end)

    MyUILib.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                MyUILib.MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Minimize/Maximize (bisa digabung dengan ToggleBtn)
do
    local minimizedSize = UDim2.new(0,400,0,28)
    local maximizedSize = UDim2.new(0,400,0,250)

    MyUILib.ToggleBtn.MouseButton1Click:Connect(function()
        MyUILib.Minimized = not MyUILib.Minimized
        if MyUILib.Minimized then
            MyUILib.ContentFrame.Visible = false
            MyUILib.ToggleBtn.Text = "+"
            MyUILib.MainFrame.Size = minimizedSize
        else
            MyUILib.ContentFrame.Visible = true
            MyUILib.ToggleBtn.Text = "-"
            MyUILib.MainFrame.Size = maximizedSize
        end
    end)
end

function MyUILib:StartWithKey(correctKey)
    -- Blur
    local Lighting = game:GetService("Lighting")
    local blur = Instance.new("BlurEffect")
    blur.Size = 20
    blur.Enabled = true
    blur.Parent = Lighting

    -- Key Frame
    local keyFrame = Instance.new("Frame", self.ScreenGui)
    keyFrame.AnchorPoint = Vector2.new(0.5,0.5)
    keyFrame.Position = UDim2.new(0.5,0,0.5,0)
    keyFrame.Size = UDim2.new(0,280,0,140)
    keyFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    keyFrame.BackgroundTransparency = 0.2
    keyFrame.BorderSizePixel = 0
    keyFrame.Active = true
    Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0,10)

    -- Header
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

    -- TextBox
    local box = Instance.new("TextBox", keyFrame)
    box.Size = UDim2.new(0.8,0,0,30)
    box.Position = UDim2.new(0.1,0,0,50)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    box.PlaceholderText = "Paste your key..."
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    -- Submit Button
    local submit = Instance.new("TextButton", keyFrame)
    submit.Size = UDim2.new(0.5,0,0,28)
    submit.Position = UDim2.new(0.25,0,0,90)
    submit.BackgroundColor3 = Color3.fromRGB(50,150,50)
    submit.Text = "Submit"
    submit.Font = Enum.Font.GothamBold
    submit.TextSize = 12
    submit.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", submit).CornerRadius = UDim.new(0,8)

    -- Notification
    local notif = Instance.new("TextLabel", keyFrame)
    notif.Size = UDim2.new(1,0,0,20)
    notif.Position = UDim2.new(0,0,1,-20)
    notif.BackgroundTransparency = 1
    notif.Text = ""
    notif.Font = Enum.Font.Gotham
    notif.TextSize = 12
    notif.TextColor3 = Color3.fromRGB(255,100,100)

    -- Submit Logic
    submit.MouseButton1Click:Connect(function()
        if box.Text == correctKey then
            notif.Text = "Correct! Loading..."
            task.wait(0.5)
            keyFrame:Destroy()
            blur:Destroy()
            self.MainFrame.Visible = true
            if self._AddCredits then
                self:_AddCredits()
            end
        else
            notif.Text = "Wrong key!"
        end
    end)

    -- Hide main UI until key correct
    self.MainFrame.Visible = false
end

function MyUILib:AddTab(tabName)
    if not self.Tabs then
        self.Tabs = {}
        self.TabButtons = {}
        self.ActiveTab = nil

        -- Tab Bar
        self.TabBar = Instance.new("Frame", self.MainFrame)
        self.TabBar.Size = UDim2.new(1, -10, 0, 28)
        self.TabBar.Position = UDim2.new(0, 5, 0, 30)
        self.TabBar.BackgroundTransparency = 1
    end

    -- Tab Button
    local tabBtn = Instance.new("TextButton", self.TabBar)
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.Position = UDim2.new(0, (#self.TabButtons)*105, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    tabBtn.Text = tabName
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0,6)

    -- Tab Content Frame
    local content = Instance.new("Frame", self.ContentFrame)
    content.Size = UDim2.new(1,0,1,-28)
    content.Position = UDim2.new(0,0,0,28)
    content.BackgroundTransparency = 1
    content.Visible = false

    -- Store tab
    self.Tabs[tabName] = content
    table.insert(self.TabButtons, tabBtn)

    -- Click logic
    tabBtn.MouseButton1Click:Connect(function()
        for name,frame in pairs(self.Tabs) do
            frame.Visible = false
        end
        content.Visible = true
        self.ActiveTab = tabName
    end)

    -- Auto select first tab
    if #self.TabButtons == 1 then
        tabBtn:CaptureFocus()
        tabBtn.MouseButton1Click:Fire()
    end

    -- Return content frame untuk menambahkan elemen (toggle, slider, textbox, dropdown) di tab ini
    return content
end
