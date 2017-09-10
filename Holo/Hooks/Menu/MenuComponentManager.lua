Holo:Post(BLTDownloadManagerGui, "_setup", function(self)
    Holo.Utils:FixBackButton(self, self._back_button)
    self._fullscreen_panel:child("back_button"):hide()
end)
Holo:Post(BLTModsGui, "_setup", function(self)
    Holo.Utils:FixBackButton(self, self._back_button)
    self._fullscreen_panel:child("back_button"):hide()
end)

Holo:Post(BLTNotificationsGui, "_setup", function(self)
    self._content_panel:child("background"):hide()
    self._content_panel:child(1):hide()
end)

Holo:Post(MutatorItem, "init", function(self, panel, mutator, index)
    Holo.Utils:SetBlendMode(panel)
    self._title_text:set_color(Holo:GetColor("TextColors/Menu"))
    self._desc_text:set_color(Holo:GetColor("TextColors/Menu"))
    self._select_rect:set_color(Holo:GetColor("Colors/Marker"))
    self._select_rect:set_alpha(0.1)
end)

Holo:Post(MutatorItem, "refresh", function(self)
    self._select_rect:set_color(Holo:GetColor("Colors/Marker"))
end)

Holo:Post(CrimeSpreeStartingLevelItem, "init", function(self, parent, data)
    Holo.Utils:SetBlendMode(self._panel)
    self._active_bg:set_color(Holo:GetColor("Colors/Marker"))
    self._highlight:set_color(Holo:GetColor("Colors/Marker"))
    self._level_bg:set_w(0)
end)

Holo:Post(MenuComponentManager, "play_transition", function(self, run_in_pause)
    if Holo:ShouldModify("Menu", "Loading") then
        self._transition_panel:child("fade1"):set_color(Holo:GetColor("Colors/Menu"))
    end
end)