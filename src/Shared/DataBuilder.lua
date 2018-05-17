local DataBuilder = {}

function DataBuilder:GetForces(modelRef, driveType)
	local allTorque = {} --sorted fl, fr, rl, rr
	local driveTorque = {} --sorted left right by axles ie (fl, fr, rl, rr) for awd or (rl, rr) for rwd
	local aero = {} -- currently only center
	
	table.insert(allTorque, modelRef.Wheels.fl.WheelCollider.Torque)
	table.insert(allTorque, modelRef.Wheels.fr.WheelCollider.Torque)
	table.insert(allTorque, modelRef.Wheels.rl.WheelCollider.Torque)
	table.insert(allTorque, modelRef.Wheels.rr.WheelCollider.Torque)
	
	if string.lower(driveType) == 'fwd' or  string.lower(driveType) == 'awd' then
		table.insert(driveTorque, allTorque[1])
		table.insert(driveTorque, allTorque[2])
	end
	
	if string.lower(driveType) == 'rwd' or  string.lower(driveType) == 'awd' then
		table.insert(driveTorque, allTorque[3])
		table.insert(driveTorque, allTorque[4])
	end

	table.insert(aero, modelRef.Main.AeroC)
	
	return allTorque, driveTorque, aero
end

function DataBuilder:GetSteering(modelRef, steerType)
	local steer = {} --sorted left right by axles ie (fl, fr) for front wheel steer or (fl, fr, rl, rr) for all wheel steer
	
	if string.lower(steerType) == 'front' or string.lower(steerType) == 'all' then
		table.insert(steer, modelRef.Wheels.fl.StrutMount.Hub)
		table.insert(steer, modelRef.Wheels.fr.StrutMount.Hub)
	end
	
	if string.lower(steerType) == 'rear' or string.lower(steerType) == 'all' then
		table.insert(steer, modelRef.Wheels.rl.StrutMount.Hub)
		table.insert(steer, modelRef.Wheels.rr.StrutMount.Hub)
	end
	
	return steer
end

function DataBuilder:GetSounds(modelRef)
	local exhaust = false
	local starter = false
	local idle = false
	local lockBeep = false
	local tireSounds = {}
	
	for k, v in pairs(modelRef:GetDescendants()) do
		if v:IsA('Sound') then
			if v.Name == 'Exhaust' then
				exhaust = v
			elseif v.Name == 'Starter' then
				starter = v
			elseif v.Name == 'Idle' then
				idle = v
			elseif v.Name == 'LockBeep' then
				lockBeep = v
			elseif v.Name == 'Squeal' then
				table.insert(tireSounds, v)
			end
		end
	end
	
	return exhaust, starter, idle, lockBeep, tireSounds
end

function DataBuilder:GetLights(modelRef)
	local rearRunning = {}
	local brake = {}
	local low = {}
	local high = {}
	local fog = {}
	local turnLeft = {}
	local turnRight = {}
	
	for k, v in pairs(modelRef:GetDescendants()) do
		if v:IsA('BasePart') then
			if v.Name == 'RearRunning' then
				table.insert(rearRunning, v)
			elseif v.Name == 'Brake' then
				table.insert(brake, v)
			elseif v.Name == 'LowLamp' then
				table.insert(low, v)
			elseif v.Name == 'HighLamp' then
				table.insert(high, v)
			elseif v.Name == 'FogLamp' then
				table.insert(fog, v)
			elseif v.Name == 'LeftIndicator' then
				table.insert(turnLeft, v)
			elseif v.Name == 'RightIndicator' then
				table.insert(turnRight, v)
			end
		end
	end
	
	return rearRunning, brake, low, high, fog, turnLeft, turnRight
end

return DataBuilder
