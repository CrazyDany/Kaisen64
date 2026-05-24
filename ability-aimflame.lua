ABILITY_ID_AIMFLAME = 12

define_custom_obj_fields(
    { oMarioParentGlobalIndex = "f32" }
)

local function onUseAimFlame()
    local m = gMarioStates[0]

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

RegisterAbility(ABILITY_ID_AIMFLAME, {
    name = "AimFlame",
    shortName = "AiFl",
    description = "Ability placeholder for modders",
    iconTextureName = "aifl",

    cost = 128,
    cooldown = 128,
    curCooldown = 0,

    onUseFunction = onUseAimFlame,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end
})
