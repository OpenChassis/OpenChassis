local httpSer = game:GetService("HttpService")
local runSer = game:GetService('RunService')
local dataBuilder = require(game.ReplicatedStorage:WaitForChild('Shared').DataBuilder)
local signal = require(game.ReplicatedStorage:WaitForChild('Shared').Signal)
local chassisEvent = game.ReplicatedStorage:WaitForChild('Events').OCEvent

local cf = CFrame.new
local v3 = Vector3.new
local v2 = Vector2.new 

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
	
	local _guid = id  
	local _settings = settings
	local _owner = owner
	local _driver = false
	
	local _master = false
	local _starter = false
	
	local _rpm = 0
	local _throttle = 0
	
	local _gear = 1
	
	local _allTorque, _driveTorque, _aeroForce = dataBuilder:GetForces(modelref, settings.DriveType)
	local _steer = dataBuilder:GetSteering(modelref, settings.SteerType)
	
	local _exhaust, _starter, _idle, _lockBeep, _tireSounds = dataBuilder:GetSounds(modelref)
	
	local _rearRunning, _brake, _low, _high, _fog, _turnLeft, _turnRight = dataBuilder:GetLights(modelref)
	
	newChassis.Model = modelref
	
	newChassis.Locked = false
	
	newChassis.Model.Name = 'OpenChassis_' .. _guid
	
	newChassis.DriverChanged = signal.new()
	newChassis.DriverEntered = signal.new()
	newChassis.DriverExited  = signal.new()
	
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
	end
	
	newChassis.ToggleStarter = function ()
		_starter = not _starter
	end
	
	newChassis.PowerWheels =  function()
		
	end
	
	newChassis.Steer = function()
		
	end
	
	newChassis.LockBeep = function()
		if _lockBeep then
			_lockBeep:Play()
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
	print(runSer:IsClient())
	print(runSer:IsServer())
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

function Chassis:Update()
	
end

return Chassis
