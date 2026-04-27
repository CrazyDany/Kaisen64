K64_HUD_DEFAULT_ENERGY_COLOR = { r = 171, g = 205, b = 239 }

local customEnergyColor = nil
function SetCustomEnergyColor(r, g, b)
    customEnergyColor = {
        r = r or K64_HUD_DEFAULT_ENERGY_COLOR.r,
        g = g or K64_HUD_DEFAULT_ENERGY_COLOR.g,
        b = b or K64_HUD_DEFAULT_ENERGY_COLOR.b
    }
end

local HUDSettings = {
    font = FONT_MENU,

    refWidth = 1920,
    refHeight = 1080,

    slots = {
        relativeSize = 0.08,
        relativePadding = 0.01,
        bottomOffset = 0.02,
        bgColor = { 35, 39, 46, 220 },
        selectedBgColor = { 50, 56, 60, 220 },
        cooldownColor = { 0, 0, 0, 180 },
        borderColor = { 255, 215, 0, 200 },
        textColor = { 220, 220, 220, 255 },
        textCooldownColor = { 100, 100, 100, 255 },
        textSelectedColor = { 255, 255, 255, 255 },
        cdTextScale = 0.65,
    },

    energyBar = {
        relativeWidth = 0.3,
        relativeHeight = 0.025,
        bottomOffset = 0.12,
        bgColor = { 31, 31, 31, 200 },
        fillColors = { { 171, 205, 239, 255 }, { 100, 180, 250, 255 } },
        costColor = { 255, 80, 80, 200 },
        textColor = { 255, 255, 255, 255 },
        textScale = 0.55,
        showNumbers = true,
        timerIndicatorColor = { 50, 70, 100, 200 },
        maxTimerEffect = 200,
    },

    healthBar = {
        relativeWidth = 0.35,
        relativeHeight = 0.04,
        topOffset = 0.06,
        bgColor = { 31, 31, 31, 200 },
        fillColor = { 80, 200, 80, 255 },
        textColor = { 255, 255, 255, 255 },
        textScale = 0.55,
        showNumbers = true,
    },

    extraInfo = {
        relativeWidth = 0.28,
        relativeX = 0.70,
        relativeY = 0.15,
        padding = 12,
        bgColor = { 0, 0, 0, 180 },
        textColor = { 255, 255, 255, 255 },
        titleColor = nil,
        fontSize = 0.5,
        lineHeight = 26,
        maxLines = 6,
    },
}

local function getAdaptiveScale(baseScale)
    local sw, sh = djui_hud_get_screen_width(), djui_hud_get_screen_height()
    local scaleW = sw / HUDSettings.refWidth
    local scaleH = sh / HUDSettings.refHeight
    local uniformScale = math.min(scaleW, scaleH)
    return baseScale * uniformScale
end

local function getCooldownText(cooldownFrames)
    if cooldownFrames <= 0 then return nil end
    return tostring(math.floor(cooldownFrames))
end

local function getCurrentEnergyColor()
    if customEnergyColor then
        return customEnergyColor.r, customEnergyColor.g, customEnergyColor.b
    else
        return K64_HUD_DEFAULT_ENERGY_COLOR.r, K64_HUD_DEFAULT_ENERGY_COLOR.g, K64_HUD_DEFAULT_ENERGY_COLOR.b
    end
end

local hudElements = {}

local function registerHudElement(name, drawFunc, priority, activeFunc)
    table.insert(hudElements, {
        name = name,
        draw = drawFunc,
        priority = priority or 100,
        isActive = activeFunc or function() return true end
    })
    table.sort(hudElements, function(a, b) return a.priority < b.priority end)
end

local function renderAbilitiesSlots()
    local settings = HUDSettings.slots
    local sw, sh = djui_hud_get_screen_width(), djui_hud_get_screen_height()

    local slotSize = sh * settings.relativeSize
    local padding = sw * settings.relativePadding
    local slotsCount = K64_MAX_ABILITIES_SLOTS

    local totalWidth = slotSize * slotsCount + padding * (slotsCount - 1)
    local startX = (sw - totalWidth) / 2
    local y = sh - slotSize - sh * settings.bottomOffset

    local textScale = 0.4 * (slotSize / 80) * getAdaptiveScale(1)

    for i = 0, slotsCount - 1 do
        local abilityId = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[i]
        local abilityData = AbilitiesData[abilityId]
        local isSelected = (gPlayerSyncTable[0].Kaisen64.currentAbilitySlot == i)
        local x = startX + (slotSize + padding) * i

        local bgColor = isSelected and settings.selectedBgColor or settings.bgColor
        djui_hud_set_color(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
        djui_hud_render_rect(x, y, slotSize, slotSize)

        if isSelected then
            local bw = 3
            djui_hud_set_color(settings.borderColor[1], settings.borderColor[2], settings.borderColor[3],
                settings.borderColor[4])
            djui_hud_render_rect(x - bw, y - bw, slotSize + bw * 2, bw)
            djui_hud_render_rect(x - bw, y + slotSize, slotSize + bw * 2, bw)
            djui_hud_render_rect(x - bw, y, bw, slotSize)
            djui_hud_render_rect(x + slotSize, y, bw, slotSize)
        end

        if abilityData then
            if abilityData.curCooldown > 0 then
                local ratio = abilityData.curCooldown / abilityData.cooldown
                djui_hud_set_color(settings.cooldownColor[1], settings.cooldownColor[2], settings.cooldownColor[3],
                    settings.cooldownColor[4])
                djui_hud_render_rect(x, y + slotSize * (1 - ratio), slotSize, slotSize * ratio)
            end

            local displayText = abilityData.shortName or "????"
            local textColor = isSelected and settings.textSelectedColor or settings.textColor
            if abilityData.curCooldown > 0 then textColor = settings.textCooldownColor end
            djui_hud_set_font(HUDSettings.font)
            djui_hud_set_color(textColor[1], textColor[2], textColor[3], textColor[4])
            local textWidth = djui_hud_measure_text(displayText) * textScale
            djui_hud_print_text(displayText, x + (slotSize - textWidth) / 2, y + slotSize / 2 - 6, textScale)

            if abilityData.curCooldown > 0 then
                local cdText = getCooldownText(abilityData.curCooldown)
                if cdText then
                    djui_hud_set_font(HUDSettings.font)
                    djui_hud_set_color(255, 255, 255, 220)
                    local cdScale = settings.cdTextScale * (slotSize / 80) * getAdaptiveScale(1)
                    local cdWidth = djui_hud_measure_text(cdText) * cdScale
                    djui_hud_print_text(cdText, x + (slotSize - cdWidth) / 2, y + slotSize - 16, cdScale)
                end
            end
        else
            djui_hud_set_font(HUDSettings.font)
            djui_hud_set_color(100, 100, 100, 150)
            local textScaleEmpty = 0.6 * (slotSize / 80) * getAdaptiveScale(1)
            djui_hud_print_text("—", x + slotSize / 2 - 4, y + slotSize / 2 - 6, textScaleEmpty)
        end
    end
end

local function renderEnergyBar()
    local settings = HUDSettings.energyBar
    local sw, sh = djui_hud_get_screen_width(), djui_hud_get_screen_height()

    local barWidth = sw * settings.relativeWidth
    local barHeight = sh * settings.relativeHeight
    local y = sh - barHeight - sh * settings.bottomOffset
    local x = (sw - barWidth) / 2

    local energy = gPlayerSyncTable[0].Kaisen64.currentEnergy or 0
    local maxEnergy = gPlayerSyncTable[0].Kaisen64.maxEnergy or K64_DEFAULT_MAX_ENERGY
    local fillPercent = math.min(1, energy / maxEnergy)
    local fillWidth = barWidth * fillPercent

    local rctTimer = gPlayerSyncTable[0].Kaisen64.RCTStateTimer or 0
    local timerEffect = 0
    local timerSign = 0
    if rctTimer ~= 0 then
        timerSign = (rctTimer > 0) and 1 or -1
        local absTimer = math.abs(rctTimer)
        local effectRatio = math.min(1, absTimer / settings.maxTimerEffect)
        timerEffect = effectRatio * barWidth * 0.5
    end

    djui_hud_set_color(settings.bgColor[1], settings.bgColor[2], settings.bgColor[3], settings.bgColor[4])
    djui_hud_render_rect(x, y, barWidth, barHeight)

    if fillWidth > 0 then
        local r, gb, bb = getCurrentEnergyColor()
        djui_hud_set_color(r, gb, bb, 255)
        djui_hud_render_rect(x + 2, y + 2, fillWidth - 4, barHeight - 4)
    end

    if timerEffect > 0 and timerSign ~= 0 then
        local indicatorX, indicatorWidth
        if timerSign > 0 then
            indicatorX = x + fillWidth
            indicatorWidth = math.min(timerEffect, barWidth - fillWidth)
        else
            indicatorX = x + math.max(0, fillWidth - timerEffect)
            indicatorWidth = math.min(timerEffect, fillWidth)
        end
        if indicatorWidth > 0 then
            djui_hud_set_color(settings.timerIndicatorColor[1], settings.timerIndicatorColor[2],
                settings.timerIndicatorColor[3], settings.timerIndicatorColor[4])
            djui_hud_render_rect(indicatorX + 2, y + 2, indicatorWidth - 4, barHeight - 4)
        end
    end

    local abilityId = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[gPlayerSyncTable[0].Kaisen64.currentAbilitySlot]
    local ability = AbilitiesData[abilityId]
    if ability and ability.cost and ability.cost > 0 then
        local isOffCooldown = (ability.curCooldown <= 0)
        local isPermissible = (ability.getPermissibilityToUse and ability.getPermissibilityToUse()) or true
        if isOffCooldown and isPermissible then
            local costPercent = ability.cost / maxEnergy
            local costWidth = barWidth * costPercent
            local costX = x + fillWidth - costWidth
            if costX < x then costX = x end
            local actualCostWidth = math.min(costWidth, fillWidth + (x + fillWidth - costX))
            if actualCostWidth > 0 then
                djui_hud_set_color(settings.costColor[1], settings.costColor[2], settings.costColor[3],
                    settings.costColor[4])
                djui_hud_render_rect(costX + 2, y + 2, actualCostWidth - 4, barHeight - 4)
            end
        end
    end
    if settings.showNumbers then
        local text = string.format("%d/%d", math.floor(energy), maxEnergy)
        djui_hud_set_font(HUDSettings.font)
        djui_hud_set_color(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4])
        local adaptiveScale = getAdaptiveScale(settings.textScale)
        local textWidth = djui_hud_measure_text(text) * adaptiveScale
        local textX = x + (barWidth - textWidth) / 2
        local textY = y - 24 * adaptiveScale
        djui_hud_print_text(text, textX, textY, adaptiveScale)
    end
end

local function renderHealthBar()
    local settings = HUDSettings.healthBar
    local sw, sh = djui_hud_get_screen_width(), djui_hud_get_screen_height()

    local barWidth = sw * settings.relativeWidth
    local barHeight = sh * settings.relativeHeight
    local y = sh * settings.topOffset
    local x = (sw - barWidth) / 2

    local mario = gMarioStates[0]
    if not mario then return end

    local realHealth = mario.health
    local MAX_REAL_HEALTH = 2176
    local healthPercent = math.min(1, realHealth / MAX_REAL_HEALTH)

    djui_hud_set_color(settings.bgColor[1], settings.bgColor[2], settings.bgColor[3], settings.bgColor[4])
    djui_hud_render_rect(x, y, barWidth, barHeight)

    local fillWidth = barWidth * healthPercent
    if fillWidth > 0 then
        djui_hud_set_color(settings.fillColor[1], settings.fillColor[2], settings.fillColor[3], settings.fillColor[4])
        djui_hud_render_rect(x + 2, y + 2, fillWidth - 4, barHeight - 4)
    end

    if settings.showNumbers then
        local text = string.format("%d / %d", math.floor(realHealth), MAX_REAL_HEALTH)
        djui_hud_set_font(HUDSettings.font)
        djui_hud_set_color(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4])
        local adaptiveScale = getAdaptiveScale(settings.textScale)
        local textWidth = djui_hud_measure_text(text) * adaptiveScale
        local textX = x + (barWidth - textWidth) / 2
        local textY = y
        djui_hud_print_text(text, textX, textY, adaptiveScale)
    end
end

local function renderExtraInfo()
    local settings = HUDSettings.extraInfo
    local sw, sh = djui_hud_get_screen_width(), djui_hud_get_screen_height()

    local abilityId = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[gPlayerSyncTable[0].Kaisen64.currentAbilitySlot]
    local ability = AbilitiesData[abilityId]
    if not ability then return end

    local extraInfo = ability.getExtraInfo and ability.getExtraInfo() or {}
    if type(extraInfo) ~= "table" then extraInfo = { tostring(extraInfo) } end

    local panelWidth = sw * settings.relativeWidth
    local x = sw * settings.relativeX
    local y = sh * settings.relativeY
    local lineCount = math.min(#extraInfo, settings.maxLines)
    local panelHeight = settings.padding * 2 + lineCount * settings.lineHeight + 24

    djui_hud_set_color(settings.bgColor[1], settings.bgColor[2], settings.bgColor[3], settings.bgColor[4])
    djui_hud_render_rect(x, y, panelWidth, panelHeight)

    local abilityName = ability.name or ability.shortName or "Способность"
    local energyR, energyG, energyB = getCurrentEnergyColor()
    djui_hud_set_font(HUDSettings.font)
    djui_hud_set_color(energyR, energyG, energyB, 255)
    local titleScale = getAdaptiveScale(settings.fontSize + 0.05)
    djui_hud_print_text(abilityName, x + settings.padding, y + settings.padding, titleScale)

    local textY = y + settings.padding + 24
    local textScale = getAdaptiveScale(settings.fontSize)
    djui_hud_set_color(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4])
    for i = 1, lineCount do
        local line = extraInfo[i] or ""
        djui_hud_set_font(HUDSettings.font)
        djui_hud_print_text(line, x + settings.padding, textY, textScale)
        textY = textY + settings.lineHeight
    end
end

registerHudElement("HealthBar", renderHealthBar, 5,
    function() return not IsModMenuOpened() and gPlayerSyncTable[0].Kaisen64 ~= nil end)
registerHudElement("AbilitiesSlots", renderAbilitiesSlots, 10,
    function() return not IsModMenuOpened() and gPlayerSyncTable[0].Kaisen64 ~= nil end)
registerHudElement("EnergyBar", renderEnergyBar, 20,
    function() return not IsModMenuOpened() and gPlayerSyncTable[0].Kaisen64 ~= nil end)
registerHudElement("ExtraInfo", renderExtraInfo, 30,
    function() return not IsModMenuOpened() and gPlayerSyncTable[0].Kaisen64 ~= nil end)

local function onHudRender()
    for _, elem in ipairs(hudElements) do
        if elem.isActive() then
            elem.draw()
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, onHudRender)
