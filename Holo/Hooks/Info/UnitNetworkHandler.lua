Hooks:PostHook(UnitNetworkHandler, "alarm_pager_interaction", "HoloAlarmPagerInteraction", function(self, status)
	if status == 3 and Network:is_client() then
		managers.groupai:state()._nr_successful_alarm_pager_bluffs = managers.groupai:state()._nr_successful_alarm_pager_bluffs + 1
	end
end)
--[[function UnitNetworkHandler:long_dis_interaction(target_unit, amount, aggressor_unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(target_unit) or not self._verify_character(aggressor_unit) then
		return
	end
	local target_is_criminal = target_unit:in_slot(managers.slot:get_mask("criminals")) or target_unit:in_slot(managers.slot:get_mask("harmless_criminals"))
	local target_is_civilian = not target_is_criminal and target_unit:in_slot(21)
	local aggressor_is_criminal = aggressor_unit:in_slot(managers.slot:get_mask("criminals")) or aggressor_unit:in_slot(managers.slot:get_mask("harmless_criminals"))
	if target_is_criminal then
		if aggressor_is_criminal then
			if target_unit:brain() then
				if target_unit:brain().on_long_dis_interacted then
					target_unit:movement():set_cool(false)
					target_unit:brain():on_long_dis_interacted(amount, aggressor_unit)
				end
			elseif amount == 1 then
				log("Shout!")
				target_unit:movement():on_morale_boost(aggressor_unit)
			end
		else
			target_unit:brain():on_intimidated(amount / 10, aggressor_unit)
		end
	elseif amount == 0 and target_is_civilian and aggressor_is_criminal then
		if self._verify_in_server_session() then
			aggressor_unit:movement():sync_call_civilian(target_unit)
		end
	elseif target_unit:brain() then
		target_unit:brain():on_intimidated(amount / 10, aggressor_unit)
	end
end]]