----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - health bar
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frame=nil
local frameTexture=nil

local background=nil
local foreground=nil
local text=nil

local cursor=0
local offset = 1

-- initialisation frames
function DF:init_healthbar_frame()
	
	if not frame then
		
		-- cadre principal
		frame = CreateFrame("FRAME","DF_healthbar_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
  			frame:StartMoving()
  		elseif button=="RightButton" then
  			DF:options_show("healthbar",frame)
  		end
		end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
	  		frame:StopMovingOrSizing()
	  		local anchorx=DF.anchor[1].frame:GetLeft()
	  		local anchory=DF.anchor[1].frame:GetTop()		  			  		
	  		DF_config.healthbar.positionx=DF:alignToGridX(self:GetLeft()-anchorx)
	  		DF_config.healthbar.positiony=DF:alignToGridY(self:GetTop()-anchory)
	  		frame:ClearAllPoints()
	  		frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.healthbar.positionx, DF_config.healthbar.positiony)
				DF.environnement["healthbarleft"]:Hide()
				DF.environnement["healthbartop"]:Hide()
				DF.environnement["healthbarleft"]:Show()
				DF.environnement["healthbartop"]:Show()
		  end
		end)	
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS HEALTHBAR",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end		
		end)		
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)		
				
		-- cadre pour la texture
		background = CreateFrame("StatusBar","DF_healthbar_BACKGROUND",frame)
		foreground = CreateFrame("StatusBar","DF_healthbar_FOREGROUND",frame)
		text = foreground:CreateFontString("DF_healthbar_TEXT","ARTWORK")
		frameTexture=frame:CreateTexture(nil)
		frame:EnableMouse(false)		
	end

	local level = DF_config.healthbar.level*10
	
	-- paramétres cadre principal
	frame:SetMovable(true)
	
	frame:SetWidth(DF_config.healthbar.width)
	frame:SetHeight(DF_config.healthbar.height)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.healthbar.positionx, DF_config.healthbar.positiony)
	frame:SetFrameLevel(level)

	if DF_config.healthbar.border then
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetTexture(DF_config.healthbar.borderColor.r, DF_config.healthbar.borderColor.v, DF_config.healthbar.borderColor.b,DF_config.healthbar.borderColor.a)
		frame.texture=frameTexture
	else
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetTexture(DF_config.healthbar.borderColor.r, DF_config.healthbar.borderColor.v, DF_config.healthbar.borderColor.b,0)
		frame.texture=frameTexture
		
	end

	-- paramétres background
	background:SetWidth(DF_config.healthbar.width-DF_config.healthbar.borderSize*2)
	background:SetHeight(DF_config.healthbar.height-DF_config.healthbar.borderSize*2)
	background:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.healthbar.borderSize, -DF_config.healthbar.borderSize)
	background:SetStatusBarTexture(DF_config.healthbar.texturePath)
	background:SetOrientation("HORIZONTAL")
	background:SetFrameLevel(level+1)

	-- paramétres foreground
	foreground:SetWidth(DF_config.healthbar.width-DF_config.healthbar.borderSize*2)
	foreground:SetHeight(DF_config.healthbar.height-DF_config.healthbar.borderSize*2)
	foreground:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.healthbar.borderSize, -DF_config.healthbar.borderSize)
	foreground:SetStatusBarTexture(DF_config.healthbar.texturePath)
	foreground:SetOrientation("HORIZONTAL")
	foreground:SetMinMaxValues(0, 100)
	foreground:SetFrameLevel(level+2)

	if DF_config.healthbar.colorchg then
		background:SetStatusBarColor(DF_config.healthbar.colorGood.r/3, DF_config.healthbar.colorGood.v/3, DF_config.healthbar.colorGood.b/3, DF_config.healthbar.colorGood.a)
		foreground:SetStatusBarColor(DF_config.healthbar.colorGood.r, DF_config.healthbar.colorGood.v, DF_config.healthbar.colorGood.b, DF_config.healthbar.colorGood.a)
	else
		background:SetStatusBarColor(1,1,1,0.33)
		foreground:SetStatusBarColor(1,1,1,1)
	end
	
	background:SetOrientation(DF_config.healthbar.orientation)
	foreground:SetOrientation(DF_config.healthbar.orientation)

	-- paramétres text
	DF:MySetFont(text,DF_config.healthbar.fontPath,DF_config.healthbar.fontSize)
	text:SetShadowColor(0, 0, 0, 0.75)
	text:SetShadowOffset(0.5, -0.5)
	text:SetTextColor(DF_config.healthbar.textColor.r, DF_config.healthbar.textColor.v, DF_config.healthbar.textColor.b, DF_config.healthbar.textColor.a)
	text:SetText("TEST")
	text:ClearAllPoints()
	text:SetPoint(DF_config.healthbar.textAlign, foreground, DF_config.healthbar.textAlign, DF_config.healthbar.textx, DF_config.healthbar.texty)
	
	if not DF_config.healthbar.showText then
		text:Hide()
	else
		text:Show()
	end
	
	if not DF_config.healthbar.enable then 
		frame:Hide()
	else
		frame:Show()
	end
		
end

-- gestion de l'animation
function DF:healthbar_update()
	
	if not DF_config.healthbar.enable then return end

	local currentForm = DF:currentForm()
	if not DF:form_goofForm(DF_config.healthbar.form,currentForm) then
		frame:Hide()
		return
	else
		frame:Show()
	end
	
	local current=0
	local value=0
	local maxi=100

	if DF.configmode then
		
		current=50
		maxi=100
		
	else
		
		current = UnitHealth("player");		
		maxi = UnitHealthMax("player");
			
	end

	value = 100 * (current/maxi)

	if DF_config.healthbar.colorchg then

		if value>0 and value<=33 then
			
			background:SetStatusBarColor(DF_config.healthbar.colorBad.r/3, DF_config.healthbar.colorBad.v/3, DF_config.healthbar.colorBad.b/3, DF_config.healthbar.colorBad.a)
			foreground:SetStatusBarColor(DF_config.healthbar.colorBad.r, DF_config.healthbar.colorBad.v, DF_config.healthbar.colorBad.b, DF_config.healthbar.colorBad.a)
			
		elseif value>33 and value<=66 then
			
			background:SetStatusBarColor(DF_config.healthbar.colorAverage.r/3, DF_config.healthbar.colorAverage.v/3, DF_config.healthbar.colorAverage.b/3, DF_config.healthbar.colorAverage.a)
			foreground:SetStatusBarColor(DF_config.healthbar.colorAverage.r, DF_config.healthbar.colorAverage.v, DF_config.healthbar.colorAverage.b, DF_config.healthbar.colorAverage.a)
			
		elseif value>66 then
			
			background:SetStatusBarColor(DF_config.healthbar.colorGood.r/3, DF_config.healthbar.colorGood.v/3, DF_config.healthbar.colorGood.b/3, DF_config.healthbar.colorGood.a)
			foreground:SetStatusBarColor(DF_config.healthbar.colorGood.r, DF_config.healthbar.colorGood.v, DF_config.healthbar.colorGood.b, DF_config.healthbar.colorGood.a)
			
		end
		
	end
	
	if cursor>value then
		
		cursor = cursor - DF_config.cursorspeed
		if cursor<value then cursor=value end
		
	elseif cursor<value then
		
		cursor = cursor + DF_config.cursorspeed
		if cursor>value then cursor=value end
		
	end
	
	foreground:SetValue(cursor)
	text:SetText(DF:formatText(maxi,current,DF_config.healthbar.sformat))
	
end

-- enable/disable déplacement du cadre avec la souris
function DF:healthbar_toogle_lock(flag)
	
	frame:EnableMouse(flag)
	
end

function DF:healthbar_reinit()
	
	DF:init_healthbar_frame()
	
end