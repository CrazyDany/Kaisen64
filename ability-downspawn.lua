ABILITY_ID_DOWNSPAWN = 7

local function onUseDownSpawn()
    local m = gMarioStates[0]

    local No = AbilitiesData[ABILITY_ID_DOWNSPAWN].DSPredictionObject

    spawn_sync_object(
        AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].id,
        AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].model,
        m.pos.x + AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].dx,
        m.pos.y + AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].dy,
        m.pos.z + AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[No].dz,
        function(o)
            -- Setup function
        end
    )

    
end

hook_event(HOOK_ON_SET_MARIO_ACTION, function(m)
    if m.playerIndex ~= 0 or gPlayerSyncTable[0].Kaisen64 == nil then
        return
    end

    AbilitiesData[ABILITY_ID_DOWNSPAWN].DSPredictionObject = math.random(0,
        #AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects)

end)

RegisterAbility(ABILITY_ID_DOWNSPAWN, {
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
        return { "Object: " ..
        AbilitiesData[ABILITY_ID_DOWNSPAWN].DSObjects[AbilitiesData[ABILITY_ID_DOWNSPAWN].DSPredictionObject].name }
    end,

    DSPredictionObject = 0,
    DSObjects = {
        [0] = { name = "Coin", id = id_bhvOneCoin, model = E_MODEL_YELLOW_COIN, dx = 0, dy = 200, dz = 0 },
        [1] = { name = "Wing Cap", id = id_bhvWingCap, model = E_MODEL_MARIOS_CAP, dx = 0, dy = 200, dz = 0 },
        [2] = { name = "Koopa Shell", id = id_bhvKoopaShell, model = E_MODEL_KOOPA_SHELL, dx = 0, dy = 0, dz = 0 },
        [3] = { name = "Bully", id = id_bhvSmallBully, model = E_MODEL_BULLY, dx = 150, dy = -150, dz = 0 },
    },

}
)
