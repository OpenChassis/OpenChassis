local Transmission = {}

function Transmission.new(settings)
	local trans = {}
	
	trans.Clutch = 0 --where 0 is resting against flywheel
	
	trans.Gear = 2 --where 2 is neutral regardless of trans type
	
	trans.GearRatios = settings.GearRatios
	
	return trans
end

function Transmission:GearUp()
	if self.Gear < #self.GearRatios then
		if self.Clutch ~= 1 then
			
		else
			self.Gear = self.Gear + 1
			return self.Gear
		end
	end
	return false
end

function Transmission:GearDown()
	if self.Gear > 0 then
		if self.Clutch ~= 1 then
			
		else
			self.Gear = self.Gear - 1
			return self.Gear
		end
	end
	return false
end

function Transmission:AdjustClutch(val)
	self.Clutch = val
end

return Transmission
