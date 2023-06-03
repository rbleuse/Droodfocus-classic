----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - cooldown
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frame=nil
local frameTexture=nil

local cdicons={
	{frame=nil,overlay=nil,texture=nil,state=0,scale=1},
	{frame=nil,overlay=nil,texture=nil,state=0,scale=1},
	{frame=nil,overlay=nil,texture=nil,state=0,scale=1},
	{frame=nil,overlay=nil,texture=nil,state=0,scale=1},
}

local cooldown_table={}
local icooldown_table={}

-- initialisation frames
function DF:init_cooldown_frame()
	if not frame then
		-- cadre principal
		frame = CreateFrame("FRAME","DF_cooldown_FRAME",DF.anchor[6].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button == "RightButton" then
				DF:options_show("cooldown",frame)
			end
		end)
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS COOLDOWN",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()
			end
		end)
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)

		-- icones
		for i = 1,4 do
			cdicons[i].frame = CreateFrame("FRAME","DF_cooldown_FRAME_"..tostring(i),frame)
			cdicons[i].overlay = CreateFrame("FRAME","DF_cooldown_overlay"..tostring(i),cdicons[i].frame)
			cdicons[i].texture = cdicons[i].overlay:CreateTexture(nil,"BACKGROUND")
			cdicons[i].frame:EnableMouse(false)
		end
		frame:EnableMouse(false)
		frameTexture = frame:CreateTexture(nil,"BACKGROUND")
	end

	local level = DF_config.cooldown.level*10

	-- paramétres cadre principal
	frame:SetMovable(true)
	frame:SetWidth(DF_config.cooldown.width+8)
	frame:SetHeight(DF_config.cooldown.height+8)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[6].frame, "TOPLEFT", 0, 0)
	frame:SetFrameLevel(level)

	-- paramétres texture
	frameTexture:SetTexCoord(0, 1, 0, 1)
	frameTexture:ClearAllPoints()
	frameTexture:SetAllPoints(frame)

	if DF.configmode then
		frameTexture:SetColorTexture(1,1,1,0.25)
	else
		frameTexture:SetColorTexture(1,1,1,0)
	end

	-- paramétres background
	for i = 1,4 do
		cdicons[i].frame:SetWidth(DF_config.cooldown.width)
		cdicons[i].frame:SetHeight(DF_config.cooldown.height)
		cdicons[i].frame:ClearAllPoints()
		cdicons[i].frame:SetPoint("CENTER", frame, "CENTER", (i-1)*DF_config.cooldown.offsetx, -((i-1)*DF_config.cooldown.offsety))
		cdicons[i].frame:SetAlpha(DF_config.cooldown.alpha)

		cdicons[i].overlay:SetWidth(DF_config.cooldown.width)
		cdicons[i].overlay:SetHeight(DF_config.cooldown.height)
		cdicons[i].overlay:SetPoint("CENTER", cdicons[i].frame, "CENTER", 0, 0)
		cdicons[i].overlay:SetFrameLevel(level+i)

		cdicons[i].texture:SetTexCoord(0, 1, 0,1)
		cdicons[i].texture:SetWidth(32)
		cdicons[i].texture:SetHeight(32)
		cdicons[i].texture:SetAllPoints(cdicons[i].overlay)
		cdicons[i].texture:SetTexture("Interface\\icons\\INV_Misc_QuestionMark")
		cdicons[i].texture:SetBlendMode(DF_config.cooldown.mode)

		cdicons[i].overlay.texture = cdicons[i].texture
	end

	if not DF_config.cooldown.enable then
		for i = 1,4 do
			cdicons[i].overlay:Hide()
		end
	else
		for i = 1,4 do
			cdicons[i].overlay:Show()
		end
	end
end

-- gestion de l'animation
function DF:cooldown_update()

	if DF.configmode then
		frameTexture:SetColorTexture(1,1,1,0.25)
	else
		frameTexture:SetColorTexture(1,1,1,0)
	end

	if not DF_config.cooldown.enable then
		for i = 1,4 do
			cdicons[i].overlay:Hide()
		end
		return
	end

	DF:cooldown_check()

	for i = 1,4 do

		if cdicons[i].state == 1 then
			cdicons[i].scale  = cdicons[i].scale  - 0.075

			local tempScale=cdicons[i].scale

			if tempScale>1 then tempScale=1 end
			if tempScale<0.1 then
				tempScale=0.1
				cdicons[i].state=0
			end

			cdicons[i].overlay:SetScale(tempScale)
			cdicons[i].overlay:Show()
		elseif cdicons[i].state==2 then
			cdicons[i].scale  = cdicons[i].scale  - 0.025

			cdicons[i].overlay:SetScale(cdicons[i].scale)
			cdicons[i].overlay:Show()

			if	cdicons[i].scale<1 then
				cdicons[i].scale=10
				cdicons[i].state=1
			end
		else
			cdicons[i].overlay:Hide()
		end

		if DF.configmode then
			cdicons[i].texture:SetTexture("Interface\\icons\\INV_Misc_QuestionMark")
			cdicons[i].overlay:SetScale(1)
			cdicons[i].overlay:Show()
		end
	end
end

function DF:cooldown_activate(texture)
	for i = 1,4 do
		if cdicons[i].state==0 then
			cdicons[i].state=2
			cdicons[i].scale=1.5
			cdicons[i].texture:SetTexture(texture)
			break
		end
	end
end

-- enable/disable déplacement du cadre avec la souris
function DF:cooldown_toogle_lock(flag)
	frame:EnableMouse(flag)
end

function DF:cooldown_reinit()
	DF:init_cooldown_frame()
end

function DF:cooldown_initTable()
	if cooldown_table then
		cooldown_table=table.wipe(cooldown_table)
	end

	for i = 1, GetNumSpellTabs() do
		local name, _, offset, numSpells = GetSpellTabInfo(i)

		if not name then
			break
		end

		for s = offset + 1, offset + numSpells do

			local spell, _ = GetSpellBookItemName(s, BOOKTYPE_SPELL)

			if (not IsPassiveSpell(s, BOOKTYPE_SPELL) and not cooldown_table[spell]) then
				cooldown_table[spell]={}
				cooldown_table[spell].active=false
				cooldown_table[spell].debut=-1
				cooldown_table[spell].duree=0
			end
		end
	end
end

function DF:cooldown_check()

	if not DF_config.cooldown.enable then return end

	for index, _ in pairs(cooldown_table) do
		local cdstart, cdduration, _ = GetSpellCooldown(index)
		if (cdstart and cdstart > 0 and cdduration>2) then
			-- sous CD
			if not cooldown_table[index].active then
				cooldown_table[index].debut=cdstart
				cooldown_table[index].duree=cdduration
				cooldown_table[index].active=true
			end
		else
			-- pas sous CD
			-- si abilites précédemment enregistrée sous CD, pulse
			if cooldown_table[index].active then
				-- enregistre "plus sous CD" et pulse
				cooldown_table[index].active=false
				local texture = GetSpellTexture(index)
				DF:cooldown_activate(texture)
			end
		end
	end
end

function DF:cooldown_addCD(index,cdstart,cdduration)
	if icooldown_table[index]==nil then
		icooldown_table[index]={}
	end
	icooldown_table[index].debut=cdstart
	icooldown_table[index].duree=cdduration
end

function DF:cooldown_getCD(name,id)
	if cooldown_table[name] then
		if cooldown_table[name].debut~=-1 then
			return cooldown_table[name].debut,cooldown_table[name].duree
		elseif icooldown_table[id] then
			return icooldown_table[id].debut,icooldown_table[id].duree
		end
	elseif icooldown_table[id] then
		return icooldown_table[id].debut,icooldown_table[id].duree
	end

	return 0,0
end