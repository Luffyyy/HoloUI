if Holo:ShouldModify("Hud", "Carrying") then
	Hooks:PostHook(HUDTemp, "init", "HoloInit", function(self, ...)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)
	function HUDTemp:_animate_hide_bag_panel(bag_panel)
		bag_panel:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), function()
			bag_panel:hide()
		end)
	end
	function HUDTemp:Bottom()
		local tm = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]
		if Holo:ShouldModify("Hud", "TeammateHud") or tm._boo then
			return tm._panel:world_top() + 24
		else
			return tm._panel:world_top()
		end 
	end
	function HUDTemp:UpdateHolo()
		local bag_panel = self._temp_panel:child("bag_panel")
		bag_panel:configure({
			w = 204,
			h = 32,
		})
		local teammate_panel = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]._panel
		bag_panel:set_world_rightbottom(teammate_panel:world_right(), self:Bottom())
		HUDBGBox_recreate(self._bg_box, {
			name = "Carrying",
			w = 204,
			h = bag_panel:h(),
		})
		self._bg_box:child("bag_text"):configure({
			visible = true,
			font_size = 20,
			align = "center",
			color = Holo:GetColor("TextColors/Carrying"),
			blend_mode = "normal",
		})
		managers.hud:make_fine_text(self._bg_box:child("bag_text"))
		self._bg_box:child("bag_text"):set_center(self._bg_box:center())
	end
	function HUDTemp:show_carry_bag(carry_id, value)
		local bag_panel = self._temp_panel:child("bag_panel")
		local carry_data = tweak_data.carry[carry_id]
		local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
		bag_panel:set_x(self._temp_panel:parent():w() / 2)
		self._bg_box:child("bag_text"):set_text(utf8.to_upper(managers.localization:text("hud_carrying") .. " " .. type_text))
		self:UpdateHolo()
		bag_panel:set_w(0)
		local teammate_panel = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]._panel
		bag_panel:set_world_rightbottom(teammate_panel:world_right(), self:Bottom())
		bag_panel:show()
		
		local right = bag_panel:right()
		bag_panel:set_w(0)
		QuickAnim:Work(bag_panel, 
			"w", self._bg_box:w(),
			"speed", 4,
			"sticky_right", right
		)
	end
end