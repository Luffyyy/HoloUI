if Holo:ShouldModify("Hud", "Presenter") then
	Holo:Post(HUDPresenter, "init", function(self)
		self._bg_box:hide()
		self._bg_box:set_alpha(0)
	end)
	function HUDPresenter:_present_information(params)
		managers.hud._hud_hint:show({text = string.format("%s %s", utf8.to_upper(params.title or "ERROR"), utf8.to_upper(params.text))})
	end
end