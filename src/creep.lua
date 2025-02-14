---@meta
local Vector3D = require('vector3d');
-- local Utils = require('utils');

local CreepPool = {
    Creep = {},
    pool = {}
};

---@enum CreepTeam
CreepTeam = {
    Ballas = 'BALLAS',
    Groove = 'GROOVE'
};

---@enum CreepType
CreepType = {
    Melee = 'MELEE',
    Range = 'RANGE',
    Tower = 'TOWER'
};

---@enum CreepModel
CreepModel = {
    [CreepTeam.Groove] = {
        [CreepType.Melee] = 105,
        [CreepType.Range] = 107,
        [CreepType.Tower] = 106
    },
    [CreepTeam.Ballas] = {
        [CreepType.Melee] = 103,
        [CreepType.Range] = 104,
        [CreepType.Tower] = 102
    }
};

---@enum CreepWeapon
CreepWeapon = {
    [CreepType.Melee] = 5,
    [CreepType.Range] = 24,
    [CreepType.Tower] = 35
};

CreepPedType = 6;

---@alias Vector3D {x: number, y: number, z: number}

function CreepPool.init()
    -- Load models
    local modelsToLoad = {};

    -- Peds models
    for team, types in pairs(CreepModel) do
        for creepType, model in pairs(types) do
            if (not hasModelLoaded(model)) then ---@diagnostic disable-line
                requestModel(model) ---@diagnostic disable-line
                table.insert(modelsToLoad, model);
            end
        end
    end

    -- Weapons models
    for _, weapon in pairs(CreepWeapon) do
        local model = getWeapontypeModel(weapon);
        if (not hasModelLoaded(model)) then ---@diagnostic disable-line
            requestModel(model) ---@diagnostic disable-line
            table.insert(modelsToLoad, model);
        end
    end
    if (#modelsToLoad > 0) then
        Utils.debugMsg('Loading creep modes. Count:', #modelsToLoad, 'models', table.concat(modelsToLoad, ', '));
        loadAllModelsNow();
    end

    -- addEventHandler('onScriptTerminate', function(scr)
    --     if (scr == thisScript()) then
    --         CreepPool.destroy();
    --     end
    -- end);
end

function CreepPool.process() 
    for index, creep in ipairs(CreepPool.pool) do
        creep:process();
        -- print('rp', DEV)
        if (DEV) then
            creep:drawDebugInfo();
        end
    end
end

---@param keepInPool? boolean
function CreepPool.destroy(keepInPool)
    for index, creep in ipairs(CreepPool.pool) do
        creep:destroy(keepInPool);
        if (creep.type == CreepType.Tower) then
            if (creep.tower and creep.tower.missle and doesObjectExist(creep.tower.missle)) then
                deleteObject(creep.tower.missle);
            end
        end
    end
end

---@param keepInPool? boolean
function CreepPool.Creep:destroy(keepInPool)
    if (doesCharExist(self.handle)) then
        deleteChar(self.handle);
    end
    if (not keepInPool) then
        for index, creep in ipairs(CreepPool.pool) do
            if (creep.handle == self.handle) then
                CreepPool.pool[index] = nil;
            end
        end
    end
end

CreepAttackRange = {
    [CreepType.Melee] = 3,
    [CreepType.Range] = 6,
    [CreepType.Tower] = 10
};
CreepTaskUpdateRate = 0.5;

---@class Creep
---@field type CreepType
---@field team CreepTeam
---@field spawnPoint Vector3D
---@field handle number
---@field route {enabled: boolean, poins: any, lastMoveUpdate: number}
---@field target? Creep
---@field process fun(self: Creep)
---@field destroy fun(self: Creep, keepInPool?: boolean)
---@field updateTarget fun(self: Creep)
---@field processMovement fun(self: Creep)

function CreepPool.Creep:drawDebugInfo()
    if (not isCharOnScreen(self.handle)) then return end
    local pos = Vector3D(getCharCoordinates(self.handle));
    local sx, sy = convert3DCoordsToScreen(pos.x, pos.y, pos.z);
    renderFontDrawText(DEBUG_FONT, ([[Creep
Handle: %d;
Team: %s;
Type: %s;
RouteEnabled: %s;
TargetHandle: %s
    ]]):format(self.handle, self.team, self.type, self.route.enabled, self.target and self.target.handle or 'NONE'), sx, sy, 0xFFffffff, false);

    Map.drawCircleIn3d(pos, CreepAttackRange[self.type], self.target == nil and 0xFF00ff00 or 0xFFff0000, 1, 25);
    Map.drawCircleIn3d(pos, CreepVisionDistance, 0xccfffffff, 1, 25);
    
    
    local rx, ry = convert3DCoordsToScreen(self.route.finish.x, self.route.finish.y, self.route.finish.z);
    renderDrawLine(sx, sy, rx, ry, 2, 0xFFffFFff);

    if (self.target) then
        local tx, ty = convert3DCoordsToScreen(getCharCoordinates(self.target.handle));
        renderDrawLine(sx, sy, tx, ty, 2, 0xFFFF0000);
    end
end

function CreepPool.Creep:processMovement()
    if (not self.handle) then return end
    if (not self.route.enabled) then return end
    if (os.clock() - self.route.lastMoveUpdate > CreepTaskUpdateRate) then
        local gotoPoint = self.target == nil and self.route.finish or Vector3D(getCharCoordinates(self.target.handle));
        taskCharSlideToCoord(self.handle, gotoPoint.x, gotoPoint.y, gotoPoint.z, 0, 0);
        self.route.lastMoveUpdate = os.clock();
    end
    -- print('processing movement')
end

CreepAttackRate = 1;
CreepVisionDistance = 10;

---@param handle number
---@return Creep?
function CreepPool.findByHandle(handle)
    for _, creep in ipairs(CreepPool.pool) do
        if (creep.handle == handle) then
            return creep;
        end
    end
    return nil;
end

function CreepPool.Creep:updateTarget()
    self.target = nil;
    local pos = Vector3D(getCharCoordinates(self.handle));
    for _, creep in ipairs(CreepPool.pool) do
        if (creep.team ~= self.team and doesCharExist(creep.handle)) then
            local targetPos = Vector3D(getCharCoordinates(creep.handle));
            local dist = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, targetPos.x, targetPos.y, targetPos.z);
            if (dist <= CreepVisionDistance) then
                self.target = creep;
            end
        end
    end
end

function CreepPool.Creep:processTower()
    if (not self.tower.missle or not self.target) then
        return
    end
    if (not doesCharExist(self.target.handle) or not doesObjectExist(self.tower.missle)) then
        return
    end
    local x, y, z = getCharCoordinates(self.target.handle);
    if (slideObject(self.tower.missle, x, y, z, 0.1, 0.1, 0.1, false)) then
        deleteObject(self.tower.missle);
        self.tower.missle = nil;
        self.target:dealDamage(50, self);
    end
end

function CreepPool.Creep:process()
    self:processTower();
    if (not doesCharExist(self.handle)) then
        print('warning, creep not found', self.handle);
        return;
    end
    local pos = Vector3D(getCharCoordinates(self.handle));
    
    if (DEV) then
        self:drawDebugInfo();
    end

    local attackingTarget = false;
    if (self.target) then
        local targetPos = Vector3D(getCharCoordinates(self.target.handle));
        local distToTarget = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, targetPos.x, targetPos.y, targetPos.z);
        if (distToTarget <= CreepAttackRange[self.type]) then
            if (os.clock() - self.lastAttack > (self.type == CreepType.Tower and 5 or CreepAttackRate)) then
                taskAimGunAtChar(self.handle, self.target.handle, 50);
                self.lastAttack = os.clock();
                if (self.type == CreepType.Tower) then
                    if (not self.tower.missle) then
                        self.tower.missle = createObject(345, pos.x, pos.y, pos.z + 5); ---@diagnostic disable-line
                    end
                else
                    taskLookAtChar(self.handle, self.target.handle, 0);
                    taskPlayAnim(self.handle, Animation.Attack[self.type].name, Animation.Attack[self.type].file, 4, false, false, false, false, -1);
                    self.target:dealDamage(10, self);
                end
            end
            attackingTarget = true
        end
    end
    if (self.route.enabled and not attackingTarget) then
        self:processMovement();
    end
    self:updateTarget();
end

---@param damage number
---@param from Creep | "player"
function CreepPool.Creep:dealDamage(damage, from)
    self.health = self.health - damage;
    if (self.health <= 0) then
        -- self:destroy(false);
    end
end

---@param countPerTeam? number
---@param rangeCount? number
function CreepPool.spawnWave(countPerTeam, rangeCount)
    local count = {
        melee = (countPerTeam or 5) - (rangeCount or 0),
        range = rangeCount or 0
    };
    for _, team in pairs(CreepTeam) do
        for i = 1, count.melee + count.range do
            local newCreepPos = CreepSpawnPoint[team];
            newCreepPos.x = newCreepPos.x + 0.3 * i;
            local newCreep = CreepPool.Creep:new(team, CreepType.Melee, newCreepPos, CreepSpawnPoint[team == CreepTeam.Groove and CreepTeam.Ballas or CreepTeam.Groove]);
            Utils.debugMsg('Spawned creep', newCreep.handle, team, 'melee');
        end
    end
end

---@param team CreepTeam
---@param type CreepType
---@param pos Vector3D
---@param routePoints? Vector3D[]
---@return Creep
function CreepPool.Creep:new(team, type, pos, routePoints)
    -- print('finish', routePoints ~= nil)
    local handle = createChar(CreepPedType, CreepModel[team][type], pos.x, pos.y, pos.z); ---@diagnostic disable-line
    if (CreepWeapon[type]) then
        giveWeaponToChar(handle, CreepWeapon[type], 9999);
        setCurrentCharWeapon(handle, CreepWeapon[type]);
    end
    local instance = {
        tower = {
            object = nil,
            missle = nil,
        },
        team = team,
        type = type,
        spawnPoint = pos,
        handle = handle,
        health = 150,
        lastAttack = 0,
        route = {
            enabled = routePoints ~= nil,
            points = Utils.isVector3D(routePoints) and { routePoints } or routePoints,
            finish = type == CreepType.Tower and pos or nil,
            currentPoint = 0,
            lastMoveUpdate = 0
        }
    };
    if (instance.route.enabled) then
        instance.route.finish = instance.route.points[#instance.route.points];
    end

    if (type == CreepType.Tower) then
        local towerPos = pos;
        towerPos.z = towerPos.z - 6;
        instance.tower.object = Object:new(3286, towerPos, nil, true, nil, nil);
        setCharCoordinates(instance.handle, pos.x, pos.y, pos.z + 10);
        
    end

    -- print(routeFinish, instance.route.enabled)
    local meta = setmetatable(instance, { __index = self });
    table.insert(CreepPool.pool, meta);
    return meta
end

return CreepPool;