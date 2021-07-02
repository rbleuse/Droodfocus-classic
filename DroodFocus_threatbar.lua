----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - threat bar
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
function DF:init_threatbar_frame()
	
	if not frame then
		
		-- cadre principal
		frame = CreateFrame("FRAME","DF_threatbar_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
  			frame:StartMoving()
  		elseif button=="RightButton" then
  			DF:options_show("threatbar",frame)
  		end
		end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
	  		frame:StopMovingOrSizing()
	  		local anchorx=DF.anchor[1].frame:GetLeft()
	  		local anchory=DF.anchor[1].frame:GetTop()				  		
	  		DF_config.threatbar.positionx=DF:alignToGridX(self:GetLeft()-anchorx)
	  		DF_config.threatbar.positiony=DF:alignToGridY(self:GetTop()-anchory)
	  		frame:ClearAllPoints()
	  		frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.threatbar.positionx, DF_config.threatbar.positiony)
				DF.environnement["threatbarleft"]:Hide()
				DF.environnement["threatbartop"]:Hide()
				DF.environnement["threatbarleft"]:Show()
				DF.environnement["threatbartop"]:Show()
			end
		end)	
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS THREATBAR",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end		
		end)		
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)	
			
		-- cadre pour la texture
		background = CreateFrame("StatusBar","DF_threatbar_BACKGROUND",frame)
		foreground = CreateFrame("StatusBar","DF_threatbar_FOREGROUND",frame)
		text = foreground:CreateFontString("DF_threatbar_TEXT","ARTWORK")
		frameTexture=frame:CreateTexture(nil)
		frame:EnableMouse(false)		
	end
	
	local level = DF_config.threatbar.level*10

	-- paramétres cadre principal
	frame:SetMovable(true)
	
	frame:SetWidth(DF_config.threatbar.width)
	frame:SetHeight(DF_config.threatbar.height)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.threatbar.positionx, DF_config.threatbar.positiony)
	frame:SetFrameLevel(level)
	if DF_config.threatbar.border then
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetColorTexture(DF_config.threatbar.borderColor.r, DF_config.threatbar.borderColor.v, DF_config.threatbar.borderColor.b,1)
		frame.texture=frameTexture
	else
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetColorTexture(DF_config.threatbar.borderColor.r, DF_config.threatbar.borderColor.v, DF_config.threatbar.borderColor.b,0)
		frame.texture=frameTexture
		
	end


	-- paramétres background
	background:SetWidth(DF_config.threatbar.width-DF_config.threatbar.borderSize*2)
	background:SetHeight(DF_config.threatbar.height-DF_config.threatbar.borderSize*2)
	background:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.threatbar.borderSize, -DF_config.threatbar.borderSize)
	background:SetStatusBarTexture(DF_config.threatbar.texturePath)
	background:SetStatusBarColor(0.5, 0, 0, 1)
	background:SetOrientation("HORIZONTAL")
	background:SetFrameLevel(level+1)

	-- paramétres foreground
	foreground:SetWidth(DF_config.threatbar.width-DF_config.threatbar.borderSize*2)
	foreground:SetHeight(DF_config.threatbar.height-DF_config.threatbar.borderSize*2)
	foreground:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.threatbar.borderSize, -DF_config.threatbar.borderSize)
	foreground:SetStatusBarTexture(DF_config.threatbar.texturePath)
	foreground:SetStatusBarColor(1, 0, 0, 1)
	foreground:SetOrientation("HORIZONTAL")
	foreground:SetMinMaxValues(0, 100)
	foreground:SetFrameLevel(level+2)

	background:SetStatusBarColor(DF_config.threatbar.color.r/3, DF_config.threatbar.color.v/3, DF_config.threatbar.color.b/3,DF_config.threatbar.color.a)
	foreground:SetStatusBarColor(DF_config.threatbar.color.r, DF_config.threatbar.color.v, DF_config.threatbar.color.b, DF_config.threatbar.color.a)
	background:SetOrientation(DF_config.threatbar.orientation)
	foreground:SetOrientation(DF_config.threatbar.orientation)
	
	-- paramétres text
	DF:MySetFont(text,DF_config.threatbar.fontPath,DF_config.threatbar.fontSize)
	text:SetShadowColor(0, 0, 0, 0.75)
	text:SetShadowOffset(0.5, -0.5)
	text:SetTextColor(DF_config.threatbar.textColor.r, DF_config.threatbar.textColor.v, DF_config.threatbar.textColor.b, 1)
	text:SetText("TEST")
	text:ClearAllPoints()
	text:SetPoint(DF_config.threatbar.textAlign, foreground, DF_config.threatbar.textAlign, DF_config.threatbar.textx, DF_config.threatbar.texty)
	
	if not DF_config.threatbar.showText then
		text:Hide()
	else
		text:Show()
	end
	
	if not DF_config.threatbar.enable then 
		frame:Hide()
	else
		frame:Show()
	end
		
end

-- gestion de l'animation
function DF:threatbar_update()

	if not DF_config.threatbar.enable then return end

	local currentForm = DF:currentForm()
	if not DF:form_goofForm(DF_config.threatbar.form,currentForm) then
		frame:Hide()
		return
	else
		frame:Show()
	end
	
	local value=0
	local maxi=100
	local _, _, current, _, _ = UnitDetailedThreatSituation("player", "playertarget")
	if not current then current =0 end

	if DF.configmode then
		
		current=50
		maxi=100
		DF.menace=0
			
	else
		maxi = 100
	end
	
	value = 100 * (current/maxi)
	
	if cursor>value then
		
		cursor = cursor - DF_config.cursorspeed
		if cursor<value then cursor=value end
		
	elseif cursor<value then
		
		cursor = cursor + DF_config.cursorspeed
		if cursor>value then cursor=value end
		
	end
	
	foreground:SetValue(cursor)
	text:SetText(DF:formatText(maxi,current,DF_config.threatbar.sformat))
	
end

-- enable/disable déplacement du cadre avec la souris
function DF:threatbar_toogle_lock(flag)
	
	frame:EnableMouse(flag)
	
end

function DF:threatbar_reinit()
	
	DF:init_threatbar_frame()
	
end