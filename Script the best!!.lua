local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Overlord Hub | Version: " .. Fluent.Version,
    SubTitle = "by overlord66-6",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "| Main", Icon = "scan-face" }),
    Settings = Window:AddTab({ Title = "| Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "This is a notification",
        SubContent = "SubContent", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })


    -- Input Element for Speed
local Input = Tabs.Main:AddInput("SpeedInput", {
    Title = "Speed",
    Default = "0",  -- Default speed value (0 means no speed adjustment)
    Placeholder = "Enter speed value",
    Numeric = true, -- Only allows numbers
    Finished = true, -- Only calls callback when you press enter
    Callback = function(Value)
        print("Input changed:", Value)
        
        -- Check if the input is a valid number
        local speed = tonumber(Value)
        
        -- If valid speed and toggle is on, set speed
        if speed and speed > 0 then
            -- Enable the toggle and set the speed
            Toggle:SetValue(true)
            print("Speed set to:", speed)
        else
            -- Disable the toggle when the input is 0 or invalid
            Toggle:SetValue(false)
            print("Speed is off or invalid input.")
        end
    end
})

-- Listen for input changes to update speed
Input:OnChanged(function()
    print("Input updated:", Input.Value)
    
    -- Re-check the input when it changes
    local speed = tonumber(Input.Value)
    
    -- Enable or disable the toggle based on valid speed
    if speed and speed > 0 then
        Toggle:SetValue(true)  -- Turn on the toggle if the speed is valid
    else
        Toggle:SetValue(false) -- Turn off the toggle if the speed is zero or invalid
    end
end)

-- Toggle Element to turn speed on or off
local Toggle = Tabs.Main:AddToggle("SpeedToggle", {Title = "Enable Speed", Default = false })

-- Listen for toggle changes and adjust speed functionality
Toggle:OnChanged(function()
    if Toggle.Value then
        print("Speed is enabled.")
        -- Here, you would set the character's speed or any other speed-related functionality.
    else
        print("Speed is disabled.")
        -- You would reset the speed to 0 or stop any movement logic.
    end
end)

-- Optionally, you can set the default value of the toggle or speed at start
Options.SpeedToggle:SetValue(false)
    
-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
