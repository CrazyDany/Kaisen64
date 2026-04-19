hook_event(HOOK_ON_PACKET_RECEIVE, function(dataTable)
    if dataTable.k64_changePos_x ~= nil then
        gMarioStates[0].pos.x = dataTable.k64_changePos_x
    end

    if dataTable.k64_changePos_y ~= nil then
        gMarioStates[0].pos.y = dataTable.k64_changePos_y
    end

    if dataTable.k64_changePos_z ~= nil then
        gMarioStates[0].pos.z = dataTable.k64_changePos_z
    end

    if dataTable.k64_playSample ~= nil then
        local playPos = {
            x = dataTable.k64_playSample_playPos_x or gMarioStates[0].pos.x,
            y = dataTable.k64_ or gMarioStates[0].pos.y,
            z = dataTable.k64_playSample_playPos_z or gMarioStates[0].pos.z
        }
        local playVolume = dataTable.k64_playSample_playVolume or 1
        audio_sample_play(AudioNames[dataTable.k64_playSample], playPos, playVolume)
    end
end)
