ABILITY_ID_SMALLTALL = 6

local STTimer = 0
local scale = 0

function onUseSmallTall()
    STTimer = 4096
    scale = 3.0
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    if STTimer > 0 then
        obj_scale(m.marioObj, scale)
        STTimer = STTimer - 1
        djui_chat_message_create(tostring(STTimer))
        if scale == 3.0 then
            if m.action == ACT_WALKING then
                mario_set_forward_vel(m, 15)
            end
        end
    end
end)

RegisterAbility(ABILITY_ID_SMALLTALL, {
    name = "SmallTall",
    shortName = "SmTl",
    description = "Grow up in size for destructibility or shrink down in size for slickness.",
    iconTextureName = "rgtc",

    cost = 128,
    cooldown = 512,
    curCooldown = 0,

    onUseFunction = onUseSmallTall,
    getPermissibilityToUse = function()
        return true
    end,
    getExtraInfo = function()
        return { " - " }
    end
})
