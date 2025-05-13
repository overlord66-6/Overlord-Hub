local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
 
local Window = Library:CreateWindow{
    Title = `Overlord Hub | Game: Brookhaven | Version {Library.Version}`,
    SubTitle = "by overlord66-6",
    TabWidth = 160,
    Size = UDim2.fromOffset(830, 525),
    Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
    MinSize = Vector2.new(470, 380),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
}

-- Fluent Renewed provides ALL 1544 Lucide 0.469.0 https://lucide.dev/icons/ Icons and ALL 9072 Phosphor 2.1.0 https://phosphoricons.com/ Icons for the tabs, icons are optional
local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "scan-face"
    },
        Troll = Window:CreateTab{
        Title = "Troll",
        Icon = "drama"
    },
        Fun = Window:CreateTab{
        Title = "Fun",
        Icon = "ferris-wheel"
    },
        Misc = Window:CreateTab{
        Title = "Miscellaneous",
        Icon = "group"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}

local Options = Library.Options

Library:Notify{
    Title = "Notification",
    Content = "This is a notification",
    SubContent = "SubContent", -- Optional
    Duration = 5 -- Set to nil to make the notification not disappear
}

Tabs.Main:CreateParagraph("Aligned Paragraph", {
    Title = "---DISCORD SERVER---",
    Content = "",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

Tabs.Main:AddButton({
    Title = "Copy Discord Invite",
    Description = "Click to copy our Discord invite link",
    Callback = function()
        -- Copy to clipboard
        setclipboard("https://discord.gg/KsVAvNDV")

        -- Show dialog confirmation
        Window:Dialog({
            Title = "Copied!",
            Content = "Discord invite has been copied to your clipboard.",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function()
                        print("User acknowledged copy.")
                    end
                }
            }
        })
    end
})

Tabs.Main:CreateParagraph("Aligned Paragraph", {
    Title = "---LOCAL PLAYER CONFIGURATION---",
    Content = "	",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

local speed = 16 -- Default speed

-- Input first
local Input = Tabs.Main:AddInput("Input", {
    Title = "Speed Input",
    Default = tostring(speed),
    Placeholder = "Enter Speed",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            speed = num
            print("Speed set to:", speed)

            -- If toggle is on, apply new speed
            if Options.MyToggle.Value then
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
                end
            end
        end
    end
})

-- Then toggle
local Toggle = Tabs.Main:AddToggle("MyToggle", {
    Title = "Enable Speed",
    Default = false
})

Toggle:OnChanged(function()
    print("Toggle changed:", Options.MyToggle.Value)

    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        if Options.MyToggle.Value then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
        else
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 -- Default Roblox WalkSpeed
        end
    end
end)

Options.MyToggle:SetValue(false)

-- Infinite Jump Toggle
local ToggleInfiniteJump = Tabs.Main:AddToggle("Toggle_InfiniteJump", {Title = "Infinite Jump", Default = false})
ToggleInfiniteJump:OnChanged(function()
    if Options.Toggle_InfiniteJump.Value then
        local UserInputService = game:GetService("UserInputService")
        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")

        -- Connection to jump input
        _G.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if Options.Toggle_InfiniteJump.Value then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        print("Infinite Jump enabled")
    else
        if _G.InfiniteJumpConnection then
            _G.InfiniteJumpConnection:Disconnect()
            _G.InfiniteJumpConnection = nil
        end
        print("Infinite Jump disabled")
    end
end)

-- No Clip Toggle
local ToggleNoClip = Tabs.Main:AddToggle("Toggle_NoClip", {Title = "No Clip", Default = false})
ToggleNoClip:OnChanged(function()
    local RunService = game:GetService("RunService")
    local Player = game.Players.LocalPlayer

    if Options.Toggle_NoClip.Value then
        _G.NoclipConnection = RunService.Stepped:Connect(function()
            local Character = Player.Character
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        print("No Clip enabled")
    else
        if _G.NoclipConnection then
            _G.NoclipConnection:Disconnect()
            _G.NoclipConnection = nil
        end
        print("No Clip disabled")
    end
end)


-- Toggle logic
Toggle_Fly:OnChanged(function(state)
    if state then
        startFlying()
    else
        stopFlying()
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local bodyGyro
local bodyVelocity
local flyConnection

-- Add toggle to Fluent UI
local Toggle_Fly = Tabs.Fun:AddToggle("FlyToggle", {
    Title = "Fly (BETA)",
    Default = false,
    Callback = function(state)
        if state then
            -- Start flying
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.P = 9e4
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            bodyGyro.Parent = rootPart

            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 50, 0) -- upward motion
            bodyVelocity.Parent = rootPart

            flyConnection = RunService.RenderStepped:Connect(function()
                if bodyGyro then
                    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                end
            end)
        else
            -- Stop flying
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        end
    end
})

-- Make sure it starts OFF
Toggle_Fly:Set(false)
-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes{}

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Library:Notify{
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
}

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
