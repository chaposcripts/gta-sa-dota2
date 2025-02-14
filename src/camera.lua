local Camera = {
    pos = Vector3D(0, 0, 0),
    point = Vector3D(0, 0, 0),
    offset = 5
};

local WheelDirection = {
    Down = 4287102976,
    Up = 7864320
};

---@param pos Vector3D
---@param point Vector3D
function Camera.init(pos, point)
    Camera.pos, Camera.point = pos, point;
    addEventHandler('onWindowMessage', function(msg, param, lParam)
        if (msg == 0x020a --[[ WM_MOUSEWHEEL ]]) then
            Camera.pos.z = param == WheelDirection.Down and Camera.pos.z + 2 or Camera.pos.z - 2;
            Camera.pos.x = param == WheelDirection.Down and Camera.pos.x + 1 or Camera.pos.x - 1;
        end
    end);
end

function Camera.destroy()
    Camera.restore();
end

function Camera.pointAtPlayer()
    local ped = Vector3D(getCharCoordinates(PLAYER_PED))
    Camera.pos.x, Camera.pos.y = ped.x, ped.y + 15
end

---@param pos Vector3D
function Camera.setPos(pos)
    cameraResetNewScriptables()
    setFixedCameraPosition(pos.x, pos.y, pos.z, 0, 0, 0)
end

---@param point Vector3D
function Camera.setPointAt(point)
    cameraResetNewScriptables()
    pointCameraAtPoint(point.x, point.y, point.z, 2)
end

function Camera.update()
    Camera.setPos(Vector3D(Camera.pos.x, Camera.pos.y - 5, Camera.pos.z + 15));
    Camera.setPointAt(Vector3D(Camera.pos.x, Camera.pos.y + 5, Camera.pos.z));
end
local imgui = require('mimgui');
local invalidDragSkipped = true;

function Camera.process()
    -- Point camera at player if tab is pressed
    if (isKeyDown(VK_TAB)) then Camera.pointAtPlayer() end

    -- Move camera if cursor on screen corner
    

    -- Move camera with mouse wheel
    -- if (isKeyDown(VK_MBUTTON)) then
    --     local mvx, mvy = getPcMouseMovement();
    --     Camera.pos.y = Camera.pos.y + mvy / 10;
    --     Camera.pos.x = Camera.pos.x + mvx / 10;
    -- end
  

    local drag = imgui.GetMouseDragDelta(2, false);
    if (drag) then
        if (invalidDragSkipped) then
            Camera.pos.x = Camera.pos.x - drag.x / 100;
            Camera.pos.y = Camera.pos.y + drag.y / 100;
            invalidDragSkipped = false;
        end
        renderFontDrawText(DEBUG_FONT, ('DRAG: INV: %s %d %d'):format(tostring(invalidDragSkipped), drag.x, drag.y), 500, 500, 0xFFff00ff, false);
       
        if (invalidDragSkipped and imgui.IsMouseReleased(2)) then
            Utils.msg('rel');
            invalidDragSkipped = false;
        end
    end
    print(drag.x, drag.y)
    
    
    if (imgui.IsMouseDragging(2)) then
        -- if (drag and invalidDragSkipped) then
        --     renderFontDrawText(DEBUG_FONT, ('DRAG: %d %d'):format(drag.x, drag.y), 500, 500, 0xFFff00ff, false);
        --     if (drag.x ~= 0) then
        --         Camera.pos.x = Camera.pos.x - drag.x / 100;
        --     end
        --     if (drag.y ~= 0) then
        --         Camera.pos.y = Camera.pos.y + drag.y / 100;
        --     end
        --     imgui.ResetMouseDragDelta(2);
        -- end
    else
        local cur = imgui.ImVec2(getCursorPos());
        local res = imgui.ImVec2(getScreenResolution());
        if (cur.x <= 5 or cur.x >= res.x - 5) then
            Camera.pos.x = Camera.pos.x + (cur.x <= 5 and -0.5 or 0.5);
        end
        if (cur.y <= 5 or cur.y >= res.y - 5) then
            Camera.pos.y = Camera.pos.y - (cur.y <= 5 and -0.5 or 0.5);
        end
    end
    
end

Camera.restore = restoreCameraJumpcut;

return Camera;