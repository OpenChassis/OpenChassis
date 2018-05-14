local signal = require(script.Signal)
local rigWorker = require(script.RigBuilder)

local httpSer = game:GetService('HttpService')

local eventList = {
	ChassisCreated = true,
	ChassisBuilding = true
}

local mt = {
	__newindex = function(t,k,v)
		if eventList[k] == true then
			rawset(t,k,signal.new())
		else
			rawset(t,k,v)
		end
	end
}

local Factory = {}
	
function Factory.newChassis(buildSettings, modelRef, owner)

	local rigBuilder = rigWorker.new(buildSettings, modelRef, owner)
	
	local main = modelRef.PrimaryPart
	
	local wheelWeld = modelRef:FindFirstChild('WheelWelded')
	
	local chassisId = httpSer:GenerateGUID(false)
	
	-- fire prebuild event if it exists
	if Factory.ChassisBuilding then
		if (type(Factory.ChassisBuilding) == 'boolean') and Factory.ChassisBuilding ~= true then
		
		else
			Factory.ChassisBuilding:Fire(chassisId)
		end
	end
	
	rigBuilder.RemoveMass(modelRef)
	rigBuilder.DontCollide(modelRef)
	
	-- calc axleF from main offset then axleR from 
	local axleF, axleR = rigBuilder.GetAxles()
	
	local fl, fr, rl, rr = rigBuilder.GetWheels(axleF, axleR)
	--local rl, rr = rigBuilder.GetWheels(axleR)
	local wheels = {
		['fl'] = fl,
		['fr'] = fr,
		['rl'] = rl,
		['rr'] = rr
	}
	
	local wheelModels = {}
	
	local suspension = {}
	local constraints = {}
	local wheelForces = {}
	--local suspensionForces = {}
	
	
	if not modelRef:FindFirstChild('Wheels') then
		local m = Instance.new("Model")
		m.Parent = modelRef
		m.Name ='Wheels'
	end
	
	for k,v in pairs(wheels) do
		local keyedWheel = modelRef.Wheels:FindFirstChild(k)
		--local keyedWeld = wheelWeld:Clone()
		
		if not keyedWheel then
			keyedWheel = Instance.new("Model")
			keyedWheel.Name = k
			keyedWheel.Parent = modelRef.Wheels
		end
		
		v.Parent = keyedWheel
		--keyedWeld.Parent = keyedWheel
		
		--keyedWeld:SetPrimaryPartCFrame(v.CFrame)
		
		suspension[k] = rigBuilder.GetSuspension(v)
		suspension[k].Parent = keyedWheel
		
		constraints[k] = {
			Spring = rigBuilder.RigSpring(v,suspension[k]),
			Dampener = rigBuilder.RigDampener(v,suspension[k])
		}
	
		wheelForces[k] = rigBuilder.RigWheelTorque(v)
		
		wheelModels[k] = keyedWheel
		
		keyedWheel.Parent = workspace
		--suspensionForces[k] = rigBuilder:RigSpringCompressor(v)
		
		v.Parent = keyedWheel
	end
	
	for k, v in pairs(suspension) do
		local w = rigBuilder.SingleWeld(main, v)
	end
	
	wait(1)
	
	local massF, massR, massC = rigBuilder.RigMass(axleF, axleR)
	
	local aeroF, aeroR, aeroC = rigBuilder.RigAero(axleF, axleR)
	
	-- weld to part main part or model modelRef ignoring suspension and wheels
	--rigBuilder.WeldExclude(main, modelRef, {wheels, wheelWeld})
	
	if wheelWeld then
		for k, _ in pairs(wheels) do
			local visuals = wheelWeld:Clone()
			visuals.Parent = wheels[k]
			rigBuilder.WeldWheel(wheels[k], visuals)
		end
	end
	
	
	rigBuilder.UnanchorAll(modelRef)
	
	if owner then
		rigBuilder.SetNetwork(modelRef, owner)
	
	end
	
	if buildSettings._isDev == true then
	
	else
	
	end
	
	if Factory.ChassisCreated then
		if (type(Factory.ChassisCreated) == 'bool' or 'boolean') and Factory.ChassisCreated ~= true then
		
		else
			Factory.ChassisCreated:Fire(chassisId)
		end
	end
	
	return true --chassis.new(modelRef, owner)
end

setmetatable(Factory, mt)

return Factory
