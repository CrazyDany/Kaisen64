K64_MAX_ABILITIES_SLOTS = 3

hook_event(HOOK_UPDATE, function(...)
    if gPlayerSyncTable[0].Kaisen64 == nil then return end

    local m = gMarioStates[0]

    if m.controller.buttonPressed == R_JPAD then
        local newSlotIndex = (gPlayerSyncTable[0].Kaisen64.currentAbilitySlot + 1) % K64_MAX_ABILITIES_SLOTS

        gPlayerSyncTable[0].Kaisen64.currentAbilitySlot = newSlotIndex
        -- djui_chat_message_create("Current slot: " .. gPlayerSyncTable[0].Kaisen64.currentAbilitySlot)
    end

    if m.controller.buttonPressed == L_JPAD then
        local newSlotIndex = (gPlayerSyncTable[0].Kaisen64.currentAbilitySlot - 1) % K64_MAX_ABILITIES_SLOTS

        gPlayerSyncTable[0].Kaisen64.currentAbilitySlot = newSlotIndex
        -- djui_chat_message_create("Current slot: " .. gPlayerSyncTable[0].Kaisen64.currentAbilitySlot)
    end

    local selectedAbilityIndex = gPlayerSyncTable[0].Kaisen64.abilitiesSlots
        [gPlayerSyncTable[0].Kaisen64.currentAbilitySlot]

    local ability = AbilitiesData[selectedAbilityIndex]

    if ability ~= nil then
        if m.controller.buttonPressed == L_TRIG then
            if (ability.onTryUseFunction ~= nil) and (ability.curCooldown <= 0) and (gPlayerSyncTable[0].Kaisen64.currentEnergy >= ability.cost) then
                if ability.onTryUseFunction() == true then
                    AddEnergy(0, -ability.cost or 0)
                    ability.curCooldown = (ability.cooldown * GetCooldownSpeed(0)) or 0
                end
            end
        end

        -- djui_chat_message_create("Current cooldown: " .. (ability.curCooldown or 0))
    end
end)
