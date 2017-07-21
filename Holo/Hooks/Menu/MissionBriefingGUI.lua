if Holo:ShouldModify("Menu", "Lobby") then
Hooks:PostHook(MissionBriefingTabItem, "init", "HoloInit", function(self)
	self._tab_text:set_y(2)
	Holo.Utils:NotUglyTab(self._tab_select_rect, self._tab_text)
	local line = self._main_panel:child("line") or self._main_panel:rect({
		name = "line",
		h = 2,
		layer = 2,
		color = Holo:GetColor("Colors/TabHighlighted"),
	})
	self._main_panel:set_top(89)
	Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
end)
	 
function MissionBriefingTabItem:UpdateHolo()
	if alive(self._main_panel) and alive(self._tab_select_rect) and self._main_panel:child("line") then
		self._tab_select_rect:set_color(Holo:GetColor("Colors/Tab"))
		self._tab_text:set_color(Holo:GetColor("TextColors/Tab"))
		self._main_panel:child("line"):set_color(Holo:GetColor("Colors/TabHighlighted"))
	end
end
function MissionBriefingTabItem:reduce_to_small_font()
 
end
function MissionBriefingTabItem:update_tab_position()
	local prev_item = self._main_panel:child("tab_select_rect_" .. tostring(self._index - 1))
	local offset = prev_item and prev_item:right() or 0
	self._tab_select_rect:set_w(self._tab_text:w())
	self._tab_text:set_x(offset)
	self._tab_select_rect:set_x(offset)
end
 
function MissionBriefingTabItem:select(no_sound)
	if self._selected then
		return
	end
	self:show()
	if self._tab_text and alive(self._tab_text) then
		self._tab_text:set_color(Holo:GetColor("TextColors/Tab"))
		self._tab_text:set_blend_mode("normal")
		self._tab_select_rect:set_color(Holo:GetColor("Colors/TabHighlighted"))
	end
	self._selected = true
	if no_sound then
		return
	end
	managers.menu_component:post_event("menu_enter")
end
function MissionBriefingTabItem:deselect()
	if not self._selected then
		return
	end
	self:hide()
	if self._tab_text and alive(self._tab_text) then
		self._tab_text:set_color(Holo:GetColor("TextColors/Tab"))
		self._tab_text:set_blend_mode("normal")
		self._tab_select_rect:set_color(Holo:GetColor("Colors/Tab"))
	end
	self._selected = false
end

function MissionBriefingTabItem:mouse_moved(x, y)
	if not self._selected then
		if self._tab_text:inside(x, y) then
			if not self._highlighted then
				self._highlighted = true
				self._tab_select_rect:set_color(Holo:GetColor("Colors/TabHighlighted"))
				managers.menu_component:post_event("highlight")
			end
		elseif self._highlighted then
			self._tab_select_rect:set_color(Holo:GetColor("Colors/Tab"))
			self._highlighted = false
		end
	end
	return self._selected, self._highlighted
end
function MissionBriefingGui:ready_text()
	local legend = not managers.menu:is_pc_controller() and managers.localization:get_default_macro("BTN_Y") or ""
	local ready = self._ready and "READY" or "NOT READY"
	return legend .. ready
end
Hooks:PostHook(MissionBriefingGui, "init", "HoloInit", function(self)
	self._ready_button:set_blend_mode("normal")
	self._ready_button:set_font_size(tweak_data.menu.pd2_medium_font_size)
	managers.hud:make_fine_text(self._ready_button)
	self._ready_button:set_rightbottom(self._panel:w(), self._panel:h() + 105)
	self._multi_profile_item:panel():set_bottom(self._panel:h() + 110)
	self._ready_tick_box:hide()
	self._fullscreen_panel:child("ready_big_text"):hide()
	for _, child in pairs(self._panel:children()) do 
		if child.child and child:child("BoxGui") then
			child:child("BoxGui"):hide()
		end
	end
end)
function MissionBriefingGui:flash_ready() 
end
end