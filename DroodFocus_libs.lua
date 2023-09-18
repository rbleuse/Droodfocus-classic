----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - Libs
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

DF.LSM = LibStub("LibSharedMedia-3.0")

DF.LSM:Register("font", "DF Font Normal",[[Interface\AddOns\Droodfocus-classic\datas\font.ttf]])
DF.LSM:Register("font", "DF Font Texte",[[Interface\AddOns\Droodfocus-classic\datas\font_text.ttf]])
DF.LSM:Register("font", "DF Font Digital",[[Interface\AddOns\Droodfocus-classic\datas\font_digital.ttf]])
DF.LSM:Register("font", "DF Font Typewriter",[[Interface\AddOns\Droodfocus-classic\datas\font_typewriter.ttf]])
DF.LSM:Register("font", "DF Font Unispace",[[Interface\AddOns\Droodfocus-classic\datas\font_unispace.ttf]])

DF.LSM:Register("statusbar", "DF Statusbar 1",[[Interface\AddOns\Droodfocus-classic\datas\statusbar.tga]])
DF.LSM:Register("statusbar", "DF Statusbar 2",[[Interface\AddOns\Droodfocus-classic\datas\statusbar2.tga]])
DF.LSM:Register("statusbar", "DF Statusbar 3",[[Interface\AddOns\Droodfocus-classic\datas\statusbar3.tga]])
DF.LSM:Register("statusbar", "DF Statusbar 4",[[Interface\AddOns\Droodfocus-classic\datas\statusbar4.tga]])
DF.LSM:Register("statusbar", "DF Statusbar 5",[[Interface\AddOns\Droodfocus-classic\datas\statusbar5.tga]])

DF.LSM:Register("background", "DF Blood 1", [[Interface\AddOns\Droodfocus-classic\datas\blood1.tga]])
DF.LSM:Register("background", "DF Blood 2", [[Interface\AddOns\Droodfocus-classic\datas\blood2.tga]])
DF.LSM:Register("background", "DF Blood 3", [[Interface\AddOns\Droodfocus-classic\datas\blood3.tga]])
DF.LSM:Register("background", "DF Icon Behind", [[Interface\AddOns\Droodfocus-classic\datas\alertBehind.tga]])
DF.LSM:Register("background", "DF Icon OutOfRange", [[Interface\AddOns\Droodfocus-classic\datas\alertRange.tga]])
DF.LSM:Register("background", "DF icon Aggro", [[Interface\AddOns\Droodfocus-classic\datas\alertSkull.tga]])
DF.LSM:Register("background", "DF icon Warning", [[Interface\AddOns\Droodfocus-classic\datas\alertWarning.tga]])
DF.LSM:Register("background", "DF Combo: Bear", [[Interface\AddOns\Droodfocus-classic\custom\combo_bear.tga]])
DF.LSM:Register("background", "DF Combo: Blue", [[Interface\AddOns\Droodfocus-classic\custom\combo_blue.tga]])
DF.LSM:Register("background", "DF Combo: Close eye", [[Interface\AddOns\Droodfocus-classic\custom\combo_closeEye.tga]])
DF.LSM:Register("background", "DF Combo: Gray", [[Interface\AddOns\Droodfocus-classic\custom\combo_gray.tga]])
DF.LSM:Register("background", "DF Combo: Black", [[Interface\AddOns\Droodfocus-classic\custom\combo_black.tga]])
DF.LSM:Register("background", "DF Combo: Gray square", [[Interface\AddOns\Droodfocus-classic\custom\combo_square_gray.tga]])
DF.LSM:Register("background", "DF Combo: Green", [[Interface\AddOns\Droodfocus-classic\custom\combo_green.tga]])
DF.LSM:Register("background", "DF Combo: Holy", [[Interface\AddOns\Droodfocus-classic\custom\combo_holy.tga]])
DF.LSM:Register("background", "DF Combo: Open eye", [[Interface\AddOns\Droodfocus-classic\custom\combo_openEye.tga]])
DF.LSM:Register("background", "DF Combo: Red", [[Interface\AddOns\Droodfocus-classic\custom\combo_red.tga]])
DF.LSM:Register("background", "DF Combo: Red square", [[Interface\AddOns\Droodfocus-classic\custom\combo_square_red.tga]])
DF.LSM:Register("background", "DF Combo: Yellow", [[Interface\AddOns\Droodfocus-classic\custom\combo_yellow.tga]])
DF.LSM:Register("background", "DF Combo: Yellow square", [[Interface\AddOns\Droodfocus-classic\custom\combo_square_yellow.tga]])
DF.LSM:Register("background", "DF Combo: Ying", [[Interface\AddOns\Droodfocus-classic\custom\ying.tga]])
DF.LSM:Register("background", "DF Combo: Yang", [[Interface\AddOns\Droodfocus-classic\custom\yang.tga]])
DF.LSM:Register("background", "DF Defense 2: Active", [[Interface\AddOns\Droodfocus-classic\custom\savage_on.tga]])
DF.LSM:Register("background", "DF Defense 2: Inactive", [[Interface\AddOns\Droodfocus-classic\custom\savage_off.tga]])
DF.LSM:Register("background", "DF Defense 2: No rage", [[Interface\AddOns\Droodfocus-classic\custom\savage_norage.tga]])
DF.LSM:Register("background", "DF UI 1", [[Interface\AddOns\Droodfocus-classic\datas\UI_texture1.tga]])
DF.LSM:Register("background", "DF UI 2", [[Interface\AddOns\Droodfocus-classic\datas\UI_texture2.tga]])
DF.LSM:Register("background", "DF Form humanoïd", [[Interface\AddOns\Droodfocus-classic\datas\noform.tga]])
DF.LSM:Register("background", "DF Form Bear", [[Interface\AddOns\Droodfocus-classic\datas\bearform.tga]])
DF.LSM:Register("background", "DF Form Cat", [[Interface\AddOns\Droodfocus-classic\datas\catform.tga]])
DF.LSM:Register("background", "DF Form Flight", [[Interface\AddOns\Droodfocus-classic\datas\flightform.tga]])
DF.LSM:Register("background", "DF Form Moonkin", [[Interface\AddOns\Droodfocus-classic\datas\moonkinform.tga]])
DF.LSM:Register("background", "DF Form Travel", [[Interface\AddOns\Droodfocus-classic\datas\travelform.tga]])
DF.LSM:Register("background", "DF Form Tree", [[Interface\AddOns\Droodfocus-classic\datas\treeform.tga]])
DF.LSM:Register("background", "DF Form Aquatic", [[Interface\AddOns\Droodfocus-classic\datas\aquaform.tga]])
DF.LSM:Register("background", "DF Frency: Active", [[Interface\AddOns\Droodfocus-classic\datas\frenzy_active.tga]])
DF.LSM:Register("background", "DF Frency: Inactive", [[Interface\AddOns\Droodfocus-classic\datas\frenzy_inactive.tga]])
DF.LSM:Register("background", "DF Frency: No rage", [[Interface\AddOns\Droodfocus-classic\datas\frenzy_norage.tga]])

DF.LSM:Register("sound", "DF Cat roar",[[Sound\Spells\Druid_FeralCharge.wav]])
DF.LSM:Register("sound", "DF Bear roar",[[Sound\Spells\Druid_Pounce.wav]])
DF.LSM:Register("sound", "DF Chicken",[[Sound\Character\BloodElf\BloodElfMaleChicken01.wav]])
DF.LSM:Register("sound", "DF Bell 1",[[Sound\Event Sounds\Wisp\WispYes1.wav]])
DF.LSM:Register("sound", "DF Bell 2",[[Sound\Spells\DirectDamage\HolyImpactDDHigh.wav]])
DF.LSM:Register("sound", "DF Bell 3",[[Sound\Spells\Tradeskills\FishReelIn.wav]])
DF.LSM:Register("sound", "DF Cower",[[Sound\Spells\Cower.wav]])
DF.LSM:Register("sound", "DF BellToll Alliance",[[Sound\Doodad\BellTollAlliance.wav]])
DF.LSM:Register("sound", "DF BellToll Horde",[[Sound\Doodad\BellTollHorde.wav]])
DF.LSM:Register("sound", "DF BellToll NightElf",[[Sound\Doodad\BellTollNightElf.wav]])
DF.LSM:Register("sound", "DF BellToll Tribal",[[Sound\Doodad\BellTollTribal.wav]])


function DF:libs_AddFile(ftype,fname,fpath)
	DF.LSM:Register(ftype, fname, fpath)
end

function DF:libs_registerUsersFiles()
	for k,_ in pairs(DF_sharemedia) do
		DF.LSM:Register(DF_sharemedia[k].ftype, k, DF_sharemedia[k].fpath)
	end
end

function DF:libs_saveNewFile(ftype,fname,fpath)
	fpath=fpath:gsub("\\\\", "\\")
	fpath=fpath:sub(2)

	DF_sharemedia[fname]={["ftype"]=ftype,["fpath"]=fpath}
	DF:libs_registerUsersFiles()

	DF:options_ShareMediaLists()
end
