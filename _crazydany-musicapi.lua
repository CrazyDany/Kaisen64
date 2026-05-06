-- ==============================
-- music_system.lua
-- Полностью переработанная система воспроизведения музыки для Kaisen64.
-- ==============================

-- Конфигурация
local config = {
    backgroundVolume = 0.4,     -- Базовая громкость фоновой музыки
    themeFadeDistance = 7500.0, -- Дистанция, на которой тема игрока полностью затихает
}


-- Таблица с загруженными аудиопотоками
local audioStreams = {
    -- Фоновая музыка
    Lobby = audio_stream_load("LobbyTheme.mp3"),
    Game = audio_stream_load("GameTheme.mp3"),
    -- Темы игроков (и звуковые эффекты)
    Clap = audio_stream_load("clap.mp3"),
    Jackpot = audio_stream_load("JACKPOT-sfx.mp3"),
    SwindlerLaugh = audio_stream_load("Swindler-Laugh.mp3"),
    BlackFlash = audio_stream_load("ScuBF.mp3"),
    JackpotMusic = audio_stream_load("JackpotMusic.mp3"),
}

-- --- Состояние музыки (клиентское)

local currentStream = nil    -- текущий играющий аудиопоток (nil - ничего не играет)
local activeThemes = {}      -- список активных тем { name, volume, distance, globalIndex }
local needMixerUpdate = true -- флаг пересчёта микшера

-- --- Вспомогательные функции

local function getDistanceFactor(distance)
    if distance >= config.themeFadeDistance then return 0 end
    return 1 - (distance / config.themeFadeDistance)
end

-- Обновление списка активных тем на основе синхронизированных данных
local function updateActiveThemes()
    activeThemes = {}
    local localPlayerGlobalIndex = gNetworkPlayers[0] and gNetworkPlayers[0].globalIndex
    if not localPlayerGlobalIndex then return end

    for localIdx = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[localIdx] and gNetworkPlayers[localIdx].connected then
            local playerSync = gPlayerSyncTable[localIdx] and gPlayerSyncTable[localIdx].kaisen64_music
            if playerSync and playerSync.themeName then
                local globalIdx = gNetworkPlayers[localIdx].globalIndex
                local themeData = {
                    name = playerSync.themeName,
                    volume = playerSync.themeVolume or 1.0,
                    globalIndex = globalIdx,
                }
                if globalIdx ~= localPlayerGlobalIndex then
                    local otherMario = gMarioStates[localIdx]
                    local localMario = gMarioStates[0]
                    if otherMario and localMario then
                        local distance = vec3f_dist(otherMario.pos, localMario.pos)
                        themeData.distance = distance
                        themeData.volume = themeData.volume * getDistanceFactor(distance)
                    else
                        themeData.volume = 0
                    end
                else
                    themeData.distance = 0
                end
                if themeData.volume > 0 then
                    table.insert(activeThemes, themeData)
                end
            end
        end
    end
    needMixerUpdate = true
end

-- Микшер: решает, что именно играть
local function mixer()
    if #activeThemes == 0 then
        local bgStream = audioStreams[gGlobalSyncTable.backgroundMusic]
        if bgStream then
            return bgStream, config.backgroundVolume, false
        else
            return nil, 0, false
        end
    end

    -- Приоритет: локальная тема > самая громкая (ближайшая)
    local localPlayerGlobalIndex = gNetworkPlayers[0] and gNetworkPlayers[0].globalIndex
    local bestTheme = nil
    local bestScore = -1

    for _, theme in ipairs(activeThemes) do
        local score = (theme.globalIndex == localPlayerGlobalIndex) and 1000 or theme.volume
        if score > bestScore then
            bestScore = score
            bestTheme = theme
        end
    end

    if bestTheme and audioStreams[bestTheme.name] then
        return audioStreams[bestTheme.name], math.min(bestTheme.volume, 1.0), true
    end
    return nil, 0, false
end

-- --- Хуки

-- Событие обновления кадра (только для локального игрока)
hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end

    updateActiveThemes()
    local stream, targetVolume, isTheme = mixer()

    if currentStream ~= stream then
        if currentStream then
            audio_stream_stop(currentStream)
            currentStream = nil
        end
        if stream and targetVolume > 0 then
            audio_stream_play(stream, false, targetVolume)
            currentStream = stream
        end
    elseif stream and currentStream == stream then
        audio_stream_set_volume(stream, targetVolume)
    end
end)

-- Подключение нового игрока: создаём подтаблицу для музыки
hook_event(HOOK_ON_PLAYER_CONNECTED, function(connector)
    if not gPlayerSyncTable[connector.playerIndex] then return end

    if not gPlayerSyncTable[connector.playerIndex].kaisen64_music then
        gPlayerSyncTable[connector.playerIndex].kaisen64_music = {}

        gPlayerSyncTable[connector.playerIndex].kaisen64_music.themeName = nil
        gPlayerSyncTable[connector.playerIndex].kaisen64_music.themeVolume = 1.0
    end
    needMixerUpdate = true
end)

-- Инициализация глобального состояния (только на сервере)
if network_is_server() then
    if not gGlobalSyncTable.backgroundMusic then
        gGlobalSyncTable.backgroundMusic = "Lobby"
    end
end

-- Отслеживание изменения фоновой музыки
hook_on_sync_table_change(gGlobalSyncTable, "backgroundMusic", "Kaisen64_MusicHook", function()
    needMixerUpdate = true
end)

-- --- Публичные API

function SetBackgroundMusic(musicName)
    if not network_is_server() then return end
    if audioStreams[musicName] then
        gGlobalSyncTable.backgroundMusic = musicName
    end
end

function PlayPlayerTheme(playerIndex, themeName, volume)
    if not gPlayerSyncTable[playerIndex] then return end
    if not gPlayerSyncTable[playerIndex].kaisen64_music then
        gPlayerSyncTable[playerIndex].kaisen64_music = { themeName = nil, themeVolume = 1.0 }
    end
    gPlayerSyncTable[playerIndex].kaisen64_music.themeName = themeName
    gPlayerSyncTable[playerIndex].kaisen64_music.themeVolume = volume or 1.0
end

function StopPlayerTheme(playerIndex)
    if gPlayerSyncTable[playerIndex] and gPlayerSyncTable[playerIndex].kaisen64_music then
        gPlayerSyncTable[playerIndex].kaisen64_music.themeName = nil
    end
end

function StopAllThemes()
    for i = 0, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i] and gPlayerSyncTable[i].kaisen64_music then
            gPlayerSyncTable[i].kaisen64_music.themeName = nil
        end
    end
end

function PlaySoundEffect(sfxName, volume)
    if audioStreams[sfxName] then
        audio_stream_play(audioStreams[sfxName], false, volume or 1.0)
    end
end

print("[Kaisen64 Music System] Loaded successfully")
