Holo:Post(MultiProfileItemGui, "init", function(self)
	if alive(self._caret) then
		self._caret:set_rotation(360)
	end
end)
Holo:Post(MultiProfileItemGui, "update", function(self)
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
	if self._quick_select_panel_elements then
		for _, element in pairs(self._quick_select_panel_elements) do
			element:set_rotation(360)
		end
	end
	local some_shit = alive(self._profile_panel) and self._profile_panel:child(0)
	if alive(some_shit) then
		some_shit:set_rotation(360)
	end
end)