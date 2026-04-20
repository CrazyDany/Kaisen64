-- name: Kaisen64
-- description: Kaisen64

hook_event(HOOK_UPDATE, function()
    if gPlayerSyncTable[0].Kaisen64 == nil then
        gPlayerSyncTable[0].Kaisen64 = {}

        gPlayerSyncTable[0].Kaisen64.currentEnergy = K64_DEFAULT_START_ENERGY
        gPlayerSyncTable[0].Kaisen64.maxEnergy = K64_DEFAULT_MAX_ENERGY
        gPlayerSyncTable[0].Kaisen64.regenEnergy = K64_DEFAULT_REGEN_ENERGY
        gPlayerSyncTable[0].Kaisen64.regenEnergyTick = K64_DEFAULT_REGEN_ENERGY_TICK
        gPlayerSyncTable[0].Kaisen64.RCTStateTimer = 0
        gPlayerSyncTable[0].Kaisen64.RCTStateEnergyRegen = K64_DEFAULT_RCT_STATE_ENERGY_REGEN
        gPlayerSyncTable[0].Kaisen64.RCTStateTick = K64_DEFAULT_RCT_STATE_TICK

        gPlayerSyncTable[0].Kaisen64.abilitiesSlots = {}

        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[0] = ABILITY_ID_SWITCHSWAP
        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[1] = ABILITY_ID_SWITCHSWAP
        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[2] = ABILITY_ID_SWITCHSWAP

        gPlayerSyncTable[0].Kaisen64.currentAbilitySlot = 0

        gPlayerSyncTable[0].Kaisen64.playingTheme = nil

        djui_chat_message_create("Система Kaisen64 успешно добавлена!")
    end
end)

local function onCommandKaien64(msg)
    if not IsModMenuOpened() then
        OpenModMenu()
    end

    return true
end

hook_chat_command("kaisen64", "Начало работы с Kaisen64", onCommandKaien64)
hook_chat_command("k64", "Начало работы с Kaisen64", onCommandKaien64)
