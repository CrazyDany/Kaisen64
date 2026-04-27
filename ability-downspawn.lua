ABILTY_ID_DOWNSPAWN = 7



local function onUseDownSpawn()
    local m = gMarioStates[0]
	
	local No = AbilitiesData[ABILITY_ID_DOWNSPAWN].DSPredictionObject
	spawn_sync_object(
	AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].id,
	AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].model,
	AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].dx,
	AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].dy, nil)
	    
	
end

RegisterAbility(ABILTY_ID_DOWNSPAWN, {
        name = "DownSpawn",
        shortName = "DnSp",
        description = "Spawning object by current act.",
        iconTextureName = "shlk",

        cost = 128,
        cooldown = 128,
        curCooldown = 0,

        onUseFunction = onUseDownSpawn,
        getPermissibilityToUse = function()
            return true
        end,
        getExtraInfo = function()
            return { " - " }
        end,
		
		DSPredictionObject = 0,
		DSObjects = {
		    [0] = {name = "Coin"	   , id = id_bhvOneCoin			   , model = E_MODEL_YELLOW_COIN	  , dx = 0   , dy = 200 },
		    [1] = {name = "Wing Cap"   , id = id_bhvWingCap			   , model = E_MODEL_MARIOS_CAP		  , dx = 0   , dy = 200 },
		    [2] = {name = "Koopa Shell", id = id_bhvKoopaShell		   , model = E_MODEL_KOOPA_SHELL	  , dx = 0   , dy = 0   },
		    [3] = {name = "Bully"	   , id = id_bhvSmallBully		   , model = E_MODEL_BULLY			  , dx = 150 , dy = -150},
		},
		
    }
)
