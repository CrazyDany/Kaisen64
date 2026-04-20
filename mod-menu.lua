local modMenuOpened = false

function OpenModMenu()
    game_pause()
    set_pause_menu_hidden(true)
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

local selectedForEditSlot = -1
MODMENU_SECTION_ABILITY = 0
MODEMNU_SECTION_CUSTOMIZATION = 1
local selectedSection = 0

local function renderModMenu()
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local padding = 16

    local backgroundX = padding
    local backgroundY = padding
    local backgroundWidth = screenWidth - (2 * padding)
    local backgroundHeight = screenHeight - (2 * padding)

    djui_hud_set_color(31, 31, 31, 200)
    djui_hud_render_rect(backgroundX, backgroundY, backgroundWidth, backgroundHeight)

    -- Close button
    local closeButtonWidth = 32
    local closeButtonHeight = 32
    local closeButtonX = backgroundX + backgroundWidth - padding - closeButtonWidth
    local closeButtonY = backgroundY + padding

    djui_hud_set_color(255, 31, 31, 0)
    local closeButton = K64Button(closeButtonX, closeButtonY, closeButtonWidth, closeButtonHeight)
    if closeButton == K64_BUTTON_NONE then
        djui_hud_set_color(255, 31, 31, 200)
        djui_hud_render_rect(closeButtonX, closeButtonY, closeButtonWidth, closeButtonHeight)
    elseif closeButton == K64_BUTTON_HOVER then
        djui_hud_set_color(255, 31, 31, 255)
        djui_hud_render_rect(closeButtonX, closeButtonY, closeButtonWidth, closeButtonHeight)
    elseif closeButton == K64_BUTTON_LEFT_CLICK then
        CloseModMenu()
    end

    -- Mod logo
    local modLogo = get_texture_info("k64-logo")
    local scale = 0.2
    local modLogoWidth = modLogo.width * scale
    local modLogoHeight = modLogo.height * scale
    local modLogoX = backgroundX + padding + (backgroundWidth - modLogoWidth * scale) / 2
    local modLogoY = backgroundY + padding - modLogoHeight/4
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(modLogo, modLogoX, modLogoY, scale, scale)

    -- Section select buttons
    local sectionBarWidth = 0
    local sectionBarX = backgroundX + padding
    local sectionBarY = backgroundY + padding

    local sections = {
        [MODMENU_SECTION_ABILITY] = "Abilities",
        [MODEMNU_SECTION_CUSTOMIZATION] = "Customization"
    }

    for i, v in pairs(sections) do
        local sectionWidth = djui_hud_measure_text(v) * 2
        sectionBarWidth = sectionBarWidth + sectionWidth + padding

        djui_hud_set_color(31, 31, 31, 0)
        local buttonClick = K64Button(sectionBarX + sectionBarWidth - padding, sectionBarY - padding,
            sectionWidth + 2 * padding,
            64 + 2 * padding)

        if buttonClick == K64_BUTTON_NONE then
            djui_hud_set_color(31, 31, 31, 200)
        elseif buttonClick == K64_BUTTON_HOVER then
            djui_hud_set_color(31, 31, 31, 255)
        elseif buttonClick == K64_BUTTON_LEFT_CLICK then
            -- djui_hud_set_color(63, 63, 63, 255)
            selectedSection = i
        end

        djui_hud_render_rect(sectionBarX + sectionBarWidth - padding, sectionBarY - padding,
            sectionWidth + 2 * padding,
            64 + 2 * padding)

        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(v, sectionBarX + sectionBarWidth, sectionBarY, 2)
    end

    if selectedSection == MODMENU_SECTION_ABILITY then
        local abilitiesSelectionX = backgroundX + backgroundWidth / 4 - padding
        local abilitiesSelectionY = backgroundY + 7 * padding
        local abilitiesSelectionWidth = (backgroundWidth - (2 * padding)) * 3 / 4
        local abilitiesSelectionHeight = backgroundHeight - (14 * padding)

        -- Render abilities
        local abilityCellSize = 128
        local abilityCellPadding = 8

        local columns = math.floor(abilitiesSelectionWidth / (abilityCellSize + abilityCellPadding))
        local rows = math.floor(abilitiesSelectionHeight / (abilityCellSize + abilityCellPadding))

        for i = 1, columns * rows - 1 do
            local x = abilitiesSelectionX + (i - 1) % columns * (abilityCellSize + abilityCellPadding)
            local y = abilitiesSelectionY + math.floor((i - 1) / columns) * (abilityCellSize + abilityCellPadding)

            djui_hud_set_color(31, 31, 31, 200)
            if selectedForEditSlot ~= -1 then
                djui_hud_set_color(63, 63, 63, 200)
            end

            if selectedForEditSlot ~= -1 then
                local abilityButton = K64Button(x, y, abilityCellSize, abilityCellSize)
                if abilityButton == K64_BUTTON_NONE then
                    djui_hud_set_color(31, 31, 31, 200)
                elseif abilityButton == K64_BUTTON_HOVER then
                    djui_hud_set_color(31, 31, 31, 255)
                elseif abilityButton == K64_BUTTON_LEFT_CLICK then
                    -- djui_hud_set_color(63, 63, 63, 255)
                    local abilityData = AbilitiesData[i - 1]
                    if abilityData ~= nil then
                        djui_chat_message_create("Set ability " ..
                            abilityData.name .. " for slot " .. selectedForEditSlot)
                        gPlayerSyncTable[0].Kaisen64.abilitiesSlots[selectedForEditSlot] = i - 1
                        selectedForEditSlot = -1
                    end
                end
            end

            djui_hud_render_rect(x, y, abilityCellSize, abilityCellSize)

            djui_hud_set_color(255, 255, 255, 255)
            if selectedForEditSlot == -1 then
                djui_hud_set_color(63, 63, 63, 255)
            end
            local abilityData = AbilitiesData[i - 1]
            local textureName = "lock"
            if abilityData ~= nil then
                textureName = abilityData.iconTextureName or textureName
            end

            if textureName == "lock" then
                djui_hud_set_color(63, 63, 63, 255)
            end

            local texture = get_texture_info(textureName)
            if texture ~= nil then
                djui_hud_render_texture(texture, x, y, 4, 4)
            end
        end

        local slotSlectionX = abilitiesSelectionX
        local slotSelectionY = abilitiesSelectionY + abilitiesSelectionHeight + padding
        local slotSelectionSize = 64

        for i = 0, K64_MAX_ABILITIES_SLOTS - 1 do
            local x = slotSlectionX + i * (slotSelectionSize + padding)
            local y = slotSelectionY

            djui_hud_set_color(31, 31, 31, 0)
            local slotButton = K64Button(x, y, slotSelectionSize, slotSelectionSize)

            if slotButton == K64_BUTTON_NONE then
                djui_hud_set_color(31, 31, 31, 200)
            elseif slotButton == K64_BUTTON_HOVER then
                djui_hud_set_color(31, 31, 31, 255)
            elseif slotButton == K64_BUTTON_LEFT_CLICK then
                -- djui_hud_set_color(63, 63, 63, 255)
                selectedForEditSlot = i
            end

            djui_hud_set_color(31, 31, 31, 200)
            djui_hud_render_rect(x, y, slotSelectionSize, slotSelectionSize)

            djui_hud_set_color(255, 255, 255, 255)
            local abilityData = AbilitiesData[gPlayerSyncTable[0].Kaisen64.abilitiesSlots[i]]
            if abilityData ~= nil then
                local texture = get_texture_info(abilityData.iconTextureName or "lock")
                if texture ~= nil then
                    djui_hud_render_texture(texture, x, y, 2, 2)
                end
            end
        end
    elseif selectedSection == MODEMNU_SECTION_CUSTOMIZATION then

    end
end

local function onHudRender()
    if modMenuOpened then
        renderModMenu()
    end
end

hook_event(HOOK_ON_HUD_RENDER, onHudRender)
