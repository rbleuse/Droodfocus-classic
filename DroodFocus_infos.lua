----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - infos
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 2
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frame
local frameTexts={}
local frameTexture=nil

-- initialisation frames
function DF:init_infos_frame()
	if not frame then
		-- cadre principal
		frame = CreateFrame("FRAME","DF_INFOS_FRAME",DF.anchor[5].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button == "RightButton" then
				DF:options_show("infos",frame)
			end
		end)
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS INFOS",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()
			end
		end)
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)

		frameTexts = frame:CreateFontString("DF_INFOSTEXT","ARTWORK")

		frameTexture = frame:CreateTexture(nil,"BACKGROUND")

		frame:EnableMouse(false)
	end

	local level = DF_config.infos.level*10

	-- paramétres cadre principal
	frame:SetMovable(false)
	frame:SetWidth(96)
	frame:SetHeight(64)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[5].frame, "TOPLEFT", 8, -8)
	frame:SetFrameLevel(level)

	-- paramétres texture
	frameTexture:SetTexCoord(0, 1, 0, 1)
	frameTexture:ClearAllPoints()
	frameTexture:SetAllPoints(frame)

	DF:MySetFont(frameTexts,DF_config.infos.fontPath,DF_config.infos.fontSize,"OUTLINE")
	frameTexts:SetNonSpaceWrap(true) 
	frameTexts:SetShadowColor(0, 0, 0, 0.75)
	frameTexts:SetShadowOffset(0.5, -0.5)
	frameTexts:SetTextColor(DF_config.infos.textColor.r, DF_config.infos.textColor.v, DF_config.infos.textColor.b, DF_config.infos.textColor.a)
	frameTexts:ClearAllPoints()
	frameTexts:SetPoint("TOPLEFT", frame,"TOPLEFT", 0, 0)
	frameTexts:SetText(DF:infos_getInfos())
	frameTexts:SetJustifyH("LEFT")
	frame:SetWidth(frameTexts:GetStringWidth()+4)
	frame:SetHeight(frameTexts:GetStringHeight()+4)

	frameTexture:SetColorTexture(DF_config.infos.backColor.r, DF_config.infos.backColor.v, DF_config.infos.backColor.b, DF_config.infos.backColor.a)

	if not DF_config.infos.enable then
		frame:Hide()
	else
		frame:Show()
	end
end

local function getPowerAttack()
	local puissance = DF:spell_getPowerAttack()
	return DF:numbers(puissance)
end

local function getRangedAttack()
	local base, posBuff, negBuff = UnitRangedAttackPower("player")
	local puissance = base + posBuff + negBuff
	return DF:numbers(puissance)
end

local function getMeleeCrit()
	local crit = GetCritChance()
	return DF:doubleNumbers(crit).."%%"
end

local function getRangedCrit()
	local crit = GetRangedCritChance()
	return DF:doubleNumbers(crit).."%%"
end

local function getMeleeHit()
	local hit = GetCombatRatingBonus(CR_HIT_MELEE)
	return DF:doubleNumbers(hit).."%%"
end

local function getRangedHit()
	local hit =GetCombatRatingBonus(CR_HIT_RANGED)
	return DF:doubleNumbers(hit).."%%"
end

local function getExpertise()
	local expertise=GetExpertise()*0.25
	return DF:doubleNumbers(expertise).."%"
end

local function getMeleeHaste()
	return DF:doubleNumbers(GetCombatRatingBonus(CR_HASTE_MELEE)).."%%"
end

local function getRangedHaste()
	return DF:doubleNumbers(GetCombatRatingBonus(CR_HASTE_RANGED)).."%%"
end

local function getArmorPen()
	return DF:doubleNumbers(GetArmorPenetration()).."%%"
end

local function getArmor()
	local _, effectiveArmor = UnitArmor("player")
	return DF:numbers(effectiveArmor)
end

local function getDodge()
	return DF:doubleNumbers(GetDodgeChance()).."%%"
end

local function getParry()
	return DF:doubleNumbers(GetParryChance()).."%%"
end

function DF:infos_getInfos()
	local formatChaine = DF_config.infos.infolines

	formatChaine=formatChaine:gsub("#meleeAP", getPowerAttack())
	formatChaine=formatChaine:gsub("#rangedAP", getRangedAttack())

	formatChaine=formatChaine:gsub("#meleeCrit", getMeleeCrit())
	formatChaine=formatChaine:gsub("#rangedCrit", getRangedCrit())

	formatChaine=formatChaine:gsub("#meleeHit", getMeleeHit())
	formatChaine=formatChaine:gsub("#rangedHit", getRangedHit())

	formatChaine=formatChaine:gsub("#dodge", getDodge())
	formatChaine=formatChaine:gsub("#parry", getParry())

	formatChaine=formatChaine:gsub("#meleeHaste", getMeleeHaste())
	formatChaine=formatChaine:gsub("#rangedHaste", getRangedHaste())

	formatChaine=formatChaine:gsub("#expertise", getExpertise())
	formatChaine=formatChaine:gsub("#armPen", getArmorPen())
	formatChaine=formatChaine:gsub("#armor", getArmor())

	formatChaine=formatChaine:gsub("*", "|n")

	return formatChaine
end

-- gestion de l'animation
function DF:infos_update()
	if not DF_config.infos.enable then return end

	frameTexts:ClearAllPoints()
	frameTexts:SetText(DF:infos_getInfos())
	frame:SetWidth(frameTexts:GetStringWidth()+4)
	frame:SetHeight(frameTexts:GetStringHeight()+4)
	frameTexts:SetPoint("TOPLEFT", frame,"TOPLEFT", 0, 0)
end

-- enable/disable déplacement du cadre avec la souris
function DF:infos_toogle_lock(flag)
	frame:EnableMouse(flag)
end


function DF:infos_reinit()
	DF:init_infos_frame()
end