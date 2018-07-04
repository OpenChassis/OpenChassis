local frame = Instance.new("Frame")
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.new(1,1,1)

local txt = Instance.new('TextLabel')	
txt.AnchorPoint = Vector2.new(.5,.5)
txt.BackgroundTransparency = 1
txt.Size = UDim2.new(0,150,0,50)
txt.FontSize = Enum.FontSize.Size18
txt.TextColor3 = Color3.new(1,1,1)
txt.TextStrokeTransparency = .6

local function getSingleTicker(i, radius, color3)
	local l = frame:Clone()
	l.Name = 'Visual' .. i
	l.Position = UDim2.new(0,0,0,(radius/2) + 18)
	l.Size = UDim2.new(0,4,0,18)
	l.AnchorPoint = Vector2.new(.5,1)
	l.BackgroundColor3 = color3
	
	return l
end

local function getSmallerTicker(i, radius, color3)
	local l = getSingleTicker(i, radius, color3)
	l.Size = UDim2.new(0,4,0,6)

	return l
end

local function getDoubleTicker(i, radius, color3)
    local f = frame:Clone()
    f.Size = UDim2.new(0,0,0,0)

    local l = getSingleTicker(i, radius, color3)
    l.AnchorPoint = Vector2.new(0,0)
    l.Parent = f
	l.Position = UDim2.new(0,0,0,(radius/2))
	
    local s = l:Clone()
    s.AnchorPoint = Vector2.new(1.2,0)
	s.Position = UDim2.new(0,0,0,(radius/2) + 3 + s.Size.Y.Offset / 2)
    s.Size = UDim2.new(0,6,0,6)
	s.BackgroundColor3 = color3
    s.Parent = f

    return f
end

local function getLabeledTicker(i, radius, color3, label)
	local l = getSingleTicker(i, radius, color3)

	local txtBox = txt:Clone()
	txtBox.Parent = l
	txtBox.Position = UDim2.new(0,0,.9,0)
	txtBox.Text = label or i

	return l
end

local RadialBuilder = {}

function RadialBuilder:BuildCircleGuage(gaugeFrame, minRot, maxRot, minVal , maxVal, count, style, radius, warnCount, labelBefore, label)
	
	-- some state
	local stylePrefix = string.sub(style, 1, 6)
	local styleSuffix = string.sub(style, 7, #style)

	------------ build ticker lines ------------
	local linesFrame = frame:Clone()
	linesFrame.Position = UDim2.new(.5,0,.5,0)
	linesFrame.Size = UDim2.new(0,0,0,0)
	linesFrame.Parent = gaugeFrame
	linesFrame.BackgroundTransparency = 1
    linesFrame.Name = 'TickerLines'
	
    local range = maxRot - minRot
    local inc = range / count 

	local redColor = Color3.new(1,0,0)
	local whiteColor = Color3.new(1,1,1)
	
	for i = 1, count + 1 do
		local f = frame:Clone()
        f.Parent = linesFrame
        f.AnchorPoint = Vector2.new(.5,.5)
		f.Position = UDim2.new(0,0,0,0)
		f.Size = UDim2.new(0,0,0,0)
        f.Rotation = (inc * i) + (minRot - inc)
		f.Name = 'Line' .. i
		
		local l
		
		if stylePrefix == 'Single' then 
			l = getSingleTicker(i, radius, i > count - warnCount and redColor or whiteColor) 
		elseif stylePrefix == 'Double' then
			l = getDoubleTicker(i, radius, i > count - warnCount and redColor or whiteColor)
		elseif stylePrefix == 'Dotted' then
			if i%2 == 1 then
				l = getSingleTicker(i, radius, i > count - warnCount and redColor or whiteColor)
			else
				l = getSmallerTicker(i, radius, i > count - warnCount and redColor or whiteColor)
			end
		elseif stylePrefix == 'Totted' then
			if i%3 == 0 then
				l = getSingleTicker(i, radius, i > count - warnCount and redColor or whiteColor)
			else
				l = getSmallerTicker(i, radius, i > count - warnCount and redColor or whiteColor)
			end
		end
		l.Parent = f
	end
	
	------------ build needle ------------
	local nf = frame:Clone()
	nf.Name = 'NeedleFrame'
    nf.AnchorPoint = Vector2.new(.5,.5)
    nf.Position = UDim2.new(.5,0,.5,0)
    nf.BackgroundTransparency = 1
	nf.Parent = gaugeFrame
	nf.Rotation = 180
    nf.Size = UDim2.new(0.025, 0,.99, 0)
    
    local img = Instance.new('ImageLabel')
    img.Name = 'Needle'
    img.Parent = nf
    img.Size = UDim2.new(1, 0, 1, 0)
    img.Rotation = minRot
	img.BackgroundTransparency = 1
	img.Image = 'rbxassetid://1932853783'

	------------ build labels ------------
	local txtBox = false
	if styleSuffix == 'Digital' then
		txtBox = txt:Clone()
		
		txtBox.Name = 'DigitalValue'
		txtBox.AnchorPoint = Vector2.new(.5,.5)
		txtBox.Position = UDim2.new(.5,0,.85,0)
		txtBox.Parent = gaugeFrame
		if labelBefore then
			txtBox.Text = label .. minVal
		else
			txtBox.Text = minVal .. label
		end
	end

	return linesFrame, nf, img, txtBox
end

return RadialBuilder