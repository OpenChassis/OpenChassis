-- module script child of ChassisClient

local DataBuilder = {}

function DataBuilder:GetForces(modelRef, settings)
	local allTorque = {} --sorted fl, fr, rl, rr
	local driveTorque = {} --sorted left right by axles ie (fl, fr, rl, rr) for awd or (rl, rr) for rwd
	local aero = {} -- currently only center
	
	table.insert(allTorque, modelRef.Wheels.fl.WheelCollider.Torque)
	table.insert(allTorque, modelRef.Wheels.fr.WheelCollider.Torque)
	table.insert(allTorque, modelRef.Wheels.rl.WheelCollider.Torque)
	table.insert(allTorque, modelRef.Wheels.rr.WheelCollider.Torque)
	
	if string.lower(settings.DriveType) == 'fwd' or  string.lower(settings.DriveType) == 'awd' then
		table.insert(driveTorque, allTorque[1])
		table.insert(driveTorque, allTorque[2])
	end
	
	if string.lower(settings.DriveType) == 'rwd' or  string.lower(settings.DriveType) == 'awd' then
			table.insert(driveTorque, allTorque[3])
		table.insert(driveTorque, allTorque[4])
	end

	table.insert(aero, modelRef.Main.AeroC)
	
	return allTorque, driveTorque, aero
end

function DataBuilder:GetSteering(modelRef, settings)
	local steer = {} --sorted left right by axles ie (fl, fr) for front wheel steer or (fl, fr, rl, rr) for all wheel steer
	
	if string.lower(settings.SteerType) == 'front' or string.lower(settings.SteerType) == 'all' then
		table.insert(steer, modelRef.Wheels.fl.StrutMount.Hub)
		table.insert(steer, modelRef.Wheels.fr.StrutMount.Hub)
	end
	
	if string.lower(settings.SteerType) == 'rear' or string.lower(settings.SteerType) == 'all' then
		table.insert(steer, modelRef.Wheels.rl.StrutMount.Hub)
		table.insert(steer, modelRef.Wheels.rr.StrutMount.Hub)
	end
	
	return steer
end

return DataBuilder
