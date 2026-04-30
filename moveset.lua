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