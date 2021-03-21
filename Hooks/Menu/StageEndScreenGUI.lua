if Holo:ShouldModify("Menu", "Lobby") then
	function StatsTabItem:init_holo()
		self._tab_select_rect = self._tab_select_rect or self._select_rect
		self._tab_select_rect:set_alpha(0)
		Holo.Utils:TabInit(self)
	end

	function StatsTabItem:is_tab_selected() return self._selected end
	Holo:Post(StatsTabItem, "select", ClassClbk(Holo.Utils, "TabUpdate"))
	Holo:Post(StatsTabItem, "deselect", ClassClbk(Holo.Utils, "TabUpdate"))
	Holo:Post(StatsTabItem, "mouse_moved", ClassClbk(Holo.Utils, "TabUpdate"))
	Holo:Post(StatsTabItem, "update_tab_position", ClassClbk(Holo.Utils, "TabUpdate"))
	Holo:Post(StatsTabItem, "update_tab_position", MissionBriefingTabItem.update_tab_position)
	Holo:Post(StatsTabItem, "init", StatsTabItem.init_holo)
	Holo:Post(CrimeSpreeResultTabItem, "init", StatsTabItem.init_holo)
	
	Holo:Post(StageEndScreenGui, "init", function(self)
		self._continue_button:configure({
			font = "fonts/font_medium_mf",
			font_size = 24,
			rotation = 360,
			color = Holo:GetColor("TextColors/Menu"),
		})
		self._continue_button:set_rightbottom(self._panel:w(), self._panel:h())
		self._prev_page:set_color(Holo:GetColor("TextColors/Menu"))
		self._next_page:set_color(Holo:GetColor("TextColors/Menu"))
		self._panel:set_y(80)
		Holo.Utils:RemoveBoxes(self._panel)
	end)
	
	Holo:Post(StageEndScreenGui, "set_continue_button_text", function(self)
		self._continue_button:set_rightbottom(self._panel:w(), self._panel:h() + 270)
		self._continue_button:set_color(self._button_not_clickable and tweak_data.screen_colors.item_stage_1 or Holo:GetColor("TextColors/Menu"))
	end)
end