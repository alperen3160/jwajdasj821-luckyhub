--[[
    UI Library: Juju Private Theme (CoreGui Universal Edition)
    Optimized for GitHub remote execution.
    100% Universal: Works on Solara, Wave, Delta, Celery, etc.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- > ( Executor Protection & Container )
local ParentContainer = nil
if gethui then
    ParentContainer = gethui()
elseif syn and syn.protect_gui then
    ParentContainer = game:GetService("CoreGui")
else
    ParentContainer = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui")
end

-- > ( UI Library Base )
local Library = {
    Colors = {
        Background = Color3.fromRGB(12, 12, 12),
        Section = Color3.fromRGB(18, 18, 18),
        Border = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(154, 213, 222),
        Text = Color3.fromRGB(200, 200, 200),
        DarkText = Color3.fromRGB(100, 100, 100),
    },
    Flags = {},
    Toggled = true
}

-- > ( Utility Functions )
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function Tween(instance, properties, duration)
    local tInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        Tween(object, {Position = pos}, 0.1)
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

-- > ( Core Window Creation )
function Library:CreateWindow(options)
    local Window = {
        Name = options.Name or "juju private",
        Tabs = {},
        ActiveTab = nil
    }

    local ScreenGui = Create("ScreenGui", {
        Name = "JujuUI",
        Parent = ParentContainer,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    self.Gui = ScreenGui

    -- Insert toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Insert then
            self.Toggled = not self.Toggled
            ScreenGui.Enabled = self.Toggled
        end
    end)

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = self.Colors.Border, -- Acts as outline
        Position = UDim2.new(0.5, -300, 0.5, -225),
        Size = UDim2.new(0, 600, 0, 450),
        BorderSizePixel = 0
    })

    local InnerFrame = Create("Frame", {
        Name = "InnerFrame",
        Parent = MainFrame,
        BackgroundColor3 = self.Colors.Background,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0
    })

    -- Dragging Area
    local DragHitbox = Create("Frame", {
        Name = "DragHitbox",
        Parent = InnerFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 50
    })
    MakeDraggable(DragHitbox, MainFrame)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = InnerFrame,
        BackgroundColor3 = self.Colors.Background,
        Size = UDim2.new(0, 120, 1, 0),
        BorderSizePixel = 0
    })

    local SidebarLine = Create("Frame", {
        Name = "SidebarLine",
        Parent = Sidebar,
        BackgroundColor3 = self.Colors.Border,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0
    })

    -- Logo
    local LogoContainer = Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -15, 0, 40)
    })

    local NameText = Create("TextLabel", {
        Parent = LogoContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.RobotoMono,
        Text = string.split(Window.Name, " ")[1] or "juju",
        TextColor3 = self.Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local SubText = Create("TextLabel", {
        Parent = LogoContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 16),
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.RobotoMono,
        Text = string.split(Window.Name, " ")[2] or "private",
        TextColor3 = self.Colors.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 75),
        Size = UDim2.new(1, -1, 1, -85),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        BorderSizePixel = 0
    })

    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })

    local ActiveTabLine = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = self.Colors.Accent,
        Size = UDim2.new(0, 2, 0, 14),
        Visible = false,
        BorderSizePixel = 0
    })

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = InnerFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 121, 0, 0),
        Size = UDim2.new(1, -121, 1, 0)
    })

    function Window:CreateGroup(groupName)
        local Group = {Name = groupName}

        Create("TextLabel", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            Font = Enum.Font.RobotoMono,
            Text = "  " .. groupName,
            TextColor3 = Library.Colors.Accent,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local DivFrame = Create("Frame", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 5)
        })
        Create("Frame", {
            Parent = DivFrame,
            BackgroundColor3 = Library.Colors.Border,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(1, -30, 0, 1),
            BorderSizePixel = 0
        })

        function Group:CreateTab(tabName)
            local Tab = {Name = tabName, Sections = {}}

            local TabBtn = Create("TextButton", {
                Parent = TabContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Font = Enum.Font.RobotoMono,
                Text = "   " .. tabName,
                TextColor3 = Library.Colors.DarkText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })

            local TabContent = Create("ScrollingFrame", {
                Parent = ContentContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 0,
                Visible = false
            })

            local LeftSide = Create("Frame", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(0.5, -15, 1, -20)
            })
            Create("UIListLayout", { Parent = LeftSide, Padding = UDim.new(0, 10) })

            local RightSide = Create("Frame", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 5, 0, 10),
                Size = UDim2.new(0.5, -15, 1, -20)
            })
            Create("UIListLayout", { Parent = RightSide, Padding = UDim.new(0, 10) })

            TabBtn.MouseButton1Click:Connect(function()
                if Window.ActiveTab then
                    Window.ActiveTab.Content.Visible = false
                    Tween(Window.ActiveTab.Btn, {TextColor3 = Library.Colors.DarkText}, 0.15)
                end
                Window.ActiveTab = {Content = TabContent, Btn = TabBtn}
                TabContent.Visible = true
                Tween(TabBtn, {TextColor3 = Library.Colors.Text}, 0.15)

                ActiveTabLine.Visible = true
                Tween(ActiveTabLine, {Position = UDim2.new(0, 0, 0, TabBtn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 2)}, 0.2)
            end)

            function Tab:CreateSection(secName, side)
                local TargetSide = side == "Right" and RightSide or LeftSide

                local SecBorder = Create("Frame", {
                    Parent = TargetSide,
                    BackgroundColor3 = Library.Colors.Border,
                    Size = UDim2.new(1, 0, 0, 20), -- Updates dynamically
                    BorderSizePixel = 0
                })

                local SecInner = Create("Frame", {
                    Parent = SecBorder,
                    BackgroundColor3 = Library.Colors.Section,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderSizePixel = 0
                })

                -- Label with lines
                local TitleContainer = Create("Frame", {
                    Parent = SecInner,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, -5)
                })

                local SecTitle = Create("TextLabel", {
                    Parent = TitleContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(0, 0, 1, 0),
                    Font = Enum.Font.RobotoMono,
                    Text = secName,
                    TextColor3 = Library.Colors.Accent,
                    TextSize = 12,
                    AutomaticSize = Enum.AutomaticSize.X
                })

                Create("Frame", { Parent = TitleContainer, BackgroundColor3 = Library.Colors.Border, Position = UDim2.new(0, 5, 0.5, 0), Size = UDim2.new(0, 8, 0, 1), BorderSizePixel = 0 })
                
                local LineRight = Create("Frame", { Parent = TitleContainer, BackgroundColor3 = Library.Colors.Border, Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -15, 0, 1), BorderSizePixel = 0 })
                SecTitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    LineRight.Position = UDim2.new(0, 15 + SecTitle.AbsoluteSize.X + 2, 0.5, 0)
                    LineRight.Size = UDim2.new(1, -(15 + SecTitle.AbsoluteSize.X + 7), 0, 1)
                end)

                local ItemContainer = Create("Frame", {
                    Parent = SecInner,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 15),
                    Size = UDim2.new(1, 0, 1, -15)
                })
                local ItemLayout = Create("UIListLayout", { Parent = ItemContainer, Padding = UDim.new(0, 4) })

                local function UpdateHeight()
                    local h = ItemLayout.AbsoluteContentSize.Y + 25
                    SecBorder.Size = UDim2.new(1, 0, 0, h)
                end
                ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)

                -- > Section Elements
                local Section = {}

                function Section:CreateToggle(options)
                    local flag = options.Flag or options.Name
                    Library.Flags[flag] = options.Default or false

                    local ToggleFrame = Create("TextButton", {
                        Parent = ItemContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Text = ""
                    })

                    local BoxBorder = Create("Frame", {
                        Parent = ToggleFrame,
                        BackgroundColor3 = Library.Colors.Border,
                        Position = UDim2.new(0, 10, 0.5, -5),
                        Size = UDim2.new(0, 10, 0, 10),
                        BorderSizePixel = 0
                    })

                    local BoxInner = Create("Frame", {
                        Parent = BoxBorder,
                        BackgroundColor3 = Library.Flags[flag] and Library.Colors.Accent or Library.Colors.Background,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2),
                        BorderSizePixel = 0
                    })

                    local Title = Create("TextLabel", {
                        Parent = ToggleFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 26, 0, 0),
                        Size = UDim2.new(1, -26, 1, 0),
                        Font = Enum.Font.RobotoMono,
                        Text = options.Name,
                        TextColor3 = Library.Flags[flag] and Library.Colors.Text or Library.Colors.DarkText,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    ToggleFrame.MouseButton1Click:Connect(function()
                        Library.Flags[flag] = not Library.Flags[flag]
                        Tween(BoxInner, {BackgroundColor3 = Library.Flags[flag] and Library.Colors.Accent or Library.Colors.Background}, 0.15)
                        Tween(Title, {TextColor3 = Library.Flags[flag] and Library.Colors.Text or Library.Colors.DarkText}, 0.15)
                        if options.Callback then options.Callback(Library.Flags[flag]) end
                    end)
                end

                function Section:CreateSlider(options)
                    local flag = options.Flag or options.Name
                    local min, max = options.Min or 0, options.Max or 100
                    Library.Flags[flag] = options.Default or min

                    local SliderFrame = Create("Frame", {
                        Parent = ItemContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 30)
                    })

                    local Title = Create("TextLabel", {
                        Parent = SliderFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 0, 15),
                        Font = Enum.Font.RobotoMono,
                        Text = options.Name .. " | " .. tostring(Library.Flags[flag]) .. (options.Suffix or ""),
                        TextColor3 = Library.Colors.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local SlideBg = Create("TextButton", {
                        Parent = SliderFrame,
                        BackgroundColor3 = Library.Colors.Background,
                        Position = UDim2.new(0, 10, 0, 18),
                        Size = UDim2.new(1, -20, 0, 6),
                        Text = "",
                        AutoButtonColor = false,
                        BorderSizePixel = 0
                    })

                    local SlideFill = Create("Frame", {
                        Parent = SlideBg,
                        BackgroundColor3 = Library.Colors.Accent,
                        Size = UDim2.new((Library.Flags[flag] - min) / (max - min), 0, 1, 0),
                        BorderSizePixel = 0
                    })

                    local sliding = false
                    local function UpdateSlider(input)
                        local relX = math.clamp(input.Position.X - SlideBg.AbsolutePosition.X, 0, SlideBg.AbsoluteSize.X)
                        local percent = relX / SlideBg.AbsoluteSize.X
                        local value = math.floor(min + (max - min) * percent)
                        Library.Flags[flag] = value
                        Title.Text = options.Name .. " | " .. tostring(value) .. (options.Suffix or "")
                        SlideFill.Size = UDim2.new(percent, 0, 1, 0)
                        if options.Callback then options.Callback(value) end
                    end

                    SlideBg.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            UpdateSlider(input)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
                    end)
                end

                function Section:CreateDropdown(options)
                    local flag = options.Flag or options.Name
                    Library.Flags[flag] = options.Default or options.Options[1] or ""

                    local DropFrame = Create("Frame", {
                        Parent = ItemContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 40)
                    })

                    Create("TextLabel", {
                        Parent = DropFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 0, 15),
                        Font = Enum.Font.RobotoMono,
                        Text = options.Name,
                        TextColor3 = Library.Colors.DarkText,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local DropBtn = Create("TextButton", {
                        Parent = DropFrame,
                        BackgroundColor3 = Library.Colors.Border,
                        Position = UDim2.new(0, 10, 0, 18),
                        Size = UDim2.new(1, -20, 0, 18),
                        Text = "",
                        BorderSizePixel = 0
                    })

                    local DropInner = Create("Frame", {
                        Parent = DropBtn,
                        BackgroundColor3 = Library.Colors.Background,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2),
                        BorderSizePixel = 0
                    })

                    local CurrentVal = Create("TextLabel", {
                        Parent = DropInner,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 0, 0),
                        Size = UDim2.new(1, -10, 1, 0),
                        Font = Enum.Font.RobotoMono,
                        Text = Library.Flags[flag],
                        TextColor3 = Library.Colors.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    -- Dropdown List Container
                    local ListFrame = Create("Frame", {
                        Parent = ScreenGui, -- Parent to ScreenGui to bypass clipping
                        BackgroundColor3 = Library.Colors.Border,
                        Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, #options.Options * 16 + 2),
                        Visible = false,
                        ZIndex = 100,
                        BorderSizePixel = 0
                    })
                    
                    local ListInner = Create("Frame", {
                        Parent = ListFrame,
                        BackgroundColor3 = Library.Colors.Background,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2),
                        ZIndex = 100,
                        BorderSizePixel = 0
                    })

                    local ListLayout = Create("UIListLayout", { Parent = ListInner })

                    for _, opt in ipairs(options.Options) do
                        local OptBtn = Create("TextButton", {
                            Parent = ListInner,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 16),
                            Font = Enum.Font.RobotoMono,
                            Text = "  " .. opt,
                            TextColor3 = opt == Library.Flags[flag] and Library.Colors.Accent or Library.Colors.DarkText,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 101
                        })

                        OptBtn.MouseButton1Click:Connect(function()
                            Library.Flags[flag] = opt
                            CurrentVal.Text = opt
                            ListFrame.Visible = false
                            
                            -- Reset colors
                            for _, v in ipairs(ListInner:GetChildren()) do
                                if v:IsA("TextButton") then
                                    v.TextColor3 = v.Text:match(opt) and Library.Colors.Accent or Library.Colors.DarkText
                                end
                            end

                            if options.Callback then options.Callback(opt) end
                        end)
                    end

                    DropBtn.MouseButton1Click:Connect(function()
                        if ListFrame.Visible then
                            ListFrame.Visible = false
                        else
                            ListFrame.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + 20)
                            ListFrame.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, #options.Options * 16 + 2)
                            ListFrame.Visible = true
                        end
                    end)
                end

                return Section
            end

            -- If it's the first tab created, select it
            if not Window.ActiveTab then
                Window.ActiveTab = {Content = TabContent, Btn = TabBtn}
                TabContent.Visible = true
                Tween(TabBtn, {TextColor3 = Library.Colors.Text}, 0)
                ActiveTabLine.Visible = true
                task.delay(0.1, function()
                    ActiveTabLine.Position = UDim2.new(0, 0, 0, TabBtn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 2)
                end)
            end

            table.insert(Window.Tabs, Tab)
            return Tab
        end

        return Group
    end

    return Window
end

-- Return library so it can be called via loadstring from Github
return Library
