E_MODEL_AURA = smlua_model_util_get_id("aura_geo")

function bhv_Aura_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_scale(3.0)
    -- obj_set_billboard(obj)

    network_init_object(obj, true, { "oMarioParentGlobalIndex" })
end

--- comment
--- @param obj Object
function bhv_Aura_loop(obj)
    local dx = 0
    local dy = 0
    local dz = 0

    local parentMario = gMarioStates[network_local_index_from_global(obj.oMarioParentGlobalIndex)]

    obj.oPosX = parentMario.pos.x + dx
    obj.oPosY = parentMario.pos.y + dy + 128
    obj.oPosZ = parentMario.pos.z + dz

    obj.oFaceAnglePitch = 16900
    obj.oFaceAngleYaw = gLakituState.yaw
    -- djui_chat_message_create("oFaceAnglePitch: " .. obj.oFaceAnglePitch)
end

id_bhvAura = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_Aura_init, bhv_Aura_loop)
