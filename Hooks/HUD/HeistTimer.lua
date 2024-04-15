if Holo:ShouldModify("HUD", "TopHUD") and Holo:ShouldModify("HUD", "Timer") then
    Holo:Post(HUDHeistTimer, "init", function(self)
        self._bg_box = HUDBGBox_create(self._heist_timer_panel)
    	self:UpdateHolo()
        Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
    end)
    Holo:Post(HUDHeistTimer, "set_time", function(self, ...)
        if Holo.Options:GetValue("RealTime") then
            self._timer_text:set_text(os.date("%X"))  
        end
    end)
    function HUDHeistTimer:UpdateHolo()
        if WolfHUD then 
            self._heist_timer_panel:set_y(2) 
        else
            self._heist_timer_panel:set_w(60)
            Holo.Utils:SetPosition(self._heist_timer_panel, "Timer")
        end
        self._heist_timer_panel:set_h(26)
        HUDBGBox_recreate(self._bg_box, {
            name = "Timer",
            w = 60,
            h = 24,
        })
        self._bg_box:set_world_center(self._heist_timer_panel:world_center())
        self._bg_box:set_visible(self._hud_panel == managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel and Holo.Options:GetValue("TimerBackground"))
        self._timer_text:configure({
            font = "fonts/font_large_mf",
            font_size = self._bg_box:h() - 2,
            vertical = "center",
            color = Holo:GetColor("TextColors/Timer")
        })
        self._timer_text:set_shape(self._bg_box:shape())
        self._timer_text:move(0, 1)
    end
end