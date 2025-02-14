---@type Hero
local Hero = {
    name = 'Shadow Fiend',
    codename = 'sf',
    model = 5,
    health = { max = 1000, regen = 1.5 },
    mana = { max = 1000, regen = 1.5 },
    attack = { damage = 50, dist = 5, rate = 2 },
    abilities = {}
};

local function coil(range)
    clearCharTasksImmediately(PLAYER_PED);
    if not hasAnimationLoaded('carry') then
        requestAnimation('carry');
    end
    clearCharTasksImmediately(PLAYER_PED)
    taskPlayAnim(PLAYER_PED, 'putdwn105', 'carry', 0, false, true, true, true, 10000)

    local x, y, z = Map.getPosFromCharVector(range);
    local smoke = createObject(18686, x, y, z - 1);
    Map.dealDamageToPoint(Vector3D(x, y, z));
    wait(3000);
    deleteObject(smoke);
end


for i = 1, 3 do
    local coilAbility = {
        name = 'Coil ' .. i,
        description = 'asdasdasd',
        type = AbilityType.NonTarget,
        manaCost = 100,
        cooldown = 10,
        iconUrl = 'https://cdn.akamai.steamstatic.com/apps/dota2/images/dota_react/abilities/nevermore_shadowraze' .. i .. '.png'
    };
    
    function coilAbility:onUse()
        lua_thread.create(coil, i * 2);
    end

    table.insert(Hero.abilities, coilAbility);
end

local requiem = {
    name = 'Requiem',
    description = 'YA DED INSIDE SHKOLYAR-NEFOR, AUF',
    type = AbilityType.NonTarget,
    manaCost = 100,
    cooldown = 10,
    iconUrl = 'https://cdn.akamai.steamstatic.com/apps/dota2/images/dota_react/abilities/nevermore_requiem.png'
}

function requiem:onUse()
    lua_thread.create(function()
        local start = os.clock()
        local ultimate_objects = {}
        
        for i = 0, 360, 30 do
            local angle = math.rad(i) + math.pi / 2
            local posX, posY, posZ = getCharCoordinates(PLAYER_PED)

            local start = Vector3D(1 * math.cos(angle) + posX, 1 * math.sin(angle) + posY, posZ - 1)
            local stop = Vector3D(20 * math.cos(angle) + posX, 20 * math.sin(angle) + posY, posZ - 1)
            local handle = createObject(18686, start.x, start.y, start.z)
            ultimate_objects[handle] = {
                start = start,
                stop = stop
            }
            
        end

        -- create object
        while start + 4 - os.clock() > 0 do
            wait(0)
            for handle, data in pairs(ultimate_objects) do
                if doesObjectExist(handle) then
                    slideObject(handle, data.stop.x, data.stop.y, data.stop.z, 0.5, 0.5, 0.5, false)
                    local result, x, y, z = getObjectCoordinates(handle);
                    if result then
                        Map.dealDamageToPoint(Vector3D(x, y, z), 55);
                    end
                end
            end
        end
        for handle, data in pairs(ultimate_objects) do
            if doesObjectExist(handle) then
                deleteObject(handle)
                ultimate_objects[handle] = nil
            end
        end
    end);
end

table.insert(Hero.abilities, requiem);

return Hero;