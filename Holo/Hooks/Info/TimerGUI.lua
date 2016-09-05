if Holo.Options:GetValue("Base/Info") and Holo.Options:GetValue("Info/DrillTimers") then
Hooks:PostHook(TimerGui, "init", "HoloInit", function(self)
	self._unit_names = {
	    drill = "Drill", 
	    lance = "Thermal".."\n".."drill",
	    huge_lance = "The Beast",
	    votingmachine2 = "Hacking", hack_suburbia = "Hacking",hold_hack_comp = "Hacking",
	    hold_download_keys = "Download",
	    hold_analyze_evidence = "analyze",
	    uload_database = "Upload"
	}
end)

Hooks:PostHook(TimerGui, "_start", "HoloStart", function(self)
	if not Holo.Info then
		return 
	end			
	if not self._created then
	    if self._unit:interaction() then
	    	if self._unit:interaction().tweak_data then
	    		self._name = self._unit_names[self._unit:interaction().tweak_data]
	    	else
	    		self._name = "Timer"
	    	end
	    else
	    	self._name = "Timer"
	    end
		Holo.Info:CreateInfo({
			timer = true,
			visible = true,
			name = self._unit:id(),
			panel = self._name,
		})		    	
		self._created = true 
    end
end)

Hooks:PostHook(TimerGui, "update", "HoloUpdate", function(self)
	if not Holo.Info then
		return 
	end			
	if not self._jammed then
		Holo.Info:SetInfoTime(self._name, self._unit:id(), self._time_left or self._current_timer or self._current_jam_timer)
	end
	if not alive(self._new_gui) and not alive(self._ws) then
		Holo.Info:RemoveInfoValue(self._name, self._unit:id())
	end
end)

Hooks:PostHook(TimerGui, "_set_jammed", "HoloSetJammed", function(self)
	if not Holo.Info then
		return 
	end			
	Holo.Info:SetInfoValueColor(self._name, self._unit:id(), "Colors/" .. (self._jammed and "Timers" or "TimersJammed"))
end)

Hooks:PostHook(TimerGui, "done", "HoloDone", function(self)
	if not Holo.Info then
		return 
	end			
	Holo.Info:RemoveInfoValue(self._name, self._unit:id())
	self._created = nil
end)

Hooks:PostHook(TimerGui, "done", "HoloSetDone", function(self)
	if not Holo.Info then
		return 
	end		
	Holo.Info:RemoveInfoValue(self._name, self._unit:id())
	self._created = nil
end)

Hooks:PostHook(TimerGui, "destroy", "HoloDestroy", function(self)
	if not Holo.Info then
		return 
	end			
	Holo.Info:RemoveInfoValue(self._name, self._unit:id())
	self._created = nil
end)

Hooks:PostHook(TimerGui, "_set_powered", "HoloSetPowered", function(self)
	if not Holo.Info then
		return 
	end		
	Holo.Info:SetInfoColor(self._name, self._unit:id(), "Colors/" .. (self._powered and "Timers" or "TimersJammed"))
end)

Hooks:PostHook(TimerGui, "post_event", "HoloPostEvent", function(self)
	if not Holo.Info then
		return 
	end			
	if event == self._done_event then
		Holo.Info:RemoveInfoValue(self._name, self._unit:id())
	    self._created = nil
	end
end)

DrillTimerGui = DrillTimerGui or class(TimerGui)
Hooks:PostHook(DrillTimerGui, "post_event", "HoloPostEvent", function(self, event)
	if not Holo.Info then
		return 
	end		
	if event == self._done_event then
		Holo.Info:RemoveInfoValue(self._name, self._unit:id())
	    self._created = nil
	end
end) 
end