----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - ooc
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local state=0
local scale=1
local offset=0.1
local ooc_spell = nil

local frame=nil
local frameTexture=nil
local overlay=nil
local overlayTexture=nil

local degre=0

local Model=nil

-- initialisation frames
function DF:init_ooc_frame()
	
	ooc_spell = GetSpellInfo(DF_config.ooc.spell)
	
	if not frame then
		
		-- cadre principal
		frame = CreateFrame("FRAME","DF_OOC_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
	  			frame:StartMoving()
	  		elseif button=="RightButton" then
	  			DF:options_show("ooc",frame)
	  		end
		end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
		  		frame:StopMovingOrSizing()
		  		local anchorx=DF.anchor[1].frame:GetLeft()
		  		local anchory=DF.anchor[1].frame:GetTop()		  		
		  		DF_config.ooc.positionx = self:GetLeft()-anchorx
		  		DF_config.ooc.positiony = self:GetTop()-anchory
		  		frame:ClearAllPoints()
		  		frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.ooc.positionx, DF_config.ooc.positiony)
		  		
					DF.environnement["oocleft"]:Hide()
					DF.environnement["ooctop"]:Hide()
					DF.environnement["oocleft"]:Show()
					DF.environnement["ooctop"]:Show()
		  end
		end)	
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS OOC",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end		
		end)		
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)	
		
		-- cadre pour la texture
		overlay = CreateFrame("FRAME","DF_OOC_OVERLAY",frame)
		
		-- la texture
		overlayTexture = overlay:CreateTexture(nil,"BACKGROUND")
		frameTexture = frame:CreateTexture(nil,"BACKGROUND")
		frame:EnableMouse(false)	
		
	end

	local level = DF_config.ooc.level*10

	-- paramétres cadre principal
	frame:SetMovable(true)
	frame:SetWidth(64)
	frame:SetHeight(64)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.ooc.positionx, DF_config.ooc.positiony)
	frame:SetFrameLevel(level)	
	
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
	overlay:SetWidth(DF_config.ooc.width)
	overlay:SetHeight(DF_config.ooc.height)
	overlay:SetPoint("CENTER", frame, "CENTER", 0, 0)
	overlay:SetFrameLevel(level+1)	
	
	-- paramétres texture
	overlayTexture:SetTexCoord(0, 1, 0, 1)
	overlayTexture:SetWidth(128)
	overlayTexture:SetHeight(128)
	overlayTexture:SetBlendMode(DF_config.ooc.mode)
	overlayTexture:ClearAllPoints()
	overlayTexture:SetAllPoints(overlay)
	overlayTexture:SetTexture(DF_config.ooc.textureOff)
	
	-- place la texture dans le cadre
	overlay.texture = overlayTexture

end

-- gestion de l'animation
function DF:ooc_update()
	
	if (DF.configmode) then
		frameTexture:SetTexture(1,1,1,0.25)
	else
		frameTexture:SetTexture(1,1,1,0)
	end
	
	if not DF_config.ooc.enable then
		overlay:Hide()
		return
	end

	DF:ooc_check_buff()
	
	overlay:Show()	
	if state~=0 or DF.configmode then
				
		if (state == 1 or DF.configmode) then
			
			if DF_config.ooc.scaleMax>DF_config.ooc.scaleMin then
				DF_config.ooc.scaleMax=DF_config.ooc.scaleMin-DF_config.ooc.speed
			end

			scale=DF_config.ooc.scaleMin+(math.cos(degre)*DF_config.ooc.scaleMax)
			degre=degre+DF_config.ooc.speed
			
		elseif state == 2 then

			scale  = scale  + offset
			
			if	scale<0.01 then
				
				scale=0.01
				state = 0
				
			end
						
		end
		
		overlay:SetScale(scale)
		if DF_config.ooc.textureOn~="" then
			overlayTexture:SetTexture(DF_config.ooc.textureOn)
		else
			overlayTexture:SetTexture(nil)
		end
		
	else
		
		if DF_config.ooc.textureOff~="" then
			overlayTexture:SetTexture(DF_config.ooc.textureOff)
		else
			overlayTexture:SetTexture(nil)
		end			
		
	end
		
end

-- vérification du buff
function DF:ooc_check_buff()

	if AuraUtil.FindAuraByName(ooc_spell, "player") then
	   
	    if (state==0 or state==2) then
	    	
		    offset = 0.1
		    state = 1
		    
	    end
	    
	else
		
		if state~=0 then
			
	    		offset = -0.1;
	    		state = 2;
	    		
		end
		
	end
	
end

-- enable/disable déplacement du cadre avec la souris
function DF:ooc_toogle_lock(flag)
	
	frame:EnableMouse(flag)
	
end

function DF:ooc_reinit()
	DF:init_ooc_frame()	
end