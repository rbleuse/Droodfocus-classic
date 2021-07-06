----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - form
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

-- Player shapeshift
-- 0: human, 1: bear, 2: aquatic, 3: cat, 4: travel, 5: moonkin(balance)/flight(resto/feral/guardian), 6: flight(balance)/tree(resto)
function DF:currentForm()

	-- determiner si féral
	-- le cas échéant si la forme == 5, retourner 6
	local nbform = GetNumShapeshiftForms()
	local form = GetShapeshiftForm(true)

	if nbform == 5 and form == 5 then form = 6 end
	return form
end

function DF:form_goofForm(list,test)
	return list[test+1]
end

function DF:form_initStanceList()
	if DF.playerClass=="DRUID" then
		DF.locale["form1"]="Bear/Dire Bear Form"
		DF.locale["form2"]="Aquatic Form"
		DF.locale["form3"]="Cat Form"
		DF.locale["form4"]="Travel Form"
		DF.locale["form5"]="Moonkin/Tree Form"
		DF.locale["form6"]="Flight Form"
	elseif DF.playerClass=="PRIEST" then
		DF.locale["form1"]="Shadowform"
	elseif DF.playerClass=="ROGUE" then
		DF.locale["form1"]="Stealth"
		DF.locale["form3"]="Shadow Dance"
	elseif DF.playerClass=="WARRIOR" then
		DF.locale["form1"]="Battle Stance"
		DF.locale["form2"]="Defensive Stance"
		DF.locale["form3"]="Berserker Stance"
	end
end
