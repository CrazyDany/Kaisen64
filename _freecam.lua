local function math_sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

local function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

local FreeCamera = {}
FreeCamera.__index = FreeCamera

local baseDelta = 1 / 30

local moveMultiplier = 1
local turnMultiplier = 1

function FreeCamera.new()
    local self = setmetatable({}, FreeCamera)
    self.enabled = true
    self.pitch = calculate_pitch(gLakituState.pos, gLakituState.focus)
    self.yaw = limit_angle(32772 + calculate_yaw(gLakituState.pos, gLakituState.focus))
    self.fov = 50
    self.moveSpeed = 1 / baseDelta
    self.turnSpeed = 0x100 / baseDelta
    self.MouseLook = false
    return self
end

local LocalPlayer = gMarioStates[0]

local FOV_GAIN = 64
local rad = math.rad
local sqrt = math.sqrt
local tan = math.tan
local delta = 0.03

function FreeCamera:Update(clockTime)
    if not self.enabled then return end
    camera_freeze()
    set_override_fov(self.fov)

    LocalPlayer.freeze = 5

    local controller = LocalPlayer.controller

    local moveX = controller.stickX
    local moveZ = controller.stickY

    local moveY = 0

    if (controller.buttonDown & A_BUTTON) ~= 0 then
        moveY = 64
    elseif (controller.buttonDown & Z_TRIG) ~= 0 then
        moveY = -64
    end

    if moveX ~= 0 or moveZ ~= 0 or moveY ~= 0 then
        local lookX = -sins(self.yaw) * coss(self.pitch)
        local lookY = sins(self.pitch)
        local lookZ = -coss(self.yaw) * coss(self.pitch)

        local rightYaw = self.yaw + 0x4000
        local rightX = sins(rightYaw)
        local rightZ = coss(rightYaw)

        local upX = sins(self.yaw) * sins(self.pitch)
        local upY = coss(self.pitch)
        local upZ = sins(self.pitch) * coss(self.yaw)

        local moveDelta = self.moveSpeed * moveMultiplier * delta
        moveX = moveX * moveDelta
        moveY = moveY * moveDelta
        moveZ = moveZ * moveDelta

        gLakituState.pos.x = gLakituState.pos.x + lookX * moveZ + rightX * moveX + upX * moveY
        gLakituState.pos.y = gLakituState.pos.y + lookY * moveZ + upY * moveY
        gLakituState.pos.z = gLakituState.pos.z + lookZ * moveZ + rightZ * moveX + upZ * moveY
        gLakituState.focus.x = gLakituState.focus.x + lookX * moveZ + rightX * moveX + upX * moveY
        gLakituState.focus.y = gLakituState.focus.y + lookY * moveZ + upY * moveY
        gLakituState.focus.z = gLakituState.focus.z + lookZ * moveZ + rightZ * moveX + upZ * moveY
    end

    local turnX = 0
    local turnY = 0

    local turnSpeed = self.turnSpeed * turnMultiplier

    if (controller.buttonPressed & B_BUTTON) ~= 0 then
        self.MouseLook = not self.MouseLook
        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, LocalPlayer.marioObj.header.gfx.cameraToObject)
    end

    if self.MouseLook then
        djui_hud_set_mouse_locked(true)
        turnX = -math.floor(djui_hud_get_raw_mouse_y() * turnSpeed * delta)
        turnY = -math.floor(djui_hud_get_raw_mouse_x() * turnSpeed * delta)
    else
        djui_hud_set_mouse_locked(false)
    end

    local fovAdd = 0

    if (controller.buttonDown & L_TRIG) ~= 0 then
        fovAdd = 1
    elseif (controller.buttonDown & R_TRIG) ~= 0 then
        fovAdd = -1
    end

    local zoomFactor = sqrt(tan(rad(70 / 2)) / tan(rad(self.fov / 2)))
    self.fov = clampf(self.fov + fovAdd * FOV_GAIN * (delta / zoomFactor), 1, 120)

    if (controller.buttonDown & D_CBUTTONS) ~= 0 then
        turnX = -math.floor(turnSpeed * 4 * delta * 0.5)
    elseif (controller.buttonDown & U_CBUTTONS) ~= 0 then
        turnX = math.floor(turnSpeed * 4 * delta * 0.5)
    end

    if (controller.buttonDown & L_CBUTTONS) ~= 0 then
        turnY = turnSpeed * 4 * delta
    elseif (controller.buttonDown & R_CBUTTONS) ~= 0 then
        turnY = -turnSpeed * 4 * delta
    end

    if turnX ~= 0 or turnY ~= 0 then
        self.pitch = clamp(self.pitch + turnX, -0x3F4A, 0x3F4A)
        local newYaw = self.yaw + turnY
        self.yaw = math_sign(newYaw) * (math.abs(newYaw) % 0x16000)
        local focusDist = gLakituState.focusDistance
        local cossPitch = (math.abs(coss(self.pitch)) < 1e-16 and 0 or coss(self.pitch))
        gLakituState.focus.x = gLakituState.pos.x - focusDist * sins(self.yaw) * cossPitch
        gLakituState.focus.y = gLakituState.pos.y + focusDist * sins(self.pitch)
        gLakituState.focus.z = gLakituState.pos.z - focusDist * coss(self.yaw) * cossPitch
    end

    gLakituState.yaw = self.yaw
    LocalPlayer.area.camera.yaw = self.yaw
    vec3f_copy(gLakituState.curPos, gLakituState.pos)
    vec3f_copy(gLakituState.curFocus, gLakituState.focus)
end

function FreeCamera:Destroy()
    self.enabled = false
    set_override_fov(0)
    djui_hud_set_mouse_locked(false)
end

local freeCamObj = nil

local function freeCamUpdate(m)
    if m.playerIndex ~= 0 then return end
    if freeCamObj then freeCamObj:Update() end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, freeCamUpdate)

local function freeCamToggle()
    if not freeCamObj then
        camera_freeze()
        hud_hide()
        freeCamObj = FreeCamera.new()
    else
        camera_unfreeze()
        hud_show()
        freeCamObj:Destroy()
        freeCamObj = nil
    end
    return true
end

local function isFreeCamActive()
    return freeCamObj ~= nil
end

function enableFreeCam()
    if not isFreeCamActive() then freeCamToggle() end
end

function disableFreeCam()
    if isFreeCamActive() then freeCamToggle() end
end
