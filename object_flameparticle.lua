function bhv_FlameParticle_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_scale(10.0)
    obj_set_billboard(obj)

    network_init_object(obj, true, nil)
end

function bhv_FlameParticle_loop(obj)
    obj.oPosX = obj.parentObj.oPosX
    obj.oPosY = obj.parentObj.oPosY
    obj.oPosZ = obj.parentObj.oPosZ

    obj.oTimer = obj.oTimer + 1

    if obj.oTimer > 256 then
        obj_mark_for_deletion(obj)
        obj.oTimer = 0
    end

    object_step_without_floor_orient()
end

id_bhvFlameParticle = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_FlameParticle_init, bhv_FlameParticle_loop)