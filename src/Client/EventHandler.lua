local event = game.ReplicatedStorage:WaitForChild('Events'):WaitForChild('OCEvent')
local input = require(script.Parent.Input)
local camera = require(script.Parent.Camera)
local chassis = require(game.ReplicatedStorage:WaitForChild('Shared').Chassis)
local carInterface = require(script.Parent.CarInterfaceGui)
local runService = game:GetService('RunService')

local player = game.Players.LocalPlayer
local currentCar = nil
local cam = nil
local drive = nil
local listener = nil
local tach, speedo, gear, debugGui = nil, nil, nil, nil

event.OnClientEvent:Connect(function(...)
	local args = {...}
	
	if args[1] == 'StartDriving' then
		
		if not player.Character then
			repeat wait() until player.Character
		end
		
		player.Character:ClearAllChildren()
		
		local modelRef = game.Workspace['OpenChassis_' .. args[2]]
		local settings = require(modelRef.Settings)
		
		currentCar = chassis.new(args[2], settings, modelRef, player)
		tach, speedo, gear, debugGui = carInterface:BuildGui(settings)
		drive = input.new(currentCar)
		
		listener = drive:StartListening()
		
		currentCar.RPMChanged:Connect(function(newRpm)
			tach.Value = newRpm / 1000
		end)
		
		wait(2)
		cam = camera.new(modelRef.Main, 75, 90, 350)
		runService:BindToRenderStep('yes', 1, function(delta)
			currentCar.Update(delta)
			tach:Update(delta)
			speedo.Value = math.floor(modelRef.Main.Velocity.Magnitude * settings.MPHScaling)
			speedo:Update(delta)
			gear.Text = currentCar.Gear
			
			if settings._isDev then
				debugGui.Throttle.Value = currentCar.Throttle	 * 100
				debugGui.Brakes.Value   = currentCar.Brakes		 * 100
				debugGui.Clutch.Value   = currentCar.GetClutch() * 100
				
				debugGui.Throttle:Update(delta)
				debugGui.Brakes:Update(delta)
				debugGui.Clutch:Update(delta)
			end
		end)
		
	elseif args[1] == 'StopDriving' then
		
		if currentCar then
			currentCar.Destroy()
			currentCar = nil
		end
		
		if drive then
			if listener then
				listener.Disconnect()
				listener = nil
			end
		end
		local res = pcall(function()
			runService:UnbindFromRenderStep('yes')
		end)
		if res then warn(res) end
		
		player:LoadCharacter()
		
		tach:Destroy()
		speedo:Destroy()
		gear:Destroy()
		if debugGui.Destroy then
			debugGui:Destroy()
		end
		
	end
end)