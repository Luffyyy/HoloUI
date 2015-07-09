core:import("CoreMenuNodeGui")
MenuNodeGui = MenuNodeGui or class(CoreMenuNodeGui.NodeGui)
function MenuNodeGui:init(node, layer, parameters)
	local name = node:parameters().name
	local lang_mods = {}
	lang_mods[Idstring("german"):key()] = name == "kit" and 0.95 or name == "challenges_active" and 0.875 or name == "challenges_awarded" and 0.875 or 0.9
	lang_mods[Idstring("french"):key()] = name == "kit" and 0.975 or name == "challenges_active" and 0.874 or name == "challenges_awarded" and 0.874 or name == "upgrades_support" and 0.875 or 0.9
	lang_mods[Idstring("italian"):key()] = name == "kit" and 0.975 or name == "challenges_active" and 0.875 or name == "challenges_awarded" and 0.875 or 0.95
	lang_mods[Idstring("spanish"):key()] = name == "kit" and 1 or name == "challenges_active" and 0.84 or name == "challenges_awarded" and 0.84 or (name == "upgrades_assault" or name == "upgrades_sharpshooter" or name == "upgrades_support") and 0.975 or 0.925
	lang_mods[Idstring("english"):key()] = name == "challenges_active" and 0.925 or name == "challenges_awarded" and 0.925 or 1
	local mod = lang_mods[SystemInfo:language():key()] or 1
	self._align_line_proportions = node:parameters().align_line_proportions or 0.65
	self._align_line_padding = 10 * tweak_data.scale.align_line_padding_multiplier
	self._use_info_rect = node:parameters().use_info_rect or node:parameters().use_info_rect == nil and true
	self._stencil_align = node:parameters().stencil_align or "right"
	self._stencil_align_percent = node:parameters().stencil_align_percent or 0
	self._stencil_image = node:parameters().stencil_image
	self._scene_state = node:parameters().scene_state
	self._no_menu_wrapper = true
	self._is_loadout = node:parameters().is_loadout
	self._align = node:parameters().align or "mid"
	self._bg_visible = node:parameters().hide_bg
	self._bg_visible = self._bg_visible == nil
	self._bg_area = node:parameters().area_bg
	self._bg_area = not self._bg_area and "full" or self._bg_area
	self.row_item_color = Holo.options.Menu_enable == true and ColorRGB(0, 150, 255) or tweak_data.screen_colors.button_stage_2
	self.row_item_hightlight_color = Holo.options.Menu_enable == true and Color.white or tweak_data.screen_colors.button_stage_3
	self.row_item_disabled_text_color = tweak_data.menu.default_disabled_text_color
	self.item_panel_h = node:parameters().item_panel_h
	MenuNodeGui.super.init(self, node, layer, parameters)
	if node:parameters().no_item_parent then
		self._item_panel_parent:set_visible(false)
	end
end
