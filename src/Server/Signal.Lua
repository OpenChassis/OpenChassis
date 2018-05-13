-- closure scoping reimplement of https://github.com/LPGhatguy/lemur/blob/master/lib/Signal.lua
local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	
	local boundCallbacks = {}
	
	local function listInsert(list, ...)
		local args = {...}
		local newList = {}
		local listLen = #list
		
		for i = 1, listLen do
			newList[i] = list[i]
		end
		
		for i = 1, #args do
			newList[listLen + i] = args[i]
		end
		
		return newList
	end
	
	local function listValueRemove(list, value)
		local newList = {}

		for i = 1, #list do
			if list[i] ~= value then
				table.insert(newList, list[i])
			end
		end
		
		return newList
	end

	
	function self:Connect(cb)

		boundCallbacks = listInsert(boundCallbacks, cb)

		local function disconnect()
			boundCallbacks = listValueRemove(boundCallbacks, cb)
		end
		
		return {Disconnect = disconnect}
	end
	
	
	function self:Fire(...)
		print(#boundCallbacks)
		for i = 1, #boundCallbacks do
			boundCallbacks[i](...)
		end
	end
	
	return self
end


return Signal
