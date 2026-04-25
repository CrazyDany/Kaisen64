local lastAttacker = nil

hook_event(HOOK_ALLOW_PVP_ATTACK, function(a, v, i)
    if v.playerIndex ~= 0 then return end
    lastAttacker = gMarioStates[a.playerIndex]
    return true
end)


hook_event(HOOK_ON_DEATH, function(m)
    if lastAttacker ~= nil then
        gPlayerSyncTable[lastAttacker.playerIndex].Kaisen64.kills = (gPlayerSyncTable[lastAttacker.playerIndex].Kaisen64.kills or 0) +
            1
    end
end)
