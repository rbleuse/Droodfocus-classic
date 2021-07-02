----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - portrait
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

local defaultTexture = nil

-- initialisation frames
function DF:init_portrait_frame()
	
	if not frame then
		
		-- cadre principal
		frame = CreateFrame("FRAME","DF_portrait_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
  			frame:StartMoving()
  		elseif button=="RightButton" then
  			DF:options_show("portrait",frame)
  		end
  	end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
	  			frame:StopMovingOrSizing()
		  		local anchorx=DF.anchor[1].frame:GetLeft()
		  		local anchory=DF.anchor[1].frame:GetTop()		  		
		  		DF_config.portrait.positionx = self:GetLeft()-anchorx
		  		DF_config.portrait.positiony = self:GetTop()-anchory
		  		frame:ClearAllPoints()
		  		frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.portrait.positionx, DF_config.portrait.positiony)
					DF.environnement["portraitleft"]:Hide()
					DF.environnement["portraittop"]:Hide()
					DF.environnement["portraitleft"]:Show()
					DF.environnement["portraittop"]:Show()
		  	end
		end)	
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS PORTRAIT",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end		
		end)		
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)
				
		-- cadre pour la texture
		overlay = CreateFrame("FRAME","DF_portrait_OVERLAY",frame)
		
		-- la texture
		overlayTexture = overlay:CreateTexture("portraitoverlayTexture","BACKGROUND")
		frameTexture = frame:CreateTexture("portraitframeTexture","BACKGROUND")
		frame:EnableMouse(false)		
	end

	local level = DF_config.portrait.level*10
	defaultTexture = DF:GetDefaultPortrait()
	
	-- paramétres cadre principal
	frame:SetMovable(true)
	
	frame:SetWidth(64)
	frame:SetHeight(64)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.portrait.positionx, DF_config.portrait.positiony)

	-- paramétres texture
	frameTexture:SetTexCoord(0, 1, 0, 1)
	frameTexture:ClearAllPoints()
	frameTexture:SetAllPoints(frame)
	
	if DF.configmode then
		frameTexture:SetColorTexture(1,1,1,0.25)
	else
		frameTexture:SetColorTexture(1,1,1,0)
	end

	-- paramétres cadre texture
	overlay:SetMovable(false)
	overlay:EnableMouse(false)		
	overlay:SetWidth(DF_config.portrait.width)
	overlay:SetHeight(DF_config.portrait.height)
	overlay:SetPoint("CENTER", frame, "CENTER", 0, 0)
	overlay:SetFrameLevel(level)
	
	-- paramétres texture
	overlayTexture:SetTexCoord(0, 1, 0, 1)
	overlayTexture:SetWidth(64)
	overlayTexture:SetHeight(64)
	overlayTexture:SetBlendMode(DF_config.portrait.mode)
	overlayTexture:ClearAllPoints()
	overlayTexture:SetAllPoints(overlay)
	overlayTexture:SetTexture(defaultTexture)
	
	-- place la texture dans le cadre
	overlay.texture = overlayTexture
	
	if not DF_config.portrait.enable then
		overlay:Hide()
	else
		overlay:Show()
	end
		
end

-- gestion de l'animation
function DF:portrait_update()

	if DF.configmode then
		frameTexture:SetColorTexture(1,1,1,0.25)
	else
		frameTexture:SetColorTexture(1,1,1,0)	
	end

	if not DF_config.portrait.enable then
		overlay:Hide()
		return
	end

	local form = DF:currentForm()	
	if form>6 or DF_config.portrait.textures[form+1]=="Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga" then
		
		overlayTexture:SetTexture(defaultTexture)

	else
		
		overlayTexture:SetTexture(DF_config.portrait.textures[form+1])
		
	end
	overlay:Show()
end


-- enable/disable déplacement du cadre avec la souris
function DF:portrait_toogle_lock(flag)
	
	frame:EnableMouse(flag)
	
end

function DF:portrait_reinit()
	
	DF:init_portrait_frame()
	
end

function DF:GetDefaultPortrait()
		
  local portrait = "Interface\\CharacterFrame\\TemporaryPortrait"
  local sex = UnitSex("player")
  local _, raceEn = UnitRace("player")
  if ( sex == 2 ) then
      portrait = portrait .. "-Male-" .. raceEn
  elseif ( sex == 3 ) then
      portrait = portrait .. "-Female-" .. raceEn
  end
 
 	return portrait

end
