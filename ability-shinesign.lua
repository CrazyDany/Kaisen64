ABILITY_ID_SHINESIGN = 14

local function onUseShineSign()
    local ability = AbilitiesData[ABILITY_ID_SHINESIGN]

    local m = gMarioStates[0]

    local chants = gPlayerSyncTable[0].Kaisen64.cur_chant or 0

    local ability = AbilitiesData[ABILITY_ID_SHINESIGN]

    if ability.selectedMode == 0 then
        spawn_sync_object(
            id_bhvGojosBlue,
            E_MODEL_GOJOSBLUE,
            m.pos.x,
            m.pos.y,
            m.pos.z,
            --- comment
            --- @param o Object
            function(o)
                o.oForwardVel = 80.0

                o.header.gfx.scale.x = 1.5 + chants
                o.header.gfx.scale.y = 1.5 + chants
                o.header.gfx.scale.z = 1.5 + chants

                o.oMarioParentGlobalIndex = network_global_index_from_local(0)
                o.oAttractRadius = 2048.0 * (chants + 1)
                o.oAttractStrength = 50.0 + (5.0 * chants)
                o.oLapseRadius = 512.0
                o.oLapseStrength = 10.0
                o.oForwardVelAfterHit = 5.0
                o.oLifetime = 256 + (32 * chants)
            end
        )
    else
        spawn_sync_object(
            id_bhvGojosRed,
            E_MODEL_GOJOSRED,
            m.pos.x,
            m.pos.y,
            m.pos.z,
            --- comment
            --- @param o Object
            function(o)
                o.oForwardVel = 80.0 + (20 * chants)

                o.header.gfx.scale.x = 0.5 - chants / 4
                o.header.gfx.scale.y = 0.5 - chants / 4
                o.header.gfx.scale.z = 0.5 - chants / 4

                o.oMarioParentGlobalIndex = network_global_index_from_local(0)
                o.oRepelRadius = 1024.0 * ((chants / 2) + 1)
                o.oRepelStrength = 75.0 + (25.0 * chants)
                o.oStrongRepelRadius = 256.0
                o.oStrongRepelStrength = 250.0 + (100.0 * chants)
                o.oLifetime = 256 + (32 * chants)
            end
        )
    end

    -- spawn_sync_object(
    --     id_bhvGojosBlue,
    --     E_MODEL_YELLOW_SPHERE,
    --     m.pos.x,
    --     m.pos.y,
    --     m.pos.z,
    --     --- comment
    --     --- @param o Object
    --     function(o)
    --         o.oForwardVel = 80.0

    --         o.header.gfx.scale.x = 1.0 + chants
    --         o.header.gfx.scale.y = 1.0 + chants
    --         o.header.gfx.scale.z = 1.0 + chants

    --         o.oMarioParentGlobalIndex = network_global_index_from_local(0)
    --         o.oAttractRadius = 2048.0 * (chants + 1)
    --         o.oAttractRadius = 2048.0 * (chants + 1)
    --         o.oAttractStrength = 50.0 + (5.0 * chants)
    --         o.oLapseRadius = 512.0
    --         o.oLapseStrength = 10.0
    --         o.oForwardVelAfterHit = 5.0
    --         o.oLifetime = 256 + (32 * chants)
    --     end
    -- )
end


hook_event(HOOK_UPDATE,
    function()
        --- @type MarioState
        local m = gMarioStates[0]

        if gPlayerSyncTable[0].Kaisen64 == nil then return end
        local ability = AbilitiesData[ABILITY_ID_SHINESIGN]

        if m.controller.buttonPressed == KEY_CHANGE_ABILITY_MODE and
            gPlayerSyncTable[0].Kaisen64.abilitiesSlots[gPlayerSyncTable[0].Kaisen64.currentAbilitySlot] == ABILITY_ID_SHINESIGN then
            if ability.selectedMode == 0 then
                ability.selectedMode = 1
            else
                ability.selectedMode = 0
            end
        end
    end
)


RegisterAbility(ABILITY_ID_SHINESIGN, {
    name = "ShineSign",
    shortName = "ShSg",
    description = {
        "Spawn a shining sign that lights up the world."
    },
    iconTextureName = "shsg",

    cost = 128,
    cooldown = 256,
    curCooldown = 0,

    onUseFunction = onUseShineSign,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        if AbilitiesData[ABILITY_ID_SHINESIGN].selectedMode == 0 then
            return { "Selected mode - BLUE" }
        else
            return { "Selected mode - RED" }
        end
    end,

    -- custom fields
    selectedMode = 0
})
