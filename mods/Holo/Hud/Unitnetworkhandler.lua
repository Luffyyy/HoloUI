Holo:clone(UnitNetworkHandler)
function UnitNetworkHandler:alarm_pager_interaction(...)
	self.old.alarm_pager_interaction(self, ...)
	if status == 3 and Network:is_client() then
		managers.groupai:state()._nr_successful_alarm_pager_bluffs = managers.groupai:state()._nr_successful_alarm_pager_bluffs + 1
	end
end
