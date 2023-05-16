﻿----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - combo
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 3
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frame = nil
local frameTexture = nil

local frequency = 1 / 60
local tempo = (frequency / 15) * 2

local combos={
	{frame=nil,overlay=nil,texture=nil,scale=1,sTexture=nil,state=0},
	{frame=nil,overlay=nil,texture=nil,scale=1,sTexture=nil,state=0},
	{frame=nil,overlay=nil,texture=nil,scale=1,sTexture=nil,state=0},
	{frame=nil,overlay=nil,texture=nil,scale=1,sTexture=nil,state=0},
	{frame=nil,overlay=nil,texture=nil,scale=1,sTexture=nil,state=0},
	{frame=nil,overlay=nil,texture=nil,scale=1,sTexture=nil,state=0},
}

local frametext=nil
local frametextTexture=nil
local frametextzoom=nil

local combotext = nil

-- offsets
-- 1 invisible
-- 2 point inactif
-- 3 point actif chat/rogue 1 à 4
-- 4 point actif chat/rogue 5
-- 5 point actif ours 1 à 4
-- 6 point actif ours 5
-- 7
-- 8
local offsets={0,1,2,4,3,5}

local comboPts = 0

-- initialisation frames
function DF:init_combo_frame()
	if not frame then
		-- cadre principal
		frame = CreateFrame("FRAME","DF_COMBO_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button == "LeftButton" then
				frame:StartMoving()
			elseif button == "RightButton" then
				DF:options_show("combo", frame)
			end
		end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
				frame:StopMovingOrSizing()
				local anchorx=DF.anchor[1].frame:GetLeft()
				local anchory=DF.anchor[1].frame:GetTop()
				DF_config.combo.positionx=self:GetLeft()-anchorx
				DF_config.combo.positiony=self:GetTop()-anchory
				frame:ClearAllPoints()
				frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.combo.positionx, DF_config.combo.positiony)
				DF.environnement["comboleft"]:Hide()
				DF.environnement["combotop"]:Hide()
				DF.environnement["comboleft"]:Show()
				DF.environnement["combotop"]:Show()
			end
		end)
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS COMBO",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end
		end)
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)

		frametext = CreateFrame("FRAME","DF_COMBO_FRAMETEXT",DF.anchor[1].frame)
		frametext:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
  			frametext:StartMoving()
  		elseif button=="RightButton" then
  			DF:options_show("combo",frame)
  		end
		end)
		frametext:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
	  		frametext:StopMovingOrSizing()
	  		local anchorx=DF.anchor[1].frame:GetLeft()
	  		local anchory=DF.anchor[1].frame:GetTop()
	  		DF_config.combo.textOffsetX=self:GetLeft()-anchorx
	  		DF_config.combo.textOffsetY=self:GetTop()-anchory
	  		frametext:ClearAllPoints()
	  		frametext:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.combo.textOffsetX, DF_config.combo.textOffsetY)
		  end
		end)
		frametext:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS COMBOTEXT",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()
			end
		end)
		frametext:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)

		-- points de combo
		for i = 1,6 do
			combos[i].frame = CreateFrame("FRAME","DF_COMBO_FRAME_"..tostring(i),frame)
			combos[i].overlay = CreateFrame("FRAME","DF_COMBO_"..tostring(i),combos[i].frame)
			combos[i].texture = combos[i].overlay:CreateTexture("DF_COMBO_TEXTURE"..tostring(i),"BACKGROUND")
			combos[i].frame:EnableMouse(false)
		end
		frame:EnableMouse(false)
		frametext:EnableMouse(false)
		frameTexture = frame:CreateTexture("DF_COMBO_FRAME_texture","BACKGROUND")

		frametextzoom = CreateFrame("FRAME","DF_COMBO_FRAMETEXTZOOM",frametext)
		combotext = frametextzoom:CreateFontString("DF_COMBOTEXT","ARTWORK")
		frametextTexture = frametext:CreateTexture("DF_COMBO_FRAME_TEXTURE","BACKGROUND")
	end

	local level = DF_config.combo.level*10

	-- paramétres cadre principal
	frame:SetMovable(true)
	frame:EnableMouse(false)
	frame:SetWidth(DF_config.combo.width+8)
	frame:SetHeight(DF_config.combo.height+8)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.combo.positionx, DF_config.combo.positiony)
	frame:SetFrameLevel(level)

	frametextzoom:SetMovable(false)
	frametextzoom:EnableMouse(false)
	frametextzoom:SetWidth(32)
	frametextzoom:SetHeight(32)
	frametextzoom:ClearAllPoints()
	frametextzoom:SetPoint("CENTER", frametext, "CENTER", 0, 0)
	frametextzoom:SetFrameLevel(level+7)

	frametext:SetMovable(true)
	frametext:EnableMouse(false)
	frametext:SetWidth(32)
	frametext:SetHeight(32)
	frametext:ClearAllPoints()
	frametext:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.combo.textOffsetX, DF_config.combo.textOffsetY)
	frametext:SetFrameLevel(level+7)

	-- paramétres texture
	frameTexture:SetTexCoord(0, 1, 0, 1)
	frameTexture:ClearAllPoints()
	frameTexture:SetAllPoints(frame)

	frameTexture:SetColorTexture(1,1,1,0)

	frametextTexture:SetTexCoord(0, 1, 0, 1)
	frametextTexture:ClearAllPoints()
	frametextTexture:SetAllPoints(frametext)

	frametextTexture:SetColorTexture(1,1,1,0)

	-- paramétres background
	for i = 1,6 do
		combos[i].frame:SetWidth(DF_config.combo.width)
		combos[i].frame:SetHeight(DF_config.combo.height)
		combos[i].frame:ClearAllPoints()
		combos[i].frame:SetPoint("CENTER", frame, "CENTER", (i-1)*DF_config.combo.offsetx, -((i-1)*DF_config.combo.offsety))
		combos[i].frame:SetFrameLevel(level+i)

		combos[i].overlay:SetWidth(DF_config.combo.width)
		combos[i].overlay:SetHeight(DF_config.combo.height)
		combos[i].overlay:SetPoint("CENTER", combos[i].frame, "CENTER", 0, 0)
		combos[i].overlay:SetFrameLevel(level+i)

		combos[i].texture:SetTexCoord(0, 1, 0, 1)
		combos[i].texture:SetWidth(32)
		combos[i].texture:SetHeight(32)
		combos[i].texture:SetAllPoints(combos[i].overlay)
		combos[i].texture:SetTexture(DF_config.combo.texturePath)
		combos[i].texture:SetBlendMode("BLEND")

		combos[i].overlay.texture = combos[i].texture
	end

	if DF_config.combo.ptype==1 then
		for i = 1,6 do
			combos[i].frame:ClearAllPoints()
			combos[i].frame:SetPoint("CENTER", frame, "CENTER", (i-1)*DF_config.combo.offsetx, -((i-1)*DF_config.combo.offsety))
		end
	else
		local angleA=DF_config.combo.angleA
		local angleB=DF_config.combo.angleB
		local pas = (angleB-angleA)/5

		for i = 1,6 do
			local px=DF_config.combo.rayon*math.cos(angleA/180*math.pi)
			local py=DF_config.combo.rayon*math.sin(angleA/180*math.pi)

			combos[i].frame:ClearAllPoints()
			combos[i].frame:SetPoint("CENTER", frame, "CENTER", px, -py)

			angleA=angleA+pas
		end
	end

	DF:MySetFont(combotext,DF_config.combo.fontPath,DF_config.combo.fontSize,"OUTLINE")
	combotext:SetWidth(64)
	combotext:SetHeight(64)	
	combotext:SetJustifyH('CENTER')
	combotext:SetJustifyV('MIDDLE')	
	combotext:SetShadowColor(0, 0, 0, 0.75)
	combotext:SetShadowOffset(0.5, -0.5)
	combotext:SetTextColor(DF_config.combo.textColor.r, DF_config.combo.textColor.v, DF_config.combo.textColor.b, DF_config.combo.textColor.a)
	combotext:ClearAllPoints()
	combotext:SetPoint("CENTER", frametextzoom,"CENTER", 0,0)
	combotext:SetText("")

	if not DF_config.combo.enable then
		for i = 1,6 do combos[i].overlay:Hide() end
	end

	if not DF_config.combo.showText then
		frametext:Hide()
	else
		frametext:Show()
	end
end

function DF:combo_toggle()
	if DF.playerClass=="DRUID" or DF.playerClass=="ROGUE" then
		combos[6].state=-1
	end
end

-- gestion de l'animation
function DF:combo_update(elapsed)

	if not DF_config.combo.enable then
		for i = 1,6 do combos[i].overlay:Hide() end
		return
	end

	tempo=tempo+elapsed
	if tempo<frequency then return end
	tempo=0

	if (DF.configmode) then
		frameTexture:SetColorTexture(1,1,1,0.25)
		frametextTexture:SetColorTexture(1,1,1,0.25)
	else
		frameTexture:SetColorTexture(1,1,1,0)
		frametextTexture:SetColorTexture(1,1,1,0)
	end

	local currentForm = DF:currentForm()
	local c = 0
	local multiple=1

	DF:combo_toggle()

	if not DF:form_goofForm(DF_config.combo.form,currentForm) then
		for i = 1,6 do combos[i].overlay:Hide() end
		return
	else
		for i = 1,6 do
			if combos[i].state==-1 then
				combos[i].overlay:Hide()
			else
				combos[i].overlay:Show()
			end
		end
	end

-- 1 invisible
-- 2 point inactif
-- 3 point actif chat/rogue 1 à 4
-- 4 point actif chat/rogue 5
-- 5 point actif ours 1 à 4
-- 6 point actif ours 5

	if ((DF.playerClass == "DRUID" and currentForm == 3) or DF.playerClass == "ROGUE") then

		c = GetComboPoints("player", "target")
		if not c or c == nil then
			c = 0
		end

		if DF_config.combo.showText and ((c and c > 0) or DF.configmode) then
			if not DF.configmode then
				combotext:SetText(tostring(c))
			else
				combotext:SetText("5")
			end
		else
			combotext:SetText("")
		end

		for i = 1,5 do
			if i<=c or DF.configmode then
				-- point ON
				combos[i].sTexture = DF_config.combo.texturePath

				if combos[i].state==0 then
					combos[i].scale = DF_config.combo.impulsion + (multiple*0.1)
					multiple = multiple + 1
				end

				combos[i].state=1
			else
				-- point OFF
				combos[i].sTexture = DF_config.combo.texturePathOff
				combos[i].state=0
			end
		end
	elseif (DF.playerClass=="DRUID" and DF:currentForm()==1) then
		c = comboPts

		if DF_config.combo.showText and c and c>0 then
			combotext:SetText(tostring(c))
		else
			combotext:SetText("")
		end
		if DF_config.combo.showText and DF.configmode then
			combotext:SetText("5")
		end

		for i = 1,5 do
			if i<=c or DF.configmode then
				-- point ON
				combos[i].sTexture = DF_config.combo.texturePath

				if combos[i].state==0 then
					combos[i].scale = DF_config.combo.impulsion + (multiple*0.1)
					multiple = multiple + 1
				end

				combos[i].state=1
			else
				-- point OFF
				combos[i].sTexture = DF_config.combo.texturePathOff
				combos[i].state=0
			end
		end
	else
		combotext:SetText("")
		for i = 1,6 do
			combos[i].sTexture = DF_config.combo.texturePathOff
			combos[i].state=0
		end
	end

	for i = 1, 6 do
		combos[i].scale = combos[i].scale - 0.05

		if combos[i].scale<1 then
			combos[i].scale=1
		end

		combos[i].texture:SetTexture(combos[i].sTexture)
		combos[i].overlay:SetScale(combos[i].scale)
	end
end

function DF:combo_set(nb)
	comboPts = nb
end

-- enable/disable déplacement du cadre avec la souris
function DF:combo_toogle_lock(flag)
	frame:EnableMouse(flag)
	frametext:EnableMouse(flag)
end

function DF:combo_reinit()
	DF:init_combo_frame()
	DF:combo_toogle_lock(DF.configmode)
end