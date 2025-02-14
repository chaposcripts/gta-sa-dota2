local imgui = require('mimgui');

local function getAbilityCooldon(index)
    local a = Player.hero.abilities[index];
    if (not a) then
        return -1;
    end

    local lastUsed = a.lastUsed or a.cooldown;
    local timeLeft = a.cooldown - (os.time() - lastUsed);
    
    return timeLeft
end

return function(frame)
    if (imgui.Begin('dota-hud', nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.AlwaysAutoResize)) then
        local dl = imgui.GetWindowDrawList();
        local fgdl = imgui.GetForegroundDrawList();
                
        local style = imgui.GetStyle();
        local padding = style.WindowPadding;
        
        local size = {
            avatar = imgui.ImVec2(150, 150),
            skill = imgui.ImVec2(75, 75),
            item = imgui.ImVec2(50, 40),
            bar = nil
        };
        size.bar = imgui.ImVec2(4 * size.skill.x + ((4 - 1) * padding.x), 20);

        
        imgui.Image(nil, size.avatar);
        
        imgui.SameLine();
        for i = 1, #Player.hero.abilities do
            local thisAbility = Player.hero.abilities[i];
            local pStart = imgui.GetCursorScreenPos();
            local cooldown = getAbilityCooldon(i);
            if (not Player.hero.abilities[i].iconUrl) then
                imgui.Button('slot' .. i, size.skill);
            else
                local t = UiComponent.imageUrl:getImage(Player.hero.abilities[i].iconUrl, true);
                imgui.Image(t, size.skill);
            end
            if (imgui.IsItemHovered()) then
                imgui.BeginTooltip();
                imgui.Text(Player.hero.abilities[i].name);
                imgui.Text(Player.hero.abilities[i].description);
                imgui.EndTooltip();
            end
            local manaCost = tostring(thisAbility.manaCost);
            fgdl:AddTextFontPtr(nil, 16, pStart + imgui.ImVec2(size.skill.x - 5 - imgui.CalcTextSize(manaCost).x, size.skill.y - 16 - 5), 0xFFff9000, tostring(thisAbility.manaCost));
            if (cooldown > 0) then
                fgdl:AddRectFilled(pStart, pStart + imgui.ImVec2(size.skill.x / thisAbility.cooldown * cooldown, size.skill.y), 0xCC000000);
                fgdl:AddTextFontPtr(nil, 20, pStart + imgui.ImVec2(size.skill.x / 2 - imgui.CalcTextSize(tostring(cooldown)).x / 2, size.skill.y / 2 - 20 / 2), 0xFFffffff, tostring(cooldown));
            end
            if (i < 4) then
                imgui.SameLine();
            end
        end
        imgui.SetCursorPos(imgui.ImVec2(size.avatar.x + padding.x * 2, size.skill.y + padding.y * 2))
        imgui.ProgressBar(Player.health / Player.hero.health.max, size.bar);
        imgui.SetCursorPos(imgui.ImVec2(size.avatar.x + padding.x * 2, size.skill.y + size.bar.y + padding.y * 3))
        imgui.ProgressBar(Player.mana / Player.hero.mana.max, size.bar);

        imgui.SetCursorPos(imgui.ImVec2(size.avatar.x + size.skill.x * 4 + padding.x * 5 + padding.y, padding.y))
        local childSize = imgui.ImVec2(size.item.x * 3 + padding.x * 4, size.item.y * 3 + padding.y * 3);
        if (imgui.BeginChild('items', childSize, true)) then
            for i = 1, 9 do
                imgui.Button('item' .. i, size.item);
                if (i %3 ~= 0) then
                    imgui.SameLine();
                end
            end
        end
        imgui.EndChild();
    end
    imgui.End();
end