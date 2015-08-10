CloneClass(HUDPlayerDowned) --Fixes downed timer colliding with the assault box(hoxhud problem).
if Holo.options.HoxHud_support == true then 	
function HUDPlayerDowned:init(hud)
	self._hud = hud
	self._hud_panel = hud.panel
	if self._hud_panel:child("downed_panel") then
		self._hud_panel:remove(self._hud_panel:child("downed_panel"))
	end
	local downed_panel = self._hud_panel:panel({
		name = "downed_panel"
	})
	local timer_msg = downed_panel:text({
		name = "timer_msg",
		text = "BLEH BLEH IN",
		align = "center",
		vertical = "center",
		w = 400,
		h = 40,
		font = tweak_data.hud.medium_font_noshadow,
		font_size = tweak_data.hud_downed.timer_message_size
	})
	local _, _, w, h = timer_msg:text_rect()
	timer_msg:set_h(h)
	timer_msg:set_x(math.round(self._hud_panel:center_x() - timer_msg:w() / 2))
	timer_msg:set_y(42)
	self._hud.timer:set_font(tweak_data.menu.pd2_large_font_id)
	self._hud.timer:set_font_size(42)
	local _, _, w, h = self._hud.timer:text_rect()
	self._hud.timer:set_h(h)
	self._hud.timer:set_y(math.round(timer_msg:bottom() - 6))
	self._hud.timer:set_center_x(self._hud_panel:center_x())
	self._hud.arrest_finished_text:set_font(Idstring(tweak_data.hud.medium_font_noshadow))
	self._hud.arrest_finished_text:set_font_size(tweak_data.hud_mask_off.text_size)
	self:set_arrest_finished_text()
	local _, _, w, h = self._hud.arrest_finished_text:text_rect()
	self._hud.arrest_finished_text:set_h(h)
	self._hud.arrest_finished_text:set_y(42)
	self._hud.arrest_finished_text:set_center_x(self._hud_panel:center_x())
end

end

Hooks:PostHook(HUDPlayerDowned, "on_downed", "set_health_downed", function(self)
if Holo.options.HealthNum_style == 1 then 
  managers.hud._teammate_panels[managers.hud.PLAYER_PANEL]:set_downed()
end
end)