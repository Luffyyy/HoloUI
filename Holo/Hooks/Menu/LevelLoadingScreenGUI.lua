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
		if arg.load_level_data.tip then
			self._loading_hint = self:_make_loading_hint(panel, arg.load_level_data.tip)
		end
		self._indicator = panel:bitmap({
			name = "indicator",
			color = data.text_color,
			texture = "guis/textures/pd2/skilltree/drillgui_icon_restarter",
			w = 32,
			h = 32,
		})		
		self._level_title_text = panel:text({
			font = "fonts/font_large_mf",
			font_size = 0,
			visible = false,
			halign = "left",
			vertical = "bottom",
		})
		self._level_name_text = panel:text({
			text = string.upper(self._level_tweak_data.name or ""),
			font = "fonts/font_large_mf",
			color = data.text_color,
			font_size = 42,
	        halign="grow",
	        valign="bottom",
		})			
		local difficulty_text = panel:text({
			text = data.difficulty_string,
			font = "fonts/font_large_mf",
			color = data.text_color,
			font_size = 24,
	        halign="grow",
	        valign="bottom",
			h = 24
		})		
		local brief_text = panel:text({
			text = data.briefing_string,
			font = "fonts/font_large_mf",
			color = data.text_color,
			font_size = 16,
			align = "right",
	        halign="grow",
	        valign="bottom",
	        wrap = true,
			w = 500
		})
		local make_text = function(text)
			local _,_,w,h = text:text_rect()
			text:set_size(w,h)
		end
		make_text(brief_text)
		brief_text:set_righttop(panel:right() - 50, panel:top() - 20)	
		make_text(self._level_name_text)
		make_text(difficulty_text)
		difficulty_text:set_top(self._level_name_text:bottom())
		self._indicator:set_leftbottom(self._level_name_text:rightbottom())
		self._indicator:move(0, -6)
	else
		oinit(self, scene_gui, res, progress, base_layer)
	end
end

local o_make_loading_hint = LevelLoadingScreenGuiScript._make_loading_hint
function LevelLoadingScreenGuiScript:color_all(panel)
	local text_color = arg.load_level_data.level_data.text_color
	for _, child in pairs(panel:children()) do
		if child.set_color and child:w() ~= 192 then
			child:set_color(text_color)
		elseif child.children then
			self:color_all(child)
		end
	end
end

function LevelLoadingScreenGuiScript:_make_loading_hint(parent, tip)
	local this = o_make_loading_hint(self, parent, tip)
	local panel = parent:child(0)
	if alive(panel) and panel.children then
		self:color_all(panel)
	end
	return this
end