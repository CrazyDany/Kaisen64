gPlayerSyncTable[0].CrazyDanyBetterStats = {}

gPlayerSyncTable[0].CrazyDanyBetterStats.groundSpeed = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.airSpeed = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.extraGravity = 0.0
gPlayerSyncTable[0].CrazyDanyBetterStats.swimingSpeed = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.jumpStrength = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.damageMult = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.knockbackStrength = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.lavaResist = false

hook_event(HOOK_BEFORE_PHYS_STEP,
    --- @param m MarioState
    --- @param s integer
    function(m, s)
        if gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats == nil then return end

        if ChecIfHit(m) == true then
            local knockbackStrength = gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats.knockbackStrength or 1
            m.vel.x = m.vel.x * knockbackStrength
            m.vel.z = m.vel.z * knockbackStrength
            m.vel.y = m.vel.y * knockbackStrength
            return
        end

        if s == STEP_TYPE_GROUND then
            -- djui_chat_message_create("Ground step")
            local groundSpeed = gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats.groundSpeed or 1
            m.vel.x = m.vel.x * groundSpeed
            m.vel.z = m.vel.z * groundSpeed
        elseif s == STEP_TYPE_AIR then
            -- djui_chat_message_create("Air step")
            local airSpeed = gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats.airSpeed or 1
            m.vel.x = m.vel.x * airSpeed
            m.vel.z = m.vel.z * airSpeed
        elseif s == STEP_TYPE_WATER then
            -- djui_chat_message_create("Water step")
            local swimingSpeed = gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats.swimingSpeed or 1
            m.vel.x = m.vel.x * swimingSpeed
            m.vel.z = m.vel.z * swimingSpeed
        end
    end
)

local luigicooldown = false

hook_event(HOOK_MARIO_UPDATE,
    --- @param m MarioState
    function(m)
        if gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats == nil then return end

        local jumpStrength = gPlayerSyncTable[0].CrazyDanyBetterStats.jumpStrength or 1

        local actionisold

        if m.actionTimer > 0 then
            actionisold = true
        else
            actionisold = false
        end

        if luigicooldown == true then
            if CheckIfStationary(m) == true or CheckIfGroundMoving(m) == true then
                luigicooldown = false
            end
        end

        if (CheckIfStationaryBefore(m) or CheckIfGroundMovingBeforeBefore(m)) and actionisold == false and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            if luigicooldown == false then
                m.vel.y = m.vel.y * jumpStrength
                luigicooldown = true
            end
        end

        local extraGravity = gPlayerSyncTable[0].CrazyDanyBetterStats.extraGravity or 0
        if (ACT_FLAG_AIR and (m.vel.y > 0)) ~= 0 then
            m.vel.y = m.vel.y - extraGravity
        end
    end
)

hook_event(HOOK_ALLOW_HAZARD_SURFACE, function(m, h)
    if gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats == nil then return end
    if (gPlayerSyncTable[m.playerIndex].CrazyDanyBetterStats.lavaResist or false) == true then
        if h == HAZARD_TYPE_LAVA_FLOOR then
            return false
        end
    end
end)

hook_chat_command("groundspeed", "Set ground speed", function(msg)
    if not IsDevModActivated() then
        djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
        return false
    end
    if gPlayerSyncTable[0].CrazyDanyBetterStats == nil then
        gPlayerSyncTable[0].CrazyDanyBetterStats = {}
    end

    gPlayerSyncTable[0].CrazyDanyBetterStats.groundSpeed = tonumber(msg)
    return true
end)

hook_chat_command("airspeed", "Set air speed", function(msg)
    if not IsDevModActivated() then
        djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
        return false
    end
    if gPlayerSyncTable[0].CrazyDanyBetterStats == nil then
        gPlayerSyncTable[0].CrazyDanyBetterStats = {}
    end

    gPlayerSyncTable[0].CrazyDanyBetterStats.airSpeed = tonumber(msg)
    return true
end)

hook_chat_command("swimingspeed", "Set swimming speed", function(msg)
    if not IsDevModActivated() then
        djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
        return false
    end
    if gPlayerSyncTable[0].CrazyDanyBetterStats == nil then
        gPlayerSyncTable[0].CrazyDanyBetterStats = {}
    end

    gPlayerSyncTable[0].CrazyDanyBetterStats.swimingSpeed = tonumber(msg)
    return true
end)

hook_chat_command("jumpstrength", "Set jump strength", function(msg)
    if not IsDevModActivated() then
        djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
        return false
    end
    if gPlayerSyncTable[0].CrazyDanyBetterStats == nil then
        gPlayerSyncTable[0].CrazyDanyBetterStats = {}
    end

    gPlayerSyncTable[0].CrazyDanyBetterStats.jumpStrength = tonumber(msg)
    return true
end)

hook_chat_command("extragravity", "Set extra gravity", function(msg)
    if not IsDevModActivated() then
        djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
        return false
    end
    if gPlayerSyncTable[0].CrazyDanyBetterStats == nil then
        gPlayerSyncTable[0].CrazyDanyBetterStats = {}
    end

    gPlayerSyncTable[0].CrazyDanyBetterStats.extraGravity = tonumber(msg)
    return true
end)

hook_chat_command("lavaresist", "Set lava resist", function(msg)
    if not IsDevModActivated() then
        djui_chat_message_create("Права разработчка отсутствуют, выполнение команды не возможно.")
        return false
    end
    if gPlayerSyncTable[0].CrazyDanyBetterStats == nil then
        gPlayerSyncTable[0].CrazyDanyBetterStats = {}
    end

    gPlayerSyncTable[0].CrazyDanyBetterStats.lavaResist = not gPlayerSyncTable[0].CrazyDanyBetterStats.lavaResist
    return true
end)
