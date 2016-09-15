Hooks:PostHook(AmmoBagBase, "init", "HoloInit", function(self)
    self._gui = FloatingInfo:new(self._unit)
end)
Hooks:PostHook(AmmoBagBase, "destroy", "HoloDestroy", function(self)
    if self._gui then
        self._gui:destroy()
        self._gui = nil
    end
end)
Hooks:PostHook(AmmoBagBase, "update", "HoloUpdate", function(self)
    if self._gui and self._ammo_amount and self._max_ammo_amount then
        self._gui.text = string.format("%.0f", self._ammo_amount * 100) .. "%"
        self._gui.percent = self._ammo_amount / self._max_ammo_amount
    end
end)