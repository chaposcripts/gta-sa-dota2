local Vector3D = require('vector3d');
local Map = {
    pos = Vector3D(0, 0, 600),
    pool = {}
};

CreepSpawnPoint = {
    [CreepTeam.Groove] = Vector3D(125, -125, Map.pos.z + 1),
    [CreepTeam.Ballas] = Vector3D(-125, 125, Map.pos.z + 1)
};

---@type {model: number, pos: Vector3D, rot: Vector3D, collision: boolean, scale: number, tag: string}[]
Map.mapping = {
    -- Floor
    { tag = "floor_1", pos = Vector3D(-125,0,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_2", pos = Vector3D(0,0,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_3", pos = Vector3D(125,0,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_4", pos = Vector3D(-125,125,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_5", pos = Vector3D(0,125,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_6", pos = Vector3D(125,125,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_4", pos = Vector3D(-125,-125,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_5", pos = Vector3D(0,-125,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },
    { tag = "floor_6", pos = Vector3D(125,-125,600), scale = 1, model = 19550, rot = Vector3D(0,0,0), collision = true },

    -- Lines routes
    { pos = Vector3D(125,-55,600), scale = 1, collision = false, tag = "DOWNLINE #2", model = 4152, rot = Vector3D(0,0,0) },
    { pos = Vector3D(125,70,600), scale = 1, collision = false, tag = "DOWNLINE #2_COPY", model = 4152, rot = Vector3D(0,0,0) },
    { pos = Vector3D(-55,125,600), scale = 1, collision = false, tag = "DOWNLINE #2_COPY_COPY", model = 4152, rot = Vector3D(0,0,90) },
    { pos = Vector3D(70,125,600), scale = 1, collision = false, tag = "DOWNLINE #2_COPY_COPY_COPY", model = 4152, rot = Vector3D(0,0,90) },

    { pos = Vector3D(-125,55,600), scale = 1, collision = false, comment = "TOPLINE #2", model = 4152, rot =  Vector3D(0,0,0)},
    { pos = Vector3D(-125,-70,600), scale = 1, collision = false, comment = "TOPLINE #2_COPY", model = 4152, rot =  Vector3D(0,0,0)},
    { pos = Vector3D(55,-125,600), scale = 1, collision = false, comment = "TOPLINE #2_COPY_COPY", model = 4152, rot =  Vector3D(0,0,270)},
    { pos = Vector3D(-70,-125,600), scale = 1, collision = false, comment = "TOPLINE #2_COPY_COPY_COPY", model = 4152, rot =  Vector3D(0,0,270)},

    -- Buildings
    { scale = 1, model = 3640, tag = "Line_Bottom_Top", pos = Vector3D(107.85287475586,-78.274017333984,600), collision = false, rot = Vector3D(0,0,90) },
    { scale = 1, model = 9326, tag = "Line_Bottom_Top", pos = Vector3D(105.28001403809,-61.934051513672,600), collision = false, rot = Vector3D(0,0,180) },
    { scale = 1, model = 3843, tag = "Line_Bottom_Top", pos = Vector3D(106.91502380371,-47.144996643066,600), collision = false, rot = Vector3D(0,0,180) },
    { scale = 1, model = 3823, tag = "Line_Bottom_Top", pos = Vector3D(105.62985992432,-32.426391601563,600), collision = false, rot = Vector3D(0,0,0) },
    { scale = 1, model = 9275, tag = "Line_Bottom_Top", pos = Vector3D(106.41770935059,-15.420436859131,600), collision = false, rot = Vector3D(0,0,0) },
    { scale = 1, model = 5520, tag = "Line_Bottom_Top", pos = Vector3D(101.08378601074,8.4388046264648,600), collision = false, rot = Vector3D(0,0,90) },
    { scale = 1, model = 9320, tag = "Line_Bottom_Top", pos = Vector3D(96.189224243164,41.706481933594,600), collision = false, rot = Vector3D(0,0,180) },
    { scale = 1, model = 9322, tag = "Line_Bottom_Top", pos = Vector3D(104.88433837891,67.820083618164,600), collision = false, rot = Vector3D(0,0,90) },
    { scale = 1, model = 3316, tag = "Line_Bottom_Top", pos = Vector3D(153.59991455078,-89.228706359863,600), collision = false, rot = Vector3D(0,0,270) },
    { scale = 1, model = 3314, tag = "Line_Bottom_Bottom", pos = Vector3D(153.59991455078,-7.1000008583069,600), collision = false, rot = Vector3D(0,0,270) },
    { scale = 1, model = 3351, tag = "Line_Bottom_Bottom", pos = Vector3D(153.59991455078,35.699989318848,600), collision = false, rot = Vector3D(0,0,270) },
    { scale = 1, model = 3353, tag = "Line_Bottom_Bottom", pos = Vector3D(153.59991455078,92.399963378906,600), collision = false, rot = Vector3D(0,0,270) },
    { scale = 1, model = 6257, tag = "Line_Bottom_Bottom", pos = Vector3D(153.46401977539,-49.524425506592,600), collision = false, rot = Vector3D(0,0,270) },


    { scale = 1, model = 3640, tag = "Line_Top_Top", pos = Vector3D(-107.85287475586,-78.274017333984,600), collision = false, rot = Vector3D(0,0,270) },
    { scale = 1, model = 9326, tag = "Line_Top_Top", pos = Vector3D(-105.28001403809,-61.934051513672,600), collision = false, rot = Vector3D(0,0,0) },
    { scale = 1, model = 3843, tag = "Line_Top_Top", pos = Vector3D(-106.91502380371,-47.144996643066,600), collision = false, rot = Vector3D(0,0,0) },
    { scale = 1, model = 3823, tag = "Line_Top_Top", pos = Vector3D(-105.62985992432,-32.426391601563,600), collision = false, rot = Vector3D(0,0,180) },
    { scale = 1, model = 9275, tag = "Line_Top_Top", pos = Vector3D(-106.41770935059,-15.420436859131,600), collision = false, rot = Vector3D(0,0,180) },
    { scale = 1, model = 5520, tag = "Line_Top_Top", pos = Vector3D(-101.08378601074,8.4388046264648,600), collision = false, rot = Vector3D(0,0,270) },
    { scale = 1, model = 9320, tag = "Line_Top_Top", pos = Vector3D(-96.189224243164,41.706481933594,600), collision = false, rot = Vector3D(0,0,0) },
    { scale = 1, model = 9322, tag = "Line_Top_Top", pos = Vector3D(-104.88433837891,67.820083618164,600), collision = false, rot = Vector3D(0,0,450) },
    { scale = 1, model = 3316, tag = "Line_Top_Top", pos = Vector3D(-153.59991455078,-89.228706359863,600), collision = false, rot = Vector3D(0,0,450) },
    { scale = 1, model = 3314, tag = "Line_Top_Bottom", pos = Vector3D(-153.59991455078,-7.1000008583069,600), collision = false, rot = Vector3D(0,0,450) },
    { scale = 1, model = 3351, tag = "Line_Top_Bottom", pos = Vector3D(-153.59991455078,35.699989318848,600), collision = false, rot = Vector3D(0,0,450) },
    { scale = 1, model = 3353, tag = "Line_Top_Bottom", pos = Vector3D(-153.59991455078,92.399963378906,600), collision = false, rot = Vector3D(0,0,450) },
    { scale = 1, model = 6257, tag = "Line_Top_Bottom", pos = Vector3D(-153.46401977539,-49.524425506592,600), collision = false, rot = Vector3D(0,0,450) },
};

function Map.destroy()
    for index, objectInstance in ipairs(Map.pool) do
        objectInstance:destroy();
        table.remove(Map.pool, index);
    end
end

---@param dist number?
---@param addAngle number?
---@return number x
---@return number y
---@return number z
function Map.getPosFromCharVector(dist, addAngle)
    local angle = math.rad(getCharHeading(PLAYER_PED)) + math.pi / 2
    local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
    local x, y, z = dist * math.cos(angle) + posX, dist * math.sin(angle) + posY, posZ
    return x, y, z
end

---@param point Vector3D
---@param damage number
---@param filterByTeam? CreepTeam
function Map.dealDamageToPoint(point, damage, filterByTeam)

end

function Map.init()
    -- addEventHandler('onScriptTerminate', function(scr)
    --     if (scr == thisScript()) then
    --        Map.destroy();
    --     end
    -- end);
    for _, obj in ipairs(Map.mapping) do
        local obj = Object:new(obj.model, obj.pos, obj.rot, obj.collision, obj.scale, obj.tag);
        Utils.msg('Object created', obj.tag);
        table.insert(Map.pool, obj);
    end
end

function Map.drawCircleIn3d(vec, radius, color, width, polygons)
    local step = math.floor(360 / (polygons or 36));
    local sX_old, sY_old;
    for angle = 0, 360, step do
        local _, sX, sY, sZ, _, _ = convert3DCoordsToScreenEx(radius * math.cos(math.rad(angle)) + vec.x , radius * math.sin(math.rad(angle)) + vec.y , vec.z); ---@diagnostic disable-line
        if (sZ > 1) then
            if (sX_old and sY_old) then
                renderDrawLine(sX, sY, sX_old, sY_old, width, color);
            end
            sX_old, sY_old = sX, sY;
        end
    end
end

return Map;