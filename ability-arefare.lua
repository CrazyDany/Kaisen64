ABILITY_ID_AREFARE = 11

local function onUseArefare()
    local ability = AbilitiesData[ABILITY_ID_AREFARE]

    gPlayerSyncTable[0].arefareActive = true
    djui_chat_message_create("Activied")
end

local inAreFare = false
local areFareDist = 0

hook_event(HOOK_BEFORE_MARIO_UPDATE,
    function(m)
        if m.playerIndex ~= 0 then return end

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

        local distToNearsestAreFare = 0
        local finded = false
        local ability = AbilitiesData[ABILITY_ID_AREFARE]

        for i = 1, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].arefareActive then
                local dist = vec3f_dist(gMarioStates[i].pos, m.pos)
                if (dist < distToNearsestAreFare or not finded) and (dist <= ability.radius) then
                    distToNearsestAreFare = dist
                    finded = true
                end
            end
        end

        if finded then
            inAreFare = true
            areFareDist = distToNearsestAreFare
        else
            inAreFare = false
            areFareDist = 0
        end
    end
)

hook_event(HOOK_BEFORE_PHYS_STEP,
    function(m)
        if m.playerIndex ~= 0 then return end

        if inAreFare then
            djui_chat_message_create("AreFare")
            local ability = AbilitiesData[ABILITY_ID_AREFARE]

            local ratio = areFareDist / ability.radius
            m.vel.x = m.vel.x * (ratio ^ 4)
            m.vel.z = m.vel.z * (ratio ^ 4)
            m.vel.y = m.vel.y * (ratio ^ 4)

            -- if areFareDist < ability.stopRadius then
            --     m.vel.x = 0
            --     m.vel.z = 0
            --     m.vel.y = 0
            -- end
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
    energyPerTick = 3,
    radius = 1024,
    stopRadius = 512
})
