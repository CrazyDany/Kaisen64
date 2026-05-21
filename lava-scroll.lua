local UvScroll = require("/lib/uv-scroll")

local function uv_scroll_right(input_vtx, original_uv, current_uv)
    local speed = 5

    current_uv[1] = current_uv[1] + speed
end

local function uv_scroll_down(input_vtx, original_uv, current_uv)
    local speed = 100

    current_uv[2] = current_uv[2] - speed
end

hook_event(HOOK_ON_SYNC_VALID, function()
    if gNetworkPlayers[0].currLevelNum == LEVEL_ARENA then
        UvScroll.hook_scrolling_function('arena_dl_Cube_001_mesh_layer_1_tri_0', uv_scroll_right)
        UvScroll.hook_scrolling_function('arena_dl_Circle_002_mesh_layer_1_tri_0', uv_scroll_down)
    end
end)