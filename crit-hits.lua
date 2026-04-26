local n = 7

hook_event(HOOK_ALLOW_PVP_ATTACK,
    function(a, v, i)
        if not IsCritAllowed() then return true end

        if v.playerIndex == 0 or a.playerIndex == 0 then
            local screenWidth = djui_hud_get_screen_width()
            local screenHeight = djui_hud_get_screen_height()

            local m = gMarioStates[0]
            start_cutscene(m.area.camera, 35)
            -- local fadeAnim = UITweenRect(
            --     {
            --         { frame = 0,      x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 0, 0, 0, 31 } },
            --         { frame = 4,      x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 0, 0, 0, 255 } },
            --         { frame = 4 + 16, x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 0, 0, 0, 255 } },
            --     }, {
            --         looping = false,
            --         onComplete = function()
            --             djui_chat_message_create("Critical hit!")
            --             PlaySound("BlackFlash", 1.5)
            --             local flashAnim = UITweenRect(
            --                 {
            --                     { frame = 0,     x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
            --                     { frame = 1,     x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 255 } },
            --                     { frame = 1 + 4, x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
            --                 }, {
            --                     looping = false,
            --                 }
            --             )
            --         end
            --     }
            -- )
        end

        return true
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
