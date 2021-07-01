----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - alert
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local state=0
local scale=1

local frame=nil
local frameTexture=nil
local overlay=nil
local overlayTexture=nil

-- initialisation frames
function DF:init_alert_frame()
	
	if not frame then
		
		-- cadre principal
		frame = CreateFrame("FRAME","DF_ALERT_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
  			frame:StartMoving()
  		elseif button=="RightButton" then
  			DF:options_show("alert",frame)
  		end
  	end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
	  		frame:StopMovingOrSizing()
		  		local anchorx=DF.anchor[1].frame:GetLeft()
		  		local anchory=DF.anchor[1].frame:GetTop()		  		
		  		DF_config.alert.positionx = self:GetLeft()-anchorx
		  		DF_config.alert.positiony = self:GetTop()-anchory
		  		frame:ClearAllPoints()
		  		frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.alert.positionx, DF_config.alert.positiony)
					DF.environnement["alertleft"]:Hide()
					DF.environnement["alerttop"]:Hide()
					DF.environnement["alertleft"]:Show()
					DF.environnement["alerttop"]:Show()			
		  end
		end)	
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS ALERT",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end		
		end)		
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)		
				
		-- cadre pour la texture
		overlay = CreateFrame("FRAME","DF_alert_OVERLAY",frame)
		
		-- la texture
		overlayTexture = overlay:CreateTexture(nil,"BACKGROUND")
		frameTexture = frame:CreateTexture(nil,"BACKGROUND")
		frame:EnableMouse(false)		
	end

	local level = DF_config.alert.level*10

	-- paramétres cadre principal
	frame:SetMovable(true)
	
	frame:SetWidth(64)
	frame:SetHeight(64)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.alert.positionx, DF_config.alert.positiony)

	-- paramétres texture
	frameTexture:SetTexCoord(0, 1, 0, 1)
	frameTexture:ClearAllPoints()
	frameTexture:SetAllPoints(frame)
	
	if DF.configmode then
		frameTexture:SetTexture(1,1,1,0.25)
	else
		frameTexture:SetTexture(1,1,1,0)
	end

	-- paramétres cadre texture
	overlay:SetMovable(false)
	overlay:EnableMouse(false)		
	overlay:SetWidth(DF_config.alert.width)
	overlay:SetHeight(DF_config.alert.height)
	overlay:SetPoint("CENTER", frame, "CENTER", 0, 0)
	overlay:SetFrameLevel(level)
	
	-- paramétres texture
	overlayTexture:SetTexCoord(0, 1, 0, 1)
	overlayTexture:SetWidth(128)
	overlayTexture:SetHeight(128)
	overlayTexture:SetBlendMode(DF_config.alert.mode)
	overlayTexture:ClearAllPoints()
	overlayTexture:SetAllPoints(overlay)
	overlayTexture:SetTexture(DF_config.alert.texture1)
	
	-- place la texture dans le cadre
	overlay.texture = overlayTexture
	
	overlay:Hide()
		
end

-- gestion de l'animation
function DF:alert_update()

	if DF.configmode then
		frameTexture:SetTexture(1,1,1,0.25)
	else
		frameTexture:SetTexture(1,1,1,0)
	end

	if not DF_config.alert.enable then
		overlay:Hide();		
		return
	end

	if state == 1 then
	
		scale  = scale  - 0.075
	
		local tempScale=scale
	
		if	tempScale>1 then tempScale=1 end			
		if	tempScale<0.1 then
			tempScale=0.1
			state=0
		end
					
		overlay:SetScale(tempScale);
		overlay:Show();		
		
	elseif state==2 then
		
		scale  = scale  - 0.025
		
		overlay:SetScale(scale);
		overlay:Show();		

		if	scale<1 then
			
			scale=DF_config.alert.persistence
			state=1
			
		end
			
	else
		
		overlay:Hide();	
		
	end

	if DF.configmode then
		overlayTexture:SetTexture("Interface\\icons\\INV_Misc_QuestionMark")
		overlay:SetScale(1);
		overlay:Show();		
	end
	
end

function DF:alert_activate(aType,force)
	
	if state==0 or force then
		
		if aType=="1" then
			overlayTexture:SetTexture(DF_config.alert.texture1)
		elseif aType=="2" then
			overlayTexture:SetTexture(DF_config.alert.texture2)
		elseif aType=="3" then
			overlayTexture:SetTexture(DF_config.alert.texture3)
		else
			overlayTexture:SetTexture(aType)
		end
		
		state=2
		scale=1.5
		
	end
	
end

-- enable/disable déplacement du cadre avec la souris
function DF:alert_toogle_lock(flag)
	
	frame:EnableMouse(flag)
	
end

function DF:alert_reinit()
	
	DF:init_alert_frame()
	DF:alert_activate("1")
	
end