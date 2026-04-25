ABILITY_ID_DRYTRY = 1

local function onUseDryTry()
    AbilitiesData[ABILITY_ID_DRYTRY].attempts = (AbilitiesData[ABILITY_ID_DRYTRY].attempts or 0) + 1
    local attempts = AbilitiesData[ABILITY_ID_DRYTRY].attempts
    local losesInRow = AbilitiesData[ABILITY_ID_DRYTRY].losesInRow or 0
    local winsInRow = AbilitiesData[ABILITY_ID_DRYTRY].winsInRow or 0


    local pseudoChance = math.floor(attempts) + (4 * losesInRow) + math.floor(winsInRow * 2)
    if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer > 0 then
        pseudoChance = 1
    end

    AbilitiesData[ABILITY_ID_DRYTRY].stage = AbilitiesData[ABILITY_ID_DRYTRY].stage or 0

    local n1, n2, n3 = -1, -2, -3
    local min, max = 1, 9
    if AbilitiesData[ABILITY_ID_DRYTRY].stage == 0 then
        min, max = 1, 9
    elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 1 then
        min, max = 2, 9
    elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 2 then
        min, max = 4, 9
    elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 3 then
        min, max = 7, 9
    elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 4 then
        min, max = 7, 7
    end

    n1, n2, n3 = math.random(min, max), math.random(min, max), math.random(min, max)
    local n = n1 * 100 + n2 * 10 + n3

    djui_hud_set_font(FONT_MENU)

    local textScale = 7
    local text = tostring(n)
    if n % 111 == 0 then
        text = "JACKPOT"
    end

    local textX = (djui_hud_get_screen_width() - djui_hud_measure_text(text) * textScale) / 2 - 40
    local textY = djui_hud_get_screen_height() / 2 - 40 * textScale

    local keyframes = {
        { frame = 0,  x = textX, y = textY, scale = textScale, color = { 255, 255, 255, 31 } },
        { frame = 16, x = textX, y = textY, scale = textScale, color = { 255, 255, 255, 63 } },
        { frame = 24, x = textX, y = textY, scale = textScale, color = { 255, 255, 255, 63 } },
        { frame = 40, x = textX, y = textY, scale = textScale, color = { 255, 255, 255, 0 } },
    }

    UITweenText(text, FONT_MENU, keyframes)

    if n % 111 == 0 then
        -- Hitting a Jackpot

        -- Hitting without a Jackpot
        if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer <= 0 then
            AbilitiesData[ABILITY_ID_DRYTRY].healthBeforeJackpot = gMarioStates[0].health
            MultipleCooldownSpeed(0, 0.5)
        end

        -- Hitting in another Jackpot
        if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer > 0 then
            PlaySound("SwindlerLaugh", 1.5)
        end

        -- Every hitting
        PlaySound("Jackpot", 0.5)
        gPlayerSyncTable[0].Kaisen64.playingTheme = "JackpotMusic"
        gPlayerSyncTable[0].Kaisen64.playingThemeVolume = 0.5
        AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer = (AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer or 0) +
            (2 * 60 + 5) * 30
    elseif (n1 == n2) or (n1 == n3) or (n2 == n3) then
        -- Hitting a Pseudo Win
        AbilitiesData[ABILITY_ID_DRYTRY].losesInRow = 0
        AbilitiesData[ABILITY_ID_DRYTRY].winsInRow = (AbilitiesData[ABILITY_ID_DRYTRY].winsInRow or 0) + 1
        -- AddEnergy(0, (n / 6 * (gPlayerSyncTable[0].Kaisen64.maxEnergy / 1024)))
        AddRCTStateTimer(0, (n / 8) * (gPlayerSyncTable[0].Kaisen64.maxEnergy / 1024))

        if random_float() <= 0.125 then
            gMarioStates[0].health = gMarioStates[0].health + 256
        end
    else
        -- Losing
        AbilitiesData[ABILITY_ID_DRYTRY].winsInRow = 0
        AbilitiesData[ABILITY_ID_DRYTRY].losesInRow = (AbilitiesData[ABILITY_ID_DRYTRY].losesInRow or 0) + 1
        -- AddEnergy(0, (-n / 8) * (gPlayerSyncTable[0].Kaisen64.maxEnergy / 1024))
        AddRCTStateTimer(0, (-n / 6) * (gPlayerSyncTable[0].Kaisen64.maxEnergy / 1024))
        if random_float() <= (1 / 12) then
            gMarioStates[0].health = gMarioStates[0].health - 256
        end

        if random_float() <= (1 / 10) then
            set_mario_action(gMarioStates[0], ACT_SHOCKED, 0)
        end
    end

    AbilitiesData[ABILITY_ID_DRYTRY].lastResult = n

    if n % 111 ~= 0 then
        if pseudoChance > 0 and pseudoChance < 5 then
            AbilitiesData[ABILITY_ID_DRYTRY].stage = 0
        elseif pseudoChance >= 5 and pseudoChance < 15 then
            AbilitiesData[ABILITY_ID_DRYTRY].stage = 1
        elseif pseudoChance >= 15 and pseudoChance < 30 then
            AbilitiesData[ABILITY_ID_DRYTRY].stage = 2
        elseif pseudoChance >= 30 and pseudoChance < 50 then
            AbilitiesData[ABILITY_ID_DRYTRY].stage = 3
        elseif pseudoChance >= 50 then
            AbilitiesData[ABILITY_ID_DRYTRY].stage = 4
        end
    else
        AbilitiesData[ABILITY_ID_DRYTRY].stage = 3
    end
    djui_chat_message_create(tostring(pseudoChance))
    return true
end

--  Ticking jackpot :D
hook_event(HOOK_UPDATE,
    function()
        if gPlayerSyncTable[0].Kaisen64 == nil then return end

        if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer > 0 then
            -- djui_chat_message_create("Jackpot timer: " .. AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer)
            AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer = AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer - 1
            gPlayerSyncTable[0].Kaisen64.currentEnergy = gPlayerSyncTable[0].Kaisen64.maxEnergy
            gMarioStates[0].health = 2176

            if (AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer % 8) == 0 then
                set_mario_particle_flags(gMarioStates[0], PARTICLE_SPARKLES, 0)
            end

            -- End jackpot
            if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer == 0 then
                MultipleCooldownSpeed(0, 2)
                gMarioStates[0].health = AbilitiesData[ABILITY_ID_DRYTRY].healthBeforeJackpot
                gPlayerSyncTable[0].Kaisen64.playingTheme = nil
                AbilitiesData[ABILITY_ID_DRYTRY].healthBeforeJackpot = 0
                AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer = 0
                AbilitiesData[ABILITY_ID_DRYTRY].attempts = 0
                AbilitiesData[ABILITY_ID_DRYTRY].losesInRow = 0
                AbilitiesData[ABILITY_ID_DRYTRY].winsInRow = 0
            end
        end
    end
)

hook_event(HOOK_MARIO_UPDATE, function(m)
    if (gPlayerSyncTable[0].Kaisen64 == nil) or (m.playerIndex ~= 0) then return end

    if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer > 0 then
        if (AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer % 8) == 0 then
            set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
        end
        if m.action == ACT_WALKING then
            mario_set_forward_vel(m, m.forwardVel + 10)
        end
    end
end)

hook_event(HOOK_ON_SET_MARIO_ACTION, function(m)
    if (gPlayerSyncTable[0].Kaisen64 == nil) or (m.playerIndex ~= 0) then return end

    if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer > 0 then
        if m.action == ACT_JUMP then
            set_mario_action(m, ACT_DOUBLE_JUMP, 0)
        end
    end
end)

hook_event(HOOK_ALLOW_HAZARD_SURFACE, function(m, h)
    if (gPlayerSyncTable[0].Kaisen64 == nil) or (m.playerIndex ~= 0) then return end

    if AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer > 0 then
        if h == HAZARD_TYPE_LAVA_FLOOR then
            if m.action == ACT_WALKING then
                play_sound_and_spawn_particles(m, SOUND_LAVA, 0)
            end
            return false
        end
    end
end)

RegisterAbility(ABILITY_ID_DRYTRY, {
    name = "DryTry",
    shortName = "DrTr",
    description = "Try your luck! It can give you a god power or punish you very hard.",
    iconTextureName = "drtr",

    cost = 64,
    cooldown = 128,
    curCooldown = 0,

    onUseFunction = onUseDryTry,
    getPermissibilityToUse = function()
        return (AbilitiesData[ABILITY_ID_DRYTRY].jackpotTimer or 0) <= 0
    end,
    getExtraInfo = function()
        if AbilitiesData[ABILITY_ID_DRYTRY] == nil then return { " - " } end

        if AbilitiesData[ABILITY_ID_DRYTRY].stage == 0 then
            return {
                "Result: " .. AbilitiesData[ABILITY_ID_DRYTRY].lastResult,
                "Jackpot chance: 9/729",
                "Win chance: 216/729"
            }
        elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 1 then
            return {
                "Result: " .. AbilitiesData[ABILITY_ID_DRYTRY].lastResult,
                "Jackpot chance: 8/512",
                "Win chance: 168/512",
            }
        elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 2 then
            return {
                "Result: " .. AbilitiesData[ABILITY_ID_DRYTRY].lastResult,
                "Jackpot chance: 6/216",
                "Win chance: 90/216",
            }
        elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 3 then
            return {
                "Result: " .. AbilitiesData[ABILITY_ID_DRYTRY].lastResult,
                "Jackpot chance: 3/27",
                "Win chance: 18/27",
            }
        elseif AbilitiesData[ABILITY_ID_DRYTRY].stage == 4 then
            return {
                "Guaranteed Jackpot"
            }
        end
    end,

    -- кастомные поля
    attempts = 0,
    losesInRow = 0,
    pseudoWinsInRow = 0,
    stage = 0,
    lastResult = 0,
    jackpotTimer = 0,
    healthBeforeJackpot = 0
})
