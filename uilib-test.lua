--[[
    Premium Drawing API UI Library
    Inspired by "juju" aesthetic.
    Features: Proxy Drawing, Tweening, Signal Events, Full Element Suite.
]]

repeat task.wait() until game:IsLoaded()

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

-- > ( Signal Library )
local Signal = {}
Signal.__index = Signal
function Signal.new()
    return setmetatable({ _callbacks = {} }, Signal)
end
function Signal:Connect(callback)
    local connection = {
        _callback = callback,
        Disconnect = function(self)
            for i, v in ipairs(self.signal._callbacks) do
                if v == self._callback then
                    table.remove(self.signal._callbacks, i)
                    break
                end
            end
        end,
        signal = self
    }
    table.insert(self._callbacks, callback)
    return connection
end
function Signal:Fire(...)
    for _, callback in ipairs(self._callbacks) do
        task.spawn(callback, ...)
    end
end

-- > ( Tween Library for Drawing API )
local CustomTween = {}
local ActiveTweens = {}
local EasingStyles = {
    Linear = function(t) return t end,
    Quad = function(t) return t * t end,
    Exponential = function(t) return t == 1 and 1 or 1 - math.pow(2, -10 * t) end,
    Circular = function(t) return math.sqrt(1 - math.pow(t - 1, 2)) end
}

function CustomTween.Tween(object, properties, style, duration)
    local start_time = os.clock()
    local initial_values = {}
    local tween_funcs = {}

    for prop, val in pairs(properties) do
        initial_values[prop] = object[prop]
        if typeof(val) == "Color3" then
            tween_funcs[prop] = function(t)
                object[prop] = initial_values[prop]:Lerp(val, t)
            end
        elseif typeof(val) == "Vector2" then
            tween_funcs[prop] = function(t)
                object[prop] = initial_values[prop]:Lerp(val, t)
            end
        elseif typeof(val) == "number" then
            tween_funcs[prop] = function(t)
                object[prop] = initial_values[prop] + (val - initial_values[prop]) * t
            end
        end
    end

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = os.clock() - start_time
        local progress = math.clamp(elapsed / duration, 0, 1)
        local eased = EasingStyles[style](progress)

        for prop, func in pairs(tween_funcs) do
            func(eased)
        end

        if progress >= 1 then
            connection:Disconnect()
            for prop, val in pairs(properties) do
                object[prop] = val -- Ensure final value is exact
            end
        end
    end)
end

-- > ( Base64 Assets - Recreated for structural integrity )
local Assets = {
    Pixel = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMvu8A7YAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAA8nYBAOgDAADydgEA6AMAAFBhaW50Lk5FVCA1LjEuMgADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAACOO8FX0xe8TgAAAAxJREFUGFdj+P//PwAF/gL+pzWBhAAAAABJRU5ErkJggg==",
    Gear = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAMAAAC67D+PAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf///wAAAFXC034AAAACdFJOU/8A5bcwSgAAAAlwSFlzAAAQKAAAECgBJz8A6wAAABh0RVh0U29mdHdhcmUAUGFpbnQuTkVUIDUuMS4y+7wDtgAAALZlWElmSUkqAAgAAAAFABoBBQABAAAASgAAABsBBQABAAAAUgAAACgBAwABAAAAAgAAADEBAgAQAAAAWgAAAGmHBAABAAAAagAAAAAAAAB3mgEA6AMAAHeaAQDoAwAAUGFpbnQuTkVUIDUuMS4yAAMAAJAHAAQAAAAwMjMwAaADAAEAAAABAAAABaAEAAEAAACUAAAAAAAAAAIAAQACAAQAAABSOTgAAgAHAAQAAAAwMTAwAAAAAEyPNqYn0aVIAAAALElEQVQYV2NgBAIGCAmioQhIQACQCZaGYBAJoZGYSApgUhATYAiikJGRkREACr4AMZ+SUSoAAAAASUVORK5CYII=",
}

local function DecodeBase64(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- > ( Drawing Proxy Wrapper )
local DrawingProxy = {}
DrawingProxy.__index = DrawingProxy

function DrawingProxy.new(class, properties)
    local proxy = setmetatable({
        Object = Drawing.new(class),
        Position = UDim2.new(0, 0, 0, 0),
        Size = class == "Text" and 12 or UDim2.new(0, 0, 0, 0),
        RealPosition = Vector2.new(0, 0),
        RealSize = class == "Text" and 12 or Vector2.new(0, 0),
        Children = {},
        Parent = nil,
        Visible = false,
        IsRendering = false,
    }, DrawingProxy)

    local zIndex = properties.ZIndex or 20
    properties.ZIndex = zIndex + 20

    for prop, val in pairs(properties) do
        proxy[prop] = val
    end

    return proxy
end

function DrawingProxy:UpdatePosition()
    if self.Parent then
        local parentPos = self.Parent.RealPosition
        local parentSize = self.Parent.RealSize
        self.RealPosition = Vector2.new(
            (parentPos.X + (type(parentSize) == "number" and 0 or parentSize.X) * self.Position.X.Scale) + self.Position.X.Offset,
            (parentPos.Y + (type(parentSize) == "number" and 0 or parentSize.Y) * self.Position.Y.Scale) + self.Position.Y.Offset
        )
    else
        self.RealPosition = Vector2.new(self.Position.X.Offset, self.Position.Y.Offset)
    end
    self.Object.Position = self.RealPosition

    for _, child in ipairs(self.Children) do
        child:UpdatePosition()
    end
end

function DrawingProxy:UpdateSize()
    if typeof(self.Size) == "number" then
        self.RealSize = self.Size
        self.Object.Size = self.RealSize
        return
    end

    if self.Parent then
        local parentSize = self.Parent.RealSize
        self.RealSize = Vector2.new(
            (type(parentSize) == "number" and 0 or parentSize.X) * self.Size.X.Scale + self.Size.X.Offset,
            (type(parentSize) == "number" and 0 or parentSize.Y) * self.Size.Y.Scale + self.Size.Y.Offset
        )
    else
        self.RealSize = Vector2.new(self.Size.X.Offset, self.Size.Y.Offset)
    end
    self.Object.Size = self.RealSize

    for _, child in ipairs(self.Children) do
        child:UpdateSize()
        child:UpdatePosition()
    end
end

function DrawingProxy:UpdateVisibility()
    if self.Parent and not self.Parent.IsRendering then
        self.IsRendering = false
        self.Object.Visible = false
    else
        self.Object.Visible = self.Visible
        self.IsRendering = self.Visible
    end

    for _, child in ipairs(self.Children) do
        child:UpdateVisibility()
    end
end

function DrawingProxy:__newindex(prop, val)
    if prop == "Position" then
        rawset(self, "Position", val)
        self:UpdatePosition()
    elseif prop == "Size" then
        rawset(self, "Size", val)
        self:UpdateSize()
    elseif prop == "Parent" then
        rawset(self, "Parent", val)
        if val then table.insert(val.Children, self) end
        self:UpdatePosition()
        self:UpdateSize()
        self:UpdateVisibility()
    elseif prop == "Visible" then
        rawset(self, "Visible", val)
        self:UpdateVisibility()
    else
        self.Object[prop] = val
    end
end

function DrawingProxy:__index(prop)
    if DrawingProxy[prop] then
        return DrawingProxy[prop]
    end
    return self.Object[prop]
end

function DrawingProxy:Destroy()
    for _, child in ipairs(self.Children) do
        child:Destroy()
    end
    self.Object:Remove()
    self.Object = nil
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
        Highlight = Color3.fromRGB(40, 45, 50)
    },
    Windows = {},
    Flags = {},
    InputBegan = Signal.new(),
    InputEnded = Signal.new(),
    MouseMoved = Signal.new()
}

-- Input Handling
local IsDragging = false
local DragOffset = Vector2.new(0, 0)
local HoveredElements = {}
local ActiveWindow = nil

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe then
        Library.InputBegan:Fire(input)
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if not gpe then
        Library.InputEnded:Fire(input)
    end
end)

UserInputService.InputChanged:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        Library.MouseMoved:Fire(input.Position)
    end
end)

-- > ( Library Functions )

function Library:CreateWindow(options)
    local Window = {
        Name = options.Name or "juju private",
        Size = options.Size or UDim2.new(0, 600, 0, 450),
        Groups = {},
        ActiveTab = nil,
        IsOpen = true
    }

    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local StartPos = UDim2.new(0, ScreenCenter.X - 300, 0, ScreenCenter.Y - 225)

    -- Main Frame
    Window.MainFrame = DrawingProxy.new("Image", {
        Position = StartPos,
        Size = Window.Size,
        Color = self.Colors.Background,
        Data = DecodeBase64(Assets.Pixel),
        Visible = true,
        Transparency = 1,
        Rounding = 4
    })

    -- Inner Frame (Sidebar + Content area)
    Window.InnerFrame = DrawingProxy.new("Image", {
        Parent = Window.MainFrame,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        Color = self.Colors.Section,
        Data = DecodeBase64(Assets.Pixel),
        Visible = true,
        Transparency = 1,
        Rounding = 4
    })

    -- Logo & Name
    Window.LogoText = DrawingProxy.new("Text", {
        Parent = Window.InnerFrame,
        Position = UDim2.new(0, 20, 0, 20),
        Text = string.split(Window.Name, " ")[1] or "juju",
        Color = self.Colors.Text,
        Size = 16,
        Font = 1,
        Visible = true
    })
    
    Window.VersionText = DrawingProxy.new("Text", {
        Parent = Window.InnerFrame,
        Position = UDim2.new(0, 20, 0, 36),
        Text = string.split(Window.Name, " ")[2] or "private",
        Color = self.Colors.Accent,
        Size = 14,
        Font = 1,
        Visible = true
    })

    -- Sidebar Divider
    Window.SidebarDivider = DrawingProxy.new("Square", {
        Parent = Window.InnerFrame,
        Position = UDim2.new(0, 120, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Color = self.Colors.Border,
        Filled = true,
        Visible = true
    })

    -- Content Area
    Window.ContentArea = DrawingProxy.new("Square", {
        Parent = Window.InnerFrame,
        Position = UDim2.new(0, 121, 0, 0),
        Size = UDim2.new(1, -121, 1, 0),
        Color = self.Colors.Background,
        Filled = true,
        Visible = true
    })

    -- Active Tab Line (The blue line on the left of tabs)
    Window.TabLine = DrawingProxy.new("Square", {
        Parent = Window.InnerFrame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 2, 0, 14),
        Color = self.Colors.Accent,
        Filled = true,
        Visible = false
    })

    -- Dragging Logic
    Library.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Window.IsOpen then
            local pos = UserInputService:GetMouseLocation()
            local framePos = Window.MainFrame.RealPosition
            local frameSize = Window.MainFrame.RealSize

            -- Drag via top area or empty space
            if pos.X >= framePos.X and pos.X <= framePos.X + frameSize.X and pos.Y >= framePos.Y and pos.Y <= framePos.Y + 30 then
                IsDragging = true
                DragOffset = Vector2.new(pos.X - framePos.X, pos.Y - framePos.Y)
            end
        end
    end)

    Library.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsDragging = false
        end
    end)

    Library.MouseMoved:Connect(function(pos)
        if IsDragging then
            Window.MainFrame.Position = UDim2.new(0, pos.X - DragOffset.X, 0, pos.Y - DragOffset.Y)
        end
    end)

    local currentGroupY = 75

    function Window:CreateGroup(name)
        local Group = {
            Name = name,
            Tabs = {},
            Label = DrawingProxy.new("Text", {
                Parent = self.InnerFrame,
                Position = UDim2.new(0, 15, 0, currentGroupY),
                Text = name,
                Color = Library.Colors.Accent,
                Size = 13,
                Font = 1,
                Visible = true
            }),
            Divider = DrawingProxy.new("Square", {
                Parent = self.InnerFrame,
                Position = UDim2.new(0, 15, 0, currentGroupY + 16),
                Size = UDim2.new(0, 90, 0, 1),
                Color = Library.Colors.Accent,
                Filled = true,
                Transparency = 0.3,
                Visible = true
            })
        }
        currentGroupY = currentGroupY + 25

        function Group:CreateTab(tabName)
            local Tab = {
                Name = tabName,
                Sections = {},
                Container = DrawingProxy.new("Square", {
                    Parent = Window.ContentArea,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 1, -20),
                    Transparency = 0, -- Invisible container
                    Visible = false
                }),
                Button = DrawingProxy.new("Text", {
                    Parent = Window.InnerFrame,
                    Position = UDim2.new(0, 15, 0, currentGroupY),
                    Text = tabName,
                    Color = Library.Colors.DarkText,
                    Size = 13,
                    Font = 1,
                    Visible = true
                }),
                Hitbox = DrawingProxy.new("Square", {
                    Parent = Window.InnerFrame,
                    Position = UDim2.new(0, 10, 0, currentGroupY),
                    Size = UDim2.new(0, 100, 0, 15),
                    Transparency = 0,
                    Visible = true
                })
            }
            currentGroupY = currentGroupY + 18

            -- Tab Switching Logic
            Library.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and Window.IsOpen then
                    local pos = UserInputService:GetMouseLocation()
                    local hp = Tab.Hitbox.RealPosition
                    local hs = Tab.Hitbox.RealSize
                    
                    if pos.X >= hp.X and pos.X <= hp.X + hs.X and pos.Y >= hp.Y and pos.Y <= hp.Y + hs.Y then
                        -- Hide old tab
                        if Window.ActiveTab then
                            Window.ActiveTab.Container.Visible = false
                            Window.ActiveTab.Button.Color = Library.Colors.DarkText
                            CustomTween.Tween(Window.ActiveTab.Button, {Position = UDim2.new(0, 15, 0, Window.ActiveTab.Button.Position.Y.Offset)}, "Exponential", 0.2)
                        end
                        
                        -- Show new tab
                        Window.ActiveTab = Tab
                        Tab.Container.Visible = true
                        Tab.Button.Color = Library.Colors.Text
                        
                        -- Animate active text and blue line
                        CustomTween.Tween(Tab.Button, {Position = UDim2.new(0, 20, 0, Tab.Button.Position.Y.Offset)}, "Exponential", 0.2)
                        Window.TabLine.Visible = true
                        CustomTween.Tween(Window.TabLine, {Position = UDim2.new(0, 12, 0, Tab.Button.Position.Y.Offset + 1)}, "Exponential", 0.2)
                    end
                end
            end)

            function Tab:CreateSection(sectionName, side)
                side = side or "Left"
                local xOffset = side == "Left" and 0 or 0.5
                local xPixels = side == "Left" and 0 or 5

                local Section = {
                    Name = sectionName,
                    Elements = {},
                    CurrentY = 15,
                    Border = DrawingProxy.new("Image", {
                        Parent = self.Container,
                        Position = UDim2.new(xOffset, xPixels, 0, 0),
                        Size = UDim2.new(0.5, -5, 1, 0), -- Automatically scales height later
                        Color = Library.Colors.Border,
                        Data = DecodeBase64(Assets.Pixel),
                        Visible = true,
                        Transparency = 1,
                        Rounding = 4
                    })
                }

                Section.Inside = DrawingProxy.new("Image", {
                    Parent = Section.Border,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    Color = Library.Colors.Section,
                    Data = DecodeBase64(Assets.Pixel),
                    Visible = true,
                    Transparency = 1,
                    Rounding = 4
                })

                -- Section Title Line
                Section.TitleText = DrawingProxy.new("Text", {
                    Parent = Section.Inside,
                    Position = UDim2.new(0, 15, 0, -7),
                    Text = sectionName,
                    Color = Library.Colors.Accent,
                    Size = 13,
                    Font = 1,
                    Visible = true
                })

                local textWidth = Section.TitleText.Object.TextBounds.X

                Section.Line1 = DrawingProxy.new("Square", {
                    Parent = Section.Inside,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0, 8, 0, 1),
                    Color = Library.Colors.Border,
                    Filled = true,
                    Visible = true
                })

                Section.Line2 = DrawingProxy.new("Square", {
                    Parent = Section.Inside,
                    Position = UDim2.new(0, 15 + textWidth + 2, 0, 0),
                    Size = UDim2.new(1, -(15 + textWidth + 7), 0, 1),
                    Color = Library.Colors.Border,
                    Filled = true,
                    Visible = true
                })

                function Section:UpdateHeight()
                    self.Border.Size = UDim2.new(0.5, -5, 0, self.CurrentY + 5)
                end

                -- > Elements inside section

                function Section:CreateToggle(options)
                    local Toggle = {
                        Name = options.Name,
                        Flag = options.Flag or options.Name,
                        State = options.Default or false,
                        Callback = options.Callback or function() end
                    }
                    Library.Flags[Toggle.Flag] = Toggle.State

                    local ToggleBox = DrawingProxy.new("Image", {
                        Parent = self.Inside,
                        Position = UDim2.new(0, 10, 0, self.CurrentY),
                        Size = UDim2.new(0, 12, 0, 12),
                        Color = Library.Colors.Border,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 4,
                        Visible = true,
                        Transparency = 1
                    })

                    local ToggleInner = DrawingProxy.new("Image", {
                        Parent = ToggleBox,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2),
                        Color = Toggle.State and Library.Colors.Accent or Library.Colors.Background,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 3,
                        Visible = true,
                        Transparency = 1
                    })

                    local ToggleText = DrawingProxy.new("Text", {
                        Parent = self.Inside,
                        Position = UDim2.new(0, 28, 0, self.CurrentY - 1),
                        Text = Toggle.Name,
                        Color = Toggle.State and Library.Colors.Text or Library.Colors.DarkText,
                        Size = 13,
                        Font = 1,
                        Visible = true
                    })

                    -- Optional Gear Icon
                    if options.HasSettings then
                        local GearIcon = DrawingProxy.new("Image", {
                            Parent = self.Inside,
                            Position = UDim2.new(1, -20, 0, self.CurrentY + 1),
                            Size = UDim2.new(0, 10, 0, 10),
                            Color = Library.Colors.DarkText,
                            Data = DecodeBase64(Assets.Gear),
                            Visible = true,
                            Transparency = 1
                        })
                    end

                    local Hitbox = DrawingProxy.new("Square", {
                        Parent = self.Inside,
                        Position = UDim2.new(0, 10, 0, self.CurrentY),
                        Size = UDim2.new(1, -20, 0, 14),
                        Transparency = 0,
                        Visible = true
                    })

                    Library.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and Window.IsOpen and Tab.Container.Visible then
                            local pos = UserInputService:GetMouseLocation()
                            local hp = Hitbox.RealPosition
                            local hs = Hitbox.RealSize
                            if pos.X >= hp.X and pos.X <= hp.X + hs.X and pos.Y >= hp.Y and pos.Y <= hp.Y + hs.Y then
                                Toggle.State = not Toggle.State
                                Library.Flags[Toggle.Flag] = Toggle.State
                                
                                CustomTween.Tween(ToggleInner, {Color = Toggle.State and Library.Colors.Accent or Library.Colors.Background}, "Circular", 0.15)
                                CustomTween.Tween(ToggleText, {Color = Toggle.State and Library.Colors.Text or Library.Colors.DarkText}, "Circular", 0.15)
                                
                                Toggle.Callback(Toggle.State)
                            end
                        end
                    end)

                    self.CurrentY = self.CurrentY + 20
                    self:UpdateHeight()
                    return Toggle
                end

                function Section:CreateSlider(options)
                    local Slider = {
                        Name = options.Name,
                        Flag = options.Flag or options.Name,
                        Min = options.Min or 0,
                        Max = options.Max or 100,
                        Value = options.Default or 50,
                        Suffix = options.Suffix or "",
                        Callback = options.Callback or function() end
                    }
                    Library.Flags[Slider.Flag] = Slider.Value

                    local TitleText = DrawingProxy.new("Text", {
                        Parent = self.Inside,
                        Position = UDim2.new(0, 10, 0, self.CurrentY),
                        Text = Slider.Name .. " | " .. tostring(Slider.Value) .. Slider.Suffix,
                        Color = Library.Colors.Text,
                        Size = 13,
                        Font = 1,
                        Visible = true
                    })

                    local SliderBg = DrawingProxy.new("Image", {
                        Parent = self.Inside,
                        Position = UDim2.new(0, 10, 0, self.CurrentY + 16),
                        Size = UDim2.new(1, -20, 0, 6),
                        Color = Library.Colors.Background,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 3,
                        Visible = true,
                        Transparency = 1
                    })

                    local SliderFill = DrawingProxy.new("Image", {
                        Parent = SliderBg,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(math.clamp((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1), 0, 1, 0),
                        Color = Library.Colors.Accent,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 3,
                        Visible = true,
                        Transparency = 1
                    })

                    local Sliding = false

                    local function UpdateSlider(input)
                        local pos = UserInputService:GetMouseLocation()
                        local relX = math.clamp(pos.X - SliderBg.RealPosition.X, 0, SliderBg.RealSize.X)
                        local percentage = relX / SliderBg.RealSize.X
                        Slider.Value = math.floor(Slider.Min + (Slider.Max - Slider.Min) * percentage)
                        Library.Flags[Slider.Flag] = Slider.Value

                        TitleText.Text = Slider.Name .. " | " .. tostring(Slider.Value) .. Slider.Suffix
                        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                        
                        Slider.Callback(Slider.Value)
                    end

                    Library.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and Window.IsOpen and Tab.Container.Visible then
                            local pos = UserInputService:GetMouseLocation()
                            local hp = SliderBg.RealPosition
                            local hs = SliderBg.RealSize
                            if pos.X >= hp.X and pos.X <= hp.X + hs.X and pos.Y >= hp.Y - 5 and pos.Y <= hp.Y + hs.Y + 5 then
                                Sliding = true
                                UpdateSlider(input)
                            end
                        end
                    end)

                    Library.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            Sliding = false
                        end
                    end)

                    Library.MouseMoved:Connect(function(pos)
                        if Sliding then
                            UpdateSlider()
                        end
                    end)

                    self.CurrentY = self.CurrentY + 30
                    self:UpdateHeight()
                    return Slider
                end

                function Section:CreateDropdown(options)
                    local Dropdown = {
                        Name = options.Name,
                        Options = options.Options or {},
                        Value = options.Default or options.Options[1] or "",
                        Flag = options.Flag or options.Name,
                        Callback = options.Callback or function() end,
                        IsOpen = false
                    }
                    Library.Flags[Dropdown.Flag] = Dropdown.Value

                    local TitleText = DrawingProxy.new("Text", {
                        Parent = self.Inside,
                        Position = UDim2.new(0, 10, 0, self.CurrentY),
                        Text = Dropdown.Name,
                        Color = Library.Colors.DarkText,
                        Size = 13,
                        Font = 1,
                        Visible = true
                    })

                    local DropBox = DrawingProxy.new("Image", {
                        Parent = self.Inside,
                        Position = UDim2.new(0, 10, 0, self.CurrentY + 16),
                        Size = UDim2.new(1, -20, 0, 18),
                        Color = Library.Colors.Border,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 3,
                        Visible = true,
                        Transparency = 1
                    })

                    local DropInner = DrawingProxy.new("Image", {
                        Parent = DropBox,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2),
                        Color = Library.Colors.Background,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 2,
                        Visible = true,
                        Transparency = 1
                    })

                    local ValueText = DrawingProxy.new("Text", {
                        Parent = DropInner,
                        Position = UDim2.new(0, 5, 0, 2),
                        Text = Dropdown.Value,
                        Color = Library.Colors.Text,
                        Size = 13,
                        Font = 1,
                        Visible = true
                    })

                    -- The dropdown list container (hidden by default)
                    local ListBox = DrawingProxy.new("Image", {
                        Parent = DropBox,
                        Position = UDim2.new(0, 0, 1, 2),
                        Size = UDim2.new(1, 0, 0, #Dropdown.Options * 16 + 4),
                        Color = Library.Colors.Border,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 3,
                        Visible = false,
                        Transparency = 1,
                        ZIndex = 100
                    })

                    local ListInner = DrawingProxy.new("Image", {
                        Parent = ListBox,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2),
                        Color = Library.Colors.Background,
                        Data = DecodeBase64(Assets.Pixel),
                        Rounding = 2,
                        Visible = true,
                        Transparency = 1,
                        ZIndex = 101
                    })

                    local OptionDrawings = {}

                    local function PopulateList()
                        for _, obj in ipairs(OptionDrawings) do
                            obj.Text:Destroy()
                            obj.Hitbox:Destroy()
                        end
                        OptionDrawings = {}

                        for i, opt in ipairs(Dropdown.Options) do
                            local optText = DrawingProxy.new("Text", {
                                Parent = ListInner,
                                Position = UDim2.new(0, 5, 0, 2 + (i - 1) * 16),
                                Text = opt,
                                Color = opt == Dropdown.Value and Library.Colors.Accent or Library.Colors.DarkText,
                                Size = 13,
                                Font = 1,
                                Visible = true,
                                ZIndex = 102
                            })

                            local optHitbox = DrawingProxy.new("Square", {
                                Parent = ListInner,
                                Position = UDim2.new(0, 0, 0, (i - 1) * 16),
                                Size = UDim2.new(1, 0, 0, 16),
                                Transparency = 0,
                                Visible = true,
                                ZIndex = 103
                            })

                            table.insert(OptionDrawings, {Text = optText, Hitbox = optHitbox, Value = opt})
                        end
                        ListBox.Size = UDim2.new(1, 0, 0, #Dropdown.Options * 16 + 4)
                    end

                    PopulateList()

                    Library.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and Window.IsOpen and Tab.Container.Visible then
                            local pos = UserInputService:GetMouseLocation()
                            
                            if Dropdown.IsOpen then
                                -- Check clicks on options
                                local clickedOption = false
                                for _, opt in ipairs(OptionDrawings) do
                                    local hp = opt.Hitbox.RealPosition
                                    local hs = opt.Hitbox.RealSize
                                    if pos.X >= hp.X and pos.X <= hp.X + hs.X and pos.Y >= hp.Y and pos.Y <= hp.Y + hs.Y then
                                        Dropdown.Value = opt.Value
                                        Library.Flags[Dropdown.Flag] = Dropdown.Value
                                        ValueText.Text = Dropdown.Value
                                        Dropdown.Callback(Dropdown.Value)
                                        clickedOption = true
                                        break
                                    end
                                end
                                
                                Dropdown.IsOpen = false
                                ListBox.Visible = false
                                if clickedOption then PopulateList() end
                                return
                            end

                            local hp = DropBox.RealPosition
                            local hs = DropBox.RealSize
                            if pos.X >= hp.X and pos.X <= hp.X + hs.X and pos.Y >= hp.Y and pos.Y <= hp.Y + hs.Y then
                                Dropdown.IsOpen = true
                                PopulateList()
                                ListBox.Visible = true
                            end
                        end
                    end)

                    self.CurrentY = self.CurrentY + 40
                    self:UpdateHeight()
                    return Dropdown
                end

                return Section
            end

            table.insert(self.Tabs, Tab)
            return Tab
        end

        table.insert(Window.Groups, Group)
        return Group
    end

    -- Return the built window object
    return Window
end

-- > ( Build the Specific UI from Screenshot )
local MyWindow = Library:CreateWindow({Name = "juju private"})

-- Groups
local MainGroup = MyWindow:CreateGroup("main")
local VisualsGroup = MyWindow:CreateGroup("visuals")
local MiscGroup = MyWindow:CreateGroup("misc.")

-- Tabs
local RagebotTab = MainGroup:CreateTab("ragebot")
MainGroup:CreateTab("legitbot")

VisualsGroup:CreateTab("players")
VisualsGroup:CreateTab("general")
VisualsGroup:CreateTab("skins")

MiscGroup:CreateTab("players")
MiscGroup:CreateTab("configs")
MiscGroup:CreateTab("addons")
MiscGroup:CreateTab("shop")
MiscGroup:CreateTab("main")

-- Sections in Ragebot (Matching image)
local GeneralSec = RagebotTab:CreateSection("general", "Left")
GeneralSec:CreateToggle({Name = "ragebot", Flag = "RagebotEnabled"})
GeneralSec:CreateToggle({Name = "auto fire", Flag = "AutoFire", HasSettings = true})
GeneralSec:CreateToggle({Name = "auto equip", Flag = "AutoEquip", HasSettings = true})
GeneralSec:CreateToggle({Name = "spam resolver", Flag = "SpamResolver", HasSettings = true})
GeneralSec:CreateDropdown({Name = "target hitbox", Options = {"head", "torso", "legs"}, Default = "head"})
GeneralSec:CreateSlider({Name = "prediction | auto", Min = 0, Max = 100, Default = 15, Suffix = "ms"})
GeneralSec:CreateSlider({Name = "shot delay | none", Min = 0, Max = 500, Default = 0, Suffix = "ms"})
GeneralSec:CreateSlider({Name = "field of view | full", Min = 0, Max = 360, Default = 360})
GeneralSec:CreateSlider({Name = "fire cooldown", Min = 0, Max = 50, Default = 5, Suffix = "ms"})
GeneralSec:CreateToggle({Name = "target selection", HasSettings = true})

local VisSec = RagebotTab:CreateSection("visualization", "Left")
VisSec:CreateToggle({Name = "crosshair follow"})
VisSec:CreateToggle({Name = "3d target circle", HasSettings = true})
VisSec:CreateToggle({Name = "view target", HasSettings = true})
VisSec:CreateToggle({Name = "face target"})
VisSec:CreateToggle({Name = "show fov", HasSettings = true})
VisSec:CreateToggle({Name = "tracer", HasSettings = true})

local AntiSec = RagebotTab:CreateSection("anti", "Right")
AntiSec:CreateToggle({Name = "sender rate value", HasSettings = true})
AntiSec:CreateToggle({Name = "network desync"})
AntiSec:CreateToggle({Name = "velocity desync", HasSettings = true})
AntiSec:CreateToggle({Name = "fake position", HasSettings = true})
AntiSec:CreateToggle({Name = "void hide", HasSettings = true})

local UtilitySec = RagebotTab:CreateSection("utility", "Right")
UtilitySec:CreateToggle({Name = "safe purchasing", HasSettings = true})
UtilitySec:CreateToggle({Name = "auto loadout", HasSettings = true})
UtilitySec:CreateToggle({Name = "follow target", HasSettings = true})
UtilitySec:CreateToggle({Name = "auto stomp", HasSettings = true})
UtilitySec:CreateToggle({Name = "auto ammo", HasSettings = true})
UtilitySec:CreateToggle({Name = "auto armor", HasSettings = true})
UtilitySec:CreateToggle({Name = "anti stomp", HasSettings = true})
UtilitySec:CreateToggle({Name = "auto mask", HasSettings = true})
UtilitySec:CreateToggle({Name = "auto heal", HasSettings = true})
UtilitySec:CreateToggle({Name = "anti taser"})
UtilitySec:CreateToggle({Name = "rapid fire"})

-- Initialize the first tab to be visible
if MainGroup.Tabs[1] then
    local firstTab = MainGroup.Tabs[1]
    MyWindow.ActiveTab = firstTab
    firstTab.Container.Visible = true
    firstTab.Button.Color = Library.Colors.Text
    MyWindow.TabLine.Visible = true
    MyWindow.TabLine.Position = UDim2.new(0, 12, 0, firstTab.Button.Position.Y.Offset + 1)
end

-- Toggle UI Binding (Insert Key by default)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        MyWindow.IsOpen = not MyWindow.IsOpen
        MyWindow.MainFrame.Visible = MyWindow.IsOpen
    end
end)
