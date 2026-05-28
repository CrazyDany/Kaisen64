ABILITY_ID_SPLIZBLITZ = 11

function onUseSplizBlitz()
    gPlayerSyncTable[0].Kaisen64.afterimages_radius = 1
end

hook_event(HOOK_UPDATE,
    function()
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        if (gPlayerSyncTable[0].Kaisen64.afterimages_radius or 0) ~= 0 then
            local ability = AbilitiesData[ABILITY_ID_SPLIZBLITZ]

            if gPlayerSyncTable[0].Kaisen64.afterimages_radius < ability.afterimages_radius then
                gPlayerSyncTable[0].Kaisen64.afterimages_radius = math.lerp(
                    gPlayerSyncTable[0].Kaisen64.afterimages_radius,
                    ability.afterimages_radius,
                    24 / ability.afterimages_radius
                )
            end

            ability.curCooldown = ability.curCooldown + 1
            AddEnergy(0, -ability.afterimages_cost_per_tick)

            if (gPlayerSyncTable[0].Kaisen64.currentEnergy < ability.afterimages_cost_per_tick) then
                gPlayerSyncTable[0].Kaisen64.afterimages_radius = 0
            end

            if gMarioStates[0].controller.buttonPressed == L_TRIG and
                gPlayerSyncTable[0].Kaisen64.abilitiesSlots[gPlayerSyncTable[0].Kaisen64.currentAbilitySlot] == ABILITY_ID_SPLIZBLITZ
            then
                gPlayerSyncTable[0].Kaisen64.afterimages_radius = 0
            end

            if ChecIfHit(gMarioStates[0]) == true then
                gPlayerSyncTable[0].Kaisen64.afterimages_radius = 0
            end
        end
    end
)

hook_event(HOOK_MARIO_UPDATE,
    --- comment
    --- @param m MarioState
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end

        if m.playerIndex == 0 then
            return
        end

        if (gPlayerSyncTable[m.playerIndex].Kaisen64.afterimages_radius or 0) ~= 0 then
            m.marioObj.header.gfx.pos.x = m.marioObj.header.gfx.pos.x +
                random_float() * random_sign() * (gPlayerSyncTable[m.playerIndex].Kaisen64.afterimages_radius or 0)

            m.marioObj.header.gfx.pos.z = m.marioObj.header.gfx.pos.z +
                random_float() * random_sign() * (gPlayerSyncTable[m.playerIndex].Kaisen64.afterimages_radius or 0)
        end
    end
)

RegisterAbility(ABILITY_ID_SPLIZBLITZ, {
    name = "SplizBlitz",
    shortName = "SpBl",
    description = {
        "Constantly change your visible position and confuse enemies."
    },
    iconTextureName = "spbl",

    cost = 128,
    cooldown = 128,
    curCooldown = 0,

    onUseFunction = onUseSplizBlitz,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end,
    onResetVariables = function()
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        gPlayerSyncTable[0].Kaisen64.afterimages_radius = 0
    end,

    -- custom fields
    afterimages_radius = 2048,
    afterimages_cost_per_tick = 1
})
