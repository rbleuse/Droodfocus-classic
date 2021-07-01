----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - config
-- Author : Meranannon - Discordia - Vol'jin (EU)
-- rev 5
----------------------------------------------------------------------------------------------------

DF_namespace.anchor={}

DF_namespace.lock=true
DF_namespace.configmode=false
DF_namespace.currentTime=GetTime()
DF_namespace.playerId = nil
DF_namespace.playerClass = nil
DF_namespace.playerLevel = nil
DF_namespace.playerTalent = nil
DF_namespace.playerTalentName = nil
DF_namespace.playerpoint = nil
DF_namespace.myArgs = ""
DF_namespace.menace = 0
DF_namespace.position3d = nil

DF_namespace.configToLoad = nil

DF_namespace.wipespell = true

DF_namespace.environnement = getfenv(0)

DF_namespace.newSpell={
	spellIDs="0",
	positionx=0,
	positiony=0,
	width=32,
	height=32,
	form={true,false,false,false,false,false,false},
	color={r=1,v=0,b=0,a=1},
	sType="Debuff",
	perso=false,
	combo=false,
	icon=true,
	timerbar=1,
	getUptime=false,
	showcd=true,
}

StaticPopupDialogs["WIPESPELLS"] = {
  text = DF_namespace.locale["loadconfigansw"],
  button1 = DF_namespace.locale["loadconfigkeep"],
  button2 = DF_namespace.locale["loadconfigdisc"],
	OnAccept = function()
		DF_namespace:config_Loadok(DF_namespace.configToLoad,false,false)
	end,
	OnCancel = function()
		DF_namespace:config_Loadok(DF_namespace.configToLoad,false,true)
	end,  
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
};

-- effacement valeur d'une table
function DF_namespace:clearTable(source,spellstoo)
	local function _clear(csource)
		for index, value in pairs(csource) do
			if type(csource[index]) ~= "table" then
				csource[index]=nil
			else
				if (tostring(index)~="spells" or (tostring(index)=="spells" and spellstoo==true)) then
					_clear(csource[index])
				end
			end
		end
	end
	_clear(source)
end

-- copy d'une table vers une autre
function DF_namespace:copyTable(source,destination,spellstoo)
	local function _copy(csource,cdestination)
		for index, value in pairs(csource) do
			if type(csource[index]) ~= "table" then
				cdestination[index]=csource[index]
			else
				if (tostring(index)~="spells" or (tostring(index)=="spells" and spellstoo==true)) then
					if cdestination[index]==nil or not cdestination[index] then
						cdestination[index]={}
					end
					_copy(csource[index],cdestination[index])
				end
			end
		end
	end
	
	_copy(source,destination)
	
end

function DF_namespace:deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

	-- Compléte la configuration actuel avec les variables de la config par default
function DF_namespace:completeTable(tcurrent,tdefaut)
	local chemin="config"
	local function _check(current,defaut,chemin)
		for index, value in pairs(defaut) do
			if type(defaut[index]) ~= "table" then
				if current[index]==nil then
					current[index]=defaut[index]
				end
			else
				if chemin~="config.spells" then
					if current[index]==nil or not current[index] then
						current[index]={}
					end				
					_check(current[index],defaut[index],chemin.."."..tostring(index))
				end
			end
		end
	end
	_check(tcurrent,tdefaut,chemin)	
end

function DF_namespace:configSaved(name)
	local nbConf=getn(DF_saved_configs)
	for i = 1,nbConf do
		if DF_saved_configs[i].configname==name then
			return i
		end
	end
	
	return 0
	
end

function DF_namespace:configBuildin(name)
	local nbConf=getn(DF_pred_configs)
	for i = 1,nbConf do
		if DF_pred_configs[i].configname==name then
			return i
		end
	end
	
	return 0
	
end

function DF_namespace:config_Save(name)
	
	if not name then name=DF_config.configname end
	
	name=name:gsub("BuildIn", "User")
	DF_config.configname=name
	
	conf = DF_namespace:configSaved(name)

	if conf==0 then
		conf=getn(DF_saved_configs)+1
		DF_saved_configs[conf] = {}
	end

	DF_config.configversion=DROODFOCUS_CONFIGVERSION

	DF_saved_configs[conf] = DF_namespace:deepcopy(DF_config)
	DF_saved_configs[conf].configname=name

	DF_namespace:options_SavedconfigLists()
	
	DEFAULT_CHAT_FRAME:AddMessage(DF_namespace.locale["saved"]..name)
	
end

function DF_namespace:config_Load(name,showconfig)

	if not name then name=DF_namespace.configToLoad end
	DF_namespace.configToLoad=name;
	
	StaticPopup_Show("WIPESPELLS");

end

function DF_namespace:config_Loadok(name,showconfig,wipespell)

	if not name then name=DF_namespace.configToLoad end
	
	if string.find(name, "BuildIn") then
		conf = DF_namespace:configBuildin(name)
		if conf~=0 then
			
			if (wipespell==true) then
				while getn(DF_config.spells)>getn(DF_pred_configs[conf].spells) do
					table.remove(DF_config.spells,getn(DF_config.spells))
				end
			end
			
			DF_namespace:options_hide()
			DF_namespace:clearTable(DF_config,wipespell)
			DF_namespace:copyTable(DF_pred_configs[conf],DF_config,wipespell)
			DF_namespace:completeTable(DF_config,DF_pred_configs[1])
			
			DF_namespace:init_frames()
			DF_namespace:toggle_toggle()
			DF_MinimapToggle()
			DEFAULT_CHAT_FRAME:AddMessage(DF_namespace.locale["loaded"]..DF_config.configname)
			
			if (showconfig==true) then
				DF_namespace:options_hide("DFOPTIONSelement");
				DF_namespace:options_show("DFOPTIONSelement")
			end
			
			DF_namespace.environnement["confignamebox"]:Hide()
			DF_namespace.environnement["confignamebox"]:Show()		
			
			return
		end
	else
		conf = DF_namespace:configSaved(name)
		if conf~=0 then

			if (wipespell==true) then
				while getn(DF_config.spells)>getn(DF_saved_configs[conf].spells) do
					table.remove(DF_config.spells,getn(DF_config.spells))
				end
			end
			
			DF_namespace:options_hide()
			
			DF_namespace:clearTable(DF_config,wipespell)
			DF_namespace:copyTable(DF_saved_configs[conf],DF_config,wipespell)
			DF_namespace:completeTable(DF_config,DF_pred_configs[1])
	
			DF_namespace:init_frames()
			DF_namespace:toggle_toggle()
			DF_MinimapToggle()
			DEFAULT_CHAT_FRAME:AddMessage(DF_namespace.locale["loaded"]..DF_config.configname)
			
			if (showconfig==true) then
				DF_namespace:options_hide("DFOPTIONSelement");
				DF_namespace:options_show("DFOPTIONSelement")
			end
			
			DF_namespace.environnement["confignamebox"]:Hide()
			DF_namespace.environnement["confignamebox"]:Show()		
			
			return
		end
	end
	
end

function DF_namespace:config_Reset()

	while getn(DF_config.spells)>getn(DF_pred_configs[1].spells) do
		table.remove(DF_config.spells,getn(DF_config.spells))
	end

	DF_namespace:options_hide()
	
	DF_namespace:clearTable(DF_config,true)
	DF_namespace:copyTable(DF_pred_configs[1],DF_config,true)
	DF_namespace:completeTable(DF_config,DF_pred_configs[1])
	
	DF_namespace:init_frames()
	DF_namespace:toggle_toggle()
	DF_namespace.environnement["confignamebox"]:Hide()
	DF_namespace.environnement["confignamebox"]:Show()
	DF_namespace.environnement["dfcombat"]:Hide()
	DF_namespace.environnement["dfcombat"]:Show()
	DEFAULT_CHAT_FRAME:AddMessage(DF_namespace.locale["reset"])
	
end

--
-- configurations prédéfinies
--
DF_pred_configs = {
	{
		["minimap"] = true,
		["configversion"] = 409,
		["MiniMapAngle"] = 215.8160744865155,
		["portrait"] = {
			["textures"] = {
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga", -- [1]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\bearform.tga", -- [2]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\aquaform.tga", -- [3]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\catform.tga", -- [4]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\travelform.tga", -- [5]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\moonkinform.tga", -- [6]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\flightform.tga", -- [7]
			},
			["height"] = "48",
			["mode"] = "ADD",
			["positiony"] = 1.5,
			["enable"] = true,
			["positionx"] = 1,
			["level"] = 5,
			["width"] = "48",
		},
		["castbar"] = {
			["impulsion"] = 1,
			["inactiveAlpha"] = 0,
			["activeAlpha"] = 1,
			["fontSize"] = 12,
			["fontSizetimer"] = 16,
			["positiony"] = 58.5,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 2,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 3,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["fontPathtimer"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["positionx"] = 10,
			["width"] = 192,
			["textx"] = 3,
			["texty"] = 0,
			["timerx"] = -3,
			["timery"] = 0,			
			["showText"] = true,
			["showTimer"] = true,
			["showSpark"] = true,
			["height"] = 24,
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "LEFT",
			["timerAlign"] = "RIGHT",
			["color"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 1,
				["b"] = 0,
			},
			["colori"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,	
			},			
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["timerColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},			
		},
		["powerbar"] = {
			["interval"] = 1,
			["sformat"] = "#c",
			["fontSize"] = 15,
			["positiony"] = -18.5,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 1,
			["form"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
			},
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorDef"] = {
				["a"] = 1,
				["r"] = 0.5,
				["v"] = 0.5,
				["b"] = 0.5,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "BOTTOMRIGHT",
			["positionx"] = 10,
			["height"] = 32,
			["textx"] = -3.5,
			["colorNrj"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["colorMana"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["colorRage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["arrows"] = {
				33983, -- [1]
				5221, -- [2]
				80, -- [3]
				1079, -- [4]
			},
			["width"] = 192,
			["showText"] = true,
			["enableArrows"] = true,
			["orientation"] = "HORIZONTAL",
			["texty"] = 2,
			["showSpark"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["threatbar"] = {
			["sformat"] = "#c%",
			["form"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
			},			
			["fontSize"] = 8,
			["positiony"] = -49.5,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 3,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["positionx"] = "10",
			["width"] = 192,
			["textx"] = -7,
			["texty"] = 1,
			["showText"] = false,
			["height"] = "6",
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeX"] = 0.25,
		["sound"] = {
			["enable"] = true,
			["soundfiles"] = {
				"", -- [1]
				"Sound\\Spells\\Druid_Pounce.wav", -- [2]
				"", -- [3]
				"Sound\\Spells\\Druid_FeralCharge.wav", -- [4]
				"", -- [5]
				"", -- [6]
				"", -- [7]
			},
		},
		["timelines"] = {
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["enable"] = false,
			["activeAlpha"] = 0.1,
			["width"] = 1,
		},
		["activeForms"] = {
			false, -- [1]
			true, -- [2]
			true, -- [3]
			true, -- [4]
			true, -- [5]
			false, -- [6]
			false, -- [7]
		},
		["uiAlwaysShow"] = false,
		["anchor5"] = {
			["visible"] = true,
			["positiony"] = 370.5,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "INFOS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 405,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["anchor3"] = {
			["visible"] = true,
			["positiony"] = 452.5,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "TIMERBARS 1",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 405.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["icons"] = {
			["decimal"] = false,
			["pointpa"] = true,
			["fontSize"] = 13,
			["orderByTime"] = true,
			["automatic"] = true,
			["activeAlpha"] = 1,
			["inactiveAlpha"] = 0.3,
			["level"] = 10,
			["textsoffsets"] = {
				{
					["visible"] = true,
					["offsety"] = -1,
					["align"] = "TOPLEFT",
					["offsetx"] = 1,
					["size"] = 13,
				}, -- [1]
				{
					["visible"] = true,
					["offsety"] = 2,
					["align"] = "BOTTOMRIGHT",
					["offsetx"] = 1,
					["size"] = 13,
				}, -- [2]
				{
					["visible"] = true,
					["offsety"] = 2,
					["align"] = "BOTTOMLEFT",
					["offsetx"] = 1,
					["size"] = 13,
				}, -- [3]
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["mode"] = "BLEND",
			["width"] = 37,
			["colonne"] = 8,
			["speed"] = 4,
			["pulse"] = 1.6,
			["enable"] = true,
			["height"] = 37,
			["showSpiral"] = 2,
			["growup"] = false,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["blood"] = {
			["persistence"] = 7,
			["enable"] = true,
			["mode"] = "BLEND",
			["level"] = 1,
			["size"] = 0.5,
		},
		["anchor4"] = {
			["visible"] = true,
			["positiony"] = 376.5,
			["scale"] = 0.75,
			["width"] = 32,
			["info"] = "TIMERBARS 2",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 850.75,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["alignToGrid"] = true,
		["inCombat"] = false,
		["configname"] = "(BuildIn) DroodFocus (Default)",
		["combo"] = {
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["fontSize"] = 18,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["textOffsetX"] = 12,
			["textOffsetY"] = -17,			
			["showText"] = false,
			["angleB"] = 183,
			["offsety"] = 0,
			["positiony"] = "-21",
			["enable"] = true,
			["form"] = {
				false, -- [1]
				true, -- [2]
				false, -- [3]
				true, -- [4]
				false, -- [5]
				false, -- [6]
				false, -- [7]
			},
			["angleA"] = 288,
			["width"] = 21,
			["impulsion"] = 1.75,
			["positionx"] = 51.66293145777689,
			["ptype"] = 1,
			["rayon"] = 37,
			["offsetx"] = 20,
			["height"] = 21,
			["mode"] = "BLEND",
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\combo.tga",
			["level"] = 4,
		},
		["anchor6"] = {
			["visible"] = true,
			["positiony"] = 291,
			["scale"] = 1,
			["width"] = "32",
			["info"] = "CD",
			["positionx"] = 608.5,
			["height"] = "32",
			["level"] = 10,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["targetbar"] = {
			["sformat"] = "#C k/#M k (#p%)",
			["form"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
			},			
			["fontSize"] = 11,
			["positiony"] = -6,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "CENTER",
			["width"] = 192,
			["textx"] = 0,
			["texty"] = 1,
			["showText"] = true,
			["height"] = "13",
			["orientation"] = "HORIZONTAL",
			["positionx"] = 10,
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.75,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["cursorspeed"] = 30,
		["timerbar"] = {
			["orderByTime"] = true,
			["enable"] = true,
			["font1Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["showSpark"] = true,
			["prop"] = true,
			["borderSize"] = 1,
			["cdColor"] = {
				["a"] = 0.4900000095367432,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["showTimeLine"] = true,
			["inactiveAlpha"] = 0,
			["level"] = 4,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["activeAlphaCD"] = 1,
			["font2Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["activeAlpha"] = 1,
			["growup"] = false,
			["width"] = "210",
			["font1Size"] = 12,
			["timeline"] = 14,
			["font2Size"] = 20,
			["textsoffsets"] = {
				{
					["offsety"] = 2,
					["offsetx"] = 0,
				}, -- [1]
				{
					["offsety"] = 0,
					["offsetx"] = 2,
				}, -- [2]
			},
			["cdoffsety"] = 2,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["height"] = "22",
			["cdoffsetx"] = 0,
			["border"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeY"] = 0.25,
		["gps"] = {
			["gpsTarget"]={"target","focus"},
			["positions"]={
				{["x"]=0,["y"]=0},
				{["x"]=0,["y"]=0}
			},
			["fontSize"] = 16,
			["offsety"] = -22,
			["positiony"] = 202.6987448411231,
			["enable"] = true,
			["alpha"] = 1,
			["width"] = "48",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["positionx"] = 726.4074455649542,
			["offsetx"] = 0,
			["height"] = "36",
			["level"] = 10,
			["mode"] = "BLEND",
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["manabar"] = {
			["sformat"] = "#C k/#M k (#p%)",
			["form"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
			},			
			["fontSize"] = 12,
			["positiony"] = 140,
			["color"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "RIGHT",
			["width"] = 192,
			["enable"] = false,
			["texty"] = 1,
			["showText"] = true,
			["orientation"] = "HORIZONTAL",
			["height"] = 18,
			["positionx"] = 8,
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["spells"] = {
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.2078431372549019,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 9846,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Fureur du tigre", -- [1]
				},
				["abiSpelltext"] = "Fureur du tigre",
				["timerbar"] = 0,
				["ids"] = {
					9846, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Buff",
				["abiSound"] = "",
				["spellIDs"] = "9846",
				["abiEnd"] = 0,
			}, -- [1]
			{
				["spellIDs"] = "16857;770;33602",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 1,
					["r"] = 0.9803921568627451,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 16857,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Lucioles (farouche)", -- [1]
					"Lucioles", -- [2]
					"Lucioles améliorées", -- [3]
				},
				["abiSpelltext"] = "Lucioles (farouche)",
				["timerbar"] = 0,
				["ids"] = {
					16857, -- [1]
					770, -- [2]
					33602, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [2]
			{
				["spellIDs"] = "33983;33987;46854",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0.4117647058823529,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33983,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Mutilation (félin)", -- [1]
					"Mutilation (ours)", -- [2]
					"Traumatisme", -- [3]
				},
				["abiSpelltext"] = "Mutilation (félin)",
				["timerbar"] = 0,
				["ids"] = {
					33983, -- [1]
					33987, -- [2]
					46854, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [3]
			{
				["spellIDs"] = "1822",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1822,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Griffure", -- [1]
				},
				["abiSpelltext"] = "Griffure",
				["timerbar"] = 0,
				["ids"] = {
					1822, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [4]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33745,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = true,
				["abiUserText"] = "",
				["names"] = {
					"Lacérer", -- [1]
				},
				["abiSpelltext"] = "Lacérer",
				["timerbar"] = 0,
				["ids"] = {
					33745, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "33745",
				["abiEnd"] = 0,
			}, -- [5]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1079,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Déchirure", -- [1]
				},
				["abiSpelltext"] = "Déchirure",
				["timerbar"] = 0,
				["ids"] = {
					1079, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "1079",
				["abiEnd"] = 0,
			}, -- [6]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0.4470588235294117,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 99,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Rugissement démoralisant", -- [1]
					"Cri démoralisant", -- [2]
				},
				["abiSpelltext"] = "Rugissement démoralisant",
				["timerbar"] = 0,
				["ids"] = {
					99, -- [1]
					25203, -- [2]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "99;25203",
				["abiEnd"] = 0,
			}, -- [7]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.1411764705882353,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 5211,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Sonner", -- [1]
				},
				["abiSpelltext"] = "Sonner",
				["timerbar"] = 0,
				["ids"] = {
					5211, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["spellIDs"] = "5211",
				["abiEnd"] = 0,
			}, -- [8]
			{
				["spellIDs"] = "22812",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.6039215686274509,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 22812,
				["icon"] = false,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 23,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Ecorce", -- [1]
				},
				["abiSpelltext"] = "Ecorce",
				["timerbar"] = 2,
				["ids"] = {
					22812, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["abiSound"] = "",
				["sType"] = "Buff",
				["abiEnd"] = 0,
			}, -- [16]
		},
		["healthbar"] = {
			["sformat"] = "#C k/#M k (#p%)",
			["form"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
			},			
			["colorchg"] = true,
			["fontSize"] = 12,
			["positiony"] = 40,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["colorBad"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorAverage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.5,
				["b"] = 0,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["colorGood"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 1,
				["b"] = 0,
			},
			["level"] = 2,
			["width"] = 192,
			["positionx"] = 8,
			["height"] = 18,
			["showText"] = true,
			["texty"] = 1,
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["ooc"] = {
			["spell"] = 12536,
			["positiony"] = 17,
			["enable"] = true,
			["scaleMin"] = 1,
			["width"] = "650",
			["textureOff"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
			["height"] = "150",
			["scaleMax"] = 0.1,
			["textureOn"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\ooc.tga",
			["speed"] = 0.1,
			["positionx"] = 70,
			["level"] = 10,
			["mode"] = "ADD",
		},
		["cooldown"] = {
			["offsety"] = -48,
			["positiony"] = -1.000137314198355,
			["enable"] = true,
			["alpha"] = 0.7,
			["width"] = 49,
			["positionx"] = 199.9999970197678,
			["height"] = 49,
			["mode"] = "BLEND",
			["level"] = 5,
			["offsetx"] = 0,
		},
		["anchor2"] = {
			["visible"] = true,
			["positiony"] = "334.5",
			["scale"] = 1,
			["width"] = 32,
			["info"] = "ICONS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 655.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["infos"] = {
			["fontSize"] = 10,
			["enable"] = false,
			["infolines"] = "PowerAttack: #meleeAP*Crit: #meleeCrit*Haste: #meleeHaste*ArPen: #armPen",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_typewriter.ttf",
			["level"] = 20,
			["backColor"] = {
				["a"] = 0,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["textColor"] = {
				["a"] = 0.4600000381469727,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["alert"] = {
			["showDebuff"] = true,
			["texture1"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertBehind.tga",
			["positiony"] = 96.99557596109207,
			["enable"] = true,
			["texture3"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertSkull.tga",
			["width"] = "96",
			["texture2"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertRange.tga",
			["height"] = "96",
			["positionx"] = 72.82351202531481,
			["mode"] = "BLEND",
			["level"] = 5,
			["persistence"] = 2.5,
		},
		["anchor1"] = {
			["visible"] = true,
			["positiony"] = 293.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "UI",
			["positionx"] = 653.25,
			["height"] = 32,
			["level"] = 1,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
	}, -- [1]
	{
		["configversion"] = 409,
		["MiniMapAngle"] = 215.8160744865155,
		["portrait"] = {
			["textures"] = {
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga", -- [1]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\bearform.tga", -- [2]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\aquaform.tga", -- [3]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\catform.tga", -- [4]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\travelform.tga", -- [5]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\moonkinform.tga", -- [6]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\flightform.tga", -- [7]
			},
			["height"] = "64",
			["mode"] = "BLEND",
			["positiony"] = -31.6851857576691,
			["enable"] = true,
			["positionx"] = 34,
			["level"] = 2,
			["width"] = "64",
		},
		["powerbar"] = {
			["fontSize"] = 10,
			["positiony"] = "-43.25",
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 0,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["colorDef"] = {
				["a"] = 1,
				["r"] = 0.5,
				["v"] = 0.5,
				["b"] = 0.5,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "RIGHT",
			["positionx"] = "99",
			["height"] = "18",
			["textx"] = -4,
			["colorNrj"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["colorMana"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["colorRage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["arrows"] = {
				33983, -- [1]
				5221, -- [2]
				80, -- [3]
				1079, -- [4]
			},
			["width"] = "119",
			["showText"] = true,
			["enableArrows"] = true,
			["orientation"] = "HORIZONTAL",
			["texty"] = -1.5,
			["showSpark"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["threatbar"] = {
			["fontSize"] = 8,
			["positiony"] = -73.75,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 0,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["positionx"] = "99",
			["width"] = "119",
			["textx"] = 1.5,
			["texty"] = 1,
			["showText"] = true,
			["height"] = "10",
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "LEFT",
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeX"] = 0.25,
		["sound"] = {
			["enable"] = true,
			["soundfiles"] = {
				"", -- [1]
				"Sound\\Spells\\Druid_Pounce.wav", -- [2]
				"", -- [3]
				"Sound\\Spells\\Druid_FeralCharge.wav", -- [4]
				"", -- [5]
				"", -- [6]
				"", -- [7]
			},
		},
		["timelines"] = {
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["enable"] = true,
			["activeAlpha"] = 0.1,
			["width"] = 1,
		},
		["activeForms"] = {
			false, -- [1]
			true, -- [2]
			true, -- [3]
			true, -- [4]
			true, -- [5]
			false, -- [6]
			false, -- [7]
		},
		["anchor5"] = {
			["visible"] = true,
			["positiony"] = 429.25,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "INFOS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 197.75,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["anchor3"] = {
			["visible"] = true,
			["positiony"] = 353.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "TIMERBARS 1",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 142.5,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["icons"] = {
			["fontSize"] = 11,
			["orderByTime"] = true,
			["automatic"] = true,
			["activeAlpha"] = 1,
			["inactiveAlpha"] = 0.3,
			["level"] = 10,
			["textsoffsets"] = {
				{
					["visible"] = true,
					["offsety"] = -12,
					["align"] = "BOTTOM",
					["offsetx"] = 0,
					["size"] = 13,
				}, -- [1]
				{
					["visible"] = true,
					["offsety"] = -1,
					["align"] = "TOPRIGHT",
					["offsetx"] = 0,
					["size"] = 13,
				}, -- [2]
				{
					["visible"] = true,
					["offsety"] = -1,
					["align"] = "TOPLEFT",
					["offsetx"] = 0,
					["size"] = 13,
				}, -- [3]
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["mode"] = "BLEND",
			["width"] = 30,
			["colonne"] = 5,
			["speed"] = 4,
			["pulse"] = 1.1,
			["enable"] = true,
			["height"] = 30,
			["showSpiral"] = 2,
			["growup"] = false,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["blood"] = {
			["persistence"] = 7,
			["enable"] = true,
			["mode"] = "BLEND",
			["level"] = 1,
			["size"] = 0.7,
		},
		["anchor4"] = {
			["visible"] = true,
			["positiony"] = 232.5,
			["scale"] = 0.699999988079071,
			["width"] = 32,
			["info"] = "TIMERBARS 2",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 172.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["alignToGrid"] = true,
		["inCombat"] = false,
		["configname"] = "(BuildIn) WoW",
		["combo"] = {
			["angleB"] = 335,
			["offsety"] = 0,
			["positiony"] = -51.37939145623099,
			["enable"] = true,
			["form"] = {
				false, -- [1]
				true, -- [2]
				false, -- [3]
				true, -- [4]
				false, -- [5]
				false, -- [6]
				false, -- [7]
			},
			["angleA"] = 164,
			["width"] = 20,
			["positionx"] = 52.97583875375148,
			["ptype"] = 2,
			["rayon"] = 37,
			["offsetx"] = 19,
			["height"] = 20,
			["mode"] = "BLEND",
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\combo2.tga",
			["level"] = 5,
		},
		["anchor6"] = {
			["visible"] = true,
			["positiony"] = 238,
			["scale"] = 1,
			["width"] = "32",
			["info"] = "CD",
			["positionx"] = 586,
			["height"] = "32",
			["level"] = 10,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["targetbar"] = {
			["fontSize"] = 8,
			["positiony"] = "-61.5",
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 0,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "CENTER",
			["width"] = "119",
			["textx"] = 0,
			["texty"] = -0.5,
			["showText"] = true,
			["height"] = "10",
			["orientation"] = "HORIZONTAL",
			["positionx"] = "99",
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.75,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["cursorspeed"] = 30,
		["timerbar"] = {
			["orderByTime"] = false,
			["enable"] = false,
			["font1Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["showSpark"] = true,
			["prop"] = false,
			["borderSize"] = 1,
			["cdColor"] = {
				["a"] = 0.8,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["showTimeLine"] = true,
			["inactiveAlpha"] = 0.3,
			["level"] = 4,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["activeAlphaCD"] = 1,
			["font2Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["activeAlpha"] = 1,
			["growup"] = false,
			["width"] = "180",
			["font1Size"] = 10,
			["timeline"] = 14,
			["font2Size"] = 15,
			["textsoffsets"] = {
				{
					["offsety"] = 1,
					["offsetx"] = 1,
				}, -- [1]
				{
					["offsety"] = 1,
					["offsetx"] = 0,
				}, -- [2]
			},
			["cdoffsety"] = 2,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["height"] = "20",
			["cdoffsetx"] = 0,
			["border"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeY"] = 0.25,
		["gps"] = {
			["fontSize"] = 16,
			["offsety"] = -22,
			["positiony"] = 191.0000009685755,
			["enable"] = true,
			["alpha"] = 1,
			["width"] = "48",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["positionx"] = 302.0000031292438,
			["offsetx"] = 0,
			["height"] = "36",
			["level"] = 10,
			["mode"] = "BLEND",
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["manabar"] = {
			["fontSize"] = 12,
			["positiony"] = 140,
			["color"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "RIGHT",
			["width"] = 192,
			["enable"] = false,
			["texty"] = 1,
			["showText"] = true,
			["orientation"] = "HORIZONTAL",
			["height"] = 18,
			["positionx"] = 8,
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["spells"] = {
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.2078431372549019,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 9846,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Fureur du tigre", -- [1]
				},
				["abiSpelltext"] = "Fureur du tigre",
				["timerbar"] = 1,
				["ids"] = {
					9846, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Buff",
				["abiSound"] = "",
				["spellIDs"] = "9846",
				["abiEnd"] = 0,
			}, -- [1]
			{
				["spellIDs"] = "16857;770;33602",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 1,
					["r"] = 0.9803921568627451,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 183.1080000000002,
				["abiSpellId"] = 16857,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 183.0909999990763,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 18155.416,
				["abiDuration"] = 300,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Lucioles (farouche)", -- [1]
					"Lucioles", -- [2]
					"Lucioles améliorées", -- [3]
				},
				["abiSpelltext"] = "Lucioles (farouche)",
				["timerbar"] = 1,
				["ids"] = {
					16857, -- [1]
					770, -- [2]
					33602, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 500,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["abiEnd"] = 18455.416,
			}, -- [2]
			{
				["spellIDs"] = "33983;33987;46854",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0.4117647058823529,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33983,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Mutilation (félin)", -- [1]
					"Mutilation (ours)", -- [2]
					"Traumatisme", -- [3]
				},
				["abiSpelltext"] = "Mutilation (félin)",
				["timerbar"] = 1,
				["ids"] = {
					33983, -- [1]
					33987, -- [2]
					46854, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [3]
			{
				["spellIDs"] = "1822",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1822,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Griffure", -- [1]
				},
				["abiSpelltext"] = "Griffure",
				["timerbar"] = 1,
				["ids"] = {
					1822, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [4]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33745,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = true,
				["abiUserText"] = "",
				["names"] = {
					"Lacérer", -- [1]
				},
				["abiSpelltext"] = "Lacérer",
				["timerbar"] = 1,
				["ids"] = {
					33745, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "33745",
				["abiEnd"] = 0,
			}, -- [5]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1079,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Déchirure", -- [1]
				},
				["abiSpelltext"] = "Déchirure",
				["timerbar"] = 1,
				["ids"] = {
					1079, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "1079",
				["abiEnd"] = 0,
			}, -- [6]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0.4470588235294117,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 99,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Rugissement démoralisant", -- [1]
					"Cri démoralisant", -- [2]
				},
				["abiSpelltext"] = "Rugissement démoralisant",
				["timerbar"] = 1,
				["ids"] = {
					99, -- [1]
					25203, -- [2]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "99;25203",
				["abiEnd"] = 0,
			}, -- [7]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.6039215686274509,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 22812,
				["icon"] = false,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Ecorce", -- [1]
				},
				["abiSpelltext"] = "Ecorce",
				["timerbar"] = 2,
				["ids"] = {
					22812, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["sType"] = "Buff",
				["abiSound"] = "",
				["spellIDs"] = "22812",
				["abiEnd"] = 0,
			}, -- [10]
		},
		["healthbar"] = {
			["fontSize"] = 12,
			["positiony"] = 40,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["colorBad"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["colorAverage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.5,
				["b"] = 0,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["colorGood"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 1,
				["b"] = 0,
			},
			["level"] = 2,
			["width"] = 192,
			["positionx"] = 8,
			["height"] = 18,
			["showText"] = true,
			["texty"] = 1,
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["ooc"] = {
			["spell"] = 12536,
			["positiony"] = -37,
			["enable"] = true,
			["scaleMin"] = 1,
			["width"] = "512",
			["textureOff"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
			["height"] = "128",
			["scaleMax"] = 0.1000000014901161,
			["textureOn"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\ooc.tga",
			["speed"] = 0.1299999952316284,
			["positionx"] = 120,
			["level"] = 6,
			["mode"] = "ADD",
		},
		["cooldown"] = {
			["offsety"] = -44,
			["positiony"] = -36.99996893107937,
			["enable"] = true,
			["alpha"] = 0.75,
			["width"] = 44,
			["positionx"] = 216.0000196695325,
			["height"] = 44,
			["mode"] = "BLEND",
			["level"] = 5,
			["offsetx"] = 0,
		},
		["anchor2"] = {
			["visible"] = true,
			["positiony"] = 193,
			["scale"] = 1.149999976158142,
			["width"] = 32,
			["info"] = "ICONS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 433.5,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["infos"] = {
			["fontSize"] = 12,
			["enable"] = false,
			["infolines"] = "PowerAttack: #meleeAP*Crit: #meleeCrit*Haste: #meleeHaste*ArPen: #armPen",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_typewriter.ttf",
			["level"] = 3,
			["backColor"] = {
				["a"] = 0,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["alert"] = {
			["texture1"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertBehind.tga",
			["positiony"] = -30.99271899703874,
			["enable"] = true,
			["texture3"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertSkull.tga",
			["width"] = "64",
			["texture2"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertRange.tga",
			["height"] = "64",
			["positionx"] = 35.21524791797145,
			["mode"] = "BLEND",
			["level"] = 5,
		},
		["anchor1"] = {
			["visible"] = true,
			["positiony"] = 287,
			["scale"] = 1.2,
			["width"] = "256",
			["info"] = "UI",
			["positionx"] = 326.25,
			["height"] = "128",
			["level"] = 4,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\UI_texture1.tga",
		},
	}, -- [2]
	{
		["configversion"] = 409,
		["MiniMapAngle"] = 215.8160744865155,
		["portrait"] = {
			["textures"] = {
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga", -- [1]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\bearform.tga", -- [2]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\aquaform.tga", -- [3]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\catform.tga", -- [4]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\travelform.tga", -- [5]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\moonkinform.tga", -- [6]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\flightform.tga", -- [7]
			},
			["height"] = "64",
			["mode"] = "BLEND",
			["positiony"] = -31.6851857576691,
			["enable"] = true,
			["positionx"] = 34,
			["level"] = 2,
			["width"] = "64",
		},
		["powerbar"] = {
			["fontSize"] = 10,
			["positiony"] = "-43.25",
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 0,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["colorDef"] = {
				["a"] = 1,
				["r"] = 0.5,
				["v"] = 0.5,
				["b"] = 0.5,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "RIGHT",
			["positionx"] = "99",
			["height"] = "18",
			["textx"] = -5.5,
			["colorNrj"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["colorMana"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["colorRage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["arrows"] = {
				33983, -- [1]
				5221, -- [2]
				80, -- [3]
				1079, -- [4]
			},
			["width"] = "119",
			["showText"] = true,
			["enableArrows"] = true,
			["orientation"] = "HORIZONTAL",
			["texty"] = 0,
			["showSpark"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["threatbar"] = {
			["fontSize"] = 8,
			["positiony"] = "-73",
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 0,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["positionx"] = "99",
			["width"] = "119",
			["textx"] = 3,
			["texty"] = 1,
			["showText"] = true,
			["height"] = "10",
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "LEFT",
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeX"] = 0.25,
		["sound"] = {
			["enable"] = true,
			["soundfiles"] = {
				"", -- [1]
				"Sound\\Spells\\Druid_Pounce.wav", -- [2]
				"", -- [3]
				"Sound\\Spells\\Druid_FeralCharge.wav", -- [4]
				"", -- [5]
				"", -- [6]
				"", -- [7]
			},
		},
		["timelines"] = {
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["enable"] = true,
			["activeAlpha"] = 0.1,
			["width"] = 1,
		},
		["activeForms"] = {
			false, -- [1]
			true, -- [2]
			true, -- [3]
			true, -- [4]
			true, -- [5]
			false, -- [6]
			false, -- [7]
		},
		["anchor5"] = {
			["visible"] = true,
			["positiony"] = 184.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "INFOS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 117.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["anchor3"] = {
			["visible"] = true,
			["positiony"] = 397.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "TIMERBARS 1",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 100.75,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["icons"] = {
			["fontSize"] = 11,
			["orderByTime"] = true,
			["automatic"] = true,
			["activeAlpha"] = 1,
			["inactiveAlpha"] = 0.300000011920929,
			["level"] = 10,
			["textsoffsets"] = {
				{
					["visible"] = true,
					["offsety"] = 0,
					["align"] = "TOPLEFT",
					["offsetx"] = 0,
					["size"] = 11,
				}, -- [1]
				{
					["visible"] = true,
					["offsety"] = 2,
					["align"] = "BOTTOMRIGHT",
					["offsetx"] = 0,
					["size"] = 11,
				}, -- [2]
				{
					["visible"] = true,
					["offsety"] = 2,
					["align"] = "BOTTOMLEFT",
					["offsetx"] = 0,
					["size"] = 11,
				}, -- [3]
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["mode"] = "BLEND",
			["width"] = 30,
			["colonne"] = 5,
			["speed"] = 4,
			["pulse"] = 1.1,
			["enable"] = true,
			["height"] = 30,
			["showSpiral"] = 2,
			["growup"] = false,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["blood"] = {
			["persistence"] = 7,
			["enable"] = true,
			["mode"] = "BLEND",
			["level"] = 1,
			["size"] = 0.8,
		},
		["anchor4"] = {
			["visible"] = true,
			["positiony"] = 281,
			["scale"] = 0.699999988079071,
			["width"] = 32,
			["info"] = "TIMERBARS 2",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 129.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["alignToGrid"] = true,
		["inCombat"] = false,
		["configname"] = "(BuildIn) WoW version 2",
		["combo"] = {
			["angleB"] = 0,
			["offsety"] = 0,
			["positiony"] = 4.543346191730052,
			["enable"] = true,
			["form"] = {
				false, -- [1]
				true, -- [2]
				false, -- [3]
				true, -- [4]
				false, -- [5]
				false, -- [6]
				false, -- [7]
			},
			["angleA"] = 36,
			["width"] = 22,
			["positionx"] = 65.68471581443288,
			["ptype"] = 2,
			["rayon"] = 169,
			["offsetx"] = 19,
			["height"] = 22,
			["mode"] = "BLEND",
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\combo2.tga",
			["level"] = 5,
		},
		["anchor6"] = {
			["visible"] = true,
			["positiony"] = 216,
			["scale"] = 1,
			["width"] = "32",
			["info"] = "CD",
			["positionx"] = 316.5,
			["height"] = "32",
			["level"] = 10,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["targetbar"] = {
			["fontSize"] = 8,
			["positiony"] = "-61.5",
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 0,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "CENTER",
			["width"] = "119",
			["textx"] = 0,
			["texty"] = 1,
			["showText"] = true,
			["height"] = "10",
			["orientation"] = "HORIZONTAL",
			["positionx"] = "99",
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.75,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["cursorspeed"] = 30,
		["timerbar"] = {
			["orderByTime"] = false,
			["enable"] = false,
			["font1Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["showSpark"] = true,
			["prop"] = false,
			["borderSize"] = 1,
			["cdColor"] = {
				["a"] = 0.8,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["showTimeLine"] = true,
			["inactiveAlpha"] = 0.3,
			["level"] = 4,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["activeAlphaCD"] = 1,
			["font2Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["activeAlpha"] = 1,
			["growup"] = false,
			["width"] = "180",
			["font1Size"] = 10,
			["timeline"] = 14,
			["font2Size"] = 15,
			["textsoffsets"] = {
				{
					["offsety"] = 1,
					["offsetx"] = 1,
				}, -- [1]
				{
					["offsety"] = 1,
					["offsetx"] = 0,
				}, -- [2]
			},
			["cdoffsety"] = 2,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["height"] = "20",
			["cdoffsetx"] = 0,
			["border"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeY"] = 0.25,
		["gps"] = {
			["fontSize"] = 16,
			["offsety"] = -22,
			["positiony"] = 187.9999704957013,
			["enable"] = true,
			["alpha"] = 1,
			["width"] = "48",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["positionx"] = 303.9999725818638,
			["offsetx"] = 0,
			["height"] = "36",
			["level"] = 10,
			["mode"] = "BLEND",
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["manabar"] = {
			["fontSize"] = 12,
			["positiony"] = 140,
			["color"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "RIGHT",
			["width"] = 192,
			["enable"] = false,
			["texty"] = 1,
			["showText"] = true,
			["orientation"] = "HORIZONTAL",
			["height"] = 18,
			["positionx"] = 8,
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["spells"] = {
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.2078431372549019,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 9846,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Fureur du tigre", -- [1]
				},
				["abiSpelltext"] = "Fureur du tigre",
				["timerbar"] = 1,
				["ids"] = {
					9846, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Buff",
				["abiSound"] = "",
				["spellIDs"] = "9846",
				["abiEnd"] = 0,
			}, -- [1]
			{
				["spellIDs"] = "16857;770;33602",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 1,
					["r"] = 0.9803921568627451,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 16857,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Lucioles (farouche)", -- [1]
					"Lucioles", -- [2]
					"Lucioles améliorées", -- [3]
				},
				["abiSpelltext"] = "Lucioles (farouche)",
				["timerbar"] = 1,
				["ids"] = {
					16857, -- [1]
					770, -- [2]
					33602, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [2]
			{
				["spellIDs"] = "33983;33987;46854",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0.4117647058823529,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33983,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 20.82400000000052,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Mutilation (félin)", -- [1]
					"Mutilation (ours)", -- [2]
					"Traumatisme", -- [3]
				},
				["abiSpelltext"] = "Mutilation (félin)",
				["timerbar"] = 1,
				["ids"] = {
					33983, -- [1]
					33987, -- [2]
					46854, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [3]
			{
				["spellIDs"] = "1822",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1822,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Griffure", -- [1]
				},
				["abiSpelltext"] = "Griffure",
				["timerbar"] = 1,
				["ids"] = {
					1822, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [4]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33745,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = true,
				["abiUserText"] = "",
				["names"] = {
					"Lacérer", -- [1]
				},
				["abiSpelltext"] = "Lacérer",
				["timerbar"] = 1,
				["ids"] = {
					33745, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "33745",
				["abiEnd"] = 0,
			}, -- [5]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1079,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Déchirure", -- [1]
				},
				["abiSpelltext"] = "Déchirure",
				["timerbar"] = 1,
				["ids"] = {
					1079, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "1079",
				["abiEnd"] = 0,
			}, -- [6]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0.4470588235294117,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 99,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 34.40899999999965,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Rugissement démoralisant", -- [1]
					"Cri démoralisant", -- [2]
				},
				["abiSpelltext"] = "Rugissement démoralisant",
				["timerbar"] = 1,
				["ids"] = {
					99, -- [1]
					25203, -- [2]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "99;25203",
				["abiEnd"] = 0,
			}, -- [7]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.6039215686274509,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 22812,
				["icon"] = false,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Ecorce", -- [1]
				},
				["abiSpelltext"] = "Ecorce",
				["timerbar"] = 2,
				["ids"] = {
					22812, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["sType"] = "Buff",
				["abiSound"] = "",
				["spellIDs"] = "22812",
				["abiEnd"] = 0,
			}, -- [10]
		},
		["healthbar"] = {
			["fontSize"] = 12,
			["positiony"] = 40,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["colorBad"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar2.tga",
			["colorAverage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.5,
				["b"] = 0,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["colorGood"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 1,
				["b"] = 0,
			},
			["level"] = 2,
			["width"] = 192,
			["positionx"] = 8,
			["height"] = 18,
			["showText"] = true,
			["texty"] = 1,
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["ooc"] = {
			["spell"] = 12536,
			["positiony"] = -55.94141839648199,
			["enable"] = true,
			["scaleMin"] = 0.699999988079071,
			["width"] = "256",
			["textureOff"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
			["height"] = "256",
			["scaleMax"] = 0.2000000029802322,
			["textureOn"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\ooc.tga",
			["speed"] = 0.04999999701976776,
			["positionx"] = 13.12168394550059,
			["level"] = 6,
			["mode"] = "ADD",
		},
		["cooldown"] = {
			["offsety"] = -32,
			["positiony"] = -45.34814293332622,
			["enable"] = true,
			["alpha"] = 0.75,
			["width"] = 32,
			["positionx"] = -21.087482406927,
			["height"] = 32,
			["mode"] = "BLEND",
			["level"] = 5,
			["offsetx"] = 0,
		},
		["anchor2"] = {
			["visible"] = true,
			["positiony"] = 268.25,
			["scale"] = 0.949999988079071,
			["width"] = 32,
			["info"] = "ICONS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 440.75,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["infos"] = {
			["fontSize"] = 12,
			["enable"] = false,
			["infolines"] = "PowerAttack: #meleeAP*Crit: #meleeCrit*Haste: #meleeHaste*ArPen: #armPen",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_typewriter.ttf",
			["level"] = 3,
			["backColor"] = {
				["a"] = 0,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["alert"] = {
			["texture1"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertBehind.tga",
			["positiony"] = -52.73155375681273,
			["enable"] = true,
			["texture3"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertSkull.tga",
			["width"] = "28",
			["texture2"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertRange.tga",
			["height"] = "28",
			["positionx"] = 13.47612207799284,
			["mode"] = "BLEND",
			["level"] = 5,
		},
		["anchor1"] = {
			["visible"] = true,
			["positiony"] = 273,
			["scale"] = 1.15,
			["width"] = "256",
			["info"] = "UI",
			["positionx"] = 336.75,
			["height"] = "128",
			["level"] = 4,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\UI_texture2.tga",
		},
	}, -- [3]
	{
		["configversion"] = 409,
		["MiniMapAngle"] = 215.8160744865155,
		["portrait"] = {
			["textures"] = {
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga", -- [1]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\bearform.tga", -- [2]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\aquaform.tga", -- [3]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\catform.tga", -- [4]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\travelform.tga", -- [5]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\moonkinform.tga", -- [6]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\flightform.tga", -- [7]
			},
			["height"] = "48",
			["mode"] = "ADD",
			["positiony"] = 0,
			["enable"] = true,
			["positionx"] = 1.72,
			["level"] = 5,
			["width"] = "48",
		},
		["powerbar"] = {
			["fontSize"] = 15,
			["positiony"] = "-18.5",
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 1,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorDef"] = {
				["a"] = 1,
				["r"] = 0.5,
				["v"] = 0.5,
				["b"] = 0.5,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "BOTTOMRIGHT",
			["positionx"] = "10",
			["height"] = 32,
			["textx"] = -3.5,
			["colorNrj"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["colorMana"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["colorRage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["arrows"] = {
				33983, -- [1]
				5221, -- [2]
				80, -- [3]
				1079, -- [4]
			},
			["width"] = 192,
			["showText"] = true,
			["enableArrows"] = true,
			["orientation"] = "HORIZONTAL",
			["texty"] = 2,
			["showSpark"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["threatbar"] = {
			["fontSize"] = 8,
			["positiony"] = -49.5,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 3,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["positionx"] = "10",
			["width"] = 192,
			["textx"] = -7,
			["texty"] = 1,
			["showText"] = false,
			["height"] = "6",
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeX"] = 0.25,
		["sound"] = {
			["enable"] = true,
			["soundfiles"] = {
				"", -- [1]
				"Sound\\Spells\\Druid_Pounce.wav", -- [2]
				"", -- [3]
				"Sound\\Spells\\Druid_FeralCharge.wav", -- [4]
				"", -- [5]
				"", -- [6]
				"", -- [7]
			},
		},
		["timelines"] = {
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["enable"] = true,
			["activeAlpha"] = 0.1,
			["width"] = 1,
		},
		["activeForms"] = {
			false, -- [1]
			true, -- [2]
			true, -- [3]
			true, -- [4]
			true, -- [5]
			false, -- [6]
			false, -- [7]
		},
		["anchor5"] = {
			["visible"] = true,
			["positiony"] = 263.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "INFOS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 679.5,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["anchor3"] = {
			["visible"] = true,
			["positiony"] = 211,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "TIMERBARS 1",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = "413",
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["icons"] = {
			["fontSize"] = 11,
			["orderByTime"] = true,
			["automatic"] = true,
			["activeAlpha"] = 1,
			["inactiveAlpha"] = 0.300000011920929,
			["level"] = 10,
			["textsoffsets"] = {
				{
					["visible"] = true,
					["offsety"] = 0,
					["align"] = "TOPLEFT",
					["offsetx"] = 1,
					["size"] = 11,
				}, -- [1]
				{
					["visible"] = true,
					["offsety"] = 2,
					["align"] = "TOPLEFT",
					["offsetx"] = 0,
					["size"] = 11,
				}, -- [2]
				{
					["visible"] = true,
					["offsety"] = 3,
					["align"] = "TOPLEFT",
					["offsetx"] = 1,
					["size"] = 11,
				}, -- [3]
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["mode"] = "BLEND",
			["width"] = 32,
			["colonne"] = 8,
			["speed"] = 4,
			["pulse"] = 1.1,
			["enable"] = false,
			["height"] = 32,
			["showSpiral"] = 2,
			["growup"] = false,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["blood"] = {
			["persistence"] = 7,
			["enable"] = true,
			["mode"] = "BLEND",
			["level"] = 1,
			["size"] = 0.6,
		},
		["anchor4"] = {
			["visible"] = false,
			["positiony"] = 314.25,
			["scale"] = 0.699999988079071,
			["width"] = 32,
			["info"] = "TIMERBARS 2",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 152.75,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["alignToGrid"] = true,
		["inCombat"] = false,
		["configname"] = "(BuildIn) Timerbars",
		["combo"] = {
			["angleB"] = 183,
			["offsety"] = 0,
			["positiony"] = -20,
			["enable"] = true,
			["form"] = {
				false, -- [1]
				true, -- [2]
				false, -- [3]
				true, -- [4]
				false, -- [5]
				false, -- [6]
				false, -- [7]
			},
			["angleA"] = 288,
			["width"] = 20,
			["positionx"] = 51.66293145777689,
			["ptype"] = 1,
			["rayon"] = 37,
			["offsetx"] = 20,
			["height"] = 20,
			["mode"] = "BLEND",
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\combo.tga",
			["level"] = 3,
		},
		["anchor6"] = {
			["visible"] = true,
			["positiony"] = 256,
			["scale"] = 1,
			["width"] = "32",
			["info"] = "CD",
			["positionx"] = 610.5,
			["height"] = "32",
			["level"] = 10,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["targetbar"] = {
			["fontSize"] = 11,
			["positiony"] = -6,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "CENTER",
			["width"] = 192,
			["textx"] = 0,
			["texty"] = 0.5,
			["showText"] = true,
			["height"] = "13",
			["orientation"] = "HORIZONTAL",
			["positionx"] = 10,
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.75,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["cursorspeed"] = 30,
		["timerbar"] = {
			["orderByTime"] = true,
			["enable"] = true,
			["font1Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["showSpark"] = true,
			["prop"] = false,
			["borderSize"] = 1,
			["cdColor"] = {
				["a"] = 0.8,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["showTimeLine"] = true,
			["inactiveAlpha"] = 0.3,
			["level"] = 4,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["activeAlphaCD"] = 1,
			["font2Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["activeAlpha"] = 1,
			["growup"] = true,
			["width"] = 192,
			["font1Size"] = 10,
			["timeline"] = 14,
			["font2Size"] = 20,
			["textsoffsets"] = {
				{
					["offsety"] = 2,
					["offsetx"] = 0,
				}, -- [1]
				{
					["offsety"] = 0,
					["offsetx"] = 2,
				}, -- [2]
			},
			["cdoffsety"] = 2,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["height"] = "20",
			["cdoffsetx"] = 0,
			["border"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeY"] = 0.25,
		["gps"] = {
			["fontSize"] = 16,
			["offsety"] = -22,
			["positiony"] = 208.9998786300439,
			["enable"] = true,
			["alpha"] = 1,
			["width"] = "48",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["positionx"] = 355.9999794363978,
			["offsetx"] = 0,
			["height"] = "36",
			["level"] = 10,
			["mode"] = "BLEND",
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["manabar"] = {
			["fontSize"] = 12,
			["positiony"] = 140,
			["color"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "RIGHT",
			["width"] = 192,
			["enable"] = false,
			["texty"] = 1,
			["showText"] = true,
			["orientation"] = "HORIZONTAL",
			["height"] = 18,
			["positionx"] = 8,
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["spells"] = {
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.2078431372549019,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 9846,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Fureur du tigre", -- [1]
				},
				["abiSpelltext"] = "Fureur du tigre",
				["timerbar"] = 1,
				["ids"] = {
					9846, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Buff",
				["abiSound"] = "",
				["spellIDs"] = "9846",
				["abiEnd"] = 0,
			}, -- [1]
			{
				["spellIDs"] = "16857;770;33602",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 1,
					["r"] = 0.9803921568627451,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 16857,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Lucioles (farouche)", -- [1]
					"Lucioles", -- [2]
					"Lucioles améliorées", -- [3]
				},
				["abiSpelltext"] = "Lucioles (farouche)",
				["timerbar"] = 1,
				["ids"] = {
					16857, -- [1]
					770, -- [2]
					33602, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [2]
			{
				["spellIDs"] = "33983;33987;46854",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0.4117647058823529,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33983,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 24.04099999999926,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Mutilation (félin)", -- [1]
					"Mutilation (ours)", -- [2]
					"Traumatisme", -- [3]
				},
				["abiSpelltext"] = "Mutilation (félin)",
				["timerbar"] = 1,
				["ids"] = {
					33983, -- [1]
					33987, -- [2]
					46854, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [3]
			{
				["spellIDs"] = "1822",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1822,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Griffure", -- [1]
				},
				["abiSpelltext"] = "Griffure",
				["timerbar"] = 1,
				["ids"] = {
					1822, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [4]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33745,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = true,
				["abiUserText"] = "",
				["names"] = {
					"Lacérer", -- [1]
				},
				["abiSpelltext"] = "Lacérer",
				["timerbar"] = 1,
				["ids"] = {
					33745, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "33745",
				["abiEnd"] = 0,
			}, -- [5]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1079,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Déchirure", -- [1]
				},
				["abiSpelltext"] = "Déchirure",
				["timerbar"] = 1,
				["ids"] = {
					1079, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "1079",
				["abiEnd"] = 0,
			}, -- [6]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0.4470588235294117,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 99,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Rugissement démoralisant", -- [1]
					"Cri démoralisant", -- [2]
				},
				["abiSpelltext"] = "Rugissement démoralisant",
				["timerbar"] = 1,
				["ids"] = {
					99, -- [1]
					25203, -- [2]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "99;25203",
				["abiEnd"] = 0,
			}, -- [7]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.1411764705882353,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 5211,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Sonner", -- [1]
				},
				["abiSpelltext"] = "Sonner",
				["timerbar"] = 1,
				["ids"] = {
					5211, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["spellIDs"] = "5211",
				["abiEnd"] = 0,
			}, -- [8]
			{
				["spellIDs"] = "22812",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0.6039215686274509,
					["v"] = 1,
					["r"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 22812,
				["icon"] = false,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Buff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Ecorce", -- [1]
				},
				["abiSpelltext"] = "Ecorce",
				["timerbar"] = 2,
				["ids"] = {
					22812, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["abiSound"] = "",
				["height"] = 32,
				["abiEnd"] = 0,
			}, -- [11]
		},
		["healthbar"] = {
			["fontSize"] = 12,
			["positiony"] = 40,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["colorBad"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorAverage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.5,
				["b"] = 0,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["colorGood"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 1,
				["b"] = 0,
			},
			["level"] = 2,
			["width"] = 192,
			["positionx"] = 8,
			["height"] = 18,
			["showText"] = true,
			["texty"] = 1,
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["ooc"] = {
			["spell"] = 12536,
			["positiony"] = -6,
			["enable"] = true,
			["scaleMin"] = 1,
			["width"] = "650",
			["textureOff"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
			["height"] = "150",
			["scaleMax"] = 0.1,
			["textureOn"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\ooc.tga",
			["speed"] = 0.09999999403953552,
			["positionx"] = 72,
			["level"] = 10,
			["mode"] = "ADD",
		},
		["cooldown"] = {
			["offsety"] = -52,
			["positiony"] = -1.000137314198355,
			["enable"] = true,
			["alpha"] = 0.75,
			["width"] = 50,
			["positionx"] = 199.9999970197678,
			["height"] = 50,
			["mode"] = "BLEND",
			["level"] = 5,
			["offsetx"] = 0,
		},
		["anchor2"] = {
			["visible"] = true,
			["positiony"] = 377.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "ICONS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 149.75,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["infos"] = {
			["fontSize"] = 10,
			["enable"] = false,
			["infolines"] = "PowerAttack: #meleeAP*Crit: #meleeCrit*Haste: #meleeHaste*ArPen: #armPen",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_typewriter.ttf",
			["level"] = 20,
			["backColor"] = {
				["a"] = 0,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["textColor"] = {
				["a"] = 0.4600000381469727,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["alert"] = {
			["texture1"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertBehind.tga",
			["positiony"] = 51.00009842216821,
			["enable"] = true,
			["texture3"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertSkull.tga",
			["width"] = "64",
			["texture2"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertRange.tga",
			["height"] = "64",
			["positionx"] = 73.99997600913082,
			["mode"] = "BLEND",
			["level"] = 5,
		},
		["anchor1"] = {
			["visible"] = true,
			["positiony"] = 257.5,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "UI",
			["positionx"] = 411,
			["height"] = 32,
			["level"] = 1,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
	}, -- [4]
	{
		["configversion"] = 409,
		["MiniMapAngle"] = 215.8160744865155,
		["portrait"] = {
			["textures"] = {
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga", -- [1]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\bearform.tga", -- [2]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\aquaform.tga", -- [3]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\catform.tga", -- [4]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\travelform.tga", -- [5]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\moonkinform.tga", -- [6]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\flightform.tga", -- [7]
			},
			["height"] = "64",
			["mode"] = "ADD",
			["positiony"] = 80.48189043280644,
			["enable"] = false,
			["positionx"] = -166.824681657185,
			["level"] = 5,
			["width"] = "64",
		},
		["powerbar"] = {
			["fontSize"] = 15,
			["positiony"] = -18.25,
			["enable"] = true,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 1,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorDef"] = {
				["a"] = 1,
				["r"] = 0.5,
				["v"] = 0.5,
				["b"] = 0.5,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "BOTTOMRIGHT",
			["positionx"] = 10.25,
			["height"] = 32,
			["textx"] = -3.5,
			["colorNrj"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["colorMana"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["colorRage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["arrows"] = {
				33983, -- [1]
				5221, -- [2]
				80, -- [3]
				1079, -- [4]
			},
			["width"] = 192,
			["showText"] = true,
			["enableArrows"] = true,
			["orientation"] = "HORIZONTAL",
			["texty"] = 2,
			["showSpark"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["threatbar"] = {
			["fontSize"] = 8,
			["positiony"] = 66,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 3,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["positionx"] = -117.25,
			["width"] = 192,
			["textx"] = -7,
			["texty"] = 1,
			["showText"] = false,
			["height"] = "6",
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeX"] = 0.25,
		["sound"] = {
			["enable"] = true,
			["soundfiles"] = {
				"", -- [1]
				"Sound\\Spells\\Druid_Pounce.wav", -- [2]
				"", -- [3]
				"Sound\\Spells\\Druid_FeralCharge.wav", -- [4]
				"", -- [5]
				"", -- [6]
				"", -- [7]
			},
		},
		["timelines"] = {
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["enable"] = true,
			["activeAlpha"] = 0.1,
			["width"] = 1,
		},
		["activeForms"] = {
			false, -- [1]
			true, -- [2]
			true, -- [3]
			true, -- [4]
			true, -- [5]
			false, -- [6]
			false, -- [7]
		},
		["anchor5"] = {
			["visible"] = true,
			["positiony"] = 266.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "INFOS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 247.5,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["anchor3"] = {
			["visible"] = true,
			["positiony"] = 433,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "TIMERBARS 1",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 238.5,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["icons"] = {
			["fontSize"] = 13,
			["orderByTime"] = true,
			["automatic"] = true,
			["activeAlpha"] = 1,
			["inactiveAlpha"] = 0.300000011920929,
			["level"] = 10,
			["textsoffsets"] = {
				{
					["visible"] = true,
					["offsety"] = -1,
					["align"] = "TOPLEFT",
					["offsetx"] = 1,
					["size"] = 13,
				}, -- [1]
				{
					["visible"] = true,
					["offsety"] = 2,
					["align"] = "BOTTOMRIGHT",
					["offsetx"] = 0,
					["size"] = 13,
				}, -- [2]
				{
					["visible"] = true,
					["offsety"] = 2,
					["align"] = "BOTTOMLEFT",
					["offsetx"] = 1,
					["size"] = 13,
				}, -- [3]
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["mode"] = "BLEND",
			["width"] = 37,
			["colonne"] = 8,
			["speed"] = 4,
			["pulse"] = 1.1,
			["enable"] = true,
			["height"] = 37,
			["showSpiral"] = 2,
			["growup"] = false,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["blood"] = {
			["persistence"] = 7,
			["enable"] = true,
			["mode"] = "BLEND",
			["level"] = 1,
			["size"] = 0.6,
		},
		["anchor4"] = {
			["visible"] = false,
			["positiony"] = 401.5,
			["scale"] = 0.699999988079071,
			["width"] = 32,
			["info"] = "TIMERBARS 2",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 238.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["alignToGrid"] = true,
		["inCombat"] = false,
		["configname"] = "(BuildIn) Compact",
		["combo"] = {
			["angleB"] = 183,
			["offsety"] = 0,
			["positiony"] = -21,
			["enable"] = true,
			["form"] = {
				false, -- [1]
				true, -- [2]
				false, -- [3]
				true, -- [4]
				false, -- [5]
				false, -- [6]
				false, -- [7]
			},
			["angleA"] = 288,
			["width"] = 20,
			["positionx"] = 9,
			["ptype"] = 1,
			["rayon"] = 37,
			["offsetx"] = 20,
			["height"] = 20,
			["mode"] = "BLEND",
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\combo.tga",
			["level"] = 3,
		},
		["anchor6"] = {
			["visible"] = true,
			["positiony"] = 272.5,
			["scale"] = 1,
			["width"] = "32",
			["info"] = "CD",
			["positionx"] = 612.75,
			["height"] = "32",
			["level"] = 10,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["targetbar"] = {
			["fontSize"] = 11,
			["positiony"] = 218.75,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "CENTER",
			["width"] = 192,
			["textx"] = 0,
			["texty"] = 1.5,
			["showText"] = true,
			["height"] = "13",
			["orientation"] = "HORIZONTAL",
			["positionx"] = -242.75,
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.75,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["cursorspeed"] = 30,
		["timerbar"] = {
			["orderByTime"] = true,
			["enable"] = false,
			["font1Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["showSpark"] = true,
			["prop"] = false,
			["borderSize"] = 1,
			["cdColor"] = {
				["a"] = 0.8,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["showTimeLine"] = true,
			["inactiveAlpha"] = 0.3,
			["level"] = 4,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["activeAlphaCD"] = 1,
			["font2Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["activeAlpha"] = 1,
			["growup"] = false,
			["width"] = 192,
			["font1Size"] = 10,
			["timeline"] = 14,
			["font2Size"] = 18,
			["textsoffsets"] = {
				{
					["offsety"] = 1,
					["offsetx"] = 1,
				}, -- [1]
				{
					["offsety"] = 1,
					["offsetx"] = 0,
				}, -- [2]
			},
			["cdoffsety"] = 2,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["height"] = "20",
			["cdoffsetx"] = 0,
			["border"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeY"] = 0.25,
		["gps"] = {
			["fontSize"] = 16,
			["offsety"] = -22,
			["positiony"] = 224.0000309944148,
			["enable"] = true,
			["alpha"] = 0.7,
			["width"] = "48",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["positionx"] = 352.9999871104957,
			["offsetx"] = 0,
			["height"] = "36",
			["level"] = 13,
			["mode"] = "BLEND",
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["manabar"] = {
			["fontSize"] = 12,
			["positiony"] = 140,
			["color"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textAlign"] = "RIGHT",
			["width"] = 192,
			["enable"] = false,
			["texty"] = 1,
			["showText"] = true,
			["orientation"] = "HORIZONTAL",
			["height"] = 18,
			["positionx"] = 8,
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["spells"] = {
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.2078431372549019,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 9846,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Fureur du tigre", -- [1]
				},
				["abiSpelltext"] = "Fureur du tigre",
				["timerbar"] = 1,
				["ids"] = {
					9846, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Buff",
				["abiSound"] = "",
				["spellIDs"] = "9846",
				["abiEnd"] = 0,
			}, -- [1]
			{
				["spellIDs"] = "16857;770;33602",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 1,
					["r"] = 0.9803921568627451,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 16857,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 16.2549999999992,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Lucioles (farouche)", -- [1]
					"Lucioles", -- [2]
					"Lucioles améliorées", -- [3]
				},
				["abiSpelltext"] = "Lucioles (farouche)",
				["timerbar"] = 1,
				["ids"] = {
					16857, -- [1]
					770, -- [2]
					33602, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [2]
			{
				["spellIDs"] = "33983;33987;46854",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0.4117647058823529,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33983,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 40.20700000000034,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Mutilation (félin)", -- [1]
					"Mutilation (ours)", -- [2]
					"Traumatisme", -- [3]
				},
				["abiSpelltext"] = "Mutilation (félin)",
				["timerbar"] = 1,
				["ids"] = {
					33983, -- [1]
					33987, -- [2]
					46854, -- [3]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [3]
			{
				["spellIDs"] = "1822",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1822,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 9.003000000000611,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Griffure", -- [1]
				},
				["abiSpelltext"] = "Griffure",
				["timerbar"] = 1,
				["ids"] = {
					1822, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["abiEnd"] = 0,
			}, -- [4]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33745,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = true,
				["abiUserText"] = "",
				["names"] = {
					"Lacérer", -- [1]
				},
				["abiSpelltext"] = "Lacérer",
				["timerbar"] = 1,
				["ids"] = {
					33745, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "33745",
				["abiEnd"] = 0,
			}, -- [5]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 1079,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 13.98799999999937,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Déchirure", -- [1]
				},
				["abiSpelltext"] = "Déchirure",
				["timerbar"] = 1,
				["ids"] = {
					1079, -- [1]
				},
				["form"] = {
					false, -- [1]
					false, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "1079",
				["abiEnd"] = 0,
			}, -- [6]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0,
					["v"] = 0.4470588235294117,
					["r"] = 1,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 99,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 11.45600000000013,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Rugissement démoralisant", -- [1]
					"Cri démoralisant", -- [2]
				},
				["abiSpelltext"] = "Rugissement démoralisant",
				["timerbar"] = 1,
				["ids"] = {
					99, -- [1]
					25203, -- [2]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["height"] = 32,
				["abiSound"] = "",
				["spellIDs"] = "99;25203",
				["abiEnd"] = 0,
			}, -- [7]
			{
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 0,
					["v"] = 1,
					["b"] = 0.1411764705882353,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 5211,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 3.983000000000175,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Sonner", -- [1]
				},
				["abiSpelltext"] = "Sonner",
				["timerbar"] = 1,
				["ids"] = {
					5211, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					false, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["sType"] = "Debuff",
				["abiSound"] = "",
				["spellIDs"] = "5211",
				["abiEnd"] = 0,
			}, -- [8]
			{
				["spellIDs"] = "22812",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0.6039215686274509,
					["v"] = 1,
					["r"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 22812,
				["icon"] = false,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Buff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Ecorce", -- [1]
				},
				["abiSpelltext"] = "Ecorce",
				["timerbar"] = 2,
				["ids"] = {
					22812, -- [1]
				},
				["form"] = {
					false, -- [1]
					true, -- [2]
					false, -- [3]
					true, -- [4]
					false, -- [5]
					false, -- [6]
					false, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["abiSound"] = "",
				["height"] = 32,
				["abiEnd"] = 0,
			}, -- [11]
		},
		["healthbar"] = {
			["fontSize"] = 12,
			["positiony"] = 40,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["colorBad"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorAverage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.5,
				["b"] = 0,
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["colorGood"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 1,
				["b"] = 0,
			},
			["level"] = 2,
			["width"] = 192,
			["positionx"] = 8,
			["height"] = 18,
			["showText"] = true,
			["texty"] = 1,
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["ooc"] = {
			["spell"] = 12536,
			["positiony"] = 16,
			["enable"] = true,
			["scaleMin"] = 1,
			["width"] = "650",
			["textureOff"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
			["height"] = "150",
			["scaleMax"] = 0.1,
			["textureOn"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\ooc.tga",
			["speed"] = 0.09999999403953552,
			["positionx"] = 73,
			["level"] = 10,
			["mode"] = "ADD",
		},
		["cooldown"] = {
			["offsety"] = -52,
			["positiony"] = -5.646686469812892,
			["enable"] = true,
			["alpha"] = 0.75,
			["width"] = 50,
			["positionx"] = 202.7081650091981,
			["height"] = 50,
			["mode"] = "BLEND",
			["level"] = 5,
			["offsetx"] = 0,
		},
		["anchor2"] = {
			["visible"] = true,
			["positiony"] = 233.75,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "ICONS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 412,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["infos"] = {
			["fontSize"] = 10,
			["enable"] = false,
			["infolines"] = "PowerAttack: #meleeAP*Crit: #meleeCrit*Haste: #meleeHaste*ArPen: #armPen",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_typewriter.ttf",
			["level"] = 20,
			["backColor"] = {
				["a"] = 0,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["textColor"] = {
				["a"] = 0.4600000381469727,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["alert"] = {
			["texture1"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertBehind.tga",
			["positiony"] = 38.18697932947816,
			["enable"] = true,
			["texture3"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertSkull.tga",
			["width"] = "64",
			["texture2"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertRange.tga",
			["height"] = "64",
			["positionx"] = 73.99974628334167,
			["mode"] = "BLEND",
			["level"] = 5,
		},
		["anchor1"] = {
			["visible"] = true,
			["positiony"] = 278.25,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "UI",
			["positionx"] = "411",
			["height"] = 32,
			["level"] = 1,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
	}, -- [5]
	{
		["configversion"] = 409,
		["MiniMapAngle"] = 122.5361970818473,
		["portrait"] = {
			["textures"] = {
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga", -- [1]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\bearform.tga", -- [2]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\aquaform.tga", -- [3]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\catform.tga", -- [4]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\travelform.tga", -- [5]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\moonkinform.tga", -- [6]
				"Interface\\AddOns\\DroodFocus-TBC\\datas\\flightform.tga", -- [7]
			},
			["height"] = "48",
			["level"] = 5,
			["positiony"] = "1",
			["enable"] = true,
			["mode"] = "ADD",
			["positionx"] = "1.8",
			["width"] = "48",
		},
		["powerbar"] = {
			["fontSize"] = 13,
			["positiony"] = "-18.5",
			["enable"] = true,
			["showSpark"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 1,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorDef"] = {
				["a"] = 1,
				["r"] = 0.5,
				["v"] = 0.5,
				["b"] = 0.5,
			},
			["positionx"] = "10",
			["textx"] = -3.5,
			["textAlign"] = "BOTTOMRIGHT",
			["height"] = 32,
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["colorNrj"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 0,
			},
			["colorMana"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["enableArrows"] = false,
			["arrows"] = {
				33983, -- [1]
				5221, -- [2]
				80, -- [3]
				1079, -- [4]
			},
			["width"] = 192,
			["showText"] = true,
			["colorRage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["orientation"] = "HORIZONTAL",
			["texty"] = 2,
			["border"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["threatbar"] = {
			["fontSize"] = 8,
			["positiony"] = -49.5,
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 3,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textx"] = -7,
			["width"] = 192,
			["texty"] = 1,
			["positionx"] = "10",
			["showText"] = false,
			["height"] = "6",
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["enable"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeX"] = 0.25,
		["sound"] = {
			["enable"] = true,
			["soundfiles"] = {
				"", -- [1]
				"Sound\\Spells\\Druid_Pounce.wav", -- [2]
				"", -- [3]
				"Sound\\Spells\\Druid_FeralCharge.wav", -- [4]
				"", -- [5]
				"", -- [6]
				"", -- [7]
			},
		},
		["timelines"] = {
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["enable"] = true,
			["activeAlpha"] = 0.1,
			["width"] = 1,
		},
		["activeForms"] = {
			true, -- [1]
			false, -- [2]
			true, -- [3]
			false, -- [4]
			true, -- [5]
			true, -- [6]
			true, -- [7]
		},
		["anchor5"] = {
			["visible"] = true,
			["positiony"] = 282,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "INFOS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 125,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["anchor3"] = {
			["visible"] = true,
			["positiony"] = 228.25,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "TIMERBARS 1",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 123.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["icons"] = {
			["fontSize"] = 13,
			["orderByTime"] = false,
			["decimal"] = false,
			["automatic"] = true,
			["activeAlpha"] = 1,
			["inactiveAlpha"] = 0.3,
			["level"] = 10,
			["textsoffsets"] = {
				{
					["visible"] = true,
					["offsety"] = 1,
					["align"] = "BOTTOM",
					["offsetx"] = 1,
					["size"] = 16,
				}, -- [1]
				{
					["visible"] = false,
					["offsety"] = 2,
					["align"] = "TOPLEFT",
					["offsetx"] = 1,
					["size"] = 13,
				}, -- [2]
				{
					["visible"] = true,
					["offsety"] = -1,
					["align"] = "TOPLEFT",
					["offsetx"] = 1,
					["size"] = 10,
				}, -- [3]
			},
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["mode"] = "BLEND",
			["pointpa"] = false,
			["width"] = 37,
			["colonne"] = 8,
			["speed"] = 4,
			["pulse"] = 2,
			["enable"] = true,
			["height"] = 37,
			["showSpiral"] = 2,
			["growup"] = false,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["blood"] = {
			["persistence"] = 7,
			["enable"] = false,
			["mode"] = "BLEND",
			["level"] = 1,
			["size"] = 0.6,
		},
		["anchor4"] = {
			["visible"] = true,
			["positiony"] = 162.5,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "TIMERBARS 2",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 409.5,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["alignToGrid"] = true,
		["inCombat"] = false,
		["configname"] = "(BuildIn) Moonkin",
		["combo"] = {
			["enable"] = true,
			["offsety"] = 0,
			["positiony"] = "-21",
			["angleB"] = 183,
			["form"] = {
				false, -- [1]
				true, -- [2]
				false, -- [3]
				true, -- [4]
				false, -- [5]
				false, -- [6]
				false, -- [7]
			},
			["angleA"] = 288,
			["width"] = 20,
			["positionx"] = 51.66293145777689,
			["ptype"] = 1,
			["rayon"] = 37,
			["offsetx"] = 20,
			["height"] = 20,
			["level"] = 3,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\combo.tga",
			["mode"] = "BLEND",
		},
		["anchor6"] = {
			["visible"] = true,
			["positiony"] = 206.25,
			["scale"] = 0.9,
			["width"] = "32",
			["info"] = "CD",
			["positionx"] = 368.5,
			["height"] = "32",
			["level"] = 10,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["minimap"] = false,
		["targetbar"] = {
			["fontSize"] = 11,
			["positiony"] = -6,
			["color"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.75,
				["b"] = 0,
			},
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["textx"] = 0,
			["width"] = 192,
			["texty"] = 0.5,
			["textAlign"] = "CENTER",
			["showText"] = true,
			["height"] = "13",
			["orientation"] = "HORIZONTAL",
			["positionx"] = 10,
			["enable"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["infos"] = {
			["fontSize"] = 10,
			["enable"] = false,
			["infolines"] = "PowerAttack: #meleeAP*Crit: #meleeCrit*Haste: #meleeHaste*ArPen: #armPen",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_typewriter.ttf",
			["level"] = 20,
			["backColor"] = {
				["a"] = 0,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
			["textColor"] = {
				["a"] = 0.4600000381469727,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["timerbar"] = {
			["orderByTime"] = true,
			["enable"] = true,
			["font1Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["showSpark"] = true,
			["prop"] = false,
			["borderSize"] = 1,
			["cdColor"] = {
				["a"] = 0.800000011920929,
				["r"] = 1,
				["v"] = 0.8666666666666667,
				["b"] = 0,
			},
			["showTimeLine"] = true,
			["inactiveAlpha"] = 0,
			["level"] = 4,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["activeAlphaCD"] = 1,
			["font2Path"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["activeAlpha"] = 1,
			["growup"] = true,
			["timeline"] = 14,
			["font1Size"] = 12,
			["width"] = "192",
			["font2Size"] = 21,
			["textsoffsets"] = {
				{
					["offsety"] = 2,
					["offsetx"] = 2,
				}, -- [1]
				{
					["offsety"] = 0,
					["offsetx"] = 1,
				}, -- [2]
			},
			["cdoffsety"] = 2,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["height"] = "20",
			["cdoffsetx"] = 0,
			["border"] = true,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["gridSizeY"] = 0.25,
		["gps"] = {
			["fontSize"] = 16,
			["offsety"] = -22,
			["positiony"] = 258.9992293864603,
			["enable"] = true,
			["alpha"] = 1,
			["width"] = "48",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font_digital.ttf",
			["offsetx"] = 0,
			["positionx"] = 479.9999928474427,
			["height"] = "36",
			["mode"] = "BLEND",
			["level"] = 10,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["manabar"] = {
			["fontSize"] = 12,
			["positiony"] = 140,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["level"] = 2,
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["color"] = {
				["r"] = 0,
				["v"] = 0,
				["b"] = 1,
			},
			["width"] = 192,
			["texty"] = 1,
			["textAlign"] = "RIGHT",
			["showText"] = true,
			["orientation"] = "HORIZONTAL",
			["height"] = 18,
			["positionx"] = 8,
			["textx"] = -7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["spells"] = {
			{
				["spellIDs"] = "26988",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 26988,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 11.65200000000186,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Eclat lunaire", -- [1]
				},
				["abiSpelltext"] = "Eclat lunaire",
				["timerbar"] = 0,
				["ids"] = {
					26988, -- [1]
				},
				["form"] = {
					true, -- [1]
					false, -- [2]
					true, -- [3]
					false, -- [4]
					true, -- [5]
					true, -- [6]
					true, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["abiSound"] = "",
				["sType"] = "Debuff",
				["abiEnd"] = 0,
			}, -- [3]
			{
				["spellIDs"] = "27013",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["r"] = 1,
					["v"] = 0,
					["b"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 48468,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["height"] = 32,
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Essaim d'insectes", -- [2]
				},
				["abiSpelltext"] = "Essaim d'insectes",
				["timerbar"] = 0,
				["ids"] = {
					27013, -- [1]
				},
				["form"] = {
					true, -- [1]
					false, -- [2]
					true, -- [3]
					false, -- [4]
					true, -- [5]
					true, -- [6]
					true, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = true,
				["abiSound"] = "",
				["sType"] = "Debuff",
				["abiEnd"] = 0,
			}, -- [4]
			{
				["spellIDs"] = "33602;770",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0.6039215686274509,
					["v"] = 1,
					["r"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33602,
				["icon"] = true,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = false,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Lucioles améliorées", -- [1]
					"Lucioles", -- [2]
				},
				["abiSpelltext"] = "Lucioles améliorées",
				["timerbar"] = 0,
				["ids"] = {
					33602, -- [1]
					770, -- [2]
				},
				["form"] = {
					true, -- [1]
					false, -- [2]
					true, -- [3]
					false, -- [4]
					true, -- [5]
					true, -- [6]
					true, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["abiSound"] = "",
				["height"] = 32,
				["abiEnd"] = 0,
			}, -- [5]
			{
				["spellIDs"] = "33831",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 0.2078431372549019,
					["v"] = 1,
					["r"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 33831,
				["icon"] = false,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Buff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Force de la nature", -- [1]
				},
				["abiSpelltext"] = "Force de la nature",
				["timerbar"] = 2,
				["ids"] = {
					33831, -- [1]
				},
				["form"] = {
					true, -- [1]
					false, -- [2]
					true, -- [3]
					false, -- [4]
					true, -- [5]
					true, -- [6]
					true, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["abiSound"] = "",
				["height"] = 32,
				["abiEnd"] = 0,
			}, -- [6]
			{
				["spellIDs"] = "37124",
				["abiStack"] = 0,
				["positiony"] = 0,
				["color"] = {
					["a"] = 1,
					["b"] = 1,
					["v"] = 0.984313725490196,
					["r"] = 0,
				},
				["showcd"] = true,
				["abiCD"] = 0,
				["abiOldTimeLeft"] = 0,
				["abiSpellId"] = 37124,
				["icon"] = false,
				["abiAlphaPulse"] = 0,
				["abiInternalCD"] = 0,
				["abiUpTime"] = 0,
				["abiUptime"] = 0,
				["perso"] = true,
				["abiTimeLeft"] = 0,
				["sType"] = "Debuff",
				["positionx"] = 0,
				["abiStart"] = 0,
				["abiDuration"] = 0,
				["combo"] = false,
				["abiUserText"] = "",
				["names"] = {
					"Météores", -- [1]
				},
				["abiSpelltext"] = "Météores",
				["timerbar"] = 2,
				["ids"] = {
					37124, -- [1]
				},
				["form"] = {
					true, -- [1]
					false, -- [2]
					true, -- [3]
					false, -- [4]
					true, -- [5]
					true, -- [6]
					true, -- [7]
				},
				["strongcheck"] = false,
				["width"] = 32,
				["abiPower"] = 0,
				["getUptime"] = false,
				["abiSound"] = "",
				["height"] = 32,
				["abiEnd"] = 0,
			}, -- [7]
		},
		["ooc"] = {
			["spell"] = 12536,
			["positiony"] = 100.3328308413501,
			["enable"] = true,
			["scaleMin"] = 1,
			["width"] = "256",
			["textureOff"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
			["speed"] = 0.1,
			["scaleMax"] = 0.1,
			["textureOn"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\ooc.tga",
			["height"] = "256",
			["positionx"] = 73.92936596379627,
			["level"] = 10,
			["mode"] = "ADD",
		},
		["healthbar"] = {
			["fontSize"] = 12,
			["positiony"] = 40,
			["enable"] = false,
			["border"] = true,
			["borderSize"] = 1,
			["borderColor"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 0,
				["b"] = 0,
			},
			["colorBad"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0,
				["b"] = 0,
			},
			["texturePath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\statusbar.tga",
			["colorAverage"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 0.5,
				["b"] = 0,
			},
			["colorchg"] = true,
			["textx"] = -7,
			["fontPath"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\font.ttf",
			["level"] = 2,
			["width"] = 192,
			["positionx"] = 8,
			["height"] = 18,
			["showText"] = true,
			["texty"] = 1,
			["orientation"] = "HORIZONTAL",
			["textAlign"] = "RIGHT",
			["colorGood"] = {
				["a"] = 1,
				["r"] = 0,
				["v"] = 1,
				["b"] = 0,
			},
			["textColor"] = {
				["a"] = 1,
				["r"] = 1,
				["v"] = 1,
				["b"] = 1,
			},
		},
		["cooldown"] = {
			["offsety"] = -52,
			["positiony"] = -1.000137314198355,
			["enable"] = true,
			["alpha"] = 0.8,
			["width"] = 48,
			["offsetx"] = 0,
			["height"] = 48,
			["positionx"] = 199.9999970197678,
			["level"] = 5,
			["mode"] = "BLEND",
		},
		["anchor2"] = {
			["visible"] = true,
			["positiony"] = "252",
			["scale"] = 1,
			["width"] = 32,
			["info"] = "ICONS",
			["mode"] = "BLEND",
			["height"] = 32,
			["positionx"] = 409.25,
			["level"] = 1,
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
		["cursorspeed"] = 100,
		["alert"] = {
			["texture1"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertBehind.tga",
			["positiony"] = 100.0000748038281,
			["enable"] = true,
			["texture3"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertSkull.tga",
			["width"] = "64",
			["texture2"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\alertRange.tga",
			["height"] = "64",
			["level"] = 5,
			["mode"] = "BLEND",
			["positionx"] = 73.82354626322467,
		},
		["anchor1"] = {
			["visible"] = true,
			["positiony"] = 211.5,
			["scale"] = 1,
			["width"] = 32,
			["info"] = "UI",
			["positionx"] = 408,
			["height"] = 32,
			["level"] = 1,
			["mode"] = "BLEND",
			["texture"] = "Interface\\AddOns\\DroodFocus-TBC\\datas\\empty.tga",
		},
	}, -- [1]
}

DF_sharemedia = {
}

DF_talents = {
}

