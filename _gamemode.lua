local GAME_STATE_NOTENOUGHPLAYERS = 0
local GAME_STATE_WAIT             = 1
local GAME_STATE_PREPARING        = 2
local GAME_STATE_PLAYING          = 3
local GAME_STATE_END              = 4

local needPlayersForStart         = 2
local REPARING_TIMER_DEFAULT      = 30 * 60
local preparingTimer              = REPARING_TIMER_DEFAULT

local SPAWN_POINTS                = {}
for i = 0, 36 do
    SPAWN_POINTS[i] = {
        x = 0 + 10000 * math.sin(2 * math.pi / 36 * i),
        y = 100,
        z = 0 - 10000 * math.cos(2 * math.pi / 36 * i)
    }
end

gGlobalSyncTable.curGameState = GAME_STATE_NOTENOUGHPLAYERS

gPlayerSyncTable[0].spectator = false

local function on_start_game_command(msg)
    if gGlobalSyncTable.curGameState == GAME_STATE_WAIT then
        djui_chat_message_create("Начинаем игру...")
        gGlobalSyncTable.curGameState = GAME_STATE_PREPARING
        for i, m in ipairs(gMarioStates) do
            if gNetworkPlayers[i].connected then
                gPlayerSyncTable[i].spawnPointIndex = math.random(0, 36)
            end
        end
    else
        if gGlobalSyncTable.curGameState == GAME_STATE_NOTENOUGHPLAYERS then
            djui_chat_message_create("Недостаточно игроков")
        else
            djui_chat_message_create("Игра уже началась")
        end
    end
    return true
end

if network_is_server() then
    hook_chat_command("k64-start", "Начинает игру", on_start_game_command)
end

local function on_server_update()
    local activePlayers = {}
    local connectedCount = 0
    for i = 0, (MAX_PLAYERS - 1) do
        if gNetworkPlayers[i].connected then
            connectedCount = connectedCount + 1
            table.insert(activePlayers, gPlayerSyncTable[i])
        end
    end

    if connectedCount < needPlayersForStart then
        gGlobalSyncTable.curGameState = GAME_STATE_NOTENOUGHPLAYERS
    elseif gGlobalSyncTable.curGameState == GAME_STATE_NOTENOUGHPLAYERS then
        gGlobalSyncTable.curGameState = GAME_STATE_WAIT
    elseif gGlobalSyncTable.curGameState == GAME_STATE_PREPARING then
        preparingTimer = preparingTimer - 1
        if preparingTimer <= 0 then
            preparingTimer = REPARING_TIMER_DEFAULT
            gGlobalSyncTable.curGameState = GAME_STATE_PLAYING
        end
    end
end

hook_event(HOOK_UPDATE,
    function()
        if network_is_server() then
            on_server_update()
        end
    end
)

hook_event(HOOK_MARIO_UPDATE,
    --- @param m MarioState
    function(m)
        if m.playerIndex ~= 0 then return end

        -- djui_chat_message_create("curGameState: " .. gGlobalSyncTable.curGameState)
        -- djui_chat_message_create("spectator: " ..
        --     (gPlayerSyncTable[m.playerIndex].spectator == true and "true" or "false"))

        if (gGlobalSyncTable.curGameState == GAME_STATE_PREPARING) and (gPlayerSyncTable[m.playerIndex].spectator == false) then
            m.pos.x = SPAWN_POINTS[gPlayerSyncTable[m.playerIndex].spawnPointIndex or 0].x
            m.pos.y = SPAWN_POINTS[gPlayerSyncTable[m.playerIndex].spawnPointIndex or 0].y
            m.pos.z = SPAWN_POINTS[gPlayerSyncTable[m.playerIndex].spawnPointIndex or 0].z

            djui_chat_message_create("Осталось " .. preparingTimer / 30 .. " секунд")
        end
    end
)

hook_event(HOOK_ON_PLAYER_CONNECTED,
    --- @param connector MarioState
    function(connector)
        if network_is_server() then
            if connector.playerIndex == 0 then
                return
            end
            if gGlobalSyncTable.curGameState == GAME_STATE_WAIT or gGlobalSyncTable.curGameState == GAME_STATE_NOTENOUGHPLAYERS then
                gPlayerSyncTable[connector.playerIndex].spectator = false
            else
                gPlayerSyncTable[connector.playerIndex].spectator = true
            end
        end
    end
)

-- public functions
function IsGameStarted()
    return gGlobalSyncTable.curGameState == GAME_STATE_PLAYING
end
