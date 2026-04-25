-- > ( Clean Drawing API UI Library )
-- > No Key System, No Exploit Logic, Pure UI.

repeat task.wait() until game:IsLoaded()

local user_input_service = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera

-- > ( Signal Library for Events )
local signal = {}
signal.__index = signal
function signal.new() return setmetatable({callbacks = {}}, signal) end
function signal:Fire(...)
    for _, callback in ipairs(self.callbacks) do
        task.spawn(callback, ...)
    end
end
function signal:Connect(callback)
    table.insert(self.callbacks, callback)
end

-- > ( Menu Configuration & Colors )
local menu = {
    colors = {
        background = Color3.fromRGB(15, 15, 15),
        section = Color3.fromRGB(20, 20, 20),
        border = Color3.fromRGB(35, 35, 35),
        accent = Color3.fromRGB(154, 213, 222), -- Beğendiğin ana tema rengi
        inactive_text = Color3.fromRGB(120, 120, 120),
        active_text = Color3.fromRGB(255, 255, 255),
    },
    groups = {},
    initial_base_offset = 75,
    menu_open = true
}

local menu_position = UDim2.new(0, camera.ViewportSize.X/2 - 575/2, 0, camera.ViewportSize.Y/2 - 450*0.5)

-- > ( Drawing Proxy Wrapper )
-- Orijinal koddaki gibi çizimleri daha kolay yönetmek için proxy yapısı
local drawing_proxy = {}
drawing_proxy.__index = drawing_proxy

function drawing_proxy.new(class, properties)
    local object = Drawing.new(class)
    local proxy = setmetatable({
        object = object,
        position = UDim2.new(0, 0, 0, 0),
        children = {},
        visible = false,
        destroy = function(self) self.object:Remove() end
    }, drawing_proxy)

    for prop, val in pairs(properties) do
        if prop == "Position" then
            proxy.position = val
            proxy.object.Position = Vector2.new(val.X.Offset, val.Y.Offset)
        elseif prop == "Size" and type(val) == "userdata" then
            proxy.object.Size = Vector2.new(val.X.Offset, val.Y.Offset)
        else
            proxy.object[prop] = val
        end
    end
    return proxy
end

-- > ( Main Background Frame )
local frame = drawing_proxy.new("Square", {
    Position = menu_position,
    Size = UDim2.new(0, 575, 0, 450),
    Color = menu.colors.background,
    Filled = true,
    Visible = true
})

local inside = drawing_proxy.new("Square", {
    Position = UDim2.new(0, menu_position.X.Offset + 1, 0, menu_position.Y.Offset + 1),
    Size = UDim2.new(0, 573, 0, 448),
    Color = menu.colors.section,
    Filled = true,
    Visible = true
})

local juju_text = drawing_proxy.new("Text", {
    Text = "Custom UI Lib",
    Size = 16,
    Position = UDim2.new(0, menu_position.X.Offset + 15, 0, menu_position.Y.Offset + 15),
    Color = menu.colors.active_text,
    Visible = true
})

-- > ( Group & Tab Logic )
local group = {}
group.__index = group

function menu.create_group(name)
    local new_group = setmetatable({
        name = name,
        tabs = {},
        is_visible = true,
    }, group)
    
    menu.groups[name] = new_group
    return new_group
end

function group:create_tab(name)
    local new_tab = {
        name = name,
        sections = {},
        group = self,
        text_obj = drawing_proxy.new("Text", {
            Text = name,
            Size = 14,
            Color = menu.colors.inactive_text,
            Visible = true,
            -- Basit konumlandırma (Gerçekte dinamik offset hesaplanır)
            Position = UDim2.new(0, menu_position.X.Offset + 15, 0, menu_position.Y.Offset + 75) 
        })
    }
    self.tabs[name] = new_tab
    return new_tab
end

local section = {}
section.__index = section

function group:create_section(tab_name, name)
    local tab = self.tabs[tab_name]
    if not tab then return end

    local new_section = setmetatable({
        name = name,
        elements = {},
        tab = tab
    }, section)

    tab.sections[name] = new_section
    return new_section
end

-- > ( Element Creation Template )
function section:create_element(info, properties)
    local element = {
        name = info.name,
        type = nil,
        value = nil,
        on_change = signal.new()
    }

    if properties.toggle then
        element.type = "toggle"
        element.value = properties.toggle.default or false
        
        -- Toggle Logic Here
        print("Created Toggle: " .. element.name)
        
    elseif properties.slider then
        element.type = "slider"
        element.value = properties.slider.default or properties.slider.min
        
        -- Slider Logic Here
        print("Created Slider: " .. element.name)
        
    elseif properties.dropdown then
        element.type = "dropdown"
        element.value = properties.dropdown.default
        
        -- Dropdown Logic Here
        print("Created Dropdown: " .. element.name)
    end

    table.insert(self.elements, element)
    return element
end

-- > ( Toggle Menu Visibility )
user_input_service.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        menu.menu_open = not menu.menu_open
        frame.object.Visible = menu.menu_open
        inside.object.Visible = menu.menu_open
        juju_text.object.Visible = menu.menu_open
        -- Loop through and toggle visibility of other items...
    end
end)

-- > ( Example Usage )
local main_group = menu.create_group("Main")
local combat_tab = main_group:create_tab("Combat")
local aim_section = main_group:create_section("Combat", "Aiming")

local aimbot_toggle = aim_section:create_element(
    {name = "Enable Aimbot"}, 
    {toggle = {default = false, flag = "aimbot_enabled"}}
)

aimbot_toggle.on_change:Connect(function(state)
    print("Aimbot state changed to: ", state)
end)
