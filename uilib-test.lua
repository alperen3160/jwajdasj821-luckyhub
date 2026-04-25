--[[
    ====================================================================
    * JUJU PRIVATE UI LIBRARY - PERFECTED CLONE (Universal CoreGui)
    * Features: Perfect pixel borders, masked section titles, 
    * circle toggles, smooth tweening, full element suite.
    * Lines: ~1000 (Full Featured & Production Ready)
    ====================================================================
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- > ( Container Setup )
local ParentContainer = nil
if gethui then ParentContainer = gethui()
elseif syn and syn.protect_gui then ParentContainer = CoreGui
else ParentContainer = CoreGui:FindFirstChild("RobloxGui") or CoreGui end

-- > ( Library Base & Theme )
local Library = {
    Name = "JujuUI_Instance",
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(12, 12, 12),       -- Deepest background
        Sidebar = Color3.fromRGB(12, 12, 12),          -- Sidebar background
        SectionBg = Color3.fromRGB(15, 15, 15),        -- Inside sections
        Border = Color3.fromRGB(35, 35, 35),           -- All outlines
        Accent = Color3.fromRGB(132, 203, 217),        -- The signature Juju blue
        Text = Color3.fromRGB(220, 220, 220),          -- Active text
        DarkText = Color3.fromRGB(110, 110, 110),      -- Inactive text
        Hover = Color3.fromRGB(25, 25, 25),            -- Hover states
    },
    Toggled = true,
    Dragging = false
}

-- > ( Utility Functions )
local Utility = {}

function Utility:Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then inst[k] = v end
    end
    if properties.Parent then inst.Parent = properties.Parent end
    return inst
end

function Utility:Tween(instance, properties, duration, style, direction)
    local tInfo = TweenInfo.new(
        duration or 0.2, 
        style or Enum.EasingStyle.Sine, 
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tInfo, properties)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(dragPart, mainFrame)
    local dragToggle, dragStart, startPos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility:GetTextBounds(text, font, size)
    local temp = Instance.new("TextLabel")
    temp.Text = text
    temp.Font = font
    temp.TextSize = size
    local bounds = temp.TextBounds
    temp:Destroy()
    return bounds
end

-- > ( UI Construction )
function Library:CreateWindow(options)
    local Window = {
        Name = options.Name or "juju private",
        Size = options.Size or UDim2.new(0, 620, 0, 480),
        Tabs = {},
        ActiveTab = nil,
        Groups = {}
    }

    -- Main ScreenGui
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = Library.Name,
        Parent = ParentContainer,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    Library.Gui = ScreenGui

    -- Window Frame
    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2),
        Size = Window.Size,
        BorderSizePixel = 0,
        ClipsDescendants = false
    })
    
    Utility:Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 5)})
    Utility:Create("UIStroke", {Parent = MainFrame, Color = Library.Theme.Border, Thickness = 1})

    -- Shadow
    local Shadow = Utility:Create("ImageLabel", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = 0
    })

    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Sidebar,
        Size = UDim2.new(0, 130, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Utility:Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 5)})
    
    -- Fix corner glitch for the right side of sidebar
    local SidebarCover = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Sidebar,
        Position = UDim2.new(1, -5, 0, 0),
        Size = UDim2.new(0, 5, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 2
    })

    local Divider = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Border,
        Position = UDim2.new(0, 130, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 3
    })

    -- Logo Area
    local LogoArea = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -15, 0, 45)
    })

    local LogoIcon = Utility:Create("TextLabel", {
        Parent = LogoArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "j",
        TextColor3 = Library.Theme.Accent,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local NameFirst = Utility:Create("TextLabel", {
        Parent = LogoArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 2),
        Size = UDim2.new(1, -25, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = string.split(Window.Name, " ")[1] or "juju",
        TextColor3 = Library.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local NameSecond = Utility:Create("TextLabel", {
        Parent = LogoArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 18),
        Size = UDim2.new(1, -25, 0, 14),
        Font = Enum.Font.GothamMedium,
        Text = string.split(Window.Name, " ")[2] or "private",
        TextColor3 = Library.Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Drag Hitbox
    local DragFrame = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 10
    })
    Utility:MakeDraggable(DragFrame, MainFrame)

    -- Bottom Icons (Like the reference image)
    local BottomIcons = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 1, -30),
        Size = UDim2.new(1, -15, 0, 20)
    })
    
    local IconList = Utility:Create("UIListLayout", {
        Parent = BottomIcons,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    local icons = {"🔍", "📌", "⚙"}
    for i, v in ipairs(icons) do
        Utility:Create("TextLabel", {
            Parent = BottomIcons,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 15, 0, 15),
            Font = Enum.Font.Gotham,
            Text = v,
            TextColor3 = Library.Theme.DarkText,
            TextSize = 14
        })
    end

    -- Tab Scrolling Frame
    local TabContainer = Utility:Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -110),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        BorderSizePixel = 0
    })
    
    local TabList = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })

    -- The active tab blue line
    local TabIndicator = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Library.Theme.Accent,
        Size = UDim2.new(0, 2, 0, 14),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5
    })

    -- Content Area
    local ContentArea = Utility:Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 131, 0, 0),
        Size = UDim2.new(1, -131, 1, 0),
        ClipsDescendants = true
    })

    -- Insert Keybind Toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Insert then
            Library.Toggled = not Library.Toggled
            ScreenGui.Enabled = Library.Toggled
        end
    end)

    -- > ( Group Creation )
    function Window:CreateGroup(groupName)
        local Group = {Name = groupName}

        local GroupHeader = Utility:Create("Frame", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30)
        })

        Utility:Create("TextLabel", {
            Parent = GroupHeader,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 5),
            Size = UDim2.new(1, -15, 0, 15),
            Font = Enum.Font.GothamMedium,
            Text = groupName,
            TextColor3 = Library.Theme.Accent,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Utility:Create("Frame", {
            Parent = GroupHeader,
            BackgroundColor3 = Library.Theme.Border,
            Position = UDim2.new(0, 15, 0, 22),
            Size = UDim2.new(0, 60, 0, 1),
            BorderSizePixel = 0
        })

        -- > ( Tab Creation )
        function Group:CreateTab(tabName)
            local Tab = {Name = tabName}

            local TabBtn = Utility:Create("TextButton", {
                Parent = TabContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Text = "",
                AutoButtonColor = false
            })

            local TabText = Utility:Create("TextLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -15, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = tabName,
                TextColor3 = Library.Theme.DarkText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local TabPage = Utility:Create("ScrollingFrame", {
                Parent = ContentArea,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 0,
                Visible = false
            })

            local LeftCol = Utility:Create("Frame", {
                Parent = TabPage,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 15),
                Size = UDim2.new(0.5, -20, 1, -30)
            })
            local LeftLayout = Utility:Create("UIListLayout", {Parent = LeftCol, Padding = UDim.new(0, 15)})

            local RightCol = Utility:Create("Frame", {
                Parent = TabPage,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 5, 0, 15),
                Size = UDim2.new(0.5, -20, 1, -30)
            })
            local RightLayout = Utility:Create("UIListLayout", {Parent = RightCol, Padding = UDim.new(0, 15)})

            TabBtn.MouseButton1Click:Connect(function()
                if Window.ActiveTab then
                    Window.ActiveTab.Page.Visible = false
                    Utility:Tween(Window.ActiveTab.Text, {TextColor3 = Library.Theme.DarkText}, 0.15)
                end
                Window.ActiveTab = {Page = TabPage, Text = TabText, Btn = TabBtn}
                TabPage.Visible = true
                Utility:Tween(TabText, {TextColor3 = Library.Theme.Text}, 0.15)

                TabIndicator.Visible = true
                Utility:Tween(TabIndicator, {
                    Position = UDim2.new(0, 0, 0, TabBtn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 4)
                }, 0.2, Enum.EasingStyle.Exponential)
            end)

            -- Handle scrolling resizing
            local function UpdateCanvas()
                local leftSize = LeftLayout.AbsoluteContentSize.Y
                local rightSize = RightLayout.AbsoluteContentSize.Y
                local max = math.max(leftSize, rightSize)
                TabPage.CanvasSize = UDim2.new(0, 0, 0, max + 30)
            end
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

            -- > ( Section Creation )
            function Tab:CreateSection(secName, side)
                local Section = {Elements = {}}
                local targetParent = side == "Right" and RightCol or LeftCol

                -- Section Main Container
                local SecContainer = Utility:Create("Frame", {
                    Parent = targetParent,
                    BackgroundColor3 = Library.Theme.SectionBg,
                    Size = UDim2.new(1, 0, 0, 40), -- Will dynamic scale
                    BorderSizePixel = 0
                })
                Utility:Create("UICorner", {Parent = SecContainer, CornerRadius = UDim.new(0, 4)})
                Utility:Create("UIStroke", {Parent = SecContainer, Color = Library.Theme.Border, Thickness = 1})

                -- The Magic Trick for Inline Title (Masking the top stroke)
                local titleWidth = Utility:GetTextBounds("— " .. secName .. " ", Enum.Font.GothamMedium, 12).X
                
                local TitleMask = Utility:Create("Frame", {
                    Parent = SecContainer,
                    BackgroundColor3 = Library.Theme.Background, -- Match background to hide stroke
                    Position = UDim2.new(0, 12, 0, -2),
                    Size = UDim2.new(0, titleWidth + 6, 0, 4),
                    BorderSizePixel = 0
                })

                local TitleText = Utility:Create("TextLabel", {
                    Parent = SecContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, -7),
                    Size = UDim2.new(0, titleWidth, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = "— " .. secName,
                    TextColor3 = Library.Theme.DarkText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ElementContainer = Utility:Create("Frame", {
                    Parent = SecContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 15),
                    Size = UDim2.new(1, -24, 1, -20)
                })
                local ElemLayout = Utility:Create("UIListLayout", {
                    Parent = ElementContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                })

                ElemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    SecContainer.Size = UDim2.new(1, 0, 0, ElemLayout.AbsoluteContentSize.Y + 25)
                end)

                -- > ( Elements )
                
                function Section:CreateToggle(options)
                    local Toggle = {
                        Flag = options.Flag or options.Name,
                        Value = options.Default or false,
                        Callback = options.Callback or function() end
                    }
                    Library.Flags[Toggle.Flag] = Toggle.Value

                    local TogFrame = Utility:Create("TextButton", {
                        Parent = ElementContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Text = ""
                    })

                    -- The Circle!
                    local TogOuter = Utility:Create("Frame", {
                        Parent = TogFrame,
                        BackgroundColor3 = Library.Theme.SectionBg,
                        Position = UDim2.new(0, 0, 0.5, -7),
                        Size = UDim2.new(0, 14, 0, 14),
                        BorderSizePixel = 0
                    })
                    Utility:Create("UICorner", {Parent = TogOuter, CornerRadius = UDim.new(1, 0)})
                    local TogStroke = Utility:Create("UIStroke", {
                        Parent = TogOuter,
                        Color = Library.Theme.Border,
                        Thickness = 1
                    })

                    local TogInner = Utility:Create("Frame", {
                        Parent = TogOuter,
                        BackgroundColor3 = Library.Theme.Accent,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 0, 0, 0), -- Starts small
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BorderSizePixel = 0
                    })
                    Utility:Create("UICorner", {Parent = TogInner, CornerRadius = UDim.new(1, 0)})

                    local Title = Utility:Create("TextLabel", {
                        Parent = TogFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 22, 0, 0),
                        Size = UDim2.new(1, -50, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = options.Name,
                        TextColor3 = Toggle.Value and Library.Theme.Text or Library.Theme.DarkText,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    if options.HasGear then
                        Utility:Create("TextLabel", {
                            Parent = TogFrame,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(1, -15, 0, 0),
                            Size = UDim2.new(0, 15, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = "⚙",
                            TextColor3 = Library.Theme.DarkText,
                            TextSize = 14
                        })
                    end

                    local function UpdateState(anim)
                        if Toggle.Value then
                            Utility:Tween(TogInner, {Size = UDim2.new(1, -4, 1, -4)}, anim and 0.2 or 0)
                            Utility:Tween(Title, {TextColor3 = Library.Theme.Text}, anim and 0.2 or 0)
                            Utility:Tween(TogStroke, {Color = Library.Theme.Accent}, anim and 0.2 or 0)
                        else
                            Utility:Tween(TogInner, {Size = UDim2.new(0, 0, 0, 0)}, anim and 0.2 or 0)
                            Utility:Tween(Title, {TextColor3 = Library.Theme.DarkText}, anim and 0.2 or 0)
                            Utility:Tween(TogStroke, {Color = Library.Theme.Border}, anim and 0.2 or 0)
                        end
                        Library.Flags[Toggle.Flag] = Toggle.Value
                        Toggle.Callback(Toggle.Value)
                    end
                    UpdateState(false)

                    TogFrame.MouseButton1Click:Connect(function()
                        Toggle.Value = not Toggle.Value
                        UpdateState(true)
                    end)

                    return Toggle
                end

                function Section:CreateSlider(options)
                    local Slider = {
                        Flag = options.Flag or options.Name,
                        Min = options.Min or 0,
                        Max = options.Max or 100,
                        Value = options.Default or 0,
                        Suffix = options.Suffix or "",
                        Callback = options.Callback or function() end
                    }
                    Library.Flags[Slider.Flag] = Slider.Value

                    local SlidFrame = Utility:Create("Frame", {
                        Parent = ElementContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 36)
                    })

                    local Title = Utility:Create("TextLabel", {
                        Parent = SlidFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, -20, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = options.Name .. " | " .. tostring(Slider.Value) .. Slider.Suffix,
                        TextColor3 = Library.Theme.DarkText,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local GearIcon = Utility:Create("TextLabel", {
                        Parent = SlidFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -15, 0, 0),
                        Size = UDim2.new(0, 15, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = "⚙",
                        TextColor3 = Library.Theme.DarkText,
                        TextSize = 14
                    })

                    local SlidBg = Utility:Create("TextButton", {
                        Parent = SlidFrame,
                        BackgroundColor3 = Library.Theme.Background,
                        Position = UDim2.new(0, 0, 0, 20),
                        Size = UDim2.new(1, 0, 0, 8),
                        Text = "",
                        AutoButtonColor = false,
                        BorderSizePixel = 0
                    })
                    Utility:Create("UICorner", {Parent = SlidBg, CornerRadius = UDim.new(1, 0)})
                    Utility:Create("UIStroke", {Parent = SlidBg, Color = Library.Theme.Border, Thickness = 1})

                    local SlidFill = Utility:Create("Frame", {
                        Parent = SlidBg,
                        BackgroundColor3 = Library.Theme.Accent,
                        Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0),
                        BorderSizePixel = 0
                    })
                    Utility:Create("UICorner", {Parent = SlidFill, CornerRadius = UDim.new(1, 0)})

                    local sliding = false
                    local function updateSlider(input)
                        local relX = math.clamp(input.Position.X - SlidBg.AbsolutePosition.X, 0, SlidBg.AbsoluteSize.X)
                        local percent = relX / SlidBg.AbsoluteSize.X
                        Slider.Value = math.floor(Slider.Min + (Slider.Max - Slider.Min) * percent)
                        Library.Flags[Slider.Flag] = Slider.Value
                        
                        Title.Text = options.Name .. " | " .. tostring(Slider.Value) .. Slider.Suffix
                        Utility:Tween(SlidFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
                        Slider.Callback(Slider.Value)
                    end

                    SlidBg.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            updateSlider(input)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input)
                        end
                    end)

                    return Slider
                end

                function Section:CreateDropdown(options)
                    local Dropdown = {
                        Flag = options.Flag or options.Name,
                        Value = options.Default or options.Options[1] or "",
                        Options = options.Options or {},
                        Callback = options.Callback or function() end,
                        IsOpen = false
                    }
                    Library.Flags[Dropdown.Flag] = Dropdown.Value

                    local DropFrame = Utility:Create("Frame", {
                        Parent = ElementContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 42)
                    })

                    Utility:Create("TextLabel", {
                        Parent = DropFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 14),
                        Font = Enum.Font.Gotham,
                        Text = options.Name,
                        TextColor3 = Library.Theme.DarkText,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local DropBtn = Utility:Create("TextButton", {
                        Parent = DropFrame,
                        BackgroundColor3 = Library.Theme.Background,
                        Position = UDim2.new(0, 0, 0, 18),
                        Size = UDim2.new(1, 0, 0, 20),
                        Text = "",
                        AutoButtonColor = false,
                        BorderSizePixel = 0
                    })
                    Utility:Create("UICorner", {Parent = DropBtn, CornerRadius = UDim.new(0, 3)})
                    Utility:Create("UIStroke", {Parent = DropBtn, Color = Library.Theme.Border, Thickness = 1})

                    local CurrentVal = Utility:Create("TextLabel", {
                        Parent = DropBtn,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = Dropdown.Value,
                        TextColor3 = Library.Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local Hamburger = Utility:Create("TextLabel", {
                        Parent = DropBtn,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -20, 0, 0),
                        Size = UDim2.new(0, 20, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = "≡",
                        TextColor3 = Library.Theme.DarkText,
                        TextSize = 16
                    })

                    -- The popup list
                    local ListBox = Utility:Create("Frame", {
                        Parent = ScreenGui,
                        BackgroundColor3 = Library.Theme.Background,
                        Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, 0),
                        ClipsDescendants = true,
                        Visible = false,
                        ZIndex = 50,
                        BorderSizePixel = 0
                    })
                    Utility:Create("UICorner", {Parent = ListBox, CornerRadius = UDim.new(0, 3)})
                    Utility:Create("UIStroke", {Parent = ListBox, Color = Library.Theme.Border, Thickness = 1})
                    
                    local ListLayout = Utility:Create("UIListLayout", {Parent = ListBox})

                    -- Build Options
                    local function BuildList()
                        for _, v in ipairs(ListBox:GetChildren()) do
                            if v:IsA("TextButton") then v:Destroy() end
                        end
                        for i, opt in ipairs(Dropdown.Options) do
                            local optBtn = Utility:Create("TextButton", {
                                Parent = ListBox,
                                BackgroundColor3 = Library.Theme.Background,
                                Size = UDim2.new(1, 0, 0, 20),
                                Text = "",
                                AutoButtonColor = false,
                                BorderSizePixel = 0,
                                ZIndex = 51
                            })
                            local optText = Utility:Create("TextLabel", {
                                Parent = optBtn,
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0, 8, 0, 0),
                                Size = UDim2.new(1, -16, 1, 0),
                                Font = Enum.Font.Gotham,
                                Text = opt,
                                TextColor3 = opt == Dropdown.Value and Library.Theme.Accent or Library.Theme.DarkText,
                                TextSize = 12,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                ZIndex = 52
                            })

                            optBtn.MouseEnter:Connect(function()
                                Utility:Tween(optBtn, {BackgroundColor3 = Library.Theme.SectionBg}, 0.1)
                            end)
                            optBtn.MouseLeave:Connect(function()
                                Utility:Tween(optBtn, {BackgroundColor3 = Library.Theme.Background}, 0.1)
                            end)

                            optBtn.MouseButton1Click:Connect(function()
                                Dropdown.Value = opt
                                Library.Flags[Dropdown.Flag] = opt
                                CurrentVal.Text = opt
                                Dropdown.IsOpen = false
                                Utility:Tween(Hamburger, {Rotation = 0}, 0.2)
                                Utility:Tween(ListBox, {Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, 0)}, 0.2).Completed:Connect(function()
                                    if not Dropdown.IsOpen then ListBox.Visible = false end
                                end)
                                BuildList() -- Refresh colors
                                Dropdown.Callback(opt)
                            end)
                        end
                    end
                    BuildList()

                    DropBtn.MouseButton1Click:Connect(function()
                        Dropdown.IsOpen = not Dropdown.IsOpen
                        if Dropdown.IsOpen then
                            ListBox.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + 25)
                            ListBox.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, 0)
                            ListBox.Visible = true
                            Utility:Tween(Hamburger, {Rotation = 90}, 0.2)
                            Utility:Tween(ListBox, {Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, #Dropdown.Options * 20)}, 0.2)
                        else
                            Utility:Tween(Hamburger, {Rotation = 0}, 0.2)
                            Utility:Tween(ListBox, {Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, 0)}, 0.2).Completed:Connect(function()
                                if not Dropdown.IsOpen then ListBox.Visible = false end
                            end)
                        end
                    end)

                    return Dropdown
                end

                return Section
            end

            -- Init first tab
            if not Window.ActiveTab then
                Window.ActiveTab = {Page = TabPage, Text = TabText, Btn = TabBtn}
                TabPage.Visible = true
                TabText.TextColor3 = Library.Theme.Text
                TabIndicator.Visible = true
                task.delay(0.05, function()
                    TabIndicator.Position = UDim2.new(0, 0, 0, TabBtn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 4)
                end)
            end

            table.insert(Window.Tabs, Tab)
            return Tab
        end

        table.insert(Window.Groups, Group)
        return Group
    end

    return Window
end

-- > ( Constructing the UI exactly as the image )
local Window = Library:CreateWindow({Name = "juju private"})

-- Groups
local MainGroup = Window:CreateGroup("main")
local VisGroup = Window:CreateGroup("visuals")
local MiscGroup = Window:CreateGroup("misc.")

-- Tabs
local RageTab = MainGroup:CreateTab("ragebot")
MainGroup:CreateTab("legitbot")

VisGroup:CreateTab("players")
VisGroup:CreateTab("general")
VisGroup:CreateTab("skins")

MiscGroup:CreateTab("players")
MiscGroup:CreateTab("configs")
MiscGroup:CreateTab("addons")
MiscGroup:CreateTab("shop")
MiscGroup:CreateTab("main")

-- Sections in Ragebot (Matching screenshot identically)
local GeneralSec = RageTab:CreateSection("general", "Left")
GeneralSec:CreateToggle({Name = "ragebot", Flag = "Ragebot"})
GeneralSec:CreateToggle({Name = "auto fire", Flag = "AutoFire", HasGear = true})
GeneralSec:CreateToggle({Name = "auto equip", Flag = "AutoEquip", HasGear = true})
GeneralSec:CreateToggle({Name = "spam resolver", Flag = "SpamResolver", HasGear = true})

GeneralSec:CreateDropdown({Name = "target hitbox", Options = {"head", "torso", "legs"}, Default = "head"})

GeneralSec:CreateSlider({Name = "prediction", Suffix = " | auto", Min = 0, Max = 100, Default = 0})
GeneralSec:CreateSlider({Name = "shot delay", Suffix = " | none", Min = 0, Max = 100, Default = 0})
GeneralSec:CreateSlider({Name = "field of view", Suffix = " | full", Min = 0, Max = 100, Default = 100})
GeneralSec:CreateSlider({Name = "fire cooldown", Suffix = "ms", Min = 0, Max = 50, Default = 5})

GeneralSec:CreateToggle({Name = "target selection", HasGear = true})

local VisSec = RageTab:CreateSection("visualization", "Left")
VisSec:CreateToggle({Name = "crosshair follow"})
VisSec:CreateToggle({Name = "3d target circle", HasGear = true})
VisSec:CreateToggle({Name = "view target", HasGear = true})
VisSec:CreateToggle({Name = "face target"})
VisSec:CreateToggle({Name = "show fov", HasGear = true})
VisSec:CreateToggle({Name = "tracer", HasGear = true})

local AntiSec = RageTab:CreateSection("anti", "Right")
AntiSec:CreateToggle({Name = "sender rate value", HasGear = true})
AntiSec:CreateToggle({Name = "network desync"})
AntiSec:CreateToggle({Name = "velocity desync", HasGear = true})
AntiSec:CreateToggle({Name = "fake position", HasGear = true})
AntiSec:CreateToggle({Name = "void hide", HasGear = true})

local UtilSec = RageTab:CreateSection("utility", "Right")
UtilSec:CreateToggle({Name = "safe purchasing", HasGear = true})
UtilSec:CreateToggle({Name = "auto loadout", HasGear = true})
UtilSec:CreateToggle({Name = "follow target", HasGear = true})
UtilSec:CreateToggle({Name = "auto stomp", HasGear = true})
UtilSec:CreateToggle({Name = "auto ammo", HasGear = true})
UtilSec:CreateToggle({Name = "auto armor", HasGear = true})
UtilSec:CreateToggle({Name = "anti stomp", HasGear = true})
UtilSec:CreateToggle({Name = "auto mask", HasGear = true})
UtilSec:CreateToggle({Name = "auto heal", HasGear = true})
UtilSec:CreateToggle({Name = "anti taser"})
UtilSec:CreateToggle({Name = "rapid fire"})

return Library
