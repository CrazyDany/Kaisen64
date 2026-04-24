ABILITY_ID_DASHCLASH = 5

ACT_DASHCLASH_DASH = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING |
    ACT_FLAG_CUSTOM_ACTION)

local function act_dashclash_dash(m)
    local stepResult = perform_ground_step(m)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0)
        return
    end

    mario_set_forward_vel(m, 100)

    set_mario_particle_flags(m, PARTICLE_DUST, 0)
    play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)

    set_mario_animation(m, MARIO_ANIM_SKID_ON_GROUND)

    m.actionTimer = m.actionTimer + 1

    if m.actionTimer >= 8 then
        set_mario_action(m, ACT_IDLE, 0)
        m.actionTimer = 0
    end
end

hook_mario_action(ACT_DASHCLASH_DASH, { every_frame = act_dashclash_dash })

local function onUseDashClash()
    local m = gMarioStates[0]

    set_mario_action(m, ACT_DASHCLASH_DASH, 0)
end

RegisterAbility(ABILITY_ID_DASHCLASH, {
    name = "DashClash",
    shortName = "DsCl",
    description = "Do a forward dash that knocks down players.",
    iconTextureName = "rgtc",

    cost = 64,
    cooldown = 64,
    curCooldown = 0,

    onUseFunction = onUseDashClash,
    getPermissibilityToUse = function()
        local m = gMarioStates[0]
        if (m.action & ACT_FLAG_AIR) ~= 0 then return false end

        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end
})
