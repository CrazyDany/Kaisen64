ABILITY_ID_AREFARE = 11

local function onUseArefare()
    local ability = AbilitiesData[ABILITY_ID_AREFARE]

    gPlayerSyncTable[0].arefareActive = true
    djui_chat_message_create("Activied")
end

local inAreFare = false
local areFareDist = 0
-- Убираем глобальные переменные, они больше не нужны
-- local inAreFare = false
-- local areFareDist = 0

hook_event(HOOK_BEFORE_MARIO_UPDATE,
    function(m)
        if m.playerIndex == 0 then
            if gPlayerSyncTable[0].arefareActive then
                gMarioStates[0].invincTimer = 10
                AbilitiesData[ABILITY_ID_AREFARE].curCooldown = AbilitiesData[ABILITY_ID_AREFARE].curCooldown + 1
                AddEnergy(0, -AbilitiesData[ABILITY_ID_AREFARE].energyPerTick)
                if (gControllers[0].buttonPressed & L_TRIG) ~= 0 then
                    gPlayerSyncTable[0].arefareActive = false
                end
                if gPlayerSyncTable[0].Kaisen64.currentEnergy < AbilitiesData[ABILITY_ID_AREFARE].energyPerTick then
                    gPlayerSyncTable[0].arefareActive = false
                end
            end
        end
    end
)

hook_event(HOOK_BEFORE_PHYS_STEP,
    function(m)
        local ability = AbilitiesData[ABILITY_ID_AREFARE]
        local closestDist = nil
        local closestSourceIndex = nil
        for i = 0, MAX_PLAYERS - 1 do
            if i ~= m.playerIndex and gPlayerSyncTable[i].arefareActive then
                local dist = vec3f_dist(gMarioStates[i].pos, m.pos)
                if dist <= ability.radius then
                    if closestDist == nil or dist < closestDist then
                        closestDist = dist
                        closestSourceIndex = i
                    end
                end
            end
        end

        if closestSourceIndex ~= nil then
            local sourcePos = gMarioStates[closestSourceIndex].pos
            local dirToSource = { sourcePos.x - m.pos.x, sourcePos.y - m.pos.y, sourcePos.z - m.pos.z }
            local dot = m.vel.x * dirToSource[1] + m.vel.y * dirToSource[2] + m.vel.z * dirToSource[3]

            if dot > 0 then
                local ratio = closestDist / ability.radius
                local factor = ratio ^ 4
                m.vel.x = m.vel.x * factor
                m.vel.y = m.vel.y * factor
                m.vel.z = m.vel.z * factor
            end
        end
    end
)
RegisterAbility(ABILITY_ID_AREFARE, {
    name = "Arefare",
    shortName = "ArFe",
    description = "Ability placeholder for modders",
    iconTextureName = "rgtc",

    cost = 128,
    cooldown = 256,
    curCooldown = 0,

    onUseFunction = onUseArefare,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end,

    -- custom fields
    energyPerTick = 2,
    radius = 2048
})
