----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - arrows
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

local frames={
	{frame=nil,texture=nil},
	{frame=nil,texture=nil},
	{frame=nil,texture=nil},
	{frame=nil,texture=nil},
}

-- initialisation frames
function DF:init_arrows_frame()

	for i = 1,4 do
		if not frames[i].frame then
			-- cadre principal
			frames[i].frame = CreateFrame("FRAME","DF_ARROW_FRAME"..tostring(i),DF.anchor[1].frame)
			frames[i].texture =frames[i].frame:CreateTexture("DF_ARROW_FRAME_TEXTURE"..tostring(i),"BACKGROUND")
		end

		local level = DF_config.powerbar.level*10

		-- paramétres cadre principal
		frames[i].frame:SetMovable(false)
		frames[i].frame:EnableMouse(false)		
		frames[i].frame:SetWidth(16)
		frames[i].frame:SetHeight(16)
		frames[i].frame:SetPoint("LEFT", DF:powerbar_get_pt(), "LEFT", 0, 0)
		frames[i].frame:SetFrameLevel(level+3)
		frames[i].frame:SetAlpha(1)

		if DF_config.powerbar.orientation=="VERTICAL" then
			frames[i].texture:SetTexCoord(0, 1, 0.5, 1)
		else
			frames[i].texture:SetTexCoord(0, 1, 0, 0.5)
		end

		frames[i].texture:SetAllPoints(frames[i].frame)
		frames[i].texture:SetTexture("Interface\\AddOns\\DroodFocus-TBC\\datas\\miniArrows.tga")
		frames[i].texture:SetBlendMode("BLEND")
	end

	if not DF_config.powerbar.enableArrows or not DF_config.powerbar.enable then
		for i = 1,4 do
			frames[i].frame:Hide()
		end
	end
end

-- gestion de l'animation
function DF:arrows_update()
	if not DF_config.powerbar.enableArrows or not DF_config.powerbar.enable then return end

	local currentForm = DF:currentForm()
	if not DF:form_goofForm(DF_config.powerbar.form,currentForm) then
		for i = 1,4 do
			frames[i].frame:Hide()
		end
		return
	else
		for i = 1,4 do
			frames[i].frame:Show()
		end
	end

	local value=0
	local cout=0

	for i = 1,4 do
		cout = DF_config.powerbar.arrows[i]

		if cout == nil then cout = -1 end

		if cout >= 0 and cout < 100 then -- indicateur actif
			value = (cout/100)
			frames[i].frame:ClearAllPoints()

			if DF_config.powerbar.orientation=="VERTICAL" then
				frames[i].frame:SetPoint("TOPLEFT", DF:powerbar_get_pt(), "TOPLEFT", -DF_config.powerbar.borderSize-4, (-value*DF_config.powerbar.height)-1)
			else
				frames[i].frame:SetPoint("TOPLEFT", DF:powerbar_get_pt(), "TOPLEFT", (value*DF_config.powerbar.width)-1, -DF_config.powerbar.borderSize+5)
			end
			frames[i].frame:Show()
		else
			frames[i].frame:Hide()
		end
	end
end
