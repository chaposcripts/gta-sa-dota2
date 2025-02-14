---@meta
---@class Player
---@field team CreepTeam
---@field health number
---@field mana number
---@field gold number
---@field lastTick number
---@field hero? Hero
---@field init fun(self: Player, hero: Hero)
---@field process fun(self: Player)
---@field onDamageReceived fun(self: Player, damage: number, from?: Creep)
---@field keyHandler fun(self: Player, key: number)
---@field useAbility fun(self: Player, slot: number): boolean, string

local targetSelectionHandler = nil;

---@type Player
local Player = {
    team = CreepTeam.Groove,
    health = 1000,
    mana = 1000,
    gold = 600,
    lastTick = 0,
    hero = nil,
    handlers = {
        ability = nil
    }
};

AbilityKey = {
    [1] = VK_Q,
    [2] = VK_W,
    [3] = VK_E,
    [4] = VK_R
};

ItemKey = {
    [1] = VK_Z,
    [2] = VK_X,
    [3] = VK_C,
    [4] = nil,
    [5] = nil,
    [6] = nil,
};

---@param hero Hero
function Player:init(hero)
    Player.lastTick = os.time();
    addEventHandler('onWindowMessage', function(msg, key)
        if (msg == 0x0100) then
            Player:keyHandler(key);
        end
    end);
    self.hero = hero;
    Utils.setCharModel(PLAYER_PED, hero.model or 0);
end

function Player:process()
    if (os.time() - Player.lastTick >= 1) then
        Player.gold = Player.gold + 1;
        Player.lastTick = os.time();

        Player.mana = Player.mana + Player.hero.mana.regen;
        if (Player.mana > Player.hero.mana.max) then
            Player.mana = Player.hero.mana.max;
        end
        Player.health = Player.health + Player.hero.health.regen;
        if (Player.health > Player.hero.health.max) then
            Player.health = Player.hero.health.max;
        end
    end
end

---@param ability Ability
local function abilityTargetSelection(ability)
    while (true) do
        wait(0);
        while (not wasKeyPressed(VK_LBUTTON)) do
            wait(0);
            
            -- renderDrawBox(200, 200, 50, 50, 0xffffffff);
        end
        renderDrawBox(0, 0, 100, 100, 0xFFff0000);
        targetSelectionHandler = nil;
        return;
    end
end

function Player:useAbility(slot)
    if (not Player.hero.abilities[slot]) then
        return false, 'ERR_NO_ABILITY';
    end
    local ability = Player.hero.abilities[slot];
    
    -- Check cooldown
    if (os.time() - (ability.lastUsed or ability.cooldown) < ability.cooldown) then
        return false, 'ERR_COOLDOWN';
    end

    -- Check manacost or health cost
    if (ability.manaCost > Player.mana) then
        return false, 'ERR_NO_MANA';
    end

    -- Use ability
    if (ability.type == AbilityType.Togleable or ability.type == AbilityType.NonTarget) then
        if (ability.type == AbilityType.Togleable) then
            Player.hero.abilities[slot].enabled = not Player.hero.abilities[slot].enabled;
            if (Player.hero.abilities[slot].enabled) then
                -- Player.hero.abilities[slot]:onToggle(Player.hero.abilities[slot].enabled);
            end
        end
        Player.mana = Player.mana - ability.manaCost;
        Player.hero.abilities[slot].lastUsed = os.time();
        Player.hero.abilities[slot]:onUse();
        return true, 'OK';
    elseif (ability.type == AbilityType.TargetPoint or ability.type == AbilityType.TargetEntity or ability.type == AbilityType.TargetAlly or ability.type == AbilityType.TargetSelf) then
        if (targetSelectionHandler) then
            return false, 'TARGET_SEARCH_IN_PROCESS';
        end
        targetSelectionHandler = lua_thread.create(abilityTargetSelection, ability); ---@diagnostic disable-line
        return true, 'WAITING_FOR_TARGET';
    end
    
    return false, 'PASS';
end

function Player:keyHandler(key)
    if (key == VK_S and targetSelectionHandler) then
        targetSelectionHandler:terminate();
        targetSelectionHandler = nil;
    end
    for abilitySlot, abilityKey in ipairs(AbilityKey) do
        if (key == abilityKey) then
            if (Player.hero.abilities[abilitySlot]) then
                local status, message = Player:useAbility(abilitySlot);
                if (not status) then
                    Utils.msg('Error using ability:', message or 'none');
                end
            end
        end
    end
end

function Player:onDamageReceived(damage, from)

end

return Player;