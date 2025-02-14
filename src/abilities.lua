---@class Ability
---@field name string
---@field description string
---@field manaCost? number
---@field healthCost? number
---@field type AbilityType
---@field onCast? fun(self: Ability, target: Creep)
---@field onCastStart? fun(self: Ability, target: Creep)
---@field onCastEnd? fun(self: Ability, target: Creep)
---@field onProcess? fun(self: Ability)
---@field objects? Object[]
---@field castAnimation? Animation
---@field onUse fun(self: Ability)
---@field onEnabled? fun(self: Ability)
---@field cooldown number
---@field lastUsed? number
---@field enabled? boolean
---@field iconUrl? string

---@enum AbilityType
AbilityType = {
    Passive = 'PASSIVE',
    TargetPoint = 'TARGET_POINT',
    TargetEntity = 'TARGET_ENTITY',
    TargetEnemy = 'TARGET_ENEMY',
    TargetAlly = 'TARGET_ALLY',
    TargetSelf = 'TARGET_SELF',
    NonTarget = 'NON_TARGET'
};

local Abilities = {};

return Abilities;