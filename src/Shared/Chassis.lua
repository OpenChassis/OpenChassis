local httpSer = game:GetService("HttpService")
local runSer  = game:GetService('RunService')

local dataBuilder = require(game.ReplicatedStorage:WaitForChild('Shared').DataBuilder)
local signal      = require(game.ReplicatedStorage:WaitForChild('Shared').Signal)
local helper      = require(game.ReplicatedStorage:WaitForChild('Shared').ChassisHelper)

local chassisEvent = game.ReplicatedStorage:WaitForChild('Events').OCEvent

local cf = CFrame.new
local v3 = Vector3.new
local v2 = Vector2.new 

local pi = math.pi
local max = math.max
local min = math.min
local abs = math.abs
local floor = math.floor

local secondsTwoPi = 60/(2 * pi)
local twoPi = 2 * pi
local piOverThirty = pi / 30

local noClutchPenalty = .7

local ran = Random.new(tick())

local Chassis = {}
Chassis.__index = Chassis

--id and owner are optional
function Chassis.new(id, settings, modelref, owner)
	
	if not type(id) == 'string' then
		if owner then owner = modelref end
		modelref = settings
		settings = id
		id = httpSer:GenerateGUID(false)
	end
	
	local newChassis = {}
	setmetatable(newChassis, Chassis)
	
	local _guid		= id  
	local _settings = settings
	local _owner	= owner
	local _driver   = false

	local _engineOn = false
	local _startDebounce = false
	local _firstStart = true
	
	local _lightsOn  = false
	local _isLowBeam = false
	
	local _rpm = 0
	local _throttle = 0
    
    local _steering = 0

	local _gear = 2
	
	local _allWheels, _driveWheels = dataBuilder:GetWheelColliders(modelref, _settings.DriveType)
	local _allDampeners, _driveDampeners = dataBuilder:GetDampeners(modelref, _settings.DriveType)

	for i = 1, #_allDampeners do
		_allDampeners[i].MotorMaxTorque = 0
		_allDampeners[i].AngularVelocity = 0
	end

	
	local _steer = dataBuilder:GetSteering(modelref, _settings.SteerType)
	
	local _rearRunning, _brake, _reverse, _low, _high, _fog, _turnLeft, _turnRight = dataBuilder:GetLights(modelref)
	local _exhaust, _starter, _idle, _lockBeep, _tireSounds = dataBuilder:GetSounds(modelref)

	local _maxTorque = helper:PowerCurveLookup(_settings.Redline + 100, _settings.Curve)
	
	newChassis.Model = modelref
	newChassis.RPMChanged = signal.new()
	
	local _clutchDebounce = false
	
	-- scoped helper funcs
	local function lightToggle(lightList, state)
		for i = 1 ,#lightList do
			local v = lightList[i]
			v.Material = (state and Enum.Material.Neon or Enum.Material.SmoothPlastic)
			
			local hasLight = v:FindFirstChildOfClass('SurfaceLight') or v:FindFirstChildOfClass('PointLight') or v:FindFirstChildOfClass('SpotLight')
			
			if hasLight then
				hasLight.Enabled = state
			end
		end
	end
	
	local function getCarMass()
		local mass = 0

		local parts = newChassis.Model:GetDescendants()
		for i = 1, #parts do
			if parts[i]:IsA('BasePart') then
				mass = mass + parts[i]:GetMass()
			end
		end
		
		return mass
	end
	
	newChassis.GetClutch = function()
		if _clutchDebounce == true then
			return 1
		else
			return newChassis.Clutch
		end
	end
	
	-- inputs
	newChassis.Throttle        = 0
	newChassis.Clutch          = 0
    newChassis.Brakes          = 0
    newChassis.SecondaryBrakes = 0
	newChassis.Steering        = 0
	
	newChassis.RPM  = 0
	newChassis.Gear = 'N'
	
	newChassis.Model.Name = 'OpenChassis_' .. _guid
	
	newChassis.GetId = function()
		return _guid
	end
	
	newChassis.ForceStall = function()
		if _idle then 
			_idle:Stop()
		end
		if _exhaust then
			_exhaust:Stop()
		end
		_engineOn = false
		_rpm = 0
		lightToggle(_brake, false)
	end
	
	newChassis.GearUp = function(bypass)
		if not bypass then

			if _clutchDebounce == true then
				return
			end

			if newChassis.GetClutch() == 0 then
				_clutchDebounce = true
				return spawn(function()
					wait(noClutchPenalty)
					_clutchDebounce = false
					newChassis.GearUp(true)
					
				end)
			end
		end

		if _gear ~= #_settings.GearRatios then
			if _gear == 1 then
				lightToggle(_reverse, false)
				newChassis.Gear = 'N'
				_gear = 2
			else
				_gear = _gear + 1
				newChassis.Gear = tostring(_gear - 2)
			end
		end
	end
	
	newChassis.GearDown = function(bypass)
		if not bypass then

			if _clutchDebounce == true then
				return
			end

			if newChassis.GetClutch() == 0 then
				_clutchDebounce = true
				return spawn(function()
					wait(noClutchPenalty)
					_clutchDebounce = false
					newChassis.GearDown(true)
					return
				end)
			end
		end

		if _gear ~= 1 then
			if _gear == 2 then
				lightToggle(_reverse, true)
				newChassis.Gear = 'R'
				_gear = 1
			else
				_gear = _gear - 1
				
				if _gear == 2 then
					newChassis.Gear = 'N'
				else
					newChassis.Gear = tostring(_gear - 2)
				end
			end
		end
	end
	
	newChassis.ToggleLights = function()
		_lightsOn = not _lightsOn
		
		if _lightsOn == false then
			lightToggle(_high, false)
			lightToggle(_low, false)
			lightToggle(_rearRunning, false)
		else
			lightToggle(_rearRunning, true)
			if _isLowBeam then
				lightToggle(_low, true)
			else
				lightToggle(_high, true)
			end
		end
	end
	
	newChassis.ToggleLamps = function()
		
		if _lightsOn then
			_isLowBeam = not _isLowBeam
			
			if _isLowBeam == true then
				lightToggle(_low, false)
				lightToggle(_high, true)
			end
		end
    end
    
--[[
    ------------------------------------------ UPDATE ------------------------------------------
]]--
	
	-- call in renstep on client, heartbeat on server
	newChassis.Update = function(delta)
		
	----------------------------------------- Rev Limiter -----------------------------------------

		if _rpm > _settings.Redline then
--			local diff = _rpm - _settings.Redline
--			_rpm = _rpm - ran:NextInteger(diff, diff + 750)
            _throttle = 0
        else
            _throttle = min(newChassis.Throttle, 1)
        end
	----------------------------------------- Starter -----------------------------------------	
	
		if _startDebounce then
			return
		end

		if not _engineOn then
			if _firstStart == false and _throttle == 0 then
				return
			elseif _firstStart == true or _throttle > 0 then
				
				if _gear ~= 2 and newChassis.GetClutch() == 0 then
					return
				end
				
				_startDebounce = true
			
				return spawn(function()
					if _starter then
						_starter:Play()
						wait(_settings.StarterDuration)
						_starter:Stop()
					end
					_startDebounce = false
					_engineOn = true
					if _idle then
						_idle:Play()
					end
					if _firstStart then
						_firstStart = false
					end
				end)
			end
		end
--[[
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ States @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
]]--
		local wheelTq = 0
		local frontForce = 0
		local rearForce  = 0
		local brakeForces = {0, 0, 0, 0}
		local slip = helper:GetSlip(_allWheels)
		local engineBrake = 0
		
		local drivelineRatio = _settings.GearRatios[_gear] * _settings.FinalDrive

--[[
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Engine @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    -------------------------------------------- RPM --------------------------------------------
]]--



        
    -------------------------------------------- RPM Intergral --------------------------------------------
		-- fastest rotvelc drive wheelcollider
		local topDriveVelcRadians = helper:GetFastestRotation(_allWheels)

		-- rpm at the clutch due to wheel rotvelc
		local clutchVelcRadians = (topDriveVelcRadians * drivelineRatio) --/ piOverThirty
		
		local clutchRPM = (clutchVelcRadians * 60) / twoPi

		-- difference between last flywheel rpm and current clutch rpm
		local clutchSlip = abs(_rpm - clutchRPM)

		--@@@@ clutch engaged to flywheel and transmission @@@@--
		if newChassis.GetClutch() == 0 and _gear ~= 2 then

			-- helper for starting out; assume last frame
			-- the clutch was dumped because the go pedals down
			-- this will sorta ease it
			-- @TODO dont do this if slipping 
			if _rpm <= _settings.StallRPM then
				newChassis.ForceStall()
			elseif _rpm > clutchRPM and _throttle > 0 then
				_rpm = _rpm - (clutchSlip * .25)
			elseif _rpm < clutchRPM then
				_rpm = _rpm + (clutchSlip * .25)
				if _throttle == 0 then
					engineBrake = _settings.EngineBraking * (_rpm / _settings.Redline)
				end
			else
				_rpm = _rpm - (clutchSlip * .5)
				engineBrake = _settings.EngineBraking * (_rpm / _settings.Redline)
			end

		--@@@@ clutch partially disengaged from flywheel @@@@--
		elseif newChassis.GetClutch() < 1 and _gear ~= 2 then
			-- @TODO partial clutch model

		--@@@@ clutch fully disengaged from flywheel or gear is neutral@@@@--
		elseif newChassis.GetClutch() == 1 or _gear == 2 then
			if _throttle > 0 then
				local scaledInertia = _settings.EngineInertia * delta
				_rpm = _rpm + (scaledInertia * _throttle) --FIXME?

			elseif _throttle == 0 then

				local scaledDecay = _settings.EngineDecay * delta
				local decayRPM = _rpm - scaledDecay

				if decayRPM < _settings.IdleRPM then
					--local rpmDiff = _settings.IdleRPM - decayRPM
					--_rpm = _settings.IdleRPM + ran:NextInteger(abs(rpmDiff * .15), abs(rpmDiff * .5))
					_rpm = _settings.IdleRPM + ran:NextInteger(_settings.IdleBounceMin, _settings.IdleBounceMax)
				else
					_rpm = decayRPM
				end
			end
		end
		
		
		------------------------------------- Driveline to the wheels -------------------------------------

		local maxFlyWheelTq = abs(helper:PowerCurveLookup(_rpm, _settings.Curve))
		
		local maxWheelRpm = _rpm / drivelineRatio
		
		local wheelAngVelcRadians = maxWheelRpm * piOverThirty

		----------------------------------------- Events & Audio -----------------------------------------

		if newChassis.RPM ~= _rpm then
			newChassis.RPMChanged:Fire(_rpm)
		end
		
        newChassis.RPM = _rpm


		if _rpm > 1250 then
			if _idle and _idle.Playing then
				_idle:Stop()
				_exhaust:Play()
			end
		else
			if _exhaust and _exhaust.Playing then
				_exhaust:Stop()
				_idle:Play()
			end
		end
		
		if _exhaust and _exhaust.Playing then
			local speed = _rpm / _settings.Redline
			_exhaust.PlaybackSpeed = 1 + speed * 2
		end
--[[
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Driveline & Differential @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
]]--
		

--		if _settings.DriveType == 'awd' then
--			wheelTq = flyWheelTq * .25
--		else
--			wheelTq = flyWheelTq * .5
--		end
		if _throttle > 0 then
			wheelTq = (maxFlyWheelTq * _throttle) * 4.8
		else
			wheelTq = 0
		end
		
--[[
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Brakes @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
]]--
		local frontBrake, rearBrake = 0, 0

        if newChassis.Brakes > 0 then
            --local deltaBrakeForce = (newChassis.Brakes * (_settings.BrakeForce * delta))
 			local scaledBrakeForce = newChassis.Brakes * _settings.BrakeForce

            frontBrake = scaledBrakeForce * _settings.FrontBrakeRate
            rearBrake = scaledBrakeForce - frontBrake

			frontBrake = frontBrake * 6
			rearBrake = rearBrake * 6
			lightToggle(_brake, true)
		else
			lightToggle(_brake, false)
        end

        if newChassis.SecondaryBrakes > 0 then

            rearBrake = rearBrake + (newChassis.SecondaryBrakes * _settings.SecondaryBrakeForce) * 10
		end

		for i = 1, #brakeForces do
			if i < 3 then
				brakeForces[i] = frontBrake
			else
				brakeForces[i] = rearBrake
			end
		end
--[[
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Force Application @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
]]--
		
		for i = 1, #_allDampeners do

			-- quick sort to see if we have a roller or a drive axle
			local isDrive = false
			for j = 1, #_driveDampeners do
				if _driveDampeners[j] == _allDampeners[i] then
					isDrive = true
				end
			end


			if isDrive == true and _gear ~= 2 and newChassis.GetClutch() == 0 then
				local force = wheelTq - (brakeForces[i]  + engineBrake)

				_allDampeners[i].MotorMaxTorque = abs(force) --* piOverThirty

				if force < 0 then
						_allDampeners[i].AngularVelocity = 0
						
				else
					_allDampeners[i].AngularVelocity = -(wheelAngVelcRadians * 1.1)
				end
			else
				if brakeForces[i] > 0 then
					_allDampeners[i].MotorMaxTorque = brakeForces[i] * piOverThirty
				else
					_allDampeners[i].MotorMaxTorque = 0
				end
				
				if _allDampeners[i].AngularVelocity ~= 0 then
					_allDampeners[i].AngularVelocity = 0
				end
				
			end
		end


--[[
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Steering @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
]]--

        -- delta rate
        local steerRate = _settings.SteeringRate * delta

        -- ease steering
		if _settings.LinearSteering == false then
            -- decay to 0
			if newChassis.Steering == 0 then
				if _steering ~= 0 then
					if _steering > 0 then
						_steering = (_steering - steerRate < 0 and 0 or _steering - steerRate)

					elseif _steering < 0 then
						_steering = (_steering + steerRate > 0 and 0 or _steering + steerRate)

					end
				end

			-- else increase to desired
            -- else increase to desired
			elseif newChassis.Steering > 0 then 
				_steering = (_steering + steerRate < newChassis.Steering and _steering + steerRate or newChassis.Steering)

			elseif newChassis.Steering < 0 then
				_steering = (_steering - steerRate > newChassis.Steering and _steering - steerRate or newChassis.Steering)

			end

        -- linear steering input
        else
            _steering = newChassis.Steering
        end    

		if _steering > 1 then
			_steering = 1
		elseif _steering < -1 then
			_steering = -1
		end
		local velcAlpha = newChassis.Model.PrimaryPart.Velocity.Magnitude / 260
        -- apply steering to attatchments
		local steerTheta = _settings.SteeringAngle - (_settings.SteeringAngle * velcAlpha)

        for i = 1, #_steer do
            _steer[i].Orientation = v3(0,  steerTheta * _steering, -90)
        end
        
	end
	
	newChassis.Destroy = function()
		
		newChassis.RPMChanged = nil

		modelref:Destroy()

	end
	
	newChassis.BindGui = function(gui)
		newChassis.Gui = gui
	end
	
	return newChassis
end

return Chassis