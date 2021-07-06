----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - timerbars
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frames={}
local nbSpells = 0
local barsOrder = {}
local restant

-- initialisation frames
function DF:init_timerbars_frame()
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
			frames[i].alpha=1

			-- cadre principal
			frames[i].frame = CreateFrame("FRAME","DF_TIMERBAR_FRAME"..tostring(i),DF.anchor[3].frame)
			frames[i].frame:SetScript("OnMouseDown",function(self,button)
					if button=="RightButton" then
		  			DF:options_show("timerbar",frames[i].frame)
		  		end
			end)
			frames[i].frame:SetScript("OnEnter",function(self,button)
				if DF.configmode then
					GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT ",16,-16)
					GameTooltip:ClearLines()
					GameTooltip:AddLine("DROODFOCUS TIMERBAR",1,1,0,nil)
					GameTooltip:AddLine(DF.locale["rightMB"],1,1,1,nil)
					GameTooltip:Show()
				end
			end)
			frames[i].frame:SetScript("OnLeave",function(self,button)
				if DF.configmode then GameTooltip:Hide() end
			end)

			-- cadre pour la texture
			frames[i].background = CreateFrame("StatusBar","DF_TIMERBAR_BACKGROUND"..tostring(i),frames[i].frame)
			frames[i].foreground = CreateFrame("StatusBar","DF_TIMERBAR_FOREGROUND"..tostring(i),frames[i].frame)
			frames[i].cooldown = CreateFrame("StatusBar","DF_TIMERBAR_cooldown"..tostring(i),frames[i].frame)
			frames[i].spark =  CreateFrame("FRAME","DF_TIMERBAR_SPARK"..tostring(i),frames[i].foreground)

			for te = 1,2 do
				frames[i].texts[te] = frames[i].foreground:CreateFontString("DF_TIMERBAR"..tostring(i).."_TEXT"..tostring(te),"ARTWORK")
			end
			frames[i].frame:EnableMouse(false)
			frames[i].frameTexture=frames[i].frame:CreateTexture(nil)
			frames[i].sparkTexture=frames[i].spark:CreateTexture(nil)
		end

		local level = DF_config.timerbar.level*10

		barsOrder[i]=i

		-- attribution du cadre parent
		if DF_config.spells[i].timerbar==1 then
			frames[i].frame:SetParent(DF.anchor[3].frame)
		elseif DF_config.spells[i].timerbar==2 then
			frames[i].frame:SetParent(DF.anchor[4].frame)
		end

		-- paramétres cadre principal
		frames[i].frame:SetMovable(false)

		frames[i].frame:SetWidth(DF_config.timerbar.width)
		frames[i].frame:SetHeight(DF_config.timerbar.height)
		frames[i].frame:ClearAllPoints()
		frames[i].frame:SetPoint("TOPLEFT", DF.anchor[3].frame, "TOPLEFT", 0, -16-((i-1)*DF_config.timerbar.height))
		frames[i].frame:SetFrameLevel(level)

		if DF_config.timerbar.border then
			frames[i].frameTexture:ClearAllPoints()
			frames[i].frameTexture:SetAllPoints(frames[i].frame)
			frames[i].frameTexture:SetColorTexture(DF_config.timerbar.borderColor.r, DF_config.timerbar.borderColor.v, DF_config.timerbar.borderColor.b,DF_config.timerbar.borderColor.a)
			frames[i].frame.texture=frames[i].frameTexture
		else
			frames[i].frameTexture:ClearAllPoints()
			frames[i].frameTexture:SetAllPoints(frames[i].frame)
			frames[i].frameTexture:SetColorTexture(DF_config.timerbar.borderColor.r, DF_config.timerbar.borderColor.v, DF_config.timerbar.borderColor.b,0)
			frames[i].frame.texture=frames[i].frameTexture	
		end

		-- paramétres background
		frames[i].background:SetWidth(DF_config.timerbar.width-DF_config.timerbar.borderSize*2)
		frames[i].background:SetHeight(DF_config.timerbar.height-DF_config.timerbar.borderSize*2)
		frames[i].background:ClearAllPoints()
		frames[i].background:SetPoint("TOPLEFT", frames[i].frame, "TOPLEFT", DF_config.timerbar.borderSize, -DF_config.timerbar.borderSize)
		frames[i].background:SetStatusBarTexture(DF_config.timerbar.texturePath)
		frames[i].background:SetStatusBarColor(DF_config.spells[i].color.r/3, DF_config.spells[i].color.v/3, DF_config.spells[i].color.b/3, DF_config.spells[i].color.a)
		frames[i].background:SetOrientation("HORIZONTAL")
		frames[i].background:SetFrameLevel(level+2)

		-- paramétres foreground
		frames[i].foreground:SetWidth(DF_config.timerbar.width-DF_config.timerbar.borderSize*2)
		frames[i].foreground:SetHeight(DF_config.timerbar.height-DF_config.timerbar.borderSize*2)
		frames[i].foreground:ClearAllPoints()
		frames[i].foreground:SetPoint("TOPLEFT", frames[i].frame, "TOPLEFT", DF_config.timerbar.borderSize, -DF_config.timerbar.borderSize)
		frames[i].foreground:SetStatusBarTexture(DF_config.timerbar.texturePath)
		frames[i].foreground:SetStatusBarColor(DF_config.spells[i].color.r, DF_config.spells[i].color.v, DF_config.spells[i].color.b, DF_config.spells[i].color.a)
		frames[i].foreground:SetOrientation("HORIZONTAL")
		frames[i].foreground:SetMinMaxValues(0, 100)
		frames[i].foreground:SetFrameLevel(level+3)

		-- paramétres cooldown
		frames[i].cooldown:SetWidth((DF_config.timerbar.width-DF_config.timerbar.borderSize*2)-2)
		frames[i].cooldown:SetHeight(3)
		frames[i].cooldown:ClearAllPoints()
		frames[i].cooldown:SetPoint("BOTTOM", frames[i].foreground, "BOTTOM", DF_config.timerbar.cdoffsetx, DF_config.timerbar.cdoffsety)
		frames[i].cooldown:SetStatusBarTexture("Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar3.tga")
		frames[i].cooldown:SetStatusBarColor(DF_config.timerbar.cdColor.r, DF_config.timerbar.cdColor.v, DF_config.timerbar.cdColor.b, DF_config.timerbar.cdColor.a)
		frames[i].cooldown:SetOrientation("HORIZONTAL")
		frames[i].cooldown:SetMinMaxValues(0, 1)
		frames[i].cooldown:SetFrameLevel(level+4)

		frames[i].spark:SetMovable(false)
		frames[i].spark:EnableMouse(false)
		frames[i].spark:SetWidth(20)
		frames[i].spark:SetHeight(DF_config.timerbar.height*2.2)
		frames[i].spark:ClearAllPoints()
		frames[i].spark:SetPoint("LEFT", frames[i].foreground, "LEFT", 0, 0)

		frames[i].sparkTexture:ClearAllPoints()
		frames[i].sparkTexture:SetAllPoints(frames[i].spark)
		frames[i].sparkTexture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		frames[i].sparkTexture:SetBlendMode("ADD")
		frames[i].spark.texture=frames[i].sparkTexture
		frames[i].spark:SetFrameLevel(255)

		-- paramétres textes
		DF:MySetFont(frames[i].texts[1],DF_config.timerbar.font1Path,DF_config.timerbar.font1Size,"OUTLINE")
		DF:MySetFont(frames[i].texts[2],DF_config.timerbar.font2Path,DF_config.timerbar.font2Size,"OUTLINE")

		for t = 1,2 do
			frames[i].texts[t]:SetShadowColor(0, 0, 0, 0.75)
			frames[i].texts[t]:SetShadowOffset(0.5, -0.5)
			frames[i].texts[t]:SetTextColor(DF_config.timerbar.textColor.r, DF_config.timerbar.textColor.v, DF_config.timerbar.textColor.b, DF_config.timerbar.textColor.a)
			frames[i].texts[t]:SetText("")
			frames[i].texts[t]:ClearAllPoints()
		end

		frames[i].texts[1]:SetPoint("LEFT", frames[i].foreground,"LEFT", DF_config.timerbar.textsoffsets[1].offsetx, DF_config.timerbar.textsoffsets[1].offsety)
		frames[i].texts[2]:SetPoint("RIGHT", frames[i].foreground,"RIGHT", DF_config.timerbar.textsoffsets[2].offsetx, DF_config.timerbar.textsoffsets[2].offsety)

		frames[i].texts[1]:SetText("SPELL")
		frames[i].texts[2]:SetText("88")

		if not DF_config.timerbar.enable or DF_config.spells[i].timerbar~=0 then
			frames[i].frame:Hide()
		else
			frames[i].frame:Show()
		end

		if not DF_config.timerbar.showSpark then
			frames[i].spark:Hide()
		else
			frames[i].spark:Show()
		end
	end
end

-- gestion de l'animation
function DF:timerbars_update()
	if not DF_config.timerbar.enable then return end

	local form = nil
	local currentForm = DF:currentForm()
	local texte =""
	local cursor =0

	local barsCounter1=1
	local barsCounter2=1

	local num=0
	local numPrec=0

	local debutCD=nil
	local dureeCD=nil

	local largeur = DF_config.timerbar.width-DF_config.timerbar.borderSize*2

	nbSpells = getn(DF_config.spells)
	-- anime
	for i = 1,nbSpells do
		form = DF_config.spells[i].form

		-- fin si pas bonne forme
		if DF_config.spells[i].timerbar~=0 and (DF:form_goofForm(form,currentForm) or DF_config.spells[i].alwaysVisible) then
			frames[i].frame:Show()
			if DF_config.spells[i].abiUserText=="" then
				texte = DF_config.spells[i].abiSpelltext
			else
				texte = DF_config.spells[i].abiUserText
			end

			if DF_config.spells[i].abiStack>0 then
				texte=texte.." x"..DF:numbers(DF_config.spells[i].abiStack)
			end

			if DF_config.spells[i].names[1]==nil then texte=DF.locale["unknow"] end

			frames[i].texts[1]:SetText(texte)

			frames[i].alpha = frames[i].alpha - 0.025

			-- màj texte temps restant
			if DF_config.spells[i].abiTimeLeft>0 then
				if DF_config.spells[i].abiTimeLeft<60 then
					frames[i].texts[2]:SetText(DF:numbers(DF_config.spells[i].abiTimeLeft))
				else
					frames[i].texts[2]:SetText(DF:minutes(DF_config.spells[i].abiTimeLeft))
				end

				if frames[i].alpha<DF_config.timerbar.activeAlpha then
					frames[i].alpha=DF_config.timerbar.activeAlpha
				end
			else
				frames[i].texts[2]:SetText("-")

				if frames[i].alpha<DF_config.timerbar.inactiveAlpha then
					frames[i].alpha=DF_config.timerbar.inactiveAlpha
				end
			end

			if (DF.configmode) then 
				if frames[i].alpha<DF_config.timerbar.activeAlpha then
					frames[i].alpha=DF_config.timerbar.activeAlpha
				end
			end

			frames[i].frame:SetAlpha(frames[i].alpha)

			debutCD,dureeCD=DF:cooldown_getCD(DF_config.spells[i].abiSpelltext,DF_config.spells[i].abiSpellId)
			if debutCD>0 and dureeCD>0 and DF_config.spells[i].showcd then
				restant = (debutCD+dureeCD)-DF.currentTime

				if restant<0 then
					restant=0
					frames[i].cooldown:Hide()
				else
					if frames[i].alpha<DF_config.timerbar.activeAlphaCD then
						frames[i].alpha=DF_config.timerbar.activeAlphaCD
					end
					frames[i].frame:SetAlpha(frames[i].alpha)
					frames[i].cooldown:Show()
					frames[i].cooldown:SetValue(restant/dureeCD)
				end
			else
				frames[i].cooldown:Hide()
			end

			if DF_config.timerbar.prop then
				if DF_config.spells[i].abiDuration==0 then
					cursor=0
				else
					cursor = (DF_config.spells[i].abiTimeLeft/DF_config.spells[i].abiDuration)*100
				end
			else
				if DF_config.spells[i].abiTimeLeft<=DF_config.timerbar.timeline then
					cursor = (((largeur/DF_config.timerbar.timeline)*DF_config.spells[i].abiTimeLeft)/largeur)*100
				else
					cursor=100
				end
			end

			if (DF.configmode) then
				cursor=50
				frames[i].texts[2]:SetText("0:00")
				frames[i].cooldown:SetValue(0.75)
				frames[i].cooldown:Show()
			end

			frames[i].foreground:SetValue(cursor)

			DF:timerbars_sparck(cursor,i)
		else
			frames[i].frame:Hide()
		end
	end

	-- classement barres par temps restant
	-- a chaque cycle les barres remonte si le temps est plus court
	if DF_config.timerbar.orderByTime then
		for i = 2,nbSpells do
			num = barsOrder[i]
			numPrec = barsOrder[i-1]

			local temps=DF_config.spells[num].abiTimeLeft
			local temps2=DF_config.spells[numPrec].abiTimeLeft

			local cd1=0
			local dur1=0
			local cd2=0
			local dur2=0
			local rt1=0
			local rt2=0

			if DF_config.spells[num].showcd then
				cd1,dur1=DF:cooldown_getCD(DF_config.spells[num].abiSpelltext,DF_config.spells[num].abiSpellId)
				rt1=(cd1+dur1)-DF.currentTime
			end

			if DF_config.spells[numPrec].showcd then
				cd2,dur2=DF:cooldown_getCD(DF_config.spells[numPrec].abiSpelltext,DF_config.spells[numPrec].abiSpellId)
				rt2=(cd2+dur2)-DF.currentTime
			end

			local plus=-1
			if DF_config.timerbar.growup then
				plus=500
			end

			if temps==0 and rt1<=0 then temps=plus end
			if temps2==0 and rt2<=0 then temps2=plus end

			-- si temps i inférieur a temps i-1 mais pas egale a 0, on échange les places
			--  and DF_config.spells[num].abiTimeLeft~=0
			if temps<temps2 then
				-- inverse
				barsOrder[i]= numPrec
				barsOrder[i-1] = num
			end
		end
	end

	-- replacement barres dans leur ancres respectives et a la bonne position
	barsCounter1=0
	barsCounter2=0
	for i = 1,nbSpells do
		-- num = barre a replacer
		num = barsOrder[i]

		form = DF_config.spells[num].form

		if DF_config.spells[num].timerbar~=0 and (DF:form_goofForm(form,currentForm) or DF_config.spells[num].alwaysVisible) then
			if DF_config.spells[num].timerbar==1 then
				-- replacement dans ancre 3
				frames[num].frame:ClearAllPoints()
				frames[num].frame:SetPoint("TOPLEFT", DF.anchor[3].frame, "TOPLEFT", 8, -8-(barsCounter1*DF_config.timerbar.height))
				barsCounter1=barsCounter1+1
			elseif DF_config.spells[num].timerbar==2 then
				-- replacement dans ancre 4
				frames[num].frame:ClearAllPoints()
				frames[num].frame:SetPoint("TOPLEFT", DF.anchor[4].frame, "TOPLEFT", 8, -8-(barsCounter2*DF_config.timerbar.height))
				barsCounter2=barsCounter2+1
			end
		end
	end
end

function DF:timerbars_sparck(cursor,num)
	local largeur=DF_config.timerbar.width-(DF_config.timerbar.borderSize*2)

	if cursor>0 and cursor<100 and DF_config.timerbar.showSpark then
		local sparckx=((cursor/100)*largeur)-10
		frames[num].spark:SetPoint("LEFT", frames[num].foreground, "LEFT", sparckx, -1)
		frames[num].spark:Show()
	else
		frames[num].spark:Hide()
	end
end

-- enable/disable déplacement du cadre avec la souris
function DF:timerbars_toogle_lock(flag)
	nbSpells = getn(DF_config.spells)
	for i = 1,nbSpells do
		frames[i].frame:EnableMouse(flag)
	end
end

function DF:timerbar_reinit()
	DF:init_timerbars_frame()
end