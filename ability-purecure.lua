ABILITY_ID_PURECURE = 2

local function onUsePureCure()
    local m = gMarioStates[0]

    local used_chants = gPlayerSyncTable[0].Kaisen64.cur_chant or 0

    m.health = m.health + 512 + (64 * used_chants)
    ClearAllEffects(m)
end

RegisterAbility(ABILITY_ID_PURECURE, {
    name = "PureCure",
    shortName = "PuCu",
    description = {
        "Heal yourself and also get cured from any negative effect."
    },
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
