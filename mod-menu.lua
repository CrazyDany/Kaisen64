local MenuConfig = {
    window = {
        padding = 16,
        bg_color = { 31, 31, 31, 200 },
        close_btn_size = 32,
        close_btn_color = { normal = { 255, 31, 31, 200 }, hover = { 255, 31, 31, 255 }, click = { 200, 20, 20, 255 } },
    },
    tabs = {
        height = 48,
        min_width = 100,
        max_width = 180,
        text_padding = 16,
        colors = {
            normal = { 31, 31, 31, 200 },
            hover = { 31, 31, 31, 255 },
            active = { 63, 63, 63, 255 },
            text = { 255, 255, 255, 255 },
        },
        text_scale = 1,
    },
    abilities_grid = {
        cell_size = 64,
        cell_padding = 4,
        colors = {
            normal = { 31, 31, 31, 200 },
            hover = { 63, 63, 63, 255 },
        },
        icon_scale = 1.5,
        lock_texture = "lock",
        drag_icon_scale = 2,
    },
    ability_slots = {
        size = 64,
        padding = 4,
        colors = {
            normal = { 31, 31, 31, 200 },
            hover = { 63, 63, 63, 255 },
        },
        icon_scale = 2,
        text_scale = 0.6,
    },
    customization = {
        preview_size = 128,
        picker_offset_x = 20,
    },
    chants = {
        preview_width = 300,
        preview_height = 150,
        preview_bg = { 20, 20, 20, 200 },
        preview_text_scale = 0.8,
        button_width = 140,
        button_height = 40,
        button_spacing = 10,
        button_colors = {
            normal = { 31, 31, 31, 200 },
            hover = { 63, 63, 63, 255 },
            active = { 80, 80, 80, 255 },
        },
        text_scale = 0.7,
    },
    info_panel = {
        bg_color = { 20, 20, 20, 220 },
        padding = 12,
        title_scale = 1.2,
        description_scale = 0.9,
        line_spacing = 22,
    },
    skins = {
        button_width = 140,
        button_height = 48,
        button_spacing = 12,
        grid_columns = 3,
        button_colors = {
            normal = { 31, 31, 31, 200 },
            hover = { 63, 63, 63, 255 },
            active = { 80, 80, 80, 255 },
        },
        text_scale = 0.8,
        preview_size = 128,
        preview_bg = { 20, 20, 20, 200 },
    },
    settings = {
        button_width = 120,
        button_height = 40,
        button_spacing = 20,
        text_scale = 0.8,
        button_colors = {
            normal = { 31, 31, 31, 200 },
            hover = { 63, 63, 63, 255 },
            active = { 80, 80, 80, 255 },
        },
    },
    logo = {
        texture = "k64-logo",
        scale = 0.2,
        offset_y = -0.25,
    },
}

local modMenuOpened = false
local selectedSection = 0 -- 0=Abilities, 1=Energy, 2=Chants, 3=Skins, 4=Settings
local customEnergyBarColor = { r = 255, g = 255, b = 255 }
local currentChantsSet = 0
local chantsScrollOffset = 0
local maxChantsScroll = 0
local chantsContentHeight = 0
local hoveredAbilityIndex = nil

local slotDisplayMode = "icons" -- "icons" или "text"
local showOtherHealthbars = true
local showStatsInNames = true
local displayTimeMode = 1 -- 0 = frames, 1 = seconds

local Sections = {
    [0] = { name = "Abilities", id = 0 },
    [1] = { name = "Energy", id = 1 },
    [2] = { name = "Chants", id = 2 },
    [3] = { name = "Skins", id = 3 },
    [4] = { name = "Settings", id = 4 },
}

local currentSlotRects = {}

function GetSlotDisplayMode()
    return slotDisplayMode
end

function GetShowOtherHealthbars()
    return showOtherHealthbars
end

function GetShowStatsInNames()
    return showStatsInNames
end

function GetDisplayTimeMode()
    return displayTimeMode
end

local function applyChantsSet(setIndex)
    if gPlayerSyncTable[0] and gPlayerSyncTable[0].Kaisen64 then
        gPlayerSyncTable[0].Kaisen64.chant = setIndex
    else
        if not gPlayerSyncTable[0] then gPlayerSyncTable[0] = {} end
        if not gPlayerSyncTable[0].Kaisen64 then gPlayerSyncTable[0].Kaisen64 = {} end
        gPlayerSyncTable[0].Kaisen64.chant = setIndex
    end
end

local function loadSettings()
    -- Цвет энергии
    local r = mod_storage_load_number("customenergycolor.r")
    local g = mod_storage_load_number("customenergycolor.g")
    local b = mod_storage_load_number("customenergycolor.b")
    if r and g and b then
        customEnergyBarColor = { r = r, g = g, b = b }
    else
        customEnergyBarColor = { r = 255, g = 255, b = 255 }
    end

    -- Набор заклинаний
    local savedSet = mod_storage_load_number("chants.selectedSet")
    if savedSet ~= nil and savedSet >= 0 and savedSet <= 18 then
        currentChantsSet = savedSet
    else
        currentChantsSet = 0
    end
    applyChantsSet(currentChantsSet)

    -- Скин
    local savedSkin = mod_storage_load_number("skin.selected")
    if savedSkin ~= nil and K64_SKINS_TABLE[savedSkin] then
        gPlayerSyncTable[0].k64_skin = savedSkin
    else
        if gPlayerSyncTable[0].k64_skin == nil then
            gPlayerSyncTable[0].k64_skin = 0
        end
    end

    local savedSlotMode = mod_storage_load_number("settings.slotDisplayMode")
    if savedSlotMode == 1 then
        slotDisplayMode = "text"
    else
        slotDisplayMode = "icons"
    end

    local savedHealthbars = mod_storage_load_number("settings.showOtherHealthbars")
    if savedHealthbars ~= nil then
        showOtherHealthbars = (savedHealthbars == 1)
    else
        showOtherHealthbars = true
    end

    local savedStats = mod_storage_load_number("settings.showStatsInNames")
    if savedStats ~= nil then
        showStatsInNames = (savedStats == 1)
    else
        showStatsInNames = true
    end

    local savedTimeMode = mod_storage_load_number("settings.displayTimeMode")
    if savedTimeMode == 1 then
        displayTimeMode = 1
    else
        displayTimeMode = 0
    end
end

local function saveColorSetting()
    mod_storage_save_number("customenergycolor.r", customEnergyBarColor.r)
    mod_storage_save_number("customenergycolor.g", customEnergyBarColor.g)
    mod_storage_save_number("customenergycolor.b", customEnergyBarColor.b)
    if SetCustomEnergyColor then
        SetCustomEnergyColor(customEnergyBarColor.r, customEnergyBarColor.g, customEnergyBarColor.b)
    end
end

local function saveChantsSet()
    mod_storage_save_number("chants.selectedSet", currentChantsSet)
end

local function saveSkin(skinId)
    mod_storage_save_number("skin.selected", skinId)
end

-- Сохранение настроек (исправленное)
local function saveSlotDisplayMode(mode)
    slotDisplayMode = mode
    local value = (mode == "text") and 1 or 0
    mod_storage_save_number("settings.slotDisplayMode", value)
end

local function saveShowOtherHealthbars(value)
    showOtherHealthbars = value
    mod_storage_save_number("settings.showOtherHealthbars", value and 1 or 0)
end

local function saveShowStatsInNames(value)
    showStatsInNames = value
    mod_storage_save_number("settings.showStatsInNames", value and 1 or 0)
end

local function saveDisplayTimeMode(mode)
    displayTimeMode = mode
    mod_storage_save_number("settings.displayTimeMode", mode)
end

local function saveSelectedAbilities()
    for idx = 0, K64_MAX_ABILITIES_SLOTS - 1 do
        local abilityIdx = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[idx]
        if abilityIdx then
            mod_storage_save_number("selectedabilities." .. tostring(idx), abilityIdx)
        end
    end
end


function GlobalLoadSaved()
    loadSettings()
end

local function renderAbilitiesSection(x, y, w, h)
    local cfgGrid = MenuConfig.abilities_grid
    local cfgSlots = MenuConfig.ability_slots
    local cfgInfo = MenuConfig.info_panel

    local leftW = w * 0.5
    local rightW = w * 0.5
    local leftX = x
    local rightX = x + leftW

    local cellW = cfgGrid.cell_size
    local cellPad = cfgGrid.cell_padding
    local gridAreaH = h * 0.75

    local columns = math.max(1, math.floor(leftW / (cellW + cellPad)))
    local rows = math.floor(gridAreaH / (cellW + cellPad))

    local mouseX = djui_hud_get_mouse_x()
    local mouseY = djui_hud_get_mouse_y()
    local newHoverIndex = nil

    for idx = 1, columns * rows do
        local ability = AbilitiesData[idx - 1]
        if ability and idx - 1 ~= -1 then
            local row = math.floor((idx - 1) / columns)
            local col = (idx - 1) % columns
            local cellX = leftX + col * (cellW + cellPad)
            local cellY = y + row * (cellW + cellPad)

            UIButton(cellX, cellY, cellW, cellW, cfgGrid.colors, nil, nil)

            local texName = ability.iconTextureName or cfgGrid.lock_texture
            UITexture(texName, cellX + (cellW - 32 * cfgGrid.icon_scale) / 2,
                cellY + (cellW - 32 * cfgGrid.icon_scale) / 2, cfgGrid.icon_scale)

            if mouseX >= cellX and mouseX <= cellX + cellW and mouseY >= cellY and mouseY <= cellY + cellW then
                newHoverIndex = idx - 1
            end

            if not UIIsDragging() then
                local buttonsPressed = djui_hud_get_mouse_buttons_pressed()
                if buttonsPressed == 1 and mouseX >= cellX and mouseX <= cellX + cellW and mouseY >= cellY and mouseY <= cellY + cellW then
                    UIStartDrag(idx - 1, texName, cfgGrid.drag_icon_scale, nil, mouseX, mouseY)
                end
            end
        end
    end

    hoveredAbilityIndex = newHoverIndex

    local slotSize = cfgSlots.size
    local slotPad = cfgSlots.padding
    local slotsStartY = y + gridAreaH + 8
    local maxSlots = K64_MAX_ABILITIES_SLOTS or 8

    currentSlotRects = {}
    for slotIdx = 0, maxSlots - 1 do
        local slotX = leftX + slotIdx * (slotSize + slotPad)
        if slotX + slotSize <= leftX + leftW then
            table.insert(currentSlotRects, { x = slotX, y = slotsStartY, w = slotSize, h = slotSize, idx = slotIdx })
            UIButton(slotX, slotsStartY, slotSize, slotSize, cfgSlots.colors, nil, nil)

            local abilityIdx = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[slotIdx]
            local slotAbility = AbilitiesData[abilityIdx]

            if slotAbility then
                if slotDisplayMode == "icons" then
                    UITexture(slotAbility.iconTextureName or cfgGrid.lock_texture, slotX, slotsStartY,
                        cfgSlots.icon_scale)
                else
                    local displayName = slotAbility.shortName or slotAbility.name or "?"
                    local textScale = cfgSlots.text_scale
                    local textW = djui_hud_measure_text(displayName) * textScale
                    local textX = slotX + (slotSize - textW) / 2
                    local textY = slotsStartY + (slotSize - 16 * textScale) / 2
                    UIText(displayName, textX, textY, textScale, { 255, 255, 255, 255 })
                end
            end
        end
    end

    local infoX = rightX + 10
    local infoY = y
    local infoW = rightW - 20
    local infoH = h

    UIPanel(infoX, infoY, infoW, infoH, cfgInfo.bg_color)
    local maxTextWidth = infoW - 2 * cfgInfo.padding

    if hoveredAbilityIndex ~= nil and AbilitiesData[hoveredAbilityIndex] then
        local ability = AbilitiesData[hoveredAbilityIndex]
        local title = ability.name or "Unknown"
        local description = ability.description or { "No description" }

        -- Название (с переносом)
        local titleLines = wrapText(title, maxTextWidth, cfgInfo.title_scale)
        local lineY = infoY + cfgInfo.padding
        for _, line in ipairs(titleLines) do
            local lineWidth = djui_hud_measure_text(line) * cfgInfo.title_scale
            local titleX = infoX + (infoW - lineWidth) / 2
            UIText(line, titleX, lineY, cfgInfo.title_scale, { 255, 255, 100, 255 })
            lineY = lineY + cfgInfo.line_spacing
        end

        lineY = lineY + 8

        for _, descLine in ipairs(description) do
            local wrappedLines = wrapText(descLine, maxTextWidth, cfgInfo.description_scale)
            for _, line in ipairs(wrappedLines) do
                UIText(line, infoX + cfgInfo.padding, lineY, cfgInfo.description_scale, { 220, 220, 220, 255 })
                lineY = lineY + cfgInfo.line_spacing
            end
        end

        lineY = lineY + cfgInfo.line_spacing

        local cost = ability.cost or 0
        local cooldown = ability.cooldown or 0

        local costText = "Cost: " .. cost
        local cooldownText
        if cooldown == 0 then
            cooldownText = "Cooldown: —"
        else
            if displayTimeMode == 0 then
                cooldownText = "Cooldown: " .. cooldown .. (cooldown == 1 and " frame" or " frames")
            else
                local seconds = cooldown / 30.0
                cooldownText = "Cooldown: " .. string.format("%.1f", seconds) .. " sec"
            end
        end

        UIText(costText, infoX + cfgInfo.padding, lineY, cfgInfo.description_scale, { 200, 200, 255, 255 })
        lineY = lineY + cfgInfo.line_spacing
        UIText(cooldownText, infoX + cfgInfo.padding, lineY, cfgInfo.description_scale, { 200, 200, 255, 255 })
        lineY = lineY + cfgInfo.line_spacing
    else
        UIText("Hover over an ability", infoX + cfgInfo.padding, infoY + cfgInfo.padding + 20, 0.9,
            { 180, 180, 180, 255 })
    end
end

local function renderEnergySection(x, y, w, h)
    local cfg = MenuConfig.customization
    local previewX = x
    local previewY = y
    local previewW = cfg.preview_size
    local previewH = cfg.preview_size

    UIPanel(previewX, previewY, previewW, previewH,
        { customEnergyBarColor.r, customEnergyBarColor.g, customEnergyBarColor.b, 255 })

    local pickerX = previewX + previewW + cfg.picker_offset_x
    local pickerY = previewY

    local newColor = UIColorPicker(pickerX, pickerY, customEnergyBarColor, function(color)
        customEnergyBarColor = color
        saveColorSetting()
    end)
    if newColor then
        customEnergyBarColor = newColor
    end
end

local function renderChantsSection(x, y, w, h)
    local cfg = MenuConfig.chants

    local previewW = cfg.preview_width
    local previewH = cfg.preview_height
    local previewX = x
    local previewY = y
    UIPanel(previewX, previewY, previewW, previewH, cfg.preview_bg)

    local previewTitle = "Preview"
    local titleScale = 0.7
    UIText(previewTitle, previewX + 10, previewY + 5, titleScale, { 255, 255, 255, 255 })

    local selectedChants = chants[currentChantsSet]
    if selectedChants then
        local lineHeight = 20
        local startY = previewY + 30
        for i, chant in ipairs(selectedChants) do
            UIText(chant, previewX + 10, startY + (i - 1) * lineHeight, cfg.preview_text_scale, { 220, 220, 220, 255 })
        end
    else
        UIText("No chants selected", previewX + 10, previewY + 40, cfg.preview_text_scale, { 255, 100, 100, 255 })
    end

    local gridX = previewX + previewW + 20
    local gridW = w - (previewW + 20)
    local gridY = y
    local gridH = h

    local btnW = cfg.button_width
    local btnH = cfg.button_height
    local spacing = cfg.button_spacing
    local fullBtnW = btnW + spacing

    local columns = math.max(1, math.floor(gridW / fullBtnW))
    local rows = math.ceil(19 / columns)

    chantsContentHeight = rows * (btnH + spacing)
    maxChantsScroll = math.max(0, chantsContentHeight - gridH)
    chantsScrollOffset = math.max(0, math.min(chantsScrollOffset, maxChantsScroll))

    local startRow = math.max(0, math.floor(chantsScrollOffset / (btnH + spacing)))
    local endRow = math.min(rows - 1, math.floor((chantsScrollOffset + gridH) / (btnH + spacing)))

    for setIdx = 0, 18 do
        local row = math.floor(setIdx / columns)
        local col = setIdx % columns

        if row >= startRow and row <= endRow then
            local btnX = gridX + col * fullBtnW
            local btnY = gridY + row * (btnH + spacing) - chantsScrollOffset

            if btnY + btnH > gridY and btnY < gridY + gridH then
                local isActive = (setIdx == currentChantsSet)
                local btnColors = {
                    normal = isActive and cfg.button_colors.active or cfg.button_colors.normal,
                    hover = cfg.button_colors.hover,
                }
                UIButton(btnX, btnY, btnW, btnH, btnColors, function()
                    currentChantsSet = setIdx
                    saveChantsSet()
                    applyChantsSet(setIdx)
                end)

                local btnText = "Set " .. (setIdx + 1)
                local textW = djui_hud_measure_text(btnText) * cfg.text_scale
                local textX = btnX + (btnW - textW) / 2
                local textY = btnY + (btnH - 16 * cfg.text_scale) / 2
                UIText(btnText, textX, textY, cfg.text_scale, { 255, 255, 255, 255 })
            end
        end
    end

    if maxChantsScroll > 0 then
        local scrollBarX = gridX + gridW - 8
        local scrollBarH = gridH - 4
        local scrollThumbH = math.max(20, (gridH / chantsContentHeight) * scrollBarH)
        local scrollThumbY = gridY + 2 + (chantsScrollOffset / maxChantsScroll) * (scrollBarH - scrollThumbH)
        UIPanel(scrollBarX, gridY + 2, 6, scrollBarH, { 40, 40, 40, 200 })
        UIPanel(scrollBarX, scrollThumbY, 6, scrollThumbH, { 200, 200, 200, 200 })
    end
end

local function renderSkinsSection(x, y, w, h)
    local cfg = MenuConfig.skins
    local currentSkin = gPlayerSyncTable[0].k64_skin or 0

    local previewW = cfg.preview_size
    local previewH = cfg.preview_size
    local previewX = x
    local previewY = y
    UIPanel(previewX, previewY, previewW, previewH, cfg.preview_bg)
    UIText("Skin preview", previewX + 10, previewY + 10, 0.8, { 255, 255, 255, 255 })
    local skinName = K64_SKINS_TABLE[currentSkin] and K64_SKINS_TABLE[currentSkin].name or "unknown"
    UIText("Selected: " .. skinName, previewX + 10, previewY + 40, 0.7, { 220, 220, 220, 255 })

    local gridX = previewX + previewW + 20
    local gridW = w - (previewW + 20)
    local gridY = y
    local gridH = h

    local btnW = cfg.button_width
    local btnH = cfg.button_height
    local spacing = cfg.button_spacing
    local columns = cfg.grid_columns
    local fullBtnW = btnW + spacing

    local totalSkins = 0
    for _ in pairs(K64_SKINS_TABLE) do totalSkins = totalSkins + 1 end
    local rows = math.ceil(totalSkins / columns)

    local startX = gridX
    local startY = gridY
    local row = 0
    local col = 0

    for skinIdx = 0, totalSkins - 1 do
        if K64_SKINS_TABLE[skinIdx] then
            if col >= columns then
                col = 0
                row = row + 1
            end
            local btnX = startX + col * fullBtnW
            local btnY = startY + row * (btnH + spacing)

            if btnY + btnH <= gridY + gridH then
                local isActive = (skinIdx == currentSkin)
                local btnColors = {
                    normal = isActive and cfg.button_colors.active or cfg.button_colors.normal,
                    hover = cfg.button_colors.hover,
                }
                UIButton(btnX, btnY, btnW, btnH, btnColors, function()
                    gPlayerSyncTable[0].k64_skin = skinIdx
                    saveSkin(skinIdx)
                    djui_chat_message_create("Skin set to " .. K64_SKINS_TABLE[skinIdx].name)
                end)

                local btnText = K64_SKINS_TABLE[skinIdx].name
                local textW = djui_hud_measure_text(btnText) * cfg.text_scale
                local textX = btnX + (btnW - textW) / 2
                local textY = btnY + (btnH - 16 * cfg.text_scale) / 2
                UIText(btnText, textX, textY, cfg.text_scale, { 255, 255, 255, 255 })
            end
            col = col + 1
        end
    end
end

local function renderSettingsSection(x, y, w, h)
    local cfg = MenuConfig.settings
    local startY = y + 20
    local btnW = cfg.button_width
    local btnH = cfg.button_height
    local spacing = cfg.button_spacing
    local textScale = cfg.text_scale

    local slotLabel = "Slots display mode:"
    local slotLabelW = djui_hud_measure_text(slotLabel) * textScale
    UIText(slotLabel, x + 20, startY, textScale, { 255, 255, 255, 255 })

    local iconsBtnX = x + 20 + slotLabelW + 20
    local iconsColor = (slotDisplayMode == "icons") and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(iconsBtnX, startY, btnW, btnH, { normal = iconsColor, hover = cfg.button_colors.hover }, function()
        if slotDisplayMode ~= "icons" then
            saveSlotDisplayMode("icons")
        end
    end)
    UIText("Icons", iconsBtnX + btnW / 2 - djui_hud_measure_text("Icons") * textScale / 2,
        startY + (btnH - 16 * textScale) / 2, textScale, { 255, 255, 255, 255 })

    local textBtnX = iconsBtnX + btnW + spacing
    local textColor = (slotDisplayMode == "text") and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(textBtnX, startY, btnW, btnH, { normal = textColor, hover = cfg.button_colors.hover }, function()
        if slotDisplayMode ~= "text" then
            saveSlotDisplayMode("text")
        end
    end)
    UIText("Text", textBtnX + btnW / 2 - djui_hud_measure_text("Text") * textScale / 2,
        startY + (btnH - 16 * textScale) /
        2, textScale, { 255, 255, 255, 255 })

    local lineY = startY + btnH + 20

    local healthLabel = "Show other players' health bars:"
    local healthLabelW = djui_hud_measure_text(healthLabel) * textScale
    UIText(healthLabel, x + 20, lineY, textScale, { 255, 255, 255, 255 })

    local onHealthX = x + 20 + healthLabelW + 20
    local onHealthColor = showOtherHealthbars and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(onHealthX, lineY, btnW, btnH, { normal = onHealthColor, hover = cfg.button_colors.hover }, function()
        if not showOtherHealthbars then
            saveShowOtherHealthbars(true)
        end
    end)
    UIText("On", onHealthX + btnW / 2 - djui_hud_measure_text("On") * textScale / 2, lineY + (btnH - 16 * textScale) / 2,
        textScale, { 255, 255, 255, 255 })

    local offHealthX = onHealthX + btnW + spacing
    local offHealthColor = not showOtherHealthbars and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(offHealthX, lineY, btnW, btnH, { normal = offHealthColor, hover = cfg.button_colors.hover }, function()
        if showOtherHealthbars then
            saveShowOtherHealthbars(false)
        end
    end)
    UIText("Off", offHealthX + btnW / 2 - djui_hud_measure_text("Off") * textScale / 2, lineY + (btnH - 16 * textScale) /
        2, textScale, { 255, 255, 255, 255 })

    lineY = lineY + btnH + 20

    local statsLabel = "Show player stats in names:"
    local statsLabelW = djui_hud_measure_text(statsLabel) * textScale
    UIText(statsLabel, x + 20, lineY, textScale, { 255, 255, 255, 255 })

    local onStatsX = x + 20 + statsLabelW + 20
    local onStatsColor = showStatsInNames and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(onStatsX, lineY, btnW, btnH, { normal = onStatsColor, hover = cfg.button_colors.hover }, function()
        if not showStatsInNames then
            saveShowStatsInNames(true)
        end
    end)
    UIText("On", onStatsX + btnW / 2 - djui_hud_measure_text("On") * textScale / 2, lineY + (btnH - 16 * textScale) / 2,
        textScale, { 255, 255, 255, 255 })

    local offStatsX = onStatsX + btnW + spacing
    local offStatsColor = not showStatsInNames and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(offStatsX, lineY, btnW, btnH, { normal = offStatsColor, hover = cfg.button_colors.hover }, function()
        if showStatsInNames then
            saveShowStatsInNames(false)
        end
    end)
    UIText("Off", offStatsX + btnW / 2 - djui_hud_measure_text("Off") * textScale / 2, lineY + (btnH - 16 * textScale) /
        2, textScale, { 255, 255, 255, 255 })


    lineY = lineY + btnH + 20

    local timeLabel = "Display time in:"
    local timeLabelW = djui_hud_measure_text(timeLabel) * textScale
    UIText(timeLabel, x + 20, lineY, textScale, { 255, 255, 255, 255 })

    local framesBtnX = x + 20 + timeLabelW + 20
    local framesColor = (displayTimeMode == 0) and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(framesBtnX, lineY, btnW, btnH, { normal = framesColor, hover = cfg.button_colors.hover }, function()
        if displayTimeMode ~= 0 then
            saveDisplayTimeMode(0)
        end
    end)
    UIText("Frames", framesBtnX + btnW / 2 - djui_hud_measure_text("Frames") * textScale / 2,
        lineY + (btnH - 16 * textScale) / 2, textScale, { 255, 255, 255, 255 })

    local secondsBtnX = framesBtnX + btnW + spacing
    local secondsColor = (displayTimeMode == 1) and cfg.button_colors.active or cfg.button_colors.normal
    UIButton(secondsBtnX, lineY, btnW, btnH, { normal = secondsColor, hover = cfg.button_colors.hover }, function()
        if displayTimeMode ~= 1 then
            saveDisplayTimeMode(1)
        end
    end)
    UIText("Seconds", secondsBtnX + btnW / 2 - djui_hud_measure_text("Seconds") * textScale / 2,
        lineY + (btnH - 16 * textScale) / 2, textScale, { 255, 255, 255, 255 })
end

local function renderModMenu()
    local screenW = djui_hud_get_screen_width()
    local screenH = djui_hud_get_screen_height()
    local pad = MenuConfig.window.padding

    local winX = pad
    local winY = pad
    local winW = screenW - 2 * pad
    local winH = screenH - 2 * pad

    UIPanel(winX, winY, winW, winH, MenuConfig.window.bg_color)

    local closeSize = MenuConfig.window.close_btn_size
    local closeX = winX + winW - pad - closeSize
    local closeY = winY + pad
    UIButton(closeX, closeY, closeSize, closeSize, MenuConfig.window.close_btn_color, CloseModMenu)

    local logo = MenuConfig.logo
    local logoInfo = get_texture_info(logo.texture)
    local logoHeight = 0
    if logoInfo then
        local logoW = logoInfo.width * logo.scale
        local logoH = logoInfo.height * logo.scale
        local logoX = winX + winW / 2 - logoW / 2
        local logoY = winY + pad + logoH * logo.offset_y
        UITexture(logo.texture, logoX, logoY, logo.scale)
        logoHeight = logoH + pad
    end

    local tabCfg = MenuConfig.tabs
    local tabStartY = winY + pad + logoHeight + 16
    local tabHeight = tabCfg.height
    local tabSpacing = 12

    local function getTabWidth(text)
        local textW = djui_hud_measure_text(text) * tabCfg.text_scale
        local btnW = textW + tabCfg.text_padding * 2
        if btnW < tabCfg.min_width then btnW = tabCfg.min_width end
        if btnW > tabCfg.max_width then btnW = tabCfg.max_width end
        return btnW
    end

    local tabX = winX + pad
    for i = 0, 4 do
        local section = Sections[i]
        if section then
            local btnW = getTabWidth(section.name)
            local isActive = (selectedSection == section.id)
            local colors = {
                normal = isActive and tabCfg.colors.active or tabCfg.colors.normal,
                hover = tabCfg.colors.hover,
                text = tabCfg.colors.text,
            }
            UIButton(tabX, tabStartY, btnW, tabHeight, colors, function()
                selectedSection = section.id
            end)

            local text = section.name
            local textW = djui_hud_measure_text(text) * tabCfg.text_scale
            local textX = tabX + (btnW - textW) / 2
            local textY = tabStartY + (tabHeight - 16 * tabCfg.text_scale) / 2
            UIText(text, textX, textY, tabCfg.text_scale, tabCfg.colors.text)

            tabX = tabX + btnW + tabSpacing
        end
    end

    local contentX = winX + pad
    local contentY = tabStartY + tabHeight + pad
    local contentW = winW - 2 * pad
    local contentH = winH - (contentY - winY) - pad

    if selectedSection == 0 then
        renderAbilitiesSection(contentX, contentY, contentW, contentH)
    elseif selectedSection == 1 then
        renderEnergySection(contentX, contentY, contentW, contentH)
    elseif selectedSection == 2 then
        renderChantsSection(contentX, contentY, contentW, contentH)
    elseif selectedSection == 3 then
        renderSkinsSection(contentX, contentY, contentW, contentH)
    elseif selectedSection == 4 then
        renderSettingsSection(contentX, contentY, contentW, contentH)
    end

    UIDrawDrag()
end

local function handleDrop(dropData)
    if not dropData or dropData.data == nil then return end
    local abilityIndex = dropData.data
    local dropX = dropData.dropX
    local dropY = dropData.dropY

    for _, slot in ipairs(currentSlotRects) do
        if dropX >= slot.x and dropX <= slot.x + slot.w and dropY >= slot.y and dropY <= slot.y + slot.h then
            gPlayerSyncTable[0].Kaisen64.abilitiesSlots[slot.idx] = abilityIndex
            local abilityName = AbilitiesData[abilityIndex] and AbilitiesData[abilityIndex].name or "?"
            djui_chat_message_create("Set ability: " .. abilityName .. " to slot " .. slot.idx)
            saveSelectedAbilities()
            break
        end
    end
end

function OpenModMenu()
    game_pause()
    set_pause_menu_hidden(true)
    loadSettings()
    modMenuOpened = true
end

function CloseModMenu()
    game_unpause()
    set_pause_menu_hidden(false)
    modMenuOpened = false
end

function IsModMenuOpened()
    return modMenuOpened
end

local function onMouseScroll(dx, dy)
    if modMenuOpened and selectedSection == 2 then
        local scrollDelta = dy * 30
        chantsScrollOffset = math.max(0, math.min(chantsScrollOffset + scrollDelta, maxChantsScroll))
    end
end

local function onHudRender()
    if modMenuOpened then
        local dropData = UIUpdateDrag()
        if dropData then
            handleDrop(dropData)
        end
        renderModMenu()
    end
end

hook_event(HOOK_ON_HUD_RENDER, onHudRender)
-- hook_event(HOOK_ON_MOUSE_SCROLL, onMouseScroll)
