hook_event(HOOK_ON_NAMETAGS_RENDER,
    function(playerIndex, pos)
        local i = tonumber(playerIndex)

        return {
            name = gNetworkPlayers[i].name .. " / " .. "Kills: " .. (gPlayerSyncTable[i].Kaisen64.kills or 0),
            pos = pos
        }
    end
)
