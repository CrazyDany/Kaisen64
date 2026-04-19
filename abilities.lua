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
            v.curCooldown = v.curCooldown - 1
        end
    end
end)
