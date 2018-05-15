local v3 =  Vector3.new
local cf = CFrame.new
local cfa = CFrame.Angles
local rad = math.rad
local noMass = PhysicalProperties.new(.01,1,1)

local part = Instance.new('Part')
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
part.Anchored = true
part.Size = v3(1,1,1)

local a = Instance.new('Attachment')
a.Parent = part
a.Name = 'Hub'

local weld = Instance.new('Weld')

local ball = part:Clone()
ball.Shape = 'Ball'
ball.Name ='WheelCollider'

part.CanCollide = false

local vecf = Instance.new('VectorForce')
vecf.Force = v3(0,0,0)

local RigBuilder = {}

function RigBuilder.new(settings, modelRef, owner )
	
	local self = {}
	
	local main = modelRef.PrimaryPart
	
	local function RemoveMass(thing)
		for _, v in pairs(thing:GetDescendants()) do
			if v:IsA('BasePart') then
				v.CustomPhysicalProperties = noMass
			end
		end
	end
	
	local function DontCollide()
		
	end
	
	local function SetNetwork(modelRef, owner)
		for _, v in pairs(modelRef:GetDescendants()) do
			if (v:IsA('BasePart') and v.ClassName ~= 'Terrain') then
				if v.Anchored == false then
					v:SetNetworkOwner(owner)
				end
			end
		end
	end
	
	local function SingleWeld(p0, p1)
		local w = weld:Clone()
		w.Parent = p0
		w.Part0 = p0
		w.Part1 = p1
		w.C0 = p0.CFrame:Inverse() * p1.CFrame
	end
	
	local function WeldWheel(wheel, visualsModel)
		RemoveMass(visualsModel)
		
		local visModel = Instance.new('Model')
		visModel.Parent = wheel.Parent
		
		if visualsModel:FindFirstChild('Main') then
			if visualsModel.Main:FindFirstChild('ColliderCenter') then
				local wOrient = wheel.Hub.WorldOrientation
				
				if string.lower(string.sub(wheel.Parent.Name, 2,2)) == 'r' then
					wOrient = v3(wOrient.x, wOrient.y, -wOrient.z)
				end
				
				local angles = cfa(rad(wOrient.X), rad(wOrient.Y), rad(wOrient.Z))
				local centerOffset = cf(visualsModel.Main.ColliderCenter.Position)
				
				visualsModel:SetPrimaryPartCFrame(wheel.CFrame * centerOffset * angles)
			end
		end
		
		for _, v in pairs(visualsModel:GetDescendants()) do 
			if v:IsA('BasePart') then
				local w = SingleWeld(wheel, v)
			end
		end
	end
	
	
	local function UnanchorAll(model)
		for _, v in pairs(model:GetDescendants()) do
			
			if v:IsA('BasePart') then
				if v.ClassName ~= 'Terrain' then
					v.Anchored = false
				end
			end
		end
	end
	
	local function GetAxles()
		local axleF = main.CFrame * cf((main.CFrame.lookVector.Unit * settings.FrontAxleOffset + main.CFrame.upVector.Unit * settings.FrontAxleHeight))
		local axleR = axleF * cf(-axleF.lookVector.Unit * settings.Wheelbase)
		
		return axleF, axleR
	end
	
	-- todo: size ball by wheelsizes
	local function GetWheels(axleF, axleR)
		local fl, fr, rl, rr = ball:Clone(), ball:Clone(), ball:Clone(), ball:Clone()
		
		local wheelsL, wheelsR = {fl, rl, }, {fr, rr}
		
		for _, v in pairs(wheelsL) do
			v.Size = v3(settings.WheelColliderRadius, settings.WheelColliderRadius, settings.WheelColliderRadius)
			v.Hub.Orientation = v3(0,0,-90)
			
			if settings._isDev == true then
				v.Transparency = .6
			else
				v.Transparency = 1
			end
		end
		
		for _, v in pairs(wheelsR) do
			v.Size = v3(settings.WheelColliderRadius, settings.WheelColliderRadius, settings.WheelColliderRadius)
			v.Hub.Orientation = v3(0,0,90)
			
			if settings._isDev == true then
				v.Transparency = .6
			else
				v.Transparency = 1
			end
		end
		
		fl.CFrame = axleF *cf(-axleF.rightVector.Unit * (settings.FrontAxleWidth / 2))
		fr.CFrame = axleF *cf(axleF.rightVector.Unit * (settings.FrontAxleWidth / 2))
		rl.CFrame = axleR *cf(-axleR.rightVector.Unit * (settings.RearAxleWidth / 2))
		rr.CFrame = axleR *cf(axleR.rightVector.Unit * (settings.RearAxleWidth / 2))

		return fl, fr, rl, rr
	end
	
	local function GetSuspension(wheel)
		
		local sideVar = 'Rear'
		if string.lower(string.sub(wheel.Parent.Name,1,1)) == 'f' then
			sideVar = 'Front'
		end
		
		local mount = part:Clone()
		mount.Name = 'StrutMount'
		mount.Hub.Orientation = v3(0,0,-90)
		mount.CFrame = wheel.CFrame * cf(wheel.CFrame.upVector.Unit * settings[sideVar .. 'SuspensionHeight'])
		
		if settings._isDev == true then
			mount.Transparency = .6
		else
			mount.Transparency = 1
		end
	
		return mount
	end
	
	local function RigSpring(wheel, mount)
		
		local sideVar = 'Rear'
		if string.lower(string.sub(wheel.Parent.Name,1,1)) == 'f' then
			sideVar = 'Front'
		end
		
		local spring = Instance.new('SpringConstraint')
		
		spring.Parent = mount
		spring.Attachment0 = mount.Hub
		spring.Attachment1 = wheel.Hub
		spring.Visible = settings._isDev and true or false
		spring.FreeLength = settings[sideVar .. 'SuspensionHeight']
		spring.Stiffness = settings[sideVar .. 'Stiffness']
		spring.Damping = 	settings[sideVar .. 'Damping']	
		
		return spring
	end
	
	local function RigDampener(wheel, mount)
		
		local sideVar = 'Rear'
		if string.lower(string.sub(wheel.Parent.Name,1,1)) == 'f' then
			sideVar = 'Front'
		end
		local axleSide = string.lower(string.sub(wheel.Parent.Name,2,2))
		
		local damp = Instance.new('CylindricalConstraint')
		damp.Parent = mount
		damp.Attachment0 = mount.Hub
		damp.Attachment1 = wheel.Hub
		damp.InclinationAngle = 90 - (axleSide == 'l' and -settings[sideVar .. 'Camber'] or settings[sideVar .. 'Camber'])
		damp.LimitsEnabled = true
		damp.LowerLimit = settings[sideVar .. 'SuspensionHeight'] / 2
		damp.UpperLimit = settings[sideVar .. 'SuspensionHeight']
		damp.Visible = settings._isDev and true or false
		
		return damp
	end
	
	local function RigSpringCompresser(mount)
		local comp = vecf:Clone()
		
		return comp
	end
	
	local function RigWheelTorque(wheel)
		local tq = Instance.new('Torque')
		tq.Parent = wheel
		tq.Attachment0 = wheel.Hub
		
		return tq
	end
	
	local function RigMass()
		local massF, massR, massC = part:Clone(), part:Clone(), part:Clone()

		local massf = settings.GrossWeight * (settings.WeightDistribution  / 100)
		local massr = settings.GrossWeight - massf
		
		
		return massF, massR, massC
	end
	
	local function RigAero(axleF, axleR)
		local aeroF, aeroR, aeroC = vecf:Clone(), vecf:Clone(), vecf:Clone()
		aeroF.Name, aeroR.Name, aeroC.Name = 'aeroF', 'aeroR', 'aeroC'
		
		local hub = a:Clone()
		
		hub.Parent = main
		
		aeroC.Parent = main
		aeroC.Attachment0 = hub
		return aeroF, aeroR, aeroC
	end

	self.RemoveMass = RemoveMass
	self.UnanchorAll = UnanchorAll
	self.DontCollide = DontCollide
	self.SetNetwork = SetNetwork
	self.WeldWheel = WeldWheel
	self.SingleWeld = SingleWeld
	self.GetAxles = GetAxles
	self.GetWheels = GetWheels
	self.GetSuspension = GetSuspension
	self.RigSpring = RigSpring
	self.RigDampener = RigDampener
	self.RigSpringCompresser = RigSpringCompresser
	self.RigWheelTorque = RigWheelTorque
	self.RigMass = RigMass
	self.RigAero = RigAero

	return self
end

return RigBuilder
