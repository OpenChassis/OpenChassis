--local gui = require(script.Gui)
local RadialGauge = require(script.RadialGauge)
local CarInterfaceGui = {}

local ran = Random.new()

function CarInterfaceGui:BuildGui(settings)
	
	local ocgui = game.Players.LocalPlayer.PlayerGui:WaitForChild('OpenChassisGui')
	
	local opts = {}
	opts.minDeg = 45
	opts.maxDeg = 315
	opts.minVal = 0
	opts.maxVal = math.ceil(settings.Redline / 1000) + 2
	opts.size = Vector2.new(250,250)
	opts.digitalLabel = " rpm"
    opts.tickerStyle = 'DottedDigital'
    opts.tickerCount = 20
    opts.warnCount = 6
	opts.scaleDigitalValue = 1000

	local tach = RadialGauge.new('tach', opts)
	tach.Frame.Parent = ocgui.Full
	tach.Frame.AnchorPoint = Vector2.new(.5,.5)
	tach.Frame.Position = UDim2.new(.38,0,.82,0)
	
	opts.minVal = 0
	opts.maxVal = 220
	opts.scaleDigitalValue = false
	opts.digitalLabel = ' mph'
	opts.tickerCount = 35
    opts.warnCount = 6
	opts.tickerStyle = 'TottedDigital'
	
	local speedo = RadialGauge.new('speedo', opts)
	speedo.Frame.Parent = ocgui.Full
	speedo.Frame.AnchorPoint = Vector2.new(.5,.5)
	speedo.Frame.Position = UDim2.new(.62,0,.82,0)
	
	local gear = Instance.new('TextLabel')
	gear.Parent = ocgui.Full
	gear.Name = 'Gear'
	gear.AnchorPoint = Vector2.new(.5,.5)
	gear.Position = UDim2.new(.5,0,.93,0)
	gear.Size = UDim2.new(0,45,0,45)
	gear.BackgroundTransparency = 1
	gear.TextColor3 = Color3.new(1,1,1)
	gear.FontSize = Enum.FontSize.Size32
	gear.Text = 'N'
	gear.TextStrokeTransparency = .5
	
	local debugGui = {}
	
	if settings._isDev == true then
		local debGui = Instance.new('Frame')
		debGui.Name = 'Debug'
		debGui.Size = UDim2.new(.65, 0, .4, 0)
		debGui.AnchorPoint = Vector2.new(.5,0)
		debGui.Position = UDim2.new(.5, 0, .1, 0)
		debGui.BackgroundTransparency = 1
		debGui.Parent = ocgui.Full
		
		opts.minVal = 0
		opts.maxVal = 100
		opts.digitalLabel = ' Throttle'
		opts.tickerStyle = 'TottedDigital'
		opts.warnCount = 1
		
		local throt = RadialGauge.new('gas', opts)
		throt.Frame.Name = 'Throttle'
		throt.Frame.AnchorPoint = Vector2.new(0,.5)
		throt.Frame.Position = UDim2.new(0,0,.3,0)
		throt.Frame.Parent = debGui
		
		opts.digitalLabel = ' Brake'
		local brake = RadialGauge.new('brakes', opts)
		brake.Frame.Name = 'Brakes'
		brake.Frame.AnchorPoint = Vector2.new(0.5,.5)
		brake.Frame.Position = UDim2.new(.5,0,.3,0)
		brake.Frame.Parent = debGui
		
		opts.digitalLabel = ' Clutch'
		local clutch = RadialGauge.new('clutch', opts)
		clutch.Frame.Name = 'Clutch'
		clutch.Frame.AnchorPoint = Vector2.new(1,.5)
		clutch.Frame.Position = UDim2.new(1,0,.3,0)
		clutch.Frame.Parent = debGui
		
		debugGui.Throttle = throt
		debugGui.Brakes   = brake
		debugGui.Clutch   = clutch
	end
	
	return tach, speedo, gear, debugGui
end

return CarInterfaceGui