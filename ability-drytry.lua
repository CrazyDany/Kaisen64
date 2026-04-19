ABILITY_ID_DRYTRY = 1

local function onUseDryTry()
    return true
end

RegisterAbility(ABILITY_ID_DRYTRY, {
    name = "Dry Try",
    shortName = "DrTr",
    description = "",
    iconTextureName = "rgtc",

    cost = 32,
    cooldown = 64,
    curCooldown = 0,

    onTryUseFunction = onUseDryTry,
    getExtraInfo = function()
        return { " - " }
    end

    -- кастомные поля

})
