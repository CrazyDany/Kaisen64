ABILITY_ID_SHINESIGN = 14

local function onUseShineSign()
    local ability = AbilitiesData[ABILITY_ID_SHINESIGN]

    local m = gMarioStates[0]

    local chants = gPlayerSyncTable[0].Kaisen64.cur_chant or 0

    spawn_sync_object(
        id_bhvGojosBlue,
        E_MODEL_YELLOW_SPHERE,
        m.pos.x,
        m.pos.y,
        m.pos.z,
        --- comment
        --- @param o Object
        function(o)
            o.oForwardVel = 80.0

            o.header.gfx.scale.x = 1.0 + chants
            o.header.gfx.scale.y = 1.0 + chants
            o.header.gfx.scale.z = 1.0 + chants

            o.oMarioParentGlobalIndex = network_global_index_from_local(0)
            o.oAttractRadius = 2048.0 * (chants + 1)
            o.oAttractStrength = 50.0 + (5.0 * chants)
            o.oLapseRadius = 512.0
            o.oLapseStrength = 10.0
            o.oForwardVelAfterHit = 5.0
            o.oLifetime = 256 + (32 * chants)
        end
    )
end

RegisterAbility(ABILITY_ID_SHINESIGN, {
    name = "ShineSign",
    shortName = "ShSg",
    description = {
        "Spawn a shining sign that lights up the world."
    },
    iconTextureName = "rctc",

    cost = 128,
    cooldown = 256,
    curCooldown = 0,

    onUseFunction = onUseShineSign,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end
})
