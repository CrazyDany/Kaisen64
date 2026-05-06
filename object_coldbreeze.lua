function bhv_coldbreeze_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_scale(10.0)

    -- physics
    obj.oWallHitboxRadius = 40.00
    obj.oGravity          = 0
    obj.oBounciness       = 0
    obj.oDragStrength     = 0.00
    obj.oFriction         = 0
    obj.oBuoyancy         = 0

    obj.oForwardVel       = 1.5

    -- hitbox
    obj.hitboxRadius      = 300
    obj.hitboxHeight      = 100

    network_init_object(obj, true, nil)
end

function bhv_coldbreeze_loop(obj)
    obj.oPosX = obj.oPosX + sins(obj.oFaceAngleYaw or 0) * (obj.oForwardVel or 0)
    obj.oPosZ = obj.oPosZ + coss(obj.oFaceAngleYaw or 0) * (obj.oForwardVel or 0)

    local m = gMarioStates[0]

    if (m.marioObj == obj.parentObj) then
        return
    end

    local dist_xOz = math.sqrt(((obj.oPosX - m.pos.x) ^ 2) + ((obj.oPosZ - m.pos.z) ^ 2))
    local dist_y = math.abs(obj.oPosY - m.pos.y)

    -- Столкнулся с локальным Марио
    if dist_xOz <= obj.hitboxRadius and dist_y <= obj.hitboxHeight then
        FreesingEffect:Apply(m, 3)
    end

    obj.oTimer = obj.oTimer - 1

    if obj.oTimer <= 0 then
        obj_mark_for_deletion(obj)
        obj.oTimer = 0
    end
end

id_bhvColdBreeze = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_coldbreeze_init, bhv_coldbreeze_loop)
