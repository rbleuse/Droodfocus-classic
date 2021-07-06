----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - Minimap
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

-- broker
DF.LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local DF_broker = DF.LDB:NewDataObject("Broker_DroodFocus", {
	type = "launcher",
	icon = "Interface\\icons\\Ability_Druid_CatForm",
	label = "DroodFocus",
	text  = "DroodFocus",

	OnClick = function(self, btn)
		if (btn=="LeftButton") then
			DF:options_show("DFOPTIONSelement")
		elseif (btn=="RightButton") then
			DF:toogle_configmode()
		end
	end,

	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		tooltip:AddLine( DF.locale["versionName"].." (Broker)",1,1,0,nil )
		tooltip:AddLine( DF.locale["brokerInfo1"],1,1,1,nil )
		tooltip:AddLine( DF.locale["brokerInfo2"],1,1,1,nil )
	end,
})

DF_MinimapButton = CreateFrame('Button', 'DroodFocusMinimapButton', Minimap)

function DF:DF_MinimapLoad()
	-- minimap
	DF_MinimapButton:SetWidth(31)
	DF_MinimapButton:SetHeight(31)
	DF_MinimapButton:SetFrameLevel(8)
	DF_MinimapButton:RegisterForClicks('anyUp')
	DF_MinimapButton:RegisterForDrag('LeftButton')
	DF_MinimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')

	local overlay = DF_MinimapButton:CreateTexture(nil, 'OVERLAY')
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
	overlay:SetPoint('TOPLEFT')

	local icon = DF_MinimapButton:CreateTexture(nil, 'BACKGROUND')
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetTexture("Interface\\icons\\Ability_Druid_CatForm")
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	icon:SetPoint('TOPLEFT', 7, -5)
	DF_MinimapButton.icon = icon
	DF_MinimapButton:SetScript('OnDragStart', DF_MinimapButton.OnDragStart)
	DF_MinimapButton:SetScript('OnDragStop', DF_MinimapButton.OnDragStop)
	DF_MinimapButton:SetScript('OnMouseDown', DF_MinimapButton.OnMouseDown)
	DF_MinimapButton:SetScript('OnMouseUp', DF_MinimapButton.OnMouseUp)
	DF_MinimapButton:SetScript('OnEnter', DF_MinimapButton.OnEnter)
	DF_MinimapButton:SetScript('OnLeave', DF_MinimapButton.OnLeave)
	DF_MinimapButton:SetScript('OnClick', DF_broker.OnClick)

	DF_MinimapToggle()
	DF_Minimap_Update()
end

function DF_MinimapToggle()
	if DF_config.minimap then
		DF_MinimapButton:Show()
	else
		DF_MinimapButton:Hide()
	end
end

function DF_MinimapButton:OnEnter()
	if not self.dragging then
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
		DF_broker.OnTooltipShow(GameTooltip)
		GameTooltip:Show()
	end
end

function DF_MinimapButton:OnLeave()
	GameTooltip:Hide()
end

function DF_MinimapButton:OnMouseDown()
	self.icon:SetTexCoord(0, 1, 0, 1)
end

function DF_MinimapButton:OnMouseUp()
	self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
end

function DF_MinimapButton:OnDragStart()
	self.dragging = true
	self:LockHighlight()
	self.icon:SetTexCoord(0, 1, 0, 1)
	self:SetScript('OnUpdate', self.OnUpdate)
	GameTooltip:Hide()
end

function DF_MinimapButton:OnDragStop()
	self.dragging = nil
	self:SetScript('OnUpdate', nil)
	self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	self:UnlockHighlight()
end

function DF_MinimapButton:OnUpdate()
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	DF_config.MiniMapAngle = math.deg(math.atan2(py - my, px - mx)) % 360
	self:UpdatePosition()
end

function DF_MinimapButton:UpdatePosition()
	local angle = math.rad(DF_config.MiniMapAngle)
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	local minimapShape = GetMinimapShape and GetMinimapShape() or 'ROUND'

	local round = false
	if minimapShape == 'ROUND' then
		round = true
	elseif minimapShape == 'SQUARE' then
		round = false
	elseif minimapShape == 'CORNER-TOPRIGHT' then
		round = not(cos < 0 or sin < 0)
	elseif minimapShape == 'CORNER-TOPLEFT' then
		round = not(cos > 0 or sin < 0)
	elseif minimapShape == 'CORNER-BOTTOMRIGHT' then
		round = not(cos < 0 or sin > 0)
	elseif minimapShape == 'CORNER-BOTTOMLEFT' then
		round = not(cos > 0 or sin > 0)
	elseif minimapShape == 'SIDE-LEFT' then
		round = cos <= 0
	elseif minimapShape == 'SIDE-RIGHT' then
		round = cos >= 0
	elseif minimapShape == 'SIDE-TOP' then
		round = sin <= 0
	elseif minimapShape == 'SIDE-BOTTOM' then
		round = sin >= 0
	elseif minimapShape == 'TRICORNER-TOPRIGHT' then
		round = not(cos < 0 and sin > 0)
	elseif minimapShape == 'TRICORNER-TOPLEFT' then
		round = not(cos > 0 and sin > 0)
	elseif minimapShape == 'TRICORNER-BOTTOMRIGHT' then
		round = not(cos < 0 and sin < 0)
	elseif minimapShape == 'TRICORNER-BOTTOMLEFT' then
		round = not(cos > 0 and sin < 0)
	end

	local x, y
	if round then
		x = cos*80
		y = sin*80
	else
		x = math.max(-82, math.min(110*cos, 84))
		y = math.max(-86, math.min(110*sin, 82))
	end

	self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function DF_Minimap_Update()
	DF_MinimapButton:UpdatePosition()
end
