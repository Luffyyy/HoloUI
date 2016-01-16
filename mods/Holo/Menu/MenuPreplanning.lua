if Holo.options.Menu_enable then

require("lib/managers/menu/renderers/MenuNodeBaseGui")
CloneClass(MenuNodeBaseGui)
function MenuNodePrePlanningGui:init(node, layer, parameters)
	parameters.font = tweak_data.menu.pd2_small_font
	parameters.font_size = tweak_data.menu.pd2_small_font_size
	parameters.align = "left"
	parameters.row_item_blend_mode = "normal"
	parameters.row_item_color = Holomenu_color_normal
	parameters.row_item_hightlight_color = Holomenu_color_highlight
	parameters.row_item_disabled_text_color = Color(1, 0.3, 0.3, 0.3)
	parameters.marker_color = Holomenu_color_marker
	parameters.to_upper = true
	parameters._align_line_proportions = 0.75
	parameters.height_pnormaling = 10
	parameters.tooltip_height = node:parameters().tooltip_height or 265
	if node:parameters().name == "preplanning_type" or node:parameters().name == "preplanning_plan" then
		parameters.row_item_disabled_text_color = tweak_data.screen_colors.important_1
		self.marker_disabled_color = tweak_data.screen_colors.important_1:with_alpha(0.2)
	end
	MenuNodePrePlanningGui.super.init(self, node, layer, parameters)
end

end