K64_DEFAULT_COOLDOWN_SPEED = 1

AbilitiesData = {
    [-1] = {
        name = "TemplateAbility",
        shortName = "TempSpell",
        description = "Ability placeholder for modders",
        iconTextureName = "ability-icon-locked",

        cost = 0,
        cooldown = 32,
        curCooldown = 0,

        onTryUseFunction = function() return true end,
        getExtraInfo = function()
            return { " - " }
        end
    }
}

function RegisterAbility(abilityID, abilityData)
    if AbilitiesData[abilityID] ~= nil then
        djui_chat_message_create("Ability with ID " .. abilityID .. " already exists!")
        return
    end

    AbilitiesData[abilityID] = abilityData
end

hook_event(HOOK_UPDATE, function(...)
    if gPlayerSyncTable[0].Kaisen64 == nil then return end

    -- Перезарядка
    for i, v in pairs(AbilitiesData) do
        if v.curCooldown > 0 then
            v.curCooldown = math.max(0, math.floor(v.curCooldown - 1))
        end
    end
end)

function SetCooldownSpeed(i, speed)
    if gPlayerSyncTable[i].Kaisen64 == nil then return end
    gPlayerSyncTable[i].Kaisen64.cooldownSpeed = math.max(0, speed)
end

function MultipleCooldownSpeed(i, multiplier)
    if gPlayerSyncTable[i].Kaisen64 == nil then return end
    gPlayerSyncTable[i].Kaisen64.cooldownSpeed = math.max(0, gPlayerSyncTable[i].Kaisen64.cooldownSpeed * multiplier)
end

function ResetCooldownSpeed(i)
    if gPlayerSyncTable[i].Kaisen64 == nil then return end
    gPlayerSyncTable[i].Kaisen64.cooldownSpeed = K64_DEFAULT_COOLDOWN_SPEED
end

function GetCooldownSpeed(i)
    if gPlayerSyncTable[i].Kaisen64 == nil then return end
    return gPlayerSyncTable[i].Kaisen64.cooldownSpeed or K64_DEFAULT_COOLDOWN_SPEED
end
