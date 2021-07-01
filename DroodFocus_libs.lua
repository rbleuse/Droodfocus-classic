----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - Libs
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

DF.LSM = LibStub("LibSharedMedia-3.0")

DF.LSM:Register("font", "DF Font Normal",[[Interface\AddOns\DroodFocus\datas\font.ttf]])
DF.LSM:Register("font", "DF Font Digital",[[Interface\AddOns\DroodFocus\datas\font_digital.ttf]])
DF.LSM:Register("font", "DF Font Typewriter",[[Interface\AddOns\DroodFocus\datas\font_typewriter.ttf]])

DF.LSM:Register("statusbar", "DF Statusbar 1",[[Interface\AddOns\DroodFocus\datas\statusbar.tga]])
DF.LSM:Register("statusbar", "DF Statusbar 2",[[Interface\AddOns\DroodFocus\datas\statusbar2.tga]])
DF.LSM:Register("statusbar", "DF Statusbar 3",[[Interface\AddOns\DroodFocus\datas\statusbar3.tga]])
DF.LSM:Register("statusbar", "DF Statusbar 4",[[Interface\AddOns\DroodFocus\datas\statusbar4.tga]])

DF.LSM:Register("background", "DF Blood 1", [[Interface\AddOns\DroodFocus\datas\blood1.tga]])
DF.LSM:Register("background", "DF Blood 2", [[Interface\AddOns\DroodFocus\datas\blood2.tga]])
DF.LSM:Register("background", "DF Blood 3", [[Interface\AddOns\DroodFocus\datas\blood3.tga]])
DF.LSM:Register("background", "DF Icon Behind", [[Interface\AddOns\DroodFocus\datas\alertBehind.tga]])
DF.LSM:Register("background", "DF Icon OutOfRange", [[Interface\AddOns\DroodFocus\datas\alertRange.tga]])
DF.LSM:Register("background", "DF icon Aggro", [[Interface\AddOns\DroodFocus\datas\alertSkull.tga]])
DF.LSM:Register("background", "DF icon Warning", [[Interface\AddOns\DroodFocus\datas\alertWarning.tga]])
DF.LSM:Register("background", "DF Combo 1", [[Interface\AddOns\DroodFocus\datas\combo.tga]])
DF.LSM:Register("background", "DF Combo 2", [[Interface\AddOns\DroodFocus\datas\combo2.tga]])
DF.LSM:Register("background", "DF Runes 1", [[Interface\AddOns\DroodFocus\datas\runes.tga]])
DF.LSM:Register("background", "DF Flash 1", [[Interface\AddOns\DroodFocus\datas\ooc.tga]])
DF.LSM:Register("background", "DF Flash 2", [[Interface\AddOns\DroodFocus\datas\ooc2.tga]])
DF.LSM:Register("background", "DF UI 1", [[Interface\AddOns\DroodFocus\datas\UI_texture1.tga]])
DF.LSM:Register("background", "DF UI 2", [[Interface\AddOns\DroodFocus\datas\UI_texture2.tga]])
DF.LSM:Register("background", "DF Form humanoïd", [[Interface\AddOns\DroodFocus\datas\noform.tga]])
DF.LSM:Register("background", "DF Form Bear", [[Interface\AddOns\DroodFocus\datas\bearform.tga]])
DF.LSM:Register("background", "DF Form Cat", [[Interface\AddOns\DroodFocus\datas\catform.tga]])
DF.LSM:Register("background", "DF Form Flight", [[Interface\AddOns\DroodFocus\datas\flightform.tga]])
DF.LSM:Register("background", "DF Form Moonkin", [[Interface\AddOns\DroodFocus\datas\moonkinform.tga]])
DF.LSM:Register("background", "DF Form Travel", [[Interface\AddOns\DroodFocus\datas\travelform.tga]])
DF.LSM:Register("background", "DF Form Tree", [[Interface\AddOns\DroodFocus\datas\treeform.tga]])
DF.LSM:Register("background", "DF Form Aquatic", [[Interface\AddOns\DroodFocus\datas\aquaform.tga]])

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





 