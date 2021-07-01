----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - blood
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace
local screenHeight = GetScreenHeight()*0.75
local screenWidth = GetScreenWidth()*0.75

local frames={
	{
	frame=nil,
	overlay=nil,
	overlayTexture=nil,
	position={0,0},
	alpha=1,
	state=0,
	height=256,
	pas=0.005
	},
	{
	frame=nil,
	overlay=nil,
	overlayTexture=nil,
	position={0,0},
	alpha=1,
	state=0,
	height=256,
	pas=0.005
	},
	{
	frame=nil,
	overlay=nil,
	overlayTexture=nil,
	position={0,0},
	alpha=1,
	state=0,
	height=256,
	pas=0.005
	},		
	{
	frame=nil,
	overlay=nil,
	overlayTexture=nil,
	position={0,0},
	alpha=1,
	state=0,
	height=256,
	pas=0.005
	},			
}

-- initialisation frames
function DF:init_blood_frame()
	
	for i = 1,4 do
		
		if not frames[i].frame then
			
			-- cadre principal
			frames[i].frame = CreateFrame("FRAME","DF_BLOOD_FRAME"..i,UIParent)
			
			-- overlay
			frames[i].overlay = CreateFrame("FRAME","DF_BLOOD_FRAME"..i,frames[i].frame)
			
			-- la texture
			frames[i].overlayTexture = frames[i].overlay:CreateTexture(nil,"BACKGROUND")
		end
	
		-- paramétres cadre principal
		frames[i].frame:SetMovable(false)
		frames[i].frame:EnableMouse(false)		
		frames[i].frame:SetWidth(16)
		frames[i].frame:SetHeight(16)
		frames[i].frame:ClearAllPoints()
		frames[i].frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)	
		frames[i].frame:SetFrameStrata("BACKGROUND")
		frames[i].frame:SetFrameLevel(0)
		
		-- paramétres cadre principal
		frames[i].overlay:SetMovable(false)
		frames[i].overlay:EnableMouse(false)		
		frames[i].overlay:SetWidth(256)
		frames[i].overlay:SetHeight(256)
		frames[i].overlay:SetPoint("TOP", frames[i].frame, "TOP", 0, 100)	

		frames[i].overlayTexture:SetTexCoord(0, 1, 1, 0)
		frames[i].overlayTexture:SetWidth(256)
		frames[i].overlayTexture:SetHeight(256)
		frames[i].overlayTexture:SetBlendMode(DF_config.blood.mode)
		frames[i].overlayTexture:ClearAllPoints()
		frames[i].overlayTexture:SetAllPoints(frames[i].overlay)
	
		frames[i].overlayTexture:SetTexture("Interface\\AddOns\\DroodFocus\\datas\\blood"..i)
	
		frames[i].overlay.texture = frames[i].overlayTexture
	
		frames[i].overlay:SetScale(DF_config.blood.size)
	
		frames[i].frame:Hide()
		
		frames[i].state=0
		frames[i].alpha=1
		frames[i].height=256
		frames[i].pas=0.005
	
	end
	
end

-- gestion de l'animation
function DF:blood_update()

	if not DF_config.blood.enable then
		for i = 1,4 do
			frames[i].frame:Hide()
		end
		return
	end
	
	for i = 1,4 do
		
		if frames[i].state~=0 then
			
			frames[i].alpha=frames[i].alpha-0.01
			
			frames[i].height=frames[i].height+frames[i].pas
			frames[i].overlay:SetHeight(frames[i].height)
			frames[i].pas=frames[i].pas+0.00075
			
			if frames[i].alpha<0 then 
				frames[i].alpha=0
				frames[i].state=0
			end
			
			if frames[i].alpha>1 then 
				frames[i].overlay:SetAlpha(1)
			else
				frames[i].overlay:SetAlpha(frames[i].alpha)
			end			
			
			frames[i].frame:Show()
			
		else
			frames[i].frame:Hide()
		end
		
	end

end

function DF:blood_activate()
	
	if not DF_config.blood.enable then return end
	
	local it
	
	for it = 1,4 do
		
		if frames[it].state==0 then

			local rotate=math.random(2)
			local scale=DF_config.blood.size+(math.random()*(DF_config.blood.size/3))
			local posx = (math.random()*screenWidth)-(screenWidth/2) 
			local posy = (math.random()*screenHeight)-(screenHeight/2)
				
			frames[it].state=1
			frames[it].alpha=DF_config.blood.persistence
			
			if rotate==1 then
				frames[it].overlay.texture:SetTexCoord(0, 1, 1, 0)
				frames[it].frame:ClearAllPoints()
			elseif rotate==2 then
				frames[it].overlay.texture:SetTexCoord(1, 0, 1, 0)
				frames[it].frame:ClearAllPoints()
			end			
			
			frames[it].frame:SetPoint("CENTER", UIParent, "CENTER", posx, posy)
			frames[it].overlay:SetScale(scale)
			frames[it].height=256
			frames[it].pas=0.005
			frames[it].overlay:SetHeight(frames[it].height)
			
			break;
			
		end
		
	end
end

function DF:blood_reinit()
	DF:init_blood_frame()
	DF:blood_activate()
end