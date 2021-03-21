if not Holo:ShouldModify("Menu", "Inventory") then
	return
end

Holo:Post(NewSkillTreeGui, "_setup", function(self)
	self._skillset_panel:child("SkillSetText"):set_blend_mode("normal")
	self._panel:child("InfoRootPanel"):move(0, 8)
	self._panel:child("SkillsRootPanel"):child("PagePanel"):move(0, 8)
end)

Holo:Post(SkillTreeGui, "_setup", function(self)
	Holo.Utils:FixBackButton(self)
	if alive(self._spec_scroll_up_box) then
		self._spec_scroll_up_box._panel:set_alpha(0)
		self._spec_scroll_down_box._panel:set_alpha(0)
	end
end)

Holo:Post(NewSkillTreeSkillItem, "refresh", function(self)
	if alive(self._skill_panel) then		
		local step = self._skilltree:next_skill_step(self._skill_id)
		self._skill_panel:child("SkillIconPanel"):child("Icon"):set_alpha(step > 1 and 1 or 0.25)
	end
end)

Holo:Post(SpecializationGuiButtonItem, "init", function(self, page_tab_panel, page)
	self._btn_text:set_blend_mode("normal")
	self._panel:child("select_rect"):set_blend_mode("normal")	
end)
function SpecializationGuiButtonItem:refresh()
	if managers.menu:is_pc_controller() then
		self._btn_text:set_color(self._highlighted and Holo:GetColor("TextColors/Menu") or Holo:GetColor("Colors/Marker"))
	end
	self._panel:child("select_rect"):set_visible(self._highlighted)
end

Holo:Post(SpecializationTabItem, "init", function(self)
	self._spec_tab:child("spec_tab_select_rect"):set_alpha(0)
	Holo.Utils:TabInit(self, self._spec_tab:child("spec_tab_name"), self._spec_tab:parent())
end)
Holo:Post(SpecializationTabItem, "refresh", ClassClbk(Holo.Utils, "TabUpdate"))
Holo:Post(SpecializationTabItem, "set_tab_position", ClassClbk(Holo.Utils, "TabUpdate"))

Holo:Post(NewSkillTreeTabItem, "init", function(self)
	self._page_panel:child("PageTabBG"):set_alpha(0)
	Holo.Utils:TabInit(self, self._page_panel:child("PageText"), self._page_panel:parent())
end)
Holo:Post(NewSkillTreeTabItem, "refresh", ClassClbk(Holo.Utils, "TabUpdate"))
Holo:Post(NewSkillTreeTabItem, "set_tab_position", ClassClbk(Holo.Utils, "TabUpdate"))
Holo:Post(SkillTreeGui, "_setup", function(self)
	self._spec_scroll_up_box._panel:set_alpha(0)
	self._spec_scroll_down_box._panel:set_alpha(0)
end)
