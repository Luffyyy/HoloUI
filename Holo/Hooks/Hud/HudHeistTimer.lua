if Holo.Options:GetValue("Base/Hud") and Holo.Options:GetValue("TopHud") then
    Hooks:PostHook(HUDHeistTimer, "init", "HoloInit", function(self)
        self._heist_timer_panel:grow(0, 100)
        self._bg_box = HUDBGBox_create(self._heist_timer_panel)
    	self:UpdateHoloHUD()
    end)

    function HUDHeistTimer:UpdateHoloHUD()
        local scale = Holo.Options:GetValue("HudScale")
        HUDBGBox_recreate(self._bg_box, {
            w = 60 * scale,
            h = 25 * scale,
            color = Holo:GetColor("Colors/TimerBox"),
        })
        self._bg_box:set_center_x(self._timer_text:center_x())
        self._bg_box:set_visible( Holo.Options:GetValue("TimerBackground"))
        self._timer_text:set_font_size(24 * scale)
        self._timer_text:set_color(Holo:GetColor("TextColors/TimerBox"))
    end
end
