if not Holo.Options:GetValue("Menu") then
	return
end

local Lobby = Holo:ShouldModify("Menu", "Lobby")
local BlackScreen = Holo:ShouldModify("Menu", "BlackScreen")
local CrimeNet = Holo:ShouldModify("Menu", "CrimeNet")
local Inventory = Holo:ShouldModify("Menu", "Inventory")

local F = table.remove(string.split(RequiredScript, "/"))

if F == "menunodejukeboxgui" and Lobby then
	Holo:Post(MenuNodeJukeboxGui, "init", function(self)
		self.item_panel:set_y(self.item_panel:parent():y() + 50)
	end)
elseif F == "menumanager" then
	MenuGuiTabItem.PAGE_PADDING = 2
	MenuGuiSmallTabItem.PAGE_PADDING = 2
	MenuGuiSmallTabItem.FONT_SIZE = tweak_data.menu.pd2_tiny_font_size
	MenuGuiTabItem.FONT_SIZE = tweak_data.menu.pd2_small_font_size
	Holo:Post(MenuManager, "init", function(self)
		managers.viewport:add_resolution_changed_func(ClassClbk(Holo, "UpdateSettings"))		
	end)
elseif F == "systemmenumanager" then
	core:module("SystemMenuManager")
	GenericSystemMenuManager = GenericSystemMenuManager or SystemMenuManager.GenericSystemMenuManager
	_G.Holo:Pre(GenericSystemMenuManager, "show_buttons", function(self, dialog_data)
		dialog_data.text_blend_mode = "normal" -- OVK PLS STOP :(
	end)
elseif F == "buttonboxgui" then
	Holo:Post(ButtonBoxGui, "_setup_buttons_panel", callback(Holo.Utils, Holo.Utils, "FixDialog"))
elseif F == "lootdropscreengui" and Lobby then
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
		panel:child("PageTabBG"):set_alpha(0)
		panel:child("PageText"):configure({
			blend_mode = "normal",
			color = Holo:GetColor("TextColors/Tab"),
		})
		self._line_select = tab_panel:child("line_select") or tab_panel:rect({
			name = "line_select",
			y = panel:bottom(),
			w = 0,
			h = 2,
			layer = 3,
			color = Holo:GetColor("Colors/Tab"),
		})
	end)
	Holo:Post(MenuGuiTabItem, "refresh", function(self)
		local text = self._page_panel:child("PageText")
		text:set_blend_mode("normal")
		text:set_color(Holo:GetColor("TextColors/Tab"))
		if self:is_active() then
			play_anim(self._line_select, {set = {w = text:w(), center_x = self._page_panel:center_x()}})
		end
	end)
elseif F == "menuitemcustomizecontroller" then
	Holo:Post(MenuItemCustomizeController, "setup_gui", function(self, node, row_item)
		row_item.controller_binding:set_color(row_item.color)
	end)
	Holo:Post(MenuItemCustomizeController, "fade_row_item", function(self, node, row_item)
		row_item.controller_binding:set_color(row_item.color)
	end)
elseif F == "menunodebasegui" then
	MenuNodeBaseGui.text_color = Holo:GetColor("TextColors/Menu")
	MenuNodeBaseGui.button_default_color = Holo:GetColor("TextColors/Menu")
	MenuNodeBaseGui.button_highlighted_color = Holo:GetColor("TextColors/MenuHighlighted")
	MenuNodeBaseGui.button_selected_color = Holo:GetColor("TextColors/MenuHighlighted")
elseif F == "menunodeskillswitchgui" then
	Holo:Post(MenuNodeSkillSwitchGui, "_create_menu_item", function(self, row_item)
		if row_item.type ~= "divider" and row_item.name ~= "back" then
			row_item.skill_points_gui:set_blend_mode("normal")
			row_item.status_gui:set_blend_mode("normal")
		end
	end)
elseif F == "coremenunode" then
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
elseif F == "infamytreegui" and Inventory then
	Holo:Post(InfamyTreeGui, "_setup", function(self)
		Holo.Utils:FixBackButton(self)
	end)
elseif F == "menunodecrimenetgui" and CrimeNet then
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
elseif F == "menunodepreplanninggui" then
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
elseif F == "menunodeupdatesgui" then
	MenuNodeUpdatesGui.PADDING = 10
	Holo:Post(MenuNodeUpdatesGui, "setup", function( self )
		Holo.Utils:FixBackButton(self)
	end)
elseif F == "menupauserenderer" then
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
elseif F == "crimenetsidebargui" and CrimeNet then
	Holo:Post(CrimeNetSidebarItem, "init", function(self, sidebar, panel, parameters)
		self:set_color(Holo:GetColor("TextColors/Menu"))
		self:set_highlight_color(Holo:GetColor("TextColors/MenuHighlighted"))
	end)
	Holo:Post(CrimeNetSidebarSafehouseItem, "init", function(self)
		if managers.custom_safehouse:unlocked() and managers.custom_safehouse:is_being_raided() then
			self:set_color(Holo:GetColor("TextColors/MenuHighlighted"))
			self:set_highlight_color(Holo:GetColor("TextColors/Menu"))
		end
	end)
	function CrimeNetSidebarItem:color()
		return self._color or Holo:GetColor("TextColors/Menu")
	end
	function CrimeNetSidebarItem:set_text(text)
		self._text:set_text(string.upper(text))
	end	
	Holo:Post(CrimeNetSidebarItem, "set_pulse_color", function(self)
		self._pulse_color = nil
	end)
	Holo:Replace(CrimeNetSidebarItem, "create_glow", function(self, orig, ...)
		local p = orig(self, ...)
		p:hide()
		return p
	end)
elseif F == "crimespreemissionsmenucomponent" then
	Holo:Post(CrimeSpreeMissionButton, "init", function(self)
		self._mission_image:configure({blend_mode = "normal"})
		self._mission_image:set_layer(1)
		self._highlight:set_alpha(0)
		self._highlight_name:set_color(Color.black)
		self._border_panel:child(0):hide()
		self._active_border:set_layer(3)
		self._active_border._panel:set_alpha(0)
		self._image_panel:child("scalines"):set_alpha(0)
	end)
	
	Holo:Post(CrimeSpreeMissionButton, "refresh", function(self)
		self._active_border:set_visible(true)
		play_value(self._active_border._panel, "alpha", (self:is_active() or self:is_selected()) and 1 or 0)
	end)

	Holo:Post(CrimeSpreeStartButton, "init", function(self)
		self._highlight:configure({blend_mode = "normal", color = Holo:GetColor("Colors/Marker")})
	end)
elseif F == "walletguiobject" then
	Holo:Post(WalletGuiObject, "set_object_visible", ClassClbk(Holo.Utils, "ModifyWallet"))
	Holo:Post(WalletGuiObject, "set_object_visible", ClassClbk(Holo.Utils, "ModifyWallet"))
	Holo:Post(WalletGuiObject, "set_wallet", ClassClbk(Holo.Utils, "ModifyWallet"))
	Holo:Post(WalletGuiObject, "refresh", ClassClbk(Holo.Utils, "ModifyWallet"))
elseif F == "textboxgui" then
	Holo:Post(TextBoxGui, "add_background", function(self) self._background:hide() end)
	Holo:Post(TextBoxGui, "init", function(self) self._scroll_panel:child("text"):set_color(Holo:GetColor("TextColors/Menu")) end)
	Holo:Post(TextBoxGui, "_setup_buttons_panel", callback(Holo.Utils, Holo.Utils, "FixDialog"))
	function TextBoxGui:_set_button_selected(index, is_selected)
		local button_panel = self._text_box_buttons_panel:child(index - 1)
		if button_panel then
			local button_text = button_panel:child("button_text")
			local selected = self._text_box_buttons_panel:child("selected")
			if is_selected then
				button_text:set_color(Holo:GetColor("TextColors/MenuHighlighted"))
	 			selected:set_x(button_panel:right() + 2)
				selected:set_rotation(360)
				play_value(selected, "y", button_panel:y() - 1)
			else
				button_text:set_color(Holo:GetColor("TextColors/Menu"))
			end
		end
	end
elseif F == "menuguicomponentgeneric" then
	Holo:Post(MenuGuiComponentGeneric, "_add_back_button", function(self)
		Holo.Utils:FixBackButton(self)
	end)
elseif F == "menubackdropgui" then
	Holo:Post(MenuBackdropGUI, "_create_base_layer", function(self)
		if Holo.Options:GetValue("ColoredBackground") then
			for _, child in pairs(self._panel:children()) do
				child:hide()
				child:set_alpha(0)
			end
			self._panel:child("item_background_layer"):show()
			self._panel:child("item_background_layer"):set_alpha(1)			
			self._panel:child("item_foreground_layer"):show()
			self._panel:child("item_foreground_layer"):set_alpha(1)
			self._panel:rect({
				name = "background_simple",
				color = Holo:GetColor("Colors/Menu"),
			})	 
		end
	end)
	function MenuBackdropGUI:animate_bg_text(text)
		text:hide()
	end
elseif F == "hudlootscreen" and Lobby then
	Holo:Post(HUDLootScreen, "init", function(self)
		self._background_layer_full:child(0):hide() --fuck off with your bg text
	end)
	Holo:Post(HUDLootScreen, "create_peer", function(self, peers_panel, peer_id)
		Holo.Utils:SetBlendMode(peers_panel)
		for _, o in pairs(peers_panel:child("peer" .. tostring(peer_id)):children()) do
			if o.child then
				for _, ob in pairs(o:children()) do
					if ob:name() == "BoxGui" then
						o:hide()
					end
				end
			end
		end
	end)
	Holo:Post(HUDLootScreen, "create_selected_panel", function(self, peer_id)
		Holo.Utils:SetBlendMode(self._peers_panel)
	end)
elseif F == "multiprofileitemgui" then
	Holo:Post(MultiProfileItemGui, "init", function(self)
		if alive(self._caret) then
			self._caret:set_rotation(360)
		end
		--when will ovk stop not using names for stuff?
		for _, child in pairs(table.list_add(self._profile_panel:children(), self._quick_select_panel:children())) do
			if child and child.color and child:alpha() < 0.41 then
				child:hide()
			end
		end
	end)
	Holo:Post(MultiProfileItemGui, "update", function(self)
		if alive(self._name_text) then
			self._name_text:set_rotation(360)
		end
		local panel = self._panel:child(0)
		if alive(panel) then
			local arrow = panel:child("arrow_left")
			if alive(arrow) then
				arrow:set_rotation(360)
			end
		end
		if self._quick_select_panel_elements then
			for _, element in pairs(self._quick_select_panel_elements) do
				element:set_rotation(360)
			end
		end
		local some_shit = alive(self._profile_panel) and self._profile_panel:child(0)
		if alive(some_shit) then
			some_shit:set_rotation(360)
		end
	end)
elseif F == "hudstageendscreen" and Lobby then
	Holo:Post(HUDPackageUnlockedItem, "init", function(self)
		Holo.Utils:SetBlendMode(self._panel)
	end)
	Holo:Post(HUDStageEndScreen, "init", function(self)
		self._background_layer_full:child("stage_text"):hide()
		Holo.Utils:SetBlendMode(self._foreground_layer_safe)
		self._box._panel:hide()
		self._package_box._panel:hide()
		self._paygrade_panel:hide()
		self._coins_box:hide()
		local pg_text = self._foreground_layer_safe:child("pg_text") 
		pg_text:set_text(managers.localization:to_upper_text(tweak_data.difficulty_name_ids[Global.game_settings.difficulty]))		
		managers.hud:make_fine_text(pg_text)		
		pg_text:set_right(self._paygrade_panel:right())
		self._foreground_layer_safe:child("skip_forepanel"):set_rightbottom(self._foreground_layer_safe:w(), self._foreground_layer_safe:h() - 32)
		self._package_forepanel:set_rightbottom(self._foreground_layer_safe:w() - 50, self._foreground_layer_safe:h() - 80)
	end)
	Holo:Post(HUDStageEndScreen, "stage_spin_up", function(self)
		self._lp_text:set_font_size(48)
	end)
elseif F == "coremenuitemslider" then
	core:module("CoreMenuItemSlider")
	core:import("CoreMenuItem")
	ItemSlider = ItemSlider or class(CoreMenuItem.Item)
	local Holo = _G.Holo
	Holo:Post(ItemSlider, "setup_gui", function(self, node, row_item)
		self:set_slider_color(_G.tweak_data.screen_colors.button_stage_2:with_alpha(0.5))
		row_item.gui_slider_gfx:set_gradient_points({0, self._slider_color, 1, self._slider_color})
	end)	
	Holo:Post(ItemSlider, "fade_row_item", function(self, node, row_item)
		local col = _G.tweak_data.screen_colors.button_stage_2:with_alpha(0.25)
		row_item.gui_slider_gfx:set_gradient_points({0, self._slider_color, 1, self._slider_color})
	end)
	Holo:Post(ItemSlider, "highlight_row_item", function(self, node, row_item)
		row_item.gui_text:set_color(node.row_item_color)
		row_item.gui_slider_text:set_color(node.row_item_color)
	end)
elseif F == "ingamewaitingforplayers" and BlackScreen then
	Holo:Pre(IngameWaitingForPlayersState, "at_enter", function(self)
		if not managers.hud:exists(self.LEVEL_INTRO_GUI) then
			managers.hud:load_hud(self.LEVEL_INTRO_GUI, false, false, false, {})
		end
	end)
	Holo:Pre(IngameWaitingForPlayersState, "update", function(self)
		if self._skip_data then
	        self._skip_data = {current = 1, total = 1}
	    end
	end)
elseif F == "ingamecontractgui" and CrimeNet then
	Holo:Post(IngameContractGui, "init", function(self)
		Holo.Utils:SetBlendMode(self._panel)
	end)
elseif F == "contractbrokergui" and CrimeNet then
	Holo:Post(ContractBrokerGui, "init", function(self)
		Holo.Utils:SetBlendMode(self._panel)
		self._filter_selection_bg:set_w(0)
	end)
elseif F == "contractbrokerheistitem" and CrimeNet then
	Holo:Post(ContractBrokerHeistItem, "init", function(self)
		Holo.Utils:SetBlendMode(self._panel)
	end)
elseif F == "crimespreedetailsmenucomponent" then
	Holo:Replace(CrimeSpreeDetailsMenuComponent, "_start_page_data", function(self, orig, ...)
		local data = orig(self, ...)
		data.outline_data.sides = {0, 0, 0, 0}
		return data
	end)
elseif F == "crimespreemodifiersmenucomponent" then
	Holo:Post(CrimeSpreeButton, "init", function(self)
		self._text:set_font_size(tweak_data.menu.pd2_medium_font_size)
		self._panel:set_h(tweak_data.menu.pd2_medium_font_size)
		self._text:set_h(self._panel:h())
		self._text:set_blend_mode("normal")
		self._highlight:set_alpha(0)
	end)
elseif F == "scrollablepanel" then
	Holo:Post(ScrollablePanel, "init", function(self) --what's even the point of that shitty shade you can clearly see the scrollbar's height
		if alive(self:panel():child("scroll_up_indicator_shade")) then
			self:panel():child("scroll_up_indicator_shade"):hide()
			self:panel():child("scroll_down_indicator_shade"):hide()
		end
	end)
elseif F == "crimespreemissionendoptions" then
	Holo:Post(CrimeSpreeMissionEndOptions, "_setup", function(self)
		local prev
		for _, button in pairs(self._buttons) do
			button:panel():set_rightbottom(self._button_panel:right(), self._button_panel:h())

			if managers.menu:is_pc_controller() then
				if prev then
					button:panel():set_right(prev:panel():left() - 4)
				end
			elseif prev then
				button:panel():set_bottom(prev:panel():y())
			end

			prev = button
		end
	end)
elseif F == "lobbycharacterdata" then
	Holo:Post(LobbyCharacterData, "init", function(self)
		Holo.Utils:SetBlendMode(self._panel)
	end)
elseif F == "contractboxgui" and CrimeNet then
	Holo:Post(ContractBoxGui, "create_character_text", function(self)
		Holo.Utils:SetBlendMode(self._panel)
	end)
elseif F == "menuitemmultichoice" then
	function MenuItemMultiChoice:holo_multi_choice_fix(node, row_item) -- makes it so the multi choice isn't confusing with how it changes the alpha.
		if not row_item then
			return
		end	
		if row_item.choice_text then
			row_item.choice_text:set_color(not self._enabled and row_item.disabled_color or self:selected_option():parameters().color or tweak_data.screen_colors.button_stage_3)
		end
		if not self:left_arrow_visible() then
			row_item.arrow_left:set_alpha(self._enabled and 0.5 or 0.25)
		end
		if not self:right_arrow_visible() then
			row_item.arrow_right:set_alpha(self._enabled and 0.5 or 0.25)
		end
	end
	Holo:Post(MenuItemMultiChoice, "highlight_row_item", MenuItemMultiChoice.holo_multi_choice_fix)
	Holo:Post(MenuItemMultiChoice, "fade_row_item", MenuItemMultiChoice.holo_multi_choice_fix)
	Holo:Post(MenuItemMultiChoice, "reload", function(self, row_item, node)
		self:holo_multi_choice_fix(node, row_item)
	end)
end