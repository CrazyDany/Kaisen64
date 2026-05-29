hook_event(HOOK_ON_PACKET_RECEIVE, function(dataTable)
    if dataTable.k64_changePos_x ~= nil then
        gMarioStates[0].pos.x = dataTable.k64_changePos_x
    end

    if dataTable.k64_changePos_y ~= nil then
        gMarioStates[0].pos.y = dataTable.k64_changePos_y
    end

    if dataTable.k64_changePos_z ~= nil then
        gMarioStates[0].pos.z = dataTable.k64_changePos_z
    end

    if dataTable.k64_playFlash ~= nil then
        local screenWidth = djui_hud_get_screen_width()
        local screenHeight = djui_hud_get_screen_height()

        UITweenRect(
            {
                { frame = 0,         x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
                { frame = 1,         x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 255 } },
                { frame = 1 + 8,     x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 255 } },
                { frame = 1 + 8 + 4, x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
            }, {
                looping = false,
            }
        )
    end
end)
