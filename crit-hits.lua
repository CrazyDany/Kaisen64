local n = 7


ACT_BE_HITTED_WITH_BLACKFLASH = allocate_mario_action(ACT_FLAG_STATIONARY)

hook_mario_action(ACT_BE_HITTED_WITH_BLACKFLASH,
    function(m)
        set_character_anim_with_accel(m, CHAR_ANIM_BACKWARD_AIR_KB, 0)
        -- m.marioObj.header.gfx.animInfo.animFrame = 0
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
)

ACT_COMBO_BLACKFLASH = allocate_mario_action(ACT_FLAG_STATIONARY | ACT_FLAG_ATTACKING)

hook_mario_action(ACT_COMBO_BLACKFLASH,
    function(m)
        set_character_anim_with_accel(m, CHAR_ANIM_AIR_KICK, 0)

        if (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            set_mario_action(m, ACT_PUNCHING, 0)
        end
    end
)

hook_event(HOOK_ON_PVP_ATTACK,
    function(a, v, i)
        if not IsCritAllowed() then return end

        if v.playerIndex == 0 then
            network_send_to(a.playerIndex, true, { k64_IDOACLACKERFLASH = true })
            local attackYaw = a.faceAngle.y + 0x8000

            -- set_mario_action(a, ACT_COMBO_BLACKFLASH, 0)
            set_mario_action(v, ACT_BE_HITTED_WITH_BLACKFLASH, 0)

            local screenWidth = djui_hud_get_screen_width()
            local screenHeight = djui_hud_get_screen_height()

            local scale = 8
            local frames = {
                { frame = 0,  x = 0, y = 0, scale = scale, color = { 255, 255, 255, 255 } },
                { frame = 32, x = 0, y = 0, scale = scale, color = { 255, 255, 255, 255 } },
            }

            PlaySound("BlackFlash", 1.5)

            UITweenTexture("bf-anim", frames,
                {
                    looping = false,
                    animated = true,
                    numFrames = 32,
                    frameDelay = 1,
                    onComplete = function()
                        -- set_mario_action(a, ACT_IDLE, 0)
                        -- set_character_anim_with_accel(a, CHAR_ANIM_AIR_KICK, 0)
                        v.faceAngle.y = attackYaw
                        set_mario_action(v, ACT_BACKWARD_AIR_KB, 0)
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
    end
)

hook_event(HOOK_UPDATE,
    function()
        if network_is_server() then
            if gGlobalSyncTable.Kaisen64 == nil then
                gGlobalSyncTable.Kaisen64 = {}
                return
            end

            if get_global_timer() % (n + 1) == 0 then
                gGlobalSyncTable.Kaisen64.critTiming = (get_global_timer() % n) + 1
            end
        end

        -- djui_chat_message_create("Current crit timing: " .. (gGlobalSyncTable.Kaisen64.critTiming or 0))
    end
)

function IsCritAllowed()
    -- return (gGlobalSyncTable.Kaisen64.critTiming or 0) == 1
    return true
end
