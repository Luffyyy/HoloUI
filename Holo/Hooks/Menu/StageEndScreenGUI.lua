if Holo:ShouldModify("Menu", "Lobby") then
Hooks:PostHook(StatsTabItem, "init", "HoloInit", function(self, panel, tab_panel, text, i)
	Holo.Utils:NotUglyTab(tab_panel:child("tab_select_rect_" .. tostring(self._index)), tab_panel:child("tab_text_" .. tostring(self._index)))
end)
Hooks:PostHook(CrimeSpreeResultTabItem, "init", "HoloInit", function(self, panel, tab_panel, text, i)
	Holo.Utils:NotUglyTab(tab_panel:child("tab_select_rect_" .. tostring(self._index)), tab_panel:child("tab_text_" .. tostring(self._index)))
end)
Hooks:PostHook(StatsTabItem, "reduce_to_small_font", "HoloReduceToSmallFont", function(self)
	self._panel:set_h(self._main_panel:h())
end)
Hooks:PostHook(StatsTabItem, "select", "HoloSelect", function(self)
	if self._tab_text and alive(self._tab_text) then
		self._tab_text:set_color(Holo:GetColor("TextColors/Tab"))
		self._tab_text:set_blend_mode("normal")
		self._select_rect:set_color(Holo:GetColor("Colors/TabHighlighted"))
		self._select_rect:show()
	end
end)
Hooks:PostHook(StatsTabItem, "deselect", "HoloDeselect", function(self)
   if self._tab_text and alive(self._tab_text) then
	   self._tab_text:set_color(Holo:GetColor("TextColors/Tab"))
	   self._tab_text:set_blend_mode("normal")
	   self._select_rect:set_color(Holo:GetColor("Colors/Tab"))
	   self._select_rect:show()
   end
end)
Hooks:PostHook(StatsTabItem, "mouse_moved", "HoloMouseMoved", function(self, x, y, mouse_over_scroll)
	self._tab_text:set_color(Holo:GetColor("TextColors/Tab"))
	if self._selected then
 		self._select_rect:set_color(Holo:GetColor("Colors/TabHighlighted"))
 	elseif mouse_over_scroll and self._tab_text:inside(x, y) then
 		if not self.highlighted then
			self._highlighted = true
 			self.highlighted = true
 			self._select_rect:set_color(Holo:GetColor("Colors/TabHighlighted"))
 		end
 	elseif self.highlighted then
		self._highlighted = false
 		self.highlighted = false
 		self._select_rect:set_color(Holo:GetColor("Colors/Tab"))
 	end
end)
Hooks:PostHook(StageEndScreenGui, "init", "HoloInit", function(self)
	self._continue_button:configure({
		font = "fonts/font_medium_mf",
		font_size = 24,
		rotation = 360,
		color = Holo:GetColor("TextColors/Menu"),
	})
	self._continue_button:set_rightbottom(self._panel:w(), self._panel:h())
	self._prev_page:set_color(Holo:GetColor("TextColors/Menu"))
	self._next_page:set_color(Holo:GetColor("TextColors/Menu"))
end)
Hooks:PostHook(StageEndScreenGui, "set_continue_button_text", "HoloSetContinueButtonText", function(self)
	self._continue_button:set_rightbottom(self._panel:w(), self._panel:h())
	self._continue_button:set_color(self._button_not_clickable and tweak_data.screen_colors.item_stage_1 or Holo:GetColor("TextColors/Menu"))
end)
end
