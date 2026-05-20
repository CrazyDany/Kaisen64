hook_event(HOOK_ON_OBJECT_LOAD, function(o)
    if obj_has_behavior_id(o, id_bhvMrIBlueCoin) ~= 0 then
        obj_mark_for_deletion(o)
    end
end)