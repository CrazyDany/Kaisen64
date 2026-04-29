ABILITY_ID_BUBBLEPOPELECTRIC = 8

ACT_FRAME_REPLAY = allocate_mario_action(ACT_FLAG_CUSTOM_ACTION | ACT_FLAG_MOVING | ACT_FLAG_AIR)

local function onStartRecordingFrames()
    local m = gMarioStates[0]

    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].isRecordingFrames = true
end

local function onRecordFrame()
    local m = gMarioStates[0]

    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].frames[#AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].frames + 1] = {
        pos = {
            x = m.pos.x,
            y = m.pos.y,
            z = m.pos.z
        },

        vel = {
            x = m.vel.x,
            y = m.vel.y,
            z = m.vel.z
        },

        angle = {
            x = m.faceAngle.x,
            y = m.faceAngle.y,
            z = m.faceAngle.z
        },

        action = m.action
    }
    djui_chat_message_create("Frame recorded " .. #AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].frames)
end

local function onEndRecordingFrames()
    djui_chat_message_create("Start replaying frames...")
    -- Adding final frame
    onRecordFrame()

    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].curFrame = 0
    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].isRecordingFrames = false
    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].isReplayingFrames = true
end


local function onEndReplayingFrames()
    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].isReplayingFrames = false
    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].curFrame = 0
    AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].frames = {}
end

hook_event(HOOK_MARIO_UPDATE,
    function(m)
        if m.playerIndex ~= 0 or gPlayerSyncTable[0].Kaisen64 == nil then
            return
        end

        local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]

        if ability.isRecordingFrames and not ability.isReplayingFrames then
            ability.curCooldown = ability.curCooldown + 1
            if (m.controller.buttonReleased == L_TRIG)
                or (gPlayerSyncTable[0].Kaisen64.currentEnergy <= ability.frameCost)
                or (ability.curCooldown == 0)
            then
                onEndRecordingFrames()
                return
            end

            if get_global_timer() % ability.frameRecordTiming == 0 then
                AddEnergy(0, -ability.frameCost)
                onRecordFrame()
            end
        end

        if ability.isReplayingFrames then
            -- set_mario_action(T, 0)
            ability.curCooldown = ability.curCooldown + 1

            if get_global_timer() % ability.frameReplayTiming == 0 then
                djui_chat_message_create("Replaying frame " .. ability.curFrame + 1)
                ability.curFrame = ability.curFrame + 1

                m.pos.x = ability.frames[ability.curFrame].pos.x
                m.pos.y = ability.frames[ability.curFrame].pos.y
                m.pos.z = ability.frames[ability.curFrame].pos.z

                m.vel.x = ability.frames[ability.curFrame].vel.x
                m.vel.y = ability.frames[ability.curFrame].vel.y
                m.vel.z = ability.frames[ability.curFrame].vel.z

                m.faceAngle.x = ability.frames[ability.curFrame].angle.x
                m.faceAngle.y = ability.frames[ability.curFrame].angle.y
                m.faceAngle.z = ability.frames[ability.curFrame].angle.z

                m.marioObj.header.gfx.pos.x = m.pos.x
                m.marioObj.header.gfx.pos.y = m.pos.y
                m.marioObj.header.gfx.pos.z = m.pos.z

                set_mario_action(m, ability.frames[ability.curFrame].action, 0)

                if ability.curFrame == #ability.frames then
                    ability.isReplayingFrames = false
                    onEndReplayingFrames()
                end
            end
        end
    end
)

RegisterAbility(ABILITY_ID_BUBBLEPOPELECTRIC, {
    name = "BubblePopElectric",
    shortName = "BpEl",
    description = "Ability placeholder for modders",
    iconTextureName = "rgtc",

    cost = 64,
    cooldown = 256,
    curCooldown = 0,

    onUseFunction = onStartRecordingFrames,
    getPermissibilityToUse = function()
        return AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].isRecordingFrames == false
            and AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC].isReplayingFrames == false
    end,
    getExtraInfo = function()
        return { " - " }
    end,

    -- custom fields
    isRecordingFrames = false,
    isReplayingFrames = false,
    frameRecordTiming = 8,
    frameReplayTiming = 1,
    frameCost = 16,
    curFrame = 0,
    frames = {}
})
