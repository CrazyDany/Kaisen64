K64_DEFAULT_START_ENERGY = 1024
K64_DEFAULT_MAX_ENERGY = 1024
K64_DEFAULT_REGEN_ENERGY = 1
K64_DEFAULT_REGEN_ENERGY_TICK = 4

-- Регенерация энергии
hook_event(HOOK_UPDATE,
    function()
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        local regenEnergy = gPlayerSyncTable[0].Kaisen64.regenEnergy or K64_DEFAULT_REGEN_ENERGY
        local regenEnergyTick = gPlayerSyncTable[0].Kaisen64.regenEnergyTick or K64_DEFAULT_REGEN_ENERGY_TICK

        if get_global_timer() % regenEnergyTick == 0 then
            AddEnergy(0, regenEnergy)
        end

        local energy = gPlayerSyncTable[0].Kaisen64.currentEnergy or 0
        local maxEnergy = gPlayerSyncTable[0].Kaisen64.maxEnergy or K64_DEFAULT_MAX_ENERGY

        -- djui_chat_message_create("Energy: " .. energy .. "/" .. maxEnergy)
    end
)

function AddEnergy(i, amount)
    if gPlayerSyncTable[0].Kaisen64 == nil then return end

    local maxEnergy = gPlayerSyncTable[i].Kaisen64.maxEnergy or K64_DEFAULT_MAX_ENERGY
    gPlayerSyncTable[i].Kaisen64.maxEnergy = gPlayerSyncTable[i].Kaisen64.maxEnergy or K64_DEFAULT_MAX_ENERGY

    gPlayerSyncTable[i].Kaisen64.currentEnergy = math.floor(math.clamp(
        (gPlayerSyncTable[i].Kaisen64.currentEnergy or 0) + amount, 0, maxEnergy))
end
