K64_SKINS_TABLE = {
    [0] = {
        name = "Стандарт",
        model = smlua_model_util_get_id("devil_bully_geo")
    },

    [1] = {
        name = "Вечный Булли",
        model = smlua_model_util_get_id("devil_bully_skin1_geo")
    },

    [2] = {
        name = "Каичи",
        model = smlua_model_util_get_id("devil_bully_skin2_geo")
    },

    [3] = {
        name = "Буллгоат",
        model = smlua_model_util_get_id("devil_bully_skin3_geo")
    },

    [4] = {
        name = "Бибик",
        model = smlua_model_util_get_id("devil_bully_skin4_geo")
    },

    [5] = {
        name = "Твердый Булли",
        model = smlua_model_util_get_id("devil_bully_skin5_geo")
    },
}

local k64_defaultSkin = 0

local function k64_getPlayerSkinIndex(playerIndex)
    if gPlayerSyncTable[playerIndex].k64_skin == nil then
        if playerIndex == 0 then
            gPlayerSyncTable[0].k64_skin = 0
        end
    end

    return gPlayerSyncTable[playerIndex].k64_skin or k64_defaultSkin
end

hook_event(HOOK_MARIO_UPDATE,
    function(m)
        local playerModel = K64_SKINS_TABLE[k64_getPlayerSkinIndex(m.playerIndex)]
        obj_set_model_extended(m.marioObj, playerModel.model)
    end
)

hook_chat_command("k64-skin", "Set skin",
    function(msg)
        local skinId = 0

        if tonumber(msg) == nil then
            for i, v in pairs(K64_SKINS_TABLE) do
                if v.name == msg then
                    skinId = i
                    break
                end
            end
        else
            skinId = tonumber(msg)
        end

        djui_chat_message_create("Skin set to " .. K64_SKINS_TABLE[skinId].name)

        gPlayerSyncTable[0].k64_skin = skinId

        return true
    end
)
