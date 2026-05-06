gPlayerSyncTable[0].crazydany_effects = {}
local EffectIdsByName = {}
local EffectsList = {}
local nextEffectId = 1
local maxEffectId = 0

EffectData = {}
EffectData.__index = EffectData

function EffectData.new(name, onUpdate, onStart, onEnd)
    if EffectIdsByName[name] then
        return EffectsList[EffectIdsByName[name]]
    end
    local id = nextEffectId
    nextEffectId = id + 1
    if id > maxEffectId then maxEffectId = id end
    local self = setmetatable({
        id = id,
        name = name,
        onUpdate = onUpdate,
        onStart = onStart,
        onEnd = onEnd
    }, EffectData)
    EffectIdsByName[name] = id
    EffectsList[id] = self
    return self
end

function EffectData:Apply(m, dur)
    if dur <= 0 then return end
    if not gPlayerSyncTable[m.playerIndex] then
        gPlayerSyncTable[m.playerIndex] = {}
    end
    if not gPlayerSyncTable[m.playerIndex].crazydany_effects then
        gPlayerSyncTable[m.playerIndex].crazydany_effects = {}
    end
    local effects = gPlayerSyncTable[m.playerIndex].crazydany_effects
    local currentDur = effects[self.id] or 0
    if currentDur == 0 then
        if self.onStart then self.onStart(m, dur) end
        effects[self.id] = dur
    else
        effects[self.id] = currentDur + dur
    end
end

function EffectData:GetRemaining(m)
    if not m or m.playerIndex == nil then return 0 end
    local idx = m.playerIndex
    local effects = gPlayerSyncTable[idx] and gPlayerSyncTable[idx].crazydany_effects
    if type(effects) ~= "table" then return 0 end
    return tonumber(effects[self.id]) or 0
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    if not gPlayerSyncTable[m.playerIndex] then
        gPlayerSyncTable[m.playerIndex] = {}
    end
    local effects = gPlayerSyncTable[m.playerIndex].crazydany_effects
    if not effects then return end

    for id = 1, maxEffectId do
        local dur = effects[id]
        if dur and dur > 0 then
            local effect = EffectsList[id]
            if effect then
                if effect.onUpdate then effect.onUpdate(m, dur) end
                local newDur = dur - 1
                if newDur <= 0 then
                    if effect.onEnd then effect.onEnd(m) end
                    effects[id] = nil
                else
                    if m.playerIndex == 0 then
                        effects[id] = newDur
                    end
                end
            end
        end
    end
end)
