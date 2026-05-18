-- Детект движения стика

function get_mario_stick_input(m)
    if (m.controller.stickX ~= 0) or (m.controller.stickY ~= 0) or (m.controller.extStickX ~= 0) or (m.controller.extStickY ~= 0) then
        return true
    else
        return false
    end
end

-- Детект поворота Марио

function get_mario_turn_around(m)
    if math.abs((m.faceAngle.y - m.intendedYaw)) > (2 ^ 14) then
        return true
    else
        return false
    end
end

-- Улучшенные повороты

hook_event(HOOK_MARIO_UPDATE, function(m)
    if (m.action == ACT_WALKING) then
        if get_mario_turn_around(m) then
            if (math.abs(m.forwardVel) > 7) and (m.action ~= ACT_TURNING_AROUND) then
                set_mario_action(m, ACT_TURNING_AROUND, 0)
            else
                m.faceAngle.y = m.intendedYaw
            end
        end
    end
end)

-- Блок и парирование

ACT_GROUND_BLOCK = allocate_mario_action(0x06b01 | ACT_FLAG_CUSTOM_ACTION | ACT_FLAG_STATIONARY)

BLOCK_STATE_NONE = -1
BLOCK_STATE_BLOCK = 0
BLOCK_STATE_PARRY = 1

function GetBlockState(m)
    if m.action == ACT_GROUND_BLOCK then
        if m.actionTimer > 256 then
            return BLOCK_STATE_BLOCK
        else
            return BLOCK_STATE_PARRY
        end
    else
        return BLOCK_STATE_NONE
    end
end

local function act_ground_block(m)
    if m.actionTimer >= 30 then
        -- Missed block
        set_mario_action(m, ACT_HARD_BACKWARD_GROUND_KB, 0)
    end
end

hook_event(HOOK_MARIO_UPDATE,
    function()
        local m = gMarioStates[0]
        gPlayerSyncTable[0].sinceLastBlock = (gPlayerSyncTable[0].sinceLastBlock or 0) + 1

        if (((m.controller.buttonPressed & Z_TRIG) ~= 0) and (m.action == ACT_STOP_CROUCHING) and (GetBlockState(m) == BLOCK_STATE_NONE)) then
            djui_chat_message_create("BLOCK")
        end
    end
)

HookEvent_LocalMarioPVPAttack(
    function(v, i)
        if GetBlockState(v) == BLOCK_STATE_PARRY then
            set_mario_action(gMarioStates[0], ACT_SHOCKED, 0)
        end
    end
)

HookEvent_LocalMarioPVPDamage(
    function(a, i)
        local m = gMarioStates[0]
        if GetBlockState(m) == BLOCK_STATE_BLOCK then
            set_mario_action(m, ACT_IDLE, 0)
            m.invincTimer = m.invincTimer + 30
            m.vel.x = 0
            m.vel.y = 0
            m.vel.z = 0
        end
    end
)


hook_event(HOOK_ALLOW_HAZARD_SURFACE, function(m, h)
    if GetBlockState(m) == BLOCK_STATE_PARRY then
        m.invincTimer = m.invincTimer + 15
        set_mario_action(m, ACT_TWIRLING, 0)
        m.vel.y = 100
        return false
    end
end)

hook_mario_action(ACT_GROUND_BLOCK,
    {
        every_frame = act_ground_block,
        gravity = nil
    }
)
