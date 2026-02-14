-- Neverlose-style UI Library (FIXED)

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeverloseUILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 720, 0, 420)
    Main.Position = UDim2.new(0.5, -360, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(12,12,15)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)

    -- Drag
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = title or "Window"
    Title.Size = UDim2.new(1,-20,0,40)
    Title.Position = UDim2.new(0,10,0,5)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.Parent = Main

    -- Sidebar
    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(0,150,1,-50)
    Tabs.Position = UDim2.new(0,0,0,50)
    Tabs.BackgroundColor3 = Color3.fromRGB(8,8,10)
    Tabs.Parent = Main

    local TabLayout = Instance.new("UIListLayout", Tabs)
    TabLayout.Padding = UDim.new(0,8)

    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,-160,1,-60)
    Content.Position = UDim2.new(0,155,0,55)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Window = {}
    Window.Tabs = {}

    function Window:CreateTab(name)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1,-10,0,38)
        Btn.BackgroundColor3 = Color3.fromRGB(18,18,22)
        Btn.Text = name
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 14
        Btn.Parent = Tabs
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,0,1,0)
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.Parent = Content

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0,12)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
        end)

        Btn.MouseButton1Click:Connect(function()
            for _,t in pairs(Window.Tabs) do
                t.Page.Visible = false
            end
            Page.Visible = true
        end)

        local Tab = {}
        Tab.Page = Page

        -- TOGGLE
        function Tab:AddToggle(text, callback)
            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(1,-10,0,32)
            Toggle.BackgroundColor3 = Color3.fromRGB(18,18,22)
            Toggle.Text = ""
            Toggle.Parent = Page
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,6)

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1,-50,1,0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.new(1,1,1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Toggle

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0,20,0,20)
            Box.Position = UDim2.new(1,-28,0.5,-10)
            Box.BackgroundColor3 = Color3.fromRGB(35,35,40)
            Box.Parent = Toggle
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4)

            local state = false
            Toggle.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Box,TweenInfo.new(0.15),{
                    BackgroundColor3 = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(35,35,40)
                }):Play()
                if callback then callback(state) end
            end)
        end

        -- SLIDER ✅ (THIS WAS MISSING)
        function Tab:AddSlider(text,min,max,default,callback)
            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1,-10,0,45)
            Holder.BackgroundTransparency = 1
            Holder.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Text = text.." : "..default
            Label.Size = UDim2.new(1,0,0,18)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.new(1,1,1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Holder

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1,0,0,6)
            Bar.Position = UDim2.new(0,0,0,30)
            Bar.BackgroundColor3 = Color3.fromRGB(35,35,40)
            Bar.Parent = Holder
            Instance.new("UICorner", Bar)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
            Fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
            Fill.Parent = Bar
            Instance.new("UICorner", Fill)

            local dragging = false
            Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UIS.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
                    Fill.Size = UDim2.new(pct,0,1,0)
                    local val = math.floor(min + (max-min)*pct)
                    Label.Text = text.." : "..val
                    if callback then callback(val) end
                end
            end)
        end

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Page.Visible = true end
        return Tab
    end

    return Window
end

return Library
