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
        if mouseButtonsPressed == 1 then
            return K64_BUTTON_LEFT_CLICK
        end

        if mouseButtonsPressed == 4 then
            return K64_BUTTON_RIGHT_CLICK
        end

        return K64_BUTTON_HOVER
    end
    return K64_BUTTON_NONE
end
