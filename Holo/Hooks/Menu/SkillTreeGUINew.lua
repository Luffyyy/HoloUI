if Holo.Options:GetValue("Menu") then
	Hooks:PostHook(SpecializationTabItem, "init", "HoloInit", function(self)
		self._spec_tab:child("spec_tab_select_rect"):set_image("units/white_df")
		self._spec_tab:child("spec_tab_select_rect"):move(0, -4)
	end)	
	Hooks:PostHook(NewSkillTreeTabItem, "init", "HoloInit", function(self, page_tab_panel, page)
		self._page_panel:child("PageTabBG"):set_image("units/white_df")
	end)	
	Hooks:PostHook(SpecializationGuiButtonItem, "init", "HoloInit", function(self, page_tab_panel, page)
		self._btn_text:set_blend_mode("normal")
		self._panel:child("select_rect"):set_blend_mode("normal")	
	end)
	function SpecializationGuiButtonItem:refresh()
		if managers.menu:is_pc_controller() then
			self._btn_text:set_color(self._highlighted and Holo:GetColor("TextColors/Menu") or Holo:GetColor("Colors/Marker"))
		end
		self._panel:child("select_rect"):set_visible(self._highlighted)
	end
	function NewSkillTreeTabItem:refresh()
		if not alive(self._page_panel) then
			return
		end
		self._page_panel:child("PageText"):set_blend_mode("normal")
		self._page_panel:child("PageTabBG"):set_color((self._active or self._selected) and Holo:GetColor("Colors/TabHighlighted") or Holo:GetColor("Colors/Tab"))
		self._page_panel:child("PageText"):set_color(Holo:GetColor("TextColors/Tab"))
		self._page_panel:child("PageTabBG"):show()
	end
	function SpecializationTabItem:refresh()
		if not alive(self._spec_tab) then
			return
		end
		self._spec_tab:child("spec_tab_select_rect"):show()
		self._spec_tab:child("spec_tab_select_rect"):set_color((self._active or self._selected) and Holo:GetColor("Colors/TabHighlighted") or Holo:GetColor("Colors/Tab"))
		self._spec_tab:child("spec_tab_name"):set_color(Holo:GetColor("TextColors/Tab"))
		self._spec_tab:child("spec_tab_name"):set_blend_mode("normal")
	end
	function NewSkillTreeTabItem:next_page_position()
		return self._page_panel:right() + 4
	end
	Hooks:PostHook(SkillTreeGui, "_setup", "HoloSetup", function(self)
		Holo.Utils:FixBackButton(self, self._panel:child("BackButton"))
	end)	
	Hooks:PostHook(NewSkillTreeGui, "_setup", "HoloSetup", function(self)
		Holo.Utils:FixBackButton(self, self._panel:child("BackButton"))
		self._skillset_panel:child("SkillSetText"):set_blend_mode("normal")
	end)
	Hooks:PostHook(NewSkillTreeSkillItem, "refresh", "HoloRefresh", function(self)
		if alive(self._skill_panel) then		
			local step = self._skilltree:next_skill_step(self._skill_id) 
			self._skill_panel:child("SkillIconPanel"):child("Icon"):set_alpha(step > 1 and 1 or 0.25)
		end
	end)	
end