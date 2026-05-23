--- comment
--- @param m MarioState
--- @param dur integer
local function onUpdateDizzinessEffect(m, dur)
    if m.playerIndex == 0 then
        set_camera_shake_from_hit(SHAKE_GROUND_POUND)
    end
end

local function onStartDizzinessEffect(m, dur)
end

local function onEndDizzinessEffect(m)
end

DizzinessEffect = EffectData.new("dizziness", onUpdateDizzinessEffect, onStartDizzinessEffect, onEndDizzinessEffect)

hook_chat_command("diz", "Apply dizziness effect", function(msg)
    DizzinessEffect:Apply(gMarioStates[0], 256)
    return true
end)
