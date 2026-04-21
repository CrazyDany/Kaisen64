K64_HUD_DEFAULT_ENERGY_COLOR = { r = 171, g = 205, b = 239 }

local function renderAbilitiesSlots()
    SlotSize = 80
    local slotPadding = 8

    local slotsCount = K64_MAX_ABILITIES_SLOTS

    local slotsX = (djui_hud_get_screen_width() - (SlotSize * slotsCount + (slotPadding * (slotsCount - 1)))) / 2
    local slotsY = djui_hud_get_screen_height() - SlotSize - slotPadding

    for i = 0, slotsCount - 1 do
        local abilityId = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[i]
        -- djui_chat_message_create("Ability ID: " .. abilityId)
        local abilityData = AbilitiesData[abilityId]

        djui_hud_set_color(40, 44, 52, 255)
        if gPlayerSyncTable[0].Kaisen64.currentAbilitySlot == i then
            djui_hud_set_color(50, 56, 6, 255)
        end
        djui_hud_render_rect(slotsX + (SlotSize + slotPadding) * i, slotsY, SlotSize, SlotSize)

        if abilityData ~= nil then
            djui_hud_set_color(33, 37, 43, 255)
            if gPlayerSyncTable[0].Kaisen64.currentAbilitySlot == i then
                djui_hud_set_color(40, 44, 52, 255)
            end

            if abilityData.curCooldown > 0 then
                local cooldownProportion = abilityData.curCooldown / abilityData.cooldown
                djui_hud_render_rect(slotsX + (SlotSize + slotPadding) * i, slotsY, SlotSize,
                    SlotSize * cooldownProportion)
            end
        end

        if abilityData ~= nil then
            djui_hud_set_color(127, 127, 127, 255)
            if gPlayerSyncTable[0].Kaisen64.currentAbilitySlot == i then
                djui_hud_set_color(255, 255, 255, 255)
            end

            if abilityData.curCooldown > 0 then
                djui_hud_set_color(31, 31, 31, 255)
            end

            local abilityShortName = abilityData.shortName or "???"
            local textScale = 0.8
            local textWidth = djui_hud_measure_text(abilityShortName)
            djui_hud_print_text(abilityShortName, slotsX + (SlotSize + slotPadding) * i + (SlotSize - textWidth) / 2,
                slotsY + SlotSize / 2, textScale)
        end
    end
end

local customEnergyColor = nil
function SetCustomEnergyColor(r, g, b)
    customEnergyColor = {
        r = r or K64_HUD_DEFAULT_ENERGY_COLOR.r,
        g = g or K64_HUD_DEFAULT_ENERGY_COLOR.g,
        b = b or K64_HUD_DEFAULT_ENERGY_COLOR.b
    }
end

local function renderEnergyBar()
    local barWidth = 512
    local barHeight = 24
    local barPadding = 4

    local barX = (djui_hud_get_screen_width() - barWidth) / 2
    local barY = djui_hud_get_screen_height() - barHeight * 2 - SlotSize

    local energy = gPlayerSyncTable[0].Kaisen64.currentEnergy or 0
    local maxEnergy = gPlayerSyncTable[0].Kaisen64.maxEnergy or K64_DEFAULT_MAX_ENERGY
    local energyProportion = energy / maxEnergy

    djui_hud_set_font(FONT_MENU)

    local text = "Energy:" .. energy .. "/" .. maxEnergy
    local textScale = 0.6
    local textWidth = djui_hud_measure_text(text) * textScale

    djui_hud_set_color(31, 31, 31, 255)
    djui_hud_render_rect(barX, barY, barWidth, barHeight)
    djui_hud_set_color(171, 205, 239, 255)
    if customEnergyColor ~= nil then
        djui_hud_set_color(customEnergyColor.r, customEnergyColor.g, customEnergyColor.b, 255)
    end
    djui_hud_render_rect(barX + barPadding, barY + barPadding, barWidth * energyProportion - (2 * barPadding),
        barHeight - (2 * barPadding))

    -- рендер цены способности на баре
    local abilityId = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[gPlayerSyncTable[0].Kaisen64.currentAbilitySlot]
    local ability = AbilitiesData[abilityId]
    if ability.curCooldown <= 0 and gPlayerSyncTable[0].Kaisen64.currentEnergy >= ability.cost then
        local abilityCost = AbilitiesData[abilityId].cost or 0
        local abilityCostProportion = abilityCost / maxEnergy
        local abilityCostBarWidth = barWidth * abilityCostProportion
        djui_hud_set_color(255, 0, 0, 255)
        djui_hud_render_rect(barX + barPadding + barWidth * energyProportion - (2 * barPadding) - abilityCostBarWidth,
            barY + barPadding,
            abilityCostBarWidth,
            barHeight - (2 * barPadding))
    end

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, barX + barWidth / 2 - textWidth / 2, barY + barHeight / 2 - 32, textScale)
end

local function rednerAbilityExtraInfo()
    local tableX = djui_hud_get_screen_width() * 3 / 4
    local tableY = djui_hud_get_screen_height() * 1 / 5

    local abilityId = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[gPlayerSyncTable[0].Kaisen64.currentAbilitySlot]
    local abilityExtraInfo = AbilitiesData[abilityId].getExtraInfo() or { "-" }

    for i, v in pairs(abilityExtraInfo) do
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(v, tableX, tableY + 16 * i, 0.5)
    end
end

local function onHudRender()
    if IsModMenuOpened() or gPlayerSyncTable[0].Kaisen64 == nil then return end

    renderAbilitiesSlots()
    renderEnergyBar()
    rednerAbilityExtraInfo()
end

hook_event(HOOK_ON_HUD_RENDER, onHudRender)
