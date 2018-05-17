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
		-3.4, --reverse
		0,    --neutral
		3.5,  --1
		3.2,  --2
		2.6,  --3
		2.2,  --4
		1.6,  --5
	}
}
