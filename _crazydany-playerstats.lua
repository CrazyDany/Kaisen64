gPlayerSyncTable[0].CrazyDanyBetterStats = {}

gPlayerSyncTable[0].CrazyDanyBetterStats.groundSpeed = 0.75
gPlayerSyncTable[0].CrazyDanyBetterStats.airSpeed = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.extraGravity = 0.0
gPlayerSyncTable[0].CrazyDanyBetterStats.swimingSpeed = 1.0
gPlayerSyncTable[0].CrazyDanyBetterStats.jumpStrength = 1.25
gPlayerSyncTable[0].CrazyDanyBetterStats.damageMult = 1.0

hook_event(HOOK_BEFORE_PHYS_STEP,
    --- @param m MarioState
    --- @param s integer
    function(m, s)
        if m.playerIndex ~= 0 then return end

        if s == STEP_TYPE_GROUND then
            -- djui_chat_message_create("Ground step")
            local groundSpeed = gPlayerSyncTable[0].CrazyDanyBetterStats.groundSpeed or 1
            m.vel.x = m.vel.x * groundSpeed
            m.vel.z = m.vel.z * groundSpeed
        elseif s == STEP_TYPE_AIR then
            -- djui_chat_message_create("Air step")
            local airSpeed = gPlayerSyncTable[0].CrazyDanyBetterStats.airSpeed or 1
            m.vel.x = m.vel.x * airSpeed
            m.vel.z = m.vel.z * airSpeed
        elseif s == STEP_TYPE_WATER then
            -- djui_chat_message_create("Water step")
            local swimingSpeed = gPlayerSyncTable[0].CrazyDanyBetterStats.swimingSpeed or 1
            m.vel.x = m.vel.x * swimingSpeed
            m.vel.z = m.vel.z * swimingSpeed
        end
    end
)

local luigicooldown = false

hook_event(HOOK_MARIO_UPDATE,
    --- @param m MarioState
    function(m)
        if m.playerIndex ~= 0 then return end

        local jumpStrength = gPlayerSyncTable[0].CrazyDanyBetterStats.jumpStrength or 1

        local actionisold

        if m.actionTimer > 0 then
            actionisold = true
        else
            actionisold = false
        end


        if luigicooldown == true then
            if CheckIfStationary() == true or CheckIfGroundMoving() == true then
                luigicooldown = false
            end
        end

        if (CheckIfStationaryBefore() or CheckIfGroundMovingBeforeBefore()) and actionisold == false and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            if luigicooldown == false then
                m.vel.y = m.vel.y * jumpStrength
                luigicooldown = true
            end
        end
    end
)
