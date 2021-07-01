----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - Core
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 2
----------------------------------------------------------------------------------------------------

-- namespace
local DF = DF_namespace
local oldTalent = nil
local inspectTalent = true

-- cadre qui recoit event
DFeventFrame = CreateFrame("FRAME","DFeventFrame",UIParent)

---- events et scripts
function DF:setUp()

	DFeventFrame:RegisterEvent("VARIABLES_LOADED")
	DFeventFrame:SetScript("OnEvent", DF.OnEvent)
	
end

-- init frames
function DF:init_frames()
	-- création objets ou màj
	DF:init_anchor_frame()
	DF:init_ooc_frame()
	DF:init_powerbar_frame()
	DF:init_healthbar_frame()
	DF:init_manabar_frame()
	DF:init_targetbar_frame()
	DF:init_threatbar_frame()
	DF:init_spells_list()
	DF:init_icons_frame()
	DF:init_timerbars_frame()
	DF:init_combo_frame()
	DF:init_arrows_frame()
	DF:init_alert_frame()
	DF:init_cooldown_frame()	
	DF:init_blood_frame()
	DF:init_infos_frame()
	DF:init_portrait_frame()
	DF:init_gps_frame()
	DF:init_castbar_frame()

end

-- events Handlers
function DF:OnEvent(eventArg, ...)

	if(eventArg == "VARIABLES_LOADED") then

		-- ligne de comm
		SLASH_DroodFocusSL1 = "/df";
		SLASH_DroodFocusSL2 = "/droodfocus";
		SlashCmdList["DroodFocusSL"] = DroodFocusSL_SlashCmd;

		if not DF_config then
			DF_config = DF:deepcopy(DF_pred_configs[1])
			DEFAULT_CHAT_FRAME:AddMessage(DF.locale["first"])
		end

		if not DF_saved_configs then
			DF_saved_configs = {}
		end

		if not DF_sharemedia then
			DF_sharemedia = {}
		end

		if not DF_talents then
			DF_talents = {}
		end

		DF:completeTable(DF_config,DF_pred_configs[1])

		DF.position3d = ( GetScreenWidth() ^ 2 + GetScreenHeight() ^ 2 ) ^ 0.5 * UIParent:GetEffectiveScale()

		_,DF.playerClass=UnitClass("player")
		DF:form_initStanceList()
		DF:libs_registerUsersFiles()		
		
		-- création objets
		DF:init_frames()
		DF:toggle_toggle()
		DF:cooldown_initTable()
		DF:options_createpanels()		
		
		if not DF_config.MiniMapAngle then
			DF_config.MiniMapAngle=0
		end

		DF:DF_MinimapLoad()
		DF_MinimapToggle()

		CombatLogClearEntries()

		-- events
		DFeventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		DFeventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		DFeventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		DFeventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		DFeventFrame:SetScript("OnUpdate", DF.OnUpdate)
		
		-- bienvenue
		DEFAULT_CHAT_FRAME:AddMessage(DF.locale["welcome"])
		
	elseif(eventArg == "PLAYER_ENTERING_WORLD") then
		
		DF.playerId = UnitGUID("player")
		DF.playerLevel = UnitLevel("player")
		DF:cooldown_initTable()
		
	elseif(eventArg == "PLAYER_REGEN_ENABLED") then
		
		DF.menace=0
		DF:spells_clearPA()
		CombatLogClearEntries()
		DF:combat_set_state(false)
		DF:sound_roar()
		DF:toggle_toggle()
		
	elseif(eventArg == "PLAYER_REGEN_DISABLED") then
		
		DF:combat_set_state(true)
		DF:spells_desactivate()
		DF:toggle_toggle()
			
	elseif(eventArg == "COMBAT_LOG_EVENT_UNFILTERED") then	

   	if (arg2=="SPELL_DAMAGE") then
			
			if arg3==DF.playerId and arg18 then
				
	 			DF:sound_set_state(true)
				DF:blood_activate()
				
			elseif arg6==DF.playerId and UnitHealth("player")<(UnitHealthMax("player")/2.5) then
			
			 	DF:alert_activate("Interface\\AddOns\\DroodFocus-TBC\\datas\\alertWarning.tga")
			 	
			end
					
		elseif (arg2=="SWING_DAMAGE" and arg3==DF.playerId and arg15) then
			
			DF:blood_activate()
			
		elseif (arg2=="SPELL_CAST_FAILED" and arg3==DF.playerId) then

			if (arg12==SPELL_FAILED_OUT_OF_RANGE) then
				DF:alert_activate("2")
				
			elseif (arg12==SPELL_FAILED_NOT_BEHIND) then
				DF:alert_activate("1")
				
			end

		elseif (arg2=="SPELL_AURA_APPLIED" and arg6==DF.playerId and arg12=="DEBUFF" and DF_config.alert.showDebuff) then

			-- le joueur viens de subir un debuff, affiche l'icone dans le système d'alert
			local _, _, imgDebuff, _, _, _, _, _, _ = GetSpellInfo(arg9);
			if imgDebuff then
				DF:alert_activate(imgDebuff,true)
			end
			
		end		

	end

end

-- OnUpdate
function DF:OnUpdate(elapsed)

	DF.currentTime = GetTime()

	DF:toggle_toggle()

	DF:spells_update(elapsed)
	DF:icons_update()
	DF:timerbars_update()
	DF:ooc_update()
	DF:combo_update()

	DF:arrows_update()
	DF:alert_update()
	DF:cooldown_update()
	DF:infos_update()
	DF:portrait_update()
	DF:gps_update()
	DF:castbar_update()
	
	DF:powerbar_update()
	DF:healthbar_update()
	DF:manabar_update()	
	DF:targetbar_update()
	DF:threatbar_update()
	
	DF:blood_update()
	
end

function DF:toogle_lock()

	if DF.lock then
		itsok=false
		DEFAULT_CHAT_FRAME:AddMessage(DF.locale["locked"])
	else
		itsok=true
		DEFAULT_CHAT_FRAME:AddMessage(DF.locale["unlocked"])
	end
	
	DF.configmode = itsok
	
	DF:toggle_toggle()
	
	DF:anchor_toogle_lock(itsok)
	DF:ooc_toogle_lock(itsok)
	DF:powerbar_toogle_lock(itsok)
	DF:healthbar_toogle_lock(itsok)
	DF:manabar_toogle_lock(itsok)
	DF:targetbar_toogle_lock(itsok)
	DF:threatbar_toogle_lock(itsok)
	DF:combo_toogle_lock(itsok)
	DF:icons_toogle_lock(itsok)
	DF:timerbars_toogle_lock(itsok)
	DF:alert_toogle_lock(itsok)
	DF:gps_toogle_lock(itsok)
	DF:castbar_toogle_lock(itsok)
	DF:cooldown_toogle_lock(itsok)
	DF:infos_toogle_lock(itsok)
	DF:portrait_toogle_lock(itsok)
	
	DF:blood_activate()
	DF:blood_activate()
	DF:blood_activate()
	DF:blood_activate()
	
end

-- gestion ligne de commande
function DroodFocusSL_SlashCmd(arg)

	local conf=0
	
	-- parse
	if (arg==nil) then
		
		arg="";
		
	else
		
		listargs = DF:explode ( " ", string.lower(arg) );
		
		arg = string.lower(listargs[1]);

		if (listargs[2]) then
			arg2 = listargs[2];
		else
			arg2="";
		end
		if (listargs[3]) then
			arg3 = listargs[3];
		else
			arg3="";
		end	
			
	end

	-- action
	if (arg=="configmode") then
		DF:toogle_configmode()
		
	elseif (arg=="options") then	
		
		DF:options_show("DFOPTIONSelement")

	elseif (arg=="reset") then	
		
		DF:config_Reset()

	elseif (arg=="buff") then	

		DF:ShowID("buff")
		
	elseif (arg=="debuff") then	

		DF:ShowID("debuff")		
				
	else
		
		DEFAULT_CHAT_FRAME:AddMessage(DF.locale["commands"])
		
	end
	
end

function DF:toogle_configmode()
	
	if DF.lock then	DF.lock = false	else DF.lock = true	end
	DF:toogle_lock()
	
end

function DF:ShowID(ftype)

	DF:debugLine("Begin list of ",ftype)		

	local index=1
	while true do 

		if ftype=="buff" then
			
			name, _, _, debuffType, _, _, unitCaster, _, _, spellId = UnitAura("player", index, "HELPFUL") 
		
		elseif ftype=="debuff" then
			
			name, _, _, debuffType, _, _, unitCaster, _, _, spellId = UnitAura("playertarget", index, "HARMFUL") 
		
		else
		
			name=nil
		
		end

		if not name then break end

		DF:debugLine(ftype.." "..tostring(index)..": "..tostring(name),spellId)		
		
		index=index+1
		
	end
	DF:debugLine("End list of ",ftype)
end

-- démarrage
DF:setUp()