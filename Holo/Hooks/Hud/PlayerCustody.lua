if Holo.Options:GetValue("Hud") then 
	Holo:Post(HUDPlayerCustody, "init", function(self)
		local custody_panel = self._hud_panel:child("custody_panel")
		custody_panel:child("timer_msg"):set_world_y(managers.hud._hud_heist_timer._heist_timer_panel:world_bottom() + 1)
		custody_panel:child("timer"):set_y(math.round(custody_panel:child("timer_msg"):bottom() - 6))
	end)
end