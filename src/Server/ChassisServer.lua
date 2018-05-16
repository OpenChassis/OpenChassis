-- module script child of Factory

local httpSer = game:GetService("HttpService")
local signal = require(game.ReplicatedStorage:WaitForChild('Shared').Signal)
local chassisEvent = game.ReplicatedStorage:WaitForChild('Events').OCEvent

local ChassisServer = {}
ChassisServer.__index = ChassisServer

--id and owner are optional
function ChassisServer.new(id, settings, modelref, owner)
	
	if not type(id) == 'string' then
		if owner then owner = modelref end
		modelref = settings
		settings = id
		id = httpSer:GenerateGUID(false)
	end
	
	local newChassis = {}
	setmetatable(newChassis, ChassisServer)
	
	local _guid = id  
	local _settings = settings
	local _owner = owner
	local _driver = false
	
	newChassis.Model = modelref
	
	newChassis.Locked = false
	
	newChassis.GetId = function()
		return _guid
	end
	
	newChassis.GetOwner = function()
		return _owner
	end
	
	newChassis.Model.Name = 'OpenChassis_' .. newChassis.GetId()
	
	newChassis.DriverChanged = signal.new()
	newChassis.DriverEntered = signal.new()
	newChassis.DriverExited  = signal.new()
	
	newChassis.StartDriving = function(playerRequesting)
		
		if newChassis.Locked == false then
			return false 
		end
		
		if _driver == false and playerRequesting then
			_driver = playerRequesting
			
			newChassis.DriverChanged:Fire(playerRequesting)
			newChassis.DriverEntered:Fire(playerRequesting)
			
			chassisEvent:FireClient(playerRequesting, 'StartDriving', newChassis.GetId())
			
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
	
	return newChassis
end

function ChassisServer:Unlock(playerRequesting)
	if playerRequesting and playerRequesting == self.GetOwner() then
		self.Locked = false
	else
		return false
	end
end

function ChassisServer:Lock(playerRequesting)
	if playerRequesting and playerRequesting == self.GetOwner() then
		self.Locked = true
	else
		return false
	end
end

return ChassisServer
