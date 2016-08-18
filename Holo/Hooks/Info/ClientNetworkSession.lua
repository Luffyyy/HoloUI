Hooks:PreHook(ClientNetworkSession, "send_to_host", "HoloSendToHost", function (self, ...)
	local sent_tbl = {...}
	if tbl and (tbl[3] and tbl[3] == "corpse_alarm_pager") and (tbl[4] and tbl[4] == 3) then
		managers.groupai:state()._nr_successful_alarm_pager_bluffs = managers.groupai:state()._nr_successful_alarm_pager_bluffs + 1
	end
end)
