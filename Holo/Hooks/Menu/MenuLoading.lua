local oinit = LevelLoadingScreenGuiScript.init
function LevelLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer)
	local data = arg.load_level_data.level_data
	if data.Holo then
		self._scene_gui = scene_gui
		self._res = res
		self._base_layer = base_layer
		self._level_tweak_data = arg.load_level_data.level_tweak_data
		self._gui_tweak_data = arg.load_level_data.gui_tweak_data
		self._menu_tweak_data = arg.load_level_data.menu_tweak_data
		self._scale_tweak_data = arg.load_level_data.scale_tweak_data
		self._coords = arg.load_level_data.controller_coords or false
		self._gui_data = arg.load_level_data.gui_data
		self._workspace_size = self._gui_data.workspace_size
		self._saferect_size = self._gui_data.saferect_size
		local challenges = arg.load_level_data.challenges
		local safe_rect_pixels = self._gui_data.safe_rect_pixels
		local safe_rect = self._gui_data.safe_rect
		local aspect_ratio = self._gui_data.aspect_ratio
		self._safe_rect_pixels = safe_rect_pixels
		self._safe_rect = safe_rect
		self._gui_data_manager = GuiDataManager:new(self._scene_gui, res, safe_rect_pixels, safe_rect, aspect_ratio)
		self._back_drop_gui = MenuBackdropGUI:new(nil, self._gui_data_manager, true)		
		local base_panel = self._back_drop_gui:get_new_base_layer()		
		base_panel:bitmap({
			texture = not data.colored_background and "guis/textures/loading/loading_bg",
			color = data.colored_background and data.background_color,
			w = base_panel:w(),
			h = base_panel:h(),
			layer = 0,
		})
		self._back_drop_gui:enable_light(false)
		self._back_drop_gui._panel:child("base_layer"):child("bd_base_layer"):hide()
		self._back_drop_gui._panel:child("particles_layer"):hide()
		local panel = self._back_drop_gui:get_new_background_layer()
		self._back_drop_gui:set_panel_to_saferect(panel)
		self._indicator = panel:bitmap({
			name = "indicator",
			texture = "guis/textures/pd2/skilltree/drillgui_icon_restarter",
			w = 32,
			h = 32,
		})		
		self._level_title_text = panel:text({
			text_id = "debug_loading_level",
			font = "fonts/font_large_mf",
			font_size = 42,
			halign = "left",
			vertical = "bottom",
			h = 36
		})
		self._level_title_text:set_text(string.upper(self._level_title_text:text()))
		self._level_name_text = panel:text({
			text = string.upper(self._level_tweak_data.name or ""),
			font = "fonts/font_large_mf",
			font_size = 42,
	        halign="grow",
	        valign="bottom",
			h = 42
		})		
		local brief_text = panel:text({
			text = data.briefing_string,
			font = "fonts/font_large_mf",
			font_size = 16,
			align = "right",
	        halign="grow",
	        valign="bottom",
	        wrap = true,
			w = 500
		})
		local line = panel:bitmap({
			name = "line",
			color = data.main_color,
			h = 2,
		})					
		local _,_,w,h = self._level_name_text:text_rect()
		self._level_name_text:set_size(w,h)
		local _, _, w2, h2 = self._level_title_text:text_rect()
		self._level_title_text:set_size(w2, h2)
		line:set_w((w > w2 and w or w2) + 2)
		self._level_title_text:set_lefttop(self._level_name_text:left(), self._level_name_text:bottom())
		self._indicator:set_leftbottom(self._level_title_text:right(), self._level_title_text:bottom() - 6)
		line:set_lefttop(self._level_title_text:left(), self._level_title_text:bottom())
		local _,_,_,h = brief_text:text_rect()
		brief_text:set_h(h)
		brief_text:set_righttop(panel:right() - 50, panel:top() - 20)
	else
		oinit(self, scene_gui, res, progress, base_layer)
	end
end
