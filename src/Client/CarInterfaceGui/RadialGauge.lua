local radialBuilder = require(script.RadialBuilder)

local function getDegOfVal(val, minVal, minDeg, valrange, degrange)
    val = val - minVal
    local rangePrecent = val / valrange
    local degPrecent = math.floor(degrange * rangePrecent)
    local deg = minDeg + degPrecent

    return deg
end

local RadialGauge = {}
RadialGauge.__index = RadialGauge


function  RadialGauge.new(name, options)
    local gauge = {}
    setmetatable(gauge, RadialGauge)

    local _minVal = options.minVal
    local _maxVal = options.maxVal
    local _valRange = _maxVal - _minVal

    local _minDeg = options.minDeg
    local _maxDeg = options.maxDeg
    local _degRange = _maxDeg - _minDeg

    local _tickerStyle = options.tickerStyle
    local _tickerCount = options.tickerCount

	local _scaleDigitalValue = options.scaleDigitalValue
	local _digitalLabel = options.digitalLabel or ''
	local _labelBefore = options.labelBefore or false

	local _tickerIncDeg = _degRange / _tickerCount

    local _warnCount = options.warnCount

	local _notWarnTicker = _maxDeg - (_warnCount * _tickerIncDeg)

    local _size = options.size
    local _gaugeRadius = _size.X

    gauge.Value = _minVal
    gauge.Frame = Instance.new('Frame')
    gauge.Frame.Name = name or 'RadialGauge'
    gauge.Frame.Size = UDim2.new(0,_size.X,0,_size.Y)
    gauge.Frame.BackgroundTransparency = 1
    
    local _tickerLines, _needle, _needleImg, _txtLabel = radialBuilder:BuildCircleGuage(gauge.Frame, _minDeg, _maxDeg,_minVal, _maxVal, _tickerCount, _tickerStyle, _gaugeRadius, _warnCount,_labelBefore, _digitalLabel)

    gauge._updateGui = function()
        
        local needleDeg = getDegOfVal(gauge.Value, _minVal, _minDeg, _valRange, _degRange)
        _needleImg.Rotation = needleDeg

        if _needleImg.Rotation > _notWarnTicker then
            if _needleImg.ImageColor3 == Color3.new(1,1,1) then
                _needleImg.ImageColor3 = Color3.new(1,0,0)
				if _txtLabel then
					_txtLabel.TextColor3 = Color3.new(1,0,0)
				end
            end
        else
            if _needleImg.ImageColor3 == Color3.new(1,0,0) then
                _needleImg.ImageColor3 = Color3.new(1,1,1)
					if _txtLabel then
					_txtLabel.TextColor3 = Color3.new(1,1,1)
				end
            end

        end

		local val

		if _txtLabel then
			if _scaleDigitalValue then
				val = math.floor(gauge.Value * _scaleDigitalValue)
			else
				val = gauge.Value
			end
			_txtLabel.Text = (_labelBefore == true and _digitalLabel .. val or val .. _digitalLabel)
		end
    end

    return gauge
end

function RadialGauge:Update(delta)
    self._updateGui()
end

function RadialGauge:Destroy()
	self.Frame:Destroy()
end

return RadialGauge