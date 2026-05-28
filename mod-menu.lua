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
    logo = {
        texture = "k64-logo",
        scale = 0.2,
        offset_y = -0.25,
    },
}

local modMenuOpened = false
local selectedSection = 0
local customEnergyBarColor = { r = 255, g = 255, b = 255 }
local currentChantsSet = 0
local chantsScrollOffset = 0
local maxChantsScroll = 0
local chantsContentHeight = 0

local hoveredAbilityIndex = nil

local Sections = {
    [0] = { name = "Abilities", id = 0 },
    [1] = { name = "Energy", id = 1 },
    [2] = { name = "Chants", id = 2 },
}

local currentSlotRects = {}

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
    local r = mod_storage_load_number("customenergycolor.r")
    local g = mod_storage_load_number("customenergycolor.g")
    local b = mod_storage_load_number("customenergycolor.b")
    if r and g and b then
        customEnergyBarColor = { r = r, g = g, b = b }
    else
        customEnergyBarColor = { r = 255, g = 255, b = 255 }
    end

    local savedSet = mod_storage_load_number("chants.selectedSet")
    if savedSet ~= nil and savedSet >= 0 and savedSet <= 18 then
        currentChantsSet = savedSet
    else
        currentChantsSet = 0
    end
    applyChantsSet(currentChantsSet)
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
                UITexture(slotAbility.iconTextureName or "lock", slotX, slotsStartY, cfgSlots.icon_scale)
            end
        end
    end

    -- Правая часть: информационная панель
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

        -- Небольшой отступ перед описанием
        lineY = lineY + 8

        -- Описание (каждая исходная строка переносится отдельно)
        for _, descLine in ipairs(description) do
            local wrappedLines = wrapText(descLine, maxTextWidth, cfgInfo.description_scale)
            for _, line in ipairs(wrappedLines) do
                UIText(line, infoX + cfgInfo.padding, lineY, cfgInfo.description_scale, { 220, 220, 220, 255 })
                lineY = lineY + cfgInfo.line_spacing
            end
        end
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
    for i = 0, 2 do
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
