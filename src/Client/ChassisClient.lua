-- module script child of client folder

local signal = require(game.ReplicatedStorage:WaitForChild('Shared').Signal)
local dataBuilder = require(script.DataBuilder)
local eng = require(script.Components.Engine)
local trans = require(script.Components.Transmission)

local ChassisClient = {}
ChassisClient.__index = ChassisClient

-- when start driving
function ChassisClient.new(id, settings, modelref, owner)
	local chassis = {}
	setmetatable(chassis, ChassisClient)
	
	chassis.ID = id
	
	chassis.Engine = eng.new()
	chassis.Transmission = trans.new()
	
	--states
	
	chassis.AllTorque, chassis.DriveTorque, chassis.Aero = dataBuilder:GetForces(modelref, settings)
	chassis.Steer = dataBuilder:GetSteering(modelref, settings)
	
	return chassis
end


-- when stop driving
function ChassisClient:Destroy()
	
end

return ChassisClient
