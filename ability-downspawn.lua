ABILTY_ID_DOWNSPAWN = 120



local function onUseDownSpawn()
    local m = gMarioStates[0]
	
	
	spawn_sync_object(DSObjects[0].id, DSObjects[0].model, DSObjects[0].dx, DSObjects[0].dy, nil)
	    
	
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
