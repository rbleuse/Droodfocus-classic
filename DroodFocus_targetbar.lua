----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - target bar
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frame=nil
local background=nil
local foreground=nil
local text=nil
local frameTexture=nil

local cursor=0
local offset = 1

-- initialisation frames
function DF:init_targetbar_frame()
	
	if not frame then
		
		-- cadre principal
		frame = CreateFrame("FRAME","DF_targetbar_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
  			frame:StartMoving()
  		elseif button=="RightButton" then
  			DF:options_show("targetbar",frame)
  		end
		end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
	  		frame:StopMovingOrSizing()
	  		local anchorx=DF.anchor[1].frame:GetLeft()
	  		local anchory=DF.anchor[1].frame:GetTop()		  			  		
	  		DF_config.targetbar.positionx=DF:alignToGridX(self:GetLeft()-anchorx)
	  		DF_config.targetbar.positiony=DF:alignToGridY(self:GetTop()-anchory)
	  		frame:ClearAllPoints()
	  		frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.targetbar.positionx, DF_config.targetbar.positiony)
				DF.environnement["targetbarleft"]:Hide()
				DF.environnement["targetbartop"]:Hide()
				DF.environnement["targetbarleft"]:Show()
				DF.environnement["targetbartop"]:Show()
		  end
		end)	
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS TARGETBAR",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end		
		end)		
		frame:SetScript("OnLeave",function(self,button)

			if DF.configmode then GameTooltip:Hide() end
		end)		
		-- cadre pour la texture
		background = CreateFrame("StatusBar","DF_targetbar_BACKGROUND",frame)
		foreground = CreateFrame("StatusBar","DF_targetbar_FOREGROUND",frame)
		text = foreground:CreateFontString("DF_targetbar_TEXT","ARTWORK")
		frameTexture=frame:CreateTexture(nil)
		frame:EnableMouse(false)	
	end
	
	local level = DF_config.targetbar.level*10

	-- paramétres cadre principal
	frame:SetMovable(true)
		
	frame:SetWidth(DF_config.targetbar.width)
	frame:SetHeight(DF_config.targetbar.height)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.targetbar.positionx, DF_config.targetbar.positiony)
	frame:SetFrameLevel(level)
	if DF_config.targetbar.border then
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetTexture(DF_config.targetbar.borderColor.r, DF_config.targetbar.borderColor.v, DF_config.targetbar.borderColor.b,1)
		frame.texture=frameTexture
	else
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetTexture(DF_config.targetbar.borderColor.r, DF_config.targetbar.borderColor.v, DF_config.targetbar.borderColor.b,0)
		frame.texture=frameTexture
		
	end

	-- paramétres background
	background:SetWidth(DF_config.targetbar.width-DF_config.targetbar.borderSize*2)
	background:SetHeight(DF_config.targetbar.height-DF_config.targetbar.borderSize*2)
	background:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.targetbar.borderSize, -DF_config.targetbar.borderSize)
	background:SetStatusBarTexture(DF_config.targetbar.texturePath)
	background:SetStatusBarColor(0.5, 0, 0, 1)
	background:SetOrientation("HORIZONTAL")
	background:SetFrameLevel(level+1)

	-- paramétres foreground
	foreground:SetWidth(DF_config.targetbar.width-DF_config.targetbar.borderSize*2)
	foreground:SetHeight(DF_config.targetbar.height-DF_config.targetbar.borderSize*2)
	foreground:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.targetbar.borderSize, -DF_config.targetbar.borderSize)
	foreground:SetStatusBarTexture(DF_config.targetbar.texturePath)
	foreground:SetStatusBarColor(1, 0, 0, 1)
	foreground:SetOrientation("HORIZONTAL")
	foreground:SetMinMaxValues(0, 100)
	foreground:SetFrameLevel(level+2)

	background:SetStatusBarColor(DF_config.targetbar.color.r/3, DF_config.targetbar.color.v/3, DF_config.targetbar.color.b/3, DF_config.targetbar.color.a)
	foreground:SetStatusBarColor(DF_config.targetbar.color.r, DF_config.targetbar.color.v, DF_config.targetbar.color.b, DF_config.targetbar.color.a)
	background:SetOrientation(DF_config.targetbar.orientation)
	foreground:SetOrientation(DF_config.targetbar.orientation)
	
	-- paramétres text
	DF:MySetFont(text,DF_config.targetbar.fontPath,DF_config.targetbar.fontSize)
	text:SetShadowColor(0, 0, 0, 0.75)
	text:SetShadowOffset(0.5, -0.5)
	text:SetTextColor(DF_config.targetbar.textColor.r, DF_config.targetbar.textColor.v, DF_config.targetbar.textColor.b, 1)
	text:SetText("TEST")
	text:ClearAllPoints()
	text:SetPoint(DF_config.targetbar.textAlign, foreground, DF_config.targetbar.textAlign, DF_config.targetbar.textx, DF_config.targetbar.texty)
	
	if not DF_config.targetbar.showText then
		text:Hide()
	else
		text:Show()
	end
	
	if not DF_config.targetbar.enable then 
		frame:Hide()
	else
		frame:Show()
	end
		
end

-- gestion de l'animation
function DF:targetbar_update()
	
	if not DF_config.targetbar.enable then return end

	local currentForm = DF:currentForm()
	if not DF:form_goofForm(DF_config.targetbar.form,currentForm) then
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
		
		current = UnitHealth("target");		
		maxi = UnitHealthMax("target");
			
	end

	maxi2=maxi
	if maxi2==0 then
		maxi2=100
	end

	value = 100 * (current/maxi2)
	
	if cursor>value then
		
		cursor = cursor - DF_config.cursorspeed
		if cursor<value then cursor=value end
		
	elseif cursor<value then
		
		cursor = cursor + DF_config.cursorspeed
		if cursor>value then cursor=value end
		
	end
	
	foreground:SetValue(cursor)
	text:SetText(DF:formatText(maxi,current,DF_config.targetbar.sformat))
	
end

-- enable/disable déplacement du cadre avec la souris
function DF:targetbar_toogle_lock(flag)
	
	frame:EnableMouse(flag)
	
end

function DF:targetbar_reinit()
	
	DF:init_targetbar_frame()
	
end