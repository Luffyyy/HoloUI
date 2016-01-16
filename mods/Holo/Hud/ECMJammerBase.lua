if Infohud_enable and Holo.options.ECMtimer_enable then
Holo:clone(ECMJammerBase)
function ECMJammerBase:set_active(active, ...)
	self.old.set_active(self,active ,...)
	if Holo._hudinfo then
		if active == true then
	     	self._timer_ID = math.random(999999999999)
		    Holo._hudinfo:create_timer(self._timer_ID)
	    end
	end
end

function ECMJammerBase:update(...)
	self.old.update(self, ...)
	if Holo._hudinfo then
		if self._jammer_active == true then
			Holo._hudinfo:set_timer(self._timer_ID, self._chk_feedback_retrigger_t or self._battery_life, "ECM")
	    end
	end
end
function ECMJammerBase:set_battery_empty(...)
	self.old.set_battery_empty(self, ...)
	if Holo._hudinfo then
		if managers.hud then
			Holo._hudinfo:remove_timer(self._timer_ID)
		end
	end
end
function ECMJammerBase:destroy(...)
	self.old.destroy(self, ...)
	if Holo._hudinfo then
		if managers.hud then
			Holo._hudinfo:remove_timer(self._timer_ID)
		end
	end
end
end