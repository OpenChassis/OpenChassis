local event = game.ReplicatedStorage:WaitForChild('Events'):WaitForChild('OCEvent')
local input = require(script.Parent.Input)
local chassis = require( game.ReplicatedStorage:WaitForChild('Shared').Chassis)

event.OnClientEvent:Connect(function(...)
	local args = {...}
	
	if args[1] == 'StartDriving' then
		local modelRef = game.Workspace['OpenChassis_' .. args[2]]
		local settings = require(modelRef.Settings)
		chassis.new(args[2], settings, modelRef)
	end
end)
