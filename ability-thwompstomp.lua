ABILTY_ID_THWOMPSTOMP = 2

ACT_THWOMPSTOMP_POUND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING |
    ACT_FLAG_CUSTOM_ACTION)

ACT_THWOMPSTOMP_POUND_LAND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING |
    ACT_FLAG_CUSTOM_ACTION)

-- id_bhvKaisenShockWave = 0x314
-- hook_behavior(id_bhvKaisenShockWave, OBJ_LIST_DEFAULT, false,
--     function(o)
--     end,

--     function(o)
--         local nearsetM = nearest_mario_state_to_object(o)

--         if nearsetM.playerIndex == 0 then return end
--         if nearsetM.marioObj ~= o.parentObj then
--             set_mario_action(nearsetM, ACT_JUMP, 0)
--         end
--     end
-- )

local function act_thwompstomp_pound_land(m)
    return
end

local function everytime_thwompstomp_pound(m)
    common_air_action_step(m, ACT_THWOMPSTOMP_POUND_LAND, MARIO_ANIM_GROUND_POUND, 0)
    m.vel.y = -250
    m.forwardVel = 0
    m.peakHeight = m.pos.y + 1
end


hook_mario_action(ACT_THWOMPSTOMP_POUND, {
    every_frame = everytime_thwompstomp_pound,
    gravity = nil,
}, 0)


hook_mario_action(ACT_THWOMPSTOMP_POUND_LAND, {
    every_frame = nil,
    gravity = nil,
}, 0)

hook_event(HOOK_ON_SET_MARIO_ACTION, function(m)
    if m.action == ACT_THWOMPSTOMP_POUND_LAND then
        spawn_sync_object(id_bhvBowserShockWave, E_MODEL_BOWSER_WAVE, m.pos.x, m.pos.y, m.pos.z,
            function(o)
            end
        )
    end
end)

local function onUseThwompStomp()
    local m = gMarioStates[0]
    set_mario_action(m, ACT_THWOMPSTOMP_POUND, 0)
end

RegisterAbility(ABILTY_ID_THWOMPSTOMP,
    {
        name = "ThwompStomp",
        shortName = "TwSt",
        description = "Fall fast and create a shocking wave by landing.",
        iconTextureName = "twst",

        cost = 128,
        cooldown = 128,
        curCooldown = 0,

        onUseFunction = onUseThwompStomp,
        getPermissibilityToUse = function()
            local m = gMarioStates[0]
            if (m.action & ACT_FLAG_AIR) ~= 0 then return true end

            return false
        end,
        getExtraInfo = function()
            return { " - " }
        end
    }
)
