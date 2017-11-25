if not Holo.Options:GetValue("Menu") then
	return
end

Holo:Post(MenuComponentManager, "register_component", function(self, name, component)
    Holo.Utils:FixBackButton(component)
end)

Holo:Post(BLTDownloadManagerGui, "_setup", function(self)
    Holo.Utils:FixBackButton(self, self._back_button)
    Holo.Utils:SetBlendMode(self._panel)
    Holo.Utils:SetBlendMode(self._scroll:canvas())
end)

Holo:Post(BLTModsGui, "_setup", function(self)
    Holo.Utils:FixBackButton(self, self._back_button)
end)

Holo:Post(BLTNotificationsGui, "_setup", function(self)
    self._content_panel:child("background"):hide()
    self._content_panel:child(1):hide()
    self._content_outline:hide()
    local box = self._content_panel:child("BoxGui")
    if alive(box) then
        self._content_panel:remove(box)
    end
    BoxGuiObject:new(self._content_panel, {sides = {
        2,
        0,
        0,
        0
    }})
end)

Holo:Post(BLTNotificationsGui, "add_notification", function(self)
    for _, notif in ipairs(self._notifications) do
        if alive(notif.panel) then
            for _, child in pairs(notif.panel:children()) do
                if type_name(child) == "Text" and child:color() == Color.white then
                    child:set_color(tweak_data.screen_colors.text)
                end
            end
        end
    end
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
    if Holo.Options:GetValue("Menu") and Holo.Options:GetValue("ColoredBackground") then
        self._transition_panel:child("fade1"):set_color(Holo:GetColor("Colors/Menu"))
    end
end)

Holo:Post(BLTViewModGui, "_setup_buttons", function(self)
    Holo.Utils:SetBlendMode(self._panel)
end)

Holo:Post(BLTDownloadControl, "init", function(self)
    Holo.Utils:SetBlendMode(self._panel)
end)