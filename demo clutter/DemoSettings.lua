return {
	FeetToOneStudScale = 1.2,
	
	_isDev = true,
	
	-- TODO: Adjust for FeetToOneStudScale
	FrontAxleOffset = 5.9,
	FrontAxleHeight = -2,
	Wheelbase = 10.9, --108.7 in = 9.05833 feet = 7.5486 studs
	FrontTrack = 6.3,
	RearTrack = 6.3,
	
	FrontCamber = -3,
	RearCamber = -7,
	
	SteeringAngle = 35,
	
	DriveType = 'rwd',
	SteerType = 'front',
	
	-- TODO: Adjust for FeetToOneStudScale
	WheelColliderRadius = 2.35,
	
	-- TODO: Adjust for FeetToOneStudScale
	FrontSuspensionHeight = 2.3,
	FrontStiffness = 25400,
	FrontDamping = 675,
	
	-- TODO: Adjust for FeetToOneStudScale
	RearSuspensionHeight = 2.4,
	RearStiffness = 25200,
	RearDamping = 680,
	
	-- TODO: Adjust for FeetToOneStudScale
	CurbWeight = 3924, --TODO: Change to Curb(Kerb) Weight (will be 'CurbWeight'
	WeightDistribution = 53,
	WeightScale = .02,
	
	GearRatios = {
		-2.9, --reverse
		0,    --neutral
		2.5,  --1
		2.2,  --2
		1.6,  --3
		1.2,  --4
		1.1,  --5
		1,  --6
	},
	FinalDrive = 5.5,
	
	-- {rpm, torque}
	Curve = {
		{0, 10},
		{700, 170},
		{2600, 275},
		{3000, 300},
		{3500, 325},
		{4000, 337},
		{4500, 345},
		{5000, 337},
		{5500, 330},
		{6000, 315},
		{6500, 290},
		{7000, 260},
		{7100, 250}
	},
	
	StallRPM = 450,
	StartRPM = 610, 
	IdleRPM = 950,
	IdleBounceMin = 2,
	IdleBounceMax = 6,
	
	Redline = 7175,
	EngineDecay = 4500, -- rev/s is cubic  
	EngineInertia = 6500, -- when clutch not engaged 
	EngineBraking = 1500, 
	
	StarterDuration = 1.18,
	
	FDiffEngageScale = 1.05, -- slipwheel velc * engaglescale > gripwheel velc = engage torque vectorijng
	FDiffSplitAllowance = 60, --precent 0-100
	RDiffEngagleScale = 1.05, -- 
	FDiffSplitAllowance = 70,
	
    SteeringRate = 1.5,
	LinearSteering = false,
    
    BrakeForce = 15000,
    SecondaryBrakeForce = 17000,
    FrontBrakeRate = .6,

	MPHScaling = .8,
}

--[[
	METADATA
	6.2L/481-hp/443-lb-ft DOHC 32-valve V-8
	443 ft-lbs. @ 5000 rpm
	451 hp @ 6800 rpm
	7-speed shiftable automatic
	Seats 5
	Dusk sense lamps
	Electronic distrubiton of brake force
	stability
	traction
	daytime running lights
	
	
	Len x Wid x Hei = 186.0 x 70.7 x 56.3 in inches
	mpgc/mpgh = 12/18
	
	Front Track		 = 61.8 in.
	Length			 = 186.1 in.
	Curb Weight		 = 3924 lbs.
	Ground Clearance = 4.1 in.
	Height			 = 56.6 in.
	Wheelbase		 = 108.7 in.
	Width			 = 70.7 in.
	Rear Track		 = 60.0 in.
	
	Tires = 255/35R18 94Z
	Wheel Size = 18 X 9.0 In
	
	
	Tank capcity	 = 17.4 gal
--]]