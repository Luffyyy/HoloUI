SmallLootBase = SmallLootBase or class(UnitBase)
Hooks:PostHook(SmallLootBase, "init", "HoloInit", function(self, unit)
	Holo:AddLoot("SmallLoot", unit)
end)
Hooks:PreHook(SmallLootBase, "_set_empty", "HoloSetEmpty", function(self)
	Holo:RemoveLoot("SmallLoot", self._unit)
end)
function SmallLootBase:on_unit_set_enabled(enabled)
	if enabled then
		Holo:AddLoot("SmallLoot", self._unit)
	end
end