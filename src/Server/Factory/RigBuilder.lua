-- module script child of Factory

local v3 =  Vector3.new
local cf = CFrame.new
local cfa = CFrame.Angles
local rad = math.rad
local noMass = PhysicalProperties.new(.01,1,1)
local physSer = game:GetService('PhysicsService')

local wheelCollisonGroup, bodyCollisionGroup, lowresColliderGroup = 'WheelGroup', 'BodyGroup', 'ColliderGroup'

local wheelGroup = physSer:CreateCollisionGroup(wheelCollisonGroup)
local bodyGroup = physSer:CreateCollisionGroup(bodyCollisionGroup)
local colliderGroup = physSer:CreateCollisionGroup(lowresColliderGroup)

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
ball.CustomPhysicalProperties = PhysicalProperties.new(1,.9,1)

part.CanCollide = false

local vecf = Instance.new('VectorForce')
vecf.Force = v3(0,0,0)

local RigBuilder = {}

function RigBuilder.new(settings, modelRef, owner )
	
	local self = {}
	
	local main = modelRef.PrimaryPart
	
	local function RemoveMass(modelRef)
		for _, v in pairs(modelRef:GetDescendants()) do
			if v:IsA('BasePart') then
				v.CustomPhysicalProperties = noMass
			end
		end
	end
	
	local function SetCollision(modelRef)
		if not modelRef:FindFirstChild('BodyColliders') then
			local m = Instance.new("Model")
			m.Parent = modelRef
			m.Name = 'BodyColliders'
		end
		
		if modelRef:FindFirstChild('Parts') then
			for _, v in pairs(modelRef.Parts:GetDescendants()) do
				if v:IsA('BasePart') then
					physSer:SetPartCollisionGroup(v, bodyCollisionGroup)
				end
			end
		end
		
		for _, v in pairs(modelRef.Wheels:GetChildren()) do
			physSer:SetPartCollisionGroup(v.WheelCollider, wheelCollisonGroup)
		end
		
		for _, v in pairs(modelRef.BodyColliders:GetDescendants()) do
			if v:IsA('BasePart') then
				physSer:SetPartCollisionGroup(v, lowresColliderGroup)
			end
		end
		
		physSer:CollisionGroupSetCollidable(wheelCollisonGroup, bodyCollisionGroup, false)
		physSer:CollisionGroupSetCollidable(wheelCollisonGroup, lowresColliderGroup, false)
		physSer:CollisionGroupSetCollidable(bodyCollisionGroup, lowresColliderGroup, false)
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
				for _, v in pairs(visualsModel:GetDescendants()) do 
					if v:IsA('BasePart') and v.Name ~= 'Main' then
						local w = SingleWeld(visualsModel.Main, v)
					end
				end

				local wOrient = wheel.Hub.Orientation
				
				if string.lower(string.sub(wheel.Parent.Name, 2,2)) == 'r' then
					wOrient = v3(wOrient.X, wOrient.Y, -wOrient.Z)
				end
				
				local angles = cfa(rad(wOrient.X), rad(wOrient.Y), rad(wOrient.Z))
				local centerOffset = cf(-visualsModel.Main.ColliderCenter.Position)
				
				visualsModel:SetPrimaryPartCFrame((wheel.CFrame* angles) * centerOffset)
				
				local axWeld = weld:Clone()
				axWeld.Parent = wheel
				axWeld.Part0 = wheel
				axWeld.Part1 = visualsModel.Main
				axWeld.C0 = wheel.CFrame:Inverse() * ((wheel.CFrame* angles) * centerOffset)
			end
		end
	end
	
	local function RigDummyHub(wheelModel, strutTowerBase)
		local hub = part:Clone()
		
		hub.Size = v3(1,1,1)
		
		return hub
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
		
		local axleF = main.CFrame * cf(0, settings.FrontAxleHeight, -settings.FrontAxleOffset)
		local axleR = axleF * cf(0, 0, settings.Wheelbase)
		
		return axleF, axleR
	end
	
	-- todo: size ball by wheelsizes
	local function GetWheels(axleF, axleR)
		local fl, fr, rl, rr = ball:Clone(), ball:Clone(), ball:Clone(), ball:Clone()
		
		local wheelsL, wheelsR = {fl, rl }, {fr, rr}
		
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
		
		fl.CFrame = axleF *cf(-settings.FrontTrack / 2,0,0)
		fr.CFrame = axleF *cf(settings.FrontTrack / 2,0,0)
		rl.CFrame = axleR *cf(-settings.RearTrack / 2,0,0)
		rr.CFrame = axleR *cf(settings.RearTrack / 2,0,0)

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
		damp.Name = 'Dampener'
		damp.Attachment0 = mount.Hub
		damp.Attachment1 = wheel.Hub
		damp.InclinationAngle = 90 - (axleSide == 'l' and -settings[sideVar .. 'Camber'] or settings[sideVar .. 'Camber'])
		damp.LimitsEnabled = true
		
		damp.AngularActuatorType = Enum.ActuatorType.Motor
		
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
		local chassmass = 0
		local parts = modelRef:GetDescendants()
		
		for i = 1, #parts do
			if parts[i]:IsA('BasePart') then
				chassmass = chassmass + parts[i]:GetMass()
			end
		end
		
		
		local massF, massR = part:Clone(), part:Clone()
		massF.Name = 'FrontMass'
		massR.Name = 'RearMass'
		
		local weightDist = settings.WeightDistribution  / 100
		local scaledMass = settings.CurbWeight * settings.WeightScale
		scaledMass = scaledMass - chassmass
		
		local massf = scaledMass * weightDist
		local massr = scaledMass - massf
		
		-- mass = volume * density
		
		local sizeScaleF, sizeScaleR = (massf ) / 9, (massr) / 9

		massF.CustomPhysicalProperties = PhysicalProperties.new(1, .01, .01, 1,1)
		massR.CustomPhysicalProperties = PhysicalProperties.new(1, .01, .01, 1,1)
		
		massF.Size = v3(sizeScaleF, sizeScaleF, sizeScaleF)
		massR.Size = v3(sizeScaleR, sizeScaleR, sizeScaleR)
		
		massF.Parent = main.Parent
		massR.Parent = main.Parent
		
		massF.CFrame = main.CFrame * cf(0, 0, -5)
		massR.CFrame = main.CFrame * cf(0, 0, 5)
		
		massF.CanCollide = false
		massR.CanCollide = false

		return massF, massR
	end
	
	local function RigAero(axleF, axleR)
		local aeroF, aeroR, aeroC = vecf:Clone(), vecf:Clone(), vecf:Clone()
		aeroF.Name, aeroR.Name, aeroC.Name = 'AeroF', 'AeroR', 'AeroC'
		
		local hub = a:Clone()
		
		hub.Parent = main
		
		aeroC.Parent = main
		aeroC.Attachment0 = hub
		return aeroF, aeroR, aeroC
	end

	self.RemoveMass = RemoveMass
	self.UnanchorAll = UnanchorAll
	self.SetCollision = SetCollision
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
