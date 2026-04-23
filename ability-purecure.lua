ABILITY_ID_PURECURE = 3

function onUsePureCure()
    local m = gMarioStates[0]

    m.health = m.health + 512
end

RegisterAbility(ABILITY_ID_PURECURE, {
    name = "PureCure",
    shortName = "PuCu",
    description = "",
    iconTextureName = "rgtc",

    cost = 512,
    cooldown = 1024,
    curCooldown = 0,

    onUseFunction = onUsePureCure,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end
})
