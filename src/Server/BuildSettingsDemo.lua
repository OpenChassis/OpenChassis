-- pass with any model that has a primary part named Main to Factory to test the rig.
-- Wheels will build in accordance to Main's lookVector and upVector. 

return {
	_isDev = true,
	
	FrontAxleOffset = 5.9,
	FrontAxleHeight = -2,
	Wheelbase = 10.9,
	FrontAxleWidth = 6.3,
	RearAxleWidth = 6.3,
	
	FrontCamber = -3,
	RearCamber = -7,
	
	DriveType = 'rwd',
	SteerType = 'front',
	
	WheelColliderRadius = 2.35,
	
	FrontSuspensionHeight = 2.3,
	FrontStiffness = 3500,
	FrontDamping = 75,
	
	RearSuspensionHeight = 2.4,
	RearStiffness = 3000,
	RearDamping = 80,
	
	GrossWeight = 1200,
	WeightDistribution = 48,
	
	GearRatios = {
		-2.9, --reverse
		0,    --neutral
		2.5,  --1
		2.2,  --2
		1.6,  --3
		1.2,  --4
		0.9,  --5
		0.6,  --6
	},
	FinalDrive = 3.1,
	
	-- {rpm, torque}
	Curve = {
		{0, 0},
		{2599, 0},
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
	
	IdleRPM = 950, 
	Redline = 7175,
	
}
