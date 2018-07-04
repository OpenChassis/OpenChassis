local cam = game.Workspace.CurrentCamera
local shake = require(script.CameraShaker)
local runSer = game:GetService('RunService')

local Camera = {}
Camera.__index = Camera

function Camera.new(subject, fovMin, fovMax, topVelc)
	local c = {}
	cam.CameraSubject = subject
	cam.CameraType = Enum.CameraType.Follow
	local fovSpread = fovMax - fovMin
	
	
--	local newShake = shake.new(1, function(shakeCFrame)
--		cam.CoordinateFrame = ((subject.CFrame * CFrame.Angles(-0.25,0,0)) * (subject.Velocity).Unit) * shakeCFrame
--	end)
--	
--	newShake:Start()
--	
	runSer:BindToRenderStep('Camera', 4, function(delta) 
		--newShake:Shake(shake.Presets.Vibration)
		
		local velocityAlpha = subject.Velocity.Magnitude / topVelc
		local desiredFov = (fovSpread * velocityAlpha) + fovMin
		cam.FieldOfView = desiredFov <= fovMax and desiredFov or fovMax
	end)


	return c
end

return Camera
