define_custom_obj_fields(
    {
        oMarioParentGlobalIndex = "f32",
        oAttractRadius = "f32",
        oAttractStrength = "f32",
        oLapseRadius = "f32",
        oLapseStrength = "f32",
        oForwardVelAfterHit = "f32",
        oLifetime = "f32"
    }
)

function bhv_GojosBlue_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(obj)

    network_init_object(obj, true, {
        "oMarioParentGlobalIndex",
        "oAttractRadius",
        "oAttractStrength",
        "oLapseRadius",
        "oLapseStrength",
        "oForwardVelAfterHit"
    })
end

function bhv_GojosBlue_loop(obj)
    cur_obj_move_xz_using_fvel_and_yaw()
    local m = gMarioStates[0]

    if (dist_between_objects(obj, m.marioObj) <= obj.oAttractRadius) and (network_global_index_from_local(0) ~= obj.oMarioParentGlobalIndex) then
        gPlayerSyncTable[0].Kaisen64.isAttracting = true
        gPlayerSyncTable[0].Kaisen64.attractingPosX = obj.oPosX
        gPlayerSyncTable[0].Kaisen64.attractingPosY = obj.oPosY
        gPlayerSyncTable[0].Kaisen64.attractingPosZ = obj.oPosZ
        gPlayerSyncTable[0].Kaisen64.attractingStrength = obj.oAttractStrength
        gPlayerSyncTable[0].Kaisen64.attractRadius = obj.oAttractRadius

        if (dist_between_objects(obj, m.marioObj) <= obj.oLapseRadius) then
            -- m.health = m.health - 1
            if obj.oForwardVel > obj.oForwardVelAfterHit then
                obj.oForwardVel = math.floor(math.lerp(obj.oForwardVel, obj.oForwardVelAfterHit, 0.05))
                obj.oTimer = obj.oTimer + 1
            end
        end
    else
        gPlayerSyncTable[0].Kaisen64.isAttracting = false
    end

    if obj.oTimer >= obj.oLifetime then
        obj_mark_for_deletion(obj)
        gPlayerSyncTable[0].Kaisen64.isAttracting = false
    end
end

hook_event(HOOK_BEFORE_PHYS_STEP,
    function(m, s)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end
        local k = gPlayerSyncTable[m.playerIndex].Kaisen64
        if k.isAttracting ~= true then return end

        local dx = k.attractingPosX - m.pos.x
        local dy = k.attractingPosY - m.pos.y
        local dz = k.attractingPosZ - m.pos.z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
        local radius = k.attractRadius

        if dist < 0.01 or dist >= radius then return end

        local dirX = dx / dist
        local dirY = dy / dist
        local dirZ = dz / dist

        local strength = k.attractingStrength * (1 - dist / radius)

        m.vel.x = m.vel.x + dirX * strength
        m.vel.y = m.vel.y + dirY * strength
        m.vel.z = m.vel.z + dirZ * strength
    end
)

id_bhvGojosBlue = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_GojosBlue_init, bhv_GojosBlue_loop)

hook_event(HOOK_MARIO_UPDATE,
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end
        local k = gPlayerSyncTable[m.playerIndex].Kaisen64
        if not k.isAttracting then return end

        if CheckIfStationary(m) then
            set_mario_action(m, ACT_FREEFALL, 0)
        end
    end
)

id_bhvGojosBlue = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_GojosBlue_init, bhv_GojosBlue_loop)
