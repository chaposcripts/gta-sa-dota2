---@diagnostic disable: lowercase-global

script_name('Dota2 SA:MP Edition');
script_author('chapo');
DEV = LUBU_BUNDLED == nil; ---@diagnostic disable-line
IS_SAMP = isSampLoaded() and isSampfuncsLoaded();
DEBUG_FONT = renderCreateFont('Arial', 8, 5);

require('moonloader');

local GameState = {
    None = 'NONE',
    Menu = 'MENU',
    InGame = 'IN_GAME'
};
local state = GameState.None;

ImGui = require('mimgui');
Vector3D = require('vector3d');

Object = require('object');
Camera = require('camera');
Utils = require('utils');
CreepPool = require('creep');
Map = require('map');
Abilities = require('abilities')
Player = require('player');
Heroes = require('hero');
Controls = require('controls');
UiComponent = {
    hud = require('ui.hud'),
    imageUrl = require('ui.image-url')
};

Animation = {
    Attack = {
        [CreepType.Melee] = { name = 'Bat_M', file = 'BASEBALL'},
        [CreepType.Range] = { name = 'colt45_fire_2hands', file = 'COLT45'},
        [CreepType.Tower] = { name = 'colt45_fire_2hands', file = 'COLT45'},
    }
};

local function loadAnimations()
    if (not hasAnimationLoaded(Animation.Attack[CreepType.Melee].file)) then
        requestAnimation(Animation.Attack[CreepType.Melee].file);
    end
end

local function destroy()
    Camera.destroy();
    CreepPool.destroy();
    Map.destroy();

    -- No destructor for this modules
    --[[
        Abilities.destroy();
        Heroes.destroy();
        Controls.destroy();
    ]]
end

function main()
    addEventHandler('onScriptTerminate', function(scr)
        if (scr == thisScript()) then
            Utils.debugMsg('Script terminated, destroying everything.');
            destroy();
        end
    end);
    Heroes.init();
    Player:init(Heroes.list[1]); -- TODO: replace with copyTable

    -- Utils.msg(type(Vector3D(1, 1, 1)))
    if (IS_SAMP) then
        while not isSampAvailable() do wait(0) end
        Utils.msg('Dooda loaded!');
        sampRegisterChatCommand('dooda', function()
            Camera.init(Vector3D(0, 0, 605), Vector3D(0, 0, 600));
            Camera.update();
            -- sampToggleCursor(true);
            -- showCursor(true)
            Map.init();
            CreepPool.init();
            setCharCoordinates(PLAYER_PED, Map.pos.x, Map.pos.y, Map.pos.z);
            CreepPool.spawnWave(5, 1);

            -- test creeps
            local p1, p2 = Vector3D(35, 130, 601), Vector3D(50, 130, 601);
            CreepPool.Creep:new(CreepTeam.Groove, CreepType.Melee, p1, p2);
            CreepPool.Creep:new(CreepTeam.Ballas, CreepType.Range, p2, p1);

            -- tower
            p = Vector3D(45, 125, 601);
            CreepPool.Creep:new(CreepTeam.Groove, CreepType.Tower, p);
        end);
    else
        print('NOT_SAMP');
    end
    while true do
        wait(0)
        -- Processing
        CreepPool.process();
        Camera.update();
        Camera.process();
        Controls.process();
        if (DEV) then
            local x, y, z = getCharCoordinates(PLAYER_PED);
            local px, py = convert3DCoordsToScreen(x, y, z);

            local xx, xy = convert3DCoordsToScreen(x + 1, y, z);
            renderDrawLine(px, py, xx, xy, 1, 0xFFff0000);
            
            local yx, yy = convert3DCoordsToScreen(x, y + 1, z);
            renderDrawLine(px, py, yx, yy, 1, 0xFF00ff00);
            
        end
    end
end

ImGui.OnFrame(
    function() return true or #CreepPool.pool > 0 end,
    function(thisWindow)
        UiComponent.hud();
        -- thisWindow.HideCursor = true;
        local dl = ImGui.GetBackgroundDrawList();
        for _, creep in ipairs(CreepPool.pool) do
            if (doesCharExist(creep.handle)) then
                local x, y, z = getCharCoordinates(creep.handle);
                local screenPos = ImGui.ImVec2(convert3DCoordsToScreen(x, y, z + 1));
                dl:AddText(screenPos, 0xFFFFFFFF, tostring(creep.health) .. ' HP');
            end
        end
    end
);