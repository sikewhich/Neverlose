local config = {
	games = {
		["Flick FPS"] = {
			id = 136801880565837,
			link = "https://raw.githubusercontent.com/sikewhich/Neverlose/refs/heads/main/Script/FlickFPS.lua"
		},
		["One Tap"] = {
			id = 90568084448279,
			link = "https://raw.githubusercontent.com/sikewhich/Neverlose/refs/heads/main/Script/OneTap.lua"
		}
	}
}

local _a,_b,_c=game:GetService("TweenService"),game:GetService("Lighting"),game:GetService("Players").LocalPlayer;local _e=Instance.new("BlurEffect",_b)_e.Size=0;local _f=Instance.new("ScreenGui",_c:WaitForChild("PlayerGui"))_f.IgnoreGuiInset=true;local _g=Instance.new("TextLabel",_f)_g.Size=UDim2.new(0,800,0,150)_g.Position=UDim2.new(0.5,0,0.5,0)_g.AnchorPoint=Vector2.new(0.5,0.5)_g.BackgroundTransparency=1;_g.Font=Enum.Font.GothamBold;_g.TextColor3=Color3.fromRGB(255,255,255)_g.TextSize=120;_g.TextTransparency=1;_g.Text="Neverlose"local _h=TweenInfo.new(1.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)_a:Create(_e,_h,{Size=25}):Play()_a:Create(_g,_h,{TextTransparency=0}):Play()task.wait(3)local _i=os.clock()while os.clock()-_i<1 do end;local _j=nil;for _,v in pairs(config.games)do if game.PlaceId==v.id then _j=v;break end end;if _j then _g.Text="Neverlose"_g.TextColor3=Color3.fromRGB(0,255,120)task.spawn(function()loadstring(game:HttpGet(_j.link))()end)task.wait(1.5)else _g.Text="Neverlose"_g.TextColor3=Color3.fromRGB(255,50,50)task.wait(2)end;_a:Create(_g,_h,{TextTransparency=1}):Play()_
