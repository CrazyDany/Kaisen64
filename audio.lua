SFX_CLAP = audio_stream_load("clap.mp3")
SFX_JACKPOT = audio_stream_load("JACKPOT-sfx.mp3")
SFX_SWINDLER_LAUGH = audio_stream_load("Swindler-Laugh.mp3")
SFX_BLACKFLASH = audio_stream_load("ScuBF.mp3")
SFX_CHANT1 = audio_stream_load("ScuChant1.mp3")
SFX_CHANT2 = audio_stream_load("ScuChant2.mp3")
SFX_CHANT3 = audio_stream_load("ScuChant3.mp3")

AudioNames = {
    ["Clap"] = SFX_CLAP,
    ["Jackpot"] = SFX_JACKPOT,
    ["SwindlerLaugh"] = SFX_SWINDLER_LAUGH,
    ["BlackFlash"] = SFX_BLACKFLASH,
    ["Chant1"] = SFX_CHANT1,
    ["Chant2"] = SFX_CHANT2,
    ["Chant3"] = SFX_CHANT3
}

function PlaySound(name, volume)
    if AudioNames[name] == nil then return end
    audio_stream_play(AudioNames[name], false, volume)
end
