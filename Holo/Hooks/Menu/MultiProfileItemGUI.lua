Hooks:PostHook(MultiProfileItemGui, "init", "HoloInit", function(self)
	self._caret:set_rotation(360)
end)
Hooks:PostHook(MultiProfileItemGui, "update", "HoloUpdate", function(self)
	self._name_text:set_rotation(360)
	self._panel:child("arrow_left"):set_rotation(360)
end)
 