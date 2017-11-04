local o_setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2
local o_hide_mission_briefing_hud = HUDManager.hide_mission_briefing_hud
Holo:Pre(HUDManager, "_setup_player_info_hud_pd2", function(self)
    if self.UpdateHolo then
        self:UpdateHolo()
        Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
    end
end)

Holo:Post(HUDManager, "_setup_player_info_hud_pd2", function(self)
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)    
    hud.panel:panel({name = "chat_panel"})  
    if Holo.Options:GetValue("Voice") then
        Holo.Voice:Init()
    end
end)

if Holo.Options:GetValue("Hud") then
    function HUDManager:UpdateHolo()
        managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect, Holo.Options:GetValue("HudScale"), Holo.Options:GetValue("HudSpacing"))
        if self.waypoints_update then
            self:waypoints_update()
        end
    end
    Holo:Post(HUDManager, "show", function(self, name)
        if name == Idstring("guis/mask_off_hud") then
            self:script(name).mask_on_text:hide()
            self:script(name).mask_on_text:set_alpha(0)
        end
    end)
end

if Holo.Options:GetValue("Chat") then
    function HUDManager._create_hud_chat_access()
    end
end

if Holo:ShouldModify("Hud", "TeammateHud") then
    function HUDManager:_create_teammates_panel(hud)
        hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
        self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
        self._teammate_panels = {}
        if hud.panel:child("teammates_panel") then
            hud.panel:remove(hud.panel:child("teammates_panel"))
        end
        local h = self:teampanels_height()
        local teammates_panel = hud.panel:panel({
            name = "teammates_panel",
            halign = "grow",
            valign = "bottom"
        })
        local teammate_w = 204
        local player_gap = 240
        local small_gap = (teammates_panel:w() - player_gap - teammate_w * 4) / 3
        for i = 1, HUDManager.PLAYER_PANEL do
            local is_player = i == HUDManager.PLAYER_PANEL
            self._hud.teammate_panels_data[i] = {
                taken = false,
                special_equipments = {}
            }
            local pw = teammate_w + (is_player and 0 or 64)
            local teammate = HUDTeammate:new(i, teammates_panel, is_player, pw)
            local x = math.floor((pw + small_gap) * (i - 1) + (i == HUDManager.PLAYER_PANEL and player_gap or 0))
            teammate._panel:set_x(x)
            table.insert(self._teammate_panels, teammate)
            if is_player then
                teammate:add_panel()
            end
        end
    end

	function HUDManager:align_teammate_panels()
        local main_tm = self._teammate_panels[HUDManager.PLAYER_PANEL]
        if not main_tm then
            return
        end

        local me_align_method = Holo.TMPositions[Holo.Options:GetValue("Positions/MainTeammatePanel")]
        local align_method = Holo.TMPositions[Holo.Options:GetValue("Positions/TeammatesPanel")]
        local avatar_enabled = Holo.Options:GetValue("ShowAvatar")
        local avatar_enabled_tm = Holo.Options:GetValue("ShowTeammatesAvatar")
        local compact_ai = Holo.Options:GetValue("CompactAI")
        local compact_tm = Holo.Options:GetValue("CompactTeammate")
        local prev
        local align_bag = main_tm
    
        local sorted = clone(self._teammate_panels)
        table.remove(sorted)
        table.sort(sorted, function(a,b)
            return (not a._ai and b._ai)
        end)
    
        local function align(tm, i)
			local me = tm._id == HUDManager.PLAYER_PANEL
			if not me then
				avatar_enabled = avatar_enabled_tm
			end
            local w = tm:GetNameWidth()
            local compact = tm._forced_compact or ((tm._ai and compact_ai) or (not me and compact_tm))
            local pw = math.max(w, me and 124 or 72) + (avatar_enabled and 108 or 40)
            local ph = compact and (me and 48 or 36) or (me and 86 or 64)
            tm._panel:set_size(pw, ph)
            tm._player_panel:set_size(pw, ph)
            if me then
                tm._panel:set_leftbottom(0, tm._panel:parent():h())
                if me_align_method == "center" then
                    tm._panel:set_center_x(tm._panel:parent():w() / 2)
                elseif me_align_method == "right" then
                    tm._panel:set_right(tm._panel:parent():w())
                end
            else
                local splt = string.split(align_method, "_")
                local pos, way = splt[1], splt[2]
                local going_up = way == "top"
				local equal_pos = pos == me_align_method				
                local w = tm._panel:parent():w()
    
				tm._panel:set_bottom(tm._panel:parent():h())
				if pos == "left" then
					tm._panel:set_x(0)
				elseif pos == "center" then
					tm._panel:set_center_x(w / 2 + (way ~= "top" and 220 or 0))
				else
					tm._panel:set_right(w)
				end
                if equal_pos and not prev then
                    prev = main_tm
                end
                if prev then
                    if going_up then
                        local prev_ground = prev._equipments_ground or prev._panel:y()
                        tm._panel:set_bottom(prev_ground - 4)
                    elseif pos == "left" then
                        tm._panel:set_x(prev._panel:right() + 4)
                    else
                        tm._panel:set_right(prev._panel:x() - 4)
                    end
                end
                if equal_pos and going_up then
                    align_bag = false
                end
                prev = tm
            end
        end
        align(main_tm)
        for i, tm in pairs(sorted) do
            align(tm, i)
        end
        if self._hud_temp and self._hud_temp.SetPositionByTeammate then
            self._hud_temp:SetPositionByTeammate(align_bag)
        end
    end
    
    Holo:Post(HUDManager, "show_player_gear", function(self, panel_id)
        if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]._player_panel then
            local tm = self._teammate_panels[panel_id]
            if tm.UpdateHolo then
                tm._forced_compact = false
                tm:UpdateHolo()
            end
        end
    end)

    Holo:Post(HUDManager, "hide_player_gear", function(self, panel_id)
        if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]._player_panel then
            local tm = self._teammate_panels[panel_id]
            if tm.UpdateHolo then
                tm._forced_compact = true
                tm:UpdateHolo()     
            end
        end
    end)
end

Holo:Post(HUDManager, "hide_mission_briefing_hud", function()
    Holo.Panel:show()
end)

if Holo:ShouldModify("Hud", "Waypoints") then
    local o_add_waypoint = HUDManager.add_waypoint
    function HUDManager:add_waypoint(id, data)
        data.blend_mode = "normal"
        data.icon = data.icon == "wp_suspicious" and "pd2_question" or data.icon == "wp_detected" and "pd2_generic_look" or data.icon
        o_add_waypoint(self, id, data)
        local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
        local waypoint_panel = hud.panel
        local arrow = waypoint_panel:child("arrow".. id)
        local bitmap = waypoint_panel:child("bitmap".. id)
        if data.distance then
            local distance = waypoint_panel:child("distance".. id)
            distance:set_color(Color(0.8,0.8,0.8))
            distance:set_font(Idstring("fonts/font_large_mf"))
            distance:set_font_size(32)
        end

        self._nocoloring = {
            "wp_calling_in_hazard",
            "wp_calling_in"
        }
        local cancolor = true
        for _,icon in pairs(self._nocoloring) do
            if data.icon == icon then
                cancolor = false
            end
        end
        if cancolor then
            bitmap:set_color(Holo:GetColor("Colors/Waypoints"))
            arrow:set_color(Holo:GetColor("Colors/Waypoints"))

        end
        bitmap:set_alpha(Holo.Options:GetValue("WaypointsAlpha"))
        arrow:set_alpha(Holo.Options:GetValue("WaypointsAlpha"))
    end
    function HUDManager:waypoints_update()
        for _, data in pairs(self._hud.waypoints) do
            if data.bitmap then
                local cancolor = true
                for _,icon in pairs(self._nocoloring) do
                    if data.icon == icon then
                        cancolor = false
                    end
                end
                if cancolor then
                    data.bitmap:set_color(Holo:GetColor("Colors/Waypoints"))
                    data.arrow:set_color(Holo:GetColor("Colors/Waypoints"))
                else
                    data.bitmap:set_color(Color.white)
                    data.arrow:set_color(Color.white)
                end
                data.bitmap:set_alpha(Holo.Options:GetValue("WaypointsAlpha"))
                data.arrow:set_alpha(Holo.Options:GetValue("WaypointsAlpha"))
            end
        end
    end
    function HUDManager:change_waypoint_icon(id, icon)
        if not self._hud.waypoints[id] then
            Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)
            return
        end
        icon = icon == "wp_suspicious" and "pd2_question" or icon == "wp_detected" and "pd2_generic_look" or icon

        local data = self._hud.waypoints[id]
        local texture, rect = tweak_data.hud_icons:get_icon_data(icon, {
            0,
            0,
            32,
            32
        })
        data.bitmap:set_image(texture, rect[1], rect[2], rect[3], rect[4])
        data.bitmap:set_size(rect[3], rect[4])
        data.size = Vector3(rect[3], rect[4])
        local cancolor = true
        for _,Icon in pairs(self._nocoloring) do
            if icon == Icon then
                cancolor = false
            end
        end
        if cancolor then
            data.bitmap:set_color(Holo:GetColor("Colors/Waypoints"))
            data.arrow:set_color(Holo:GetColor("Colors/Waypoints"))
        else
            data.bitmap:set_color(Color.white)
            data.arrow:set_color(Color.white)
        end
        data.bitmap:set_alpha(Holo.Options:GetValue("WaypointsAlpha"))
        data.arrow:set_alpha(Holo.Options:GetValue("WaypointsAlpha"))
    end
	Holo:Post(HUDManager, "set_disabled", function(self)
        Holo.Panel:hide()
	end)
	Holo:Post(HUDManager, "set_enabled", function(self)
        if self._hud_mission_briefing and not self._hud_mission_briefing._backdrop._panel:visible() then
            Holo.Panel:show()
        end
	end)
end