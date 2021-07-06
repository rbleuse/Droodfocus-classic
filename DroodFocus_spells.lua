----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - spells
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

-- initialisation liste
function DF:init_spells_list()
	local nbSpells = getn(DF_config.spells)

	for i = 1, nbSpells do
		-- init variables
		DF_config.spells[i].abiOldTimeLeft=0
		DF_config.spells[i].abiStack=0
		DF_config.spells[i].abiTimeLeft=0
		DF_config.spells[i].abiDuration=0
		DF_config.spells[i].abiAlphaPulse=0
		DF_config.spells[i].abiCD=0
		DF_config.spells[i].abiPower={}
		DF_config.spells[i].abiEnd=0
		DF_config.spells[i].abiStart=0

		DF_config.spells[i].abiLast=0

		if DF_config.spells[i].abiLastCd==nil then
			DF_config.spells[i].abiLastCd=0
		end

		DF_config.spells[i][""]=nil

		--
		-- nouvelles variables a créer
		--
		if DF_config.spells[i].strongcheck==nil then
			DF_config.spells[i].strongcheck=false
		end

		if DF_config.spells[i].showcd==nil then
			DF_config.spells[i].showcd=true
		end

		if DF_config.spells[i].abiInternalCD==nil then
			DF_config.spells[i].abiInternalCD=0
		end

		if DF_config.spells[i].abiSound==nil then
			DF_config.spells[i].abiSound=""
		end

		if DF_config.spells[i].abiUserText==nil then
			DF_config.spells[i].abiUserText=""
		end

		if DF_config.spells[i].alwaysVisible==nil then
			DF_config.spells[i].alwaysVisible=false
		end

		--
		-- Fin nouvelles variables
		--

		-- sauve les nom des debuffs
		if DF_config.spells[i].names==nil then
			DF_config.spells[i].names={}
		else
			DF_config.spells[i].names=table.wipe(DF_config.spells[i].names)
			DF_config.spells[i].names={}
		end

		if DF_config.spells[i].ids==nil then
			DF_config.spells[i].ids={}
		else
			DF_config.spells[i].ids=table.wipe(DF_config.spells[i].ids)
			DF_config.spells[i].ids={}
		end

		local temp=DF:explode ( ";", DF_config.spells[i].spellIDs )
		local nbIds = getn(temp)

		for ide = 1,nbIds do
			DF_config.spells[i].ids[ide]=tonumber(temp[ide])
			if DF_config.spells[i].ids[ide] then
				DF_config.spells[i].names[ide] = GetSpellInfo(DF_config.spells[i].ids[ide])
			else
				DF_config.spells[i].names[ide] = nil
			end
		end

		DF_config.spells[i].abiSpelltext=DF_config.spells[i].names[1]
		DF_config.spells[i].abiSpellId=DF_config.spells[i].ids[1]
	end
end

-- gestion de l'animation
function DF:spells_update(elapsed)
	local nbSpells = getn(DF_config.spells)

	-- anime
	for it = 1,nbSpells do

		-- màj temps restant
		if DF_config.spells[it].abiTimeLeft>0 then
			DF_config.spells[it].abiTimeLeft=DF_config.spells[it].abiTimeLeft-elapsed
			if DF_config.spells[it].abiTimeLeft<0 then
				DF_config.spells[it].abiTimeLeft=0
			end
		end

		if DF:spell_check(it) then
			DF:spells_activate(it)
		else
			DF:spells_desactivate(it)
		end
	end
end

function DF:spell_exist(idcheck,namecheck,cible,filtre,strong)
	local index=1
	local name = nil
	local spellId = nil

	while true do

		name, _, _, _, _, _, _, _, _, spellId = UnitAura(cible, index, filtre)

		-- plus de nom la liste est finie
		if not name then
			return nil
		end

		-- l'id correspond on tient le sort
		if spellId == idcheck then
			return index
		end

		-- vérification avec juste le nom du debuff, vérification simple qui peut confondre certain debuff entre eux (portant le même nom, mais pas la même ID)
		if name==namecheck and not strong then
			return index
		end

		index=index+1
	end
end

function DF:spell_getPowerAttack()
	local base, posBuff, negBuff = UnitAttackPower("player")
	local puissance = base + posBuff + negBuff
	_, _, _, _, posBuff, negBuff = UnitDamage("player")
	return puissance + posBuff + negBuff
end

function DF:spell_check(num)
	local form = DF_config.spells[num].form

	-- fin si pas de cible
	if not DF:form_goofForm(form, DF:currentForm()) then return false end

	local filter = nil
	local debuffName = nil
	local thatOk = false
	local difference=0

	local targetID=nil

	local name=nil
	local count=nil
	local duration=nil
	local expirationTime=nil
	local timeLeft=nil
	local caster=nil
	local isPerso=false
	local lid=nil
	local index=nil

	local isActive = false

	-- récupére infos du spell
	local sType = DF_config.spells[num].sType
	local perso = DF_config.spells[num].perso
	local combo = DF_config.spells[num].combo

	local nbIds = getn(DF_config.spells[num].ids)

	if (combo) then DF:combo_set(0) end

	if sType=="Debuff" then

		if (perso) then
			filter="HARMFUL|PLAYER"
		else
			filter="HARMFUL"
		end

		targetID=UnitGUID("playertarget")
		if not targetID then return false end

		-- c'est un debuff
		thatOk = false

		local currentPA = DF:spell_getPowerAttack()

		-- cherche les debuffs
		for ide = 1,nbIds do
			-- nom du debuff
			debuffName = DF_config.spells[num].names[ide]

			if (debuffName) then
				index = DF:spell_exist(DF_config.spells[num].ids[ide],debuffName,"playertarget",filter,DF_config.spells[num].strongcheck)

				-- si présent
				if (index) then
					thatOk = true

					-- sauve les infos
					name, _, count, _, duration, expirationTime, caster, _, _, _ = UnitAura("playertarget", index, filter)
					lid=DF_config.spells[num].ids[ide]
				end
			end
		end

		-- si c'est ok
		if thatOk then
			-- indique si le debuff appartient au joueur
			if (caster=="player") then
				isPerso=true
			else
				isPerso=false
			end

			-- si c'est un sort non personnel ou personnel et qui vient du joueur
			if (not perso or (perso and isPerso)) then
				-- indique spell active
				isActive=true

				-- si on dispose d'une fin de debuff, on retranche l'heure courante pour obtenir le temps restant
				if (expirationTime ~= nil) then
					timeLeft = expirationTime - DF.currentTime

					if (timeLeft<0) then
						timeLeft=0
					end

					-- le sort vient d'être posé
					if DF_config.spells[num].abiStart==0 then
						DF:icons_pulse(num)
						DF:sound_play(DF_config.spells[num].abiSound)
						DF_config.spells[num].abiPower[targetID]=currentPA
						if DF_config.spells[num].abiInternalCD>0 then
							DF:cooldown_addCD(lid,DF.currentTime,DF_config.spells[num].abiInternalCD)
						end
					end

					-- *** Gestion de la glyphe Lambeau (shred) ***
					difference = timeLeft - DF_config.spells[num].abiOldTimeLeft

					-- si la différence de temps depuis le dernier cycle est >0, le temps du debuff a augmenté
					if (difference>0 and isPerso) then
						if DF_config.spells[num].abiOldTimeLeft~=0 then
							DF:icons_pulse(num)
						end

						-- si la différence est supérieure a 3 secondes (2 secondes plus 1 seconde pour le lag),
						-- c'est une application ou un rafraichissement du debuff
						-- sinon c'est une augmentation de la durée du debuff par lambeau (+2 sec)
						-- !!! pê un probléme si rafraichissement avant 2 sec aprés application !!!
						if (difference>3) then
							-- application ou rafraichissement
							DF_config.spells[num].abiStack = 0
							DF_config.spells[num].abiPower[targetID]=currentPA
						else
							-- lambeau
							DF_config.spells[num].abiStack = DF_config.spells[num].abiStack + 1
						end
					end

					DF_config.spells[num].abiOldTimeLeft = timeLeft
				else
					timeLeft=0
				end

				-- sauve données dans le tableau
				DF_config.spells[num].abiSpelltext=name
				DF_config.spells[num].abiSpellId=lid
				DF_config.spells[num].abiStart=expirationTime-duration
				DF_config.spells[num].abiEnd=expirationTime
				if (count>0) then DF_config.spells[num].abiStack=count end
				DF_config.spells[num].abiTimeLeft = timeLeft
				DF_config.spells[num].abiDuration = duration

				-- abilités a combo pour notre barre? et count valide?
				if (combo) then DF:combo_set(count) end
			end
		end
	elseif sType=="BuffTarget" then

		if (perso) then
			filter="HELPFUL|PLAYER"
		else
			filter="HELPFUL"
		end

		targetID=UnitGUID("playertarget")
		if not targetID then return false end

		-- c'est un debuff
		thatOk = false

		-- cherche les debuffs
		for ide = 1,nbIds do

			-- nom du debuff
			debuffName = DF_config.spells[num].names[ide]

			if (debuffName) then
				index = DF:spell_exist(DF_config.spells[num].ids[ide],debuffName,"playertarget",filter,DF_config.spells[num].strongcheck)

				-- si présent
				if (index) then
					thatOk = true

					-- sauve les infos
					name, _, count, _, duration, expirationTime, caster, _, _, _ = UnitAura("playertarget", index, filter) 
					lid=DF_config.spells[num].ids[ide]
				end
			end
		end

		-- si c'est ok
		if thatOk then
			-- indique si le debuff appartient au joueur
			if (caster=="player") then
				isPerso=true
			else
				isPerso=false
			end

			-- si c'est un sort non personnel ou personnel et qui vient du joueur
			if (not perso or (perso and isPerso)) then
				-- indique spell active
				isActive=true

				-- si on dispose d'une fin de debuff, on retranche l'heure courante pour obtenir le temps restant
				if (expirationTime ~= nil) then
					timeLeft = expirationTime - DF.currentTime

					if (timeLeft<0) then
						timeLeft=0
					end

					-- le sort vient d'être posé
					if DF_config.spells[num].abiStart==0 then
						DF:icons_pulse(num)
						DF:sound_play(DF_config.spells[num].abiSound)
						DF_config.spells[num].abiPower[targetID]=currentPA
						if DF_config.spells[num].abiInternalCD>0 then
							DF:cooldown_addCD(lid,DF.currentTime,DF_config.spells[num].abiInternalCD)
						end
					end

					-- *** Gestion de la glyphe Lambeau (shred) ***
					difference = timeLeft - DF_config.spells[num].abiOldTimeLeft

					-- si la différence de temps depuis le dernier cycle est >0, le temps du debuff a augmenté
					if (difference>0 and isPerso) then
						if DF_config.spells[num].abiOldTimeLeft~=0 then
							DF:icons_pulse(num)
						end

						-- si la différence est supérieure a 3 secondes (2 secondes plus 1 seconde pour le lag),
						-- c'est une application ou un rafraichissement du debuff
						-- sinon c'est une augmentation de la durée du debuff par lambeau (+2 sec)
						-- !!! pê un probléme si rafraichissement avant 2 sec aprés application !!!
						if (difference>3) then
							-- application ou rafraichissement
							DF_config.spells[num].abiStack = 0
							DF_config.spells[num].abiPower[targetID] = currentPA
						else
							-- lambeau
							DF_config.spells[num].abiStack = DF_config.spells[num].abiStack + 1
						end
					end

					DF_config.spells[num].abiOldTimeLeft = timeLeft
				else
					timeLeft=0
				end

				-- sauve données dans le tableau
				DF_config.spells[num].abiSpelltext=name
				DF_config.spells[num].abiSpellId=lid
				DF_config.spells[num].abiStart=expirationTime-duration
				DF_config.spells[num].abiEnd=expirationTime
				if (count>0) then DF_config.spells[num].abiStack=count end
				DF_config.spells[num].abiTimeLeft = timeLeft
				DF_config.spells[num].abiDuration = duration

				-- abilités a combo pour notre barre? et count valide?
				if (combo) then DF:combo_set(count) end
			end
		end
	elseif sType=="Buff" then

		-- buff
		thatOk = false

		-- cherche le(s) buff(s)
		for ide = 1,nbIds do
			debuffName = DF_config.spells[num].names[ide]
			if (debuffName) then
				index = DF:spell_exist(DF_config.spells[num].ids[ide],debuffName,"player","HELPFUL|PLAYER",DF_config.spells[num].strongcheck)

				-- si présent
				if (index) then

					thatOk = true

					-- sauve les infos
					name, _, count, _, duration, expirationTime, caster = UnitAura("player", index, "HELPFUL|PLAYER")
					lid=DF_config.spells[num].ids[ide]
				end
			end
		end

		-- concordance avec le buff a scanner?
		if thatOk then

			isActive=true

			-- si on dispose d'une fin de buff, on retranche l'heure courante pour obtenir le temps restant
			if (expirationTime ~= nil) then
				timeLeft = expirationTime - DF.currentTime

				if (timeLeft<0) then
					timeLeft=0
				end

				if DF_config.spells[num].abiStart==0 then
					DF:icons_pulse(num)
					DF:sound_play(DF_config.spells[num].abiSound)
					if DF_config.spells[num].abiInternalCD>0 then
						DF:cooldown_addCD(lid,DF.currentTime,DF_config.spells[num].abiInternalCD)
					end

					if DF_config.spells[num].abiLast>0 then
						local abiLastCd=DF.currentTime-DF_config.spells[num].abiLast

						if abiLastCd<DF_config.spells[num].abiLastCd or DF_config.spells[num].abiLastCd==0 then
							DF_config.spells[num].abiLastCd=abiLastCd
						end
					end

					DF_config.spells[num].abiLast=DF.currentTime
				end
			else
				timeLeft=0
			end

			DF_config.spells[num].abiSpelltext=name
			DF_config.spells[num].abiSpellId=lid
			DF_config.spells[num].abiTimeLeft = timeLeft
			DF_config.spells[num].abiDuration = duration
			if (count>0) then DF_config.spells[num].abiStack=count end
			DF_config.spells[num].abiStart=expirationTime-duration
			DF_config.spells[num].abiEnd=expirationTime
		end
	else
		return false
	end

	return isActive
end

function DF:spells_activate(numero)
	DF:icons_activate(numero)
end

function DF:spells_desactivate(numero)
	local nbSpells = getn(DF_config.spells)

	if numero then
		DF_config.spells[numero].abiOldTimeLeft=0
		DF_config.spells[numero].abiStack=0
		DF_config.spells[numero].abiTimeLeft=0
		DF_config.spells[numero].abiDuration=0
		DF_config.spells[numero].abiAlphaPulse=0
		DF_config.spells[numero].abiCD=0
		--DF_config.spells[numero].abiPower=0
		DF:spells_clearPA(numero)
		DF_config.spells[numero].abiEnd=0
		DF_config.spells[numero].abiStart=0

		DF:icons_desactivate(numero)
	else
		for spellIdx = 1, nbSpells do
			DF_config.spells[spellIdx].abiTimeLeft=0
			DF_config.spells[spellIdx].abiOldTimeLeft=0
			DF_config.spells[spellIdx].abiStack=0
			DF_config.spells[spellIdx].abiEnd=0
			DF:spells_clearPA(spellIdx)

			DF:icons_desactivate(spellIdx)
		end
	end
end

function DF:spells_list_reinit()
	DF:init_spells_list()
	DF:icons_reinit()
	DF:timerbar_reinit()
end

function DF:spells_clearPA(num)
	if not num then
		local nbSpells = getn(DF_config.spells)
		for it = 1,nbSpells do
			DF_config.spells[it].abiPower = table.wipe(DF_config.spells[it].abiPower)
		end
	else
		for index, _ in pairs(DF_config.spells[num].abiPower) do
			DF_config.spells[num].abiPower[index]=0
		end
	end
end
