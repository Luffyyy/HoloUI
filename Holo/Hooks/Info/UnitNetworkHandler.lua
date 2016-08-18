Hooks:PostHook(UnitNetworkHandler, "alarm_pager_interaction", "HoloAlarmPagerInteraction", function(self, status)
	if status == 3 and Network:is_client() then
		managers.groupai:state()._nr_successful_alarm_pager_bluffs = managers.groupai:state()._nr_successful_alarm_pager_bluffs + 1
	end
end)
