----------------------------------------------------------------------------------------------------
-- DroodFocus 4.0.0 - toggle
-- Meranannon - Discordia - Vol'jin (EU)
-- rev 1
----------------------------------------------------------------------------------------------------

local DF = DF_namespace

function DF:toggle_toggle()
	
	local showIt = DF:form_goofForm(DF_config.activeForms,DF:currentForm())
	
	if not DF.configmode then

		if DF_config.inCombat and not DF:inCombat() then
			showIt=false
		end
		
	end

	if DF_config.uiAlwaysShow or DF.configmode then
		showIt=true
	end
		
	DF:toggle_change(showIt)
	
end

function DF:toggle_change(flag)
		
	for i = 1,4 do
		
		if flag==true then
			DF.anchor[i].base:Show()
		else
			DF.anchor[i].base:Hide()
		end
		
	end
	
end