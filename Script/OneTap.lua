--[[
    NEVERLOSE UI Script
    Warning: This script is for educational purposes. Use at your own risk.
]]
local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/SourceCludeLib/refs/heads/main/NerverLoseLibEdited.lua"))()

local Window = NEVERLOSE:AddWindow("NEVERLOSE", "CS:GO CHEAT", 'Fan Made')

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Config Variables
local aimOn = false
local smooth = 1
local aimFov = 90
local teamChk = false
local aimPart = "HumanoidRootPart"
local wallChk = false
local fovCircle = false
local fovSize = 100
local rainbowFov = false

local espOn = false
local espTeam = false
local espBox = false
local espName = false
local espHp = false
local rainbowEsp = false

local skellyEsp = false
local skellyTeam = false

local tracerOn = false
local tracerTeam = false
local rainbowTracer = false

local chamOn = false
local chamTeam = false
local rainbowCham = false

local speedOn = false
local speedVal = 20
local jumpOn = false
local jumpVal = 50
local infJump = false
local gravOn = false
local gravVal = 196.2
local noAir = false
local flyOn = false
local fly2On = false
local fly2Spd = 50
local invisOn = false
local spinOn = false
local spinSpd = 20
local noclipOn = false
local plrFov = 70
local autoShoot = false
local autoTeam = false

-- Object Tables
local espObjs = {}
local tracerObjs = {}
local chamObjs = {}
local skellyObjs = {}

-- FOV Drawing
local fovDraw = Drawing.new("Circle")
fovDraw.Visible = false
fovDraw.Thickness = 1
fovDraw.NumSides = 50
fovDraw.Filled = false

local bv, bg

-- Helper: Get Closest Target
local function getTarget()
    local target = nil
    local dist = math.huge
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            local part = v.Character:FindFirstChild(aimPart)
            
            -- Fallback for R6/R15 parts
            if not part then
                if aimPart == "Legs" then part = v.Character:FindFirstChild("LeftLeg") or v.Character:FindFirstChild("Left Leg")
                elseif aimPart == "Torso" then part = v.Character:FindFirstChild("UpperTorso") or v.Character:FindFirstChild("Torso")
                else part = v.Character:FindFirstChild("Head") end
            end
            if not part then continue end

            local tPos = part.Position
            local sPos, onScreen = Camera:WorldToViewportPoint(tPos)
            local mPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local d = (Vector2.new(sPos.X, sPos.Y) - mPos).Magnitude

            if onScreen and d < (fovSize / 2) then
                if teamChk and v.Team == LocalPlayer.Team then continue end
                
                if wallChk then
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    local res = workspace:Raycast(Camera.CFrame.Position, (tPos - Camera.CFrame.Position).Unit * 1000, rp)
                    if res and res.Instance and not res.Instance:IsDescendantOf(v.Character) then continue end
                end

                if d < dist then
                    dist = d
                    target = v
                end
            end
        end
    end
    return target
end

-- Update Loops
local function updateFov()
    fovDraw.Radius = fovSize
    fovDraw.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if rainbowFov then
        fovDraw.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    else
        fovDraw.Color = Color3.new(1, 1, 1)
    end
    fovDraw.Visible = fovCircle
end

local function updateEsp()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not espObjs[v] then
            local box = Drawing.new("Square")
            box.Thickness = 1
            local name = Drawing.new("Text")
            name.Size = 13
            name.Center = true
            name.Outline = true
            local hp = Drawing.new("Text")
            hp.Size = 13
            hp.Center = true
            hp.Outline = true
            espObjs[v] = {Box = box, Name = name, Health = hp}
        end
    end

    for _, v in pairs(Players:GetPlayers()) do
        local obj = espObjs[v]
        if not obj then continue end
        
        local show = false
        local col = Color3.new(1, 1, 1)
        
        if espOn and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if not (espTeam and v.Team == LocalPlayer.Team) then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if onScreen then
                    show = true
                    if rainbowEsp then col = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
                    
                    obj.Box.Size = Vector2.new(30, 60)
                    obj.Box.Position = Vector2.new(pos.X - 15, pos.Y - 30)
                    obj.Box.Color = col
                    
                    obj.Name.Text = v.Name
                    obj.Name.Position = Vector2.new(pos.X, pos.Y - 40)
                    obj.Name.Color = col
                    
                    obj.Health.Text = math.floor(v.Character.Humanoid.Health)
                    obj.Health.Position = Vector2.new(pos.X, pos.Y - 55)
                    obj.Health.Color = Color3.fromRGB(0, 255, 0)
                end
            end
        end
        obj.Box.Visible = show and espBox
        obj.Name.Visible = show and espName
        obj.Health.Visible = show and espHp
    end
end

local function updateSkelly()
    for _, line in pairs(skellyObjs) do line:Remove() end
    table.clear(skellyObjs)
    if not skellyEsp then return end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            if not (skellyTeam and v.Team == LocalPlayer.Team) then
                local hum = v.Character:FindFirstChild("Humanoid")
                if hum then
                    local conns = {
                        {"Head", "UpperTorso"}, {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
                        {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
                        {"UpperTorso", "LowerTorso"}, {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
                        {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"}
                    }
                    local r6conns = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}
                    local sel = (hum.RigType == Enum.HumanoidRigType.R15) and conns or r6conns

                    for _, c in pairs(sel) do
                        local p1 = v.Character:FindFirstChild(c[1])
                        local p2 = v.Character:FindFirstChild(c[2])
                        if p1 and p2 then
                            local pos1, on1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, on2 = Camera:WorldToViewportPoint(p2.Position)
                            if on1 and on2 then
                                local line = Drawing.new("Line")
                                line.Thickness = 1
                                line.Color = rainbowEsp and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)
                                line.From = Vector2.new(pos1.X, pos1.Y)
                                line.To = Vector2.new(pos2.X, pos2.Y)
                                line.Visible = true
                                table.insert(skellyObjs, line)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function updateTracer()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not tracerObjs[v] then
            local line = Drawing.new("Line")
            line.Thickness = 1
            tracerObjs[v] = {Line = line}
        end
    end

    for _, v in pairs(Players:GetPlayers()) do
        local obj = tracerObjs[v]
        if not obj then continue end
        local show = false
        local col = Color3.new(1, 1, 1)

        if tracerOn and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if not (tracerTeam and v.Team == LocalPlayer.Team) then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if onScreen then
                    show = true
                    if rainbowTracer then col = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
                    obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    obj.Line.To = Vector2.new(pos.X, pos.Y)
                    obj.Line.Color = col
                end
            end
        end
        obj.Line.Visible = show
    end
end

local function updateCham()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            if chamOn and not (chamTeam and v.Team == LocalPlayer.Team) then
                if not chamObjs[v] then
                    local h = Instance.new("Highlight")
                    h.Name = "NLHighlight"
                    h.FillTransparency = 0.5
                    h.Adornee = v.Character
                    h.Parent = v.Character
                    chamObjs[v] = h
                end
                chamObjs[v].Enabled = true
                chamObjs[v].FillColor = rainbowCham and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.fromRGB(255, 0, 0)
            else
                if chamObjs[v] then chamObjs[v].Enabled = false end
            end
        end
    end
end

local function setXray(en)
    if en then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) and v:GetAttribute("xrayd") == nil then
                v:SetAttribute("xrayd", true)
                v:SetAttribute("oldTrans", v.Transparency)
                v.Transparency = 0.5
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v:GetAttribute("xrayd") then
                local old = v:GetAttribute("oldTrans")
                if old ~= nil then v.Transparency = old end
                v:SetAttribute("xrayd", nil)
            end
        end
    end
end

local function fly2Update()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if fly2On then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end

        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = char.HumanoidRootPart
        end
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 10000
            bg.Parent = char.HumanoidRootPart
        end

        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

        bv.Velocity = (move.Magnitude > 0 and move.Unit * fly2Spd) or Vector3.new(0, 0, 0)
        bg.CFrame = Camera.CFrame
    else
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = plrFov
    
    -- Aimbot Logic
    if aimOn then
        local t = getTarget()
        if t then
            local part = t.Character:FindFirstChild(aimPart) or t.Character:FindFirstChild("Head") or t.Character.HumanoidRootPart
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), (smooth / 100))
        end
    end

    -- Auto Shoot
    if autoShoot then
        local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {LocalPlayer.Character}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
        
        if res then
            local char = res.Instance:FindFirstAncestorOfClass("Model")
            if char then
                local plr = Players:GetPlayerFromCharacter(char)
                if plr and plr ~= LocalPlayer and not (autoTeam and plr.Team == LocalPlayer.Team) then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end
        end
    end

    -- Character Modifiers
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if speedOn and hum and root then root.CFrame = root.CFrame + (hum.MoveDirection * ((speedVal / 10) * 0.5)) end
        if jumpOn and hum then hum.JumpPower = jumpVal elseif hum then hum.JumpPower = 50 end
        if gravOn then workspace.Gravity = gravVal end
        if noAir and hum and root then local v = root.Velocity; root.Velocity = Vector3.new(v.X, 0, v.Z) end
        
        fly2Update()
        
        if spinOn and root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpd), 0) end
        if noclipOn then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end

    -- Visual Updates
    updateFov()
    updateEsp()
    updateTracer()
    updateCham()
    updateSkelly()
end)

-- Input Handling
UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- UI Construction
Window:AddTabLabel('Aimbot')
local tabAim = Window:AddTab('Aimbot', 'CrossHair')
local aimMain = tabAim:AddSection('Main', "left")

aimMain:AddToggle('Enable Aimbot', false, function(v) aimOn = v end)
aimMain:AddSlider('Smoothness', 1, 100, 1, function(v) smooth = v end)
aimMain:AddSlider('FOV Size', 10, 500, 90, function(v) fovSize = v end)
aimMain:AddToggle('Show FOV Circle', false, function(v) fovCircle = v end)
aimMain:AddToggle('Rainbow FOV Circle', false, function(v) rainbowFov = v end)
aimMain:AddDropdown('Aim Part', {'Head', 'Torso', 'Legs'}, 'HumanoidRootPart', function(v)
    if v == 'HumanoidRootPart' then aimPart = 'HumanoidRootPart'
    elseif v == 'Torso' then aimPart = 'UpperTorso'
    elseif v == 'Legs' then aimPart = 'LeftLeg'
    end
end)
aimMain:AddToggle('Wall Check', false, function(v) wallChk = v end)
aimMain:AddToggle('Team Check', false, function(v) teamChk = v end)

local legit = tabAim:AddSection('Legit', "right")
legit:AddToggle('Auto Shoot', false, function(v) autoShoot = v end)
legit:AddToggle('Team Check', false, function(v) autoTeam = v end)

Window:AddTabLabel('Visual')
local tabVis = Window:AddTab('Visual', 'user')
local visPlr = tabVis:AddSection('Player', "left")

visPlr:AddToggle('Enable ESP', false, function(v) espOn = v end)
visPlr:AddToggle('Boxes', false, function(v) espBox = v end)
visPlr:AddToggle('Names', false, function(v) espName = v end)
visPlr:AddToggle('Health', false, function(v) espHp = v end)
visPlr:AddToggle('Rainbow ESP', false, function(v) rainbowEsp = v end)
visPlr:AddToggle('Team Check', false, function(v) espTeam = v end)
visPlr:AddToggle('Skeleton ESP', false, function(v) skellyEsp = v end)
visPlr:AddToggle('Tracers', false, function(v) tracerOn = v end)
visPlr:AddToggle('Rainbow Tracers', false, function(v) rainbowTracer = v end)
visPlr:AddToggle('Team Check', false, function(v) tracerTeam = v end)
visPlr:AddToggle('Chams', false, function(v) chamOn = v end)
visPlr:AddToggle('Rainbow Chams', false, function(v) rainbowCham = v end)
visPlr:AddToggle('Team Check', false, function(v) chamTeam = v end)

Window:AddTabLabel('World')
local tabWorld = Window:AddTab('World', 'earth')
local worldVis = tabWorld:AddSection('Visuals', "left")

worldVis:AddToggle('Xray', false, function(v) setXray(v) end)
worldVis:AddToggle('Night Mode', false, function(v)
    if v then Lighting.TimeOfDay = 0 else Lighting.TimeOfDay = 12 end
end)
worldVis:AddToggle('Anti Lag', false, function(v)
    if v then for _, x in pairs(game:GetDescendants()) do if x:IsA("Texture") or x:IsA("ParticleEmitter") or x:IsA("Trail") then x:Destroy() end end end
end)

Window:AddTabLabel('Player')
local tabPlr = Window:AddTab('Player', 'user')
local plrVis = tabPlr:AddSection('Visuals', "left")
plrVis:AddSlider('FOV', 30, 120, 70, function(v) plrFov = v end)

local plrMove = tabPlr:AddSection('Movement', "left")
plrMove:AddToggle('Speed Enabled', false, function(v) speedOn = v end)
plrMove:AddSlider('Speed', 1, 999, 20, function(v) speedVal = v end)
plrMove:AddToggle('Infinite Jump', false, function(v) infJump = v end)
plrMove:AddToggle('Jump Power', false, function(v) jumpOn = v end)
plrMove:AddSlider('Jump Amount', 1, 999, 50, function(v) jumpVal = v end)
plrMove:AddToggle('Low Gravity', false, function(v)
    gravOn = v
    if v then if gravVal == 196.2 then gravVal = 50 end else gravVal = 196.2 workspace.Gravity = 196.2 end
end)
plrMove:AddSlider('Gravity', 0, 999, 50, function(v) gravVal = v if gravOn then workspace.Gravity = v end end)

local plrFly = tabPlr:AddSection('Fly', "right")
plrFly:AddToggle('NoAir / Float', false, function(v) noAir = v end)
plrFly:AddToggle('Fly 1 (Proohio)', false, function(v) flyOn = v end) -- Note: Fly 1 logic was missing in original loop, currently a placeholder
plrFly:AddToggle('Fly 2 (Space/Ctrl)', false, function(v) fly2On = v end)
plrFly:AddSlider('Fly 2 Speed', 10, 200, 50, function(v) fly2Spd = v end)

local plrMisc = tabPlr:AddSection('Misc', "right")
plrMisc:AddToggle('Invisible', false, function(v)
    if v then
        local char = LocalPlayer.Character
        if char then
            local saved = char.HumanoidRootPart.CFrame
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            local seat = Instance.new("Seat", workspace)
            seat.Anchored = false
            seat.CanCollide = false
            seat.Name = "invischair"
            seat.Transparency = 1
            seat.Position = Vector3.new(-25.95, 84, 3537.55)
            local weld = Instance.new("Weld", seat)
            weld.Part0 = seat
            weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            seat.CFrame = saved
        end
    else
        if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end
    end
end)
plrMisc:AddToggle('SpinBot', false, function(v) spinOn = v end)
plrMisc:AddSlider('Spin Speed', 1, 100, 20, function(v) spinSpd = v end)
plrMisc:AddToggle('Noclip', false, function(v) noclipOn = v end)

Window:AddTabLabel('Settings')
local tabSet = Window:AddTab('Settings', 'gear')
local setCfg = tabSet:AddSection('Config', "left")

setCfg:AddButton("Serverhop", function()
    local pid = game.PlaceId
    local srvs = {}
    local pg = 1
    while true do
        local ok, resp = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&sortBy=Players&limit=100&cursor="..(pg > 1 and ((pg-1)*100) or "")))
        end)
        if not ok then break end
        for _, s in pairs(resp.data) do table.insert(srvs, s) end
        if not resp.nextPageCursor then break end
        pg = pg + 1
    end
    if #srvs > 0 then
        local pick = srvs[math.random(1, #srvs)]
        TeleportService:TeleportToPlaceInstance(pid, pick.id)
    end
end)

setCfg:AddButton("Rejoin", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

setCfg:AddButton("Exit", function()
    game:Shutdown()
end)

setCfg:AddButton("Unload", function()
    Window:Destroy()
end)

print("NEVERLOSE UI Loaded")
