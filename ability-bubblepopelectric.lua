ABILITY_ID_BUBBLEPOPELECTRIC = 8

ACT_FRAME_REPLAY = allocate_mario_action(ACT_FLAG_CUSTOM_ACTION | ACT_FLAG_MOVING | ACT_FLAG_AIR)

local function onStartRecordingFrames()
    local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]
    ability.frames = {}
    ability.curFrame = 0
    ability.isRecordingFrames = true
    ability.isReplayingFrames = false
end

local function onRecordFrame()
    local m = gMarioStates[0]
    local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]
    ability.frames[#ability.frames + 1] = {
        pos = { x = m.pos.x, y = m.pos.y, z = m.pos.z },
        vel = { x = m.vel.x, y = m.vel.y, z = m.vel.z },
        angle = { x = m.faceAngle.x, y = m.faceAngle.y, z = m.faceAngle.z },
        action = m.action
    }
end

local function onEndRecordingFrames()
    local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]
    if not ability.isRecordingFrames then return end

    onRecordFrame()

    ability.isRecordingFrames = false
    ability.isReplayingFrames = true
    ability.curFrame = 0
end

local function onEndReplayingFrames()
    local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]
    ability.isReplayingFrames = false
    ability.curFrame = 0
    ability.frames = {}
end

local function onAbilityUse()
    local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]
    if ability.isRecordingFrames or ability.isReplayingFrames then
        return
    end
    onStartRecordingFrames()
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 or gPlayerSyncTable[0].Kaisen64 == nil then
        return
    end

    local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]

    if ability.isRecordingFrames or ability.isReplayingFrames then
        ability.curCooldown = ability.curCooldown + 1
    end

    if ability.isRecordingFrames and m.controller.buttonPressed == L_TRIG then
        onEndRecordingFrames()
        return
    end
    if ability.isRecordingFrames and not ability.isReplayingFrames then
        if gPlayerSyncTable[0].Kaisen64.currentEnergy < ability.frameCost then
            onEndRecordingFrames()
            return
        end

        if get_global_timer() % ability.frameRecordTiming == 0 then
            AddEnergy(0, -ability.frameCost)
            onRecordFrame()
        end
    end

    if ability.isReplayingFrames then
        if get_global_timer() % ability.frameReplayTiming == 0 then
            ability.curFrame = ability.curFrame + 1
            if ability.curFrame > #ability.frames then
                onEndReplayingFrames()
                return
            end

            local frame = ability.frames[ability.curFrame]
            m.pos.x = frame.pos.x
            m.pos.y = frame.pos.y
            m.pos.z = frame.pos.z
            m.vel.x = frame.vel.x
            m.vel.y = frame.vel.y
            m.vel.z = frame.vel.z
            m.faceAngle.x = frame.angle.x
            m.faceAngle.y = frame.angle.y
            m.faceAngle.z = frame.angle.z

            m.marioObj.header.gfx.pos.x = m.pos.x
            m.marioObj.header.gfx.pos.y = m.pos.y
            m.marioObj.header.gfx.pos.z = m.pos.z

            set_mario_action(m, frame.action, 0)
        end
    end
end)

RegisterAbility(ABILITY_ID_BUBBLEPOPELECTRIC, {
    name = "BubblePopElectric",
    shortName = "BpEl",
    description = "",
    iconTextureName = "rgtc",

    cost = 64,
    cooldown = 256,
    curCooldown = 0,

    onUseFunction = onAbilityUse,
    getPermissibilityToUse = function()
        local ability = AbilitiesData[ABILITY_ID_BUBBLEPOPELECTRIC]
        return not (ability.isRecordingFrames or ability.isReplayingFrames) and ability.curCooldown == 0
    end,
    getExtraInfo = function() return { " - " } end,

    -- custom fields
    isRecordingFrames = false,
    isReplayingFrames = false,
    frameRecordTiming = 8,
    frameReplayTiming = 1,
    frameCost = 16,
    curFrame = 0,
    frames = {}
})
