---@class Hero
---@field name string
---@field codename string
---@field model number
---@field health {max: number, regen: number}
---@field mana {max: number, regen: number}
---@field weapon? number
---@field attack {animation?: Animation, dist: number, damage: number, rate: number}
---@field abilities Ability[]
---@field onTakeDamage? fun(self: Hero, damage: number, from: Creep)
---@field beforeTakeDamage? fun(self: Hero, damage: number, from: Creep): boolean
---@field onGiveDamage? fun(self: Hero, damage: number, to: Creep)
---@field beforeGiveDamage? fun(self: Hero, damage: number, to: Creep): boolean
---@field process? fun(self: Hero)
---@field iconUrl? string

local Heroes = {
    list = {}
};

function Heroes.init()
    Heroes.list = {
        require('heroes.sf'),
        -- require('heroes.tinker')
    };
    
    local modelsToLoad = {};
    for _, hero in ipairs(Heroes.list) do
        table.insert(modelsToLoad, hero.model);
        if (hero.weapon) then
            table.insert(modelsToLoad, getWeapontypeModel(hero.weapon));
        end
    end

    for _, model in ipairs(modelsToLoad) do
        if (not hasModelLoaded(model)) then
            requestModel(model);
        end
    end
    loadAllModelsNow();
end

return Heroes;