---comment
---@param m MarioState
---@param dur number
local function onApplyFreesingEffect(m, dur)
end

local function f(n) return 1024 / (n + 1024) end

---comment
---@param m MarioState
---@param dur number
local function onUpdateFreesingEffect(m, dur)
end

hook_event(HOOK_BEFORE_PHYS_STEP,
    --- @param m MarioState
    --- @param s integer
    function(m, s)
        local effectStrength = FreesingEffect:GetRemaining(m) or 0

        if effectStrength <= 0 then return end

        if ChecIfHit() == true then return end

        local groundSpeed = f(effectStrength)
        m.vel.x = m.vel.x * groundSpeed
        m.vel.z = m.vel.z * groundSpeed
    end
)

local idkcooldown = false

hook_event(HOOK_MARIO_UPDATE,
    --- @param m MarioState
    function(m)
        local effectStrength = FreesingEffect:GetRemaining(m) or 0

        if effectStrength <= 0 then return end

        local jumpStrength = f(effectStrength)

        local actionisold

        if m.actionTimer > 0 then
            actionisold = true
        else
            actionisold = false
        end

        if idkcooldown == true then
            if CheckIfStationary() == true or CheckIfGroundMoving() == true then
                idkcooldown = false
            end
        end

        if (CheckIfStationaryBefore() or CheckIfGroundMovingBeforeBefore()) and actionisold == false and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            if idkcooldown == false then
                m.vel.y = m.vel.y * jumpStrength
                idkcooldown = true
            end
        end
    end
)

---comment
---@param m MarioState
local function onEndFreesingEffect(m)
end

FreesingEffect = EffectData.new("freezing", onUpdateFreesingEffect, onApplyFreesingEffect, onEndFreesingEffect)

hook_chat_command("freeze", "Apply freezing effect", function(m)
    FreesingEffect:Apply(gMarioStates[0], 128)
    return true
end)
