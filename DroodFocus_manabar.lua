----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - mana bar
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
function DF:init_manabar_frame()
	
	if not frame then
		
		-- cadre principal
		frame = CreateFrame("FRAME","DF_manabar_FRAME",DF.anchor[1].frame)
		frame:SetScript("OnMouseDown",function(self,button)
			if button=="LeftButton" then
  			frame:StartMoving()
  		elseif button=="RightButton" then
  			DF:options_show("manabar",frame)
  		end
		end)
		frame:SetScript("OnMouseUp",function(self,button)
			if button=="LeftButton" then
	  		frame:StopMovingOrSizing()
	  		local anchorx=DF.anchor[1].frame:GetLeft()
	  		local anchory=DF.anchor[1].frame:GetTop()		  			  		
	  		DF_config.manabar.positionx=DF:alignToGridX(self:GetLeft()-anchorx)
	  		DF_config.manabar.positiony=DF:alignToGridY(self:GetTop()-anchory)
	  		frame:ClearAllPoints()
	  		frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.manabar.positionx, DF_config.manabar.positiony)
				DF.environnement["manabarleft"]:Hide()
				DF.environnement["manabartop"]:Hide()
				DF.environnement["manabarleft"]:Show()
				DF.environnement["manabartop"]:Show()
		  end
		end)	
		frame:SetScript("OnEnter",function(self,button)
			if DF.configmode then
				GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
				GameTooltip:ClearLines()
				GameTooltip:AddLine("DROODFOCUS MANABAR",1,1,0,nil)
				GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
				GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
				GameTooltip:Show()		
			end		
		end)		
		frame:SetScript("OnLeave",function(self,button)
			if DF.configmode then GameTooltip:Hide() end
		end)	
					
		-- cadre pour la texture
		background = CreateFrame("StatusBar","DF_manabar_BACKGROUND",frame)
		foreground = CreateFrame("StatusBar","DF_manabar_FOREGROUND",frame)
		text = foreground:CreateFontString("DF_manabar_TEXT","ARTWORK")
		frameTexture=frame:CreateTexture(nil)
		frame:EnableMouse(false)		
	end

	local level = DF_config.manabar.level*10
	
	-- paramétres cadre principal
	frame:SetMovable(true)
	
	frame:SetWidth(DF_config.manabar.width)
	frame:SetHeight(DF_config.manabar.height)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", DF.anchor[1].frame, "TOPLEFT", DF_config.manabar.positionx, DF_config.manabar.positiony)
	frame:SetFrameLevel(DF_config.manabar.level)
	if DF_config.manabar.border then
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetColorTexture(DF_config.manabar.borderColor.r, DF_config.manabar.borderColor.v, DF_config.manabar.borderColor.b,DF_config.manabar.borderColor.a)
		frame.texture=frameTexture
	else
		frameTexture:ClearAllPoints()
		frameTexture:SetAllPoints(frame)
		frameTexture:SetColorTexture(DF_config.manabar.borderColor.r, DF_config.manabar.borderColor.v, DF_config.manabar.borderColor.b,0)
		frame.texture=frameTexture
		
	end

	-- paramétres background
	background:SetWidth(DF_config.manabar.width-DF_config.manabar.borderSize*2)
	background:SetHeight(DF_config.manabar.height-DF_config.manabar.borderSize*2)
	background:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.manabar.borderSize, -DF_config.manabar.borderSize)
	background:SetStatusBarTexture(DF_config.manabar.texturePath)
	background:SetOrientation("HORIZONTAL")
	background:SetFrameLevel(level+1)

	-- paramétres foreground
	foreground:SetWidth(DF_config.manabar.width-DF_config.manabar.borderSize*2)
	foreground:SetHeight(DF_config.manabar.height-DF_config.manabar.borderSize*2)
	foreground:SetPoint("TOPLEFT", frame, "TOPLEFT", DF_config.manabar.borderSize, -DF_config.manabar.borderSize)
	foreground:SetStatusBarTexture(DF_config.manabar.texturePath)
	foreground:SetOrientation("HORIZONTAL")
	foreground:SetMinMaxValues(0, 100)
	foreground:SetFrameLevel(level+2)

	background:SetStatusBarColor(DF_config.manabar.color.r/3, DF_config.manabar.color.v/3, DF_config.manabar.color.b/3, DF_config.manabar.color.a)
	foreground:SetStatusBarColor(DF_config.manabar.color.r, DF_config.manabar.color.v, DF_config.manabar.color.b, DF_config.manabar.color.a)
	background:SetOrientation(DF_config.manabar.orientation)
	foreground:SetOrientation(DF_config.manabar.orientation)
	
	-- paramétres text
	DF:MySetFont(text,DF_config.manabar.fontPath,DF_config.manabar.fontSize)
	text:SetShadowColor(0, 0, 0, 0.75)
	text:SetShadowOffset(0.5, -0.5)
	text:SetTextColor(DF_config.manabar.textColor.r, DF_config.manabar.textColor.v, DF_config.manabar.textColor.b, DF_config.manabar.textColor.a)
	text:SetText("TEST")
	text:ClearAllPoints()
	text:SetPoint(DF_config.manabar.textAlign, foreground, DF_config.manabar.textAlign, DF_config.manabar.textx, DF_config.manabar.texty)
	
	if not DF_config.manabar.showText then
		text:Hide()
	else
		text:Show()
	end
	
	if not DF_config.manabar.enable then 
		frame:Hide()
	else
		frame:Show()
	end
		
end

-- gestion de l'animation
function DF:manabar_update()
	
	if not DF_config.manabar.enable then return end
	
	local currentForm = DF:currentForm()
	if not DF:form_goofForm(DF_config.manabar.form,currentForm) then
		frame:Hide()
		return
	else
		frame:Show()
	end
		
	local current=0
	local value=0
	local maxi=100
	local powerType = UnitPowerType("player")

	maxi = UnitPowerMax("player",SPELL_POWER_MANA)
	current = UnitPower("player",SPELL_POWER_MANA)

	if maxi==0 then cursor=0 end

	if DF.configmode then
		
		current=50
		maxi=100
			
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
	text:SetText(DF:formatText(maxi,current,DF_config.manabar.sformat))

end

-- enable/disable déplacement du cadre avec la souris
function DF:manabar_toogle_lock(flag)
	
	frame:EnableMouse(flag)
	
end

function DF:manabar_reinit()
	
	DF:init_manabar_frame()
	
end