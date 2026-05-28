E_MODEL_GOJOSRED = smlua_model_util_get_id("red_sphere_geo")

define_custom_obj_fields(
    {
        oRepelRadius = "f32",
        oRepelStrength = "f32",
        oStrongRepelRadius = "f32",
        oStrongRepelStrength = "f32",
    }
)

function bhv_GojosRed_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(obj)

    network_init_object(obj, true, {
        "oMarioParentGlobalIndex",
        "oRepelRadius",
        "oRepelStrength",
        "oStrongRepelRadius",
        "oStrongRepelStrength",
        "oLifetime"
    })
end

function bhv_GojosRed_loop(obj)
    cur_obj_move_xz_using_fvel_and_yaw()
    local m = gMarioStates[0]

    local distToMario = dist_between_objects(obj, m.marioObj)
    local isInside = (distToMario <= obj.oRepelRadius) and
        (network_global_index_from_local(0) ~= obj.oMarioParentGlobalIndex)

    if isInside then
        gPlayerSyncTable[0].Kaisen64.isRepelling = true
        gPlayerSyncTable[0].Kaisen64.repelPosX = obj.oPosX
        gPlayerSyncTable[0].Kaisen64.repelPosY = obj.oPosY
        gPlayerSyncTable[0].Kaisen64.repelPosZ = obj.oPosZ
        gPlayerSyncTable[0].Kaisen64.repelStrength = obj.oRepelStrength
        gPlayerSyncTable[0].Kaisen64.strongRepelRadius = obj.oStrongRepelRadius
        gPlayerSyncTable[0].Kaisen64.strongRepelStrength = obj.oStrongRepelStrength
        gPlayerSyncTable[0].Kaisen64.distToRed = distToMario
    else
        gPlayerSyncTable[0].Kaisen64.isRepelling = false
    end

    if obj.oTimer >= obj.oLifetime then
        obj_mark_for_deletion(obj)
        gPlayerSyncTable[0].Kaisen64.isRepelling = false
    end
end

hook_event(HOOK_BEFORE_PHYS_STEP,
    function(m, s)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end
        local k = gPlayerSyncTable[m.playerIndex].Kaisen64
        if not k.isRepelling then return end

        -- Вектор от центра сферы К МАРИО (наружу)
        local dx = m.pos.x - k.repelPosX
        local dy = m.pos.y - k.repelPosY
        local dz = m.pos.z - k.repelPosZ
        local dist = k.distToRed or math.sqrt(dx * dx + dy * dy + dz * dz)
        if dist < 0.01 then return end

        local dirX = dx / dist
        local dirY = dy / dist
        local dirZ = dz / dist

        -- Постоянное отталкивание (не зависит от расстояния)
        m.vel.x = m.vel.x + dirX * k.repelStrength
        m.vel.y = m.vel.y + dirY * k.repelStrength
        m.vel.z = m.vel.z + dirZ * k.repelStrength

        -- Если слишком близко — дополнительный сильный импульс
        if dist <= k.strongRepelRadius then
            m.vel.x = m.vel.x + dirX * k.strongRepelStrength
            m.vel.y = m.vel.y + dirY * k.strongRepelStrength
            m.vel.z = m.vel.z + dirZ * k.strongRepelStrength
        end
    end
)

hook_event(HOOK_MARIO_UPDATE,
    function(m)
        if gPlayerSyncTable[m.playerIndex].Kaisen64 == nil then return end
        local k = gPlayerSyncTable[m.playerIndex].Kaisen64
        if not k.isRepelling then return end

        if (k.distToRed <= k.strongRepelRadius) then
            set_mario_action(m, ACT_HARD_BACKWARD_AIR_KB, 0)
        end

        if CheckIfStationary(m) then
            set_mario_action(m, ACT_FREEFALL, 0)
        end
    end
)

-- Отталкивание других объектов
local function obj_repel_from_red(obj)
    if obj_has_behavior_id(obj, id_bhvGojosRed) ~= 0 then return end


    local closest_red = obj_get_nearest_object_with_behavior_id(obj, id_bhvGojosRed)
    if closest_red == nil then return end

    -- -- purple nuke
    -- if obj_has_behavior_id(obj, id_bhvGojosBlue) ~= 0 then
    --     obj_mark_for_deletion(obj)
    --     obj_mark_for_deletion(closest_red)
    -- end

    local dist = dist_between_objects(obj, closest_red)
    local radius = closest_red.oRepelRadius or 0
    if dist > radius then return end

    local dx = obj.oPosX - closest_red.oPosX
    local dy = obj.oPosY - closest_red.oPosY
    local dz = obj.oPosZ - closest_red.oPosZ
    if dist < 0.01 then return end
    local dirX = dx / dist
    local dirY = dy / dist
    local dirZ = dz / dist

    -- Постоянное отталкивание
    local strength = closest_red.oRepelStrength or 0
    obj_move_xyz(obj, dirX * strength, dirY * strength, dirZ * strength)

    -- Сильное отталкивание в ближней зоне
    local strongRadius = closest_red.oStrongRepelRadius or 0
    if dist <= strongRadius then
        local strongStrength = closest_red.oStrongRepelStrength or 0
        obj_move_xyz(obj, dirX * strongStrength, dirY * strongStrength, dirZ * strongStrength)
    end
end

hook_event(HOOK_UPDATE, function()
    local objLists = {
        OBJ_LIST_GENACTOR,
        OBJ_LIST_PUSHABLE,
        OBJ_LIST_SURFACE,
        OBJ_LIST_DEFAULT,
        OBJ_LIST_LEVEL
    }
    for _, list in ipairs(objLists) do
        local obj = obj_get_first(list)
        while obj ~= nil do
            obj_repel_from_red(obj)
            obj = obj_get_next(obj)
        end
    end
end)

id_bhvGojosRed = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_GojosRed_init, bhv_GojosRed_loop)
