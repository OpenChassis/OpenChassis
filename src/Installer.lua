-- server script child of OpenChassis folder

local server = script.Parent.Server
local client = script.Parent.Client
local share = script.Parent.Shared

if not game.ServerScriptService:FindFirstChild('Server') then
	server.Parent = game.ServerScriptService
else
	server:Destroy()
end

if not game.StarterPlayer.StarterPlayerScripts:FindFirstChild('Client') then
	client:Clone().Parent = game.StarterPlayer.StarterPlayerScripts
	
	for _, v in pairs(game.Players:GetPlayers()) do
		client:Clone().Parent = v.PlayerScripts
	end
	
else
	client:Destroy()
end

if not game.ReplicatedStorage:FindFirstChild('Shared') then
	share.Parent = game.ReplicatedStorage
else
	share:Destroy()
end

if not game.ReplicatedStorage:FindFirstChild('Events') then
	local events = Instance.new("Folder")
	events.Name = 'Events'
	events.Parent = game.ReplicatedStorage
	
	local event = Instance.new('RemoteEvent')
	event.Name = 'OCEvent'
	event.Parent = events
end

wait(2)

script:Destroy()
