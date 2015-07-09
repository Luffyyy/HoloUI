core:import("CoreMenuNodeGui")
require("lib/managers/menu/MenuNodeKitGui")
CloneClass(MenuLobbyRenderer)

function MenuKitRenderer:show_node(node)
	local gui_class = MenuNodeKitGui
	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end
	local parameters = {
		row_item_color = Holo.options.Menu_enable == true and Color.white or tweak_data.screen_colors.button_stage_3,
		row_item_hightlight_color = Holo.options.Menu_enable == true and ColorRGB(0, 150, 255) or tweak_data.screen_colors.button_stage_2,
		row_item_blend_mode = Holo.options.Menu_enable == true and "normal" or "add",
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		node_gui_class = gui_class,
		spacing = node:parameters().spacing,
		marker_alpha = 0.2,
		marker_color = Holo.options.Menu_enable == true and Color.white or tweak_data.screen_colors.button_stage_3,
		align = "right",
		to_upper = true
	}
	MenuKitRenderer.super.super.show_node(self, node, parameters)
end


