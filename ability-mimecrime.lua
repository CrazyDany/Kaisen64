ABILITY_ID_MIMECRIME = 9

local function onUseMimeCrime()
    local mimeCrimeAbility = AbilitiesData[ABILITY_ID_MIMECRIME]

    -- Cast copied ability
    if mimeCrimeAbility.copiedAbilityIndex ~= nil
        and AbilitiesData[mimeCrimeAbility.copiedAbilityIndex] ~= nil
        and AbilitiesData[mimeCrimeAbility.copiedAbilityIndex].getPermissibilityToUse() == true
    then
        AbilitiesData[mimeCrimeAbility.copiedAbilityIndex].onUseFunction()
        mimeCrimeAbility.copiedAbilityIndex = nil
        return
    end

    local m = gMarioStates[0]
    local targetIndex = AbilitiesData[ABILITY_ID_MIMECRIME].targetIndex
    local copiedAbilitySlotIndex = math.random(0, 2)
    local copiedAbilityIndex = gPlayerSyncTable[targetIndex].Kaisen64.abilitiesSlots[copiedAbilitySlotIndex]

    djui_chat_message_create("Copied " .. AbilitiesData[copiedAbilityIndex].shortName)

    AbilitiesData[ABILITY_ID_MIMECRIME].copiedAbilityIndex = copiedAbilityIndex
end

HookEvent_LocalMarioPVPAttack(
    function(v, i)
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        AbilitiesData[ABILITY_ID_MIMECRIME].targetIndex = v.playerIndex
    end
)

RegisterAbility(ABILITY_ID_MIMECRIME, {
    name = "MimeCrime",
    shortName = "MmCm",
    description = "Ability placeholder for modders",
    iconTextureName = "mmcm",

    cost = 128,
    cooldown = 256,
    curCooldown = 0,

    onUseFunction = onUseMimeCrime,
    getPermissibilityToUse = function()
        if AbilitiesData[ABILITY_ID_MIMECRIME].copiedAbilityIndex ~= nil then
            return AbilitiesData[AbilitiesData[ABILITY_ID_MIMECRIME].copiedAbilityIndex].getPermissibilityToUse()
        end

        return AbilitiesData[ABILITY_ID_MIMECRIME].targetIndex ~= 0 and
            AbilitiesData[ABILITY_ID_MIMECRIME].targetIndex ~= nil
    end,
    getExtraInfo = function()
        if AbilitiesData[ABILITY_ID_MIMECRIME].copiedAbilityIndex ~= nil then
            return { "Copied: " .. AbilitiesData[AbilitiesData[ABILITY_ID_MIMECRIME].copiedAbilityIndex].shortName }
        end

        local curTargetIndex = AbilitiesData[ABILITY_ID_MIMECRIME].targetIndex
        if (curTargetIndex ~= nil) and (curTargetIndex ~= 0) and (gMarioStates[curTargetIndex] ~= nil) then
            local ability = AbilitiesData[ABILITY_ID_MIMECRIME]
            local targetIndex = ability.targetIndex
            local targetAbilities = {
                "Target ailities: ",
                "   > " .. AbilitiesData[gPlayerSyncTable[targetIndex].Kaisen64.abilitiesSlots[0]].shortName,
                "   > " .. AbilitiesData[gPlayerSyncTable[targetIndex].Kaisen64.abilitiesSlots[1]].shortName,
                "   > " .. AbilitiesData[gPlayerSyncTable[targetIndex].Kaisen64.abilitiesSlots[2]].shortName
            }

            return targetAbilities
        else
            return { " - " }
        end
    end,

    -- custom fields
    targetIndex = 0,
    copiedAbilityIndex = nil
})
