local CONFIG = {
    needPlayersForStart = 2,
    preparingTimerDuration = 30 * 5,
    endTimerDuration = 30 * 10,
    spawnRadius = 10000,
    spawnY = 100,
}

local GAME_STATE = {
    NOT_ENOUGH_PLAYERS = 0,
    WAIT               = 1,
    PREPARING          = 2,
    PLAYING            = 3,
    END                = 4,
}

local SPAWN_POINTS = {}
do
    local count = 720
    for i = 0, count - 1 do
        local angle = 2 * math.pi / count * i
        SPAWN_POINTS[i] = {
            x = CONFIG.spawnRadius * math.sin(angle),
            y = CONFIG.spawnY,
            z = -CONFIG.spawnRadius * math.cos(angle),
        }
    end
end

if network_is_server() then
    gGlobalSyncTable.curGameState = GAME_STATE.NOT_ENOUGH_PLAYERS
    gGlobalSyncTable.preparingTimer = CONFIG.preparingTimerDuration
    gGlobalSyncTable.endTimer = 0
    gGlobalSyncTable.nonSpectatorCount = 0
end

gPlayerSyncTable[0].spectator = false


local function isPlayerSpectator(pid)
    return gPlayerSyncTable[pid] and gPlayerSyncTable[pid].spectator == true
end

local function onGameStateChanged(tag, oldState, newState)
    ResetAbilities()
    if newState == GAME_STATE.WAIT then
        gServerSettings.playerInteractions = PLAYER_INTERACTIONS_NONE
        djui_chat_message_create("Ожидание игроков...")
        if oldState == GAME_STATE.END then
            if gPlayerSyncTable[0].spectator then
                gPlayerSyncTable[0].spectator = false
            end
        end

        if network_is_server() then
            StopAllThemes()
            SetBackgroundMusic("Lobby")
        end
    elseif newState == GAME_STATE.PREPARING then
        djui_chat_message_create("Подготовка...")
        if network_is_server() then
            SetBackgroundMusic("Game")
        end
    elseif newState == GAME_STATE.PLAYING then
        djui_chat_message_create("Игра началась!")
        gServerSettings.playerInteractions = PLAYER_INTERACTIONS_SOLID
    elseif newState == GAME_STATE.END then
        djui_chat_message_create("Игра окончена!")
    elseif newState == GAME_STATE.NOT_ENOUGH_PLAYERS then
        djui_chat_message_create("Недостаточно игроков для старта")
    end
end

hook_on_sync_table_change(gGlobalSyncTable, "curGameState", "GameStateHook", onGameStateChanged)

local function onStartGameCommand(msg)
    if not network_is_server() then return true end

    local state = gGlobalSyncTable.curGameState
    if state == GAME_STATE.WAIT then
        djui_chat_message_create("Начинаем игру...")
        gGlobalSyncTable.curGameState = GAME_STATE.PREPARING
        gGlobalSyncTable.preparingTimer = CONFIG.preparingTimerDuration

        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                gPlayerSyncTable[i].spawnPointIndex = math.random(0, 719)
            end
        end
    else
        if state == GAME_STATE.NOT_ENOUGH_PLAYERS then
            djui_chat_message_create("Недостаточно игроков")
        else
            djui_chat_message_create("Игра уже началась")
        end
    end
    return true
end

if network_is_server() then
    hook_chat_command("k64-start", "Начинает игру", onStartGameCommand)
end

local function serverUpdateGameState()
    local connectedCount = 0
    local nonSpectatorCount = 0

    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            connectedCount = connectedCount + 1
            if not isPlayerSpectator(i) then
                nonSpectatorCount = nonSpectatorCount + 1
            end
        end
    end

    gGlobalSyncTable.nonSpectatorCount = nonSpectatorCount
    local currentState = gGlobalSyncTable.curGameState

    if connectedCount < CONFIG.needPlayersForStart then
        if currentState ~= GAME_STATE.NOT_ENOUGH_PLAYERS then
            gGlobalSyncTable.curGameState = GAME_STATE.NOT_ENOUGH_PLAYERS
        end
        return
    end

    if currentState == GAME_STATE.NOT_ENOUGH_PLAYERS then
        gGlobalSyncTable.curGameState = GAME_STATE.WAIT
        return
    end

    if currentState == GAME_STATE.PREPARING then
        local timer = gGlobalSyncTable.preparingTimer - 1
        gGlobalSyncTable.preparingTimer = timer
        if timer <= 0 then
            gGlobalSyncTable.curGameState = GAME_STATE.PLAYING
            gGlobalSyncTable.preparingTimer = CONFIG.preparingTimerDuration
        end
    elseif currentState == GAME_STATE.PLAYING then
        if nonSpectatorCount < 2 then
            gGlobalSyncTable.endTimer = CONFIG.endTimerDuration
            gGlobalSyncTable.curGameState = GAME_STATE.END
        end
    elseif currentState == GAME_STATE.END then
        local timer = gGlobalSyncTable.endTimer - 1
        gGlobalSyncTable.endTimer = timer
        if timer <= 0 then
            gGlobalSyncTable.curGameState = GAME_STATE.WAIT
        end
    end
end

local function clientMarioUpdate(m)
    if m.playerIndex ~= 0 then return end

    local state = gGlobalSyncTable.curGameState
    local isSpectator = isPlayerSpectator(m.playerIndex)

    if state == GAME_STATE.WAIT then
        m.health = 0x880
    end

    if state == GAME_STATE.PREPARING and not isSpectator then
        local idx = gPlayerSyncTable[m.playerIndex].spawnPointIndex or 0
        local point = SPAWN_POINTS[idx]
        if point then
            m.pos.x = point.x
            m.pos.y = point.y
            m.pos.z = point.z
        end
        if CloseModMenu then CloseModMenu() end
    end

    if state == GAME_STATE.END and gGlobalSyncTable.endTimer <= 2 then
        m.pos.x = m.spawnInfo.startPos.x
        m.pos.y = m.spawnInfo.startPos.y
        m.pos.z = m.spawnInfo.startPos.z
    end

    if state == GAME_STATE.PLAYING and isSpectator then
        m.health = 0
    end
end

hook_event(HOOK_UPDATE, function()
    if network_is_server() then
        serverUpdateGameState()
    end
end)

hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end
    clientMarioUpdate(m)
end)

hook_event(HOOK_ON_PLAYER_CONNECTED, function(connector)
    if not network_is_server() then return end
    if connector.playerIndex == 0 then return end

    local state = gGlobalSyncTable.curGameState
    if state == GAME_STATE.PLAYING or state == GAME_STATE.END or state == GAME_STATE.PREPARING then
        gPlayerSyncTable[connector.playerIndex].spectator = true
    else
        gPlayerSyncTable[connector.playerIndex].spectator = false
    end
end)

hook_event(HOOK_ON_DEATH, function(m)
    if not m then return end

    ResetAbilities()

    local pid = m.playerIndex
    if not isPlayerSpectator(pid) and gGlobalSyncTable.curGameState == GAME_STATE.PLAYING then
        gPlayerSyncTable[pid].spectator = true

        m.pos.x = m.spawnInfo.startPos.x
        m.pos.y = m.spawnInfo.startPos.y
        m.pos.z = m.spawnInfo.startPos.z
    end
end)

function IsGameStarted()
    return gGlobalSyncTable.curGameState == GAME_STATE.PLAYING
end
