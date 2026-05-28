ABILITY_ID_IREFIRE = 10

define_custom_obj_fields(
    { oMarioParentGlobalIndex = "f32" }
)

local function onUseIreFire()
    local m = gMarioStates[0]

    local chants = gPlayerSyncTable[0].Kaisen64.cur_chant or 0

    for i = 0, chants do
        spawn_sync_object(
            id_bhvFireSphere,
            E_MODEL_RED_FLAME,
            m.pos.x,
            m.pos.y,
            m.pos.z,
            function(o)
                o.parentObj = m.marioObj
                o.oMarioParentGlobalIndex = network_global_index_from_local(0)
            end
        )
    end
end

RegisterAbility(ABILITY_ID_IREFIRE, {
    name = "IreFire",
    shortName = "IrFr",
    description = {
        "Spawn a rotating fireball that burns enemies."
    },
    iconTextureName = "irfr",

    cost = 128,
    cooldown = 128,
    curCooldown = 0,

    onUseFunction = onUseIreFire,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end
})
