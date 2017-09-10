if Holo.Options:GetValue("Hud") then 
	Holo:Post(HUDPlayerCustody, "init", function(self)
		local custody_panel = self._hud_panel:child("custody_panel")
		custody_panel:child("timer_msg"):set_y(36)
		custody_panel:child("timer"):set_y(math.round(custody_panel:child("timer_msg"):bottom() - 6))
	end)
end


