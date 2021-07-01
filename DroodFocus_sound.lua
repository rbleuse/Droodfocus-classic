----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - sound
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

-- namespace
local DF = DF_namespace

local doSound=false
local fichier = nil

function DF:sound_set_state(flag)
	doSound = flag
end

function DF:sound_roar()

	if DF_config.sound.enable and doSound then
		
		fichier = DF_config.sound.soundfiles[DF:currentForm()+1]

		if fichier and fichier~="" then PlaySoundFile(fichier) end
		doSound=false
		
	end

end

function DF:sound_play(fpath)

	if DF_config.sound.enable then
	
		if fpath and fpath~="" then PlaySoundFile(fpath) end
		
	end

end