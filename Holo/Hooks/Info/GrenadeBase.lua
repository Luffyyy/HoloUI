Hooks:PostHook(GrenadeBase, "init", "HoloInit", function(self)
    self._gui = FloatingInfo:new(self._unit)
end)
Hooks:PostHook(GrenadeBase, "destroy", "HoloDestroy", function(self)
    if self._gui then
        self._gui:destroy()
        self._gui = nil
    end
end)
Hooks:PostHook(GrenadeBase, "update", "HoloUpdate", function(self)
	if self._gui and self._timer then
        self._gui.text = string.format("%.2f", self._timer) .. "s"
        self._gui.percent = self._timer / self._init_timer
	end
end)
  