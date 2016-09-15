Hooks:PostHook(EnvironmentFire, "on_spawn", "HoloOnSpawn", function(self)
    self._max_burn_duration = self._burn_duration
    self._gui = FloatingInfo:new(self._unit)
end)
Hooks:PostHook(EnvironmentFire, "destroy", "HoloDestroy", function(self)
    if self._gui then
        self._gui:destroy()
        self._gui = nil
    end
end)
Hooks:PostHook(EnvironmentFire, "update", "HoloUpdate", function(self)
	if self._gui then
        self._gui.text = string.format("%.2f", self._burn_duration) .. "s"
        self._gui.percent = self._burn_duration / self._max_burn_duration
	end
end)
 