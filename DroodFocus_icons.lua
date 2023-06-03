----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - icons
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frames={}
local nbSpells = 0
local iconsOrder = {}
local abiImg=nil
local level=nil
local realWidth=nil
local realHeight=nil
local temps=nil
local temps2=nil

local cd1=0
local dur1=0
local cd2=0
local dur2=0
local rt1=0
local rt2=0
local plus=-1

-- initialisation frames
function DF:init_icons_frame()

	nbSpells = getn(DF_config.spells)

	for i = 1,getn(frames) do
		if i>nbSpells then
			frames[i].frame:Hide()
		end
	end

	for i = 1,nbSpells do
		if not frames[i] then
			frames[i]={}
			frames[i].texts={}

			frames[i].state=0
			frames[i].scale=1
			frames[i].alpha=1

			-- cadre principal
			frames[i].frame = CreateFrame("FRAME","DF_SPELL_FRAME_"..tostring(i),DF.anchor[2].frame)
			frames[i].frame:SetScript("OnMouseDown",function(self,button)
				if button=="LeftButton" then
					if not DF_config.icons.automatic then
						frames[i].frame:StartMoving()
					end
				elseif button=="RightButton" then
					DF:options_show("icons",frames[i].frame)
				end
			end)
			frames[i].frame:SetScript("OnMouseUp",function(self,button)
				if button=="LeftButton" and not DF_config.icons.automatic then
		  		frames[i].frame:StopMovingOrSizing()
		  		local anchorx=DF.anchor[2].frame:GetLeft()
		  		local anchory=DF.anchor[2].frame:GetTop()		  		
		  		DF_config.spells[i].positionx=DF:alignToGridX(self:GetLeft()-anchorx)
		  		DF_config.spells[i].positiony=DF:alignToGridY(self:GetTop()-anchory)
		  		frames[i].frame:ClearAllPoints()
		  		frames[i].frame:SetPoint("TOPLEFT", DF.anchor[2].frame, "TOPLEFT", DF_config.spells[i].positionx, DF_config.spells[i].positiony)
				end
			end)
			frames[i].frame:SetScript("OnEnter",function(self,button)
				if DF.configmode then
					GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT",16,-16)
					GameTooltip:ClearLines()
					GameTooltip:AddLine("DROODFOCUS ICONS",1,1,0,nil)
					GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
					GameTooltip:Show()
				end
			end)
			frames[i].frame:SetScript("OnLeave",function(self,button)
				if DF.configmode then GameTooltip:Hide() end
			end)

			frames[i].overlay = CreateFrame("FRAME","DF_SPELL_OVERLAY_"..tostring(i),frames[i].frame)
			frames[i].texture = frames[i].overlay:CreateTexture(nil,"BACKGROUND")

			frames[i].pointpa  = CreateFrame("FRAME","DF_SPELL_POINTPA_"..tostring(i),frames[i].overlay)
			frames[i].pointpatexture = frames[i].pointpa:CreateTexture(nil,"BACKGROUND")

			frames[i].cooldownframe=CreateFrame("Cooldown","DF_SPELL_COOLDOWN_"..tostring(i),frames[i].overlay)
			frames[i].cooldownframe:SetAllPoints(frames[i].overlay)
			frames[i].cooldownframe.noCooldownCount=true

			for te = 1,3 do
				frames[i].texts[te] = frames[i].frame:CreateFontString("DF_SPELLICON"..tostring(i).."_TEXT"..te,"ARTWORK")
			end
			frames[i].frame:EnableMouse(false)
		end

		level = DF_config.icons.level*10

		iconsOrder[i]=i
		frames[i].activeX=0
		frames[i].activeY=0

		if DF_config.icons.automatic then
			if DF_config.spells[i].positionx==0 and DF_config.spells[i].positiony==0 then
				realWidth=DF_config.icons.width
				realHeight=DF_config.icons.height
			else
				realWidth=DF_config.spells[i].width
				realHeight=DF_config.spells[i].height
			end
		else
			realWidth=DF_config.spells[i].width
			realHeight=DF_config.spells[i].height
		end

		-- paramétres cadre principal
		frames[i].frame:SetMovable(true)

		frames[i].frame:SetWidth(realWidth)
		frames[i].frame:SetHeight(realHeight)
 		frames[i].frame:ClearAllPoints()
		frames[i].frame:SetPoint("TOPLEFT", DF.anchor[2].frame, "TOPLEFT", DF_config.spells[i].positionx, DF_config.spells[i].positiony)
		frames[i].frame:SetFrameLevel(level+4)

		-- paramétres cadre principal
		frames[i].overlay:SetMovable(false)
		frames[i].overlay:EnableMouse(false)
		frames[i].overlay:SetWidth(realWidth)
		frames[i].overlay:SetHeight(realHeight)
		frames[i].overlay:SetPoint("CENTER", frames[i].frame, "CENTER", 0, 0)
		frames[i].overlay:SetFrameLevel(level+1)

		-- paramétres texture
		-- l'icone du premier sort de la liste
		if DF_config.spells[i].names[1]==nil then
			abiImg="Interface\\icons\\INV_Misc_QuestionMark"
		else
			abiImg = GetSpellTexture(DF_config.spells[i].ids[1])
		end
		frames[i].texture:SetTexCoord(0, 1, 0, 1)
		frames[i].texture:SetWidth(64)
		frames[i].texture:SetHeight(64)
		frames[i].texture:SetBlendMode(DF_config.icons.mode)
		frames[i].texture:ClearAllPoints()
		frames[i].texture:SetAllPoints(frames[i].overlay)
		frames[i].texture:SetTexture(abiImg)

		frames[i].overlay.texture = frames[i].texture

		-- paramétres textes
		for t = 1,3 do
			DF:MySetFont(frames[i].texts[t],DF_config.icons.fontPath,DF_config.icons.textsoffsets[t].size,"OUTLINE")
			frames[i].texts[t]:SetShadowColor(0, 0, 0, 0.75)
			frames[i].texts[t]:SetShadowOffset(0.5, -0.5)
			frames[i].texts[t]:SetWidth(64)
			frames[i].texts[t]:SetHeight(32)			
			frames[i].texts[t]:SetTextColor(DF_config.icons.textColor.r, DF_config.icons.textColor.v, DF_config.icons.textColor.b, DF_config.icons.textColor.a)
			frames[i].texts[t]:SetText("")

			frames[i].texts[t]:SetJustifyH('CENTER')
			frames[i].texts[t]:SetJustifyV('MIDDLE')

			if string.find(DF_config.icons.textsoffsets[t].align, "TOP") then
				frames[i].texts[t]:SetJustifyV('TOP')
			end
			if string.find(DF_config.icons.textsoffsets[t].align, "BOTTOM") then
				frames[i].texts[t]:SetJustifyV('BOTTOM')
			end
			if string.find(DF_config.icons.textsoffsets[t].align, "LEFT") then
				frames[i].texts[t]:SetJustifyH('LEFT')
			end
			if string.find(DF_config.icons.textsoffsets[t].align, "RIGHT") then
				frames[i].texts[t]:SetJustifyH('RIGHT')
			end
			frames[i].texts[t]:ClearAllPoints()
		end

		frames[i].texts[1]:SetPoint(DF_config.icons.textsoffsets[1].align, frames[i].overlay,DF_config.icons.textsoffsets[1].align, DF_config.icons.textsoffsets[1].offsetx, DF_config.icons.textsoffsets[1].offsety)
		frames[i].texts[2]:SetPoint(DF_config.icons.textsoffsets[2].align, frames[i].overlay,DF_config.icons.textsoffsets[2].align, DF_config.icons.textsoffsets[2].offsetx, DF_config.icons.textsoffsets[2].offsety)
		frames[i].texts[3]:SetPoint(DF_config.icons.textsoffsets[3].align, frames[i].overlay,DF_config.icons.textsoffsets[3].align, DF_config.icons.textsoffsets[3].offsetx, DF_config.icons.textsoffsets[3].offsety)

		-- paramétres cadre pointPA
		frames[i].pointpa:SetMovable(false)
		frames[i].pointpa:EnableMouse(false)
		frames[i].pointpa:SetWidth(20)
		frames[i].pointpa:SetHeight(20)
		frames[i].pointpa:SetPoint("TOPRIGHT", frames[i].frame, "TOPRIGHT", 1, 1)
		frames[i].pointpa:SetFrameLevel(level+3)
		frames[i].pointpa:SetAlpha(0.75)

		frames[i].pointpatexture:SetTexCoord(0, 1, 0, 1)
		frames[i].pointpatexture:SetBlendMode("ADD")
		frames[i].pointpatexture:ClearAllPoints()
		frames[i].pointpatexture:SetAllPoints(frames[i].pointpa)
		frames[i].pointpatexture:SetTexture("Interface\\AddOns\\DroodFocus-TBC\\datas\\ooc2.tga")

		DF:icons_SetCooldown(i,0,0)
		frames[i].cooldownframe:Hide()
		if DF_config.icons.showSpiral==3 then
			frames[i].cooldownframe:SetReverse(false)
		else
			frames[i].cooldownframe:SetReverse(true)
		end
		frames[i].cooldownframe:SetDrawEdge(true)

		if not DF_config.icons.enable or not DF_config.spells[i].icon then
			frames[i].frame:Hide()
		else
			frames[i].frame:Show()
		end
	end
end

-- gestion de l'animation
function DF:icons_update()
	if not DF_config.icons.enable then return end

	local mini=1
	local fadingPulse=0
	local finalAlpha=0
	local form = nil
	local currentForm = DF:currentForm()
	local iconPower	=nil
	local currentPower	=nil
	local targetID=UnitGUID("target")
	local restant

	-- anime
	for i = 1,nbSpells do
		form = DF_config.spells[i].form

		-- fin si pas bonne forme
		if DF_config.spells[i].icon and (DF:form_goofForm(form,currentForm) or DF_config.spells[i].alwaysVisible) then
			frames[i].frame:Show()

			-- scaling et alpha
			frames[i].alpha = frames[i].alpha - 0.025
			frames[i].scale = frames[i].scale - 0.025

			mini=DF_config.icons.activeAlpha
			if frames[i].state==0 then
				mini=DF_config.icons.inactiveAlpha
			end

			if DF_config.icons.pointpa then
				currentPower=DF:spell_getPowerAttack()
				iconPower = DF_config.spells[i].abiPower[targetID]

				if not iconPower then
					frames[i].pointpa:Hide()
				else
					if (currentPower==iconPower or iconPower==0) then
						frames[i].pointpatexture:SetVertexColor(1, 1, 1,0.5)
						frames[i].pointpa:Show()
					elseif (currentPower>iconPower) then
						frames[i].pointpatexture:SetVertexColor(0, 1, 0,1)
						frames[i].pointpa:Show()
					elseif (currentPower<iconPower) then
						frames[i].pointpatexture:SetVertexColor(1, 0, 0,1)
						frames[i].pointpa:Show()
					end
				end
			else
				frames[i].pointpa:Hide()
			end

			-- clignotage de l'icone
			if DF_config.icons.showSpiral==1 then
				if (DF_config.spells[i].abiTimeLeft>0 and DF_config.spells[i].abiTimeLeft<3) then
					fadingPulse = 0.01+((3-DF_config.spells[i].abiTimeLeft)/12.5)
					DF_config.spells[i].abiAlphaPulse = DF_config.spells[i].abiAlphaPulse + fadingPulse
					if (DF_config.spells[i].abiAlphaPulse>0.95) then
						DF_config.spells[i].abiAlphaPulse = 0
					end
				else
					DF_config.spells[i].abiAlphaPulse = 0
				end
			end

			if frames[i].alpha<mini then
				frames[i].alpha=mini
			end
			if frames[i].scale<1 then frames[i].scale=1 end

			finalAlpha = frames[i].alpha-DF_config.spells[i].abiAlphaPulse
			if finalAlpha<0 then finalAlpha=0 end
			if finalAlpha>1 or DF.configmode then finalAlpha=1 end

			frames[i].overlay:SetAlpha(finalAlpha)
			frames[i].overlay:SetScale(frames[i].scale)

			-- màj texte temps restant
			if DF_config.icons.textsoffsets[1].visible then
				if DF_config.spells[i].abiTimeLeft>0 then
					if DF_config.spells[i].abiTimeLeft<3 and DF_config.icons.decimal then
						frames[i].texts[1]:SetText(DF:floatNumbers(DF_config.spells[i].abiTimeLeft))
					else
						frames[i].texts[1]:SetText(DF:numbers(DF_config.spells[i].abiTimeLeft))
					end
				else
					if DF.configmode then
						frames[i].texts[1]:SetText("8")
					else
						frames[i].texts[1]:SetText("")
					end
				end

				frames[i].texts[1]:Show()
			else
				frames[i].texts[1]:Hide()
			end

			-- maj texte stack
			if DF_config.icons.textsoffsets[2].visible then
				if DF_config.spells[i].abiStack>0 then
					frames[i].texts[2]:SetText(DF:numbers(DF_config.spells[i].abiStack))
				else
					if DF.configmode then
						frames[i].texts[2]:SetText("8")
					else
						frames[i].texts[2]:SetText("")
					end
				end

				frames[i].texts[2]:Show()
			else
				frames[i].texts[2]:Hide()
			end

			-- maj texte CD
			if DF_config.icons.textsoffsets[3].visible then
				local debutCD, dureeCD = DF:cooldown_getCD(DF_config.spells[i].abiSpelltext,DF_config.spells[i].abiSpellId)

				if debutCD>0 and dureeCD>0 then
					restant = (debutCD+dureeCD)-DF.currentTime
					if restant<0 then
						restant=0
						frames[i].texts[3]:SetText("")
					else
						frames[i].texts[3]:SetText(DF:numbers(restant))
					end
				else
					if DF.configmode then
						frames[i].texts[3]:SetText("8")
					else
						frames[i].texts[3]:SetText("")
					end
				end

				frames[i].texts[3]:Show()
			else
				frames[i].texts[3]:Hide()
			end
		else
			frames[i].frame:Hide()
		end
	end

	-- classement barres par temps restant
	-- a chaque cycle les barres remonte si le temps est plus court
	if DF_config.icons.orderByTime and DF_config.icons.automatic then
		local num, numPrec
		for i = 2,nbSpells do

			num = iconsOrder[i]
			numPrec = iconsOrder[i-1]

			temps=DF_config.spells[num].abiTimeLeft
			temps2=DF_config.spells[numPrec].abiTimeLeft

			cd1=0
			dur1=0
			cd2=0
			dur2=0
			rt1=0
			rt2=0

			if DF_config.spells[num].showcd then
				cd1,dur1=DF:cooldown_getCD(DF_config.spells[num].abiSpelltext,DF_config.spells[num].abiSpellId)
				rt1=(cd1+dur1)-DF.currentTime
			end

			if DF_config.spells[numPrec].showcd then
				cd2,dur2=DF:cooldown_getCD(DF_config.spells[numPrec].abiSpelltext,DF_config.spells[numPrec].abiSpellId)
				rt2=(cd2+dur2)-DF.currentTime
			end

			plus=-1
			if DF_config.icons.growup then
				plus=500
			end

			if temps==0 and rt1<=0 then temps=plus end
			if temps2==0 and rt2<=0 then temps2=plus end

			-- si temps i inférieur a temps i-1 mais pas egale a 0, on échange les places
			--  and DF_config.spells[num].abiTimeLeft~=0
			if temps<temps2 then
				-- inverse
				iconsOrder[i]= numPrec
				iconsOrder[i-1] = num
			end
		end
	end

	-- replacement icons a la bonne position
	if DF_config.icons.automatic then

		local offsetx=0
		local offsety=0
		local colonne=1
		local num

		for i = 1,nbSpells do
			-- num = barre a replacer
			num = iconsOrder[i]

			form = DF_config.spells[num].form

			-- bonne forme?
			if DF_config.spells[num].icon and (DF:form_goofForm(form,currentForm) or DF_config.spells[num].alwaysVisible) then
				-- si pas d'override de la position automatique par les coordonnées
				if tonumber(DF_config.spells[num].positionx)==0 and tonumber(DF_config.spells[num].positiony)==0 then
					-- placement auto
					frames[num].frame:ClearAllPoints()
					frames[num].frame:SetPoint("TOPLEFT", DF.anchor[2].frame, "TOPLEFT", frames[num].activeX+8, frames[num].activeY-8)

					if frames[num].activeX<offsetx then
						frames[num].activeX=frames[num].activeX+DF_config.icons.speed
						if frames[num].activeX>offsetx then
							frames[num].activeX=offsetx
						end
					end
					if frames[num].activeX>offsetx then
						frames[num].activeX=frames[num].activeX-DF_config.icons.speed
						if frames[num].activeX<offsetx then
							frames[num].activeX=offsetx
						end
					end

					if frames[num].activeY<offsety then
						frames[num].activeY=frames[num].activeY+DF_config.icons.speed
						if frames[num].activeY>offsety then
							frames[num].activeY=offsety
						end
					end
					if frames[num].activeY>offsety then
						frames[num].activeY=frames[num].activeY-DF_config.icons.speed
						if frames[num].activeY<offsety then
							frames[num].activeY=offsety
						end
					end

					offsetx=offsetx+ realWidth+2
					colonne=colonne+1
					if colonne>DF_config.icons.colonne then
						colonne=1
						offsety=offsety- (realHeight+2)
						offsetx=0
					end
				else
					-- placement normal
					frames[num].frame:ClearAllPoints()
					frames[num].frame:SetPoint("TOPLEFT", DF.anchor[2].frame, "TOPLEFT", DF_config.spells[num].positionx, DF_config.spells[num].positiony)
				end
			end
		end
	end
end

function DF:icons_activate(num)
	if frames[num] then
		if DF_config.icons.showSpiral==2 or DF_config.icons.showSpiral==3 then
			DF:icons_SetCooldown(num,DF_config.spells[num].abiEnd-DF_config.spells[num].abiDuration,DF_config.spells[num].abiDuration)
			frames[num].cooldownframe:Show()
		end
		frames[num].state = 1
	end
end

function DF:icons_desactivate(num)
	if frames[num] then
		if frames[num].state~=0 then
			if DF_config.icons.showSpiral==2 or DF_config.icons.showSpiral==3 then
				DF:icons_SetCooldown(num,0,0)
				frames[num].cooldownframe:Hide()
			end
		end

		frames[num].state = 0
	end
end


function DF:icons_pulse(num)
	frames[num].scale = DF_config.icons.pulse
end

-- enable/disable déplacement du cadre avec la souris
function DF:icons_toogle_lock(flag)
	for i = 1,nbSpells do
		frames[i].frame:EnableMouse(flag)
	end
end

function DF:icons_reinit()
	DF:init_icons_frame()
end

function DF:icons_SetCooldown(numero,start,duration)
	frames[numero].cooldownframe:SetCooldown(start,duration)
end
