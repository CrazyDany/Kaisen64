ABILITY_ID_BLOODBOOST = 4

local function onUseBloodBoost()
    local used_chants = gPlayerSyncTable[0].Kaisen64.cur_chant or 0

    local m = gMarioStates[0]

    m.health = math.floor(m.health / ((0.75 ^ used_chants) + 1))

    AddRCTStateTimer(0, gPlayerSyncTable[0].Kaisen64.maxEnergy * (3 + (1.3 ^ used_chants)))
    for i, v in pairs(AbilitiesData) do
        if i ~= ABILITY_ID_BLOODBOOST then
            v.curCooldown = 0
        end
    end
end

RegisterAbility(ABILITY_ID_BLOODBOOST, {
    name = "BloodBoost",
    shortName = "BlBs",
    description = "Give away half of your health and gain energy reload boost.",
    iconTextureName = "blbs",

    cost = 32,
    cooldown = 512,
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
