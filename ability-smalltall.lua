ABILITY_ID_SMALLTALL = 5

local function onUseSmallTall()
    gPlayerSyncTable[0].Kaisen64.smalltall_size = 2 ^ random_sign()
    gPlayerSyncTable[0].Kaisen64.smalltall_cur_duration = 256

    local m = gMarioStates[0]

    m.marioObj.hitboxRadius = m.marioObj.hitboxRadius * gPlayerSyncTable[0].Kaisen64.smalltall_size
end

hook_event(HOOK_MARIO_UPDATE,
    --- comment
    --- @param m MarioState
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end
        if ((gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_cur_duration or 0) > 0) then
            if m.playerIndex == 0 then
                gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_cur_duration = gPlayerSyncTable[m.playerIndex]
                    .Kaisen64
                    .smalltall_cur_duration - 1
            end

            m.marioObj.header.gfx.scale.x = m.marioObj.header.gfx.scale.x *
                gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size

            m.marioObj.header.gfx.scale.z = m.marioObj.header.gfx.scale.z *
                gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size

            m.marioObj.header.gfx.scale.y = m.marioObj.header.gfx.scale.y *
                gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size

            m.marioObj.hitboxHeight = m.marioObj.hitboxHeight *
                gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size

            if (gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size > 1) then
                if m.playerIndex == 0 then
                    set_override_fov(65)
                end

                if m.action == ACT_WALKING then
                    smlua_anim_util_set_animation(m.marioObj, "mario_anim_walking")
                    set_camera_shake_from_hit(SHAKE_GROUND_POUND)
                    play_step_sound(m, 0, 88)
                end
            end

            if (gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size < 1) then
                if m.playerIndex == 0 then
                    set_override_fov(35)
                end
            end
            if (ACT_FLAG_AIR and (m.vel.y > 0)) ~= 0 then
                m.vel.y = m.vel.y - (gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size or 0) / 2
            end
            if (gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_cur_duration == 0) then
                m.marioObj.hitboxRadius = m.marioObj.hitboxRadius / gPlayerSyncTable[0].Kaisen64.smalltall_size
                gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size = 1
                if m.playerIndex == 0 then
                    set_override_fov(0)
                end
            end
        end
    end
)

hook_event(HOOK_BEFORE_PHYS_STEP,
    --- @param m MarioState
    --- @param s integer
    function(m, s)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end
        if ((gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_cur_duration or 0) > 0) then
            m.vel.x = m.vel.x / ((gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size or 1) * 0.75)
            m.vel.z = m.vel.z / ((gPlayerSyncTable[m.playerIndex].Kaisen64.smalltall_size or 1) * 0.75)
        end
    end
)

RegisterAbility(ABILITY_ID_SMALLTALL, {
    name = "SmallTall",
    shortName = "SmTl",
    description = {
        "Grow up in size for destructibility or shrink down in size for slickness."
    },
    iconTextureName = "smtl",

    cost = 128,
    cooldown = 512,
    curCooldown = 0,

    onUseFunction = onUseSmallTall,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end,

    onResetVariables = function()
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        local m = gMarioStates[0]

        m.marioObj.hitboxRadius = m.marioObj.hitboxRadius / (gPlayerSyncTable[0].Kaisen64.smalltall_size or 1)

        gPlayerSyncTable[0].Kaisen64.smalltall_size = 1
        gPlayerSyncTable[0].Kaisen64.smalltall_cur_duration = 0
    end,

    --- custom fields
    smalltall_duration = 256
})
