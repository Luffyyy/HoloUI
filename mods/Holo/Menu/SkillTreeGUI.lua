if Holo.options.Menu_enable then

function SpecializationGuiButtonItem:refresh()
	if managers.menu:is_pc_controller() then
		self._btn_text:set_color(self._highlighted and Holomenu_color_normal or Holomenu_color_marker)
	end
	self._panel:child("select_rect"):set_visible(self._highlighted)
end
function SkillTreeTabItem:refresh()
	if not alive(self._tree_tab) then
		return
	end
	self._tree_tab:child("tree_tab_select_rect"):show()
	self._tree_tab:child("tree_tab_select_rect"):set_color( (self._active or self._selected) and Holomenu_color_tab_highlight or Holomenu_color_tab)
	self._tree_tab:child("tree_tab_name"):set_color(Holomenu_color_tabtext)
	self._tree_tab:child("tree_tab_name"):set_blend_mode("normal")
end
function SpecializationTabItem:refresh()
	if not alive(self._spec_tab) then
		return
	end		
	self._spec_tab:child("spec_tab_select_rect"):show()
	self._spec_tab:child("spec_tab_select_rect"):set_color( (self._active or self._selected) and Holomenu_color_tab_highlight or Holomenu_color_tab)
	self._spec_tab:child("spec_tab_name"):set_color(Holomenu_color_tabtext)
	self._spec_tab:child("spec_tab_name"):set_blend_mode("normal")
end
function SkillTreeGui:check_skill_switch_button(x, y, force_text_update)
	local inside = false
	if x and y and self._skill_tree_panel:child("switch_skills_button"):inside(x, y) then
		if not self._skill_switch_highlight then
			self._skill_switch_highlight = true
			self._skill_tree_panel:child("switch_skills_button"):set_color(Holomenu_color_marker)
			managers.menu_component:post_event("highlight")
		end
		inside = true
	elseif self._skill_switch_highlight then
		self._skill_switch_highlight = false
		self._skill_tree_panel:child("switch_skills_button"):set_color(managers.menu:is_pc_controller() and Holomenu_color_normal or Color.black)
	end
	if x and y and self._skill_tree_panel:child("skill_set_bg"):inside(x, y) then
		if not self._skill_set_highlight then
			self._skill_set_highlight = true
			self._skill_tree_panel:child("skill_set_text"):set_color(Holomenu_color_marker)
			self._skill_tree_panel:child("skill_set_bg"):set_alpha(0.35)
			managers.menu_component:post_event("highlight")
		end
		inside = true
	elseif self._skill_set_highlight then
		self._skill_set_highlight = false
		self._skill_tree_panel:child("skill_set_text"):set_color(tweak_data.screen_colors.text)
		self._skill_tree_panel:child("skill_set_bg"):set_alpha(0)
	end
	if not managers.menu:is_pc_controller() then
		local text_id = "st_menu_respec_tree"
		local prefix = managers.localization:get_default_macro("BTN_X")
		self._skill_tree_panel:child("switch_skills_button"):set_color(tweak_data.screen_colors.text)
		self._skill_tree_panel:child("switch_skills_button"):set_text(prefix .. managers.localization:to_upper_text("menu_st_skill_switch_title"))
	end
	return inside
end
function SkillTreeGui:check_respec_button(x, y, force_text_update)
	local text_id = "st_menu_respec_tree"
	local prefix = not managers.menu:is_pc_controller() and managers.localization:get_default_macro("BTN_Y") or ""
	local macroes = {}
	if not managers.menu:is_pc_controller() then
		self._skill_tree_panel:child("respec_tree_button"):set_color(tweak_data.screen_colors.text)
		self._skill_tree_panel:child("respec_tree_button"):set_blend_mode("normal")
		self._skill_tree_panel:child("respec_tree_button"):show()
	end
	if managers.skilltree:points_spent(self._active_tree) == 0 then
		self._skill_tree_panel:child("respec_tree_button"):hide()
		self._respec_highlight = false
		prefix = ""
	elseif x and y and self._skill_tree_panel:child("respec_tree_button"):inside(x, y) then
		if not self._respec_highlight then
			self._respec_highlight = true
			self._skill_tree_panel:child("respec_tree_button"):set_color(Holomenu_color_marker)
			self._skill_tree_panel:child("respec_tree_button"):set_blend_mode("normal")
			managers.menu_component:post_event("highlight")
		end
	else
		self._respec_highlight = false
		if not managers.menu:is_pc_controller() then
			self._skill_tree_panel:child("respec_tree_button"):set_color(tweak_data.screen_colors.text)
		else
			self._skill_tree_panel:child("respec_tree_button"):set_color(Holomenu_color_normal)
			self._skill_tree_panel:child("respec_tree_button"):set_blend_mode("normal")
		end
	end
	if self._respec_text_id ~= text_id or force_text_update then
		self._respec_text_id = text_id
		self._skill_tree_panel:child("respec_tree_button"):set_text(prefix .. managers.localization:to_upper_text(text_id, macroes))
		self:make_fine_text(self._skill_tree_panel:child("respec_tree_button"))
	end
	return self._respec_highlight
end

CloneClass(SkillTreeGui)
function SkillTreeGui:_setup( ... )
	self.orig._setup(self, ...)
	back_button = self._panel:child("back_button")
	bg_back = self._fullscreen_panel:child("back_button")
	bg_back:set_visible(false)
	back_button:set_color(Holomenu_color_normal)
	back_button:set_blend_mode("normal")
	back_button:set_font_size(tweak_data.menu.pd2_medium_font_size)
	self._marker_panel = self._fullscreen_ws:panel():panel({layer = 5})
	self._back_marker = self._marker_panel:bitmap({
		color = Holomenu_color_marker,
		alpha = Holomenu_markeralpha,
		visible = false,
		layer = back_button:layer() - 1
	})
	local x,y,_,h = back_button:text_rect()
	self._back_marker:set_shape(x,y,313,h)
	local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back_button"):world_right(), self._panel:child("back_button"):world_center_y())
	self._back_marker:set_world_right(x)
	self._back_marker:set_world_center_y(y)
	self._back_marker:move(0, 10)	
	self._fullscreen_panel:child("title_bg"):hide()
	self._skill_tree_panel:child("skill_set_bg"):set_blend_mode("normal")
	self._skill_tree_panel:child("skill_set_text"):set_blend_mode("normal")
	self._skill_tree_panel:child("skill_set_bg"):set_color(Holomenu_color_normal)
end

function SkillTreeGui:mouse_moved(o, x, y)
	if self._renaming_skill_switch then
		return true, "link"
	end
	if not self._enabled then
		return
	end
	if self._spec_placing_points then
		return true, "grab"
	end
	local inside = false
	local pointer = "arrow"
	if self._is_skilltree_page_active and self._use_specialization then
		local specialization_text = self._panel:child("specialization_text")
		if specialization_text:inside(x, y) then
			if not self._specialization_text_highlighted then
				self._specialization_text_highlighted = true
				specialization_text:set_color(Holomenu_color_marker)
				managers.menu_component:post_event("highlight")
			end
			inside = true
			pointer = "link"
		elseif self._specialization_text_highlighted then
			self._specialization_text_highlighted = false
			specialization_text:set_color(Holomenu_color_normal)
		end
	elseif not self._is_skilltree_page_active and self._use_skilltree then
		local skilltree_text = self._panel:child("skilltree_text")
		if skilltree_text:inside(x, y) then
			if not self._skilltree_text_highlighted then
				self._skilltree_text_highlighted = true
				skilltree_text:set_color(Holomenu_color_marker)
				managers.menu_component:post_event("highlight")
			end
			inside = true
			pointer = "link"
		elseif self._skilltree_text_highlighted then
			self._skilltree_text_highlighted = false
			skilltree_text:set_color(Holomenu_color_normal)
		end
	end
	if self._is_skilltree_page_active and self._use_skilltree then
		if self:check_respec_button(x, y) then
			inside = true
			pointer = "link"
		elseif self:check_skill_switch_button(x, y) then
			inside = true
			pointer = "link"
		end
		if self._active_page then
			for _, item in ipairs(self._active_page._items) do
				if item:inside(x, y) then
					self:set_selected_item(item)
					inside = true
					pointer = "link"
				end
			end
		end
		for _, tab_item in ipairs(self._tab_items) do
			if tab_item:inside(x, y) then
				local same_tab_item = self._active_tree == tab_item:tree()
				self:set_selected_item(tab_item, true)
				inside = true
				pointer = same_tab_item and "arrow" or "link"
			end
		end
	elseif not self._is_skilltree_page_active and self._use_specialization then
		local inside2, pointer2 = self:moved_scroll_bar(x, y)
		if inside2 then
			return inside2, pointer2
		end
		if self._specialization_panel:child("spec_tabs_panel"):inside(x, y) then
			for _, tab_item in ipairs(self._spec_tab_items) do
				if tab_item:inside(x, y) then
					local same_tab_item = self._active_spec_tree == tab_item:tree()
					self:set_selected_item(tab_item, true)
					inside = true
					pointer = same_tab_item and "arrow" or "link"
				end
			end
		end
		for _, tab_item in ipairs(self._spec_tree_items) do
			local selected_item = tab_item:selected_item(x, y)
			if selected_item then
				self:set_selected_item(selected_item)
				inside = true
				pointer = "link"
				break
			else
				if tab_item:selected_btn(x, y) then
					inside = true
					pointer = "hand"
				end
			end
		end
		local update_select = false
		if not self._button_highlighted then
			update_select = true
		elseif self._btns[self._button_highlighted] and not self._btns[self._button_highlighted]:inside(x, y) then
			self._btns[self._button_highlighted]:set_highlight(false)
			self._button_highlighted = nil
			update_select = true
		end
		if update_select then
			for i, btn in pairs(self._btns) do
				if not self._button_highlighted and btn:visible() and btn:inside(x, y) then
					self._button_highlighted = i
					btn:set_highlight(true)
				else
					btn:set_highlight(false)
				end
			end
		end
	end
	if managers.menu:is_pc_controller() then
		if self._panel:child("back_button"):inside(x, y) then
			if not self._back_highlight then
				self._back_highlight = true
				self._panel:child("back_button"):set_color(Holomenu_color_highlight)
				self._back_marker:set_visible(true)
				managers.menu_component:post_event("highlight")
			end
			inside = true
			pointer = "link"
		elseif self._back_highlight then
			self._back_highlight = false
			self._panel:child("back_button"):set_color(Holomenu_color_normal)
			self._back_marker:set_visible(false)
		end
	end
	if not inside and self._panel:inside(x, y) then
		inside = true
		pointer = "arrow"
	end
	return inside, pointer
end

function SkillTreeGui:close()
	self._fullscreen_ws:panel():remove(self._marker_panel)
	self.orig.close(self)
end
end