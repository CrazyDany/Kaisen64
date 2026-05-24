function bhv_firesphere_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_scale(3.0)
    obj_set_billboard(obj)

    -- physics
    obj.oWallHitboxRadius = 40.00
    obj.oGravity          = 0
    obj.oBounciness       = 0
    obj.oDragStrength     = 0.00
    obj.oFriction         = 0
    obj.oBuoyancy         = 0

    obj.oForwardVel       = 2

    -- hitbox
    obj.hitboxRadius      = 100
    obj.hitboxHeight      = 100

    network_init_object(obj, true, { "oMarioParentGlobalIndex" })
end

--- comment
--- @param obj Object
function bhv_firesphere_loop(obj)
    local t = obj.oTimer * 1.5

    local R_base = 300
    local R_amp = 0
    local R_freq = 0.075
    local R = R_base + R_amp * math.sin(R_freq * t)

    -- азимут
    local gamma_speed = 0.02
    local gamma = gamma_speed * t

    -- наклон
    local beta_speed = 0.015
    local beta = beta_speed * t

    -- кгловая скорость
    local phi_speed = 0.24
    local phi = phi_speed * t

    -- нормаль к сечению
    local nx = math.sin(beta) * math.cos(gamma)
    local ny = math.cos(beta)
    local nz = math.sin(beta) * math.sin(gamma)

    local ux = 0 * ny - 1 * nz
    local uy = 1 * nz - 0 * nx
    local uz = 0 * nx - 1 * ny
    local len_u = math.sqrt(ux * ux + uy * uy + uz * uz)
    if len_u < 0.001 then
        ux = 0 * nz - 1 * ny
        uy = 1 * nx - 0 * nz
        uz = 0 * ny - 1 * nx
        len_u = math.sqrt(ux * ux + uy * uy + uz * uz)
    end
    ux = ux / len_u
    uy = uy / len_u
    uz = uz / len_u

    local vx = ny * uz - nz * uy
    local vy = nz * ux - nx * uz
    local vz = nx * uy - ny * ux

    local dx = R * (math.cos(phi) * ux + math.sin(phi) * vx)
    local dy = R * (math.cos(phi) * uy + math.sin(phi) * vy)
    local dz = R * (math.cos(phi) * uz + math.sin(phi) * vz)

    local parentMario = gMarioStates[network_local_index_from_global(obj.oMarioParentGlobalIndex)]

    obj.oPosX = parentMario.pos.x + dx
    obj.oPosY = parentMario.pos.y + dy
    obj.oPosZ = parentMario.pos.z + dz

    if obj.oTimer >= 512 then
        obj_mark_for_deletion(obj)
    end

    -- checking collsion with mario
    local m = gMarioStates[0]

    if obj_check_hitbox_overlap(m.marioObj, obj) and (network_global_index_from_local(0) ~= obj.oMarioParentGlobalIndex) and (m.invincTimer <= 0) then
        hurt_and_set_mario_action(m, ACT_AIR_HIT_WALL, 0, 1)
        m.invincTimer = m.invincTimer + 16
        BurningEffect:Apply(m, 64)
        obj_mark_for_deletion(obj)
    end
end

id_bhvFireSphere = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bhv_firesphere_init, bhv_firesphere_loop)
