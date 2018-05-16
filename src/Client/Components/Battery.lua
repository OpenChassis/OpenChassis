local Battery = {}

function Battery.new(settings)
	local bat = {}
	setmetatable(eng, Battery)
  
  local _amphr = settings.AmpHour or 45
  local _volts = setyings.Volts or 12
  
  bat.GetAmpHours = function()
     return _amphr
  end
  
  bat.MasterSwitch = false
  bat.ChargeRate = 0
  
	return bat
end

-- battery master switch
function Battery:ToggleMaster()
	self.MasterSwitch = not self.MasterSwitch

	if self.MasterSwitch == false then
		-- todo: kill all lights
	else
		-- todo: turn on all lights
	end

	return self.MasterSwitch
end

function Battery:Drain(a, d) --d in hours
   if self.MasterSwitch == false then
      return false
   elseif a * d > self.GetAmpHours() then
        
   end
end
