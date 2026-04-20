SFX_CLAP = audio_stream_load("clap.mp3")
SFX_JACKPOT = audio_stream_load("JACKPOT-sfx.mp3")
SFX_SWINDLER_LAUGH = audio_stream_load("Swindler-Laugh.mp3")
MSC_JACKPOT = audio_stream_load("JackpotMusic.mp3")

AudioNames = {
    ["Clap"] = SFX_CLAP,
    ["Jackpot"] = SFX_JACKPOT,
    ["SwindlerLaugh"] = SFX_SWINDLER_LAUGH,
    ["JackpotMusic"] = MSC_JACKPOT
}

-- PLAYING PLAYERS THEMES
hook_event(HOOK_MARIO_UPDATE,
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end

        local themeName = gPlayerSyncTable[m.playerIndex].Kaisen64.playingTheme
        local selfTheme = gPlayerSyncTable[0].Kaisen64.playingTheme

        if themeName == nil then return end
        if (AudioNames[themeName] == nil) then return end

        local distance = vec3f_dist(m.pos, gMarioStates[0].pos)
        local f = function(d)
            return math.clamp(1 - (d / 7500), 0, 1)
        end

        local volume = f(distance)
        -- djui_chat_message_create("Volume: " .. volume)

        audio_stream_play(AudioNames[themeName], false, volume)
    end
)

function PlaySound(name, volume)
    if AudioNames[name] == nil then return end
    audio_stream_play(AudioNames[name], false, volume)
end
