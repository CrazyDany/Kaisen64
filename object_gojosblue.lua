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


local function obj_override_behavior_script(o, script)
    if obj_has_behavior_id(o, id_bhvGojosBlue) ~= 0 then return end

    local closest_blue = obj_get_nearest_object_with_behavior_id(o, id_bhvGojosBlue)

    if closest_blue == nil then return end

    local dist = dist_between_objects(o, closest_blue)
    local blue_raidus = closest_blue.oAttractRadius or 0
    local blue_strength = closest_blue.oAttractStrength or 0
    local blue_lapse_radius = closest_blue.oLapseRadius or 0

    if dist <= blue_raidus then
        local dx = closest_blue.oPosX - o.oPosX
        local dy = closest_blue.oPosY - o.oPosY
        local dz = closest_blue.oPosZ - o.oPosZ

        local dirX = dx / dist
        local dirY = dy / dist
        local dirZ = dz / dist

        local strength = blue_strength * (1 - dist / blue_raidus)

        obj_move_xyz(o, dirX * strength, dirY * strength, dirZ * strength)

        -- if dist <= blue_lapse_radius then
        --     -- m.health = m.health - 1
        --     if closest_blue.oForwardVel > closest_blue.oForwardVelAfterHit then
        --         closest_blue.oForwardVel = math.floor(math.lerp(closest_blue.oForwardVel,
        --         closest_blue.oForwardVelAfterHit, 0.05))
        --         closest_blue.oTimer = closest_blue.oTimer + 1
        --     end
        -- end
    end
end

hook_event(HOOK_UPDATE, function()
    local sObjList = {}
    -- Inserts all object lists automatically
    for k, v in pairs(_G) do
        if not k:find("OBJ_LIST_") then goto continue end
        table.insert(sObjList, v)
        ::continue::
    end
    for _, objList in pairs(sObjList) do
        local obj = obj_get_first(objList)
        while obj ~= nil do
            obj_override_behavior_script(obj, get_behavior_from_id(id_bhvGoomba))
            obj = obj_get_next(obj)
        end
    end
end)

id_bhvGojosBlue = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_GojosBlue_init, bhv_GojosBlue_loop)
