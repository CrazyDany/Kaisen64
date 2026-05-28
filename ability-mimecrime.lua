ABILITY_ID_MIMECRIME = 9

local function onUseMimeCrime()
    local mimeCrime = AbilitiesData[ABILITY_ID_MIMECRIME]
    if mimeCrime.copiedAbilityIndex ~= nil then
        local copied = AbilitiesData[mimeCrime.copiedAbilityIndex]
        if copied ~= nil and copied.getPermissibilityToUse() == true then
            copied.onUseFunction()
            if mimeCrime.originalCost then
                mimeCrime.cost = mimeCrime.originalCost
                mimeCrime.cooldown = mimeCrime.originalCooldown
                mimeCrime.originalCost = nil
                mimeCrime.originalCooldown = nil
            end
            mimeCrime.copiedAbilityIndex = nil
            mimeCrime.targetIndex = 0
        end
        return
    end

    local targetIdx = mimeCrime.targetIndex
    if targetIdx == nil or targetIdx == 0 then
        return
    end

    local targetSync = gPlayerSyncTable[targetIdx]
    if targetSync == nil or targetSync.Kaisen64 == nil then
        return
    end

    local slot = math.random(0, 2)
    local copiedIdx = targetSync.Kaisen64.abilitiesSlots[slot]
    local copiedAbility = AbilitiesData[copiedIdx]

    if copiedIdx == ABILITY_ID_MIMECRIME then
        djui_chat_message_create("Cannot copy MimeCrime itself!")
        return
    end

    if copiedAbility == nil then
        return
    end

    if mimeCrime.originalCost == nil then
        mimeCrime.originalCost = mimeCrime.cost
        mimeCrime.originalCooldown = mimeCrime.cooldown
    end

    mimeCrime.cost = copiedAbility.cost
    mimeCrime.cooldown = copiedAbility.cooldown

    mimeCrime.copiedAbilityIndex = copiedIdx

    mimeCrime.targetIndex = 0

    djui_chat_message_create("Copied " .. copiedAbility.shortName)
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
    description = {
        "Steal a random ability from your last hit player."
    },
    iconTextureName = "mmcm",

    cost = 128,
    cooldown = 256,
    curCooldown = 0,

    onUseFunction = onUseMimeCrime,

    getPermissibilityToUse = function()
        local mimeCrime = AbilitiesData[ABILITY_ID_MIMECRIME]
        if mimeCrime.copiedAbilityIndex ~= nil then
            local copied = AbilitiesData[mimeCrime.copiedAbilityIndex]
            if copied == nil then return false end
            return copied.getPermissibilityToUse()
        else
            local targetIdx = mimeCrime.targetIndex
            return targetIdx ~= nil and targetIdx ~= 0
        end
    end,

    getExtraInfo = function()
        local mimeCrime = AbilitiesData[ABILITY_ID_MIMECRIME]
        if mimeCrime.copiedAbilityIndex ~= nil then
            local copied = AbilitiesData[mimeCrime.copiedAbilityIndex]
            if copied then
                return { "Copied: " .. copied.shortName, "Cost: " .. copied.cost, "Cooldown: " .. copied.cooldown }
            end
        end

        local targetIdx = mimeCrime.targetIndex
        if targetIdx ~= nil and targetIdx ~= 0 and gMarioStates[targetIdx] ~= nil then
            local targetSync = gPlayerSyncTable[targetIdx]
            if targetSync and targetSync.Kaisen64 then
                local slots = targetSync.Kaisen64.abilitiesSlots
                return {
                    "Target abilities:",
                    "   > " .. AbilitiesData[slots[0]].shortName,
                    "   > " .. AbilitiesData[slots[1]].shortName,
                    "   > " .. AbilitiesData[slots[2]].shortName
                }
            end
        end
        return { " - " }
    end,

    onResetVariables = function()
        local mimeCrime = AbilitiesData[ABILITY_ID_MIMECRIME]
        mimeCrime.targetIndex = 0
        mimeCrime.copiedAbilityIndex = nil
        if mimeCrime.originalCost then
            mimeCrime.cost = mimeCrime.originalCost
            mimeCrime.cooldown = mimeCrime.originalCooldown
            mimeCrime.originalCost = nil
            mimeCrime.originalCooldown = nil
        end
        mimeCrime.curCooldown = 0
    end,

    targetIndex = 0,
    copiedAbilityIndex = nil,
    originalCost = nil,
    originalCooldown = nil
})
