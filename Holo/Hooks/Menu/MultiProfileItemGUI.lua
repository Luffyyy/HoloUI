Hooks:PostHook(MultiProfileItemGui, "init", "HoloInit", function(self)
	if alive(self._caret) then
		self._caret:set_rotation(360)
	end
end)
Hooks:PostHook(MultiProfileItemGui, "update", "HoloUpdate", function(self)
	if alive(self._name_text) then
		self._name_text:set_rotation(360)
	end
	local panel = self._panel:child(0)
	if alive(panel) then
		local arrow = panel:child("arrow_left")
		if alive(arrow) then
			arrow:set_rotation(360)
		end
	end
end)