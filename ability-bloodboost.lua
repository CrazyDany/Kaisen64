ABILITY_ID_BLOODBOOST = 4

local function onUseBloodBoost()
    local m = gMarioStates[0]

    m.health = m.health / 2

    AddRCTStateTimer(0, gPlayerSyncTable[0].Kaisen64.maxEnergy * 3)
    for i, v in pairs(AbilitiesData) do
        if i ~= ABILITY_ID_BLOODBOOST then
            v.curCooldown = 0
        end
    end
end

RegisterAbility(ABILITY_ID_BLOODBOOST, {
    name = "BloodBoost",
    shortName = "BlBo",
    description = "Ability placeholder for modders",
    iconTextureName = "rgtc",

    cost = 32,
    cooldown = 1024,
    curCooldown = 0,

    onUseFunction = onUseBloodBoost,
    getPermissibilityToUse = function()
        local m = gMarioStates[0]
        return m.health > 128
    end,
    getExtraInfo = function()
        return { " - " }
    end
})
