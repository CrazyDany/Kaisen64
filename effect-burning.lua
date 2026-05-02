---comment
---@param m MarioState
---@param dur number
local function onApplyBurningEffect(m, dur)
    m.health = m.health - 2 ^ 7
    spawn_sync_object(id_bhvFlameParticle, E_MODEL_RED_FLAME, m.pos.x, m.pos.y, m.pos.z, function(o)
        o.parentObj = m.marioObj
    end)
end

---comment
---@param m MarioState
---@param dur number
local function onUpdateBurningEffect(m, dur)
    m.health = m.health - 1
    if dur % 4 == 0 then
        set_mario_particle_flags(m, PARTICLE_FIRE, 0)
    end

    if dur > 1 then
        m.marioBodyState.shadeR, m.marioBodyState.shadeG, m.marioBodyState.shadeB = 127, 0, 0
    else
        m.marioBodyState.shadeR, m.marioBodyState.shadeG, m.marioBodyState.shadeB = 127, 127, 127
    end
end

---comment
---@param m MarioState
local function onEndBurningEffect(m)
    m.marioBodyState.shadeR, m.marioBodyState.shadeG, m.marioBodyState.shadeB = 127, 127, 127
end

BurningEffect = EffectData.new("burning", onUpdateBurningEffect, onApplyBurningEffect, onEndBurningEffect)

hook_chat_command("burn", "Apply burning effect", function(m)
    BurningEffect:Apply(gMarioStates[0], 128)
    return true
end)
