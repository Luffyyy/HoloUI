Hooks:PostHook(DoctorBagBase, "init", "HoloInit", function(self)
    self._gui = FloatingInfo:new(self._unit)
end)
Hooks:PostHook(DoctorBagBase, "destroy", "HoloDestroy", function(self)
    if self._gui then
        self._gui:destroy()
        self._gui = nil
    end
end)
Hooks:PostHook(DoctorBagBase, "update", "HoloUpdate", function(self)
    if self._gui and self._amount then
        self._gui.text = string.format("%s / %s", self._amount, self._max_amount)
        self._gui.percent = self._amount / self._max_amount
    end
end)