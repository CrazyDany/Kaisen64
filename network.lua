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

    if dataTable.k64_playStream ~= nil then
        local playVolume = dataTable.k64_playStream_playVolume or 1
        PlaySound(AudioNames[dataTable.k64_playStream], playVolume)
    end
end)
