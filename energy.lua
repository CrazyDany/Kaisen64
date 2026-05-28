K64_DEFAULT_START_ENERGY = 1024
K64_DEFAULT_MAX_ENERGY = 1024
K64_DEFAULT_REGEN_ENERGY = 1
K64_DEFAULT_REGEN_ENERGY_TICK = 4
K64_DEFAULT_RCT_STATE_TICK = 1
K64_DEFAULT_RCT_STATE_ENERGY_REGEN = 2

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

        local RCTStateTimer = gPlayerSyncTable[0].Kaisen64.RCTStateTimer or 0
        local RCTStateEnergyRegen = gPlayerSyncTable[0].Kaisen64.RCTStateEnergyRegen or
            K64_DEFAULT_RCT_STATE_ENERGY_REGEN
        local RCTStateTick = gPlayerSyncTable[0].Kaisen64.RCTStateTick or K64_DEFAULT_RCT_STATE_TICK

        if get_global_timer() % RCTStateTick == 0 then
            if RCTStateTimer > 0 then
                gPlayerSyncTable[0].Kaisen64.RCTStateTimer = RCTStateTimer - 1
                AddEnergy(0, RCTStateEnergyRegen)
            elseif RCTStateTimer < 0 then
                gPlayerSyncTable[0].Kaisen64.RCTStateTimer = RCTStateTimer + 1
                AddEnergy(0, -RCTStateEnergyRegen)
            end
        end
        -- djui_chat_message_create("RCTStateTimer: " .. gPlayerSyncTable[0].Kaisen64.RCTStateTimer)
    end
)

function AddEnergy(i, amount)
    if gPlayerSyncTable[i].Kaisen64 == nil then return end

    local maxEnergy = gPlayerSyncTable[i].Kaisen64.maxEnergy or K64_DEFAULT_MAX_ENERGY
    gPlayerSyncTable[i].Kaisen64.maxEnergy = gPlayerSyncTable[i].Kaisen64.maxEnergy or K64_DEFAULT_MAX_ENERGY

    gPlayerSyncTable[i].Kaisen64.currentEnergy = math.floor(math.clamp(
        (gPlayerSyncTable[i].Kaisen64.currentEnergy or 0) + amount, 0, maxEnergy))
end

function AddRCTStateTimer(i, amount)
    if gPlayerSyncTable[i].Kaisen64 == nil then return end
    gPlayerSyncTable[i].Kaisen64.RCTStateTimer = math.floor((gPlayerSyncTable[i].Kaisen64.RCTStateTimer or 0) + amount)
end

hook_chat_command('k64-maxenergy', 'Установить максимальное кол-во энергии [maxEnergy | natural]',
    function(msg)
        if not IsDevModActivated() then
            djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
            return false
        end

        local inputedMaxEnergy = tonumber(msg)

        if inputedMaxEnergy == nil then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        if math.floor(inputedMaxEnergy) ~= inputedMaxEnergy then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        if inputedMaxEnergy < 0 then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        gPlayerSyncTable[0].Kaisen64.maxEnergy = inputedMaxEnergy
        return true
    end
)

hook_chat_command('k64-regenenergy', 'Установить скорость регенерации энергии [regenEnergy | natural]',
    function(msg)
        if not IsDevModActivated() then
            djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
            return false
        end

        local inputedRegenEnergy = tonumber(msg)

        if inputedRegenEnergy == nil then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        if math.floor(inputedRegenEnergy) ~= inputedRegenEnergy then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        if inputedRegenEnergy < 0 then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        gPlayerSyncTable[0].Kaisen64.regenEnergy = inputedRegenEnergy
        return true
    end
)

hook_chat_command('k64-regenenergy-tick', 'Установить скорость регенерации энергии [regenEnergyTick | natural]',
    function(msg)
        if not IsDevModActivated() then
            djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
            return false
        end

        local inputedRegenEnergyTick = tonumber(msg)

        if inputedRegenEnergyTick == nil then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        if math.floor(inputedRegenEnergyTick) ~= inputedRegenEnergyTick then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        if inputedRegenEnergyTick < 0 then
            djui_chat_message_create("Аргумент функции должен быть натуральным числом.")
            return false
        end

        gPlayerSyncTable[0].Kaisen64.regenEnergyTick = inputedRegenEnergyTick
        return true
    end
)


hook_chat_command('k64-addrctstatetimer', 'Добавить RCTStateTimer [RCTStateTimer | integer]',
    function(msg)
        if not IsDevModActivated() then
            djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
            return false
        end

        local inputedRCTStateTimer = tonumber(msg)

        if inputedRCTStateTimer == nil then
            djui_chat_message_create("Аргумент функции должен быть целым числом.")
            return false
        end

        if math.floor(inputedRCTStateTimer) ~= inputedRCTStateTimer then
            djui_chat_message_create("Аргумент функции должен быть целым числом.")
            return false
        end

        gPlayerSyncTable[0].Kaisen64.RCTStateTimer = (gPlayerSyncTable[0].Kaisen64.RCTStateTimer or 0) +
            inputedRCTStateTimer
        return true
    end
)
