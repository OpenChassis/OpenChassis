-- pass with any model that has a primary part named Main to Factory to test the rig.
-- Wheels will build in accordance to Main's lookVector and upVector. 

return {
	_isDev = true,
	
	FrontAxleOffset = 7,
	FrontAxleHeight = -1.2,
	Wheelbase = 13,
	FrontAxleWidth = 3,
	RearAxleWidth = 3.4,
	
	FrontSuspensionHeight = 2.3,
	FrontStiffness = 2500,
	FrontDamping = 50,
	
	RearSuspensionHeight = 2.4,
	RearStiffness = 2000,
	RearDamping = 45,
	
	GrossWeight = 1200,
	WeightDistribution = 48
}
