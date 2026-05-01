--- @type table
local hookedFunctions = {}

--- @param f function
function HookEvent_LocalMarioPVPAttack(f)
    table.insert(hookedFunctions, f)
end

--- @param v MarioState
--- @param i integer
local function onLocalMarioAttack(v, i)
    if v.playerIndex == 0 then return end

    for _, func in ipairs(hookedFunctions) do
        if gPlayerSyncTable[0].betterpvp_n <= 0 then
            func(v, i)
        end
    end

    gPlayerSyncTable[0].betterpvp_n = 12
end

hook_event(HOOK_UPDATE,
    function()
        gPlayerSyncTable[0].betterpvp_n = (gPlayerSyncTable[0].betterpvp_n or 0) - 1
        if gPlayerSyncTable[0].betterpvp_n < 0 then
            gPlayerSyncTable[0].betterpvp_n = 0
        end
    end
)


hook_event(HOOK_ON_PVP_ATTACK,
    --- @param a MarioState
    --- @param v MarioState
    --- @param i integer
    function(a, v, i)
        if a.playerIndex == 0 then
            onLocalMarioAttack(v, i)
            return
        end
        if v.playerIndex == 0 then
            network_send_to(a.playerIndex, true,
                {
                    betterpvp_localMarioAttackVictim = network_global_index_from_local(v.playerIndex),
                    betterpvp_localMarioAttackInteraction = i
                })
            return
        end
    end
)

hook_event(HOOK_ON_PACKET_RECEIVE,
    --- @param dataTable table
    function(dataTable)
        if (dataTable.betterpvp_localMarioAttackVictim ~= nil) and (dataTable.betterpvp_localMarioAttackInteraction ~= nil) then
            local victim = gMarioStates[network_local_index_from_global(dataTable.betterpvp_localMarioAttackVictim)]
            local interaction = dataTable.betterpvp_localMarioAttackInteraction
            onLocalMarioAttack(victim, interaction)
        end
    end
)
