----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - talent
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

-- namespace
local DF = DF_namespace

-- calcul un checksum en fonction des talents
function DF:talent_getSpeChecksum()

	local checksum = 0;
	local numTabs = GetNumTalentTabs();
	local name="Unknow"
	local mini=0
	local total=0
	local pts=0
	local points=""
	
	for t=1, numTabs do

		local numTalents = GetNumTalents(t);
		
		total=0
		pts=0
		for i=1, numTalents do
			local nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(t,i)
			checksum = checksum + (currRank*i)
			total=total + (currRank*i)
			pts=pts+currRank
		end
    
    if points~="" then
    	points=points.."/"
    end
    points=points..tostring(pts)
    
    if total>mini then
    	name = GetTalentTabInfo(t);
			mini=total
    end
    
	end
	
	local letexte=DF.environnement["dfcurrenttalenttext"]
	local letexte2=DF.environnement["dfcurrenttalentconfigtext"]

	if letexte and DF.playerTalentName and DF.playerpoint then
		letexte:SetText("|cffffffff    Talent: "..DF.playerTalentName.." ("..tostring(DF.playerpoint)..")")
		letexte2:SetText("|cffffffff    Configuration: "..DF:talent_getSpeConfig(DF.playerTalent))	
	end

	return checksum,name,points

end

-- verifie si la spe existe dans le tableau
function DF:talent_speExist(spe)
	
	if DF_talents and DF_talents[spe] and DF_talents[spe]~="-" then
		return true
	else
		return false
	end

end

-- ajoute la configname pour cette spe
function DF:talent_setSpeConfig()
	
	DF_talents[DF.playerTalent]=DF_config.configname
	DF.environnement["dfcurrenttalentconfigtext"]:SetText("|cffffffff    Configuration: "..DF_config.configname)

end

-- ajoute la configname pour cette spe
function DF:talent_clearSpeConfig()
	
	DF_talents[DF.playerTalent]="-"
	DF.environnement["dfcurrenttalentconfigtext"]:SetText("|cffffffff    Configuration: -")

end

-- ajoute la configname pour cette spe
function DF:talent_getSpeConfig(spe)
	
	if DF_talents[spe] then 
		return DF_talents[spe]
	else
		return "-"
	end

end