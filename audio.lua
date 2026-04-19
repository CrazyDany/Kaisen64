SFX_CLAP = audio_sample_load("clap.mp3")
MSC_JACKPOT = audio_stream_load("JackpotMusic.mp3")

AudioNames = {
    ["clap"] = SFX_CLAP,
    ["JackpotMusic"] = MSC_JACKPOT
}

-- PLAYING PLAYERS THEMES
hook_event(HOOK_MARIO_UPDATE,
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end

        local themeName = gPlayerSyncTable[m.playerIndex].Kaisen64.playingTheme

        if themeName == nil then return end
        if AudioNames[themeName] == nil then return end

        local distance = vec3f_dist(m.pos, gMarioStates[0].pos)
        local f = function(d)
            return math.clamp(1 - (d / 7500), 0, 1)
        end

        local volume = f(distance)
        djui_chat_message_create("Volume: " .. volume)

        audio_stream_play(AudioNames[themeName], false, volume)
    end
)
