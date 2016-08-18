Hooks:PostHook(CarryData, "init", "HoloInit", function(self, unit)
	if self._carry_id then	
		if tweak_data.carry[self._carry_id].bag_value then
			Holo:AddLoot(string.pretty(self._carry_id, true), unit)
		end
	end
end)
Hooks:PostHook(CarryData, "update", "HoloUpdate", function(self)
	if not self._unit:enabled() then
		Holo:RemoveLoot(string.pretty(self._carry_id, true), self._unit)
	end
end)
Hooks:PostHook(CarryData, "destroy", "HoloDestroy", function(self)
	Holo:RemoveLoot(string.pretty(self._carry_id, true), self._unit)
end) 
