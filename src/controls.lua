local Controls = {
    gotoPointer = {
        draw = false,
        pos = Vector3D(0, 0, 0)
    },
    ---@type { start: number, pos: Vector3D }[]
    circles = {}
};

---@param x number?
---@param y number?
---@param custom boolean[]?
---@return Vector3D
---@return table
function Controls.getCursorMapPos(x, y, custom)
    local args = custom or {true, true, false, true, false, false, false}
    local curX, curY = getCursorPos()
    local resX, resY = getScreenResolution()
    local posX, posY, posZ = convertScreenCoordsToWorld3D(x or curX, y or curY, 700.0)
    local camX, camY, camZ = getActiveCameraCoordinates()
    local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, table.unpack(args))
    if result and colpoint.entity ~= 0 then
        local normal = colpoint.normal
        local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
        local zOffset = 300
        if normal[3] >= 0.5 then zOffset = 1 end
        local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3, table.unpack(args))
        if result then
            return Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3]), colpoint2
        end
    end
    return Vector3D(0, 0, 0), colpoint
end

function Controls.process()
    if (wasKeyPressed(VK_RBUTTON)) then
        local pos, colpoint = Controls.getCursorMapPos();
        if (pos) then
            taskCharSlideToCoord(PLAYER_PED, pos.x, pos.y, pos.z, 0 ,0);
            Controls.gotoPointer.draw = true;
            Controls.gotoPointer.pos = pos;
            Controls.gotoPointer.start = os.clock();

            table.insert(Controls.circles, {
                pos = pos,
                start = os.clock()
            });
        end
    end
    setGameKeyState(16, 256); -- sprint

    -- draw circles
    for index, circle in pairs(Controls.circles) do
        local radius, alpha = Utils.bringFloatTo(0.5, 0, circle.start, 0.5), Utils.bringFloatTo(255, 0, circle.start, 0.5);
        local color = Utils.join_argb(alpha, 0, 255, 0);
        Map.drawCircleIn3d(
            circle.pos,
            radius,
            color,
            4,
            50
        );
        if (alpha == 0) then
            table.remove(Controls.circles[index]);
        end
    end
end

return Controls;