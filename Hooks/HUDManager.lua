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
end)

if Holo.Options:GetValue("HUD") then
    function HUDManager:UpdateHolo()
        managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect, Holo.Options:GetValue("HUDScale"), Holo.Options:GetValue("HUDSpacing"))
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
    Holo:Post(HUDManager, "update", function(self)
        local chatgui = managers.menu_component._game_chat_gui
        local stage = self._hud_stage_endscreen
        if (stage and stage._backdrop and alive(stage._backdrop._panel) and stage._backdrop._panel:visible()) or chatgui and chatgui:enabled() then
            local chat = self._hud_chat_ingame
            if alive(chat._panel) then
                local output_panel = chat._panel:child("output_panel")
                output_panel:stop()
                output_panel:set_alpha(0)
                chat._input_panel:set_alpha(0)
            end
        end
    end)
end

if Holo:ShouldModify("HUD", "Teammate") then

    if Holo.Options:GetValue("AltTeammate") then
        function HUDManager:show_player_gear(panel_id)
            local tm = self._teammate_panels[panel_id]        
            if tm and alive(tm._player_panel) then
                if tm.UpdateHolo and tm._forced_compact then
                    tm._forced_compact = false
                    tm:UpdateHolo()
                end
            end
        end

        Holo:Post(HUDManager, "hide_player_gear", function(self, panel_id)
            local tm = self._teammate_panels[panel_id]        
            if tm and alive(tm._player_panel) then
                if tm.UpdateHolo and not tm._forced_compact then
                    tm._forced_compact = true
                    tm:UpdateHolo()     
                end
            end
        end)

        function HUDManager:align_teammate_panels_resize(tm, me)
            local me = tm._id == HUDManager.PLAYER_PANEL
            local avatar = Holo.Options:GetValue("ShowAvatar")
            local compact_ai = Holo.Options:GetValue("CompactAI")
            local compact_tm = Holo.Options:GetValue("CompactTeammate")

            if not me then
                avatar = Holo.Options:GetValue("ShowTeammatesAvatar")
            end

            local w = tm:GetNameWidth()
            local compact = tm._forced_compact or ((tm._ai and compact_ai) or (not me and compact_tm))
            local ph = (compact and (me and 48 or 36) or (me and 86 or tm._ai and 50 or 70)) + tm._equipments_h
            local pw = (avatar and (ph - tm._equipments_h) + 4 or 8) + math.max(w + 8, me and 132 or 106)
            tm._panel:set_size(pw, ph)
            tm._player_panel:set_size(pw, ph)
        end

        HUDManager.TEAMMATE_PANELS_OFFSET = 4
    else
        Holo:Post(HUDManager, "show_player_gear", function(self, panel_id)
            local tm = self._teammate_panels[panel_id]        
            if tm and alive(tm._player_panel) then
                tm._player_panel:child("Mainbg"):show()
            end
        end)

        Holo:Post(HUDManager, "hide_player_gear", function(self, panel_id)
            local tm = self._teammate_panels[panel_id]        
            if tm and alive(tm._player_panel) then
                tm._player_panel:child("Mainbg"):hide()
            end
        end)

        function HUDManager:align_teammate_panels_resize(tm, me)
            local bg = tm._player_panel:child("Mainbg")
            local name = tm._panel:child("Namebg")
            local w = bg:right()
            local h = tm:calc_panel_height()
            tm._panel:set_size(w, h)
            tm._player_panel:set_size(w, h)        
        end

        HUDManager.TEAMMATE_PANELS_OFFSET = 16
    end

    function HUDManager:teampanels_height()
        return managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:h()
    end

    function HUDManager:align_teammate_panels()
        local main_tm = self._teammate_panels[HUDManager.PLAYER_PANEL]
        if not main_tm then
            return
        end

        local me_align_method = Holo.TMPositions[Holo.Options:GetValue("Positions/MyTeammatePan")]
        local align_method = Holo.TMPositions[Holo.Options:GetValue("Positions/TeammatesPan")]
        local prev

        local sorted = clone(self._teammate_panels)
        table.remove(sorted)
        table.sort(sorted, function(a,b)
            return (not a._ai and b._ai)
        end)

        local function align(tm)
            local me = tm._id == HUDManager.PLAYER_PANEL
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
                        tm._panel:set_bottom(prev._panel:y() - HUDManager.TEAMMATE_PANELS_OFFSET)
                    elseif pos == "left" then
                        tm._panel:set_x(prev._panel:right() + HUDManager.TEAMMATE_PANELS_OFFSET)
                    else
                        tm._panel:set_right(prev._panel:x() - HUDManager.TEAMMATE_PANELS_OFFSET)
                    end
                end
                prev = tm
            end
        end

        self:align_teammate_panels_resize(main_tm)
        align(main_tm)
        for _, tm in pairs(sorted) do
            self:align_teammate_panels_resize(tm)
        end
        for _, tm in pairs(sorted) do
            align(tm)
        end
        if self._hud_temp and self._hud_temp.SetPositionByTeammate then
            self._hud_temp:SetPositionByTeammate()
        end
    end
end

if Holo:ShouldModify("HUD", "Waypoints") then
    HUDManager.no_color_waypoints = {"wp_calling_in_hazard", "wp_calling_in"}
    Holo:Replace(HUDManager, "add_waypoint", function(self, orig, id, data, ...)
        data.blend_mode = "normal"
        if Holo.Options:GetValue("ColorWaypoints") then
            data.icon = data.icon == "wp_suspicious" and "pd2_question" or data.icon == "wp_detected" and "pd2_generic_look" or data.icon
        end
        orig(self, id, data, ...)
        local waypoint = self._hud.waypoints[id]
        if waypoint then
            waypoint.icon = data.icon
            self:holo_update_waypoint(waypoint, data.icon)
        end
    end)

    function HUDManager:holo_update_waypoint(data, icon)
        if not data or not alive(data.bitmap) then
            return
        end

        local color = Holo.Options:GetValue("ColorWaypoints") and Holo:GetColor("Colors/Waypoints") or nil
        local alpha = Holo.Options:GetValue("WaypointsAlpha")

        data.alpha = alpha

        local distance = data.distance
        local bitmap = data.bitmap
        local arrow = data.arrow

        if alive(distance) then
            distance:configure({
                color = color,
                font = "fonts/font_large_mf",
                font_size = 32
            })
        end

        bitmap:set_alpha(alpha)
        arrow:set_alpha(alpha)
        for _, disallowed_icon in pairs(HUDManager.no_color_waypoints) do
            if disallowed_icon == icon then
                return
            end
        end
        if color then
            bitmap:set_color(color)
            arrow:set_color(color)
        end 
    end

    function HUDManager:waypoints_update()
        for _, data in pairs(self._hud.waypoints) do
            self:holo_update_waypoint(data, data.icon)
        end
    end

    Holo:Replace(HUDManager, "change_waypoint_icon", function(self, orig, id, icon, ...)
        if Holo.Options:GetValue("ColorWaypoints") then        
            icon = icon == "wp_suspicious" and "pd2_question" or icon == "wp_detected" and "pd2_generic_look" or icon
        end
        orig(self, id, icon, ...)
        local waypoint = self._hud.waypoints[id]
        if waypoint then
            waypoint.icon = icon
            self:holo_update_waypoint(waypoint, icon)
        end
    end)
end