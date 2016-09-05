if Holo.Options:GetValue("Base/Menu") then
	core:import("CoreMenuNodeGui")
	local o_init = MenuNodeGui.init
	function MenuNodeGui:init(node, layer, params)
		params.row_item_color = Holo:GetColor("TextColors/Menu")
		params.row_item_hightlight_color = Holo:GetColor("TextColors/MenuHighlighted")
		params.row_item_blend_mode = "normal"
		params.font_size = Holo.TextSizes[Holo.Options:GetValue("Menu/TextSize")]
		params.marker_alpha = Holo.Options:GetValue("Menu/MarkerAlpha")
		params.marker_color = Holo:GetColor("Colors/Marker")
		params.marker_disabled_color = Color(0.1, 0.1, 0.1)
		o_init(self, node, layer, params)
	end
	function MenuNodeGui:_create_marker(node)
		self._marker_data = {}
		self._marker_data.marker = self.item_panel:panel({
			w = 1280,
			h = 10,
			visible = false,
			layer = self.layers.marker
		})
		self._marker_data.gradient = self._marker_data.marker:rect({
			halign = "grow",
			valign = "grow",
			alpha = Holo.Options:GetValue("Menu/MarkerAlpha"),
			color = Holo:GetColor("TextColors/MenuHighlighted")
		})
		if self.marker_color ~= tweak_data.screen_colors.button_stage_3 or self.marker_color ~= tweak_data.screen_colors.button_stage_2 then
			self._marker_data.gradient:set_color(self.marker_color)
		end
	end

	Hooks:PostHook(MenuNodeGui, "_create_menu_item", "HoloCreateMenuItem", function(self, row_item)
		if row_item and row_item.item:parameters().pd2_corner then
			row_item.gui_text:configure({
				color = Holo:GetColor("TextColors/Menu"),
				blend_mode = "normal",
				font_size = self.font_size,
			})
			local _, _, _, h = row_item.gui_text:text_rect()
			row_item.gui_text:set_h(h)
			row_item.gui_panel:set_h(h)
			if managers.menu:is_pc_controller() then 
				row_item.gui_panel:set_rightbottom(row_item.gui_pd2_panel:w(), row_item.gui_pd2_panel:h())
			else
				row_item.gui_panel:set_right(row_item.gui_pd2_panel:w())
			end
		end
	end)

	Hooks:PostHook(MenuNodeGui, "_fade_row_item", "HoloFadeRowItem", function(self, row_item)
		if row_item and row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(Holo:GetColor("TextColors/Menu"))
		end
	end)
	Hooks:PostHook(MenuNodeGui, "_highlight_row_item", "HoloHighlightRowItem", function(self, row_item)
		if row_item and row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(Holo:GetColor("TextColors/MenuHighlighted"))
		end
	end)
	function MenuNodeGui:_align_marker(row_item)
		self._marker_data.marker:show()
		if self.marker_color or row_item.marker_color then
			self._marker_data.gradient:set_color(row_item.item:enabled() and Holo:GetColor("Colors/Marker") or row_item.marker_disabled_color)
			self._marker_data.gradient:set_alpha(Holo.Options:GetValue("Menu/MarkerAlpha"))
		end
		if row_item.item:parameters().pd2_corner then
			local _,_,_,h = row_item.gui_text:text_rect()
			self._marker_data.gradient:set_rotation(360)
			self._marker_data.marker:set_h(h)
			self._marker_data.marker:set_w(self:_scaled_size().width - row_item.menu_unselected:x())
			self._marker_data.marker:set_world_right(row_item.menu_unselected:world_right())
			self._marker_data.marker:set_world_bottom(row_item.gui_text:world_bottom())
			return
		end
		self._marker_data.marker:set_h(row_item.gui_panel:h())
		self._marker_data.gradient:set_rotation(0)
		self._marker_data.gradient:set_x(row_item.menu_unselected:x())
		self._marker_data.marker:set_center_y(row_item.gui_panel:center_y())
		if row_item.type == "upgrade" then
			self._marker_data.marker:set_left(self:_mid_align())
		elseif row_item.type == "friend" then
			if row_item.align == "right" then
				self._marker_data.marker:move(-100, 0)
			else
				local _, _, w, _ = row_item.signin_status:text_rect()
				self._marker_data.marker:set_left(self:_left_align() - w - self._align_line_padding)
			end
		elseif row_item.type == "server_column" then
			self._marker_data.marker:set_left(row_item.gui_panel:x())
		elseif row_item.type == "slider" then
			self._marker_data.marker:hide()
		end
		self._marker_data.marker:set_w(self:_scaled_size().width - self._marker_data.marker:left())
	end
end
