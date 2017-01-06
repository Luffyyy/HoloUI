if Holo:ShouldModify("Hud", "HudBox") then
    Hooks:PostHook(HUDHeistTimer, "init", "HoloInit", function(self)
        self._bg_box = HUDBGBox_create(self._heist_timer_panel)
    	self:UpdateHolo()
        Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
    end)
    Hooks:PostHook(HUDHeistTimer, "set_time", "HoloSetTime", function(self, ...)
        if Holo.Options:GetValue("Extra/RealTime") then
            self._timer_text:set_text(os.date("%X"))  
        end
    end)
    function HUDHeistTimer:UpdateHolo()
        if WolfHUD then 
            self._heist_timer_panel:set_world_center_y(managers.hud._hud_objectives._bg_box:world_center_y()) 
        else
            self._heist_timer_panel:set_world_center_x(self._heist_timer_panel:parent():world_center_x())
        end
        self._heist_timer_panel:set_h(26)
        HUDBGBox_recreate(self._bg_box, {
            name = "TimerBackground",
            w = 60,
            h = 24,
        })
        self._bg_box:set_world_center(self._heist_timer_panel:world_center())
        self._bg_box:set_visible(self._hud_panel == managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel and Holo.Options:GetValue("Extra/TimerBackground"))
        self._timer_text:configure({
            font = "fonts/font_medium_noshadow_mf",
            font_size = self._bg_box:h() - 2,
            color = Holo:GetColor("TextColors/TimerBox")
        })
    end
end
