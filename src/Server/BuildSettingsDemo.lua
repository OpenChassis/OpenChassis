-- pass with any model that has a primary part named Main to Factory to test the rig.
-- Wheels will build in accordance to Main's lookVector and upVector. 

return {
	_isDev = true,
	
	FrontAxleOffset = 5.9,
	FrontAxleHeight = -2,
	Wheelbase = 10.9,
	FrontAxleWidth = 6,
	RearAxleWidth = 6,
	
	WheelColliderRadius = 2.6,
	
	FrontSuspensionHeight = 2.3,
	FrontStiffness = 2500,
	FrontDamping = 50,
	
	RearSuspensionHeight = 2.4,
	RearStiffness = 2000,
	RearDamping = 45,
	
	GrossWeight = 1200,
	WeightDistribution = 48
}
