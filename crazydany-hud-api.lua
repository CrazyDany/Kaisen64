K64_BUTTON_RIGHT_CLICK = 1
K64_BUTTON_LEFT_CLICK = 2
K64_BUTTON_HOVER = 3
K64_BUTTON_NONE = 4

function K64Button(x, y, w, h)
    djui_hud_render_rect(x, y, w, h)
    local mouseX = djui_hud_get_mouse_x()
    local mouseY = djui_hud_get_mouse_y()
    local mouseButtonsPressed = djui_hud_get_mouse_buttons_pressed()
    if mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h then
        if mouseButtonsPressed == 1 then return K64_BUTTON_LEFT_CLICK end
        if mouseButtonsPressed == 4 then return K64_BUTTON_RIGHT_CLICK end
        return K64_BUTTON_HOVER
    end
    return K64_BUTTON_NONE
end

function UIButton(x, y, w, h, colors, onClickLeft, onClickRight)
    djui_hud_set_color(colors.normal[1], colors.normal[2], colors.normal[3], colors.normal[4])
    local state = K64Button(x, y, w, h)
    if state == K64_BUTTON_HOVER and colors.hover then
        djui_hud_set_color(colors.hover[1], colors.hover[2], colors.hover[3], colors.hover[4])
        djui_hud_render_rect(x, y, w, h)
    elseif state == K64_BUTTON_LEFT_CLICK and onClickLeft then
        if colors.click then
            djui_hud_set_color(colors.click[1], colors.click[2], colors.click[3], colors.click[4])
            djui_hud_render_rect(x, y, w, h)
        end
        onClickLeft()
    elseif state == K64_BUTTON_RIGHT_CLICK and onClickRight then
        if colors.click then
            djui_hud_set_color(colors.click[1], colors.click[2], colors.click[3], colors.click[4])
            djui_hud_render_rect(x, y, w, h)
        end
        onClickRight()
    end
    return state
end

local dragState = {
    active = false,
    data = nil,
    textureName = nil,
    scale = 1,
    onDrop = nil,
    currentX = 0,
    currentY = 0,
}

function UIStartDrag(data, textureName, scale, onDrop, startX, startY)
    dragState.active = true
    dragState.data = data
    dragState.textureName = textureName
    dragState.scale = scale or 2
    dragState.onDrop = onDrop
    dragState.currentX = startX or 0
    dragState.currentY = startY or 0
end

function UIUpdateDrag()
    if not dragState.active then return nil end
    local mouseX = djui_hud_get_mouse_x()
    local mouseY = djui_hud_get_mouse_y()
    dragState.currentX = mouseX
    dragState.currentY = mouseY

    local buttonsDown = djui_hud_get_mouse_buttons_down()
    if buttonsDown ~= 1 then
        local dropData = {
            data = dragState.data,
            onDrop = dragState.onDrop,
            dropX = dragState.currentX,
            dropY = dragState.currentY,
        }
        dragState.active = false
        return dropData
    end
    return nil
end

function UIDrawDrag()
    if not dragState.active then return end
    local tex = get_texture_info(dragState.textureName)
    local size = 48 * dragState.scale
    if tex then
        size = tex.width * dragState.scale
        djui_hud_set_color(255, 255, 255, 200)
        djui_hud_render_texture(tex, dragState.currentX - size / 2, dragState.currentY - size / 2, dragState.scale,
            dragState.scale)
    else
        djui_hud_set_color(200, 200, 200, 200)
        djui_hud_render_rect(dragState.currentX - size / 2, dragState.currentY - size / 2, size, size)
    end
end

function UIIsDragging()
    return dragState.active
end

function UIIsDropTarget(x, y, w, h, dropX, dropY)
    return dropX >= x and dropX <= x + w and dropY >= y and dropY <= y + h
end

function UISlider(x, y, w, h, value, minVal, maxVal, colors, onChange)
    local percent = (value - minVal) / (maxVal - minVal)
    local fillWidth = w * percent

    djui_hud_set_color(colors.bg[1], colors.bg[2], colors.bg[3], colors.bg[4])
    djui_hud_render_rect(x, y, w, h)
    djui_hud_set_color(colors.fill[1], colors.fill[2], colors.fill[3], colors.fill[4])
    djui_hud_render_rect(x, y, fillWidth, h)

    local handleX = x + fillWidth - 4
    if handleX < x then handleX = x end
    if handleX > x + w - 8 then handleX = x + w - 8 end
    djui_hud_set_color(colors.handle[1], colors.handle[2], colors.handle[3], colors.handle[4])
    djui_hud_render_rect(handleX, y - 2, 8, h + 4)

    local mouseX = djui_hud_get_mouse_x()
    local mouseY = djui_hud_get_mouse_y()
    local buttonsDown = djui_hud_get_mouse_buttons_down()
    if buttonsDown == 1 and mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h then
        local newPercent = (mouseX - x) / w
        newPercent = math.max(0, math.min(1, newPercent))
        local newValue = minVal + newPercent * (maxVal - minVal)
        newValue = math.floor(newValue + 0.5)
        if newValue ~= value and onChange then
            onChange(newValue)
        end
        return newValue
    end
    return nil
end

function UIColorPicker(x, y, color, onChange)
    local previewSize = 64
    local sliderWidth = 200
    local sliderHeight = 20
    local spacing = 8

    djui_hud_set_color(color.r, color.g, color.b, 255)
    djui_hud_render_rect(x, y, previewSize, previewSize)

    local startX = x + previewSize + spacing
    local startY = y
    local changed = false
    local newColor = { r = color.r, g = color.g, b = color.b }

    local newR = UISlider(startX, startY, sliderWidth, sliderHeight, color.r, 0, 255,
        { bg = { 50, 50, 50, 255 }, fill = { 255, 0, 0, 255 }, handle = { 255, 255, 255, 255 } },
        function(val)
            newColor.r = val; changed = true
        end)
    if newR then
        newColor.r = newR; changed = true
    end

    local newG = UISlider(startX, startY + sliderHeight + spacing, sliderWidth, sliderHeight, color.g, 0, 255,
        { bg = { 50, 50, 50, 255 }, fill = { 0, 255, 0, 255 }, handle = { 255, 255, 255, 255 } },
        function(val)
            newColor.g = val; changed = true
        end)
    if newG then
        newColor.g = newG; changed = true
    end

    local newB = UISlider(startX, startY + (sliderHeight + spacing) * 2, sliderWidth, sliderHeight, color.b, 0, 255,
        { bg = { 50, 50, 50, 255 }, fill = { 0, 0, 255, 255 }, handle = { 255, 255, 255, 255 } },
        function(val)
            newColor.b = val; changed = true
        end)
    if newB then
        newColor.b = newB; changed = true
    end

    if changed and onChange then
        onChange(newColor)
    end
    return changed and newColor or nil
end

function UIText(text, x, y, scale, color)
    djui_hud_set_color(color[1], color[2], color[3], color[4])
    djui_hud_print_text(text, x, y, scale)
end

function UIPanel(x, y, w, h, color)
    djui_hud_set_color(color[1], color[2], color[3], color[4])
    djui_hud_render_rect(x, y, w, h)
end

function UITexture(textureName, x, y, scale, color)
    local tex = get_texture_info(textureName)
    if tex then
        if color then
            djui_hud_set_color(color[1], color[2], color[3], color[4])
        else
            djui_hud_set_color(255, 255, 255, 255)
        end
        djui_hud_render_texture(tex, x, y, scale, scale)
    end
end
