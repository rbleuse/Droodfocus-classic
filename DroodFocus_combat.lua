----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - combat
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

-- namespace
local DF = DF_namespace

local inCombat = false
local startTime = 0
local endTime = 0

function DF:combat_set_state(flag)
	if flag and not inCombat then
		startTime = DF.currentTime
		endTime = 0
	elseif not flag and inCombat then
		endTime = DF.currentTime
	end
	inCombat = flag
end

function DF:inCombat()
	return inCombat
end

function DF:combatTime()
	if (endTime > startTime) then
		return (endTime - startTime)
	else
		return 0
	end
end
