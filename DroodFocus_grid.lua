----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - Grid
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

function DF:alignToGridX(value)
	if DF_config.alignToGrid then
		local newValue = math.ceil(value/DF_config.gridSizeX)*DF_config.gridSizeX
		return newValue
	else
		return value
	end
end

function DF:alignToGridY(value)
	if DF_config.alignToGrid then
		local newValue = math.ceil(value/DF_config.gridSizeY)*DF_config.gridSizeY
		return newValue
	else
		return value
	end
end