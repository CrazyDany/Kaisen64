local config = {
    backgroundVolume = 0.4,
    themeFadeDistance = 7500.0,
}

local audioStreams = {
    Lobby        = audio_stream_load("LobbyTheme.mp3"),
    Game         = audio_stream_load("GameTheme.mp3"),
    JackpotMusic = audio_stream_load("JackpotMusic.mp3"),
}

local backgroundStream = nil

local themeStreams = {}

local function startBackgroundMusic()
    if backgroundStream then return end
    local bgName = gGlobalSyncTable.backgroundMusic
    local stream = bgName and audioStreams[bgName]
    if stream then
        audio_stream_play(stream, false, 0)
        audio_stream_set_looping(stream, true)
        backgroundStream = stream
    end
end

local function updateBackgroundVolume()
    if not backgroundStream then return end
    local anyTheme = false
    for i = 0, MAX_PLAYERS - 1 do
        local musicData = gPlayerSyncTable[i] and gPlayerSyncTable[i].kaisen64_music
        if musicData and musicData.themeName then
            anyTheme = true
            break
        end
    end
    local targetVol = anyTheme and 0 or config.backgroundVolume
    audio_stream_set_volume(backgroundStream, targetVol)
end

local function updateThemes()
    local localMario = gMarioStates[0]
    if not localMario then return end

    local allActiveThemes = {}
    local themeVolumes = {}

    for i = 0, MAX_PLAYERS - 1 do
        local musicData = gPlayerSyncTable[i] and gPlayerSyncTable[i].kaisen64_music
        if musicData and musicData.themeName then
            local themeName = musicData.themeName
            local baseVol = musicData.themeVolume or 1.0
            allActiveThemes[themeName] = true

            if i == 0 then
                themeVolumes[themeName] = math.max(themeVolumes[themeName] or 0, baseVol)
            else
                local otherMario = gMarioStates[i]
                if otherMario then
                    local dist = vec3f_dist(otherMario.pos, localMario.pos)
                    local factor = (dist >= config.themeFadeDistance) and 0 or (1 - dist / config.themeFadeDistance)
                    local vol = baseVol * factor
                    if vol > 0 then
                        themeVolumes[themeName] = math.max(themeVolumes[themeName] or 0, vol)
                    end
                end
            end
        end
    end

    for themeName, _ in pairs(allActiveThemes) do
        if not themeStreams[themeName] and audioStreams[themeName] then
            local stream = audioStreams[themeName]
            audio_stream_play(stream, false, 0) -- стартуем с громкостью 0
            themeStreams[themeName] = { stream = stream, active = true }
        end
    end

    for themeName, info in pairs(themeStreams) do
        local desiredVol = themeVolumes[themeName] or 0
        audio_stream_set_volume(info.stream, desiredVol)
    end

    for themeName, info in pairs(themeStreams) do
        if not allActiveThemes[themeName] then
            audio_stream_stop(info.stream)
            themeStreams[themeName] = nil
        end
    end
end

local function initMusicSystem()
    if network_is_server() then
        if not gGlobalSyncTable.backgroundMusic then
            gGlobalSyncTable.backgroundMusic = "Lobby"
        end
    end
    startBackgroundMusic()
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end
    updateBackgroundVolume()
    updateThemes()
end)

hook_event(HOOK_ON_PLAYER_CONNECTED, function(connector)
    if not gPlayerSyncTable[connector.playerIndex] then return end
    if not gPlayerSyncTable[connector.playerIndex].kaisen64_music then
        gPlayerSyncTable[connector.playerIndex].kaisen64_music = {}
        gPlayerSyncTable[connector.playerIndex].kaisen64_music.themeName = nil
        gPlayerSyncTable[connector.playerIndex].kaisen64_music.themeVolume = 1.0
    end
end)

hook_on_sync_table_change(gGlobalSyncTable, "backgroundMusic", "Kaisen64_MusicHook", function(tag, old, new)
    if new and audioStreams[new] then
        if backgroundStream then
            audio_stream_stop(backgroundStream)
            backgroundStream = nil
        end
        startBackgroundMusic()
        updateBackgroundVolume()
    end
end)

function SetBackgroundMusic(musicName)
    if not network_is_server() then return end
    if audioStreams[musicName] then
        gGlobalSyncTable.backgroundMusic = musicName
    end
end

function PlayPlayerTheme(playerIndex, themeName, volume)
    if not gPlayerSyncTable[playerIndex] then return end
    if not gPlayerSyncTable[playerIndex].kaisen64_music then
        gPlayerSyncTable[playerIndex].kaisen64_music = {}
        gPlayerSyncTable[playerIndex].kaisen64_music.themeName = nil
        gPlayerSyncTable[playerIndex].kaisen64_music.themeVolume = 1.0
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

initMusicSystem()
