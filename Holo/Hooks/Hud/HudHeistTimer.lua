if Holo.Options:GetValue("Base/Hud") and Holo.Options:GetValue("TopHud") then
    Hooks:PostHook(HUDHeistTimer, "init", "HoloInit", function(self)
        self._bg_box = HUDBGBox_create(self._heist_timer_panel)
    	self:UpdateHolo()
    end)

    function HUDHeistTimer:UpdateHolo()
        self._heist_timer_panel:set_world_center_x(self._heist_timer_panel:parent():world_center_x())
        HUDBGBox_recreate(self._bg_box, {
            w = 60,
            h = 25,
            color = Holo:GetColor("Colors/TimerBox"),
        })
        self._bg_box:set_center_x(self._timer_text:center_x())
        self._bg_box:set_visible(Holo.Options:GetValue("TimerBackground"))
        self._timer_text:set_color(Holo:GetColor("TextColors/TimerBox"))
        self._timer_text:set_font_size(24)
    end
end
