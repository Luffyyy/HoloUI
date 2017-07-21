if RequiredScript == "lib/managers/hudmanagerpd2" then
    local o_setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2
    local o_hide_mission_briefing_hud = HUDManager.hide_mission_briefing_hud
    Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "HoloPreSetupPlayerInfoHudPD2", function(self)
        if self.UpdateHolo then
            self:UpdateHolo()
            Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
        end
    end)
    Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "HoloSetupPlayerInfoHudPD2", function(self)
        local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)    
        hud.panel:panel({ 
            name = "chat_panel"
        })  
        hud.flash_icon = function(o, seconds, on_panel, no_remove)
            seconds = seconds or 4
            for i=1, seconds do
                QuickAnim:Work(o, "alpha", 0.5)
                wait(0.5)
                QuickAnim:Work(o, "alpha", 1)
                wait(0.5)
            end
            QuickAnim:Work(o, "alpha", no_remove and 1 or 0, "callback", function()
                if not no_remove then
                    on_panel = on_panel or hud
                    on_panel:remove(o)
                end
            end)
        end
        Holo.flash_icon = hud.flash_icon
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
        Hooks:PostHook(HUDManager, "show", "HoloShow", function(self, name)
            if name == Idstring("guis/mask_off_hud") then
                self:script(name).mask_on_text:hide()
                self:script(name).mask_on_text:set_alpha(0)
            end
        end)
        function HUDManager:show_switching(id, curr, total)
            if self._teammate_panels[HUDManager.PLAYER_PANEL].show_switching then
                self._teammate_panels[HUDManager.PLAYER_PANEL]:show_switching(id, curr, total)
            end
        end
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
        	local teammate_w = 204
        	local player_gap = 240
        	local h = self:teampanels_height() 
        	local small_gap = (managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel:child("teammates_panel"):w() - player_gap - teammate_w * 4) / 3
            local compact = Holo.Options:GetValue("CompactTeammate")
        	for i = 1, HUDManager.PLAYER_PANEL do
        		local is_player = i == HUDManager.PLAYER_PANEL
                if compact then
                    if not is_player then
                    local y = math.floor(24 * (HUDManager.PLAYER_PANEL - (i + 1)) - 2)
                        if self._teammate_panels[i] then
                             self._teammate_panels[i]._panel:set_y(y)
                        end
                    end
                else
                    if self._teammate_panels[i] then
                        local pw = teammate_w + (is_player and 32 or 64)
                        local x = math.floor(((pw - (is_player and 42 or 0)) + (is_player and small_gap or 10)) * (i - 1) + (i == HUDManager.PLAYER_PANEL and player_gap or 0))
                        self._teammate_panels[i]._panel:set_size(pw, h)
                        self._teammate_panels[i]._player_panel:set_size(pw, h)
                        self._teammate_panels[i]._panel:set_leftbottom(x, self._teammate_panels[i]._panel:parent():h())
                    end
                end
        	end
        end
    end
    Hooks:PostHook(HUDManager, "hide_mission_briefing_hud", "HideMissionBriefingHud", function()
        Holo.Panel:show()
    end)
    if Holo:ShouldModify("Hud", "TeammateHud") then
        Hooks:PostHook(HUDManager, "show_player_gear", "HoloShowPlayerGear", function(self, panel_id)
            if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]._player_panel then
                local panel = self._teammate_panels[panel_id]._player_panel
                if alive(panel:child("Mainbg")) then
                    panel:child("Mainbg"):set_visible((not CompactHUD and not Fallout4hud))
                    panel:parent():child("teammate_line"):set_h(panel:parent():child("name_bg"):h() + panel:child("Mainbg"):h())
                    panel:parent():child("teammate_line"):set_right(panel:child("Mainbg"):left())
                    panel:parent():child("teammate_line"):set_bottom(panel:child("Mainbg"):bottom())                
                    if self._teammate_panels[panel_id].layout_equipments then
                        self._teammate_panels[panel_id]:layout_equipments()
                    end      
                end
            end
        end)        
        Hooks:PostHook(HUDManager, "hide_player_gear", "HoloHidePlayerGear", function(self, panel_id)
            if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]._player_panel then
                local panel = self._teammate_panels[panel_id]._player_panel
                if alive(panel:child("Mainbg")) then
                    panel:child("Mainbg"):hide()
                    panel:parent():child("teammate_line"):set_h(panel:parent():child("name_bg"):h() + panel:child("Mainbg"):h())
                    panel:parent():child("teammate_line"):set_right(panel:child("Mainbg"):left())
                    panel:parent():child("teammate_line"):set_bottom(panel:child("Mainbg"):bottom())                
                    if self._teammate_panels[panel_id].layout_equipments then
                        self._teammate_panels[panel_id]:layout_equipments()
                    end      
                end
            end
        end)
    end
else
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
    end
	Hooks:PostHook(HUDManager, "set_disabled", "HoloSetDisabled", function(self)
        Holo.Panel:hide()
	end)
	Hooks:PostHook(HUDManager, "set_enabled", "HoloSetEnabled", function(self)
        if self._hud_mission_briefing and not self._hud_mission_briefing._backdrop._panel:visible() then
            Holo.Panel:show()
        end
	end)
end