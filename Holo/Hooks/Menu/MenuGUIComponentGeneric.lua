Hooks:PostHook(MenuGuiComponentGeneric, "_add_back_button", "HoloAddBackButton", function(self)
	Holo.Utils:FixBackButton(self, self._panel:child("back_button"))
end)