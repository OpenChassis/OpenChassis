local factory = require(game.ServerScriptService:WaitForChild('Server').Factory)
local car = game.ReplicatedStorage.Dummy
local settings = require(car.Settings)

local event = game.ReplicatedStorage:WaitForChild('Events'):WaitForChild('OCEvent')

local players = game:GetService('Players')

local function giveCar(player)
	if not player.Character then
		repeat wait(.1) until player.Character
	end
	local newCar = car:Clone()
	newCar.Parent = game.Workspace
	local playerCar = factory.NewChassis(settings,newCar, player)
	event:FireClient(player, 'StartDriving', playerCar.GetId())
	if not player.Character:FindFirstChild('Humanoid') then
		repeat wait(1) until player.Character:FindFirstChild('Humanoid') 
	end
--	player.Character:ClearAllChildren()
end

for _,p in pairs(players:GetPlayers()) do
	giveCar(p)
end

players.PlayerAdded:Connect(giveCar)
