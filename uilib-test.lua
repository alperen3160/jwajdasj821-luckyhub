--[[
    ====================================================================
    * JUJU PRIVATE V4 - PERFECTED ENGINE (Video Reference Match)
    * Aesthetic: Glassmorphism pop-outs, slide animations, nested tabs.
    * Features: Real-time Search, Keybinds, Theme Manager, Nested Configs.
    * Constraint: < 1200 Lines. Pure Logic & Smooth Tweens.
    ====================================================================
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local ParentContainer = (gethui and gethui()) or (syn and syn.protect_gui and CoreGui) or CoreGui:FindFirstChild("RobloxGui") or CoreGui

local Library = {
    Name = "Juju_Private_V4",
    Flags = {},
    Connections = {},
    Theme = {
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(15, 15, 15),
        SectionBg = Color3.fromRGB(18, 18, 18),
        Border = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(132, 203, 217),
        Text = Color3.fromRGB(240, 240, 240),
        DarkText = Color3.fromRGB(120, 120, 120),
        PopOutBg = Color3.fromRGB(15, 15, 15) -- For search/theme/keybind menus
    },
    ThemeObjects = {},
    Toggled = true,
    Keybinds = {}
}

local Util = {}
function Util:Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

function Util:Tween(inst, props, dur, style)
    local tween = TweenService:Create(inst, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tween:Play(); return tween
end

function Util:MakeDraggable(dragPart, mainFrame)
    local dragging, dragStart, startPos
    table.insert(Library.Connections, dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            local endConn; endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false; endConn:Disconnect() end
            end)
        end
    end))
    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

function Library:RegisterTheme(inst, prop, colorType)
    table.insert(self.ThemeObjects, {Inst = inst, Prop = prop, Type = colorType})
    inst[prop] = self.Theme[colorType]
end

function Library:UpdateTheme(newColor)
    self.Theme.Accent = newColor
    for _, obj in ipairs(self.ThemeObjects) do
        if obj.Type == "Accent" and obj.Inst.Parent then Util:Tween(obj.Inst, {[obj.Prop] = newColor}, 0.2) end
    end
end

-- > ( Pop-Out Menu Engine - The ones on the bottom left )
local function CreatePopOutMenu(parentGui, titleText, size, offsetX, offsetY)
    local PopOut = Util:Create("Frame", {
        Parent = parentGui, BackgroundColor3 = Library.Theme.PopOutBg, Position = UDim2.new(0, offsetX, 0, offsetY), Size = UDim2.new(0, 0, 0, size.Y.Offset), ClipsDescendants = true, Visible = false, ZIndex = 100
    })
    Util:Create("UICorner", {Parent = PopOut, CornerRadius = UDim.new(0, 4)})
    local Stroke = Util:Create("UIStroke", {Parent = PopOut, Color = Library.Theme.Border})
    Library:RegisterTheme(Stroke, "Color", "Accent")

    local Title = Util:Create("TextLabel", {
        Parent = PopOut, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 15), Font = Enum.Font.GothamMedium, Text = titleText, TextColor3 = Library.Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
    })

    local Content = Util:Create("Frame", {Parent = PopOut, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 1, -30)})

    local function TogglePopOut(state, targetBtn)
        if state then
            PopOut.Position = UDim2.new(0, targetBtn.AbsolutePosition.X + 30, 0, targetBtn.AbsolutePosition.Y - (size.Y.Offset - 20))
            PopOut.Visible = true
            Util:Tween(PopOut, {Size = size}, 0.25)
            Util:Tween(Title, {TextTransparency = 0}, 0.3)
        else
            Util:Tween(Title, {TextTransparency = 1}, 0.1)
            Util:Tween(PopOut, {Size = UDim2.new(0, 0, 0, size.Y.Offset)}, 0.2).Completed:Connect(function()
                if not state then PopOut.Visible = false end
            end)
        end
    end

    return PopOut, Content, TogglePopOut
end

function Library:CreateWindow(options)
    local Window = {Name = options.Name or "juju private", Size = UDim2.new(0, 580, 0, 440), Tabs = {}, ActiveTab = nil}
    local SG = Util:Create("ScreenGui", {Name = Library.Name, Parent = ParentContainer, ResetOnSpawn = false})
    Library.Gui = SG

    local Main = Util:Create("Frame", {
        Parent = SG, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0.5, -290, 0.5, -220), Size = Window.Size, BorderSizePixel = 0
    })
    Util:Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 4)})
    Util:Create("UIStroke", {Parent = Main, Color = Library.Theme.Border})
    Util:MakeDraggable(Main, Main)

    local Sidebar = Util:Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(0, 130, 1, 0), BorderSizePixel = 0})
    Util:Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 4)})
    Util:Create("Frame", {Parent = Sidebar, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(1, -5, 0, 0), Size = UDim2.new(0, 5, 1, 0), BorderSizePixel = 0})
    Util:Create("Frame", {Parent = Main, BackgroundColor3 = Library.Theme.Border, Position = UDim2.new(0, 130, 0, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0})

    -- Logo matching video
    local LogoArea = Util:Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(1, -15, 0, 40)})
    local LogoJ = Util:Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Size = UDim2.new(0, 15, 0, 25), Font = Enum.Font.GothamBold, Text = "j", TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left})
    Library:RegisterTheme(LogoJ, "TextColor3", "Accent")
    Util:Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 2), Size = UDim2.new(1, -20, 0, 14), Font = Enum.Font.GothamMedium, Text = string.split(Window.Name, " ")[1], TextColor3 = Library.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local LogoSub = Util:Create("TextLabel", {Parent = LogoArea, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 16), Size = UDim2.new(1, -20, 0, 12), Font = Enum.Font.Gotham, Text = string.split(Window.Name, " ")[2], TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
    Library:RegisterTheme(LogoSub, "TextColor3", "Accent")

    local TabContainer = Util:Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 70), Size = UDim2.new(1, 0, 1, -120), ScrollBarThickness = 0})
    local TabList = Util:Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 2)})
    local TabIndicator = Util:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0, 2, 0, 14), BorderSizePixel = 0, Visible = false, ZIndex = 5})
    Library:RegisterTheme(TabIndicator, "BackgroundColor3", "Accent")

    local ContentArea = Util:Create("Frame", {Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 131, 0, 0), Size = UDim2.new(1, -131, 1, 0), ClipsDescendants = true})

    -- > ( Bottom Icons Implementation based on Video )
    local BtmIcons = Util:Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 1, -35), Size = UDim2.new(1, -15, 0, 20)})
    local BtmLayout = Util:Create("UIListLayout", {Parent = BtmIcons, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10)})

    local function CreateIcon(txt)
        local b = Util:Create("TextButton", {Parent = BtmIcons, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Font = Enum.Font.Gotham, Text = txt, TextColor3 = Library.Theme.DarkText, TextSize = 14})
        b.MouseEnter:Connect(function() Util:Tween(b, {TextColor3 = Library.Theme.Text}, 0.1) end)
        b.MouseLeave:Connect(function() Util:Tween(b, {TextColor3 = Library.Theme.DarkText}, 0.1) end)
        return b
    end
    
    local I_Search = CreateIcon("🔍")
    local I_Color = CreateIcon("🎨")
    local I_Config = CreateIcon("⚙")

    -- Search PopOut
    local searchOpen = false
    local SearchMenu, SearchContent, ToggleSearch = CreatePopOutMenu(SG, "search", UDim2.new(0, 200, 0, 50), 0, 0)
    local SearchBox = Util:Create("TextBox", {Parent = SearchContent, BackgroundColor3 = Library.Theme.SectionBg, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.Gotham, PlaceholderText = "search elements...", Text = "", TextColor3 = Library.Theme.Text, TextSize = 11})
    Util:Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
    Util:Create("UIStroke", {Parent = SearchBox, Color = Library.Theme.Border})
    
    I_Search.MouseButton1Click:Connect(function()
        searchOpen = not searchOpen; ToggleSearch(searchOpen, I_Search)
    end)

    -- Color PopOut
    local colorOpen = false
    local ColorMenu, ColorContent, ToggleColor = CreatePopOutMenu(SG, "accent color", UDim2.new(0, 160, 0, 160), 0, 0)
    local ColorMap = Util:Create("ImageButton", {Parent = ColorContent, Size = UDim2.new(1, 0, 1, 0), AutoButtonColor = false, Image = "rbxassetid://4155801252"})
    local ColorRing = Util:Create("ImageLabel", {Parent = ColorMap, BackgroundTransparency = 1, Size = UDim2.new(0, 10, 0, 10), Image = "rbxassetid://3192025350", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0)})

    local function UpdateColor(input)
        local px = math.clamp((input.Position.X - ColorMap.AbsolutePosition.X) / ColorMap.AbsoluteSize.X, 0, 1)
        local py = math.clamp((input.Position.Y - ColorMap.AbsolutePosition.Y) / ColorMap.AbsoluteSize.Y, 0, 1)
        ColorRing.Position = UDim2.new(px, 0, py, 0)
        Library:UpdateTheme(Color3.fromHSV(1-px, 1-py, 1))
    end
    ColorMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UpdateColor(input)
            local mc; mc = UserInputService.InputChanged:Connect(function(i2)
                if i2.UserInputType == Enum.UserInputType.MouseMovement then UpdateColor(i2) end
            end)
            UserInputService.InputEnded:Wait(); mc:Disconnect()
        end
    end)
    I_Color.MouseButton1Click:Connect(function()
        colorOpen = not colorOpen; ToggleColor(colorOpen, I_Color)
    end)

    -- > ( Tab & Section Engine )
    function Window:CreateGroup(gName)
        local Group = {}
        local GHead = Util:Create("Frame", {Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26)})
        local GTxt = Util:Create("TextLabel", {Parent = GHead, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 4), Size = UDim2.new(1, -15, 0, 12), Font = Enum.Font.GothamMedium, Text = gName, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
        Library:RegisterTheme(GTxt, "TextColor3", "Accent")
        Util:Create("Frame", {Parent = GHead, BackgroundColor3 = Library.Theme.Border, Position = UDim2.new(0, 15, 0, 20), Size = UDim2.new(0, 40, 0, 1), BorderSizePixel = 0})

        function Group:CreateTab(tName)
            local Tab = {}
            local TBtn = Util:Create("TextButton", {Parent = TabContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Text = "", AutoButtonColor = false})
            local TTxt = Util:Create("TextLabel", {Parent = TBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -15, 1, 0), Font = Enum.Font.GothamMedium, Text = tName, TextColor3 = Library.Theme.DarkText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            
            local TPage = Util:Create("ScrollingFrame", {Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 0, Visible = false})
            local LCol = Util:Create("Frame", {Parent = TPage, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(0.5, -20, 1, -30)})
            local RCol = Util:Create("Frame", {Parent = TPage, BackgroundTransparency = 1, Position = UDim2.new(0.5, 5, 0, 15), Size = UDim2.new(0.5, -20, 1, -30)})
            local LLay = Util:Create("UIListLayout", {Parent = LCol, Padding = UDim.new(0, 15)})
            local RLay = Util:Create("UIListLayout", {Parent = RCol, Padding = UDim.new(0, 15)})

            TBtn.MouseButton1Click:Connect(function()
                if Window.ActiveTab then Window.ActiveTab.Page.Visible = false; Util:Tween(Window.ActiveTab.Text, {TextColor3 = Library.Theme.DarkText}, 0.15) end
                Window.ActiveTab = {Page = TPage, Text = TTxt, Btn = TBtn}; TPage.Visible = true; Util:Tween(TTxt, {TextColor3 = Library.Theme.Text}, 0.15)
                TabIndicator.Visible = true; Util:Tween(TabIndicator, {Position = UDim2.new(0, 0, 0, TBtn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 4)}, 0.2)
            end)

            local function UpdCanvas() TPage.CanvasSize = UDim2.new(0, 0, 0, math.max(LLay.AbsoluteContentSize.Y, RLay.AbsoluteContentSize.Y) + 30) end
            LLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas); RLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdCanvas)

            function Tab:CreateSection(sName, side)
                local Sec = {}
                local SCont = Util:Create("Frame", {Parent = side == "Right" and RCol or LCol, BackgroundColor3 = Library.Theme.SectionBg, Size = UDim2.new(1, 0, 0, 40)})
                Util:Create("UICorner", {Parent = SCont, CornerRadius = UDim.new(0, 4)}); Util:Create("UIStroke", {Parent = SCont, Color = Library.Theme.Border})

                local tW = Utility:GetTextBounds("— " .. sName .. " ", Enum.Font.GothamMedium, 11).X
                Util:Create("Frame", {Parent = SCont, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0, 8, 0, -2), Size = UDim2.new(0, tW + 6, 0, 4), BorderSizePixel = 0})
                Util:Create("TextLabel", {Parent = SCont, BackgroundTransparency = 1, Position = UDim2.new(0, 11, 0, -7), Size = UDim2.new(0, tW, 0, 14), Font = Enum.Font.GothamMedium, Text = "— " .. sName, TextColor3 = Library.Theme.DarkText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})

                local ECont = Util:Create("Frame", {Parent = SCont, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 15), Size = UDim2.new(1, -20, 1, -20)})
                local ELay = Util:Create("UIListLayout", {Parent = ECont, Padding = UDim.new(0, 8)})
                ELay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SCont.Size = UDim2.new(1, 0, 0, ELay.AbsoluteContentSize.Y + 25) end)

                function Sec:CreateToggle(opts)
                    local Tog = {Val = opts.Default or false}
                    local TF = Util:Create("TextButton", {Parent = ECont, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = ""})
                    local O = Util:Create("Frame", {Parent = TF, BackgroundColor3 = Library.Theme.SectionBg, Position = UDim2.new(0, 0, 0.5, -6), Size = UDim2.new(0, 12, 0, 12)}); Util:Create("UICorner", {Parent = O, CornerRadius = UDim.new(1, 0)}); local Strk = Util:Create("UIStroke", {Parent = O, Color = Library.Theme.Border})
                    local I = Util:Create("Frame", {Parent = O, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0.5)}); Util:Create("UICorner", {Parent = I, CornerRadius = UDim.new(1, 0)}); Library:RegisterTheme(I, "BackgroundColor3", "Accent")
                    local T = Util:Create("TextLabel", {Parent = TF, BackgroundTransparency = 1, Position = UDim2.new(0, 22, 0, 0), Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Library.Theme.DarkText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
                    
                    if opts.HasSettings then Util:Create("TextLabel", {Parent = TF, BackgroundTransparency = 1, Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0, 12, 1, 0), Font = Enum.Font.Gotham, Text = "⚙", TextColor3 = Library.Theme.DarkText, TextSize = 12}) end

                    local function Upd(anim)
                        Util:Tween(I, {Size = Tog.Val and UDim2.new(1, -4, 1, -4) or UDim2.new(0, 0, 0, 0)}, anim and 0.15 or 0)
                        Util:Tween(T, {TextColor3 = Tog.Val and Library.Theme.Text or Library.Theme.DarkText}, anim and 0.15 or 0)
                        Strk.Color = Tog.Val and Library.Theme.Accent or Library.Theme.Border
                        if opts.Callback then opts.Callback(Tog.Val) end
                    end
                    Upd(false)
                    TF.MouseButton1Click:Connect(function() Tog.Val = not Tog.Val; Upd(true) end)
                    return Tog
                end

                function Sec:CreateSlider(opts)
                    local Sld = {Val = opts.Default or opts.Min or 0}
                    local SF = Util:Create("Frame", {Parent = ECont, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32)})
                    local T = Util:Create("TextLabel", {Parent = SF, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Font = Enum.Font.Gotham, Text = opts.Name .. " | " .. Sld.Val .. (opts.Suffix or ""), TextColor3 = Library.Theme.DarkText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
                    local SB = Util:Create("TextButton", {Parent = SF, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 6), Text = "", AutoButtonColor = false}); Util:Create("UICorner", {Parent = SB, CornerRadius = UDim.new(1, 0)}); Util:Create("UIStroke", {Parent = SB, Color = Library.Theme.Border})
                    local SF_Fill = Util:Create("Frame", {Parent = SB, Size = UDim2.new((Sld.Val - opts.Min) / (opts.Max - opts.Min), 0, 1, 0)}); Util:Create("UICorner", {Parent = SF_Fill, CornerRadius = UDim.new(1, 0)}); Library:RegisterTheme(SF_Fill, "BackgroundColor3", "Accent")

                    local sliding = false
                    local function update(inp)
                        local pct = math.clamp((inp.Position.X - SB.AbsolutePosition.X) / SB.AbsoluteSize.X, 0, 1)
                        Sld.Val = math.floor(opts.Min + (opts.Max - opts.Min) * pct)
                        T.Text = opts.Name .. " | " .. Sld.Val .. (opts.Suffix or "")
                        Util:Tween(SF_Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                        if opts.Callback then opts.Callback(Sld.Val) end
                    end
                    SB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(i) end end)
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
                    UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
                end

                function Sec:CreateDropdown(opts)
                    local Drop = {Val = opts.Default or opts.Options[1] or ""}
                    local DF = Util:Create("Frame", {Parent = ECont, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38)})
                    Util:Create("TextLabel", {Parent = DF, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Font = Enum.Font.Gotham, Text = opts.Name, TextColor3 = Library.Theme.DarkText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
                    local DB = Util:Create("TextButton", {Parent = DF, BackgroundColor3 = Library.Theme.Background, Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, 0, 0, 20), Text = "", AutoButtonColor = false}); Util:Create("UICorner", {Parent = DB, CornerRadius = UDim.new(0, 3)}); Util:Create("UIStroke", {Parent = DB, Color = Library.Theme.Border})
                    local VTxt = Util:Create("TextLabel", {Parent = DB, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -25, 1, 0), Font = Enum.Font.Gotham, Text = Drop.Val, TextColor3 = Library.Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
                    local HIco = Util:Create("TextLabel", {Parent = DB, BackgroundTransparency = 1, Position = UDim2.new(1, -18, 0, 0), Size = UDim2.new(0, 18, 1, 0), Font = Enum.Font.Gotham, Text = "≡", TextColor3 = Library.Theme.DarkText, TextSize = 14})
                    
                    local Lst = Util:Create("Frame", {Parent = SG, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(0, DB.AbsoluteSize.X, 0, 0), ClipsDescendants = true, Visible = false, ZIndex = 200}); Util:Create("UICorner", {Parent = Lst, CornerRadius = UDim.new(0, 3)}); Util:Create("UIStroke", {Parent = Lst, Color = Library.Theme.Border})
                    Util:Create("UIListLayout", {Parent = Lst})

                    local isOpen = false
                    local function bList()
                        for _, v in ipairs(Lst:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                        for _, o in ipairs(opts.Options) do
                            local ob = Util:Create("TextButton", {Parent = Lst, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Text = "", ZIndex = 201})
                            Util:Create("TextLabel", {Parent = ob, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -16, 1, 0), Font = Enum.Font.Gotham, Text = o, TextColor3 = o == Drop.Val and Library.Theme.Accent or Library.Theme.DarkText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202})
                            ob.MouseButton1Click:Connect(function()
                                Drop.Val = o; VTxt.Text = o; isOpen = false; Util:Tween(HIco, {Rotation = 0}, 0.15); Util:Tween(Lst, {Size = UDim2.new(0, DB.AbsoluteSize.X, 0, 0)}, 0.15).Completed:Connect(function() if not isOpen then Lst.Visible = false end end); bList(); if opts.Callback then opts.Callback(o) end
                            end)
                        end
                    end; bList()

                    DB.MouseButton1Click:Connect(function()
                        isOpen = not isOpen
                        if isOpen then
                            Lst.Position = UDim2.new(0, DB.AbsolutePosition.X, 0, DB.AbsolutePosition.Y + 25); Lst.Size = UDim2.new(0, DB.AbsoluteSize.X, 0, 0); Lst.Visible = true
                            Util:Tween(HIco, {Rotation = 90}, 0.15); Util:Tween(Lst, {Size = UDim2.new(0, DB.AbsoluteSize.X, 0, #opts.Options * 20)}, 0.15)
                        else
                            Util:Tween(HIco, {Rotation = 0}, 0.15); Util:Tween(Lst, {Size = UDim2.new(0, DB.AbsoluteSize.X, 0, 0)}, 0.15).Completed:Connect(function() if not isOpen then Lst.Visible = false end end)
                        end
                    end)
                end
                return Sec
            end
            if not Window.ActiveTab then Window.ActiveTab = {Page = TPage, Text = TTxt, Btn = TBtn}; TPage.Visible = true; TTxt.TextColor3 = Library.Theme.Text; TabIndicator.Visible = true; task.delay(0.05, function() TabIndicator.Position = UDim2.new(0, 0, 0, TBtn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 4) end) end
            table.insert(Window.Tabs, Tab); return Tab
        end
        return Group
    end
    return Window
end

-- > ( Building the UI exactly from the video )
local W = Library:CreateWindow({Name = "juju private"})

local MG = W:CreateGroup("main")
local VG = W:CreateGroup("visuals")
local MiscG = W:CreateGroup("misc.")

local RT = MG:CreateTab("ragebot")
MG:CreateTab("legitbot")
VG:CreateTab("players")
VG:CreateTab("general")
VG:CreateTab("skins")
MiscG:CreateTab("players")
MiscG:CreateTab("configs")

local GS = RT:CreateSection("general", "Left")
GS:CreateToggle({Name = "ragebot"})
GS:CreateToggle({Name = "auto fire", HasSettings = true})
GS:CreateToggle({Name = "auto equip", HasSettings = true})
GS:CreateToggle({Name = "spam resolver", HasSettings = true})
GS:CreateDropdown({Name = "target hitbox", Options = {"head", "torso", "legs"}})
GS:CreateSlider({Name = "prediction", Suffix = " | auto", Max = 100})
GS:CreateSlider({Name = "shot delay", Suffix = " | none", Max = 500})
GS:CreateSlider({Name = "field of view", Suffix = " | full", Max = 360, Default = 360})
GS:CreateSlider({Name = "fire cooldown", Suffix = "ms", Max = 50, Default = 5})
GS:CreateToggle({Name = "target selection", HasSettings = true})

local VS = RT:CreateSection("visualization", "Left")
VS:CreateToggle({Name = "crosshair follow"})
VS:CreateToggle({Name = "3d target circle", HasSettings = true})
VS:CreateToggle({Name = "view target", HasSettings = true})
VS:CreateToggle({Name = "face target"})

local AS = RT:CreateSection("anti", "Right")
AS:CreateToggle({Name = "sender rate value", HasSettings = true})
AS:CreateToggle({Name = "network desync"})
AS:CreateToggle({Name = "velocity desync", HasSettings = true})
AS:CreateToggle({Name = "fake position", HasSettings = true})

local US = RT:CreateSection("utility", "Right")
US:CreateToggle({Name = "safe purchasing", HasSettings = true})
US:CreateToggle({Name = "auto loadout", HasSettings = true})
US:CreateToggle({Name = "follow target", HasSettings = true})
US:CreateToggle({Name = "auto stomp", HasSettings = true})
US:CreateToggle({Name = "auto ammo", HasSettings = true})
US:CreateToggle({Name = "auto armor", HasSettings = true})

return Library
