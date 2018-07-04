local server = script.Parent.Server
local client = script.Parent.Client
local share = script.Parent.Shared

if not game.ServerScriptService:FindFirstChild('Server') then
	server.Parent = game.ServerScriptService
else
	server:Destroy()
end

if not game.StarterPlayer.StarterPlayerScripts:FindFirstChild('Client') then
	
	for _, v in pairs(game.Players:GetPlayers()) do
		client:Clone().Parent = v.PlayerScripts
	end
	
	client.Parent = game.StarterPlayer.StarterPlayerScripts
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

script.Parent:Destroy()