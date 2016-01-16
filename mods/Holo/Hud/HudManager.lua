if RequiredScript == "lib/managers/hudmanagerpd2" then
    dofile("mods/holo/hud/hudvoice.lua")
    dofile("mods/holo/hud/hudinfo.lua")     
    local o_setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2
    local o_hide_mission_briefing_hud = HUDManager.hide_mission_briefing_hud
    function HUDManager:_setup_player_info_hud_pd2(...)
        o_setup_player_info_hud_pd2(self, ...)
        if Infohud_enable then
            Holo._hudinfo = HUDInfo:new(managers.gui_data:create_fullscreen_workspace():panel())
        end
        if Holo.options.voice_enable then
            Holo._hudvoice = HUDVoice:new(managers.gui_data:create_fullscreen_workspace())
        end   
    end
    function HUDManager._create_hud_chat_access() end   
    function HUDManager:hide_mission_briefing_hud(...)
        o_hide_mission_briefing_hud(self, ...)
        if self._hud_mission_briefing then
            self._hud_mission_briefing:hide()
            self._mission_briefing_hidden = true
        end
    end
     function HUDManager:show_player_gear(panel_id)
        if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
            local player_panel = self._teammate_panels[panel_id]:panel():child("player")
            local teammate_panel = self._teammate_panels[panel_id]:panel()
            player_panel:child("weapons_panel"):set_visible(true)
            player_panel:child("deployable_equipment_panel"):set_visible(true)
            player_panel:child("cable_ties_panel"):set_visible(true)
            player_panel:child("grenades_panel"):set_visible(true)
            if alive(player_panel:child("Mainbg")) then
                player_panel:child("Mainbg"):set_visible(true)
            end            
            if alive(player_panel:child("EquipmentsBG")) then
                player_panel:child("EquipmentsBG"):set_visible(true)
                if alive(teammate_panel:child("teammate_line")) then
                    teammate_panel:child("teammate_line"):set_h(teammate_panel:child("name_bg"):h() + player_panel:child("EquipmentsBG"):h())
                    teammate_panel:child("teammate_line"):set_right(player_panel:child("EquipmentsBG"):left())
                    teammate_panel:child("teammate_line"):set_bottom(player_panel:child("EquipmentsBG"):bottom())
                end
            end
        end
        self._teammate_panels[panel_id]._cable_ties_visible = true
        self._teammate_panels[panel_id]._deployable_visible = true
        self._teammate_panels[panel_id]:layout_equipments()
    end
    function HUDManager:hide_player_gear(panel_id)
    if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
        local player_panel = self._teammate_panels[panel_id]:panel():child("player")
        local teammate_panel = self._teammate_panels[panel_id]:panel()
        player_panel:child("weapons_panel"):set_visible(false)
        player_panel:child("deployable_equipment_panel"):set_visible(false)
        player_panel:child("cable_ties_panel"):set_visible(false)
        player_panel:child("grenades_panel"):set_visible(false)
        if alive(player_panel:child("selfBG")) then
            player_panel:child("selfBG"):set_visible(false)
        end            
        if alive(player_panel:child("EquipmentsBG")) then
            player_panel:child("EquipmentsBG"):set_visible(false)
            if alive(teammate_panel:child("teammate_line")) then
                teammate_panel:child("teammate_line"):set_h(teammate_panel:child("name_bg"):h())
                teammate_panel:child("teammate_line"):set_right(teammate_panel:child("name_bg"):left())
                teammate_panel:child("teammate_line"):set_bottom(teammate_panel:child("name_bg"):bottom())
            end        
        end
        self._teammate_panels[panel_id]._cable_ties_visible = false
        self._teammate_panels[panel_id]._deployable_visible = false
        self._teammate_panels[panel_id]:layout_equipments()
    end
end
elseif Holo.options.waypoints_enable then
    Holo:clone(HUDManager)
    function HUDManager:add_waypoint(id, data)       
        data.blend_mode = "normal"        
        data.icon = data.icon == "wp_suspicious" and "pd2_question" or data.icon == "wp_detected" and "pd2_generic_look" or data.icon
        self.old.add_waypoint(self, id, data)
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
            bitmap:set_color(Waypoint_color)
            arrow:set_color(Waypoint_color)            

        end            
        bitmap:set_alpha(waypoints_alpha)
        arrow:set_alpha(waypoints_alpha)
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
                    data.bitmap:set_color(Waypoint_color)
                    data.arrow:set_color(Waypoint_color)
                else
                    data.bitmap:set_color(Color.white)
                    data.arrow:set_color(Color.white)                        

                end                    
                data.bitmap:set_alpha(waypoints_alpha)
                data.arrow:set_alpha(waypoints_alpha)
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
            data.bitmap:set_color(Waypoint_color)
            data.arrow:set_color(Waypoint_color)
        else
            data.bitmap:set_color(Color.white)
            data.arrow:set_color(Color.white)           
        end
        data.bitmap:set_alpha(waypoints_alpha)
        data.arrow:set_alpha(waypoints_alpha)
    end
 
end

 