----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - options
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 2
----------------------------------------------------------------------------------------------------

-- namespace
local DF = DF_namespace

local DroodFocusOptions = {}
local debuffListButton = {}

local selectPt=nil
local currentPosition=1
local nbLines = 8

local startX=16
local startY=-16
local startLevel=1

local trash = {}
local lignes = {}

local _G = getfenv(0);

local options_sharemedia = {["fpath"]="",["ftype"]="",["fname"]=""}
local shareMediaFrame = nil
local shareMediaTexture = nil
local shareMediaBox = nil
local shareMediaFont=nil

local apercutexture = nil
local apercutexture_texture= nil

DF.selectedSpell=nil

StaticPopupDialogs["MEDIAERREUR"] = {
  text = "- DroodFocus -\n\n%s",
  button1 = "Ok",
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
};

local optionsTarget={
	{texte="none",valeur="",form=nil},
	{texte="target ",valeur="target",form=nil},
	{texte="focus",valeur="focus",form=nil},
	{texte="pet",valeur="pet",form=nil},
}

-- table pour listes de choix
local optionsBlend={
	{texte="BLEND",valeur="BLEND",form=nil},
	{texte="ADD",valeur="ADD",form=nil},
	{texte="MOD",valeur="MOD",form=nil},
	{texte="ALPHAKEY",valeur="ALPHAKEY",form=nil},
	{texte="DISABLE",valeur="DISABLE",form=nil},
}

local optionsTimerbar={
	{texte=DF.locale["none"],valeur=0,form=nil},
	{texte=DF.locale["timerbar"].." 1",valeur=1,form=nil},
	{texte=DF.locale["timerbar"].." 2",valeur=2,form=nil},
}

local optionsSpiral={
	{texte=DF.locale["spiral1"],valeur=1,form=nil},
	{texte=DF.locale["spiral2"],valeur=2,form=nil},
	{texte=DF.locale["spiral3"],valeur=3,form=nil},
}

local optionsCombotype={
	{texte=DF.locale["linear"],valeur=1,form=nil},
	{texte=DF.locale["radial"],valeur=2,form=nil},
}

local optionsTextalign={
	{texte=DF.locale["TOPLEFT"],valeur="TOPLEFT",form=nil},
	{texte=DF.locale["TOP"],valeur="TOP",form=nil},
	{texte=DF.locale["TOPRIGHT"],valeur="TOPRIGHT",form=nil},
	{texte=DF.locale["LEFT"],valeur="LEFT",form=nil},
	{texte=DF.locale["CENTER"],valeur="CENTER",form=nil},
	{texte=DF.locale["RIGHT"],valeur="RIGHT",form=nil},
	{texte=DF.locale["BOTTOMLEFT"],valeur="BOTTOMLEFT",form=nil},
	{texte=DF.locale["BOTTOM"],valeur="BOTTOM",form=nil},
	{texte=DF.locale["BOTTOMRIGHT"],valeur="BOTTOMRIGHT",form=nil},	
}

local optionsStype={
	{texte="BuffPlayer",valeur="Buff",form=nil},
	{texte="DebuffTarget",valeur="Debuff",form=nil},
	{texte="BuffTarget",valeur="BuffTarget",form=nil},
}

local optionsMediatype={
	{texte="Font",valeur="font",form=nil},
	{texte="Statusbar",valeur="statusbar",form=nil},
	{texte="Texture",valeur="background",form=nil},
	{texte="Sound",valeur="sound",form=nil},
}

local optionsOrientation={
	{texte="Horizontal",valeur="HORIZONTAL",form=nil},
	{texte="Vertical",valeur="VERTICAL",form=nil},
}

local optionsSavedconfig= {}

function DF:options_prepareSpellsList()
	
	-- renseigne les noms localisés
	local nb=getn(DF.spellsList)
	for i = 1,nb do

		if (DF.spellsList[i].ltype==1) then
			
			lenom,lerang = GetSpellInfo(DF.spellsList[i].id)

			if (lenom) then
				if lerang~="" then
					rangchaine=" ("..tostring(lerang)..")"
				else
					rangchaine=""
				end
				DF.spellsList[i].texte="(S) "..lenom..rangchaine
				
			else
				
				DF.spellsList[i].texte="(S) SpellID["..DF.spellsList[i].id.."]"
				
			end
			
		elseif (DF.spellsList[i].ltype>1) then

			lenom = GetItemInfo(DF.spellsList[i].id)
			if (lenom) then
				DF.spellsList[i].texte="(O) "..lenom
			else
				DF.spellsList[i].texte="(O) ItemID["..DF.spellsList[i].id.."]"	
			end
			
		end

	end	
	
	-- trier la liste
	local mini=0
	local valeur=""
	local save ={}
	
	for i = 1,nb do
		mini=i
		valeur=DF.spellsList[mini].texte
		for j = i,nb do
			if i~=j and DF.spellsList[j].texte<valeur then
				mini=j
				valeur=DF.spellsList[mini].texte
			end
		end
		
		save = DF.spellsList[i]
		DF.spellsList[i]=DF.spellsList[mini]
		DF.spellsList[mini]=save
		
	end
	
end

function DF:options_SavedconfigLists()
	local index=1
	optionsSavedconfig=table.wipe(optionsSavedconfig)
	for tkey,tvalue in pairs(DF_saved_configs) do
		optionsSavedconfig[index]={texte=DF_saved_configs[tkey].configname,valeur=DF_saved_configs[tkey].configname}
		index=index+1
	end	
	for tkey,tvalue in pairs(DF_pred_configs) do
		optionsSavedconfig[index]={texte=DF_pred_configs[tkey].configname,valeur=DF_pred_configs[tkey].configname}
		index=index+1
	end	
	
end

local optionsTextures={}
local optionsFonts={}
local optionsStatusbars={}
local optionsSounds={}

local falseEditBox = CreateFrame("EditBox", "falseEditBox", UIParent,"InputBoxTemplate")
falseEditBox:SetAlpha(0)
falseEditBox:EnableMouse(false)
falseEditBox:SetAutoFocus(false)
falseEditBox:SetScript("OnEditFocusGained", function(self)
  self:ClearFocus()
end)		

-- construit liste pour options
function DF:options_ShareMediaLists()

	local temp = DF.LSM:List("background")
	local fetch=nil
	local index=1
	
	optionsTextures[index]={texte="None",valeur="Interface\\AddOns\\DroodFocus\\datas\\empty.tga",form="background"}; index=index+1
	for tkey,tvalue in pairs(temp) do
		fetch=DF.LSM:Fetch("background", tvalue)
		optionsTextures[index]={texte=tvalue,valeur=fetch,form="background"}; index=index+1
	end

	temp = DF.LSM:List("font")
	fetch=nil
	index=1

	for tkey,tvalue in pairs(temp) do
		fetch=DF.LSM:Fetch("font", tvalue)
		optionsFonts[index]={texte=tvalue,valeur=fetch,form="font"}; index=index+1
	end

	temp = DF.LSM:List("statusbar")
	fetch=nil
	index=1
	
	for tkey,tvalue in pairs(temp) do
		fetch=DF.LSM:Fetch("statusbar", tvalue)
		optionsStatusbars[index]={texte=tvalue,valeur=fetch,form="statusbar"}; index=index+1
	end

	temp = DF.LSM:List("sound")
	fetch=nil
	index=1
	
	optionsSounds[index]={texte="None",valeur="",form="sound"}; index=index+1
	for tkey,tvalue in pairs(temp) do
		fetch=DF.LSM:Fetch("sound", tvalue)
		optionsSounds[index]={texte=tvalue,valeur=fetch,form="sound"}; index=index+1
	end
	
end

function DF:options_addID()
	if DF.selectedSpell then
		
		--DF:debugLine("DF.selectedSpell",DF.selectedSpell)
		
		local value =_G["DFSPELLOPT_ids"]:GetText()
		
		if value=="" then
			_G["DFSPELLOPT_ids"]:SetText(DF.selectedSpell)
		else
			_G["DFSPELLOPT_ids"]:SetText(value..";"..DF.selectedSpell)
		end
		_G["DFSPELLOPT_ids"]:SetFocus()

	end
	
end

-- creation des panneaux de configs
function DF:options_createpanels()
	
	DF:options_ShareMediaLists()
	DF:options_SavedconfigLists()
	DF:options_prepareSpellsList()
	
	local pt

	-- frame preview texture
	apercutexture = CreateFrame("FRAME","DF_PREVIEWTEXTURE",UIParent)
	apercutexture_texture= apercutexture:CreateTexture(nil,"BACKGROUND")
	
	apercutexture:SetMovable(false)
	apercutexture:EnableMouse(false)		
	apercutexture:SetWidth(128)
	apercutexture:SetHeight(128)
	apercutexture:ClearAllPoints()
	apercutexture:SetPoint("CENTER", UIParent, "CENTER", 0, 0)	
	apercutexture:SetFrameStrata("TOOLTIP")
	apercutexture:Hide()

	apercutexture_texture:ClearAllPoints()
	apercutexture_texture:SetAllPoints(apercutexture)

	apercutexture_texture:SetTexture(nil)

	apercutexture.texture = apercutexture_texture

	-- panneau pour l'interface de blizzard
	pt = DF:options_createPanel("DFOPTIONSmain",1,1,false,DF.locale["versionName"])
	pt.name = "DroodFocus"
	DF:options_createTitle(pt,DF.locale["versionName"])

	picture1 = CreateFrame("FRAME","picture1",pt);
	picture1:SetWidth(256);
	picture1:SetHeight(128);
	picture1:SetPoint("TOP", pt, "TOP",0, -10);
	picture1t = picture1:CreateTexture(nil,"BACKGROUND");
	picture1t:SetAllPoints(picture1); -- attache la texture a la frame
	picture1t:SetTexture("Interface\\AddOns\\DroodFocus\\datas\\picture");
	picture1t:SetBlendMode("BLEND");
	picture1.texture = picture1t;
	
	DF:options_createConfigButton(pt,"DFmainpanelbutton",DF.locale["DFmainpanel"],3,3,DF.options_show,"DFOPTIONSelement")
	InterfaceOptions_AddCategory(pt);

	-- panneaux spéciaux
	pt = DF:options_createPanel("DFOPTIONSelement",2,15,true,DF.locale["mainmain"])
	pt.name = "DroodFocus elements"

	picture2 = CreateFrame("FRAME","picture2",pt);
	picture2:SetWidth(256*0.75);
	picture2:SetHeight(128*0.75);
	picture2:SetPoint("TOPRIGHT", pt, "TOPRIGHT",-16, -80);
	picture2t = picture2:CreateTexture(nil,"BACKGROUND");
	picture2t:SetAllPoints(picture2); -- attache la texture a la frame
	picture2t:SetTexture("Interface\\AddOns\\DroodFocus\\datas\\picture");
	picture2t:SetBlendMode("BLEND");
	picture2.texture = picture2t;

	DF:options_createEditbox(pt,"confignamebox",DF_config,"configname",DF.locale["configname"],0,1,nil,false)
	DF:options_createButton(pt,"confignamesavebutton",DF.locale["save"],17,1,DF.config_Save,1)
	DF:options_createListbox(pt,"confignameload",DF,"configToLoad",DF.locale["loadlist"],0,2,DF.config_Load,optionsSavedconfig)
	DF:options_createSwapButton(pt,"dflock",DF,"lock",DF.locale["configmode"],DF.locale["enter"],DF.locale["leave"],0,3,DF.toogle_lock)
	DF:options_createConfigButton(pt,"mainvisibilitycheck",DF.locale["visibility"],17,5,DF.options_show,"visibility")
	DF:options_createText(pt,DF.locale["infosmode"],0,4)
	DF:options_createSubTitle(pt,DF.locale["parts"],0,5)
	DF:options_createConfigButton(pt,"mainooccheck",DF.locale["ooc"],0,6,DF.options_show,"ooc")
	DF:options_createConfigButton(pt,"mainalertcheck",DF.locale["alert"],17,6,DF.options_show,"alert")
	DF:options_createConfigButton(pt,"mainpowerbarcheck",DF.locale["powerbar"],0,7,DF.options_show,"powerbar")
	DF:options_createConfigButton(pt,"mainhealthbarcheck",DF.locale["healthbar"],17,7,DF.options_show,"healthbar")
	DF:options_createConfigButton(pt,"mainmanabarcheck",DF.locale["manabar"],0,8,DF.options_show,"manabar")
	DF:options_createConfigButton(pt,"maintargetbarcheck",DF.locale["targetbar"],17,8,DF.options_show,"targetbar")
	DF:options_createConfigButton(pt,"mainthreattbarcheck",DF.locale["threatbar"],0,9,DF.options_show,"threatbar")
	DF:options_createConfigButton(pt,"maincombobarcheck",DF.locale["combo"],17,9,DF.options_show,"combo")
	DF:options_createConfigButton(pt,"mainbloodcheck",DF.locale["blood"],0,10,DF.options_show,"blood")
	DF:options_createConfigButton(pt,"maingridcheck",DF.locale["grid"],17,10,DF.options_show,"grid")
	DF:options_createConfigButton(pt,"maininfoscheck",DF.locale["infos"],0,11,DF.options_show,"infos")
	DF:options_createConfigButton(pt,"mainspellscheck",DF.locale["spells"],17,11,DF.options_show,"spells")
	DF:options_createConfigButton(pt,"maintimerbarcheck",DF.locale["icons"],17,12,DF.options_show,"icons")
	DF:options_createConfigButton(pt,"maintimerbarcheck",DF.locale["timerbar"],0,12,DF.options_show,"timerbar")
	DF:options_createConfigButton(pt,"mainportraitcheck",DF.locale["portrait"],0,13,DF.options_show,"portrait")
	DF:options_createConfigButton(pt,"maincooldowncheck",DF.locale["cooldown"],17,13,DF.options_show,"cooldown")
	DF:options_createConfigButton(pt,"maingpscheck",DF.locale["gps"],0,14,DF.options_show,"gps")
	DF:options_createConfigButton(pt,"mainsoundcheck",DF.locale["sound"],17,14,DF.options_show,"sound")
	DF:options_createConfigButton(pt,"mainsharemediacheck",DF.locale["sharemedia"],17,15,DF.options_show,"sharemedia")
	--DF:options_createConfigButton(pt,"maintalentcheck",DF.locale["talent"],17,15,DF.options_show,"talent")
	DF:options_createConfigButton(pt,"maincastbarcheck",DF.locale["castbar"],0,15,DF.options_show,"castbar")
	DF:options_createCheckBox(pt,"mainminimapcheck",DF_config,"minimap",DF.locale["minimap"],0,0,DF_MinimapToggle)

	pt:ClearAllPoints()
	pt:SetPoint("RIGHT", UIParent, "RIGHT", -16, 0)
	
	pt = DF:options_createPanel("blood",2,1,true,DF.locale["blood"])
	pt.name = DF.locale["blood"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"bloodCB",DF_config.blood,"enable",DF.locale["blood"].." "..DF.locale["active"],0,0,nil,"blood")
	DF:options_createSlider(pt,"bloodslidersize",DF_config.blood,"size",0.20,2,0.10,DF.locale["scale"],0,1,DF.blood_reinit,"Scale")
	DF:options_createSlider(pt,"bloodsliderpers",DF_config.blood,"persistence",1,10,0.5,DF.locale["persistence"],17,1,DF.blood_reinit,"Persistence")

	pt = DF:options_createPanel("grid",2,1,true,DF.locale["grid"])
	pt.name = DF.locale["grid"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"gridCB",DF_config,"alignToGrid",DF.locale["aligngrid"],0,0,nil)
	DF:options_createSlider(pt,"gridslidersizex",DF_config,"gridSizeX",0.25,16,0.25,DF.locale["gridsizex"],0,1,nil)
	DF:options_createSlider(pt,"gridslidersizey",DF_config,"gridSizeY",0.25,16,0.25,DF.locale["gridsizey"],17,1,nil)

	pt = DF:options_createPanel("talent",2,5,true,DF.locale["talent"])
	pt.name = DF.locale["talent"]
	pt.parent = "DroodFocus"
	DF:options_createSubTitle(pt,DF.locale["talentinfos"],0,0)
	DF:options_createText(pt,DF.locale["talentinfos2"],0,1)
	DF:options_createSubTitle(pt,DF.locale["currenttalent"],0,2)
	local textet = pt:CreateFontString("dfcurrenttalenttext", "OVERLAY", "GameFontNormal")
	textet:SetPoint("TOPLEFT", pt, "TOPLEFT", 8, -32-(2*38)-16)
	local textec = pt:CreateFontString("dfcurrenttalentconfigtext", "OVERLAY", "GameFontNormal")
	textec:SetPoint("TOPLEFT", pt, "TOPLEFT", 8, -32-(2*38)-32)
	DF:options_createButton(pt,"talentbuttonset",DF.locale["set"],0,4,DF.talent_setSpeConfig,tostring(DF.playerTalent))
	DF:options_createButton(pt,"talentbuttonclear",DF.locale["clear"],8,4,DF.talent_clearSpeConfig,tostring(DF.playerTalent))
	DF:options_createText(pt,DF.locale["talentinfos3"],0,5)
	
	pt = DF:options_createPanel("sound",2,4,true,DF.locale["sound"])
	pt.name = DF.locale["sound"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"soundCB",DF_config.sound,"enable",DF.locale["active"],0,0,nil,"sound")
	DF:options_createListbox(pt,"soundfile0",DF_config.sound.soundfiles,1,DF.locale["sound"].." "..DF.locale["form0"],0,1,nil,optionsSounds,false,"Humanoïd")
	DF:options_createListbox(pt,"soundfile1",DF_config.sound.soundfiles,2,DF.locale["sound"].." "..DF.locale["form1"],0,2,nil,optionsSounds,false,"Stance")
	DF:options_createListbox(pt,"soundfile2",DF_config.sound.soundfiles,3,DF.locale["sound"].." "..DF.locale["form2"],17,2,nil,optionsSounds,false,"Stance")
	DF:options_createListbox(pt,"soundfile3",DF_config.sound.soundfiles,4,DF.locale["sound"].." "..DF.locale["form3"],0,3,nil,optionsSounds,false,"Stance")
	DF:options_createListbox(pt,"soundfile4",DF_config.sound.soundfiles,5,DF.locale["sound"].." "..DF.locale["form4"],17,3,nil,optionsSounds,false,"Stance")
	DF:options_createListbox(pt,"soundfile5",DF_config.sound.soundfiles,6,DF.locale["sound"].." "..DF.locale["form5"],0,4,nil,optionsSounds,false,"Stance")
	DF:options_createListbox(pt,"soundfile6",DF_config.sound.soundfiles,7,DF.locale["sound"].." "..DF.locale["form6"],17,4,nil,optionsSounds,false,"Stance")


	pt = DF:options_createPanel("sharemedia",2,6,true,DF.locale["sharemedia"])
	pt.name = DF.locale["sharemedia"]
	pt.parent = "DroodFocus"
	DF:options_createSubTitle(pt,DF.locale["sharemediainfos"],0,0)
	DF:options_createListbox(pt,"sharemediatype",options_sharemedia,"ftype",DF.locale["mtype"],0,1,nil,optionsMediatype,false,"mtype")
	DF:options_createEditbox(pt,"sharemedianame",options_sharemedia,"fname",DF.locale["mname"],17,1,nil,false,"mname")
	DF:options_createEditbox(pt,"sharemediapath",options_sharemedia,"fpath",DF.locale["mpath"],0,2,nil,true,"mpath")
	DF:options_createButton(pt,"sharemediabutton1",DF.locale["test"],9,6,DF.options_testMedia,"")
	DF:options_createButton(pt,"sharemediabutton2",DF.locale["add"],17,6,DF.options_testMedia,"add")
	
	shareMediaBox = CreateFrame("FRAME", "DFshareMediaBox", pt, BackdropTemplateMixin and "BackdropTemplate" or nil)
	shareMediaBox:SetWidth(380)
 	shareMediaBox:SetHeight(128)
	shareMediaBox:SetPoint("TOPLEFT", pt, "TOPLEFT", 10, -140)
	shareMediaBox:SetBackdrop({bgFile = nil, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	shareMediaBox:SetBackdropColor(0,0,0,1);	

	shareMediaFrame = CreateFrame("FRAME","DF_shareMediaframe",pt)
	shareMediaTexture=shareMediaFrame:CreateTexture("DF_shareMediaTexture","BACKGROUND")

	-- paramétres cadre texture
	shareMediaFrame:SetMovable(false)
	shareMediaFrame:EnableMouse(false)		
	shareMediaFrame:SetWidth(370)
	shareMediaFrame:SetHeight(118)
	shareMediaFrame:SetPoint("CENTER", shareMediaBox, "CENTER", 0, 0)
	
	-- paramétres texture
	shareMediaTexture:SetTexCoord(0, 1, 0, 1)
	shareMediaTexture:SetWidth(370)
	shareMediaTexture:SetHeight(118)
	shareMediaTexture:ClearAllPoints()
	shareMediaTexture:SetAllPoints(shareMediaFrame)
	shareMediaTexture:SetTexture(nil)
	
	shareMediaFrame.texture = shareMediaTexture
		
	shareMediaFont = shareMediaFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	shareMediaFont:SetPoint("CENTER", shareMediaFrame, "CENTER", 0, 0)
	shareMediaFont:SetJustifyH("CENTER")
	shareMediaFont:SetText("MEDIA PREVIEW")
	police = shareMediaFont:GetFont();shareMediaFont:SetFont(police,14)

	shareMediaBox:SetScript("OnShow", function(self)
		shareMediaTexture:SetTexture(nil)
		shareMediaFont:SetFont("Interface\\AddOns\\DroodFocus\\datas\\font.ttf",14)
	end)	

	pt = DF:options_createPanel("infos",2,5,true,DF.locale["infos"])
	pt.name = DF.locale["infos"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"infoscheck",DF_config.infos,"enable",DF.locale["active"],0,0,DF.infos_reinit,"infos")
	DF:options_createListbox(pt,"infosfont1",DF_config.infos,"fontPath",DF.locale["fontPath"],0,1,DF.infos_reinit,optionsFonts)
	DF:options_createSlider(pt,"infosslidersize",DF_config.infos,"fontSize",6,28,1,DF.locale["fontSize"],17,1,DF.infos_reinit)
	DF:options_createEditbox(pt,"infostext",DF_config.infos,"infolines",DF.locale["infostext"],0,2,DF.infos_reinit,true,"Infos format")
	DF:options_createSlider(pt,"infossliderlevel",DF_config.infos,"level",1,20,1,DF.locale["level"],0,3,DF.infos_reinit,"Level","Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,4)
	DF:options_createColorBox(pt,"infostextcolor",DF_config.infos,"textColor",DF.locale["text"].." "..DF.locale["color"],0,5,DF.infos_reinit)
	DF:options_createColorBox(pt,"infosbackcolor",DF_config.infos,"backColor",DF.locale["background"].." "..DF.locale["color"],17,5,DF.infos_reinit)

	pt = DF:options_createPanel("spells",2,18,true,DF.locale["spells"])
	pt.name = DF.locale["spells"]
	pt.parent = "DroodFocus"
	DF:options_createBox(pt,"DFspellsbox",8,-28,390,(17*nbLines)+10)
	
	_G["DFspellsbox"]:EnableMouse(true)
	_G["DFspellsbox"]:EnableMouseWheel(true)
	_G["DFspellsbox"]:SetScript("OnMouseWheel",function(self,delta)
		local offset=_G["DFdebufflistContenerSlider"]:GetValue()+(delta*-1)
		_G["DFdebufflistContenerSlider"]:SetValue(offset)
	end)
		
	DF:options_DebuffList_create(pt)
	DF:options_DebuffList_populate()
	
	DF:options_createButton(pt,"DFSPELLOPT_up",DF.locale["up"],0,4,DF.options_DebuffList_up,nil)
	DF:options_createButton(pt,"DFSPELLOPT_down",DF.locale["down"],7,4,DF.options_DebuffList_down,nil)
	DF:options_createButton(pt,"DFSPELLOPT_new",DF.locale["new"],14,4,DF.options_DebuffList_new,nil)
	DF:options_createButton(pt,"DFSPELLOPT_kill",DF.locale["kill"],21,4,DF.options_DebuffList_kill,nil)

	_G["DFSPELLOPT_up"]:Disable()
	_G["DFSPELLOPT_down"]:Disable()
	_G["DFSPELLOPT_kill"]:Disable()
	DF:options_createEditbox(pt,"DFSPELLOPT_ids",nil,"spellIDs",DF.locale["ids"],0,5,DF.options_debuffList_apply,false,"ID's list")
	DF:options_createEditbox(pt,"DFSPELLOPT_usertext",nil,"abiUserText",DF.locale["usertext"],17,8,DF.options_debuffList_apply,false,"usertext")
	DF:options_createListbox(pt,"DFSPELLOPT_spellslist",nil,"selectedSpell",DF.locale["spellslist"],17,5,DF.options_addID,DF.spellsList,false,"spellslist")
	DF:options_createEditbox(pt,"DFSPELLOPT_positionx",nil,"positionx",DF.locale["positionx"],0,6,DF.options_debuffList_apply,false,"iposition")
	DF:options_createEditbox(pt,"DFSPELLOPT_positiony",nil,"positiony",DF.locale["positiony"],17,6,DF.options_debuffList_apply,false,"iposition")
	DF:options_createEditbox(pt,"DFSPELLOPT_width",nil,"width",DF.locale["width"],0,7,DF.options_debuffList_apply)
	DF:options_createEditbox(pt,"DFSPELLOPT_height",nil,"height",DF.locale["height"],17,7,DF.options_debuffList_apply)
	DF:options_createListbox(pt,"DFSPELLOPT_sType",nil,"sType",DF.locale["sType"],0,8,DF.options_debuffList_apply,optionsStype,false,"Spell type")
--	DF:options_createCheckBox(pt,"DFSPELLOPT_getUptime",nil,"getUptime",DF.locale["getUptime"],17,9,DF.options_debuffList_apply,"Uptime")
	DF:options_createCheckBox(pt,"DFSPELLOPT_showcd",nil,"showcd",DF.locale["showcd"],0,13,DF.options_debuffList_apply,"showcd")
	DF:options_createCheckBox(pt,"DFSPELLOPT_strong",nil,"strongcheck",DF.locale["strongcheck"],17,9,DF.options_debuffList_apply,"strongcheck")
	DF:options_createCheckBox(pt,"DFSPELLOPT_perso",nil,"perso",DF.locale["isPerso"],0,9,DF.options_debuffList_apply,"Scan spell")
	DF:options_createCheckBox(pt,"DFSPELLOPT_combo",nil,"combo",DF.locale["toCombo"],17,10,DF.options_debuffList_apply,"Stack > Combo")
	DF:options_createCheckBox(pt,"DFSPELLOPT_icon",nil,"icon",DF.locale["hasIcon"],0,10,DF.options_debuffList_apply)
	DF:options_createSlider(pt,"DFSPELLOPT_icd",nil,"abiInternalCD",0,300,1,DF.locale["internalcd"],0,11,DF.options_debuffList_apply,"internalcd")
	DF:options_createListbox(pt,"DFSPELLOPT_timerbar",nil,"timerbar",DF.locale["hastimerbar"],0,12,DF.options_debuffList_apply,optionsTimerbar)
	DF:options_createColorBox(pt,"DFSPELLOPT_color",nil,"color",DF.locale["timerbar"].." "..DF.locale["color"],17,12,DF.options_debuffList_apply)
	DF:options_createListbox(pt,"DFSPELLOPT_sound",nil,"abiSound",DF.locale["sound"],17,11,DF.options_debuffList_apply,optionsSounds,false,"abiSound")
	DF:options_createText(pt,DF.locale["infostance"],0,14)
	DF:options_createCheckBox(pt,"DFSPELLOPT_always",nil,"alwaysVisible",DF.locale["always"],17,14,DF.options_debuffList_apply,"always")
	DF:options_createCheckBox(pt,"DFSPELLOPT_form0",nil,1,DF.locale["form0"],0,15,DF.options_debuffList_apply,"Humanoïd")
	DF:options_createCheckBox(pt,"DFSPELLOPT_form1",nil,2,DF.locale["form1"],0,16,DF.options_debuffList_apply,"Stance")
	DF:options_createCheckBox(pt,"DFSPELLOPT_form2",nil,3,DF.locale["form2"],17,16,DF.options_debuffList_apply,"Stance")
	DF:options_createCheckBox(pt,"DFSPELLOPT_form3",nil,4,DF.locale["form3"],0,17,DF.options_debuffList_apply,"Stance")
	DF:options_createCheckBox(pt,"DFSPELLOPT_form4",nil,5,DF.locale["form4"],17,17,DF.options_debuffList_apply,"Stance")
	DF:options_createCheckBox(pt,"DFSPELLOPT_form5",nil,6,DF.locale["form5"],0,18,DF.options_debuffList_apply,"Stance")
	DF:options_createCheckBox(pt,"DFSPELLOPT_form6",nil,7,DF.locale["form6"],17,18,DF.options_debuffList_apply,"Stance")

	pt = DF:options_createPanel("visibility",2,6,true,DF.locale["visibility"])
	pt.name = DF.locale["visibility"]
	pt.parent = "DroodFocus"			
	DF:options_createText(pt,DF.locale["infovisibility"],0,0)
	DF:options_createCheckBox(pt,"dfvisibilityalwaysui",DF_config,"uiAlwaysShow",DF.locale["always"],0,1,DF.toggle_toggle,"always")
	DF:options_createCheckBox(pt,"dfcombat",DF_config,"inCombat",DF.locale["incombat"],0,2,DF.toggle_toggle)	
	DF:options_createCheckBox(pt,"dfvisibility0",DF_config.activeForms,1,DF.locale["form0"],0,3,DF.toggle_toggle,"Humanoïd")
	DF:options_createCheckBox(pt,"dfvisibility1",DF_config.activeForms,2,DF.locale["form1"],0,4,DF.toggle_toggle,"Stance")
	DF:options_createCheckBox(pt,"dfvisibility2",DF_config.activeForms,3,DF.locale["form2"],17,4,DF.toggle_toggle,"Stance")
	DF:options_createCheckBox(pt,"dfvisibility3",DF_config.activeForms,4,DF.locale["form3"],0,5,DF.toggle_toggle,"Stance")
	DF:options_createCheckBox(pt,"dfvisibility4",DF_config.activeForms,5,DF.locale["form4"],17,5,DF.toggle_toggle,"Stance")
	DF:options_createCheckBox(pt,"dfvisibility5",DF_config.activeForms,6,DF.locale["form5"],0,6,DF.toggle_toggle,"Stance")
	DF:options_createCheckBox(pt,"dfvisibility6",DF_config.activeForms,7,DF.locale["form6"],17,6,DF.toggle_toggle,"Stance")

	pt = DF:options_createPanel("dfancre1",2,4,true,DF.locale["anchor"].." "..DF_config.anchor1.info)
	pt.name = DF.locale["anchor1"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"anchor1check",DF_config.anchor1,"visible",DF.locale["visible"],0,0,DF.anchor_reinit)
	DF:options_createConfigButton(pt,"anchoruicheck",DF.locale["DFOPTIONSelement"],17,0,DF.options_show,"DFOPTIONSelement")
	DF:options_createEditbox(pt,"anchor1left",DF_config.anchor1,"positionx",DF.locale["positionx"],0,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor1top",DF_config.anchor1,"positiony",DF.locale["positiony"],17,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor1w",DF_config.anchor1,"width",DF.locale["width"],0,2,DF.anchor_reinit)
	DF:options_createEditbox(pt,"anchor1h",DF_config.anchor1,"height",DF.locale["height"],17,2,DF.anchor_reinit)
	DF:options_createListbox(pt,"anchor1texture",DF_config.anchor1,"texture",DF.locale["texture"],0,3,DF.anchor_reinit,optionsTextures)
	DF:options_createListbox(pt,"anchor1mode",DF_config.anchor1,"mode",DF.locale["mode"],17,3,DF.anchor_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"anchor1sliderlevel",DF_config.anchor1,"level",1,20,1,DF.locale["level"],0,4,DF.anchor_reinit,"Level")
	DF:options_createSlider(pt,"anchor1sliderscale",DF_config.anchor1,"scale",0.05,2,0.05,DF.locale["scale"],17,4,DF.anchor_reinit,"Scale")

	pt = DF:options_createPanel("dfancre2",2,4,true,DF.locale["anchor"].." "..DF_config.anchor2.info)
	pt.name = DF.locale["anchor2"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"anchor2check",DF_config.anchor2,"visible",DF.locale["visible"],0,0,DF.anchor_reinit)
	DF:options_createConfigButton(pt,"anchoriconcheck",DF.locale["icons"],17,0,DF.options_show,"icons")
	DF:options_createEditbox(pt,"anchor2left",DF_config.anchor2,"positionx",DF.locale["positionx"],0,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor2top",DF_config.anchor2,"positiony",DF.locale["positiony"],17,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor2w",DF_config.anchor2,"width",DF.locale["width"],0,2,DF.anchor_reinit)
	DF:options_createEditbox(pt,"anchor2h",DF_config.anchor2,"height",DF.locale["height"],17,2,DF.anchor_reinit)
	DF:options_createListbox(pt,"anchor2texture",DF_config.anchor2,"texture",DF.locale["texture"],0,3,DF.anchor_reinit,optionsTextures)
	DF:options_createListbox(pt,"anchor2mode",DF_config.anchor2,"mode",DF.locale["mode"],17,3,DF.anchor_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"anchor2sliderlevel",DF_config.anchor2,"level",1,20,1,DF.locale["level"],0,4,DF.anchor_reinit,"Level")
	DF:options_createSlider(pt,"anchor2sliderscale",DF_config.anchor2,"scale",0.05,2,0.05,DF.locale["scale"],17,4,DF.anchor_reinit,"Scale")

	pt = DF:options_createPanel("dfancre3",2,4,true,DF.locale["anchor"].." "..DF_config.anchor3.info)
	pt.name = DF.locale["anchor3"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"anchor3check",DF_config.anchor3,"visible",DF.locale["visible"],0,0,DF.anchor_reinit)
	DF:options_createConfigButton(pt,"anchortb1check",DF.locale["timerbar"],17,0,DF.options_show,"timerbar")
	DF:options_createEditbox(pt,"anchor3left",DF_config.anchor3,"positionx",DF.locale["positionx"],0,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor3top",DF_config.anchor3,"positiony",DF.locale["positiony"],17,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor3w",DF_config.anchor3,"width",DF.locale["width"],0,2,DF.anchor_reinit)
	DF:options_createEditbox(pt,"anchor3h",DF_config.anchor3,"height",DF.locale["height"],17,2,DF.anchor_reinit)
	DF:options_createListbox(pt,"anchor3texture",DF_config.anchor3,"texture",DF.locale["texture"],0,3,DF.anchor_reinit,optionsTextures)
	DF:options_createListbox(pt,"anchor3mode",DF_config.anchor3,"mode",DF.locale["mode"],17,3,DF.anchor_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"anchor3sliderlevel",DF_config.anchor3,"level",1,20,1,DF.locale["level"],0,4,DF.anchor_reinit,"Level")
	DF:options_createSlider(pt,"anchor3sliderscale",DF_config.anchor3,"scale",0.05,2,0.05,DF.locale["scale"],17,4,DF.anchor_reinit,"Scale")	

	pt = DF:options_createPanel("dfancre4",2,4,true,DF.locale["anchor"].." "..DF_config.anchor4.info)
	pt.name = DF.locale["anchor4"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"anchor4check",DF_config.anchor4,"visible",DF.locale["visible"],0,0,DF.anchor_reinit)
	DF:options_createConfigButton(pt,"anchortb2check",DF.locale["timerbar"],17,0,DF.options_show,"timerbar")
	DF:options_createEditbox(pt,"anchor4left",DF_config.anchor4,"positionx",DF.locale["positionx"],0,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor4top",DF_config.anchor4,"positiony",DF.locale["positiony"],17,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor4w",DF_config.anchor4,"width",DF.locale["width"],0,2,DF.anchor_reinit)
	DF:options_createEditbox(pt,"anchor4h",DF_config.anchor4,"height",DF.locale["height"],17,2,DF.anchor_reinit)
	DF:options_createListbox(pt,"anchor4texture",DF_config.anchor4,"texture",DF.locale["texture"],0,3,DF.anchor_reinit,optionsTextures)
	DF:options_createListbox(pt,"ancho4rmode",DF_config.anchor4,"mode",DF.locale["mode"],17,3,DF.anchor_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"anchor4sliderlevel",DF_config.anchor4,"level",1,20,1,DF.locale["level"],0,4,DF.anchor_reinit,"Level")
	DF:options_createSlider(pt,"anchor4sliderscale",DF_config.anchor4,"scale",0.05,2,0.05,DF.locale["scale"],17,4,DF.anchor_reinit,"Scale")

	pt = DF:options_createPanel("dfancre5",2,4,true,DF.locale["anchor"].." "..DF_config.anchor5.info)
	pt.name = DF.locale["anchor5"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"anchor5check",DF_config.anchor5,"visible",DF.locale["visible"],0,0,DF.anchor_reinit)
	DF:options_createConfigButton(pt,"anchorinfoscheck",DF.locale["infos"],17,0,DF.options_show,"infos")
	DF:options_createEditbox(pt,"anchor5left",DF_config.anchor5,"positionx",DF.locale["positionx"],0,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor5top",DF_config.anchor5,"positiony",DF.locale["positiony"],17,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor5w",DF_config.anchor5,"width",DF.locale["width"],0,2,DF.anchor_reinit)
	DF:options_createEditbox(pt,"anchor5h",DF_config.anchor5,"height",DF.locale["height"],17,2,DF.anchor_reinit)
	DF:options_createListbox(pt,"anchor5texture",DF_config.anchor5,"texture",DF.locale["texture"],0,3,DF.anchor_reinit,optionsTextures)
	DF:options_createListbox(pt,"anchor5mode",DF_config.anchor5,"mode",DF.locale["mode"],17,3,DF.anchor_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"anchor5sliderlevel",DF_config.anchor5,"level",1,20,1,DF.locale["level"],0,4,DF.anchor_reinit,"Level")
	DF:options_createSlider(pt,"anchor5sliderscale",DF_config.anchor5,"scale",0.05,2,0.05,DF.locale["scale"],17,4,DF.anchor_reinit,"Scale")

	pt = DF:options_createPanel("dfancre6",2,4,true,DF.locale["anchor"].." "..DF_config.anchor6.info)
	pt.name = DF.locale["anchor6"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"anchor6check",DF_config.anchor6,"visible",DF.locale["visible"],0,0,DF.anchor_reinit)
	DF:options_createConfigButton(pt,"anchorcdcheck",DF.locale["cooldown"],17,0,DF.options_show,"cooldown")
	DF:options_createEditbox(pt,"anchor6left",DF_config.anchor6,"positionx",DF.locale["positionx"],0,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor6top",DF_config.anchor6,"positiony",DF.locale["positiony"],17,1,DF.anchor_reinit,false,"position")
	DF:options_createEditbox(pt,"anchor6w",DF_config.anchor6,"width",DF.locale["width"],0,2,DF.anchor_reinit)
	DF:options_createEditbox(pt,"anchor6h",DF_config.anchor6,"height",DF.locale["height"],17,2,DF.anchor_reinit)
	DF:options_createListbox(pt,"anchor6texture",DF_config.anchor6,"texture",DF.locale["texture"],0,3,DF.anchor_reinit,optionsTextures)
	DF:options_createListbox(pt,"anchor6mode",DF_config.anchor6,"mode",DF.locale["mode"],17,3,DF.anchor_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"anchor6sliderlevel",DF_config.anchor6,"level",1,20,1,DF.locale["level"],0,4,DF.anchor_reinit,"Level")
	DF:options_createSlider(pt,"anchor6sliderscale",DF_config.anchor6,"scale",0.05,2,0.05,DF.locale["scale"],17,4,DF.anchor_reinit,"Scale")


	pt = DF:options_createPanel("gps",2,8,true,DF.locale["gps"])
	pt.name = DF.locale["gps"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"gpscheck",DF_config.gps,"enable",DF.locale["active"],0,0,DF.gps_reinit,"gps")
	DF:options_createListbox(pt,"gpstarget1",DF_config.gps.gpsTarget,1,DF.locale["target"].." 1",0,1,DF.gps_reinit,optionsTarget,false,"target")
	DF:options_createListbox(pt,"gpstarget2",DF_config.gps.gpsTarget,2,DF.locale["target"].." 2",17,1,DF.gps_reinit,optionsTarget,false,"target")
	DF:options_createEditbox(pt,"gpsw",DF_config.gps,"width",DF.locale["width"],0,2,DF.gps_reinit)
	DF:options_createEditbox(pt,"gpsh",DF_config.gps,"height",DF.locale["height"],17,2,DF.gps_reinit)
	DF:options_createListbox(pt,"gpsmode",DF_config.gps,"mode",DF.locale["mode"],0,3,DF.gps_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"gpsslideralpha",DF_config.gps,"alpha",0,1,0.10,DF.locale["activeAlpha"],17,3,DF.gps_reinit,"alpha")
	DF:options_createListbox(pt,"gpsfont1",DF_config.gps,"fontPath",DF.locale["fontPath"],0,4,DF.gps_reinit,optionsFonts)
	DF:options_createSlider(pt,"gpsslidersize",DF_config.gps,"fontSize",6,28,1,DF.locale["fontSize"],17,4,DF.gps_reinit)
	DF:options_createSlider(pt,"gpsslideroffset1x",DF_config.gps,"offsetx",-128,128,1,DF.locale["toffsetx"],0,5,DF.gps_reinit,"Text offset")
	DF:options_createSlider(pt,"gpsslideroffset1y",DF_config.gps,"offsety",-128,128,1,DF.locale["toffsety"],17,5,DF.gps_reinit,"Text offset")
	DF:options_createSlider(pt,"gpssliderlevel",DF_config.gps,"level",1,20,1,DF.locale["level"],0,6,DF.gps_reinit,"Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,7)
	DF:options_createColorBox(pt,"gpstextcolor",DF_config.gps,"textColor",DF.locale["text"].." "..DF.locale["color"],0,8,DF.gps_reinit)
	
	pt = DF:options_createPanel("ooc",2,7,true,DF.locale["ooc"])
	pt.name = DF.locale["ooc"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"ooccheck",DF_config.ooc,"enable",DF.locale["active"],0,0,DF.ooc_reinit,"ooc")
	DF:options_createEditbox(pt,"oocspell",DF_config.ooc,"spell",DF.locale["spellid"],0,1,DF.ooc_reinit,true,"Spell ID")
	DF:options_createEditbox(pt,"oocleft",DF_config.ooc,"positionx",DF.locale["positionx"],0,2,DF.ooc_reinit,false,"position")
	DF:options_createEditbox(pt,"ooctop",DF_config.ooc,"positiony",DF.locale["positiony"],17,2,DF.ooc_reinit,false,"position")
	DF:options_createEditbox(pt,"oocw",DF_config.ooc,"width",DF.locale["width"],0,3,DF.ooc_reinit)
	DF:options_createEditbox(pt,"ooch",DF_config.ooc,"height",DF.locale["height"],17,3,DF.ooc_reinit)
	DF:options_createListbox(pt,"ooctextureOff",DF_config.ooc,"textureOff",DF.locale["textureOff"],0,4,DF.ooc_reinit,optionsTextures)
	DF:options_createListbox(pt,"ooctextureOn",DF_config.ooc,"textureOn",DF.locale["textureOn"],17,4,DF.ooc_reinit,optionsTextures)
	DF:options_createListbox(pt,"oocmode",DF_config.ooc,"mode",DF.locale["mode"],0,5,DF.ooc_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"oocslidermin",DF_config.ooc,"scaleMin",0.1,2,0.10,DF.locale["scalemin"],17,5,DF.ooc_reinit,"Scale")
	DF:options_createSlider(pt,"oocslidermax",DF_config.ooc,"scaleMax",0,2,0.10,DF.locale["scalemax"],17,6,DF.ooc_reinit,"Scale")
	DF:options_createSlider(pt,"oocsliderlevel",DF_config.ooc,"level",1,20,1,DF.locale["level"],0,6,DF.ooc_reinit,"Level")
	DF:options_createSlider(pt,"oocspeed",DF_config.ooc,"speed",0.01,0.75,0.01,DF.locale["ampspeed"],17,7,DF.ooc_reinit)

	pt = DF:options_createPanel("alert",2,6,true,DF.locale["alert"])
	pt.name = DF.locale["alert"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"alertcheck",DF_config.alert,"enable",DF.locale["active"],0,0,DF.alert_reinit,"alert")
	DF:options_createEditbox(pt,"alertleft",DF_config.alert,"positionx",DF.locale["positionx"],0,1,DF.alert_reinit,false,"position")
	DF:options_createEditbox(pt,"alerttop",DF_config.alert,"positiony",DF.locale["positiony"],17,1,DF.alert_reinit,false,"position")
	DF:options_createEditbox(pt,"alertw",DF_config.alert,"width",DF.locale["width"],0,2,DF.alert_reinit)
	DF:options_createEditbox(pt,"alerth",DF_config.alert,"height",DF.locale["height"],17,2,DF.alert_reinit)
	DF:options_createListbox(pt,"alerttexture1",DF_config.alert,"texture1",DF.locale["texture1"],0,3,DF.alert_reinit,optionsTextures)
	DF:options_createListbox(pt,"alerttexture2",DF_config.alert,"texture2",DF.locale["texture2"],0,4,DF.alert_reinit,optionsTextures)
	DF:options_createListbox(pt,"alerttexture3",DF_config.alert,"texture3",DF.locale["texture3"],0,5,DF.alert_reinit,optionsTextures)
	DF:options_createListbox(pt,"alertmode",DF_config.alert,"mode",DF.locale["mode"],17,3,DF.alert_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"alertsliderlevel",DF_config.alert,"level",1,20,1,DF.locale["level"],0,6,DF.alert_reinit,"Level")
	DF:options_createSlider(pt,"alertsliderpers",DF_config.alert,"persistence",1,10,0.5,DF.locale["persistence"],17,4,DF.alert_reinit,"Persistence")
	DF:options_createCheckBox(pt,"alertcheckdebuff",DF_config.alert,"showDebuff",DF.locale["AlertShowDebuff"],17,5,nil)

	pt = DF:options_createPanel("portrait",2,7,true,DF.locale["portrait"])
	pt.name = DF.locale["portrait"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"portraitcheck",DF_config.portrait,"enable",DF.locale["active"],0,0,DF.portrait_reinit,"portrait")
	DF:options_createEditbox(pt,"portraitleft",DF_config.portrait,"positionx",DF.locale["positionx"],0,1,DF.portrait_reinit,false,"position")
	DF:options_createEditbox(pt,"portraittop",DF_config.portrait,"positiony",DF.locale["positiony"],17,1,DF.portrait_reinit,false,"position")
	DF:options_createEditbox(pt,"portraitw",DF_config.portrait,"width",DF.locale["width"],0,2,DF.portrait_reinit)
	DF:options_createEditbox(pt,"portraith",DF_config.portrait,"height",DF.locale["height"],17,2,DF.portrait_reinit)
	DF:options_createListbox(pt,"portraittexture0",DF_config.portrait.textures,1,DF.locale["texture"].." "..DF.locale["form0"],0,3,DF.portrait_reinit,optionsTextures,false,"Humanoïd")
	DF:options_createListbox(pt,"portraittexture1",DF_config.portrait.textures,2,DF.locale["texture"].." "..DF.locale["form1"],0,4,DF.portrait_reinit,optionsTextures,false,"Stance")
	DF:options_createListbox(pt,"portraittexture2",DF_config.portrait.textures,3,DF.locale["texture"].." "..DF.locale["form2"],17,4,DF.portrait_reinit,optionsTextures,false,"Stance")
	DF:options_createListbox(pt,"portraittexture3",DF_config.portrait.textures,4,DF.locale["texture"].." "..DF.locale["form3"],0,5,DF.portrait_reinit,optionsTextures,false,"Stance")
	DF:options_createListbox(pt,"portraittexture4",DF_config.portrait.textures,5,DF.locale["texture"].." "..DF.locale["form4"],17,5,DF.portrait_reinit,optionsTextures,false,"Stance")
	DF:options_createListbox(pt,"portraittexture5",DF_config.portrait.textures,6,DF.locale["texture"].." "..DF.locale["form5"],0,6,DF.portrait_reinit,optionsTextures,false,"Stance")
	DF:options_createListbox(pt,"portraittexture6",DF_config.portrait.textures,7,DF.locale["texture"].." "..DF.locale["form6"],17,6,DF.portrait_reinit,optionsTextures,false,"Stance")
	DF:options_createListbox(pt,"portraitmode",DF_config.portrait,"mode",DF.locale["mode"],0,7,DF.portrait_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"portraitsliderlevel",DF_config.portrait,"level",1,20,1,DF.locale["level"],17,7,DF.portrait_reinit,"Level")


	pt = DF:options_createPanel("powerbar",3,14,true,DF.locale["powerbar"])
	pt.name = DF.locale["powerbar"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"powerbarcheck",DF_config.powerbar,"enable",DF.locale["active"],0,0,DF.powerbar_reinit)
	DF:options_createCheckBox(pt,"powerbararrowcheck",DF_config.powerbar,"enableArrows",DF.locale["arrows"].." "..DF.locale["active"],17,0,DF.powerbar_reinit,"Arrows")
	DF:options_createEditbox(pt,"powerbarleft",DF_config.powerbar,"positionx",DF.locale["positionx"],0,1,DF.powerbar_reinit,false,"position")
	DF:options_createEditbox(pt,"powerbartop",DF_config.powerbar,"positiony",DF.locale["positiony"],17,1,DF.powerbar_reinit,false,"position")
	DF:options_createEditbox(pt,"powerbarw",DF_config.powerbar,"width",DF.locale["width"],0,2,DF.powerbar_reinit)
	DF:options_createEditbox(pt,"powerbarh",DF_config.powerbar,"height",DF.locale["height"],17,2,DF.powerbar_reinit)
	DF:options_createListbox(pt,"powerbartexture1",DF_config.powerbar,"texturePath",DF.locale["texturePath"],0,3,DF.powerbar_reinit,optionsStatusbars)
	DF:options_createListbox(pt,"powerbarorient",DF_config.powerbar,"orientation",DF.locale["orientation"],17,3,DF.powerbar_reinit,optionsOrientation)
	DF:options_createCheckBox(pt,"powerbarshowspark",DF_config.powerbar,"showSpark",DF.locale["showSpark"],0,4,DF.powerbar_reinit,"spark")
	DF:options_createSlider(pt,"powerbarscursorspeed",DF_config,"cursorspeed",1,100,1,DF.locale["cursorspeed"],17,4,nil,"Cursor speed")
	DF:options_createSlider(pt,"powerbarinterval",DF_config.powerbar,"interval",1,100,1,DF.locale["interval"],17,10,nil,"interval")
	DF:options_createCheckBox(pt,"powerbarshowt",DF_config.powerbar,"showText",DF.locale["showText"],0,5,DF.powerbar_reinit)
	DF:options_createListbox(pt,"powerbarfont1",DF_config.powerbar,"fontPath",DF.locale["fontPath"],0,6,DF.powerbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"powerbarslidersize",DF_config.powerbar,"fontSize",6,28,1,DF.locale["fontSize"],17,6,DF.powerbar_reinit)
	DF:options_createListbox(pt,"powerbartextalign",DF_config.powerbar,"textAlign",DF.locale["text"].." "..DF.locale["align"],0,7,DF.powerbar_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"powerbarslideralignx",DF_config.powerbar,"textx",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsetx"],17,7,DF.powerbar_reinit,"Text offset")
	DF:options_createSlider(pt,"powerbarslideraligny",DF_config.powerbar,"texty",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsety"],17,8,DF.powerbar_reinit,"Text offset")
	DF:options_createCheckBox(pt,"powerbarborder",DF_config.powerbar,"border",DF.locale["border"].." "..DF.locale["active"],0,9,DF.powerbar_reinit)
	DF:options_createSlider(pt,"powerbarbordersize",DF_config.powerbar,"borderSize",0,8,1,DF.locale["border"].." "..DF.locale["size"],17,9,DF.powerbar_reinit)
	DF:options_createSlider(pt,"powerbarsliderlevel",DF_config.powerbar,"level",1,20,1,DF.locale["level"],0,10,DF.powerbar_reinit,"Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,11)
	DF:options_createColorBox(pt,"powerbardefcolor",DF_config.powerbar,"colorDef",DF.locale["default"].." "..DF.locale["color"],0,12,DF.powerbar_reinit)
	DF:options_createColorBox(pt,"powerbarmanacolor",DF_config.powerbar,"colorMana",DF.locale["mana"].." "..DF.locale["color"],17,12,DF.powerbar_reinit)
	DF:options_createColorBox(pt,"powerbarnrjcolor",DF_config.powerbar,"colorNrj",DF.locale["nrj"].." "..DF.locale["color"],0,13,DF.powerbar_reinit)
	DF:options_createColorBox(pt,"powerbarragecolor",DF_config.powerbar,"colorRage",DF.locale["rage"].." "..DF.locale["color"],17,13,DF.powerbar_reinit)
	DF:options_createColorBox(pt,"powerbarbordercolor",DF_config.powerbar,"borderColor",DF.locale["border"].." "..DF.locale["color"],0,14,DF.powerbar_reinit)
	DF:options_createColorBox(pt,"powerbartextcolor",DF_config.powerbar,"textColor",DF.locale["text"].." "..DF.locale["color"],17,14,DF.powerbar_reinit)
	DF:options_createEditbox(pt,"powerbartextformat",DF_config.powerbar,"sformat",DF.locale["sformat"],17,5,DF.powerbar_reinit,false,"sformat")
	DF:options_createText(pt,DF.locale["infostance"],34,0)
	DF:options_createCheckBox(pt,"powerbar_form0",DF_config.powerbar.form,1,DF.locale["form0"],34,1,DF.powerbar_reinit,"Humanoïd")
	DF:options_createCheckBox(pt,"powerbar_form1",DF_config.powerbar.form,2,DF.locale["form1"],34,2,DF.powerbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"powerbar_form2",DF_config.powerbar.form,3,DF.locale["form2"],34,3,DF.powerbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"powerbar_form3",DF_config.powerbar.form,4,DF.locale["form3"],34,4,DF.powerbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"powerbar_form4",DF_config.powerbar.form,5,DF.locale["form4"],34,5,DF.powerbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"powerbar_form5",DF_config.powerbar.form,6,DF.locale["form5"],34,6,DF.powerbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"powerbar_form6",DF_config.powerbar.form,7,DF.locale["form6"],34,7,DF.powerbar_reinit,"Stance")
	
	pt = DF:options_createPanel("castbar",3,13,true,DF.locale["castbar"])
	pt.name = DF.locale["castbar"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"castbarcheck",DF_config.castbar,"enable",DF.locale["active"],0,0,DF.castbar_reinit,"castbar")
	DF:options_createEditbox(pt,"castbarleft",DF_config.castbar,"positionx",DF.locale["positionx"],0,1,DF.castbar_reinit,false,"position")
	DF:options_createEditbox(pt,"castbartop",DF_config.castbar,"positiony",DF.locale["positiony"],17,1,DF.castbar_reinit,false,"position")
	DF:options_createEditbox(pt,"castbarw",DF_config.castbar,"width",DF.locale["width"],0,2,DF.castbar_reinit)
	DF:options_createEditbox(pt,"castbarh",DF_config.castbar,"height",DF.locale["height"],17,2,DF.castbar_reinit)
	DF:options_createListbox(pt,"castbartexture1",DF_config.castbar,"texturePath",DF.locale["texturePath"],0,3,DF.castbar_reinit,optionsStatusbars)
	DF:options_createListbox(pt,"castbarorient",DF_config.castbar,"orientation",DF.locale["orientation"],17,3,DF.castbar_reinit,optionsOrientation)
	DF:options_createCheckBox(pt,"castbarshowspark",DF_config.castbar,"showSpark",DF.locale["showSpark"],0,4,DF.castbar_reinit,"spark")
	DF:options_createSlider(pt,"castbarsliderimpulsion",DF_config.castbar,"impulsion",0,4,0.1,DF.locale["pulse"],17,4,DF.castbar_reinit,"pulse2")
	
	DF:options_createCheckBox(pt,"castbarshowt",DF_config.castbar,"showText",DF.locale["showText"],0,5,DF.castbar_reinit)
	DF:options_createListbox(pt,"castbarfont1",DF_config.castbar,"fontPath",DF.locale["text"].." "..DF.locale["fontPath"],17,5,DF.castbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"castbarslidersize",DF_config.castbar,"fontSize",6,28,1,DF.locale["text"].." "..DF.locale["fontSize"],34,5,DF.castbar_reinit)
	
	DF:options_createListbox(pt,"castbartextalign",DF_config.castbar,"textAlign",DF.locale["text"].." "..DF.locale["align"],0,6,DF.castbar_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"castbarslideralignx",DF_config.castbar,"textx",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsetx"],17,6,DF.castbar_reinit,"Text offset")
	DF:options_createSlider(pt,"castbarslideraligny",DF_config.castbar,"texty",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsety"],34,6,DF.castbar_reinit,"Text offset")

	DF:options_createCheckBox(pt,"castbarshowttimer",DF_config.castbar,"showTimer",DF.locale["number"].." "..DF.locale["active"],0,7,DF.castbar_reinit)
	DF:options_createListbox(pt,"castbarfont1timer",DF_config.castbar,"fontPathtimer",DF.locale["number"].." "..DF.locale["fontPath"],17,7,DF.castbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"castbarslidersizetimer",DF_config.castbar,"fontSizetimer",6,28,1,DF.locale["number"].." "..DF.locale["fontSize"],34,7,DF.castbar_reinit)
	
	DF:options_createListbox(pt,"castbartextaligntimer",DF_config.castbar,"timerAlign",DF.locale["number"].." "..DF.locale["align"],0,8,DF.castbar_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"castbarslideralignxtimer",DF_config.castbar,"timerx",-32,32,0.5,DF.locale["number"].." "..DF.locale["offsetx"],17,8,DF.castbar_reinit,"Text offset")
	DF:options_createSlider(pt,"castbarslideralignytimer",DF_config.castbar,"timery",-32,32,0.5,DF.locale["number"].." "..DF.locale["offsety"],34,8,DF.castbar_reinit,"Text offset")

	
	DF:options_createCheckBox(pt,"castbarborder",DF_config.castbar,"border",DF.locale["border"].." "..DF.locale["active"],0,9,DF.castbar_reinit)
	DF:options_createSlider(pt,"castbarbordersize",DF_config.castbar,"borderSize",0,8,1,DF.locale["border"].." "..DF.locale["size"],17,9,DF.castbar_reinit)
	DF:options_createSlider(pt,"castbarsliderlevel",DF_config.castbar,"level",1,20,1,DF.locale["level"],0,10,DF.castbar_reinit,"Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,11)
	DF:options_createColorBox(pt,"castbardefcolor",DF_config.castbar,"color",DF.locale["color"].." "..DF.locale["normal"],0,12,DF.castbar_reinit)
	DF:options_createColorBox(pt,"castbarintcolor",DF_config.castbar,"colori",DF.locale["color"].." "..DF.locale["interrupt"],17,12,DF.castbar_reinit)
	DF:options_createColorBox(pt,"castbarbordercolor",DF_config.castbar,"borderColor",DF.locale["border"].." "..DF.locale["color"],0,13,DF.castbar_reinit)
	DF:options_createColorBox(pt,"castbartextcolor",DF_config.castbar,"textColor",DF.locale["text"].." "..DF.locale["color"],17,13,DF.castbar_reinit)

	pt = DF:options_createPanel("healthbar",3,13,true,DF.locale["healthbar"])
	pt.name = DF.locale["healthbar"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"healthbarcheck",DF_config.healthbar,"enable",DF.locale["active"],0,0,DF.healthbar_reinit)
	DF:options_createEditbox(pt,"healthbarleft",DF_config.healthbar,"positionx",DF.locale["positionx"],0,1,DF.healthbar_reinit,false,"position")
	DF:options_createEditbox(pt,"healthbartop",DF_config.healthbar,"positiony",DF.locale["positiony"],17,1,DF.healthbar_reinit,false,"position")
	DF:options_createEditbox(pt,"healthbarw",DF_config.healthbar,"width",DF.locale["width"],0,2,DF.healthbar_reinit)
	DF:options_createEditbox(pt,"healthbarh",DF_config.healthbar,"height",DF.locale["height"],17,2,DF.healthbar_reinit)
	DF:options_createListbox(pt,"healthbartexture1",DF_config.healthbar,"texturePath",DF.locale["texturePath"],0,3,DF.healthbar_reinit,optionsStatusbars)
	DF:options_createListbox(pt,"healthbarorient",DF_config.healthbar,"orientation",DF.locale["orientation"],17,3,DF.healthbar_reinit,optionsOrientation)
	DF:options_createCheckBox(pt,"healthbarshowt",DF_config.healthbar,"showText",DF.locale["showText"],0,4,DF.healthbar_reinit)
	DF:options_createListbox(pt,"healthbarfont1",DF_config.healthbar,"fontPath",DF.locale["fontPath"],0,5,DF.healthbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"healthbarslidersize",DF_config.healthbar,"fontSize",6,28,1,DF.locale["fontSize"],17,5,DF.healthbar_reinit)
	DF:options_createListbox(pt,"healthbartextalign",DF_config.healthbar,"textAlign",DF.locale["text"].." "..DF.locale["align"],0,6,DF.healthbar_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"healthbarslideralignx",DF_config.healthbar,"textx",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsetx"],17,6,DF.healthbar_reinit,"Text offset")
	DF:options_createSlider(pt,"healthbarslideraligny",DF_config.healthbar,"texty",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsety"],17,7,DF.healthbar_reinit,"Text offset")
	DF:options_createCheckBox(pt,"healthbarborder",DF_config.healthbar,"border",DF.locale["border"].." "..DF.locale["active"],0,8,DF.healthbar_reinit)
	DF:options_createSlider(pt,"healthbarbordersize",DF_config.healthbar,"borderSize",0,8,1,DF.locale["border"].." "..DF.locale["size"],17,8,DF.healthbar_reinit)
	DF:options_createSlider(pt,"healthbarsliderlevel",DF_config.healthbar,"level",1,20,1,DF.locale["level"],0,9,DF.healthbar_reinit,"Level")
	DF:options_createCheckBox(pt,"healthbarcolorchgcheck",DF_config.healthbar,"colorchg",DF.locale["colorchg"],17,10,DF.healthbar_reinit,"colorchg")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,10)
	DF:options_createColorBox(pt,"healthbarcolorGood",DF_config.healthbar,"colorGood",DF.locale["colorGood"].." "..DF.locale["color"],0,11,DF.healthbar_reinit)
	DF:options_createColorBox(pt,"healthbarcolorAverage",DF_config.healthbar,"colorAverage",DF.locale["colorAverage"].." "..DF.locale["color"],17,11,DF.healthbar_reinit)
	DF:options_createColorBox(pt,"healthbarcolorBad",DF_config.healthbar,"colorBad",DF.locale["colorBad"].." "..DF.locale["color"],0,12,DF.healthbar_reinit)
	DF:options_createColorBox(pt,"healthbarbordercolor",DF_config.healthbar,"borderColor",DF.locale["border"].." "..DF.locale["color"],17,12,DF.healthbar_reinit)
	DF:options_createColorBox(pt,"healthbartextcolor",DF_config.healthbar,"textColor",DF.locale["text"].." "..DF.locale["color"],0,13,DF.healthbar_reinit)
	DF:options_createEditbox(pt,"healthbartextformat",DF_config.healthbar,"sformat",DF.locale["sformat"],17,4,DF.healthbar_reinit,false,"sformat")
	DF:options_createText(pt,DF.locale["infostance"],34,0)
	DF:options_createCheckBox(pt,"DFhealthbar_form0",DF_config.healthbar.form,1,DF.locale["form0"],34,1,DF.healthbar_reinit,"Humanoïd")
	DF:options_createCheckBox(pt,"DFhealthbar_form1",DF_config.healthbar.form,2,DF.locale["form1"],34,2,DF.healthbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"DFhealthbar_form2",DF_config.healthbar.form,3,DF.locale["form2"],34,3,DF.healthbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"DFhealthbar_form3",DF_config.healthbar.form,4,DF.locale["form3"],34,4,DF.healthbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"DFhealthbar_form4",DF_config.healthbar.form,5,DF.locale["form4"],34,5,DF.healthbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"DFhealthbar_form5",DF_config.healthbar.form,6,DF.locale["form5"],34,6,DF.healthbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"DFhealthbar_form6",DF_config.healthbar.form,7,DF.locale["form6"],34,7,DF.healthbar_reinit,"Stance")

	pt = DF:options_createPanel("manabar",3,12,true,DF.locale["manabar"])
	pt.name = DF.locale["manabar"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"manabarcheck",DF_config.manabar,"enable",DF.locale["active"],0,0,DF.manabar_reinit)
	DF:options_createEditbox(pt,"manabarleft",DF_config.manabar,"positionx",DF.locale["positionx"],0,1,DF.manabar_reinit,false,"position")
	DF:options_createEditbox(pt,"manabartop",DF_config.manabar,"positiony",DF.locale["positiony"],17,1,DF.manabar_reinit,false,"position")
	DF:options_createEditbox(pt,"manabarw",DF_config.manabar,"width",DF.locale["width"],0,2,DF.manabar_reinit)
	DF:options_createEditbox(pt,"manabarh",DF_config.manabar,"height",DF.locale["height"],17,2,DF.manabar_reinit)
	DF:options_createListbox(pt,"manabartexture1",DF_config.manabar,"texturePath",DF.locale["texturePath"],0,3,DF.manabar_reinit,optionsStatusbars)
	DF:options_createListbox(pt,"manabarorient",DF_config.manabar,"orientation",DF.locale["orientation"],17,3,DF.manabar_reinit,optionsOrientation)
	DF:options_createCheckBox(pt,"manabarshowt",DF_config.manabar,"showText",DF.locale["showText"],0,4,DF.manabar_reinit)
	DF:options_createListbox(pt,"manabarfont1",DF_config.manabar,"fontPath",DF.locale["fontPath"],0,5,DF.manabar_reinit,optionsFonts)
	DF:options_createSlider(pt,"manabarslidersize",DF_config.manabar,"fontSize",6,28,1,DF.locale["fontSize"],17,5,DF.manabar_reinit)
	DF:options_createListbox(pt,"manabartextalign",DF_config.manabar,"textAlign",DF.locale["text"].." "..DF.locale["align"],0,6,DF.manabar_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"manabarslideralignx",DF_config.manabar,"textx",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsetx"],17,6,DF.manabar_reinit,"Text offset")
	DF:options_createSlider(pt,"manabarslideraligny",DF_config.manabar,"texty",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsety"],17,7,DF.manabar_reinit,"Text offset")
	DF:options_createCheckBox(pt,"manabarborder",DF_config.manabar,"border",DF.locale["border"].." "..DF.locale["active"],0,8,DF.manabar_reinit)
	DF:options_createSlider(pt,"manabarbordersize",DF_config.manabar,"borderSize",0,8,1,DF.locale["border"].." "..DF.locale["size"],17,8,DF.manabar_reinit)
	DF:options_createSlider(pt,"manabarsliderlevel",DF_config.manabar,"level",1,20,1,DF.locale["level"],0,9,DF.manabar_reinit,"Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,10)
	DF:options_createColorBox(pt,"manabarcolor",DF_config.manabar,"color",DF.locale["manabar"].." "..DF.locale["color"],0,11,DF.manabar_reinit)
	DF:options_createColorBox(pt,"manabarbordercolor",DF_config.manabar,"borderColor",DF.locale["border"].." "..DF.locale["color"],17,11,DF.manabar_reinit)
	DF:options_createColorBox(pt,"manabartextcolor",DF_config.manabar,"textColor",DF.locale["text"].." "..DF.locale["color"],0,12,DF.manabar_reinit)
	DF:options_createEditbox(pt,"manabartextformat",DF_config.manabar,"sformat",DF.locale["sformat"],17,4,DF.manabar_reinit,false,"sformat")
	DF:options_createText(pt,DF.locale["infostance"],34,0)
	DF:options_createCheckBox(pt,"manabar_form0",DF_config.manabar.form,1,DF.locale["form0"],34,1,DF.manabar_reinit,"Humanoïd")
	DF:options_createCheckBox(pt,"manabar_form1",DF_config.manabar.form,2,DF.locale["form1"],34,2,DF.manabar_reinit,"Stance")
	DF:options_createCheckBox(pt,"manabar_form2",DF_config.manabar.form,3,DF.locale["form2"],34,3,DF.manabar_reinit,"Stance")
	DF:options_createCheckBox(pt,"manabar_form3",DF_config.manabar.form,4,DF.locale["form3"],34,4,DF.manabar_reinit,"Stance")
	DF:options_createCheckBox(pt,"manabar_form4",DF_config.manabar.form,5,DF.locale["form4"],34,5,DF.manabar_reinit,"Stance")
	DF:options_createCheckBox(pt,"manabar_form5",DF_config.manabar.form,6,DF.locale["form5"],34,6,DF.manabar_reinit,"Stance")
	DF:options_createCheckBox(pt,"manabar_form6",DF_config.manabar.form,7,DF.locale["form6"],34,7,DF.manabar_reinit,"Stance")
		
	pt = DF:options_createPanel("targetbar",3,12,true,DF.locale["targetbar"])
	pt.name = DF.locale["targetbar"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"targetbarcheck",DF_config.targetbar,"enable",DF.locale["active"],0,0,DF.targetbar_reinit)
	DF:options_createEditbox(pt,"targetbarleft",DF_config.targetbar,"positionx",DF.locale["positionx"],0,1,DF.targetbar_reinit,false,"position")
	DF:options_createEditbox(pt,"targetbartop",DF_config.targetbar,"positiony",DF.locale["positiony"],17,1,DF.targetbar_reinit,false,"position")
	DF:options_createEditbox(pt,"targetbarw",DF_config.targetbar,"width",DF.locale["width"],0,2,DF.targetbar_reinit)
	DF:options_createEditbox(pt,"targetbarh",DF_config.targetbar,"height",DF.locale["height"],17,2,DF.targetbar_reinit)
	DF:options_createListbox(pt,"targetbartexture1",DF_config.targetbar,"texturePath",DF.locale["texturePath"],0,3,DF.targetbar_reinit,optionsStatusbars)
	DF:options_createListbox(pt,"targetbarorient",DF_config.targetbar,"orientation",DF.locale["orientation"],17,3,DF.targetbar_reinit,optionsOrientation)
	DF:options_createCheckBox(pt,"targetbarshowt",DF_config.targetbar,"showText",DF.locale["showText"],0,4,DF.targetbar_reinit)
	DF:options_createListbox(pt,"targetbarfont1",DF_config.targetbar,"fontPath",DF.locale["fontPath"],0,5,DF.targetbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"targetbarslidersize",DF_config.targetbar,"fontSize",6,28,1,DF.locale["fontSize"],17,5,DF.targetbar_reinit)
	DF:options_createListbox(pt,"targetbartextalign",DF_config.targetbar,"textAlign",DF.locale["text"].." "..DF.locale["align"],0,6,DF.targetbar_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"targetbarslideralignx",DF_config.targetbar,"textx",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsetx"],17,6,DF.targetbar_reinit,"Text offset")
	DF:options_createSlider(pt,"targetbarslideraligny",DF_config.targetbar,"texty",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsety"],17,7,DF.targetbar_reinit,"Text offset")
	DF:options_createCheckBox(pt,"targetbarborder",DF_config.targetbar,"border",DF.locale["border"].." "..DF.locale["active"],0,8,DF.targetbar_reinit)
	DF:options_createSlider(pt,"targetbarbordersize",DF_config.targetbar,"borderSize",0,8,1,DF.locale["border"].." "..DF.locale["size"],17,8,DF.targetbar_reinit)
	DF:options_createSlider(pt,"targetbarsliderlevel",DF_config.targetbar,"level",1,20,1,DF.locale["level"],0,9,DF.targetbar_reinit,"Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,10)
	DF:options_createColorBox(pt,"targetbarcolor",DF_config.targetbar,"color",DF.locale["targetbar"].." "..DF.locale["color"],0,11,DF.targetbar_reinit)
	DF:options_createColorBox(pt,"targetbarbordercolor",DF_config.targetbar,"borderColor",DF.locale["border"].." "..DF.locale["color"],17,11,DF.targetbar_reinit)
	DF:options_createColorBox(pt,"targetbartextcolor",DF_config.targetbar,"textColor",DF.locale["text"].." "..DF.locale["color"],0,12,DF.targetbar_reinit)
	DF:options_createEditbox(pt,"targetbartextformat",DF_config.targetbar,"sformat",DF.locale["sformat"],17,4,DF.targetbar_reinit,false,"sformat")
	DF:options_createText(pt,DF.locale["infostance"],34,0)
	DF:options_createCheckBox(pt,"targetbar_form0",DF_config.targetbar.form,1,DF.locale["form0"],34,1,DF.targetbar_reinit,"Humanoïd")
	DF:options_createCheckBox(pt,"targetbar_form1",DF_config.targetbar.form,2,DF.locale["form1"],34,2,DF.targetbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"targetbar_form2",DF_config.targetbar.form,3,DF.locale["form2"],34,3,DF.targetbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"targetbar_form3",DF_config.targetbar.form,4,DF.locale["form3"],34,4,DF.targetbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"targetbar_form4",DF_config.targetbar.form,5,DF.locale["form4"],34,5,DF.targetbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"targetbar_form5",DF_config.targetbar.form,6,DF.locale["form5"],34,6,DF.targetbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"targetbar_form6",DF_config.targetbar.form,7,DF.locale["form6"],34,7,DF.targetbar_reinit,"Stance")
		
	pt = DF:options_createPanel("threatbar",3,12,true,DF.locale["threatbar"])
	pt.name = DF.locale["threatbar"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"threatbarcheck",DF_config.threatbar,"enable",DF.locale["active"],0,0,DF.threatbar_reinit)
	DF:options_createEditbox(pt,"threatbarleft",DF_config.threatbar,"positionx",DF.locale["positionx"],0,1,DF.threatbar_reinit,false,"position")
	DF:options_createEditbox(pt,"threatbartop",DF_config.threatbar,"positiony",DF.locale["positiony"],17,1,DF.threatbar_reinit,false,"position")
	DF:options_createEditbox(pt,"threatbarw",DF_config.threatbar,"width",DF.locale["width"],0,2,DF.threatbar_reinit)
	DF:options_createEditbox(pt,"threatbarh",DF_config.threatbar,"height",DF.locale["height"],17,2,DF.threatbar_reinit)
	DF:options_createListbox(pt,"threatbartexture1",DF_config.threatbar,"texturePath",DF.locale["texturePath"],0,3,DF.threatbar_reinit,optionsStatusbars)
	DF:options_createListbox(pt,"threatbarorient",DF_config.threatbar,"orientation",DF.locale["orientation"],17,3,DF.threatbar_reinit,optionsOrientation)
	DF:options_createCheckBox(pt,"threatbarshowt",DF_config.threatbar,"showText",DF.locale["showText"],0,4,DF.threatbar_reinit)
	DF:options_createListbox(pt,"threatbarfont1",DF_config.threatbar,"fontPath",DF.locale["fontPath"],0,5,DF.threatbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"threatbarslidersize",DF_config.threatbar,"fontSize",6,28,1,DF.locale["fontSize"],17,5,DF.threatbar_reinit)
	DF:options_createListbox(pt,"threatbartextalign",DF_config.threatbar,"textAlign",DF.locale["text"].." "..DF.locale["align"],0,6,DF.threatbar_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"threatbarslideralignx",DF_config.threatbar,"textx",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsetx"],17,6,DF.threatbar_reinit,"Text offset")
	DF:options_createSlider(pt,"threatbarslideraligny",DF_config.threatbar,"texty",-32,32,0.5,DF.locale["text"].." "..DF.locale["offsety"],17,7,DF.threatbar_reinit,"Text offset")
	DF:options_createCheckBox(pt,"threatbarborder",DF_config.threatbar,"border",DF.locale["border"].." "..DF.locale["active"],0,8,DF.threatbar_reinit)
	DF:options_createSlider(pt,"threatbarbordersize",DF_config.threatbar,"borderSize",0,8,1,DF.locale["border"].." "..DF.locale["size"],17,8,DF.threatbar_reinit)
	DF:options_createSlider(pt,"threatbarsliderlevel",DF_config.threatbar,"level",1,20,1,DF.locale["level"],0,9,DF.threatbar_reinit,"Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,10)
	DF:options_createColorBox(pt,"threatbarcolor",DF_config.threatbar,"color",DF.locale["threatbar"].." "..DF.locale["color"],0,11,DF.threatbar_reinit)
	DF:options_createColorBox(pt,"threatbarbordercolor",DF_config.threatbar,"borderColor",DF.locale["border"].." "..DF.locale["color"],17,11,DF.threatbar_reinit)
	DF:options_createColorBox(pt,"threatbartextcolor",DF_config.threatbar,"textColor",DF.locale["text"].." "..DF.locale["color"],0,12,DF.threatbar_reinit)
	DF:options_createEditbox(pt,"threatbartextformat",DF_config.threatbar,"sformat",DF.locale["sformat"],17,4,DF.threatbar_reinit,false,"sformat")
	DF:options_createText(pt,DF.locale["infostance"],34,0)
	DF:options_createCheckBox(pt,"threatbar_form0",DF_config.threatbar.form,1,DF.locale["form0"],34,1,DF.threatbar_reinit,"Humanoïd")
	DF:options_createCheckBox(pt,"threatbar_form1",DF_config.threatbar.form,2,DF.locale["form1"],34,2,DF.threatbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"threatbar_form2",DF_config.threatbar.form,3,DF.locale["form2"],34,3,DF.threatbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"threatbar_form3",DF_config.threatbar.form,4,DF.locale["form3"],34,4,DF.threatbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"threatbar_form4",DF_config.threatbar.form,5,DF.locale["form4"],34,5,DF.threatbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"threatbar_form5",DF_config.threatbar.form,6,DF.locale["form5"],34,6,DF.threatbar_reinit,"Stance")
	DF:options_createCheckBox(pt,"threatbar_form6",DF_config.threatbar.form,7,DF.locale["form6"],34,7,DF.threatbar_reinit,"Stance")
	
	pt = DF:options_createPanel("cooldown",2,4,true,DF.locale["cooldown"])
	pt.name = DF.locale["cooldown"]
	pt.parent = "DroodFocus"			
	DF:options_createCheckBox(pt,"cooldowncheck",DF_config.cooldown,"enable",DF.locale["active"],0,0,DF.cooldown_reinit,"cooldown")
	--DF:options_createEditbox(pt,"cooldownleft",DF_config.cooldown,"positionx",DF.locale["positionx"],0,1,DF.cooldown_reinit,false,"position")
	--DF:options_createEditbox(pt,"cooldowntop",DF_config.cooldown,"positiony",DF.locale["positiony"],17,1,DF.cooldown_reinit,false,"position")
	DF:options_createSlider(pt,"cooldownw",DF_config.cooldown,"width",8,128,1,DF.locale["width"],0,1,DF.cooldown_reinit)
	DF:options_createSlider(pt,"cooldownh",DF_config.cooldown,"height",8,128,1,DF.locale["height"],17,1,DF.cooldown_reinit)
	DF:options_createSlider(pt,"cooldownoffsetx",DF_config.cooldown,"offsetx",-128,128,4,DF.locale["offsetx"],0,2,DF.cooldown_reinit,"Point offset")
	DF:options_createSlider(pt,"cooldownoffsety",DF_config.cooldown,"offsety",-128,128,4,DF.locale["offsety"],17,2,DF.cooldown_reinit,"Point offset")
	DF:options_createListbox(pt,"cooldowntexturemode",DF_config.cooldown,"mode",DF.locale["mode"],0,3,DF.cooldown_reinit,optionsBlend,false,"Blend mode")
	DF:options_createSlider(pt,"cooldownsliderlevel",DF_config.cooldown,"level",1,20,1,DF.locale["level"],0,4,DF.cooldown_reinit,"Level")
	DF:options_createSlider(pt,"cooldownalpha",DF_config.cooldown,"alpha",0,1,0.1,DF.locale["activeAlpha"],17,3,DF.cooldown_reinit,"Alpha")

	pt = DF:options_createPanel("combo",2,14,true,DF.locale["combo"])
	pt.name = DF.locale["combo"]
	pt.parent = "DroodFocus"			
	DF:options_createCheckBox(pt,"combocheck",DF_config.combo,"enable",DF.locale["active"],0,0,DF.combo_reinit,"combo")
	DF:options_createEditbox(pt,"comboleft",DF_config.combo,"positionx",DF.locale["positionx"],0,1,DF.combo_reinit,false,"position")
	DF:options_createEditbox(pt,"combotop",DF_config.combo,"positiony",DF.locale["positiony"],17,1,DF.combo_reinit,false,"position")
	DF:options_createSlider(pt,"combow",DF_config.combo,"width",8,128,1,DF.locale["width"],0,2,DF.combo_reinit)
	DF:options_createSlider(pt,"comboh",DF_config.combo,"height",8,128,1,DF.locale["height"],17,2,DF.combo_reinit)
	DF:options_createSlider(pt,"combooffsetx",DF_config.combo,"offsetx",-64,64,1,DF.locale["offsetx"],0,5,DF.combo_reinit,"Point offset")
	DF:options_createSlider(pt,"combooffsety",DF_config.combo,"offsety",-64,64,1,DF.locale["offsety"],0,6,DF.combo_reinit,"Point offset")
	DF:options_createListbox(pt,"combotexture1",DF_config.combo,"texturePath",DF.locale["texturePath"],0,3,DF.combo_reinit,optionsTextures)
	DF:options_createListbox(pt,"combotexturemode",DF_config.combo,"mode",DF.locale["mode"],17,3,DF.combo_reinit,optionsBlend,false,"Blend mode")
	DF:options_createListbox(pt,"comboplacemode",DF_config.combo,"ptype",DF.locale["ptype"],0,4,DF.combo_reinit,optionsCombotype,false,"ptype")
	DF:options_createSlider(pt,"combosliderlevel",DF_config.combo,"level",1,20,1,DF.locale["level"],0,7,DF.combo_reinit,"Level")
	DF:options_createSlider(pt,"combosliderrayon",DF_config.combo,"rayon",8,256,1,DF.locale["rayon"],17,5,DF.combo_reinit)
	DF:options_createSlider(pt,"comboslidersangle",DF_config.combo,"angleA",0,359,1,DF.locale["sangle"],17,6,DF.combo_reinit)
	DF:options_createSlider(pt,"comboslidereangle",DF_config.combo,"angleB",0,359,1,DF.locale["eangle"],17,7,DF.combo_reinit)
	DF:options_createCheckBox(pt,"comboshowt",DF_config.combo,"showText",DF.locale["showText"],0,8,DF.combo_reinit)
	DF:options_createColorBox(pt,"combotextcolor",DF_config.combo,"textColor",DF.locale["text"].." "..DF.locale["color"],17,8,DF.combo_reinit)
	DF:options_createListbox(pt,"combosfont1",DF_config.combo,"fontPath",DF.locale["fontPath"].." "..DF.locale["texts"],0,9,DF.combo_reinit,optionsFonts)
	DF:options_createSlider(pt,"combosslidersize1",DF_config.combo,"fontSize",6,28,1,DF.locale["fontSize"].." "..DF.locale["texts"],17,9,DF.combo_reinit)
	DF:options_createText(pt,DF.locale["infostance"],0,10)
	DF:options_createCheckBox(pt,"combo_form0",DF_config.combo.form,1,DF.locale["form0"],0,11,DF.combo_reinit,"Humanoïd")
	DF:options_createCheckBox(pt,"combo_form1",DF_config.combo.form,2,DF.locale["form1"],0,12,DF.combo_reinit,"Stance")
	DF:options_createCheckBox(pt,"combo_form2",DF_config.combo.form,3,DF.locale["form2"],17,12,DF.combo_reinit,"Stance")
	DF:options_createCheckBox(pt,"combo_form3",DF_config.combo.form,4,DF.locale["form3"],0,13,DF.combo_reinit,"Stance")
	DF:options_createCheckBox(pt,"combo_form4",DF_config.combo.form,5,DF.locale["form4"],17,13,DF.combo_reinit,"Stance")
	DF:options_createCheckBox(pt,"combo_form5",DF_config.combo.form,6,DF.locale["form5"],0,14,DF.combo_reinit,"Stance")
	DF:options_createCheckBox(pt,"combo_form6",DF_config.combo.form,7,DF.locale["form6"],17,14,DF.combo_reinit,"Stance")
	DF:options_createSlider(pt,"comboimpulsion",DF_config.combo,"impulsion",0,3,0.05,DF.locale["pulse2"],17,4,DF.combo_reinit,"pulse2")

	pt = DF:options_createPanel("icons",3,14,true,DF.locale["icons"])
	pt.name = DF.locale["icons"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"iconscheck",DF_config.icons,"enable",DF.locale["active"],0,0,DF.icons_reinit)
	DF:options_createConfigButton(pt,"iconscheckspellscheck",DF.locale["spells"],17,0,DF.options_show,"spells")
	DF:options_createCheckBox(pt,"iconsauto",DF_config.icons,"automatic",DF.locale["automatic"],0,1,DF.icons_reinit,"Automatic placement")
	DF:options_createCheckBox(pt,"iconsgrowup",DF_config.icons,"growup",DF.locale["growup"],17,2,DF.icons_reinit,"growup")
	DF:options_createCheckBox(pt,"iconsgrowup",DF_config.icons,"pointpa",DF.locale["pointpa"],17,3,DF.icons_reinit,"pointpa")
	DF:options_createSlider(pt,"iconsspeed",DF_config.icons,"speed",4,256,8,DF.locale["speed"],0,2,DF.icons_reinit,"Slide speed")
	DF:options_createCheckBox(pt,"iconsorder",DF_config.icons,"orderByTime",DF.locale["order"],17,1,DF.icons_reinit,"Sort by timeleft")
	DF:options_createListbox(pt,"iconsfont1",DF_config.icons,"fontPath",DF.locale["fontPath"],0,3,DF.icons_reinit,optionsFonts)
	DF:options_createListbox(pt,"iconsspiral",DF_config.icons,"showSpiral",DF.locale["spiral"],34,2,DF.icons_reinit,optionsSpiral,false,"spiral")
	DF:options_createSlider(pt,"iconssliderpulse",DF_config.icons,"pulse",1,2,0.10,DF.locale["pulse"],34,3,DF.icons_reinit,"pulse")
	DF:options_createListbox(pt,"iconsslideralign1x",DF_config.icons.textsoffsets[1],"align",DF.locale["number"].." "..DF.locale["align"],17,4,DF.icons_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"iconsslidersize1",DF_config.icons.textsoffsets[1],"size",6,28,1,DF.locale["number"].." "..DF.locale["fontSize"],34,4,DF.icons_reinit)
	DF:options_createSlider(pt,"iconsslideroffset1x",DF_config.icons.textsoffsets[1],"offsetx",-128,128,1,DF.locale["toffsetx"].." "..DF.locale["number"],17,5,DF.icons_reinit,"Text offset")
	DF:options_createSlider(pt,"iconsslideroffset1y",DF_config.icons.textsoffsets[1],"offsety",-128,128,1,DF.locale["toffsety"].." "..DF.locale["number"],34,5,DF.icons_reinit,"Text offset")
	DF:options_createListbox(pt,"iconsslideralign2x",DF_config.icons.textsoffsets[2],"align",DF.locale["stack"].." "..DF.locale["align"],17,6,DF.icons_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"iconsslidersize2",DF_config.icons.textsoffsets[2],"size",6,28,1,DF.locale["stack"].." "..DF.locale["fontSize"],34,6,DF.icons_reinit)
	DF:options_createSlider(pt,"iconsslideroffset2x",DF_config.icons.textsoffsets[2],"offsetx",-128,128,1,DF.locale["toffsetx"].." "..DF.locale["stack"],17,7,DF.icons_reinit,"Text offset")
	DF:options_createSlider(pt,"iconsslideroffset2y",DF_config.icons.textsoffsets[2],"offsety",-128,128,1,DF.locale["toffsety"].." "..DF.locale["stack"],34,7,DF.icons_reinit,"Text offset")
	DF:options_createListbox(pt,"iconsslideralign3x",DF_config.icons.textsoffsets[3],"align","CD "..DF.locale["align"],17,8,DF.icons_reinit,optionsTextalign,false,"align")
	DF:options_createSlider(pt,"iconsslidersize3",DF_config.icons.textsoffsets[3],"size",6,28,1,"CD "..DF.locale["fontSize"],34,8,DF.icons_reinit)
	DF:options_createSlider(pt,"iconsslideroffset3x",DF_config.icons.textsoffsets[3],"offsetx",-128,128,1,DF.locale["toffsetx"].." CD",17,9,DF.icons_reinit,"Text offset")
	DF:options_createSlider(pt,"iconsslideroffset3y",DF_config.icons.textsoffsets[3],"offsety",-128,128,1,DF.locale["toffsety"].." CD",34,9,DF.icons_reinit,"Text offset")
	DF:options_createSlider(pt,"iconsslidermin",DF_config.icons,"activeAlpha",0,1,0.1,DF.locale["activeAlpha"],0,10,DF.icons_reinit,"Alpha")
	DF:options_createSlider(pt,"iconsslidermax",DF_config.icons,"inactiveAlpha",0,1,0.1,DF.locale["inactiveAlpha"],17,10,DF.icons_reinit,"Alpha")
	DF:options_createSlider(pt,"iconssliderwidth",DF_config.icons,"width",8,128,1,DF.locale["auto"].." "..DF.locale["width"],0,11,DF.icons_reinit)
	DF:options_createSlider(pt,"iconssliderheight",DF_config.icons,"height",8,128,1,DF.locale["auto"].." "..DF.locale["height"],17,11,DF.icons_reinit)
	DF:options_createSlider(pt,"iconsslidercolone",DF_config.icons,"colonne",1,20,1,DF.locale["colonne"],34,1,DF.icons_reinit,"colonne")
	DF:options_createSlider(pt,"iconssliderlevel",DF_config.icons,"level",1,20,1,DF.locale["level"],0,12,DF.icons_reinit,"Level")
	DF:options_createSubTitle(pt,DF.locale["colors"],0,13)
	DF:options_createColorBox(pt,"iconscolor",DF_config.icons,"textColor",DF.locale["text"].." "..DF.locale["color"],0,14,DF.icons_reinit)
	DF:options_createCheckBox(pt,"iconschecktimer1",DF_config.icons.textsoffsets[1],"visible",DF.locale["text"].." "..DF.locale["number"].." "..DF.locale["active"],0,4,DF.icons_reinit)
	DF:options_createCheckBox(pt,"iconscheckdecimal",DF_config.icons,"decimal",DF.locale["decimal"],0,5,DF.icons_reinit,"decimal")
	DF:options_createCheckBox(pt,"iconschecktimer2",DF_config.icons.textsoffsets[2],"visible",DF.locale["text"].." "..DF.locale["stack"].." "..DF.locale["active"],0,6,DF.icons_reinit)
	DF:options_createCheckBox(pt,"iconschecktimer3",DF_config.icons.textsoffsets[3],"visible",DF.locale["text"].." CD "..DF.locale["active"],0,8,DF.icons_reinit)

	pt = DF:options_createPanel("timerbar",2,16,true,DF.locale["timerbar"])
	pt.name = DF.locale["timerbar"]
	pt.parent = "DroodFocus"
	DF:options_createCheckBox(pt,"timerbarcheck",DF_config.timerbar,"enable",DF.locale["active"],0,0,DF.timerbar_reinit)
	DF:options_createConfigButton(pt,"timerbarspellscheck",DF.locale["spells"],17,0,DF.options_show,"spells")
	DF:options_createEditbox(pt,"timerbarw",DF_config.timerbar,"width",DF.locale["width"],0,1,DF.timerbar_reinit)
	DF:options_createEditbox(pt,"timerbarh",DF_config.timerbar,"height",DF.locale["height"],17,1,DF.timerbar_reinit)
	DF:options_createListbox(pt,"timerbartexture1",DF_config.timerbar,"texturePath",DF.locale["texturePath"],0,2,DF.timerbar_reinit,optionsStatusbars)
	DF:options_createListbox(pt,"timerbarfont1",DF_config.timerbar,"font1Path",DF.locale["fontPath"].." "..DF.locale["texts"],0,3,DF.timerbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"timerbarslidersize1",DF_config.timerbar,"font1Size",6,28,1,DF.locale["fontSize"].." "..DF.locale["texts"],17,3,DF.timerbar_reinit)
	DF:options_createListbox(pt,"timerbarfont2",DF_config.timerbar,"font2Path",DF.locale["fontPath"].." "..DF.locale["numbers"],0,5,DF.timerbar_reinit,optionsFonts)
	DF:options_createSlider(pt,"timerbarslidersize2",DF_config.timerbar,"font2Size",6,28,1,DF.locale["fontSize"].." "..DF.locale["numbers"],17,5,DF.timerbar_reinit)
	DF:options_createSlider(pt,"timerbarslidermin",DF_config.timerbar,"activeAlpha",0,1,0.1,DF.locale["activeAlpha"],0,7,DF.timerbar_reinit,"Alpha")
	DF:options_createSlider(pt,"timerbarslidermax",DF_config.timerbar,"inactiveAlpha",0,1,0.1,DF.locale["inactiveAlpha"],17,7,DF.timerbar_reinit,"Alpha")
	DF:options_createCheckBox(pt,"timerbarborder",DF_config.timerbar,"border",DF.locale["border"].." "..DF.locale["active"],0,9,DF.timerbar_reinit)
	DF:options_createSlider(pt,"timerbarbordersize",DF_config.timerbar,"borderSize",0,8,1,DF.locale["border"].." "..DF.locale["size"],17,9,DF.timerbar_reinit)
	DF:options_createSlider(pt,"timerbartimeline",DF_config.timerbar,"timeline",8,60,1,DF.locale["timerange"],17,10,DF.timerbar_reinit,"Time range")
	DF:options_createCheckBox(pt,"timerbarpropcheck",DF_config.timerbar,"prop",DF.locale["prop"],0,10,DF.timerbar_reinit,"prop")
	DF:options_createCheckBox(pt,"timerbarorder",DF_config.timerbar,"orderByTime",DF.locale["order"],0,11,DF.timerbar_reinit,"Sort by timeleft")
	DF:options_createSlider(pt,"timerbarsliderlevel",DF_config.timerbar,"level",1,20,1,DF.locale["level"],0,13,DF.timerbar_reinit,"Level")
	DF:options_createCheckBox(pt,"timerbargrowup",DF_config.timerbar,"growup",DF.locale["growup"],17,11,DF.timerbar_reinit,"growup")
	DF:options_createCheckBox(pt,"timerbarshowspark",DF_config.timerbar,"showSpark",DF.locale["showSpark"],0,12,DF.timerbar_reinit,"spark")
	DF:options_createSlider(pt,"timerbarcdslidermin",DF_config.timerbar,"activeAlphaCD",0,1,0.1,DF.locale["activeAlphaCD"],0,8,DF.timerbar_reinit,"Alpha")
	DF:options_createSlider(pt,"timerbarslideroffsetcdy",DF_config.timerbar,"cdoffsety",-128,128,1,DF.locale["cdoffsety"],17,8,DF.timerbar_reinit)
	DF:options_createSubTitle(pt,DF.locale["colors"],0,14)
	DF:options_createColorBox(pt,"timerbarcolor",DF_config.timerbar,"textColor",DF.locale["text"].." "..DF.locale["color"],0,15,DF.timerbar_reinit)
	DF:options_createColorBox(pt,"timerbarbcolor",DF_config.timerbar,"borderColor",DF.locale["border"].." "..DF.locale["color"],17,15,DF.timerbar_reinit)
	DF:options_createColorBox(pt,"timerbarcdcolor",DF_config.timerbar,"cdColor",DF.locale["cdbar"].." "..DF.locale["color"],0,16,DF.timerbar_reinit)
	DF:options_createSlider(pt,"timerbarslideroffset1x",DF_config.timerbar.textsoffsets[1],"offsetx",-128,128,1,DF.locale["toffsetx"],0,4,DF.timerbar_reinit,"Text offset")
	DF:options_createSlider(pt,"timerbarslideroffset1y",DF_config.timerbar.textsoffsets[1],"offsety",-128,128,1,DF.locale["toffsety"],17,4,DF.timerbar_reinit,"Text offset")
	DF:options_createSlider(pt,"timerbarslideroffset2x",DF_config.timerbar.textsoffsets[2],"offsetx",-128,128,1,DF.locale["toffsetx"].." "..DF.locale["number"],0,6,DF.timerbar_reinit,"Text offset")
	DF:options_createSlider(pt,"timerbarslideroffset2y",DF_config.timerbar.textsoffsets[2],"offsety",-128,128,1,DF.locale["toffsety"].." "..DF.locale["number"],17,6,DF.timerbar_reinit,"Text offset")

	
	-- frames levels
	DF:options_chgFramesLevel(nil)
	DF:options_hide()
	
end

function DF:options_debuffList_apply()
	DF:spells_list_reinit()
	DF:options_DebuffList_populate()
end

function DF:options_DebuffList_up()
	local maxi = getn(DF_config.spells)
	local save={}
	
	if selectPt then
		
		if selectPt>1 then
			DF:copyTable(DF_config.spells[selectPt-1],save)
			DF:copyTable(DF_config.spells[selectPt],DF_config.spells[selectPt-1])
			DF:copyTable(save,DF_config.spells[selectPt])
			selectPt=selectPt-1
			DF:options_DebuffList_click(selectPt)
			DF:spells_list_reinit()
			DF:options_DebuffList_populate()
		end
		
	end	
	
end


function DF:options_DebuffList_new()
	
	table.insert(DF_config.spells, 1, {})
	DF:copyTable(DF.newSpell,DF_config.spells[1])
	DF:spells_list_reinit()
	DF:options_DebuffList_populate()	
	selectPt=1
	currentPosition=1
	DF:options_DebuffList_click(selectPt)
	_G["DFdebufflistContenerSlider"]:SetValue(1)
		
end

function DF:options_DebuffList_kill()
	
	if selectPt and getn(DF_config.spells)>1 then
		
		table.remove(DF_config.spells ,selectPt )
		selectPt=1
		currentPosition=1
		DF:options_DebuffList_click(selectPt)
		DF:spells_list_reinit()
		DF:options_DebuffList_populate()		
		
	end	
	
end

function DF:options_DebuffList_down()
	local maxi = getn(DF_config.spells)
	local save={}
	
	if selectPt then
		
		if selectPt<maxi then

			DF:copyTable(DF_config.spells[selectPt+1],save)
			DF:copyTable(DF_config.spells[selectPt],DF_config.spells[selectPt+1])
			DF:copyTable(save,DF_config.spells[selectPt])
			selectPt=selectPt+1
			DF:options_DebuffList_click(selectPt)
			DF:spells_list_reinit()
			DF:options_DebuffList_populate()
		end
		
	end	
	
end

function DF:options_show(name,parent)
	if not name then name=DF.myArgs end
	
	if DroodFocusOptions[name]:IsVisible() then
		DroodFocusOptions[name]:Hide()
	else
		DF:options_chgFramesLevel(name)
		DroodFocusOptions[name]:Show()
	end
	
end

function DF:options_transp(name)
	if name then
		if DroodFocusOptions[name].transp then
			DroodFocusOptions[name].transp=false
			DroodFocusOptions[name]:SetAlpha(1)
		else
			DroodFocusOptions[name].transp=true
			DroodFocusOptions[name]:SetAlpha(0.33)			
		end
	end
end

function DF:options_hide(name)
	if name then
		DroodFocusOptions[name]:Hide()
	else
		for k,_ in pairs(DroodFocusOptions) do
			if DroodFocusOptions[k].isMovable then
				DroodFocusOptions[k]:Hide()
			end
		end
	end
end

-- widgets fonctions
function DF:options_createPanel(name,largeur,nline,movable,title)
	DroodFocusOptions[name] = CreateFrame("FRAME","DroodFocusOptions"..name,UIParent,"OptionsBoxTemplate")

	DroodFocusOptions[name].isMovable = movable

	if movable then
		DroodFocusOptions[name]:SetMovable(true)
		DroodFocusOptions[name]:EnableMouse(true)
		DroodFocusOptions[name]:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark.blp", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
		DroodFocusOptions[name]:SetFrameStrata("DIALOG");
		DroodFocusOptions[name]:SetBackdropColor(0,0,0,1);
		DroodFocusOptions[name]:SetWidth(202*largeur)
		DroodFocusOptions[name]:SetHeight(28+((nline+1)*38))

		DroodFocusOptions[name].transp = false

		DroodFocusOptions[name]:ClearAllPoints()
		DroodFocusOptions[name]:SetPoint("LEFT", UIParent, "LEFT", 16, 0)

		DroodFocusOptions[name]:SetScript("OnMouseDown",function(self)
			DF:options_chgFramesLevel(name)
			DroodFocusOptions[name]:StartMoving()
		end)
		DroodFocusOptions[name]:SetScript("OnMouseUp",function(self)
			DroodFocusOptions[name]:StopMovingOrSizing()
		end)	

		temp = CreateFrame("FRAME","DroodFocusOptionsbar"..name,DroodFocusOptions[name]);
		temp:SetMovable(false)
		temp:EnableMouse(movable)
		t=temp:CreateTexture(nil);
		temp.texture=t;
		temp:SetHeight(22)
		temp:SetWidth((202*largeur)-4)
		temp:SetPoint("TOPLEFT", DroodFocusOptions[name], "TOPLEFT", 2, -2)
		temp.texture:SetAllPoints(temp)
		temp.texture:SetTexture(90/255,106/255,80/255,0.85);
		temp.text = temp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		temp.text:SetText(DF.locale["versionName"].." - "..title)
		temp.text:SetPoint("LEFT", temp, "LEFT", 6, 0);	
		temp:SetScript("OnMouseDown",function(self)
			DF:options_chgFramesLevel(name)
			DroodFocusOptions[name]:StartMoving()
		end)
		temp:SetScript("OnMouseUp",function(self)
			DroodFocusOptions[name]:StopMovingOrSizing()
		end)	
		temp:SetFrameLevel(DroodFocusOptions[name]:GetFrameLevel()+1)
		
		local button = CreateFrame("Button", "DroodFocusOptionsclose"..name, DroodFocusOptions[name], "GameMenuButtonTemplate")
		button:SetText("X")
		button:SetWidth(20)
		button:SetHeight(20)
		button:SetPoint("TOPRIGHT", DroodFocusOptions[name], "TOPRIGHT", -4, -3)
		button:SetScript("OnClick", function(self)
			DF:options_hide(name)
		end)
		button:SetFrameLevel(DroodFocusOptions[name]:GetFrameLevel()+2)
		
		local button = CreateFrame("Button", "DroodFocusOptionsderoule"..name, DroodFocusOptions[name], "GameMenuButtonTemplate")
		button:SetText("-")
		button:SetWidth(20)
		button:SetHeight(20)
		button:SetPoint("TOPRIGHT", DroodFocusOptions[name], "TOPRIGHT", -26, -3)
		button:SetScript("OnClick", function(self)
			DF:options_transp(name)
		end)
		button:SetFrameLevel(DroodFocusOptions[name]:GetFrameLevel()+2)		
		
	end
	
	return DroodFocusOptions[name]
end

function DF:options_chgFramesLevel(name)
	
	if not DroodFocusOptions[name] then
		
		startLevel=1
		for k,_ in pairs(DroodFocusOptions) do
			if DroodFocusOptions[k].isMovable then
				DroodFocusOptions[k]:SetFrameLevel(startLevel)
			end
		end
		
	else
		
		startLevel=1
		for k,_ in pairs(DroodFocusOptions) do
			if DroodFocusOptions[k]:IsVisible() then
				if DroodFocusOptions[k]:GetFrameLevel()>=startLevel and k~=name then
					startLevel=DroodFocusOptions[k]:GetFrameLevel()+4
				end
			end
		end

		if DroodFocusOptions[name].isMovable then
			DroodFocusOptions[name]:SetFrameLevel(startLevel)
		end
		
	end	
	
end

function DF:options_chgBase(name,newbase)
	
	local obj = _G[name]
	if obj then
		obj.base=newbase
		obj:Hide()
		obj:Show()
	end
	
end

function DF:options_createButton(parent,name,infos,posx,posy,fonction,args)
	
	-- titre
	local obj = CreateFrame("Button", name, parent, "OptionsButtonTemplate")
	obj:SetText(infos)
	obj:SetWidth(80)
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 8+(posx*11.5), -29-(posy*38))
	
	local fontString = obj:GetFontString()
	police = fontString:GetFont();fontString:SetFont(police,10)
		
	obj:SetScript("OnClick", function(self)
		falseEditBox:SetFocus()
		if fonction then
			DF.myArgs=args
			fonction()
		end
	end)
	
end

function DF:options_createSwapButton(parent,name,base,index,infos,textOn,textOff,posx,posy,fonction)

	-- titre
	local obj = CreateFrame("Button", name, parent, "OptionsButtonTemplate")
	obj.base=base
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 8+(posx*11.5), -27-(posy*38))
	obj:SetScript("OnClick", function(self)
		falseEditBox:SetFocus()
		if obj.base[index] then
			obj.base[index]=false
			obj:SetText(textOff)
		else
			obj.base[index]=true
			obj:SetText(textOn)
		end
		if fonction then
			fonction()
		end
	end)
	obj:SetScript("OnShow", function(self)
		if obj.base[index] then
			obj:SetText(textOn)
		else
			obj:SetText(textOff)
		end
	end)
	local fontString = obj:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fontString:SetPoint("LEFT", obj, "RIGHT", 0, 0)
	fontString:SetJustifyH("LEFT")
	fontString:SetText(infos)
	police = fontString:GetFont();fontString:SetFont(police,10)	
end

function DF:options_createConfigButton(parent,name,infos,posx,posy,fonction,args)
	-- titre
	local obj = CreateFrame("Button", name, parent, "OptionsButtonTemplate")
	obj:SetText(DF.locale["config"])
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 8+(posx*11.5), -27-(posy*38))
	obj:SetScript("OnClick", function(self)
		falseEditBox:SetFocus()
		if fonction then
			DF.myArgs=args
			fonction()
		end
	end)
	local fontString = obj:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fontString:SetPoint("LEFT", obj, "RIGHT", 0, 0)
	fontString:SetJustifyH("LEFT")
	fontString:SetText(infos)
	police = fontString:GetFont();fontString:SetFont(police,10)	
end

function DF:options_createTitle(parent,infos)
	-- titre
	local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", parent, "TOP", 0, -4)
	title:SetJustifyH("CENTER")
	title:SetText(string.upper(infos))	
end

function DF:options_createSubTitle(parent,infos,posx,posy)
	-- titre
	local texte = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	texte:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -32-(posy*38))
	texte:SetText(infos)	
end

function DF:options_createText(parent,infos,posx,posy,nblignes)
	-- titre
	local texte = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	texte:SetWidth(390)
	if not nblignes then nblignes=3 end
	texte:SetHeight(nblignes*11)
	texte:SetJustifyH("LEFT")
	texte:SetPoint("TOPLEFT", parent, "TOPLEFT", 8+(posx*11.5), -21-(posy*38))
	texte:SetText(infos)	
	police = texte:GetFont();texte:SetFont(police,10)	
end

function DF:options_createCheckBox(parent,name,base,index,infos,posx,posy,fonction,help)
	 -- Create check button
	local obj = CreateFrame("CHECKBUTTON", name, parent,"OptionsCheckButtonTemplate")
	obj.base=base	
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 8+(posx*11.5), -27-(posy*38))
	obj:SetScript("OnShow", function(self)
	  if self.base then
		  if self.base[index]==true then
		  	self:SetChecked(true)
		  else
		  	self:SetChecked(false)
		  end 
		  obj:EnableMouse(true) 
		  obj:SetAlpha(1)
		else
			obj:EnableMouse(false) 
			obj:SetAlpha(0.5)
		end
	end)	
	obj:SetScript("OnClick", function(self)
		falseEditBox:SetFocus()
		if (self:GetChecked()==1) then
			self.base[index]=true
			if fonction then fonction() end
		else
			self.base[index]=false
			if fonction then fonction() end
		end
	end)
	obj.fontString = obj:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	obj.fontString:SetPoint("LEFT", obj, "RIGHT", 0, 2)
	obj.fontString:SetJustifyH("LEFT")
	obj.fontString:SetText(infos)
	police = obj.fontString:GetFont();obj.fontString:SetFont(police,10)
	
	if help then DF:options_createHelp(obj,obj.fontString,name,help) end
	
end

function DF:options_createHelp(parent,ancre,nom,index)

	if DF.help[index] then
		local pointI= CreateFrame("FRAME",nom.."pointi",parent)
		local pointItexture=pointI:CreateTexture(nil,"BACKGROUND")
		
		pointI.lindex=index
		
		pointI:SetMovable(false)
		pointI:EnableMouse(true)
		pointI:SetWidth(16)
		pointI:SetHeight(16)
		pointI:SetPoint("LEFT", ancre, "RIGHT", 0, -1)
	
		-- paramétres texture
		pointItexture:SetTexCoord(1, 0, 0, 1)
		pointItexture:ClearAllPoints()
		pointItexture:SetAllPoints(pointI)
		pointItexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Up")
		
		pointI:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:ClearLines()
			lignes=DF:explode ( "|", DF.help[self.lindex] )
			for li = 1,getn(lignes) do
				if li==1 then
					GameTooltip:AddLine(lignes[li],1,1,0,nil)
				else
					GameTooltip:AddLine(lignes[li],1,1,1,nil)
				end
			end
			GameTooltip:Show()	
		end)
		pointI:SetScript("OnLeave", function(self)
			GameTooltip:Hide()	
		end)	
	end
	
end

function DF:options_createSlider(parent,name,base,index,mini,maxi,pas,infos,posx,posy,fonction,help)

	local obj = CreateFrame('Slider', name, parent, 'OptionsSliderTemplate')
	obj.base=base
	obj.pas=pas
	obj.mini=mini
	obj.maxi=maxi
	obj:EnableMouseWheel(1)
	obj:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	obj:SetWidth(180)
 	obj:SetHeight(24)
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 12+(posx*11.5), -28-(posy*38))
	obj:SetOrientation('HORIZONTAL')
	getglobal(obj:GetName()..'Low'):SetText(tostring(mini))
	getglobal(obj:GetName()..'High'):SetText(tostring(maxi))
	getglobal(obj:GetName()..'Low'):SetText("")
	getglobal(obj:GetName()..'High'):SetText("")	
	getglobal(obj:GetName() .. 'Text'):SetText(infos)
	getglobal(obj:GetName() .. 'Text'):SetPoint("BOTTOMLEFT", obj, "TOPLEFT", 0, 0)
	
	getglobal(obj:GetName() .. 'Text'):GetFont();getglobal(obj:GetName() .. 'Text'):SetFont(police,10)
	getglobal(obj:GetName() .. 'Low'):GetFont();getglobal(obj:GetName() .. 'Low'):SetFont(police,8)
	getglobal(obj:GetName() .. 'High'):GetFont();getglobal(obj:GetName() .. 'High'):SetFont(police,8)
	
	obj:SetMinMaxValues(mini*100, maxi*100)
	obj:SetValueStep(pas*100)
	if base then
		obj:SetValue(base[index])
	end	
	
	local fontString = obj:CreateFontString(name.."value", "OVERLAY", "GameFontNormalSmall")
	fontString:SetPoint("BOTTOMRIGHT", obj, "TOPRIGHT", 0, 0)
	fontString:SetJustifyH("CENTER")

	obj:SetScript("OnShow", function(self)
	  if self.base then
			value = format("%.2f", self.base[index])
			_G[name.."value"]:SetText(value)
			obj:SetValue(self.base[index]*100)
		  obj:EnableMouse(true) 
		  obj:SetAlpha(1)
		else
			obj:EnableMouse(false) 
			obj:SetAlpha(0.5)
		end
	end)
	obj:SetScript("OnMouseWheel",function(self,delta)
		local offset=self:GetValue()+(delta*(self.pas*100))
		self:SetValue(offset)
	end)	
	obj:SetScript("OnValueChanged", function(self)
		falseEditBox:SetFocus()
		if self.base then
			value = format("%.2f", self:GetValue()/100)
			_G[name.."value"]:SetText(value)
			self.base[index] = self:GetValue()/100
			if fonction then fonction() end
		end
	end)	
	if help then DF:options_createHelp(obj,getglobal(obj:GetName() .. 'Text'),name,help) end
end

function DF:options_returnText(val)
	local texte=""
	if type(val)=="number" then
		if math.floor(val)==val then
			texte=tostring(val)
		else
			texte=DF:doubleNumbers(val)
		end
	else
		texte=tostring(val)
	end
	return texte
end

function DF:options_createEditbox(parent,name,base,index,infos,posx,posy,fonction,large,help)
	local obj = CreateFrame("EditBox", name, parent,"InputBoxTemplate")
	obj.base=base
	obj.fonction =fonction
	obj.currentValue=nil
	if not large then
		obj:SetWidth(160)
	else
		obj:SetWidth(356)
	end
	obj:SetHeight(20)
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 16+(posx*11.5), -30-(posy*38))
	obj:SetAutoFocus(false)
	if base then
		obj:SetText(DF:options_returnText(base[index]))
		obj.currentValue=DF:options_returnText(base[index])
	else
		obj:SetText("")
	end
	obj:SetCursorPosition(0)
	obj:SetFontObject("GameFontNormal")
	obj:IsMultiLine(false)
	obj:SetScript("OnShow", function(self)
			
	  if self.base then
	  	local texte =""
	  	if type(self.base[index])=="table" then
	  		for ind,val in pairs(self.base[index]) do
	  			if texte~="" then texte=texte..";" end
 					texte=texte..DF:options_returnText(val)
				end
				self:SetText(texte)
				self.currentValue=texte
	  	else
	  		self:SetText(DF:options_returnText(self.base[index]))
	  		self.currentValue=DF:options_returnText(self.base[index])
	  	end
	  	self:SetCursorPosition(0)
		  self:EnableMouse(true) 
		  self:SetAlpha(1)
		  self.lebouton:EnableMouse(false) 
		  self.lebouton:SetAlpha(0.5)			
		else
			self:EnableMouse(false) 
			self:SetAlpha(0.5)
		  self.lebouton:EnableMouse(false) 
		  self.lebouton:SetAlpha(0.5)			
		end
		
	end)	
	-- text changé active bouton validation
	obj:SetScript("OnTextChanged", function(self)
	  if obj.currentValue~=self:GetText() then
	  	self.lebouton:EnableMouse(true) 
	  	self.lebouton:SetAlpha(1)			
		end
	end)		

	-- touche entrée pressée, enregistre et désactive bouton validation
	obj:SetScript("OnEnterPressed", function(self)
		if type(self.base[index])=="table" then
			local element=DF:explode ( ";", self:GetText() )
			self.base[index]=table.wipe(self.base[index])
			DF:copyTable(element,self.base[index])
		else
			self.base[index] = self:GetText()
		end
		obj.currentValue=self:GetText()
		self:ClearFocus()
		if fonction then fonction() end
	  self.lebouton:EnableMouse(false) 
	  self.lebouton:SetAlpha(0.5)			
	end)	 
	
	-- perte du focus, place valeur origine et désactive bouton validation
	obj:SetScript("OnEditFocusLost", function(self)
		if self:GetText()~=self.currentValue then
			if type(self.base[index])=="table" then
				local element=DF:explode ( ";", self:GetText() )
				self.base[index]=table.wipe(self.base[index])
				DF:copyTable(element,self.base[index])
			else
				self.base[index] = self:GetText()
			end
			obj.currentValue=self:GetText()
			--self:ClearFocus()
			self:HighlightText(0, 0)
			if fonction then fonction() end
		  self.lebouton:EnableMouse(false) 
		  self.lebouton:SetAlpha(0.5)		
		end
	end)	 	

	-- touche ESC, place valeur origine et désactive bouton validation
	obj:SetScript("OnEscapePressed", function(self)
		self:SetText(DF:options_returnText(obj.currentValue))
		self.lebouton:EnableMouse(false) 
	  self.lebouton:SetAlpha(0.5)			
		self:ClearFocus()
	end)	
	
	-- intitulé
	obj.fontString = obj:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	obj.fontString:SetPoint("BOTTOMLEFT", obj, "TOPLEFT", 0, 2)
	obj.fontString:SetJustifyH("LEFT")
	obj.fontString:SetText(infos)
	police = obj.fontString:GetFont();obj.fontString:SetFont(police,10)
	
	-- création du bouton validation
	local button = CreateFrame("Button", name.."_buttonok", obj, "OptionsButtonTemplate")
	button.parent=obj	-- pointeur vers le parent
	button:SetText("OK")
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetPoint("TOPLEFT", obj, "TOPRIGHT", 0, 0)
	local fontString = button:GetFontString()
	police = fontString:GetFont();fontString:SetFont(police,10)
	
	-- bouton OK préssé, enregistre et désavtive le bouton
	button:SetScript("OnClick", function(self)
		if type(self.parent.base[index])=="table" then
			local element=DF:explode ( ";", self.parent:GetText() )
			self.parent.base[index]=table.wipe(self.parent.base[index])
			DF:copyTable(element,self.parent.base[index])
		else
			self.parent.base[index] = self.parent:GetText()
		end
		self.parent.currentValue=self.parent:GetText()
	  self:EnableMouse(false) 
	  self:SetAlpha(0.5)	
	  self.parent:ClearFocus()		
		if self.parent.fonction then self.parent.fonction() end
	end)	 	
  button:EnableMouse(false) 
  button:SetAlpha(0.5)
	  			
	-- pointeur vers le bouton
	obj.lebouton=button
	if help then DF:options_createHelp(obj,obj.fontString,name,help) end
end

function DF:options_createColorBox(parent,name,base,index,infos,posx,posy,fonction,help)
	
	local obj = CreateFrame("FRAME", name, parent)
	local overlay = CreateFrame("FRAME", name.."border", parent, BackdropTemplateMixin and "BackdropTemplate" or nil)

	obj.base=base
	obj:EnableMouse(true)
	obj:SetHeight(12)
	obj:SetWidth(14)
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 14+(posx*11.5), -34-(posy*38))
	
	obj.texture=obj:CreateTexture(name.."text")
	obj.texture:SetAllPoints(obj)
	obj.text = obj:CreateFontString(name.."text", "OVERLAY", "GameFontHighlight")
	obj.text:SetText(infos)
	obj.text:SetPoint("LEFT", obj, "RIGHT", 6, 0)
	police = obj.text:GetFont();obj.text:SetFont(police,10)
	obj:SetFrameLevel(2)
	obj:EnableMouse(true)

	obj:SetScript("OnShow", function(self)
		if self.base then
			obj.texture:SetTexture(self.base[index].r,self.base[index].v,self.base[index].b,self.base[index].a)
			obj:EnableMouse(true)
			overlay:SetAlpha(1)
			obj:SetAlpha(1)
		else
			obj.texture:SetTexture(0,0,0,1)
			obj:EnableMouse(false)
			overlay:SetAlpha(0.5)
			obj:SetAlpha(0.5)
		end
	end)
	obj:SetScript("OnMouseUp",function(self)
		falseEditBox:SetFocus()
		ColorPickerFrame.func=nil
		ColorPickerFrame.opacityFunc=nil
		ColorPickerFrame.cancelFunc=nil
		ColorPickerFrame.hasOpacity=true
			ColorPickerFrame.opacity = 1-self.base[index].a
		ColorPickerFrame.previousValues = {self.base[index].r,self.base[index].v,self.base[index].b,self.base[index].a};
		ColorPickerFrame:SetColorRGB(self.base[index].r,self.base[index].v,self.base[index].b,self.base[index].a)
		ColorPickerFrame.func = function()
			local R,G,B = ColorPickerFrame:GetColorRGB()
			local A = 1-OpacitySliderFrame:GetValue()
			self.base[index].r=R
			self.base[index].v=G
			self.base[index].b=B
			self.base[index].a=A
			obj.texture:SetTexture(self.base[index].r,self.base[index].v,self.base[index].b,self.base[index].a)
			if fonction then fonction() end
		end	
		
		ColorPickerFrame.opacityFunc = function()
			local R,G,B = ColorPickerFrame:GetColorRGB()
			local A = 1-OpacitySliderFrame:GetValue()
			self.base[index].r=R
			self.base[index].v=G
			self.base[index].b=B
			self.base[index].a=A
			obj.texture:SetTexture(self.base[index].r,self.base[index].v,self.base[index].b,self.base[index].a)
			if fonction then fonction() end
		end	
		
		ColorPickerFrame.cancelFunc = function()
			self.base[index].r=ColorPickerFrame.previousValues[1]
			self.base[index].v=ColorPickerFrame.previousValues[2]
			self.base[index].b=ColorPickerFrame.previousValues[3]
			self.base[index].a=ColorPickerFrame.previousValues[4]
			obj.texture:SetTexture(self.base[index].r,self.base[index].v,self.base[index].b,self.base[index].a)
			if fonction then fonction() end
		end	

		ColorPickerFrame:Show()

	end)		
		
	overlay:SetBackdrop({ bgFile = nil, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 8, edgeSize =8, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
	overlay:SetHeight(18)
	overlay:SetWidth(20)
	overlay:SetPoint("CENTER", obj, "CENTER", 0, 0)
	overlay:SetFrameLevel(1)
	overlay:EnableMouse(false)
	if help then DF:options_createHelp(obj,obj.text,name,help) end
end

function DF:options_createBox(parent,name,posx,posy,bwidth,bheight)
	local obj = CreateFrame('Frame', name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	obj:SetWidth(bwidth)
 	obj:SetHeight(bheight)
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", posx, posy)
	obj:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	obj:SetBackdropColor(0,0,0,1);
end

function DF:options_DebuffList_click(newPt)
	
	DF:options_chgBase("DFSPELLOPT_ids",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_positionx",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_positiony",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_width",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_height",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_sType",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_perso",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_combo",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_icon",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_timerbar",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_color",DF_config.spells[newPt])
--	DF:options_chgBase("DFSPELLOPT_getUptime",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_spellslist",DF)
	DF:options_chgBase("DFSPELLOPT_usertext",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_always",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_form0",DF_config.spells[newPt].form)
	DF:options_chgBase("DFSPELLOPT_form1",DF_config.spells[newPt].form)
	DF:options_chgBase("DFSPELLOPT_form2",DF_config.spells[newPt].form)
	DF:options_chgBase("DFSPELLOPT_form3",DF_config.spells[newPt].form)
	DF:options_chgBase("DFSPELLOPT_form4",DF_config.spells[newPt].form)
	DF:options_chgBase("DFSPELLOPT_form5",DF_config.spells[newPt].form)
	DF:options_chgBase("DFSPELLOPT_form6",DF_config.spells[newPt].form)
	DF:options_chgBase("DFSPELLOPT_strong",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_icd",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_sound",DF_config.spells[newPt])
	DF:options_chgBase("DFSPELLOPT_showcd",DF_config.spells[newPt])

	_G["DFSPELLOPT_up"]:Enable()
	_G["DFSPELLOPT_down"]:Enable()
	_G["DFSPELLOPT_kill"]:Enable()

	if DF_config.spells[newPt].abiLastCd>0 then
		
	end

end

function DF:options_DebuffList_create(parent)

	contener=_G["DFspellsbox"]

	for i = 1,nbLines do

		debuffListButton[i] = CreateFrame("Button", nil, contener)
		debuffListButton[i]:SetPoint("TOPLEFT", contener, "TOPLEFT", 4, -5-((i-1)*17))
		debuffListButton[i]:SetWidth(362)
		debuffListButton[i]:SetHeight(16)
		debuffListButton[i]:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
		debuffListButton[i]:SetNormalTexture(nil)
		debuffListButton[i]:SetPushedTexture(nil)
		letext = debuffListButton[i]:CreateFontString("debuffListButton"..tostring(i).."Text", "ARTWORK")
		letext:SetFontObject(GameFontNormal)
		police = letext:GetFont();letext:SetFont(police,10)	
		letext:SetText("button "..tostring(i))
		letext:Show()
		letext:ClearAllPoints()
		letext:SetTextColor(1,1,1,1)
		letext:SetPoint("LEFT", debuffListButton[i], "LEFT", 2, 0)
		debuffListButton[i]:SetScript("OnClick", function(self)
			selectPt=(i+currentPosition)-1
			DF:options_DebuffList_populate()
			DF:options_DebuffList_click(selectPt)
		end);		
	end
	
	local obj = CreateFrame('Slider', "DFdebufflistContenerSlider", parent, 'OptionsSliderTemplate')
	obj:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
	obj:SetWidth(20)
 	obj:SetHeight((8*17)+8)
 	obj:EnableMouse(true)
	obj:SetPoint("RIGHT", contener, "RIGHT", -4, 0);
	obj:SetOrientation('VERTICAL')
	getglobal(obj:GetName() .. 'Low'):SetText("");
	getglobal(obj:GetName() .. 'High'):SetText(""); 
	getglobal(obj:GetName() .. 'Text'):SetText("");
	obj:SetMinMaxValues(1, 1);
	obj:SetValueStep(1);
	obj:SetValue(1);
	obj:SetScript("OnValueChanged", function(self)
		currentPosition = self:GetValue();
		DF:options_DebuffList_populate();		
	end);
	obj:SetFrameLevel(5)
	contener:SetScript("OnShow", function(self)
		DF:options_DebuffList_populate();	
	end)		
	
end

function DF:options_DebuffList_populate()

	local maxi = getn(DF_config.spells)
	local smaxi =  maxi-(nbLines-1)
	
	local reel=0
	local textPt=nil
	if (smaxi<1) then
		smaxi=1
	end
	
	if smaxi==1 then
			_G["DFdebufflistContenerSlider"]:Hide()
			_G["DFspellsbox"]:EnableMouseWheel(false)

	else
		_G["DFdebufflistContenerSlider"]:SetMinMaxValues(1, smaxi)
		_G["DFdebufflistContenerSlider"]:Show()
		_G["DFspellsbox"]:EnableMouseWheel(true)

	end
	
	for i = 0,nbLines-1 do
	
		reel = currentPosition+i;
		
		textPt = _G["debuffListButton"..tostring(i+1).."Text"];
		textPt:SetText("");
		debuffListButton[i+1].sonnum=nil
		
		if (reel<=maxi) then
			debuffListButton[i+1].sonnum=reel
			if (DF_config.spells[reel].ids[1]==0 or not DF_config.spells[reel].names[1]) then
				textPt:SetText(tostring(reel).." - ".."NEW")
			else
				if DF_config.spells[reel].abiUserText=="" then
					textPt:SetText(tostring(reel).." - "..DF_config.spells[reel].names[1])
				else
					textPt:SetText(tostring(reel).." - "..DF_config.spells[reel].abiUserText)
				end
			end
			
			if (selectPt==reel) then
				debuffListButton[i+1]:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
				debuffListButton[i+1]:SetNormalTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
				debuffListButton[i+1]:SetPushedTexture(nil)
--				textPt:SetTextColor(1,1,0,1);	
			else
				debuffListButton[i+1]:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
				debuffListButton[i+1]:SetNormalTexture(nil)
				debuffListButton[i+1]:SetPushedTexture(nil)
--				textPt:SetTextColor(1,1,1,1);	
			end

			debuffListButton[i+1]:SetScript("OnEnter",function(self)
				if self.sonnum then
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",-20,20)
					GameTooltip:ClearLines()
					GameTooltip:AddLine(DF.locale["spells"],1,1,0,nil)
					for li = 1,getn(DF_config.spells[self.sonnum].names) do
						GameTooltip:AddLine("   "..DF_config.spells[self.sonnum].names[li].." ["..tostring(DF_config.spells[self.sonnum].ids[li]).."]",1,1,1,nil)
					end
					if DF_config.spells[self.sonnum].abiLastCd>0 then
						GameTooltip:AddLine("   Calculated InternalCD: "..DF:doubleNumbers(DF_config.spells[self.sonnum].abiLastCd),1,1,1,nil)
					end
					GameTooltip:Show()	
				end
			end);
			debuffListButton[i+1]:SetScript("OnLeave",function(self)
				if self.sonnum then GameTooltip:Hide() end
			end);						
			debuffListButton[i+1]:Show();
			
		else
			
			debuffListButton[i+1]:SetScript("OnEnter", nil)
			debuffListButton[i+1]:SetScript("OnLeave", nil)
			debuffListButton[i+1]:Hide();
			
		end
	
	end
	
end

function DF:options_createListbox(parent,name,base,index,infos,posx,posy,fonction,optionsList,large,help)
	
	-- list des menu créés
	if not dropdownlist then dropdownlist={} end
		
	local largeur=156
	if not large then
		largeur=156
	else
		largeur=348
	end
	local nbLines=getn(optionsList)
	local maxNbLines=nbLines
	if maxNbLines>20 then maxNbLines=20 end
	local smaxi = getn(optionsList)-19

	local obj = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
	obj.base=base
	obj.laliste=optionsList
	obj:SetWidth(largeur)
	obj:SetHeight(20)
	obj:SetPoint("TOPLEFT", parent, "TOPLEFT", 16+(posx*11.5), -30-(posy*38))
	obj:SetAutoFocus(false)
	obj:SetText("")
	obj:SetCursorPosition(0)
	obj:SetFontObject("GameFontNormal")
	obj:IsMultiLine(false)
	obj:SetScript("OnShow", function(self)
		self:SetText("")
		-- retrouve le texte correspondant a la valeur et l'affiche
		if self.base then
			if self.base[index] then
				for k,v in pairs(obj.laliste) do
					if self.laliste[k].valeur==self.base[index] then
						self:SetText(tostring(self.laliste[k].texte))
						break
					end
				end
			end
			self:SetAlpha(1)
			self.lebouton:EnableMouse(true)
		else
			self:SetAlpha(0.5)
			self.lebouton:EnableMouse(false)
		end
		self:SetCursorPosition(0)
	end)	
	obj:EnableMouse(false)

	obj.fontString = obj:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	obj.fontString:SetPoint("BOTTOMLEFT", obj, "TOPLEFT", 0, 2)
	obj.fontString:SetJustifyH("LEFT")
	obj.fontString:SetText(infos)
	police = obj.fontString:GetFont();obj.fontString:SetFont(police,10)

	-- création du menu
	local menu = CreateFrame("FRAME", name.."menudropdown", parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	menu.obj=obj
	menu.slide=nil
	menu.optionsList=optionsList
	menu.isvisible=false
	menu.index=index
	menu.maxNbLines=maxNbLines
	menu.offset=1
	menu.items={}
	menu:SetMovable(false)
	menu:ClearAllPoints()
	menu:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
	menu:SetHeight(((nbLines+1)*17)-8)
	menu:SetWidth(260)
	menu:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", -6, 4);
	menu:SetFrameStrata("FULLSCREEN_DIALOG");
	menu:Hide();
	menu:SetBackdropColor(0,0,0,1);
	menu:EnableMouse(true)
	menu:EnableMouseWheel(true)
	menu:SetScript("OnMouseWheel",function(self,delta)
		if menu.slide then
			local offset=menu.slide:GetValue()+(delta*-3)
			menu.slide:SetValue(offset)
		end
	end)
	
	-- register menu
	table.insert(dropdownlist,name.."menudropdown")

	-- créé ligne du menu
	for i = 1,20 do
		menu.items[i] = CreateFrame("Button", nil, menu)
		menu.items[i]:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -5-((i-1)*17))
		menu.items[i]:SetWidth(230)
		menu.items[i]:SetHeight(16)
		menu.items[i]:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
		menu.items[i]:SetNormalTexture(nil)
		menu.items[i]:SetPushedTexture(nil)
		menu.items[i].parent=menu
		menu.items[i].letext = menu.items[i]:CreateFontString("menuitems"..tostring(i).."Text", "ARTWORK")
		menu.items[i].letext:SetFontObject(GameFontNormal)
		menu.items[i].letext:SetWidth(230)
		menu.items[i].letext:SetJustifyH("LEFT")
		police = menu.items[i].letext:GetFont();menu.items[i].letext:SetFont(police,10)	
		menu.items[i].lafont=police
		
		if i<=maxNbLines then
			menu.items[i].letext:SetText(optionsList[i].texte)
			menu.items[i].letext:Show()
			menu.items[i]:Show()
		else
			menu.items[i].letext:SetText("")
			menu.items[i]:Hide()
		end

		menu.items[i].letext:ClearAllPoints()
		menu.items[i].letext:SetTextColor(1,1,1,1)
		menu.items[i].letext:SetPoint("LEFT", menu.items[i], "LEFT", 2, 0)
		menu.items[i]:SetScript("OnClick", function(self)
			local click=menu.offset+(i-1)
			menu.obj.base[menu.index]=optionsList[click].valeur
			menu.obj:SetText(tostring(optionsList[click].texte))
			menu.obj:SetCursorPosition(0)
			menu:Hide()
			menu.items[i].parent.isvisible=false
			if fonction then fonction() end
		end);		

	end   

	menu.redraw = function(pointeur)
		local nbLines=getn(pointeur.optionsList)
		for i = 1,20 do
			local toshow=pointeur.offset+(i-1)
			if toshow<=nbLines then
				
				if pointeur.optionsList[toshow].form=="statusbar" then
					pointeur.items[i]:SetNormalTexture(pointeur.optionsList[toshow].valeur)
				else
					pointeur.items[i]:SetNormalTexture(nil)
				end
				if pointeur.optionsList[toshow].form=="font" then
					pointeur.items[i].letext:SetFont(pointeur.optionsList[toshow].valeur,10)
				else
					pointeur.items[i].letext:SetFont(pointeur.items[i].lafont,10)
				end				
				
				pointeur.items[i].letext:SetText(pointeur.optionsList[toshow].texte)
				pointeur.items[i].letext:Show()
				pointeur.items[i]:Show()
				
				if pointeur.optionsList[toshow].form=="background" then
					pointeur.items[i]:SetScript("OnEnter",function(self)
						
						apercutexture:ClearAllPoints()
						apercutexture:SetPoint("TOPLEFT", self.parent, "TOPRIGHT", 0, 0)	
						apercutexture_texture:SetTexture(pointeur.optionsList[toshow].valeur)
						apercutexture:Show()

					end);
					pointeur.items[i]:SetScript("OnLeave",function(self)
						apercutexture:Hide()
					end);						
				end
			
			else
				pointeur.items[i].letext:SetText("")
				pointeur.items[i]:Hide()
			end			
		end		
	end

	-- a l'affichage, rafraichir le contenu
	menu:SetScript("OnShow",function(self)
		self.redraw(self)
	end)
	
	-- si contenu plus grand que affichage, créé un slider
	if smaxi>1 then
		local slide = CreateFrame('Slider', name.."Slider", menu, 'OptionsSliderTemplate')
		slide.parent=menu
		slide.parent.slide=slide
		slide:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		slide:SetWidth(20)
	 	slide:SetHeight((maxNbLines*17)+6)
	 	slide:EnableMouse(true)
		slide:SetPoint("RIGHT", menu, "RIGHT", -4, 0)
		slide:SetOrientation('VERTICAL')
		getglobal(slide:GetName() .. 'Low'):SetText("")
		getglobal(slide:GetName() .. 'High'):SetText("");
		getglobal(slide:GetName() .. 'Text'):SetText("")
		slide:SetMinMaxValues(1, smaxi)
		slide:SetValueStep(1)
		slide:SetValue(1)
		slide:SetScript("OnValueChanged", function(self)
			self.parent.offset = self:GetValue()
			self.parent.redraw(self.parent)
		end);	
	end
	
	-- création du bouton pour afficher le menu
	local button = CreateFrame("Button", name.."_button", obj, "OptionsButtonTemplate")
	button.lemenu=menu
	button.name=name
	button:SetText("=")
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetPoint("TOPLEFT", obj, "TOPRIGHT", 2, 0)
	local fontString = button:GetFontString()
	police = fontString:GetFont();fontString:SetFont(police,10)
	button:SetScript("OnClick", function(self)
		falseEditBox:SetFocus()
		local nbLines=getn(button.lemenu.optionsList)
		if nbLines>20 then nbLines=20 end
		if nbLines==0 then nbLines=1 end
		button.lemenu:SetHeight(((nbLines+1)*17)-8)
		for k,v in pairs(dropdownlist) do
			if v~=self.name.."menudropdown" then
				_G[v]:Hide()
				_G[v].isvisible=false
			end
		end
		
		if self.lemenu.isvisible then
			self.lemenu:Hide()
			self.lemenu.isvisible=false
		else
			self.lemenu:Show()
			self.lemenu.isvisible=true
		end
	end)	 
	
	obj.lebouton=button
	if help then DF:options_createHelp(obj,obj.fontString,name,help) end
end

function DF:options_testMedia()

	local ftype=options_sharemedia.ftype
	local fpath=options_sharemedia.fpath
	local fname=options_sharemedia.fname

	local mediaValide=false
	local oldMedia=nil
	
	shareMediaTexture:SetTexture(nil)
	shareMediaFont:SetFont("Interface\\AddOns\\DroodFocus\\datas\\font.ttf",14)
	
	if ftype~="" and fpath~="" and fname~="" then

		if ftype=="statusbar" or ftype=="background" then

			shareMediaTexture:SetTexture(fpath)
			if shareMediaFrame.texture:GetTexture() then
				mediaValide=true
			end
				
		elseif ftype=="font" then
			
			shareMediaFont:SetFont(fpath,14)

			if shareMediaFont:GetFont()~="Interface\\AddOns\\DroodFocus\\datas\\font.ttf" then
				mediaValide=true
			end
			
		end

	end

	if not mediaValide then
		StaticPopup_Show ("MEDIAERREUR","Media invalid")
	else
		if DF.myArgs=="add" then
			
			fetch=DF.LSM:Fetch("background", fname)
			if fetch then
				StaticPopup_Show ("MEDIAERREUR","Media already exist")
			else
				DF:libs_saveNewFile(ftype,fname,fpath)
				StaticPopup_Show ("MEDIAERREUR","Media added")
			end
			
		end
	end
	
end