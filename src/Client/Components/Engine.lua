local Engine = {}

function Engine.new(settings)
	local eng = {}
	setmetatable(eng, Engine)
	
	eng.MasterSwitch = false
	eng.Starter = false
	eng.Running = false

	eng.RPM = 0
	eng.Throttle = 0
	eng.Load = 0
	
	--todo: curves
	eng.Curve = false
	
	return eng
end
-- battery master switch
function Engine:ToggleMaster()
	self.MasterSwitch = not self.MasterSwitch
	
	if self.MasterSwitch == false then
		-- todo: kill all lights
	else
		-- todo: turn on all lights
	end

	return self.Engine.MasterSwitch
end
	
function Engine:ToggleStarter()
	self.Starter = not self.Starter
	
	-- if we've turned on the starter
	if self.Starter == true then
		-- if battery master is off
		if self.Engine.MasterSwitch == false then
			return false
		--master on
		else
			-- overcrank starter
			if self.Running == true then
				
			-- initiate starting loop
			else
				-- todo: starting loop
			end
		end
	end 
end

function Engine:AdjustThrottle(newThrot)
	if newThrot > 1 then
		newThrot = 1
	end
	
	self.Throttle = newThrot
end

return Engine
