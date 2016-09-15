if Holo.Options:GetValue("Base/Info") and Holo.Options:GetValue("Info/DrillTimers") then
Hooks:PostHook(TimerGui, "_start", "HoloStart", function(self)
	if not Holo.Info then
		return 
	end			
	if self._unit:interaction() then
		local unit_names = {
			drill = "Drill", 
			lance = "ThermalDrill",
			huge_lance = "Beast",
			votingmachine2 = "Hacking", hack_suburbia = "Hacking",hold_hack_comp = "Hacking",
			hold_download_keys = "Download",
			hold_analyze_evidence = "Analyze",
			uload_database = "Upload"
		}
		if self._unit:interaction().tweak_data then
			self._name = unit_names[self._unit:interaction().tweak_data]
		else
			self._name = "Timer"
		end
	else
		self._name = "Timer"
	end
	Holo.Info:CreateInfo({
		timer = true,
		visible = true,
		color = self._name,
		name = self._unit:id(),
		unit = self._unit,
		panel = self._name,
	})		
	self._info = FloatingInfo:new(self._unit)    	
end)

Hooks:PostHook(TimerGui, "update", "HoloUpdate", function(self)
	if not Holo.Info then
		return 
	end		
	if alive(self._unit) then
		self._id = self._unit:id()
	end
	self._info.text = string.format("%.2f", self._time_left or self._current_timer or self._current_jam_timer)
	self._info.percent = self._current_timer / self._timer
	self._info.color = Holo:GetColor("Colors/" .. self._name)
	if self._jammed then
		self._info.text = self._info.text .. "(!)"
		self._info.color = Color.red
		Holo.Info:SetInfoValueColor(self._name, self._id, self._jammed and self._name or "TimersJammed")
	else
		Holo.Info:SetInfoTime(self._name, self._id, self._time_left or self._current_timer or self._current_jam_timer)
	end
end)
end