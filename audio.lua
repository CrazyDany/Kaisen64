SFX_CLAP = audio_stream_load("clap.mp3")
SFX_JACKPOT = audio_stream_load("JACKPOT-sfx.mp3")
SFX_SWINDLER_LAUGH = audio_stream_load("Swindler-Laugh.mp3")
SFX_BLACKFLASH = audio_stream_load("ScuBF.mp3")

AudioNames = {
    ["Clap"] = SFX_CLAP,
    ["Jackpot"] = SFX_JACKPOT,
    ["SwindlerLaugh"] = SFX_SWINDLER_LAUGH,
    ["BlackFlash"] = SFX_BLACKFLASH,
}

function PlaySound(name, volume)
    if AudioNames[name] == nil then return end
    audio_stream_play(AudioNames[name], false, volume)
end
