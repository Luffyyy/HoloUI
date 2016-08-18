if Holo.Options:GetValue("Base/Hud") then
	Hooks:PostHook(HUDTemp, "init", "HoloInit", function(self, ...)
		self:UpdateHoloHUD()
	end)
	function HUDTemp:_animate_hide_bag_panel(bag_panel)
		GUIAnim.play(bag_panel, "left_grow", 0, function()
			bag_panel:hide()
		end)
	end
	function HUDTemp:UpdateHoloHUD()
		local scale = Holo.Options:GetValue("HudScale")
		local bag_panel = self._temp_panel:child("bag_panel")
		bag_panel:configure({
			w = 204 * scale,
			h = 32 * scale,
		})
		local teammate_panel = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]._panel
		bag_panel:set_world_rightbottom(teammate_panel:world_right(), teammate_panel:world_top() + (20 * scale))
		HUDBGBox_recreate(self._bg_box, {
			w = 204 * scale,
			h = bag_panel:h(),
			color = Holo:GetColor("Colors/Carrying"),
		})
		self._bg_box:child("bag_text"):configure({
			visible = true,
			font_size = 20 * scale,
			align = "center",
			color = Holo:GetColor("TextColors/Carrying"),
			blend_mode = "normal",
		})
		managers.hud:make_fine_text(self._bg_box:child("bag_text"))
		self._bg_box:child("bag_text"):set_center(self._bg_box:center())
	end
	function HUDTemp:show_carry_bag(carry_id, value)
		local scale = Holo.Options:GetValue("HudScale")
		local bag_panel = self._temp_panel:child("bag_panel")
		local carry_data = tweak_data.carry[carry_id]
		local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
		bag_panel:set_x(self._temp_panel:parent():w() / 2)
		self._bg_box:child("bag_text"):set_text(utf8.to_upper(managers.localization:text("hud_carrying") .. " " .. type_text))
		self:UpdateHoloHUD()
		bag_panel:set_w(0)
		local teammate_panel = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]._panel
		bag_panel:set_world_rightbottom(teammate_panel:world_right(), teammate_panel:world_top() + (20 * scale))
		bag_panel:show()
		GUIAnim.play(bag_panel, "left_grow", self._bg_box:w())
	end
end