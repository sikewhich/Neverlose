local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/SourceCludeLib/refs/heads/main/NerverLoseLibEdited.lua"))()
local Window = NEVERLOSE:AddWindow("NEVERLOSE", "CS:GO CHEAT", 'Fan Made')

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local aimOn = false
local smooth = 1
local fovSize = 90
local aimPart = "Head"
local wallChk = false
local fovCircle = false
local rainbowFov = false

local espOn = false
local espBox = false
local espName = false
local espHp = false
local rainbowEsp = false
local tracerOn = false
local rainbowTracer = false
local skellyEsp = false
local chamOn = false
local rainbowCham = false

local speedOn = false
local speedVal = 20
local jumpOn = false
local jumpVal = 50
local infJump = false
local gravOn = false
local gravVal = 196.2
local noAir = false
local fly2On = false
local fly2Spd = 50
local spinOn = false
local spinSpd = 20
local noclipOn = false
local plrFov = 70

local hitboxOn = false
local hitboxSize = 5
local hitboxTrans = 1

local triggerBot = false
local lastShot = 0
local silentAim = false
local autoShoot = false

local espObjs = {}
local tracerObjs = {}
local chamObjs = {}
local skellyObjs = {}
local bv, bg
local connection

local fovDraw = Drawing.new("Circle")
fovDraw.Visible = false
fovDraw.Thickness = 1
fovDraw.NumSides = 50
fovDraw.Filled = false

local function clearESP(plr)
    if espObjs[plr] then
        espObjs[plr].Box:Remove()
        espObjs[plr].Name:Remove()
        espObjs[plr].Health:Remove()
        espObjs[plr] = nil
    end
    if tracerObjs[plr] then
        tracerObjs[plr].Line:Remove()
        tracerObjs[plr] = nil
    end
    if chamObjs[plr] then
        chamObjs[plr].Enabled = false
        chamObjs[plr] = nil
    end
end

local function getTarget()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = v.Character:FindFirstChild(aimPart)
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
    end
    return target
end

local function updateFov()
    fovDraw.Radius = fovSize
    fovDraw.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovDraw.Color = rainbowFov and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1,1,1)
    fovDraw.Visible = fovCircle
end

local function updateEsp()
    for _, v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        
        if not v.Character or not v.Character:FindFirstChild("HumanoidRootPart") or (v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0) then
            clearESP(v)
            continue
        end

        if not espObjs[v] then
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
        
        if not tracerObjs[v] then
            local line = Drawing.new("Line")
            line.Thickness = 1
            tracerObjs[v] = {Line = line}
        end

        local obj = espObjs[v]
        local tobj = tracerObjs[v]
        local hum = v.Character.Humanoid
        local root = v.Character.HumanoidRootPart

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        
        if espOn and onScreen then
            local col = rainbowEsp and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1,1,1)
            local headPos = Camera:WorldToViewportPoint(v.Character.Head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
            
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height / 2

            obj.Box.Size = Vector2.new(width, height)
            obj.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
            obj.Box.Color = col
            obj.Box.Visible = espBox

            obj.Name.Text = v.Name
            obj.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
            obj.Name.Color = col
            obj.Name.Visible = espName

            obj.Health.Text = tostring(math.floor(hum.Health))
            obj.Health.Position = Vector2.new(pos.X - width/2 - 20, pos.Y - height/2)
            obj.Health.Color = Color3.fromRGB(0, 255, 0)
            obj.Health.Visible = espHp
        else
            obj.Box.Visible = false
            obj.Name.Visible = false
            obj.Health.Visible = false
        end

        if tracerOn and onScreen then
            tobj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            tobj.Line.To = Vector2.new(pos.X, pos.Y)
            tobj.Line.Color = rainbowTracer and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1,1,1)
            tobj.Line.Visible = true
        else
            tobj.Line.Visible = false
        end

        if chamOn then
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

local function updateSkelly()
    for _, line in pairs(skellyObjs) do line:Remove() end
    table.clear(skellyObjs)
    if not skellyEsp then return end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local hum = v.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local conns = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"}}
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
                            line.Color = rainbowEsp and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1,1,1)
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

local function updateHitbox()
    if hitboxOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hum = v.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local hrp = v.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = hitboxTrans
                    hrp.Massless = true
                    hrp.CanCollide = false
                end
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

local function silentAimHook()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if silentAim and method == "FireServer" and tostring(self):lower():find("shoot") or tostring(self):lower():find("fire") then
            local target = getTarget()
            if target and target.Character and target.Character:FindFirstChild(aimPart) then
                local pos = target.Character[aimPart].Position
                if args[1] and typeof(args[1]) == "table" then
                    if args[1].origin then args[1].origin = LocalPlayer.Character.Head.Position end
                    if args[1].direction then args[1].direction = (pos - LocalPlayer.Character.Head.Position).Unit end
                    if args[1].hit then args[1].hit = target.Character[aimPart] end
                elseif args[1] and typeof(args[1]) == "Vector3" then
                    args[1] = pos
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

local function panic()
    if connection then connection:Disconnect() end
    for _, v in pairs(espObjs) do clearESP(v) end
    for _, v in pairs(tracerObjs) do if v.Line then v.Line:Remove() end end
    for _, v in pairs(skellyObjs) do v:Remove() end
    for _, v in pairs(chamObjs) do if v then v:Destroy() end end
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = Vector3.new(2,2,1)
            v.Character.HumanoidRootPart.Transparency = 0
        end
    end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    workspace.Gravity = 196.2
    Window:Destroy()
end

connection = RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = plrFov
    
    if aimOn then
        local t = getTarget()
        if t then
            local part = t.Character:FindFirstChild(aimPart) or t.Character:FindFirstChild("Head") or t.Character.HumanoidRootPart
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), (smooth / 100))
        end
    end

    if triggerBot then
        local currentTime = tick()
        if currentTime - lastShot >= 1.0 then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
                    local hum = v.Character.Humanoid
                    if hum and hum.Health > 0 then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        lastShot = currentTime
                        break
                    end
                end
            end
        end
    end

    if autoShoot then
        local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local res = workspace:Raycast(ray.Origin, ray.Direction * 10, RaycastParams.new())
        
        if res and res.Instance then
            if res.Instance.Name == "LayBody" or res.Instance.Name == "LayDown" or res.Instance:IsA("Seat") then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                task.wait(0.5)
            end
        end
    end

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
        if noclipOn then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end

    updateFov()
    updateEsp()
    updateSkelly()
    updateHitbox()
end)

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

Window:AddTabLabel('Main')
local tabAim = Window:AddTab('Aimbot', 'CrossHair')
local aimMain = tabAim:AddSection('Main', "left")
aimMain:AddToggle('Enable Aimbot', false, function(v) aimOn = v end)
aimMain:AddSlider('Smoothness', 1, 100, 1, function(v) smooth = v end)
aimMain:AddSlider('FOV Size', 10, 500, 90, function(v) fovSize = v end)
aimMain:AddToggle('Show FOV Circle', false, function(v) fovCircle = v end)
aimMain:AddToggle('Rainbow FOV Circle', false, function(v) rainbowFov = v end)
aimMain:AddDropdown('Aim Part', {'Head', 'Torso', 'Legs'}, 'Head', function(v) aimPart = v end)
aimMain:AddToggle('Wall Check', false, function(v) wallChk = v end)

local legit = tabAim:AddSection('Silent / Auto', "right")
legit:AddToggle('Silent Aim', false, function(v) silentAim = v end)
legit:AddToggle('Auto Shoot (Body)', false, function(v) autoShoot = v end)

local tabCombat = Window:AddTab('Combat', 'sword')
local combatMain = tabCombat:AddSection('Hitbox', "left")
combatMain:AddToggle('Enabled', false, function(v) hitboxOn = v end)
combatMain:AddSlider('Size', 1, 50, 10, function(v) hitboxSize = v end)
combatMain:AddSlider('Transparency', 0, 1, 1, function(v) hitboxTrans = v end)

local combatBot = tabCombat:AddSection('Trigger Bot', "right")
combatBot:AddToggle('Shoot All (1s Delay)', false, function(v) triggerBot = v end)

Window:AddTabLabel('Visuals')
local tabVis = Window:AddTab('Visuals', 'user')
local visPlr = tabVis:AddSection('Player ESP', "left")
visPlr:AddToggle('Enable ESP', false, function(v) espOn = v end)
visPlr:AddToggle('Boxes', false, function(v) espBox = v end)
visPlr:AddToggle('Names', false, function(v) espName = v end)
visPlr:AddToggle('Health', false, function(v) espHp = v end)
visPlr:AddToggle('Skeleton', false, function(v) skellyEsp = v end)
visPlr:AddToggle('Tracers', false, function(v) tracerOn = v end)
visPlr:AddToggle('Chams', false, function(v) chamOn = v end)
visPlr:AddToggle('Rainbow', false, function(v) rainbowEsp = v end)

local visWorld = tabVis:AddSection('World', "right")
visWorld:AddToggle('Fullbright', false, function(v)
    if v then Lighting.Brightness = 2 Lighting.ClockTime = 14 else Lighting.Brightness = 1 end
end)

Window:AddTabLabel('Movement')
local tabPlr = Window:AddTab('Player', 'running')
local plrMove = tabPlr:AddSection('Physics', "left")
plrMove:AddToggle('Speed Enabled', false, function(v) speedOn = v end)
plrMove:AddSlider('Speed', 1, 100, 20, function(v) speedVal = v end)
plrMove:AddToggle('Infinite Jump', false, function(v) infJump = v end)
plrMove:AddToggle('Jump Power', false, function(v) jumpOn = v end)
plrMove:AddSlider('Jump Amount', 1, 200, 50, function(v) jumpVal = v end)
plrMove:AddToggle('Low Gravity', false, function(v)
    gravOn = v
    if v then if gravVal == 196.2 then gravVal = 50 end else gravVal = 196.2 workspace.Gravity = 196.2 end
end)

local plrFly = tabPlr:AddSection('Fly / Misc', "right")
plrFly:AddToggle('Fly (Space/Ctrl)', false, function(v) fly2On = v end)
plrFly:AddSlider('Fly Speed', 10, 200, 50, function(v) fly2Spd = v end)
plrFly:AddToggle('Noclip', false, function(v) noclipOn = v end)
plrFly:AddToggle('SpinBot', false, function(v) spinOn = v end)
plrFly:AddSlider('Spin Speed', 1, 100, 20, function(v) spinSpd = v end)

Window:AddTabLabel('Settings')
local tabSet = Window:AddTab('Settings', 'gear')
local setCfg = tabSet:AddSection('Config', "left")
setCfg:AddButton("Serverhop", function()
    local pid = game.PlaceId
    local srvs = {}
    local pg = 1
    while true do
        local ok, resp = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100&cursor="..(pg > 1 and pg or "")))
        end)
        if not ok then break end
        for _, s in pairs(resp.data) do table.insert(srvs, s) end
        if not resp.nextPageCursor then break end
        pg = pg + 1
    end
    if #srvs > 0 then TeleportService:TeleportToPlaceInstance(pid, srvs[math.random(1, #srvs)].id) end
end)
setCfg:AddButton("Rejoin", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
setCfg:AddButton("PANIC (Unload All)", function() panic() end)

silentAimHook()
print("Loaded")
