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
        cell_size = 96,
        cell_padding = 8,
        colors = {
            normal = { 31, 31, 31, 200 },
            hover = { 63, 63, 63, 255 },
            selected = { 80, 80, 80, 200 },
        },
        icon_scale = 3,
        lock_texture = "lock",
    },
    ability_slots = {
        size = 64,
        padding = 8,
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
    logo = {
        texture = "k64-logo",
        scale = 0.2,
        offset_y = -0.25,
    },
}

local modMenuOpened = false
local selectedSection = 0
local selectedForEditSlot = -1
local customEnergyBarColor = { r = 255, g = 255, b = 255 }

local Sections = {
    [0] = { name = "Abilities", id = 0 },
    [1] = { name = "Customization", id = 1 },
}

local function loadSettings()
    local r = mod_storage_load_number("customenergycolor.r")
    local g = mod_storage_load_number("customenergycolor.g")
    local b = mod_storage_load_number("customenergycolor.b")
    if r and g and b then
        customEnergyBarColor = { r = r, g = g, b = b }
    else
        customEnergyBarColor = { r = 255, g = 255, b = 255 }
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

local function renderAbilitiesSection(x, y, w, h)
    local cfgGrid = MenuConfig.abilities_grid
    local cfgSlots = MenuConfig.ability_slots
    local cellW = cfgGrid.cell_size
    local cellPad = cfgGrid.cell_padding
    local gridAreaH = h * 0.75

    local columns = math.max(1, math.floor(w / (cellW + cellPad)))
    local rows = math.floor(gridAreaH / (cellW + cellPad))

    for idx = 1, columns * rows do
        local ability = AbilitiesData[idx - 1]
        local row = math.floor((idx - 1) / columns)
        local col = (idx - 1) % columns
        local cellX = x + col * (cellW + cellPad)
        local cellY = y + row * (cellW + cellPad)

        local colors = cfgGrid.colors
        if selectedForEditSlot ~= -1 then
            colors = { normal = cfgGrid.colors.selected, hover = cfgGrid.colors.hover }
        end

        UIButton(cellX, cellY, cellW, cellW, colors, function()
            if selectedForEditSlot ~= -1 and ability then
                gPlayerSyncTable[0].Kaisen64.abilitiesSlots[selectedForEditSlot] = idx - 1
                djui_chat_message_create("Set ability: " .. (ability.name or "?") .. " to slot " .. selectedForEditSlot)
                selectedForEditSlot = -1
            end
        end)

        local texName = ability and ability.iconTextureName or cfgGrid.lock_texture
        local texColor = ability and nil or { 63, 63, 63, 255 }
        UITexture(texName, cellX, cellY, cfgGrid.icon_scale, texColor)
    end

    local slotSize = cfgSlots.size
    local slotPad = cfgSlots.padding
    local slotsStartY = y + gridAreaH + 8
    local maxSlots = K64_MAX_ABILITIES_SLOTS or 8

    for slotIdx = 0, maxSlots - 1 do
        local slotX = x + slotIdx * (slotSize + slotPad)
        if slotX + slotSize <= x + w then
            UIButton(slotX, slotsStartY, slotSize, slotSize, cfgSlots.colors, function()
                selectedForEditSlot = slotIdx
            end)

            local abilityIdx = gPlayerSyncTable[0].Kaisen64.abilitiesSlots[slotIdx]
            local slotAbility = AbilitiesData[abilityIdx]
            if slotAbility then
                UITexture(slotAbility.iconTextureName or "lock", slotX, slotsStartY, cfgSlots.icon_scale)
            end
        end
    end
end

local function renderCustomizationSection(x, y, w, h)
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

local function renderModMenu()
    local screenW = djui_hud_get_screen_width()
    local screenH = djui_hud_get_screen_height()
    local pad = MenuConfig.window.padding

    local winX = pad
    local winY = pad
    local winW = screenW - 2 * pad
    local winH = screenH - 2 * pad

    UIPanel(winX, winY, winW, winH, MenuConfig.window.bg_color)

    -- Кнопка закрытия
    local closeSize = MenuConfig.window.close_btn_size
    local closeX = winX + winW - pad - closeSize
    local closeY = winY + pad
    UIButton(closeX, closeY, closeSize, closeSize, MenuConfig.window.close_btn_color, CloseModMenu)

    -- Логотип
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

    -- Вкладки
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
    for i = 0, 1 do
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

    -- Область контента
    local contentX = winX + pad
    local contentY = tabStartY + tabHeight + pad
    local contentW = winW - 2 * pad
    local contentH = winH - (contentY - winY) - pad

    if selectedSection == 0 then
        renderAbilitiesSection(contentX, contentY, contentW, contentH)
    elseif selectedSection == 1 then
        renderCustomizationSection(contentX, contentY, contentW, contentH)
    end
end

function OpenModMenu()
    game_pause()
    set_pause_menu_hidden(true)
    loadSettings()
    modMenuOpened = true
    selectedForEditSlot = -1
end

function CloseModMenu()
    game_unpause()
    set_pause_menu_hidden(false)
    modMenuOpened = false
end

function IsModMenuOpened()
    return modMenuOpened
end

local function onHudRender()
    if modMenuOpened then
        renderModMenu()
    end
end

hook_event(HOOK_ON_HUD_RENDER, onHudRender)
