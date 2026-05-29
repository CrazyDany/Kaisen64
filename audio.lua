SFX_CLAP = audio_sample_load("clap.mp3")
SFX_JACKPOT = audio_sample_load("JACKPOT-sfx.mp3")
SFX_SWINDLER_LAUGH = audio_sample_load("Swindler-Laugh.mp3")
SFX_BLACKFLASH = audio_sample_load("ScuBF.mp3")
SFX_CHANT1 = audio_sample_load("ScuChant1.mp3")
SFX_CHANT2 = audio_sample_load("ScuChant2.mp3")
SFX_CHANT3 = audio_sample_load("ScuChant3.mp3")

AudioSamplesNames = {
    ["Clap"] = SFX_CLAP,
    ["Jackpot"] = SFX_JACKPOT,
    ["SwindlerLaugh"] = SFX_SWINDLER_LAUGH,
    ["BlackFlash"] = SFX_BLACKFLASH,
    ["Chant1"] = SFX_CHANT1,
    ["Chant2"] = SFX_CHANT2,
    ["Chant3"] = SFX_CHANT3
}

--- @param name string
--- @param pos Vec3f
--- @param volume number
--- @param forEveryone boolean
function PlaySample(name, pos, volume, forEveryone)
    if AudioSamplesNames[name] == nil then return end

    if pos ~= nil then
        audio_sample_play(AudioSamplesNames[name], pos, volume)

        if not forEveryone then return end
        network_send(true,
            {
                k64_play_sample_name = name,
                k64_play_sample_posX = pos.x,
                k64_play_sample_posY = pos.y,
                k64_play_sample_posZ = pos.z,
                k64_play_sample_volume = volume
            }
        )
    else
        audio_sample_play(AudioSamplesNames[name], gMarioStates[0].pos, volume)

        if not forEveryone then return end
        network_send(true,
            {
                k64_play_sample_name = name,
                k64_play_sample_volume = volume
            }
        )
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE,
    function(dataTable)
        if dataTable.k64_play_sample_name ~= nil then
            local name = dataTable.k64_play_sample_name
            local m = gMarioStates[0]
            local pos = {
                x = dataTable.k64_play_sample_posX or m.pos.x,
                y = dataTable.k64_play_sample_posY or m.pos.y,
                z = dataTable.k64_play_sample_posZ or m.pos.z,
            }
            local volume = dataTable.k64_play_sample_volume or 1
            if AudioSamplesNames[name] == nil then return end
            audio_sample_play(AudioSamplesNames[name], pos, volume)
        end
    end
)
