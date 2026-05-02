local EffectIdsByName = {}
local EffectsList = {}

local nextEffectId = 1

EffectData = {}
EffectData.__index = EffectData

--- Создаёт или возвращает существующий эффект
--- @param name string
--- @param onUpdate function(m, dur) вызывается каждый кадр, пока эффект активен
--- @param onStart function(m, dur) вызывается при первом применении эффекта
--- @param onEnd function(m) вызывается, когда длительность эффекта становится 0
--- @return table
function EffectData.new(name, onUpdate, onStart, onEnd)
    if EffectIdsByName[name] ~= nil then
        return EffectsList[EffectIdsByName[name]]
    end

    local id = nextEffectId
    nextEffectId = nextEffectId + 1

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

--- Применяет эффект к игроку на указанную длительность (в кадрах)
--- @param m MarioState
--- @param dur number длительность в кадрах (>0)
function EffectData:Apply(m, dur)
    djui_chat_message_create("Applying effect " .. self.name .. " for player " .. m.playerIndex)

    if dur <= 0 then
        return
    end

    if gPlayerSyncTable[m.playerIndex].crazydany_effects == nil then
        gPlayerSyncTable[m.playerIndex].crazydany_effects = {}
    end

    local effects = gPlayerSyncTable[m.playerIndex].crazydany_effects
    local currentDur = effects[self.id] or 0

    if currentDur == 0 then
        if self.onStart then
            self.onStart(m, dur)
        end
        effects[self.id] = dur
    else
        effects[self.id] = currentDur + dur
    end
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    local effects = gPlayerSyncTable[m.playerIndex].crazydany_effects
    if not effects then
        return
    end

    for id, dur in ipairs(effects) do
        if type(id) == "number" and dur > 0 then
            local effect = EffectsList[id]
            if effect then
                if effect.onUpdate then
                    djui_chat_message_create("Updating effect " .. effect.name .. " for player " .. m.playerIndex)
                    effect.onUpdate(m, dur)
                end

                local newDur = dur - 1
                if newDur <= 0 then
                    if effect.onEnd then
                        effect.onEnd(m)
                    end
                    effects[id] = nil
                else
                    effects[id] = newDur
                end
            end
        end
    end
end)
