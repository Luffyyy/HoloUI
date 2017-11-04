if Holo:ShouldModify("Hud", "Carrying") then
	Holo:Post(HUDTemp, "init", function(self, ...)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)

	function HUDTemp:_animate_hide_bag_panel(bag_panel)
		play_value(bag_panel, "alpha", 0)
	end

	function HUDTemp:SetPositionByTeammate(tm)
		if tm == nil then
			tm = self._last_tm
		end

		local me_align_method = Holo.TMPositions[Holo.Options:GetValue("Positions/MainTeammatePanel")]
		if not tm then
			if me_align_method == "left" then
				me_align_method = "right"
			else
				me_align_method = "left"
			end
		end

		local bag_panel = self._temp_panel:child("bag_panel")
		
		local p = tm and tm._panel or self._temp_panel
		if tm then
			bag_panel:set_world_leftbottom(p:world_x(), p:world_y() - 2)
		else
			bag_panel:set_leftbottom(0, p:h())
		end
		if me_align_method == "center" then
			bag_panel:set_world_center_x(p:world_center_x())
		elseif me_align_method == "right" then
			bag_panel:set_world_right(p:world_right())
		end
		self._last_tm = tm
	end

	function HUDTemp:UpdateHolo()
		local bag_panel = self._temp_panel:child("bag_panel")
		bag_panel:configure({
			w = 204,
			h = 32,
		})
		local teammate_panel = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]._panel
		if Holo:ShouldModify("Hud", "TeammateHud") then
			self:SetPositionByTeammate()
		else
			bag_panel:set_world_rightbottom(teammate_panel:world_righttop())
		end
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

		self._bg_box:child("bag_text"):set_text(utf8.to_upper(managers.localization:text("hud_carrying") .. " " .. type_text))
		self:UpdateHolo()
		bag_panel:set_alpha(0)
		bag_panel:show()
		
		play_value(bag_panel, "alpha", 1)
	end
end