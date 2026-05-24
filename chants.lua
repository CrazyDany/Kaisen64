local chants = {
    [0] = {
        "[[ scale of the dragon ]]",
        "[[ Recoil ]]",
        "[[ TWIN METEORS ]]",
    },
    [1] = {
        "[[ phase ]]",
        "[[ Twilight ]]",
        "[[ EYES OF WISDOM ]]",
    },
    [2] = {
        "[[ phase ]]",
        "[[ Paramita ]]",
        "[[ PILLARS OF LIGHT ]]",
    },
    [3] = {
        "[[ nine ropes ]]",
        "[[ Polarised Light ]]",
        "[[ CROW AND DECLARATION ]]",
    },
}

hook_chat_command("k64-setchant", "Выбирает произносимые заклинания",
    function(msg)
        if gPlayerSyncTable[0].Kaisen64 == nil then return false end

        local number = math.clamp((tonumber(msg) or 0), 0, 3)

        gPlayerSyncTable[0].Kaisen64.chant = number
        return true
    end
)

local msglist = {}
local timerlist = {}

for i = 0, 15 do timerlist[gMarioStates[i]] = 0 end

local function display_bubble(m, c)
    djui_hud_set_resolution(RESOLUTION_N64); djui_hud_set_font(FONT_NORMAL);
    local out = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 210, z = m.marioObj.header.gfx.pos.z }
    djui_hud_world_pos_to_screen_pos(out, out)

    local scale = 0.4 - (vec3f_dist(m.pos, gMarioStates[0].pos)) / 16384

    if scale > 0 then
        local measure = djui_hud_measure_text(c) * (scale / 2)
        djui_hud_set_color(255, 255, 255, 127); djui_hud_render_rect(out.x - measure, out.y, measure * 2, 32 * scale); djui_hud_set_color(
            0, 0, 0, 255); djui_hud_print_text(c, out.x - measure, out.y, scale);
    end
end

local function render_bubbles()
    for i = 0, 15 do
        if msglist[gMarioStates[i]] ~= nil and gNetworkPlayers[i].currActNum == gNetworkPlayers[0].currActNum and gNetworkPlayers[i].currAreaIndex == gNetworkPlayers[0].currAreaIndex and gNetworkPlayers[i].currLevelNum == gNetworkPlayers[0].currLevelNum then
            display_bubble(gMarioStates[i], msglist[gMarioStates[i]])
        else
            msglist[gMarioStates[i]] = nil
        end
    end
end

local function addmsg(m, c)
    msglist[m] = c; timerlist[m] = 255;
end

local function clearmsgs()
    for i = 0, 15 do msglist[gMarioStates[i]] = nil end
end

local function updatetimer()
    for i = 0, 15 do
        if timerlist[gMarioStates[i]] > 0 then
            timerlist[gMarioStates[i]] = timerlist[gMarioStates[i]] - 1
        else
            msglist[gMarioStates[i]] = nil
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, render_bubbles)
hook_event(HOOK_ON_WARP, clearmsgs)
hook_event(HOOK_UPDATE, updatetimer)

hook_event(HOOK_MARIO_UPDATE,
    --- @param m MarioState
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end

        if (m.controller.buttonPressed & CONT_UP) ~= 0 then
            if (gPlayerSyncTable[m.playerIndex].Kaisen64.chant_cooldown or 0) > 0 then
                return
            end

            if gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant == 3 then
                return
            end

            if m.playerIndex == 0 then
                if gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant == 3 then
                    gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant = 0
                    gPlayerSyncTable[m.playerIndex].Kaisen64.chant_cooldown = 512
                else
                    gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant = math.clamp(
                        (gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant or 0) +
                        1, 0, 3)
                    gPlayerSyncTable[m.playerIndex].Kaisen64.chant_cooldown = 128
                end

                addmsg(m,
                    chants[gPlayerSyncTable[m.playerIndex].Kaisen64.chant or 0]
                    [gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant]
                )

                -- djui_chat_message_create("Chant: " .. gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant)

                for i = 0, MAX_PLAYERS - 1 do
                    if gNetworkPlayers[i].currActNum == gNetworkPlayers[0].currActNum and gNetworkPlayers[i].currAreaIndex == gNetworkPlayers[0].currAreaIndex and gNetworkPlayers[i].currLevelNum == gNetworkPlayers[0].currLevelNum then
                        network_send(true,
                            {
                                chant_msg = chants[gPlayerSyncTable[m.playerIndex].Kaisen64.chant or 0]
                                    [gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant],
                                chant_msg_index = network_global_index_from_local(0)
                            }
                        )
                    end
                end
            end

            if gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant == 1 then
                PlaySound("Chant1", 1)
                network_send(true,
                    {
                        k64_playStream = "Chant1",
                        k64_playStream_playVolume = 1
                    }
                )
            elseif gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant == 2 then
                PlaySound("Chant2", 1)
                network_send(true,
                    {
                        k64_playStream = "Chant2",
                        k64_playStream_playVolume = 1
                    }
                )
            elseif gPlayerSyncTable[m.playerIndex].Kaisen64.cur_chant == 3 then
                PlaySound("Chant3", 1)
                network_send(true,
                    {
                        k64_playStream = "Chant3",
                        k64_playStream_playVolume = 1
                    }
                )
            end
        end
    end
)

hook_event(HOOK_UPDATE,
    function()
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        if (gPlayerSyncTable[0].Kaisen64.chant_cooldown or 0) > 0 then
            gPlayerSyncTable[0].Kaisen64.chant_cooldown = gPlayerSyncTable[0].Kaisen64.chant_cooldown - 1
        end
    end
)

hook_event(HOOK_ON_PACKET_RECEIVE,
    --- comment
    --- @param dataTable table
    function(dataTable)
        if dataTable.chant_msg == nil then return end

        addmsg(gMarioStates[network_local_index_from_global(dataTable.chant_msg_index)], dataTable.chant_msg)
    end
)
