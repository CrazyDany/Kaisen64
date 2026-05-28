hook_event(HOOK_ON_NAMETAGS_RENDER,
    function(playerIndex, pos)
        local i = tonumber(playerIndex)

        if GetShowStatsInNames() == false then return end

        return {
            name = gNetworkPlayers[i].name .. " / " .. "Kills: " .. (gPlayerSyncTable[i].Kaisen64.kills or 0),
            pos = pos
        }
    end
)

hook_event(HOOK_ON_HUD_RENDER_BEHIND,
    function()
        djui_hud_set_resolution(RESOLUTION_N64)

        if (not IsGameStarted() and not IsDevModActivated()) then return end
        if GetShowOtherHealthbars() == false then return end
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].currActNum == gNetworkPlayers[0].currActNum and gNetworkPlayers[i].currAreaIndex == gNetworkPlayers[0].currAreaIndex and gNetworkPlayers[i].currLevelNum == gNetworkPlayers[0].currLevelNum then
                local m = gMarioStates[i]

                local out = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 250, z = m.marioObj.header.gfx.pos.z }
                djui_hud_world_pos_to_screen_pos(out, out)

                local scale = 0.4 - (vec3f_dist(m.pos, gMarioStates[0].pos)) / 16384

                if scale > 0 then
                    local width = 128
                    local height = 16
                    local measure = width * (scale / 2)
                    local healthRatio = (m.health - 255) / 1921

                    djui_hud_set_color(31, 31, 31, 200)
                    djui_hud_render_rect(out.x - measure, out.y, width * scale, height * scale)
                    djui_hud_set_color(80, 200, 80, 255)
                    djui_hud_render_rect(out.x - measure, out.y, width * scale * healthRatio, height * scale)
                end
            end
        end
    end
)
