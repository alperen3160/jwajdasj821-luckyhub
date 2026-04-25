--[[
    LuckyHub UI Library - Hood Style
    Author: Pro Tarafından Senin İçin Yazıldı
    Version: 1.0.0 (Premium)
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Kütüphane Ana Tablosu
local LuckyHub = {}
local Utility = {}

-- Utility Fonksiyonları (Sürükleme & Animasyonlar)
function Utility:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utility:Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end

-- Ana Pencere Oluşturma
function LuckyHub:MakeWindow(options)
    options = options or {}
    local TitleText = options.Name or "LuckyHub Premium"
    local ThemeColor = options.Color or Color3.fromRGB(130, 0, 255) -- Default Mor (Hood Tarzı)
    local Bind = options.Keybind or Enum.KeyCode.RightControl

    -- Eski GUI'yi temizle
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "LuckyHubUI" then
            gui:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LuckyHubUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.ClipsDescendants = true

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = ThemeColor
    MainStroke.Thickness = 1.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.Size = UDim2.new(1, 0, 0, 35)

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 6)
    TopCorner.Parent = TopBar

    local TopBarBottom = Instance.new("Frame")
    TopBarBottom.Parent = TopBar
    TopBarBottom.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBarBottom.BorderSizePixel = 0
    TopBarBottom.Position = UDim2.new(0, 0, 1, -5)
    TopBarBottom.Size = UDim2.new(1, 0, 0, 5)

    local TitleLine = Instance.new("Frame")
    TitleLine.Parent = TopBar
    TitleLine.BackgroundColor3 = ThemeColor
    TitleLine.BorderSizePixel = 0
    TitleLine.Position = UDim2.new(0, 0, 1, 0)
    TitleLine.Size = UDim2.new(1, 0, 0, 1)

    local Title = Instance.new("TextLabel")
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -15, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = TitleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    Utility:MakeDraggable(TopBar, MainFrame)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 36)
    Sidebar.Size = UDim2.new(0, 130, 1, -36)

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Parent = Sidebar
    SidebarLine.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = Sidebar
    TabContainer.Active = true
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 10)
    TabContainer.Size = UDim2.new(1, 0, 1, -20)
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 131, 0, 36)
    ContentContainer.Size = UDim2.new(1, -131, 1, -36)

    -- Arayüz Kapat/Aç
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Bind and not gameProcessed then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local Window = {}
    local FirstTab = true

    function Window:MakeTab(tabOptions)
        local TabName = tabOptions.Name or "Tab"
        local Tab = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = ThemeColor
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0.9, 0, 0, 30)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.Text = TabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 13
        TabBtn.AutoButtonColor = false

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 4)
        TabBtnCorner.Parent = TabBtn

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Parent = ContentContainer
        TabPage.Active = true
        TabPage.BackgroundTransparency = 1
        TabPage.Position = UDim2.new(0, 0, 0, 10)
        TabPage.Size = UDim2.new(1, 0, 1, -20)
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = ThemeColor
        TabPage.Visible = false

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = TabPage
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)

        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = TabPage
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        if FirstTab then
            FirstTab = false
            TabPage.Visible = true
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.TextColor3 = ThemeColor
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    Utility:Tween(btn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
                end
            end
            TabPage.Visible = true
            Utility:Tween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = ThemeColor}, 0.2)
        end)

        -- Buton Elemanı
        function Tab:AddButton(btnOptions)
            local BtnName = btnOptions.Name or "Button"
            local Callback = btnOptions.Callback or function() end

            local Button = Instance.new("TextButton")
            Button.Parent = TabPage
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Button.Size = UDim2.new(1, -10, 0, 35)
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = BtnName
            Button.TextColor3 = Color3.fromRGB(220, 220, 220)
            Button.TextSize = 13
            Button.AutoButtonColor = false

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Button

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Parent = Button
            BtnStroke.Color = Color3.fromRGB(40, 40, 40)
            BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            Button.MouseEnter:Connect(function()
                Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.2)
                Utility:Tween(BtnStroke, {Color = ThemeColor}, 0.2)
            end)

            Button.MouseLeave:Connect(function()
                Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.2)
                Utility:Tween(BtnStroke, {Color = Color3.fromRGB(40, 40, 40)}, 0.2)
            end)

            Button.MouseButton1Click:Connect(function()
                local circle = Instance.new("Frame")
                circle.Parent = Button
                circle.BackgroundColor3 = ThemeColor
                circle.BackgroundTransparency = 0.5
                circle.BorderSizePixel = 0
                circle.Position = UDim2.new(0.5, 0, 0.5, 0)
                circle.Size = UDim2.new(0, 0, 0, 0)
                circle.ZIndex = 10
                
                local circleCorner = Instance.new("UICorner")
                circleCorner.CornerRadius = UDim.new(1, 0)
                circleCorner.Parent = circle

                local tw = Utility:Tween(circle, {Size = UDim2.new(0, 150, 0, 150), BackgroundTransparency = 1}, 0.4)
                tw.Completed:Connect(function() circle:Destroy() end)
                
                Callback()
            end)
        end

        -- Toggle Elemanı
        function Tab:AddToggle(tglOptions)
            local TglName = tglOptions.Name or "Toggle"
            local Default = tglOptions.Default or false
            local Callback = tglOptions.Callback or function() end
            local State = Default

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Parent = TabPage
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false

            local TglCorner = Instance.new("UICorner")
            TglCorner.CornerRadius = UDim.new(0, 4)
            TglCorner.Parent = ToggleFrame

            local TglStroke = Instance.new("UIStroke")
            TglStroke.Parent = ToggleFrame
            TglStroke.Color = Color3.fromRGB(40, 40, 40)
            TglStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local TglLabel = Instance.new("TextLabel")
            TglLabel.Parent = ToggleFrame
            TglLabel.BackgroundTransparency = 1
            TglLabel.Position = UDim2.new(0, 10, 0, 0)
            TglLabel.Size = UDim2.new(1, -50, 1, 0)
            TglLabel.Font = Enum.Font.GothamSemibold
            TglLabel.Text = TglName
            TglLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TglLabel.TextSize = 13
            TglLabel.TextXAlignment = Enum.TextXAlignment.Left

            local TglOuter = Instance.new("Frame")
            TglOuter.Parent = ToggleFrame
            TglOuter.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            TglOuter.Position = UDim2.new(1, -45, 0.5, -10)
            TglOuter.Size = UDim2.new(0, 35, 0, 20)
            
            local OuterCorner = Instance.new("UICorner")
            OuterCorner.CornerRadius = UDim.new(1, 0)
            OuterCorner.Parent = TglOuter

            local OuterStroke = Instance.new("UIStroke")
            OuterStroke.Parent = TglOuter
            OuterStroke.Color = Color3.fromRGB(50, 50, 50)

            local TglInner = Instance.new("Frame")
            TglInner.Parent = TglOuter
            TglInner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            TglInner.Position = UDim2.new(0, 2, 0.5, -8)
            TglInner.Size = UDim2.new(0, 16, 0, 16)

            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(1, 0)
            InnerCorner.Parent = TglInner

            local function UpdateToggle(anim)
                if State then
                    Utility:Tween(TglInner, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = ThemeColor}, anim and 0.2 or 0)
                    Utility:Tween(OuterStroke, {Color = ThemeColor}, anim and 0.2 or 0)
                else
                    Utility:Tween(TglInner, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, anim and 0.2 or 0)
                    Utility:Tween(OuterStroke, {Color = Color3.fromRGB(50, 50, 50)}, anim and 0.2 or 0)
                end
                Callback(State)
            end

            UpdateToggle(false)

            ToggleFrame.MouseButton1Click:Connect(function()
                State = not State
                UpdateToggle(true)
            end)

            return {
                Set = function(v)
                    State = v
                    UpdateToggle(true)
                end
            }
        end

        -- Slider Elemanı
        function Tab:AddSlider(sldOptions)
            local SldName = sldOptions.Name or "Slider"
            local Min = sldOptions.Min or 0
            local Max = sldOptions.Max or 100
            local Default = sldOptions.Default or Min
            local Callback = sldOptions.Callback or function() end
            local Value = Default

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = TabPage
            SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)

            local SldCorner = Instance.new("UICorner")
            SldCorner.CornerRadius = UDim.new(0, 4)
            SldCorner.Parent = SliderFrame

            local SldStroke = Instance.new("UIStroke")
            SldStroke.Parent = SliderFrame
            SldStroke.Color = Color3.fromRGB(40, 40, 40)
            SldStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local SldLabel = Instance.new("TextLabel")
            SldLabel.Parent = SliderFrame
            SldLabel.BackgroundTransparency = 1
            SldLabel.Position = UDim2.new(0, 10, 0, 5)
            SldLabel.Size = UDim2.new(0.8, 0, 0, 20)
            SldLabel.Font = Enum.Font.GothamSemibold
            SldLabel.Text = SldName
            SldLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            SldLabel.TextSize = 13
            SldLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SldValue = Instance.new("TextLabel")
            SldValue.Parent = SliderFrame
            SldValue.BackgroundTransparency = 1
            SldValue.Position = UDim2.new(0.8, 0, 0, 5)
            SldValue.Size = UDim2.new(0.2, -10, 0, 20)
            SldValue.Font = Enum.Font.GothamBold
            SldValue.Text = tostring(Default)
            SldValue.TextColor3 = ThemeColor
            SldValue.TextSize = 13
            SldValue.TextXAlignment = Enum.TextXAlignment.Right

            local SldOuter = Instance.new("TextButton")
            SldOuter.Parent = SliderFrame
            SldOuter.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            SldOuter.Position = UDim2.new(0, 10, 0, 30)
            SldOuter.Size = UDim2.new(1, -20, 0, 8)
            SldOuter.Text = ""
            SldOuter.AutoButtonColor = false

            local OuterCorner = Instance.new("UICorner")
            OuterCorner.CornerRadius = UDim.new(1, 0)
            OuterCorner.Parent = SldOuter

            local SldInner = Instance.new("Frame")
            SldInner.Parent = SldOuter
            SldInner.BackgroundColor3 = ThemeColor
            SldInner.Size = UDim2.new(math.clamp((Default - Min) / (Max - Min), 0, 1), 0, 1, 0)

            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(1, 0)
            InnerCorner.Parent = SldInner

            local function Update(input)
                local pos = math.clamp((input.Position.X - SldOuter.AbsolutePosition.X) / SldOuter.AbsoluteSize.X, 0, 1)
                Value = math.floor(Min + ((Max - Min) * pos))
                SldValue.Text = tostring(Value)
                Utility:Tween(SldInner, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                Callback(Value)
            end

            local dragging = false
            SldOuter.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
        end

        return Tab
    end
    
    -- Bildirim (Notification) Sistemi
    function LuckyHub:Notify(notifOptions)
        local NTitle = notifOptions.Title or "Notification"
        local NText = notifOptions.Text or "This is a notification."
        local NDuration = notifOptions.Duration or 3
        
        local NotifGui = CoreGui:FindFirstChild("LuckyHubNotifUI")
        if not NotifGui then
            NotifGui = Instance.new("ScreenGui")
            NotifGui.Name = "LuckyHubNotifUI"
            NotifGui.Parent = CoreGui
        end
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Parent = NotifGui
        NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        NotifFrame.Position = UDim2.new(1, 10, 1, -100) -- Dışarıda başlar
        NotifFrame.Size = UDim2.new(0, 250, 0, 60)
        
        local NCorner = Instance.new("UICorner")
        NCorner.CornerRadius = UDim.new(0, 6)
        NCorner.Parent = NotifFrame
        
        local NStroke = Instance.new("UIStroke")
        NStroke.Parent = NotifFrame
        NStroke.Color = ThemeColor
        NStroke.Thickness = 1.5
        
        local NTitleLabel = Instance.new("TextLabel")
        NTitleLabel.Parent = NotifFrame
        NTitleLabel.BackgroundTransparency = 1
        NTitleLabel.Position = UDim2.new(0, 10, 0, 5)
        NTitleLabel.Size = UDim2.new(1, -20, 0, 20)
        NTitleLabel.Font = Enum.Font.GothamBold
        NTitleLabel.Text = NTitle
        NTitleLabel.TextColor3 = ThemeColor
        NTitleLabel.TextSize = 14
        NTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local NTextLabel = Instance.new("TextLabel")
        NTextLabel.Parent = NotifFrame
        NTextLabel.BackgroundTransparency = 1
        NTextLabel.Position = UDim2.new(0, 10, 0, 25)
        NTextLabel.Size = UDim2.new(1, -20, 0, 30)
        NTextLabel.Font = Enum.Font.Gotham
        NTextLabel.Text = NText
        NTextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        NTextLabel.TextSize = 12
        NTextLabel.TextWrapped = true
        NTextLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Mevcut bildirimleri yukarı kaydır
        for _, v in pairs(NotifGui:GetChildren()) do
            if v ~= NotifFrame then
                Utility:Tween(v, {Position = UDim2.new(1, -260, 1, v.Position.Y.Offset - 70)}, 0.3)
            end
        end
        
        -- Giriş Animasyonu
        Utility:Tween(NotifFrame, {Position = UDim2.new(1, -260, 1, -70)}, 0.3)
        
        -- Çıkış Animasyonu
        task.delay(NDuration, function()
            local tw = Utility:Tween(NotifFrame, {Position = UDim2.new(1, 10, 1, NotifFrame.Position.Y.Offset)}, 0.3)
            tw.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end)
    end

    return Window
end

return LuckyHub
