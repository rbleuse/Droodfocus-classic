----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - gps
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frame={}
local frameTexture={}
local overlay={}
local overlayTexture={}
local frameText={}

local degre=0
local cible=""

local posX=0
local posY=0
local TposX=0
local TposY=0
local colonne=0
local ligne=0
local distance=0

local arrowW = 56
local arrowH = 42
local deltax = arrowW / 512
local deltay = arrowH / 512

local pif = math.pi

-- initialisation frames
function DF:init_gps_frame()

	if DF_config.gps.positionx~=0 then
		for i = 1,2 do
			DF_config.gps.positions[i].x=DF_config.gps.positionx+((i-1)*64)
			DF_config.gps.positions[i].y=DF_config.gps.positiony
		end	
		DF_config.gps.positionx=0
	end
	
	for i = 1,2 do

		if not frame[i] then
			
			-- cadre principal
			frame[i] = CreateFrame("FRAME","DF_gps_FRAME"..i,UIParent)
			frame[i]:SetScript("OnMouseDown",function(self,button)
				if button=="LeftButton" then
		  			frame[i]:StartMoving()
		  		elseif button=="RightButton" then
		  			DF:options_show("gps",frame[i])
		  		end
			end)
			frame[i]:SetScript("OnMouseUp",function(self,button)
				if button=="LeftButton" then
			  		frame[i]:StopMovingOrSizing()
			  		DF_config.gps.positions[i].x = self:GetLeft()
			  		DF_config.gps.positions[i].y = self:GetBottom()
			  		frame[i]:ClearAllPoints()
			  		frame[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", DF_config.gps.positions[i].x, DF_config.gps.positions[i].y)
			  end
			end)	
			frame[i]:SetScript("OnEnter",function(self,button)
				if DF.configmode then
					GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
					GameTooltip:ClearLines()
					GameTooltip:AddLine("DROODFOCUS GPS",1,1,0,nil)
					GameTooltip:AddLine(DF.locale["leftMB"],1,1,1,nil)
					GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
					GameTooltip:Show()		
				end		
			end)		
			frame[i]:SetScript("OnLeave",function(self,button)
				if DF.configmode then GameTooltip:Hide() end
			end)	
			
			-- cadre pour la texture
			overlay[i] = CreateFrame("FRAME","DF_gps_OVERLAY"..i,frame[i])
			
			-- la texture
			overlayTexture[i] = overlay[i]:CreateTexture(nil,"BACKGROUND")
			frameTexture[i] = frame[i]:CreateTexture(nil,"BACKGROUND")
			frameText[i] = overlay[i]:CreateFontString("DF_GPSTEXT","ARTWORK")
			frame[i]:EnableMouse(false)	
		end
	
		local level = DF_config.gps.level*10
	
		-- paramétres cadre principal
		frame[i]:SetMovable(true)
		frame[i]:SetWidth(64)
		frame[i]:SetHeight(64)
		frame[i]:ClearAllPoints()
		frame[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", DF_config.gps.positions[i].x, DF_config.gps.positions[i].y)
		frame[i]:SetFrameLevel(level)	
		
		-- paramétres texture
		frameTexture[i]:SetTexCoord(0, 1, 0, 1)
		frameTexture[i]:ClearAllPoints()
		frameTexture[i]:SetAllPoints(frame[i])
	
		if DF.configmode then
			frameTexture[i]:SetTexture(1,1,1,0.25)
		else
			frameTexture[i]:SetTexture(1,1,1,0)
		end
			
		-- paramétres cadre texture
		overlay[i]:SetMovable(false)
		overlay[i]:EnableMouse(false)		
		overlay[i]:SetWidth(DF_config.gps.width)
		overlay[i]:SetHeight(DF_config.gps.height)
		overlay[i]:SetPoint("CENTER", frame[i], "CENTER", 0, 0)
		overlay[i]:SetFrameLevel(level+1)	
		overlay[i]:SetAlpha(DF_config.gps.alpha)
		
		-- paramétres texture
		overlayTexture[i]:SetTexCoord(0, deltax, 0, deltay)
		overlayTexture[i]:SetBlendMode(DF_config.gps.mode)
		overlayTexture[i]:ClearAllPoints()
		overlayTexture[i]:SetAllPoints(overlay[i])
		overlayTexture[i]:SetTexture("Interface\\Addons\\DroodFocus-TBC\\datas\\Arrow")
		
		-- place la texture dans le cadre
		overlay[i].texture = overlayTexture[i]
	
		DF:MySetFont(frameText[i],DF_config.gps.fontPath,DF_config.gps.fontSize,"OUTLINE")
		frameText[i]:SetNonSpaceWrap(true) 
		frameText[i]:SetShadowColor(0, 0, 0, 0.75)
		frameText[i]:SetShadowOffset(0.5, -0.5)
		frameText[i]:SetTextColor(DF_config.gps.textColor.r, DF_config.gps.textColor.v, DF_config.gps.textColor.b, DF_config.gps.textColor.a)
		frameText[i]:ClearAllPoints()
		frameText[i]:SetPoint("CENTER", overlay[i],"CENTER", DF_config.gps.offsetx, DF_config.gps.offsety)
		frameText[i]:SetText("")
		frameText[i]:SetJustifyH("CENTER")
	
	end
	
end

-- gestion de l'animation
function DF:gps_update()

	if (DF.configmode) then
		for i = 1,2 do
			frameTexture[i]:SetTexture(1,1,1,0.25)
		end
	else
		for i = 1,2 do
			frameTexture[i]:SetTexture(1,1,1,0)
		end
	end
	
	if not DF_config.gps.enable then
		for i = 1,2 do
			overlay[i]:Hide()
		end
		return
	end

	if (DF.configmode) then
		for i = 1,2 do
			overlayTexture[i]:SetTexCoord(0, deltax, 0, deltay)
			frameText[i]:SetText(DF_config.gps.gpsTarget[i])
			overlay[i]:Show()			
		end
		return
	else
		for i = 1,2 do
			overlay[i]:Hide()			
		end		
	end


	for i = 1,2 do
			
		local colonne,ligne,distance = DF:gps_getGpsData(DF_config.gps.gpsTarget[i])
	
		if colonne==nil or ligne==nil or distance==nil then
			overlay[i]:Hide()
		else
	
			overlayTexture[i]:SetTexCoord(colonne*deltax, (colonne*deltax)+deltax, ligne*deltay, (ligne*deltay)+deltay)
			frameText[i]:SetText(DF:doubleNumbers(distance))
			overlay[i]:Show()
		
		end
		
	end
	
end

function DF:gps_getGpsData(gpscible)

	local nom=UnitName(gpscible)
	if not nom then
		return nil,nil,nil
	end
	
	-- cherche la cible dans le roster
	local cible=DF:gps_findPlayer(nom)
	if not cible then
		return nil,nil,nil
	end

	local posX, posY = GetPlayerMapPosition("player")
	local TposX, TposY = GetPlayerMapPosition(cible)
		
	if (TposX==0 and TposY==0) or (posX==0 and posY==0) then
		return nil,nil,nil
	end
	
	local mapW =WorldMapDetailFrame:GetWidth()
	local mapH =WorldMapDetailFrame:GetHeight()		
	
	local diffx = TposX * mapW - posX * mapW
	local diffy = TposY * mapH - posY * mapH
	local distance = (math.sqrt( (diffx * diffx) + (diffy * diffy) ))

	local angle = (math.atan2(posY - TposY, TposX-posX) * 180 / pif)
	local playerfacing = ((GetPlayerFacing()* 180 / pif)-260)%360
	
	local finalangle=(angle-playerfacing)%360
	
	local numero = math.floor(finalangle/3.3333)
	local ligne = math.floor (numero / 9)
	local colonne = numero -(ligne*9)

	return colonne,ligne,distance
	
end

function DF:gps_findPlayer(nom)

	local nb = GetNumRaidMembers()
	for i=1,nb do
		local name = GetRaidRosterInfo(i)
		if (name == nom) then
			return "raid"..tostring(i)
		end
	end

	nb = GetNumPartyMembers()
	for i=1,nb do
		name = UnitName("party"..tostring(i))
		if (name == nom) then
			return "party"..tostring(i)
		end
	end

	return nil
	
end


-- enable/disable déplacement du cadre avec la souris
function DF:gps_toogle_lock(flag)
	
	for i = 1,2 do
		frame[i]:EnableMouse(flag)
	end
	
end

function DF:gps_reinit()
	DF:init_gps_frame()	
end