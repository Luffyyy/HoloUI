if not Holo.Options:GetValue("Menu") then
	return
end

core:import("CoreMenuNodeGui")
local o_init = MenuNodeGui.init
function MenuNodeGui:init(node, layer, params)
	params.row_item_color = Holo:GetColor("TextColors/Menu")
	params.row_item_hightlight_color = Holo:GetColor("TextColors/MenuHighlighted")
	params.row_item_blend_mode = "normal"
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
		color = Holo:GetColor("TextColors/MenuHighlighted")
	})
	if self.marker_color ~= tweak_data.screen_colors.button_stage_3 or self.marker_color ~= tweak_data.screen_colors.button_stage_2 then
		self._marker_data.gradient:set_color(self.marker_color)
	end
end

Holo:Post(MenuNodeGui, "_create_menu_item", function(self, row_item)
	if row_item and row_item.item:parameters().pd2_corner then
		row_item.gui_text:configure({
			color = Holo:GetColor("TextColors/Menu"),
			blend_mode = "normal",
			font_size = self.font_size,
		})
		local _,_,_,h = row_item.gui_text:text_rect()
		row_item.gui_text:set_h(h)
		row_item.gui_panel:set_h(h)
		if managers.menu:is_pc_controller() then
			row_item.gui_panel:set_rightbottom(row_item.gui_pd2_panel:size())
			if row_item.name == "spree_reroll" then
				row_item.gui_text:set_rightbottom(row_item.gui_pd2_panel:w(), row_item.gui_pd2_panel:h() + 4)
			end
		end
	end
end)

Holo:Replace(MenuNodeGui, "_fade_row_item", function(self, o, row_item, ...)
	if not row_item then
		return
	end
	local panel = row_item.gui_text or row_item.gui_panel
	local color = panel and panel.color and panel:color()
	local ret = o(self, row_item, ...)
	local new_color = panel.color and panel:color()	
	if color then
		panel:set_color(color)
		play_color(panel, new_color, {time = 0.2})
	end
	return ret
end)

Holo:Replace(MenuNodeGui, "_highlight_row_item", function(self, o, row_item, ...)
	if not row_item then
		return
	end
	local panel = row_item.gui_text or row_item.gui_panel
	local color = panel.color and panel:color()	
	local ret = o(self, row_item, ...)
	local new_color = panel.color and panel:color()	
	if color then
		panel:set_color(color)
		play_color(panel, new_color, {time = 0.2})
	end
	return ret	
end)

Holo:Pre(MenuNodeGui, "_align_marker", function(self, row_item)
	self._old_center_y = self._marker_data.marker:world_center_y()
end)

Holo:Post(MenuNodeGui, "_align_marker", function(self, row_item)
	local panel = row_item.gui_panel or row_item.gui_text
	self._marker_data.gradient:set_rotation(360)
	self._marker_data.marker:set_h(panel:h())
	self._marker_data.gradient:set_h(panel:h())
	self._marker_data.marker:set_w(2)
	if row_item.align == "right" or row_item.item:parameters().pd2_corner then
		self._marker_data.marker:set_world_x(panel:world_right() + 2)
	else
		self._marker_data.marker:set_world_x(panel:world_x() - 2)
	end
	self._marker_data.marker:stop()
	if self._old_center_y then
		self._marker_data.marker:set_world_center_y(self._old_center_y)
	end

	play_anim(self._marker_data.marker, {
		time = 0.2,
		set = {
			world_center_y = row_item.item:parameters().pd2_corner and row_item.gui_pd2_panel and row_item.gui_text:world_center_y() or panel:world_center_y(),
		}
	})
end)