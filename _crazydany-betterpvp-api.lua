--- @type table
local hookedFunctions = {}
--- @type table
local hookedDamageFunctions = {}

--- @param f function
function HookEvent_LocalMarioPVPAttack(f)
    table.insert(hookedFunctions, f)
end

--- @param f function
function HookEvent_LocalMarioPVPDamage(f)
    table.insert(hookedDamageFunctions, f)
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

--- @param a MarioState
--- @param i integer
local function onLocalMarioDamage(a, i)
    if a.playerIndex == 0 then return end
    for _, func in ipairs(hookedDamageFunctions) do
        if gPlayerSyncTable[0].betterpvp_k <= 0 then
            func(a, i)
        end
    end

    gPlayerSyncTable[0].betterpvp_k = 4
end

hook_event(HOOK_UPDATE,
    function()
        gPlayerSyncTable[0].betterpvp_n = (gPlayerSyncTable[0].betterpvp_n or 0) - 1
        if gPlayerSyncTable[0].betterpvp_n < 0 then
            gPlayerSyncTable[0].betterpvp_n = 0
        end

        gPlayerSyncTable[0].betterpvp_k = (gPlayerSyncTable[0].betterpvp_k or 0) - 1
        if gPlayerSyncTable[0].betterpvp_k < 0 then
            gPlayerSyncTable[0].betterpvp_k = 0
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

            network_send_to(v.playerIndex, true,
                {
                    betterpvp_localMarioDamage = network_global_index_from_local(a.playerIndex),
                    betterpvp_localMarioDamage_Interaction = i
                })
            return
        end
        if v.playerIndex == 0 then
            onLocalMarioDamage(v, i)

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
        if (dataTable.betterpvp_localMarioAttackVictim ~= nil) then
            local victim = gMarioStates[network_local_index_from_global(dataTable.betterpvp_localMarioAttackVictim)]
            local interaction = dataTable.betterpvp_localMarioAttackInteraction
            onLocalMarioAttack(victim, interaction)
        end

        if (dataTable.betterpvp_localMarioDamage ~= nil) then
            local attacker = gMarioStates[network_local_index_from_global(dataTable.betterpvp_localMarioDamage)]
            local interaction = dataTable.betterpvp_localMarioDamage_Interaction
            onLocalMarioDamage(attacker, interaction)
        end
    end
)
