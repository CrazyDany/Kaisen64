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

    if dataTable.k64_playStream ~= nil then
        local playVolume = dataTable.k64_playStream_playVolume or 1
        PlaySound(AudioNames[dataTable.k64_playStream], playVolume)
    end

    if dataTable.k64_IDOACLACKERFLASH ~= nil then
        local m = gMarioStates[0]

        set_mario_action(m, ACT_COMBO_BLACKFLASH, 0)

        local screenWidth = djui_hud_get_screen_width()
        local screenHeight = djui_hud_get_screen_height()

        local scale = 8
        local frames = {
            { frame = 0,  x = 0, y = 0, scale = scale, color = { 255, 255, 255, 255 } },
            { frame = 14, x = 0, y = 0, scale = scale, color = { 255, 255, 255, 255 } },
        }

        PlaySound("BlackFlash", 1.5)

        UITweenTexture("bf-anim", frames,
            {
                looping = false,
                animated = true,
                numFrames = 14,
                frameDelay = 1,
                onComplete = function()
                    set_mario_action(m, ACT_JUMP_KICK, 0)
                    set_character_anim_with_accel(m, CHAR_ANIM_AIR_KICK, 0)
                    djui_chat_message_create("Critical hit!")
                    UITweenRect(
                        {
                            { frame = 0,     x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
                            { frame = 1,     x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 255 } },
                            { frame = 1 + 4, x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
                        }, {
                            looping = false,
                        }
                    )
                end
            })
    end
end)
