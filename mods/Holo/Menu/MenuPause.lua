if Holo.options.Menu_enable then

core:import("CoreMenuNodeGui")
CloneClass(MenuRenderer)
if Holo.options.Menu_enable then
function MenuPauseRenderer:show_node(node)
	local gui_class = MenuNodeGui
	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end
	if not managers.menu:active_menu() then
		Application:error("now everything is broken")
	end
	local parameters = {
		font = tweak_data.menu.pd2_medium_font,
		row_item_color = Holomenu_color_normal,
		row_item_hightlight_color = Holomenu_color_highlight,
		row_item_blend_mode = "normal",
		font_size = Holomenu_textsize,
		node_gui_class = gui_class,
		spacing = node:parameters().spacing,
		marker_alpha = 0.2,
		marker_color = Holomenu_color_normal,
		align = "right",
		to_upper = true
	}
	MenuPauseRenderer.super.super.show_node(self, node, parameters)
end

function MenuPauseRenderer:open(...)
	MenuPauseRenderer.super.super.open(self, ...)
		self._menu_bg = self._fullscreen_panel:gradient({
		visible = false,
		valign = "center",
		y = managers.gui_data:y_safe_to_full(0),
		w = self._fullscreen_panel:w(),
		h = managers.gui_data:scaled_size().height,
		orientation = "vertical",
		layer = -2,
		gradient_points = {
			0,
			Color(1, 0, 0, 0),
			0.25,
			Color(0, 0.4, 0.2, 0),
			1,
			Color(1, 0, 0, 0)
		},
		blend_mode = "normal"
	})
		self._NewBG = self._fullscreen_panel:bitmap({
		name = "BG",
		visible = Holo.options.Menu_enable,
		valign = "center",
		y = -2,
		w = self._fullscreen_panel:w(),
	    color = Color.black:with_alpha(0.3),
		layer = -1
	})
	self._blur_bg = self._fullscreen_panel:bitmap({
		name = "blur_bg",
		visible = false,
		valign = "center",
		texture = "guis/textures/test_blur_df",
		y = managers.gui_data:y_safe_to_full(0),
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h(),
		render_template = "VertexColorTexturedBlur3D",
		layer = -1
	})
	self._top_rect = self._fullscreen_panel:rect({
		valign = {0, 0.5},
		color = Color.black,
		visible = false,
		w = self._fullscreen_panel:w(),
		h = managers.gui_data:y_safe_to_full(0) + 2,
		y = -2,
		rotation = 360
	})
	self._bottom_rect = self._fullscreen_panel:rect({
		valign = {0.5, 0.5},
		color = Color.black,
		visible = false,
		y = managers.gui_data:y_safe_to_full(managers.gui_data:scaled_size().height),
		w = self._fullscreen_panel:w(),
		h = managers.gui_data:y_safe_to_full(0) + 2,
		rotation = 360
	})
	MenuRenderer._create_framing(self)
end

function MenuPauseRenderer:update(t, dt)
	MenuPauseRenderer.super.update(self, t, dt)
	local x, y = managers.mouse_pointer:modified_mouse_pos()
	y = math.clamp(y, 0, managers.gui_data:scaled_size().height)
	y = y / managers.gui_data:scaled_size().height
	local button_stage_2 = tweak_data.screen_colors.button_stage_2 / 4
	local button_stage_3 = tweak_data.screen_colors.button_stage_3 / 4
	if Holo.options.Menu_enable == false then
	self._menu_bg:set_gradient_points({
		0,
		button_stage_2:with_alpha(0.75),
		y,
		button_stage_3:with_alpha(0.65),
		1,
		button_stage_2:with_alpha(0.75)
	})
    self._top_rect:set_visible(true)
	self._bottom_rect:set_visible(true)
	self._NewBG:set_visible(false)
	self._menu_bg:set_visible(true)
	self._blur_bg:set_visible(true)
	else
    self._top_rect:set_visible(false)
	self._bottom_rect:set_visible(false)
	self._NewBG:set_visible(true)
	self._menu_bg:set_visible(false)
	self._blur_bg:set_visible(false)
	end	
end

function MenuPauseRenderer:set_bg_visible(visible)

end

function MenuPauseRenderer:set_bg_area(area)
	if self._menu_bg then
		if area == "full" then
			self._menu_bg:set_size(self._menu_bg:parent():size())
			self._menu_bg:set_position(0, 0)
		elseif area == "half" then
			self._menu_bg:set_alpha(0.3)
		else
			self._menu_bg:set_size(self._menu_bg:parent():size())
			self._menu_bg:set_position(0, 0)
		end
		if self._blur_bg then
			self._blur_bg:set_shape(self._menu_bg:shape())
		end
	end
end
end
end