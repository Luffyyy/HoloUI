if not Holo:ShouldModify("Menu", "PlayerProfile") then
	return
end

Holo:Post(PlayerProfileGuiObject, "init", function(self)
    --Because whoever made this script in ovk couldn't include names best I can do is recreate it.
    for _, child in pairs(self._panel:children()) do
        child:hide()
    end

    --Avatar			
    local avatar = self._panel:bitmap({
        name = "Avatar",
        texture = "guis/textures/pd2/none_icon",
        x = 4,
        y = 4,
        w = 86,
        h = 86,
    })

    local steam_id = Steam:userid()
    Steam:friend_avatar(Steam.LARGE_AVATAR, steam_id, function(texture)
        avatar:animate(function()
            wait(0.25)
            Steam:friend_avatar(Steam.LARGE_AVATAR, steam_id, function(texture)
                avatar:set_image(texture or "guis/textures/pd2/none_icon")
            end)
        end)
    end)
    local font = tweak_data.menu.pd2_large_font
    local font_size = tweak_data.menu.pd2_small_font_size
    local prev
    local function createText(name, text, belowprev, icon_data)
        local panel = self._panel:panel({
            name = name,
            x = avatar:right() + 8,
            y = prev and prev:y() or avatar:y()
        })
        local icon
        if icon_data then
            icon = panel:bitmap({
                name = "Icon",
                texture = icon_data.texture,
                texture_rect = icon_data.texture_rect,
                w = icon_data.w or font_size,
                h = icon_data.h or font_size,
            })
        end
        local text = panel:text({
            name = "Text",
            text = text,
            font = font,				
            font_size = font_size,
            color = Holo:GetColor("TextColors/Menu"),
            x = icon and icon:right() + 2 or 0,
        })
        WalletGuiObject.make_fine_text(text)
        if icon then
            icon:set_center_y(text:center_y())
        end
        panel:set_size(text:right(), text:h())
        if prev then
            if belowprev then
                panel:set_y(prev:bottom() + 4)
            else
                panel:set_x(prev:right() + 8)
            end
        end
        prev = panel
        return panel
    end

    --name and level
    createText("Name", tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name()))
    local player_level = managers.experience:current_level()
    local player_rank = managers.experience:current_rank()
    local wallet_icon = {texture = "guis/textures/pd2/shared_level_symbol", w = font_size - 4, h = font_size - 4}

    createText("Level", (player_rank > 0 and managers.experience:rank_string(player_rank) .. "-" or "") .. tostring(player_level), true, wallet_icon)
    --coins / skill points
    local skillpoints = managers.skilltree:points()
    if skillpoints > 0 then
        wallet_icon.texture = "guis/textures/pd2/shared_skillpoint_symbol"
        createText("SkillPoints", tostring(skillpoints), nil, wallet_icon)
    end
    
    --cash
    wallet_icon.texture = "guis/textures/pd2/shared_wallet_symbol"
    createText("Cash", managers.money:total_string_no_currency(), true, wallet_icon)
    createText("OffshoreCash", managers.experience:cash_string(managers.money:offshore(), ""), nil, wallet_icon)

            
    --skills and perk
    local aspect_ratio = (22 / 31)
    local icon = {texture = "guis/textures/pd2/inv_skillcards_icons", texture_rect = {0, 0, 22, 31}, w = aspect_ratio * font_size, h = font_size}
    local mp, mns = managers.skilltree:get_tree_progress_2("mastermind")
    local ep, ens = managers.skilltree:get_tree_progress_2("enforcer")
    local tp, tns = managers.skilltree:get_tree_progress_2("technician")
    local gp, gns = managers.skilltree:get_tree_progress_2("ghost")
    local fp, fns = managers.skilltree:get_tree_progress_2("hoxton")

    local skills_prev = prev
    local mastermind = createText("Mastermind", tostring(mp), true, icon)
    icon.texture_rect[1] = 24
    createText("Enforcer", tostring(ep), nil, icon)
    icon.texture_rect[1] = 48
    createText("Technician", tostring(tp), nil, icon)
    icon.texture_rect[1] = 72
    createText("Ghost", tostring(gp), nil, icon)
    icon.texture_rect[1] = 96
    createText("Fugitive", tostring(fp), nil, icon)
            
    --Frame
    local box = self._panel:child("BoxGui")
    if alive(box) then
        self._panel:remove(box)		
    end
    BoxGuiObject:new(self._panel, {sides = {
        2,
        0,
        0,
        0
    }})

    self._panel:set_h(avatar:h() + 8)
    self._panel:set_bottom(self._panel:parent():h() - 50)
end)