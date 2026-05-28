ABILITY_ID_CLAPSWAP = 0

local function onUseSwitchSwap()
    local target = AbilitiesData[ABILITY_ID_CLAPSWAP].target
    local targetType = AbilitiesData[ABILITY_ID_CLAPSWAP].targetType

    local m = gMarioStates[0]

    if targetType == "player" then
        if target.playerIndex == 0 then return false end

        local screenWidth = djui_hud_get_screen_width()
        local screenHeight = djui_hud_get_screen_height()

        PlaySound("Clap", 1)

        UITweenRect(
            {
                { frame = 0,         x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
                { frame = 1,         x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 255 } },
                { frame = 1 + 8,     x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 255 } },
                { frame = 1 + 8 + 4, x = 0, y = 0, w = screenWidth, h = screenHeight, color = { 255, 255, 255, 0 } },
            }, {
                looping = false,
            }
        )

        network_send(true,
            {
                k64_playStream = "Clap",
                k64_playStream_playVolume = 1,
                k64_playFlash = true,
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

        AbilitiesData[ABILITY_ID_CLAPSWAP].target = nil
        AbilitiesData[ABILITY_ID_CLAPSWAP].targetType = nil
    elseif targetType == "object" then
        if target == nil then return false end

        PlaySound("Clap", 1)

        network_send(true,
            {
                k64_playStream = "Clap",
                k64_playStream_playVolume = 1
            })

        local selfPosX = m.pos.x
        local selfPosY = m.pos.y
        local selfPosZ = m.pos.z

        m.pos.x = target.oPosX
        m.pos.y = target.oPosY
        m.pos.z = target.oPosZ

        target.oPosX = selfPosX
        target.oPosY = selfPosY
        target.oPosZ = selfPosZ

        AbilitiesData[ABILITY_ID_CLAPSWAP].target = nil
        AbilitiesData[ABILITY_ID_CLAPSWAP].targetType = nil
    end
end

HookEvent_LocalMarioPVPAttack(
    function(v, i)
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        AbilitiesData[ABILITY_ID_CLAPSWAP].target = v
        AbilitiesData[ABILITY_ID_CLAPSWAP].targetType = "player"
    end
)

hook_event(HOOK_ON_ATTACK_OBJECT,
    --- comment
    --- @param m MarioState
    --- @param o Object
    --- @param i integer
    function(m, o, i)
        if gPlayerSyncTable[0].Kaisen64 == nil then return end
        if m.playerIndex ~= 0 then return end

        if o.oPosX == nil or o.oPosY == nil or o.oPosZ == nil then return end

        AbilitiesData[ABILITY_ID_CLAPSWAP].target = o
        AbilitiesData[ABILITY_ID_CLAPSWAP].targetType = "object"
    end
)

RegisterAbility(ABILITY_ID_CLAPSWAP, {
    name = "ClapSwap",
    shortName = "ClSw",
    description = {
        "Clap your hands and switch places with your last hitted player."
    },
    iconTextureName = "swsw",

    cost = 32,
    cooldown = 32,
    curCooldown = 0,

    onUseFunction = onUseSwitchSwap,
    getPermissibilityToUse = function()
        if AbilitiesData[ABILITY_ID_CLAPSWAP].target == nil or AbilitiesData[ABILITY_ID_CLAPSWAP].targetType == nil then
            return false
        end

        return true
    end,
    getExtraInfo = function()
        local ability = AbilitiesData[ABILITY_ID_CLAPSWAP]

        if ability == nil then return { "" } end

        if ability.target == nil or ability.targetType == nil then return { "Target: - " } end

        if AbilitiesData[ABILITY_ID_CLAPSWAP].targetType == "player" then
            local targetIndex = AbilitiesData[ABILITY_ID_CLAPSWAP].target.playerIndex
            return { "Target: " .. gNetworkPlayers[targetIndex].name }
        elseif AbilitiesData[ABILITY_ID_CLAPSWAP].targetType == "object" then
            return { "Target: Object" }
        end

        return { "Target: - " }
    end,

    onResetVariables = function()
        AbilitiesData[ABILITY_ID_CLAPSWAP].target = nil
        AbilitiesData[ABILITY_ID_CLAPSWAP].targetType = nil
    end,

    -- Кастомные поля
    target = nil,
    targetType = nil,
})

-- penis shutnika
