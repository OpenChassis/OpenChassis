local camera = game.Workspace.CurrentCamera
local uis = game:GetService('UserInputService')

local function normalize(x,y)
	if typeof(x) == 'Vector3' then
		y = x.Y
		x = x.X
	end
	
	local xHalf, yHalf = camera.ViewportSize.X/2, camera.ViewportSize.Y/2
	return  x - xHalf, -(y - yHalf)
end

local Input = {}

function Input:StartListening()
	local inBegan = uis.InputBegan:Connect(function(obj, gpe)
	
	end)

	local inChanged = uis.InputChanged:Connect(function(obj, gpe)
	
	end)

	local inEnded = uis.InputEnded:Connect(function(obj, gpe)
	
	end)
	
	local typeChanged = uis.LastInputTypeChanged:Connect(function(usInType)
		
	end)
	
	local function Disconnect()
		inBegan:Disconnect()
		inChanged:Disconnect()
		inEnded:Disconnect()
		typeChanged:Disconnect()
	end
	
	return {Disconnect = Disconnect}
end

return Input
