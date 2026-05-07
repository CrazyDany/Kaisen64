ABILITY_ID_COLDMOLD = 10

local function onUseColdMold()
    local m = gMarioStates[0]

    AbilitiesData[ABILITY_ID_COLDMOLD].curTimer = AbilitiesData[ABILITY_ID_COLDMOLD].duration
end

hook_event(HOOK_UPDATE,
    function()
        local m = gMarioStates[0]

        if m.playerIndex ~= 0 or gPlayerSyncTable[0].Kaisen64 == nil then
            return
        end

        AbilitiesData[ABILITY_ID_COLDMOLD].curTimer = AbilitiesData[ABILITY_ID_COLDMOLD].curTimer - 1
        if AbilitiesData[ABILITY_ID_COLDMOLD].curTimer <= 0 then
            AbilitiesData[ABILITY_ID_COLDMOLD].curTimer = 0
            return
        end

        if AbilitiesData[ABILITY_ID_COLDMOLD].curTimer % AbilitiesData[ABILITY_ID_COLDMOLD].tickSpawnRatio == 0 then
            spawn_sync_object(
                id_bhvColdBreeze,
                E_MODEL_BLUE_FLAME,
                m.pos.x,
                m.pos.y,
                m.pos.z,
                function(o)
                    o.parentObj = m.marioObj
                end
            )
        end
    end
)

RegisterAbility(ABILITY_ID_COLDMOLD, {
    name = "ColdMold",
    shortName = "CoMo",
    description = "Freeze enemies.",
    iconTextureName = "ability-icon-locked",

    cost = 128,
    cooldown = 128,
    curCooldown = 0,

    onUseFunction = onUseColdMold,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end,

    -- custom fields
    duration = 64,
    tickSpawnRatio = 16,

    curTimer = 0,
})
