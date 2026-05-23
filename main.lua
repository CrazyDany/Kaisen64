-- name: \\#FFC401\\Kaisen 64
-- category: gamemode
-- incompatible: gamemode moveset romhack cs
-- description: \\#FFC401\\Kaisen 64\n\n\\#FFFFFF\\Kaisen 64 is a mod that adds a fight club of the tired \\#FFC401\\Devil Bullies\n\n\\#FFFFFF\\In their quest of defeating \\#FA0000\\Mario\\#FFFFFF\\, they've unlocked magical techniques using the energy of the Power Stars and are now ready to train against each other.\n\nUnlock a vast and unique magic system with a wide variety of abilities and effects, inspired by the Jujutsu Kaisen franchise.\n\nUse your favorite characters abilities or just enjoy the mod's combat system and compete against your friends.
-- pausable: false

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

        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[0] = ABILITY_ID_RECTECH
        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[1] = ABILITY_ID_DRYTRY
        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[2] = ABILITY_ID_CLAPSWAP

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

        hud_hide()

        djui_chat_message_create("Система Kaisen64 успешно добавлена!")
    end
end)


local function onCommandKaien64(msg)
    if not IsModMenuOpened() and not IsGameStarted() then
        OpenModMenu()
    end

    return true
end

hook_chat_command("kaisen64", "Начало работы с Kaisen64", onCommandKaien64)
hook_chat_command("k64", "Начало работы с Kaisen64", onCommandKaien64)

HookEvent_LocalMarioPVPAttack(
--- @param v MarioState
--- @param i integer
    function(v, i)
        -- djui_chat_message_create("Attack.")
    end
)

HookEvent_LocalMarioPVPDamage(
--- @param a MarioState
--- @param i integer
    function(a, i)
        local m = gMarioStates[0]
        m.health = m.health - 150
        -- djui_chat_message_create("Damage.")
    end
)
