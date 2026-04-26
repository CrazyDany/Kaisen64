-- name: Kaisen64
-- description: Kaisen64

LEVEL_ARENA = level_register('level_arena_entry', COURSE_NONE, 'Arena', 'arena', 28000, 0x28, 0x28, 0x28)

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
        gPlayerSyncTable[0].Kaisen64.cooldownSpeed = K64_DEFAULT_COOLDOWN_SPEED

        gPlayerSyncTable[0].Kaisen64.abilitiesSlots = {}

        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[0] = ABILITY_ID_SMALLTALL
        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[1] = ABILITY_ID_DRYTRY
        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[2] = ABILITY_ID_SWITCHSWAP

        gPlayerSyncTable[0].Kaisen64.currentAbilitySlot = 0

        gPlayerSyncTable[0].Kaisen64.playingTheme = nil


        -- Загрузка сохранененых штук
        -- local modFs = mod_fs_get() or mod_fs_create()
        -- local energyColorFile = modFs:get_file("energybarcolor.txt") or modFs:create_file("energybarcolor.txt", true)
        -- local energyColorString = energyColorFile:read_string()
        -- djui_chat_message_create("energybarcolor.txt: " .. energyColorString)
        local loadedEnergyColorR = mod_storage_load_number("customenergycolor.r")
        local loadedEnergyColorG = mod_storage_load_number("customenergycolor.g")
        local loadedEnergyColorB = mod_storage_load_number("customenergycolor.b")

        SetCustomEnergyColor(K64_HUD_DEFAULT_ENERGY_COLOR.r, K64_HUD_DEFAULT_ENERGY_COLOR.g,
            K64_HUD_DEFAULT_ENERGY_COLOR.b)

        if loadedEnergyColorR ~= 0 or loadedEnergyColorG ~= 0 or loadedEnergyColorB ~= 0 then
            SetCustomEnergyColor(loadedEnergyColorR, loadedEnergyColorG, loadedEnergyColorB)
        end

        warp_to_level(LEVEL_ARENA, 1, 0)

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
