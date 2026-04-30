hook_event(HOOK_MARIO_UPDATE, function(m)
    if (m.action == ACT_WALKING) then
        if math.abs((m.faceAngle.y - m.intendedYaw)) > math.pow(2, 14) then
            if (math.abs(m.forwardVel) > 7) and (m.action ~= ACT_TURNING_AROUND) then
                set_mario_action(m, ACT_TURNING_AROUND, 0)
            else
                m.faceAngle.y = m.intendedYaw
            end
        end
    end
end)
