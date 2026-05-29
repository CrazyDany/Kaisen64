chants = {
    [0] = {
        "[[ драконий масштаб ]]",
        "[[ Повтори ]]",
        "[[ БЛИЗНЕЦЫ МЕТЕОРЫ ]]",
    },
    [1] = {
        "[[ фазовый ]]",
        "[[ Двойной свет ]]",
        "[[ ГЛАЗА МУДРОГО КУПОЛА ]]",
    },
    [2] = {
        "[[ фазированный ]]",
        "[[ Периметр ]]",
        "[[ СВЕТЛЫЕ КОЛОННЫ ]]",
    },
    [3] = {
        "[[ девять веревок ]]",
        "[[ Полярная лампа ]]",
        "[[ ВОРОНА И ПАРЛАМЕНТ ]]",
    },

    -- DryTry
    [4] = {
        "[[ лихорадка ячейки ]]",
        "[[ Азартная нескончаемость ]]",
        "[[ РЕКВИЕМ ГОРШКА ДЖЕКА ]]",
    },
    -- ColdMod
    [5] = {
        "[[ прохладное предложение ]]",
        "[[ Холодный Мандела ]]",
        "[[ ТИХОГО НЕ РВАЛИ ]]",
    },
    -- IreFire
    [6] = {
        "[[ янтарный сермон ]]",
        "[[ Гарь и Гордость ]]",
        "[[ КАЛЬДЕРА БЕЗ ПОЩАДЫ ]]",
    },
    -- RecTech
    [7] = {
        "[[ разбитая рамка ]]",
        "[[ Карма Остановись ]]",
        "[[ ЧЕРТОВА ПРОЕКЦИЯ ]]",
    },

    [8] = {
        "[[ железный кулак с утра ]]",
        "[[ Черное сравнение ]]",
        "[[ РАЗДЕЛИ ПРОТИВОПОЛОЖНЫЙ КРЕСТИК ]]",
    },
    -- DawnSpawn
    [9] = {
        "[[ теневой зародышь ]]",
        "[[ Десять Бриллиантов ]]",
        "[[ ДОМИНАЦИЯ НАД ПУСТОТОЙ ]]",
    },

    [10] = {
        "[[ чертово семя ]]",
        "[[ Иголка Манделы ]]",
        "[[ ЗАЦВЕТАНИЕ ПРОШЛОГО УНИЧТОЖЕНИЯ ]]",
    },

    [11] = {
        "[[ крылатый градус ]]",
        "[[ Пустая радиация ]]",
        "[[ ИЗГНАННОЕ ПРОТИВОРЕЧИЕ ]]",
    },

    [12] = {
        "[[ ебнутый с утра ]]",
        "[[ Перефранирование души ]]",
        "[[ ПРЕВРАЩЕНИЕ В САМСАРУ ]]",
    },

    [13] = {
        "[[ вращающаяся пустота ]]",
        "[[ Пустой сердечник ]]",
        "[[ БЕСКОНЕЧНОЕ СОПРИКОСНОВЕНИЕ ]]",
    },

    [14] = {
        "[[ разбитый масштаб ]]",
        "[[ Канализационная судьба ]]",
        "[[ РАВНОВЕСИЕ НИХУЯ ]]",
    },

    [15] = {
        "[[ тихий колокольчик ]]",
        "[[ Последнее Сказание ]]",
        "[[ КОНЕЦ ЭКСОРСИЗМА ]]",
    },

    [16] = {
        "[[ ржавая цепочка ]]",
        "[[ Переплёт Воу ]]",
        "[[ ДУШЕВНАЯ ТЮРЬМА ]]",
    },

    [17] = {
        "[[ курящий лотус ]]",
        "[[ Лепестный ураган ]]",
        "[[ ВЗРЫВ АНИХИЛАЦИИ ]]",
    },

    [18] = {
        "[[ тень флейты ]]",
        "[[ Луносветлый край ]]",
        "[[ КАНАЛИЗАЦИЯ ДВОЙНОГО СВЕТА ]]",
    },
}

hook_chat_command("k64-setchant", "Выбирает произносимые заклинания",
    function(msg)
        if gPlayerSyncTable[0].Kaisen64 == nil then return false end

        local number = math.clamp((tonumber(msg) or 0), 0, #chants - 1)

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
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end

        if ((m.controller.buttonPressed & CONT_UP) ~= 0) and (IsGameStarted() or IsDevModActivated()) then
            if m.playerIndex ~= 0 then return end

            local data = gPlayerSyncTable[0].Kaisen64
            if (data.chant_cooldown or 0) > 0 then return end

            local cur = data.cur_chant or 0
            if cur == 3 then
                return
            end

            local new_cur = cur + 1
            data.cur_chant = new_cur

            if new_cur == 3 then
                data.chant_cooldown = 1024
            else
                data.chant_cooldown = 128
            end

            for i, v in pairs(AbilitiesData) do
                v.curCooldown = v.curCooldown + v.cooldown * 0.5 * new_cur
            end

            local chant_text = chants[data.chant or 0][new_cur]
            addmsg(m, chant_text)

            local sound = nil
            if new_cur == 1 then
                sound = "Chant1"
            elseif new_cur == 2 then
                sound = "Chant2"
            elseif new_cur == 3 then
                sound = "Chant3"
            end
            if sound then
                PlaySample(sound, m.pos, 1.0, true)
            end

            for i = 0, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].currActNum == gNetworkPlayers[0].currActNum and
                    gNetworkPlayers[i].currAreaIndex == gNetworkPlayers[0].currAreaIndex and
                    gNetworkPlayers[i].currLevelNum == gNetworkPlayers[0].currLevelNum then
                    network_send(true, {
                        chant_msg = chant_text,
                        chant_msg_index = network_global_index_from_local(0)
                    })
                end
            end
        end
    end
)

hook_event(HOOK_UPDATE,
    function()
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        if ((gPlayerSyncTable[0].Kaisen64.chant_cooldown or 0) > 0) and (gPlayerSyncTable[0].Kaisen64.cur_chant ~= 3) then
            gPlayerSyncTable[0].Kaisen64.chant_cooldown = gPlayerSyncTable[0].Kaisen64.chant_cooldown - 1
        end

        -- djui_chat_message_create("Chant cooldown: " .. (gPlayerSyncTable[0].Kaisen64.chant_cooldown or 0))
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
