local camera = game.Workspace.CurrentCamera
local uis    = game:GetService('UserInputService')

local keyboardSchema = require(script.KeyboardSchema)
local gamepadSchema = require(script.GamepadSchema)

local deadzone = .12

local function normalize(x,y)
	if typeof(x) == 'Vector2' or typeof(x) == 'Vector3' then
		y = x.Y
		x = x.X
	end
	
	local xHalf, yHalf = camera.ViewportSize.X/2, camera.ViewportSize.Y/2
	
	return  x - xHalf, -(y - yHalf)
end

local function checkInput(inputObj, keyCodes, inputTypes)
    local inputName = false
    local inputType = false

    for k, v in pairs(inputTypes) do
        if inputObj.UserInputType == k then
            inputName = v
        end
    end

    for k, v in pairs(keyCodes) do
        if inputObj.KeyCode == k then
            inputName = v 
        end
    end

    return inputName
end

local function washInputRes(res)
    if res == 'SteerLeft'  then

    elseif res == 'SteerRight' then

    end
end

------------------------------------------------------------------------

local Input = {}
Input.__index = Input

function Input.new(chassis) --, gamepadSchema, mobileSchema)
    local inpt = {}
    setmetatable(inpt, Input)

	inpt.Chassis = chassis

	inpt.CurrentPC      = keyboardSchema
	inpt.CurrentGamepad = gamepadSchema
--  inpt.CurrentMobile  = mobileSchema

    inpt._keyCodes = {}
    inpt._inputTypes = {}

	local function addToEnumList(schema)
		for k, v in pairs(schema) do 
	        if v.EnumType == Enum.UserInputType then
	            inpt._inputTypes[v] = k
	        elseif v.EnumType == Enum.KeyCode then
	            inpt._keyCodes[v] = k
	        end
    	end
	end

    addToEnumList(inpt.CurrentPC)
	addToEnumList(inpt.CurrentGamepad)

    return inpt
end

function Input:_handler(inputObj, gpe)
    local throt, brake, secbrake, steer = 0, 0, 0, 0

    if gpe and not (inputObj.UserInputType == Enum.UserInputType.Gamepad1) then
        return
    end

    local inputName = checkInput(inputObj, self._keyCodes, self._inputTypes)

    if inputName == 'GearUp' or inputName == 'GearDown' or inputName == 'ToggleLights' then
        if inputObj.UserInputState == Enum.UserInputState.Begin then
            self.Chassis[inputName]()

        end
    elseif inputName == 'SteerLeft' or inputName == 'SteerRight' then
        if inputObj.UserInputType == Enum.UserInputType.Gamepad1 then

            if inputObj.UserInputState == Enum.UserInputState.End then
                self.Chassis.Steering = 0
			else
				if math.abs(inputObj.Position.X) <= deadzone then
					self.Chassis.Steering = 0 
				else
					self.Chassis.Steering = -inputObj.Position.X
				end
            end
        elseif inputObj.UserInputType == Enum.UserInputType.Keyboard then
            if inputObj.UserInputState == Enum.UserInputState.End then
                self.Chassis.Steering = 0
            elseif inputObj.UserInputState == Enum.UserInputState.Begin then
                if inputName == 'SteerLeft' then
                    self.Chassis.Steering = 1
                elseif inputName == 'SteerRight' then
                    self.Chassis.Steering = -1
                end
            end
        end
    elseif inputName == 'Throttle' or inputName == 'Brakes' then
        if inputObj.UserInputType == Enum.UserInputType.Gamepad1 then
            if inputObj.UserInputState == Enum.UserInputState.Begin then
                self.Chassis[inputName] = inputObj.Position.Z
            elseif inputObj.UserInputState == Enum.UserInputState.End then
                self.Chassis[inputName] = 0 
            end
        elseif inputObj.UserInputType == Enum.UserInputType.Keyboard then
            if inputObj.UserInputState == Enum.UserInputState.Begin then
                self.Chassis[inputName] = 1 
            elseif inputObj.UserInputState == Enum.UserInputState.End then
                self.Chassis[inputName] = 0
            end
        end
    else
        if inputObj.UserInputState == Enum.UserInputState.Begin then
            self.Chassis[inputName] = 1 
        elseif inputObj.UserInputState == Enum.UserInputState.End then
            self.Chassis[inputName] = 0
        end
    end
end


function Input:StartListening()
    local inBegan = uis.InputBegan:Connect(function(inputObj, gpe)
        self:_handler(inputObj, gpe)
    end)

    local inChanged = uis.InputChanged:Connect(function(inputObj, gpe)
        self:_handler(inputObj, gpe)
    end)

    local inEnded = uis.InputEnded:Connect(function(inputObj, gpe)
        self:_handler(inputObj, gpe)
    end)

--	local typeChanged = uis.LastInputTypeChanged:Connect(function(usInType)
--		
--	end)
	
	local function Disconnect()
		inBegan:Disconnect()
		inChanged:Disconnect()
		inEnded:Disconnect()
--		typeChanged:Disconnect()
	end
	
	return {Disconnect = Disconnect}
end

return Input