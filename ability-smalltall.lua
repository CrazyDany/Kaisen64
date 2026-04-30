ABILITY_ID_SMALLTALL = 6

local function onUseSmallTall()
    AbilitiesData[ABILITY_ID_SMALLTALL].STTimer = 512
    if random_float() >= 0.5 then
        AbilitiesData[ABILITY_ID_SMALLTALL].scale = 3.0
    else
        AbilitiesData[ABILITY_ID_SMALLTALL].scale = 0.2
    end
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end

    if AbilitiesData[ABILITY_ID_SMALLTALL].STTimer > 1 then
        obj_scale(m.marioObj, AbilitiesData[ABILITY_ID_SMALLTALL].scale)
        obj_set_hitbox_radius_and_height(m.marioObj, 37 * AbilitiesData[ABILITY_ID_SMALLTALL].scale, 160 * AbilitiesData[ABILITY_ID_SMALLTALL].scale)
        AbilitiesData[ABILITY_ID_SMALLTALL].STTimer = AbilitiesData[ABILITY_ID_SMALLTALL].STTimer - 1
        if AbilitiesData[ABILITY_ID_SMALLTALL].scale == 3.0 then
            set_override_fov(65)
            if (m.hurtCounter) ~= 0 then
                m.hurtCounter = m.hurtCounter / 2
            end
            if (get_mario_stick_input(m)) and not (get_mario_turn_around(m)) then
                mario_set_forward_vel(m, math.clamp(m.forwardVel, -25, 25))
            end
            if m.action == ACT_WALKING then
                smlua_anim_util_set_animation(m.marioObj, "mario_anim_walking")
                play_step_sound(m, 0, 88)
            end
            if AbilitiesData[ABILITY_ID_SMALLTALL].actionsShake[m.action] ~= nil then
                set_camera_shake_from_hit(SHAKE_GROUND_POUND)
            end
        elseif AbilitiesData[ABILITY_ID_SMALLTALL].scale == 0.2 then
            set_override_fov(35)
            if (m.hurtCounter) ~= 0 then
                m.hurtCounter = m.hurtCounter * 1.5
            end
            if (get_mario_stick_input(m)) and not (get_mario_turn_around(m)) then
                mario_set_forward_vel(m, math.clamp(m.forwardVel * 1.15, -75, 75))
            end
        end
    elseif AbilitiesData[ABILITY_ID_SMALLTALL].STTimer == 1 then
        set_override_fov(50)
        AbilitiesData[ABILITY_ID_SMALLTALL].STTimer = 0
        obj_set_hitbox_radius_and_height(m.marioObj, 37, 160)
    end
end)

RegisterAbility(ABILITY_ID_SMALLTALL, {
    name = "SmallTall",
    shortName = "SmTl",
    description = "Grow up in size for destructibility or shrink down in size for slickness.",
    iconTextureName = "rgtc",

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

    STTimer = 0,

    scale = 0,

    actionsShake = {
        [ACT_WALKING] = true,
        [ACT_JUMP_LAND] = true,
        [ACT_DOUBLE_JUMP_LAND] = true,
        [ACT_TRIPLE_JUMP_LAND] = true,
        [ACT_LONG_JUMP_LAND] = true,
        [ACT_SIDE_FLIP_LAND] = true,
        [ACT_BACKFLIP_LAND] = true,
        [ACT_SOFT_BONK] = true,
        [ACT_SOFT_BACKWARD_GROUND_KB] = true,
        [ACT_BACKWARD_GROUND_KB] = true,
        [ACT_HARD_BACKWARD_GROUND_KB] = true,
        [ACT_SOFT_FORWARD_GROUND_KB] = true,
        [ACT_FORWARD_GROUND_KB] = true,
        [ACT_HARD_FORWARD_GROUND_KB] = true,
        [ACT_GROUND_POUND_LAND] = true,
    }
})
