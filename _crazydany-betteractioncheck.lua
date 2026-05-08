StationaryActions = {
    ACT_IDLE,
    ACT_START_SLEEPING,
    ACT_SLEEPING,
    ACT_WAKING_UP,
    ACT_PANTING,
    ACT_HOLD_IDLE,
    ACT_HOLD_HEAVY_IDLE,
    ACT_STANDING_AGAINST_WALL,
    ACT_COUGHING,
    ACT_SHIVERING,
    ACT_IN_QUICKSAND,
    ACT_CROUCHING,
    ACT_START_CROUCHING,
    ACT_STOP_CROUCHING,
    ACT_START_CRAWLING,
    ACT_STOP_CRAWLING,
    ACT_SLIDE_KICK_SLIDE_STOP,
    ACT_BACKFLIP_LAND_STOP,
    ACT_JUMP_LAND_STOP,
    ACT_DOUBLE_JUMP_LAND_STOP,
    ACT_TRIPLE_JUMP_LAND_STOP,
    ACT_FREEFALL_LAND_STOP,
    ACT_FREEFALL_LAND_STOP,
    ACT_HOLD_JUMP_LAND_STOP,
    ACT_HOLD_FREEFALL_LAND_STOP,
    ACT_AIR_THROW_LAND,
    ACT_TWIRL_LAND,
    ACT_LAVA_BOOST_LAND,
    ACT_LONG_JUMP_LAND_STOP,
    ACT_GROUND_POUND_LAND,
    ACT_BRAKING_STOP
}

GroundMovingActions = {
    ACT_WALKING,
    ACT_HOLD_WALKING,
    ACT_TURNING_AROUND,
    ACT_FINISH_TURNING_AROUND,
    ACT_BRAKING,
    ACT_RIDING_SHELL_GROUND,
    ACT_HOLD_HEAVY_WALKING,
    ACT_CRAWLING,
    ACT_BURNING_GROUND,
    ACT_DECELERATING,
    ACT_HOLD_DECELERATING,
    ACT_MOVE_PUNCHING,
    ACT_JUMP_LAND,
    ACT_FREEFALL_LAND,
    ACT_DOUBLE_JUMP_LAND,
    ACT_SIDE_FLIP_LAND,
    ACT_HOLD_JUMP_LAND,
    ACT_HOLD_FREEFALL_LAND,
    ACT_QUICKSAND_JUMP_LAND,
    ACT_HOLD_QUICKSAND_JUMP_LAND,
    ACT_TRIPLE_JUMP_LAND,
    ACT_BACKFLIP_LAND
}

HurtActions = {
    ACT_HARD_BACKWARD_GROUND_KB,
    ACT_HARD_FORWARD_GROUND_KB,
    ACT_BACKWARD_GROUND_KB,
    ACT_FORWARD_GROUND_KB,
    ACT_SOFT_BACKWARD_GROUND_KB,
    ACT_SOFT_FORWARD_GROUND_KB,
    ACT_HARD_BACKWARD_AIR_KB,
    ACT_HARD_FORWARD_AIR_KB


}

--- @param m MarioState
--- @return boolean
function ChecIfHit(m)
    for _, action in ipairs(HurtActions) do
        if action == gMarioStates[m.playerIndex].action then
            return true
        end
    end
    return false
end

--- @param m MarioState
--- @return boolean
function CheckIfStationary(m)
    for _, action in ipairs(StationaryActions) do
        if action == gMarioStates[m.playerIndex].action then
            return true
        end
    end
    return false
end

--- @param m MarioState
--- @return boolean
function CheckIfStationaryBefore(m)
    for _, action in ipairs(StationaryActions) do
        if action == gMarioStates[m.playerIndex].prevAction then
            return true
        end
    end
    return false
end

--- @param m MarioState
--- @return boolean
function CheckIfGroundMoving(m)
    for _, action in ipairs(GroundMovingActions) do
        if action == gMarioStates[m.playerIndex].action then
            return true
        end
    end
    return false
end

--- @param m MarioState
--- @return boolean
function CheckIfGroundMovingBeforeBefore(m)
    for _, action in ipairs(GroundMovingActions) do
        if action == gMarioStates[m.playerIndex].prevAction then
            return true
        end
    end
    return false
end
