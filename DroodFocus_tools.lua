----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - Tools
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

function DF:debugLine(variable,valeur)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(variable).." -> "..tostring(valeur))
end

function DF:numbers(valeur)
	return string.format("%u",math.ceil(valeur))
end

function DF:floatNumbers(valeur)
	return string.format("%.1f",valeur)
end

function DF:doubleNumbers(valeur)
	return string.format("%.2f",valeur)
end

function DF:minutes(valeur)
	local minute = math.floor(valeur/60)
	local seconde = valeur-(minute*60)
	local secondes = string.format("%u",seconde)
	if string.len(secondes)==1 then
		secondes="0"..secondes
	end
	return string.format("%u",minute)..":"..secondes
end

function DF:explode (seperator, str)
 	local pos, arr = 0, {}
	for st, sp in function() return string.find(str, seperator, pos, true) end do
		table.insert(arr, string.sub(str, pos, st-1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(str, pos))
	return arr
end

function DF:hasbit(x, p)
  return x % (p + p) >= p
end

function DF:setbit(x, p)
  return DF:hasbit(x, p) and x or x + p
end

function DF:clearbit(x, p)
  return DF:hasbit(x, p) and x - p or x
end

function DF:MySetFont(obj,path,size,mode)
	obj:SetFont(path,size,mode)
	local police = obj:GetFont()
	if not police then
		obj:SetFont("Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",size,mode)
	end
end

function DF:formatText(maxi,current,formatChaine)
	if maxi==0 then
		formatChaine=""
	else
		formatChaine=formatChaine:gsub("#m", DF:numbers(maxi))
		formatChaine=formatChaine:gsub("#c", DF:numbers(current))
		formatChaine=formatChaine:gsub("#p", DF:numbers((current/maxi)*100))

		formatChaine=formatChaine:gsub("#M", DF:doubleNumbers(maxi/1000))
		formatChaine=formatChaine:gsub("#C", DF:doubleNumbers(current/1000))
		formatChaine=formatChaine:gsub("#P", DF:floatNumbers((current/maxi)*100))
	end

	return formatChaine
end