ABILITY_ID_SWITCHSWAP = 0

local function onUseSwitchSwap()
    local target = AbilitiesData[ABILITY_ID_SWITCHSWAP].target
    local targetType = AbilitiesData[ABILITY_ID_SWITCHSWAP].targetType

    if target == nil or targetType == nil then return false end

    local m = gMarioStates[0]

    if targetType == "player" then
        if target.playerIndex == 0 then return false end

        PlaySound("Clap", 1)

        network_send(true,
            {
                k64_playSample = "Clap",
                k64_playSample_playVolume = 1
            })

        network_send_to(target.playerIndex, true,
            {
                k64_changePos_x = m.pos.x,
                k64_changePos_y = m.pos.y,
                k64_changePos_z = m.pos.z
            })

        m.pos.x = target.pos.x
        m.pos.y = target.pos.y
        m.pos.z = target.pos.z

        AbilitiesData[ABILITY_ID_SWITCHSWAP].target = nil
        AbilitiesData[ABILITY_ID_SWITCHSWAP].targetType = nil

        return true
    end

    return false
end

hook_event(HOOK_ALLOW_PVP_ATTACK, function(a, v, i)
    if gPlayerSyncTable[0].Kaisen64 == nil then return end

    if a.playerIndex == 0 then
        AbilitiesData[ABILITY_ID_SWITCHSWAP].target = v
        AbilitiesData[ABILITY_ID_SWITCHSWAP].targetType = "player"
    end

    return true
end)

RegisterAbility(ABILITY_ID_SWITCHSWAP, {
    name = "Switch Swap",
    shortName = "SwSw",
    description = "",
    iconTextureName = "swsw",

    cost = 32,
    cooldown = 32,
    curCooldown = 0,

    onTryUseFunction = onUseSwitchSwap,
    getExtraInfo = function()
        local ability = AbilitiesData[ABILITY_ID_SWITCHSWAP]

        if ability == nil then return { "" } end

        if ability.target == nil or ability.targetType == nil then return { "Target: - " } end

        if AbilitiesData[ABILITY_ID_SWITCHSWAP].targetType == "player" then
            local targetIndex = AbilitiesData[ABILITY_ID_SWITCHSWAP].target.playerIndex
            return { "Target: " .. gNetworkPlayers[targetIndex].name }
        end

        return { "Target: - " }
    end,

    -- Кастомные поля
    target = nil,
    targetType = nil,
})
