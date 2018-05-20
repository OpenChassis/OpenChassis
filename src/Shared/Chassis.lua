local httpSer = game:GetService("HttpService")
local runSer = game:GetService('RunService')
local dataBuilder = require(game.ReplicatedStorage:WaitForChild('Shared').DataBuilder)
local signal = require(game.ReplicatedStorage:WaitForChild('Shared').Signal)
local helper = require(game.ReplicatedStorage:WaitForChild('Shared').ChassisHelper)

local chassisEvent = game.ReplicatedStorage:WaitForChild('Events').OCEvent

local cf = CFrame.new
local v3 = Vector3.new
local v2 = Vector2.new 

local pi = math.pi

local ran = Random.new(tick())

local Chassis = {}
Chassis.__index = Chassis

--id and owner are optional
function Chassis.new(id, settings, modelref, owner)
	
	if not type(id) == 'string' then
		if owner then owner = modelref end
		modelref = settings
		settings = id
		id = httpSer:GenerateGUID(false)
	end
	
	local newChassis = {}
	setmetatable(newChassis, Chassis)
	
	local _guid		= id  
	local _settings = settings
	local _owner	= owner
	local _driver   = false
	
	local _master  = false
	local _starter = false
	local _running = false
	
	local _lightsOn  = false
	local _isLowBeam = false
	
	local _rpm = 0

	local _gear = 2
	
	local _allWheels, _driveWheels = dataBuilder:GetWheelColliders(modelref, _settings.DriveType)
	
	local _allTorque, _driveTorque, _aeroForce = dataBuilder:GetForces(modelref, _settings.DriveType)
	
	local _steer = dataBuilder:GetSteering(modelref, _settings.SteerType)
	
	local _exhaust, _starter, _idle, _lockBeep, _tireSounds = dataBuilder:GetSounds(modelref)
	
	local _rearRunning, _brake, _reverse, _low, _high, _fog, _turnLeft, _turnRight = dataBuilder:GetLights(modelref)
	
	newChassis.Model = modelref
	
	-- scoped helper funcs
	local function lightToggle(lightList, state)
		for i = 1 ,#lightList do
			local v = lightList[i]
			v.Material = (state and Enum.Material.Neon or Enum.Material.SmoothPlastic)
			
			local hasLight = v:FindFirstChildOfClass('SurfaceLight') or v:FindFirstChildOfClass('PointLight') or v:FindFirstChildOfClass('SpotLight')
			
			if hasLight then
				hasLight.Enabled = state
			end
		end
	end
	
	local function applyTorque(tQ)
		if #_driveWheels == 4 then
			-- is awd
			-- first split between axles then wheels
		else
			-- is fwd or rwd
			-- just split between these wheels
		end
	end
	
	-- inputs
	newChassis.Throttle = 0
	newChassis.Clutch   = 0
	newChassis.Brakes   = 0
	
	newChassis.Locked = false
	
	newChassis.Model.Name = 'OpenChassis_' .. _guid
	
	newChassis.DriverChanged = signal.new()
	newChassis.DriverEntered = signal.new()
	newChassis.DriverExited  = signal.new()
	newChassis.EngineStarted = signal.new()
	newChassis.EngineStopped = signal.new()
	
	newChassis.GetId = function()
		return _guid
	end
	
	newChassis.GetOwner = function()
		return _owner
	end
	
	newChassis.StartDriving = function(playerRequesting)
		
		if runSer:IsClient() then
			playerRequesting = game.Players.LocalPlayer
		end

		if newChassis.Locked == true then
			return false 
		end
		
		if _driver == false and playerRequesting then
			_driver = playerRequesting
			
			newChassis.DriverChanged:Fire(playerRequesting)
			newChassis.DriverEntered:Fire(playerRequesting)
			
			if runSer:IsServer() then
				chassisEvent:FireClient(playerRequesting, 'StartDriving', newChassis.GetId())
			end
			
			return true
		else
			return false
		end
	end
	
	newChassis.StopDriving = function(playerRequesting)
		if runSer:IsClient() then
			chassisEvent:FireServer('StopDriving', newChassis.GetId())
		end
		
		if _driver == playerRequesting then
			_driver = false
			
			newChassis.DriverChanged:Fire(playerRequesting)
			newChassis.DriverExited:Fire(playerRequesting)
			
			return true
		else
			return false
		end
	end
	
	newChassis.ToggleMaster = function()
		_master = not _master
		
		if _master == false then
			if _running then
				_idle:Stop()
				_exhaust:Stop()
				_starter:Stop()
				_running = false
				
				newChassis.EngineStopped:Fire()
			end
		end
	end
	
	newChassis.ToggleStarter = function ()
		_starter = not _starter
		
		if _starter == true then
			if not _running then
				spawn(function()
					_starter:Play()
					
					wait(ran:NextNumber(.5, 3))
					
					_idle:Play()
					_running = true
					
					newChassis.EngineStarted:Fire()
				end)
			else
				-- over crank
			end
		else
			_starter:Stop()
		end
	end
	
	newChassis.GearUp = function()
		if _gear ~= #_settings.GearRatios then
			if _gear == 1 then
				lightToggle(_reverse, false)
				_gear = 2
			else
				_gear = _gear + 1
			end
		end
	end
	
	newChassis.GearDown = function()
		if _gear == 2 then
			lightToggle(_reverse, true)
			_gear = 1
		else
			_gear = _gear - 1
		end
	end
	
	newChassis.ToggleLights = function()
		_lightsOn = not _lightsOn
		
		if not _master then
			lightToggle(_high, false)
			lightToggle(_low, false)
			lightToggle(_rearRunning, false)
			return false
		end
		
		if _lightsOn == false then
			lightToggle(_high, false)
			lightToggle(_low, false)
			lightToggle(_rearRunning, false)
		else
			lightToggle(_rearRunning, true)
			if _isLowBeam then
				lightToggle(_low, true)
			else
				lightToggle(_high, true)
			end
		end
	end
	
	newChassis.ToggleLamps = function()
		if not _master then
			return false
		end
		
		if _lightsOn then
			_isLowBeam = not _isLowBeam
			
			if _isLowBeam == true then
				lightToggle(_low, false)
				lightToggle(_high, true)
			end
		end
	end
	
	newChassis.LockBeep = function()
		if _lockBeep then
			_lockBeep:Play()
		end
	end
	
	-- call in renstep on client, heartbeat on server
	newChassis.Update = function()
		
		if not _running then
			return false
		end
		
		if newChassis.Clutch == 0 then
			local topDriveVelc = helper:GetFastestRotation(_driveWheels)
			
			if topDriveVelc == 0 then
				-- _rpm = _settings.Idle
				-- thats for autos ^
				-- lets stall mannys ayy?
			else
				_rpm = (topDriveVelc * _settings.GearRatios[_gear] * _settings.FinalDrive) * (60/2 * pi)
			end
			
			local maxTorque = helper:PowerCurveLookup(_rpm, _settings.Curve)
			local flyWheelTorque = (newChassis.Throttle <= .05 and maxTorque * .05 or maxTorque * newChassis.Throttle)
			
			local driveLineTorque = flyWheelTorque * _settings.GearRatios[_gear] * _settings.FinalDrive * .7 -- mechanical loss factor of 30%
			
			-- driveLineTorque is NOT scaled for roblox!!!
			-- add brake torque to it then pass to wheels
		end
	end
	
	newChassis.Destroy = function()
		
		newChassis.DriverChanged:Disconnect()
		newChassis.DriverEntered:Disconnect()
		newChassis.DriverExited:Disconnect()
		newChassis.EngineStarted:Disconnect()
		newChassis.EngineStopped:Disconnect()
	
		if runSer:IsClient() then
			chassisEvent:FireServer('Destroy', newChassis.GetId())
		else
			modelref:Destroy()
		end
	end
	
	return newChassis
end

function Chassis:Unlock(playerRequesting)
	if runSer:IsClient() then
		chassisEvent:FireServer('Unlock', self.GetId())
		return 
	end
	if playerRequesting and playerRequesting == self.GetOwner() then
		self.Locked = false
	else
		return false
	end
end

function Chassis:Lock(playerRequesting)
	if runSer:IsClient() then
		chassisEvent:FireServer('Lock', self.GetId())
		return 
	end
	if playerRequesting and playerRequesting == self.GetOwner() then
		self.Locked = true
		self.LockBeep()
	else
		return false
	end
end

return Chassis
