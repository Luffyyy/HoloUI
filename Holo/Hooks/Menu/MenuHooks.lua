if Holo.Options:GetValue("Menu") then
	local Lobby = Holo:ShouldModify("Menu", "Lobby")
	if RequiredScript == "lib/managers/menu/renderers/menunodejukeboxgui" and Lobby then
		Holo:Post(MenuNodeJukeboxGui, "init", function(self)
			self.item_panel:set_y(self.item_panel:parent():y() + 50)
		end)
	elseif RequiredScript == "lib/managers/menumanager" then
		MenuGuiTabItem.PAGE_PADDING = 2
		MenuGuiSmallTabItem.PAGE_PADDING = 2
		MenuGuiSmallTabItem.FONT_SIZE = tweak_data.menu.pd2_tiny_font_size
		MenuGuiTabItem.FONT_SIZE = tweak_data.menu.pd2_small_font_size
	elseif RequiredScript == "lib/managers/systemmenumanager" then
		core:module("SystemMenuManager")
		GenericSystemMenuManager = GenericSystemMenuManager or SystemMenuManager.GenericSystemMenuManager
		_G.Holo:Pre(GenericSystemMenuManager, "show_buttons", function(self, dialog_data)
			dialog_data.text_blend_mode = "normal" -- OVK PLS STOP :(
		end)
	elseif RequiredScript == "lib/managers/menu/buttonboxgui" then
		Holo:Post(ButtonBoxGui, "_setup_buttons_panel", callback(Holo.Utils, Holo.Utils, "FixDialog"))
	elseif RequiredScript == "lib/managers/menu/lootdropscreengui" and Lobby then
		Holo:Post(LootDropScreenGui, "init", function(self)
			self._continue_button:configure({
				font = "fonts/font_medium_mf",
				font_size = 24,
				color = Holo:GetColor("TextColors/Menu"),
			})
		end)
		Holo:Post(LootDropScreenGui, "check_all_ready", function(self)
			if managers.menu:is_pc_controller() then
				self._continue_button:set_color(Holo:GetColor("TextColors/Menu"))
			end
		end)
		Holo:Post(LootDropScreenGui, "mouse_moved", function(self, x, y)
			if self._button_not_clickable then
				self._continue_button:set_color(tweak_data.screen_colors.item_stage_1)
			elseif self._continue_button:inside(x, y) then
				if not self.continue_button_highlighted then
					self._continue_button_highlighted = true
					self.continue_button_highlighted = true
					self._continue_button:set_color(Holo:GetColor("Colors/Marker"))
				end
			elseif self.continue_button_highlighted then
				self._continue_button_highlighted = false
				self.continue_button_highlighted = false
				self._continue_button:set_color(Holo:GetColor("TextColors/Menu"))
			end
		end)
		Holo:Post(MenuGuiTabItem, "init", function(self, index, title_id, page_item, gui, tab_x, tab_panel)
			local panel = tab_panel:child("Page" .. string.capitalize(tostring(title_id)))
			Holo.Utils:NotUglyTab(panel:child("PageTabBG"), panel:child("PageText"))
		end)
		Holo:Post(MenuGuiTabItem, "refresh", function(self)
			self._page_panel:child("PageText"):set_blend_mode("normal") --PLS STOP USING ADD BLEND MODE ITS SO FUCKING UGLY AND BADDD
			self._page_panel:child("PageText"):set_color(Holo:GetColor("TextColors/Tab"))
			self._page_panel:child("PageTabBG"):set_color(self._selected and Holo:GetColor("Colors/TabHighlighted") or Holo:GetColor("Colors/Tab"))
			self._page_panel:child("PageTabBG"):show()
		end)
	elseif RequiredScript == "lib/managers/menu/items/menuitemcustomizecontroller" then
		Holo:Post(MenuItemCustomizeController, "setup_gui", function(self, node, row_item)
			row_item.controller_binding:set_color(row_item.color)
		end)
		Holo:Post(MenuItemCustomizeController, "fade_row_item", function(self, node, row_item)
			row_item.controller_binding:set_color(row_item.color)
		end)
	elseif RequiredScript == "lib/managers/menu/renderers/menunodebasegui" then
		MenuNodeBaseGui.text_color = Holo:GetColor("TextColors/Menu")
		MenuNodeBaseGui.button_default_color = Holo:GetColor("TextColors/Menu")
		MenuNodeBaseGui.button_highlighted_color = Holo:GetColor("TextColors/MenuHighlighted")
		MenuNodeBaseGui.button_selected_color = Holo:GetColor("TextColors/MenuHighlighted")
	elseif RequiredScript == "lib/managers/menu/renderers/menunodeskillswitchgui" then
		Holo:Post(MenuNodeSkillSwitchGui, "_create_menu_item", function(self, row_item)
			if row_item.type ~= "divider" and row_item.name ~= "back" then
				row_item.skill_points_gui:set_blend_mode("normal")
				row_item.status_gui:set_blend_mode("normal")
			end
		end)
	elseif RequiredScript == "core/lib/managers/menu/coremenunode" then
		core:module("CoreMenuNode")
		MenuNode = MenuNode or class()
		local o_create_item = MenuNode.create_item
		function MenuNode:create_item( data_node, params )
			if _G.Holo and params then
				params.row_item_color = _G.Holo:GetColor("TextColors/Menu")
				params.hightlight_color = _G.Holo:GetColor("TextColors/MenuHighlighted")
				params.row_item_blend_mode = "normal"
				params.marker_color = _G.Holo:GetColor("Colors/Marker")
				params.marker_disabled_color = Color(0.1, 0.1, 0.1)
			end
			return o_create_item(self, data_node, params)
		end
	elseif RequiredScript == "lib/managers/menu/infamytreegui" then
		Holo:Post(InfamyTreeGui, "_setup", function(self)
			Holo.Utils:FixBackButton(self, self._panel:child("back_button"))
		end)
	elseif RequiredScript == "lib/managers/menu/renderers/menunodecrimenetgui" then
		MenuNodeCrimenetContactChillGui.HEIGHT = 270
		function MenuNodeCrimenetContactInfoGui:_align_marker(row_item)
			MenuNodeCrimenetContactInfoGui.super._align_marker(self, row_item)
			if row_item.item:parameters().pd2_corner then
				self._marker_data.marker:set_left(row_item.menu_unselected:x() + 2)
				return
			end
		end
		function MenuNodeCrimenetContactShortGui:_align_marker(row_item)
			MenuNodeCrimenetContactShortGui.super._align_marker(self, row_item)
			if row_item.item:parameters().pd2_corner then
				self._marker_data.marker:set_left(row_item.menu_unselected:x() + 2)
				return
			end
		end
		function MenuNodeCrimenetChallengeGui:_align_marker(row_item)
			MenuNodeCrimenetChallengeGui.super._align_marker(self, row_item)
			if row_item.item:parameters().pd2_corner then
				self._marker_data.marker:set_left(row_item.menu_unselected:x() + 2)
				return
			end
		end
	elseif RequiredScript == "lib/managers/menu/renderers/menunodepreplanninggui" then
		Holo:Pre(MenuNodePrePlanningGui, "setup", function(self)
			self.large_font_size = self.font_size
		end)
		function MenuNodePrePlanningGui:_align_marker(row_item)
			MenuNodePrePlanningGui.super._align_marker(self, row_item)
			if row_item.item:parameters().pd2_corner then 
				self._marker_data.marker:set_left(row_item.menu_unselected:x() + 2)
				return
			end
		end
	elseif RequiredScript == "lib/managers/menu/renderers/menunodeupdatesgui" then
		MenuNodeUpdatesGui.PADDING = 10
		Holo:Post(MenuNodeUpdatesGui, "setup", function( self )
			Holo.Utils:FixBackButton(self, self._panel:child("back_button"))
		end)
	elseif RequiredScript == "lib/managers/menu/menupauserenderer" then
		Holo:Post(MenuPauseRenderer, "open", function(self)
			self._menu_bg:set_alpha(0)
			self._blur_bg:set_alpha(0)
			self._top_rect:set_alpha(0)
			self._bottom_rect:set_alpha(0)
			self._bg = self._fullscreen_panel:rect({
				name = "bg",
				valign = "center",
				halign ="grow",
				valign ="grow",
				alpha = 0.5,
				color = Holo:GetColor("Colors/Menu"),
				layer = -1
			})
		end)	
	elseif RequiredScript == "lib/managers/menu/playerprofileguiobject" then
		Holo:Post(PlayerProfileGuiObject, "init", function(self)
			for _, child in pairs(self._panel:children()) do
				if child.texture_name and child:texture_name() == Idstring("guis/textures/pd2/crimenet_marker_glow") then
					child:hide()
				end
			end
		end)
	elseif RequiredScript == "lib/managers/menu/newsfeedgui" then
		Holo:Post(NewsFeedGui, "update", function(self)
			local color = Holo:GetColor("TextColors/Menu")
			local color_highlight = Holo:GetColor("Colors/Marker")
			self._title_panel:child("title"):set_color(self._mouse_over and color_highlight or color)		
			self._panel:child("title_announcement"):set_color(color)
		end)
	end
end