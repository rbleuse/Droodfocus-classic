----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - power bar
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frame=nil
local frameTexture=nil
local background=nil
local foreground=nil
local spark=nil
local sparkTexture=nil
local text=nil

local cursor=0

local frequency =1/60
local tempo=(frequency/15)*6

-- initialisation frames
function DF:init_powerbar_frame()
	if not frame then
		-- cadre principal
		frame = CreateFrame("FRAME","DF_POWERBAR_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
				frame:StartMoving()
			elseif button=="RightButton" then
				DF:options_show("powerbar",frame)
			end
		end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
				frame:StopMovingOrSizing()
				local anchorx=DF.anchor[1].frame:GetLeft()
				local anchory=DF.anchor[1].frame:GetTop()
				DF_config.powerbar.positionx=DF:alignToGridX(self:GetLeft()-anchorx)
				DF_config.powerbar.positiony=DF:alignToGridY(self:GetTop()-anchory)
				frame:ClearAllPoints()
				frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.powerbar.positionx, DF_config.powerbar.positiony)
				DF.environnement["powerbarleft"]:Hide()
				DF.environnement["powerbartop"]:Hide()
				DF.environnement["powerbarleft"]:Show()
				DF.environnement["powerbartop"]:Show()
			end
		end)
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS POWERBAR",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()
			end
		end)
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)

		-- cadre pour la texture
		background = CreateFrame("StatusBar","DF_POWERBAR_BACKGROUND",frame)
		foreground = CreateFrame("StatusBar","DF_POWERBAR_FOREGROUND",frame)
		spark =  CreateFrame("FRAME","DF_POWERBAR_SPARK",foreground)

		text = foreground:CreateFontString("DF_POWERBAR_TEXT","ARTWORK")
		frame:EnableMouse(false)

		sparkTexture=spark:CreateTexture(nil)
		frameTexture=frame:CreateTexture(nil)
	end

	local level = DF_config.powerbar.level*10

	-- paramétres cadre principal
	frame:SetMovable(true)

	frame:SetWidth(DF_config.powerbar.width)
	frame:SetHeight(DF_config.powerbar.height)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.powerbar.positionx, DF_config.powerbar.positiony)
	frame:SetFrameLevel(level)

	if DF_config.powerbar.border then
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetColorTexture(DF_config.powerbar.borderColor.r, DF_config.powerbar.borderColor.v, DF_config.powerbar.borderColor.b,DF_config.powerbar.borderColor.a)
		frame.texture=frameTexture
	else
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetColorTexture(DF_config.powerbar.borderColor.r, DF_config.powerbar.borderColor.v, DF_config.powerbar.borderColor.b,0)
		frame.texture=frameTexture
	end

	-- paramétres background
	background:SetWidth(DF_config.powerbar.width-DF_config.powerbar.borderSize*2)
	background:SetHeight(DF_config.powerbar.height-DF_config.powerbar.borderSize*2)
	background:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.powerbar.borderSize, -DF_config.powerbar.borderSize)
	background:SetStatusBarTexture(DF_config.powerbar.texturePath)
	background:SetStatusBarColor(DF_config.powerbar.colorNrj.r/3, DF_config.powerbar.colorNrj.v/3, DF_config.powerbar.colorNrj.b/3, DF_config.powerbar.colorNrj.a)
	background:SetFrameLevel(level+1)

	-- paramétres foreground
	foreground:SetWidth(DF_config.powerbar.width-DF_config.powerbar.borderSize*2)
	foreground:SetHeight(DF_config.powerbar.height-DF_config.powerbar.borderSize*2)
	foreground:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.powerbar.borderSize, -DF_config.powerbar.borderSize)
	foreground:SetStatusBarTexture(DF_config.powerbar.texturePath)
	foreground:SetStatusBarColor(DF_config.powerbar.colorNrj.r, DF_config.powerbar.colorNrj.v, DF_config.powerbar.colorNrj.b, DF_config.powerbar.colorNrj.a)
	foreground:SetMinMaxValues(0, 100)
	foreground:SetFrameLevel(level+2)

	background:SetOrientation(DF_config.powerbar.orientation)
	foreground:SetOrientation(DF_config.powerbar.orientation)

	spark:SetMovable(false)
	spark:EnableMouse(false)
	spark:SetWidth(20)
	spark:SetHeight(DF_config.powerbar.height*2.2)
	spark:SetPoint("LEFT", foreground, "LEFT", 0, 0)
	spark:SetFrameLevel(255)

	sparkTexture:ClearAllPoints()
	sparkTexture:SetAllPoints(spark)
	sparkTexture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	sparkTexture:SetBlendMode("ADD")
	spark.texture=sparkTexture				

	if DF_config.powerbar.orientation=="VERTICAL" or not DF_config.powerbar.showSpark then
		spark:Hide()
	else
		spark:Show()
	end

	-- paramétres text
	DF:MySetFont(text,DF_config.powerbar.fontPath,DF_config.powerbar.fontSize)
	text:SetShadowColor(0, 0, 0, 0.75)
	text:SetShadowOffset(0.5, -0.5)
	text:SetTextColor(DF_config.powerbar.textColor.r, DF_config.powerbar.textColor.v, DF_config.powerbar.textColor.b, DF_config.powerbar.textColor.a)
	text:SetText("POWERBAR")
	text:ClearAllPoints()
	text:SetPoint(DF_config.powerbar.textAlign, foreground, DF_config.powerbar.textAlign, DF_config.powerbar.textx, DF_config.powerbar.texty)

	if not DF_config.powerbar.showText then
		text:Hide()
	else
		text:Show()
	end

	if not DF_config.powerbar.enable then
		frame:Hide()
	else
		frame:Show()
	end
end

-- gestion de l'animation
function DF:powerbar_update(elapsed)
	if not DF_config.powerbar.enable then return end

	tempo=tempo+elapsed
	if tempo<frequency then return end
	tempo=0	

	local currentForm = DF:currentForm()
	if not DF:form_goofForm(DF_config.powerbar.form,currentForm) then
		frame:Hide()
		return
	else
		frame:Show()
	end

	local current=0
	local value=0
	local maxi=100
	local powerType = UnitPowerType("player")

	if (powerType==0) then
		maxi = UnitPowerMax("player",SPELL_POWER_MANA)
		current = UnitPower("player",SPELL_POWER_MANA)

		background:SetStatusBarColor(DF_config.powerbar.colorMana.r/3, DF_config.powerbar.colorMana.v/3, DF_config.powerbar.colorMana.b/3, DF_config.powerbar.colorMana.a)
		foreground:SetStatusBarColor(DF_config.powerbar.colorMana.r, DF_config.powerbar.colorMana.v, DF_config.powerbar.colorMana.b, DF_config.powerbar.colorMana.a)
	elseif (powerType==1) then
		maxi = UnitPowerMax("player",SPELL_POWER_RAGE)
		current = UnitPower("player",SPELL_POWER_RAGE)

		background:SetStatusBarColor(DF_config.powerbar.colorRage.r/3, DF_config.powerbar.colorRage.v/3, DF_config.powerbar.colorRage.b/3, DF_config.powerbar.colorRage.a)
		foreground:SetStatusBarColor(DF_config.powerbar.colorRage.r, DF_config.powerbar.colorRage.v, DF_config.powerbar.colorRage.b, DF_config.powerbar.colorRage.a)
	elseif (powerType==3) then
		maxi = UnitPowerMax("player",SPELL_POWER_ENERGY)
		current = UnitPower("player",SPELL_POWER_ENERGY)
		
		background:SetStatusBarColor(DF_config.powerbar.colorNrj.r/3, DF_config.powerbar.colorNrj.v/3, DF_config.powerbar.colorNrj.b/3, DF_config.powerbar.colorNrj.a)
		foreground:SetStatusBarColor(DF_config.powerbar.colorNrj.r, DF_config.powerbar.colorNrj.v, DF_config.powerbar.colorNrj.b, DF_config.powerbar.colorNrj.a)
	else
		maxi = UnitPowerMax("player")
		current = UnitPower("player")

		background:SetStatusBarColor(DF_config.powerbar.colorDef.r/3, DF_config.powerbar.colorDef.v/3, DF_config.powerbar.colorDef.b/3, DF_config.powerbar.colorDef.a)
		foreground:SetStatusBarColor(DF_config.powerbar.colorDef.r, DF_config.powerbar.colorDef.v, DF_config.powerbar.colorDef.b, DF_config.powerbar.colorDef.a)
	end

	if DF.configmode then
		current=50
		maxi=100

		background:SetStatusBarColor(DF_config.powerbar.colorNrj.r/3, DF_config.powerbar.colorNrj.v/3, DF_config.powerbar.colorNrj.b/3, DF_config.powerbar.colorNrj.a)
		foreground:SetStatusBarColor(DF_config.powerbar.colorNrj.r, DF_config.powerbar.colorNrj.v, DF_config.powerbar.colorNrj.b, DF_config.powerbar.colorNrj.a)
	end

	if maxi<=0 then
		value = 0
	else
		value = 100 * (current/maxi)
	end

	if DF_config.powerbar.interval>1 and value<maxi then
		value=math.floor(value/DF_config.powerbar.interval)*DF_config.powerbar.interval
		current=math.floor(current/DF_config.powerbar.interval)*DF_config.powerbar.interval
	end

	if cursor>value then
		cursor = cursor - DF_config.cursorspeed
		if cursor<value then cursor=value end
	elseif cursor<value then
		cursor = cursor + DF_config.cursorspeed
		if cursor>value then cursor=value end
	end

	foreground:SetValue(cursor)

	DF:powerbar_sparck(cursor)

	text:SetText(DF:formatText(maxi,current,DF_config.powerbar.sformat))
end

function DF:powerbar_sparck(cursor)
	local largeur=DF_config.powerbar.width-(DF_config.powerbar.borderSize*2)
	if cursor>0 and cursor<100 and DF_config.powerbar.orientation~="VERTICAL" and DF_config.powerbar.showSpark then
		local sparckx=((cursor/100)*largeur)-10
		spark:SetPoint("LEFT", foreground, "LEFT", sparckx, -1)
		spark:Show()
	else
		spark:Hide()
	end
end

function DF:powerbar_get_pt()
	return frame
end

-- enable/disable déplacement du cadre avec la souris
function DF:powerbar_toogle_lock(flag)
	frame:EnableMouse(flag)
end

function DF:powerbar_reinit()
	DF:init_powerbar_frame()
	DF:init_arrows_frame()
end