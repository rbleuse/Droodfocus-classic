----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - anchor
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace
local nbAnchors = nil

-- initialisation frames
function DF:init_anchor_frame()
	nbAnchors = 6

	for i = 1,nbAnchors do
		if not DF.anchor[i] then
			DF.anchor[i] = {}

			-- cadre principal
			DF.anchor[i].base = CreateFrame("FRAME","DF_anchor_BASE"..tostring(i), UIParent)

			-- la texture
			DF.anchor[i].frame = CreateFrame("FRAME","DF_anchor_FRAME"..tostring(i),DF.anchor[i].base)
			DF.anchor[i].framet = CreateFrame("FRAME","DF_anchor_FRAMEt"..tostring(i),DF.anchor[i].base)
			DF.anchor[i].overlay = CreateFrame("FRAME","DF_anchor_OVERLAY"..tostring(i),DF.anchor[i].base)
			DF.anchor[i].overlayTexture = DF.anchor[i].overlay:CreateTexture(nil, "BACKGROUND")
			DF.anchor[i].frameTexture = DF.anchor[i].framet:CreateTexture(nil, "BACKGROUND")
			DF.anchor[i].text = DF.anchor[i].overlay:CreateFontString("DF_ANCHORTEXT"..tostring(i), "ARTWORK")
			DF.anchor[i].base:EnableMouse(false)

			DF.anchor[i].overlay.numero = i

			DF.anchor[i].overlay:EnableMouse(false)
			DF.anchor[i].overlay:SetScript("OnMouseDown",function(self,button)
				if button == "LeftButton" then
					DF.anchor[i].base:StartMoving()
				elseif button == "RightButton" then
					DF:options_show("dfancre"..tostring(i),DF.anchor[i].base)
				end
			end)
			DF.anchor[i].overlay:SetScript("OnMouseUp",function(self,button)
				if button == "LeftButton" then
			  		DF.anchor[i].base:StopMovingOrSizing()
			  		DF_config["anchor"..tostring(i)].positionx = DF:alignToGridX(self:GetLeft())
			  		DF_config["anchor"..tostring(i)].positiony = DF:alignToGridY(self:GetBottom())
			  		DF.anchor[i].base:ClearAllPoints()
			  		DF.anchor[i].base:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", DF_config["anchor"..tostring(i)].positionx, DF_config["anchor"..tostring(i)].positiony)
						DF.environnement["anchor"..tostring(self.numero).."left"]:Hide()
						DF.environnement["anchor"..tostring(self.numero).."top"]:Hide()
						DF.environnement["anchor"..tostring(self.numero).."left"]:Show()
						DF.environnement["anchor"..tostring(self.numero).."top"]:Show()
			  	end
			end)
			DF.anchor[i].overlay:SetScript("OnEnter", function(self,button)
				if DF.configmode then
					GameTooltip:SetOwner(UIParent, "ANCHOR_TOPLEFT", 16, -16)
					GameTooltip:ClearLines()
					GameTooltip:AddLine("DROODFOCUS "..DF_config["anchor"..tostring(self.numero)].info.." ANCHOR", 1, 1, 0, nil)
					GameTooltip:AddLine(DF.locale["leftMB"], 1, 1, 1, nil)
					GameTooltip:AddLine(DF.locale["rightMBanchor"], 1, 1, 1, nil)
					GameTooltip:Show()
				end
			end)
			DF.anchor[i].overlay:SetScript("OnLeave", function(self,button)
				if DF.configmode then GameTooltip:Hide() end
			end)
		end

		local level = DF_config["anchor"..tostring(i)].level*10

		-- paramétres cadre principal
		DF.anchor[i].base:SetMovable(true)
		DF.anchor[i].base:SetWidth(16)
		DF.anchor[i].base:SetHeight(16)
		DF.anchor[i].base:ClearAllPoints()
		DF.anchor[i].base:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", DF_config["anchor"..tostring(i)].positionx, DF_config["anchor"..tostring(i)].positiony)

		-- paramétres cadre qui acceuil éléments
		DF.anchor[i].frame:SetMovable(true)
		DF.anchor[i].frame:SetWidth(DF_config["anchor"..tostring(i)].width)
		DF.anchor[i].frame:SetHeight(DF_config["anchor"..tostring(i)].height)
		DF.anchor[i].frame:ClearAllPoints()
		DF.anchor[i].frame:SetPoint("TOPLEFT", DF.anchor[i].base, "TOPLEFT", 0, 0)

		-- paramétres cadre qui acceuil éléments
		DF.anchor[i].framet:SetMovable(true)
		DF.anchor[i].framet:SetWidth(DF_config["anchor"..tostring(i)].width)
		DF.anchor[i].framet:SetHeight(DF_config["anchor"..tostring(i)].height)
		DF.anchor[i].framet:ClearAllPoints()
		DF.anchor[i].framet:SetPoint("TOPLEFT", DF.anchor[i].base, "TOPLEFT", 0, 0)

		-- paramétres overlay
		DF.anchor[i].overlay:SetMovable(false)
		DF.anchor[i].overlay:SetWidth(16)
		DF.anchor[i].overlay:SetHeight(16)
		DF.anchor[i].overlay:ClearAllPoints()
		DF.anchor[i].overlay:SetPoint("TOPLEFT", DF.anchor[i].frame, "TOPLEFT", 0, 0)
		DF.anchor[i].overlay:SetFrameLevel(255)

		-- paramétres texture
		DF.anchor[i].overlayTexture:SetTexCoord(0, 1, 0, 1)
		DF.anchor[i].overlayTexture:SetWidth(16)
		DF.anchor[i].overlayTexture:SetHeight(16)
		DF.anchor[i].overlayTexture:SetBlendMode("BLEND")
		DF.anchor[i].overlayTexture:ClearAllPoints()
		DF.anchor[i].overlayTexture:SetAllPoints(DF.anchor[i].overlay)
		DF.anchor[i].overlayTexture:SetTexture("Interface\\GossipFrame\\HealerGossipIcon")

		-- paramétres texture
		DF.anchor[i].frameTexture:SetTexCoord(0, 1, 0, 1)
		DF.anchor[i].frameTexture:SetBlendMode(DF_config["anchor"..tostring(i)].mode)
		DF.anchor[i].frameTexture:ClearAllPoints()
		DF.anchor[i].frameTexture:SetAllPoints(DF.anchor[i].framet)
		DF.anchor[i].frameTexture:SetTexture(DF_config["anchor"..tostring(i)].texture)

		DF:MySetFont(DF.anchor[i].text,"Interface\\AddOns\\DroodFocus-classic\\datas\\font.ttf",12,"OUTLINE")
		DF.anchor[i].text:SetShadowColor(0, 0, 0, 0.75)
		DF.anchor[i].text:SetShadowOffset(0.5, -0.5)
		DF.anchor[i].text:SetTextColor(1, 1, 1, 1)
		DF.anchor[i].text:SetPoint("LEFT", DF.anchor[i].overlay,"RIGHT", 0, 1)
		DF.anchor[i].text:SetText(DF_config["anchor"..tostring(i)].info)

		-- place la texture dans le cadre
		DF.anchor[i].overlay.texture = DF.anchor[i].overlayTexture
		DF.anchor[i].framet.texture = DF.anchor[i].frameTexture

		DF.anchor[i].frame:SetScale(DF_config["anchor"..tostring(i)].scale)
		DF.anchor[i].framet:SetScale(DF_config["anchor"..tostring(i)].scale)
		DF.anchor[i].framet:SetFrameLevel(level)

		DF.anchor[i].base:SetFrameLevel(i*5)

		if (DF.lock) then
			DF.anchor[i].overlay:Hide()
		end

		if DF_config["anchor"..tostring(i)].visible then
			DF.anchor[i].frame:Show()
		else
			DF.anchor[i].frame:Hide()
		end
	end
end

-- enable/disable déplacement du cadre avec la souris
function DF:anchor_toogle_lock(flag)

	for i = 1,nbAnchors do
		DF.anchor[i].overlay:EnableMouse(flag)

		if flag then 
			DF.anchor[i].overlay:Show()
		else
			DF.anchor[i].overlay:Hide()
		end
	end
end

function DF:anchor_reinit()
	DF:init_anchor_frame()
end
