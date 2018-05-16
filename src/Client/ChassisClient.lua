-- module script child of client folder

local signal = require(game.ReplicatedStorage:WaitForChild('Shared').Signal)
local dataBuilder = require(script.DataBuilder)

local ChassisClient = {}
ChassisClient.__index = function(t, k) --ChassisClient
	if ChassisClient[k] then
		return ChassisClient[k]
	end
	
end

-- when start driving
function ChassisClient.new(id, settings, modelref, owner)
	local chassis = {}
	setmetatable(chassis, ChassisClient)
	
	chassis.ID = id
	
	--states
	chassis.MasterSwitch = false
	chassis.Starter = false
	
	
	chassis.AllTorque, chassis.DriveTorque, chassis.Aero = dataBuilder:GetForces(modelref, settings)
	chassis.Steer = dataBuilder:GetSteering(modelref, settings)
	
	return chassis
end

function ChassisClient:Start()
	if self.MasterSwitch == false then
		return false
	else
		
	end
end

-- when stop driving
function ChassisClient:Destroy()
	
end

return ChassisClient
