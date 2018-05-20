local ChassisHelper = {}

function ChassisHelper:GetFastestRotation(wheels)
	local topVelc = 0
	
	for i = 1, #wheels do
		if wheels[i].RotVelocity.Magnitude > topVelc then
			topVelc = wheels[i].RotVelocity.Magnitude
		end
	end
	
	return topVelc
end

function ChassisHelper:GetSlip(wheels)
	local slip = {}
	
	for i = 1, #wheels do
		local rotations  = wheels[i].RotVelocity.Magnitude * (wheels[i].Size.X/2)
		local difference = rotations - wheels[i].Velocity.Magnitude
		
		-- account for floating point
		if difference > 1 or difference < -1 then
			slip[i] = true
		else
			slip[i] = false
		end
	end
	
	return slip
end

function ChassisHelper:PowerCurveLookup(rpm, curve)
	
	local minRpm, maxRpm = 0, math.huge
	
	for i = 1, #curve do
		local thisCurve = curve[i]
		
		if rpm <= thisCurve[1] then
			if curve[i - 1] and rpm > curve[i - 1][1] then
				local prevCurve = curve[i - 1]
				
				local difference = thisCurve[1] - prevCurve[1]
				
				local alpha = difference / (rpm - prevCurve[1])
				
				-- lerp to find torque				
				return thisCurve[2] + alpha * (prevCurve[2] - thisCurve[2])
					
			else
				return 0
			end
		end
	end
	return 0
end

function ChassisHelper:GetHorsePower(rpm, torque)
	return torque * rpm/5252
end

return ChassisHelper
