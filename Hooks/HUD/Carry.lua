if Holo:ShouldModify("HUD", "Carrying") then
	Holo:Post(HUDTemp, "init", function(self, ...)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)

	function HUDTemp:_animate_hide_bag_panel(bag_panel)
		play_value(bag_panel, "alpha", 0)
	end

	function HUDTemp:SetPositionByTeammate()
		local tm, p
		local pos = Holo.TMPositions[Holo.Options:GetValue("Positions/Carrying")]
		local my_pos = Holo.TMPositions[Holo.Options:GetValue("Positions/MyTeammatePan")]
		local tm_pos = string.split(Holo.TMPositions[Holo.Options:GetValue("Positions/TeammatesPan")], '_')
		local tm_pos_x, tm_pos_y = tm_pos[1], tm_pos[2]
		local panels = managers.hud._teammate_panels
		local bag_panel = self._temp_panel:child("bag_panel")

		if pos == my_pos and (my_pos ~= tm_pos_x or tm_pos_y == nil) then
			tm = panels[HUDManager.PLAYER_PANEL]
		elseif pos == tm_pos_x then
			if tm_pos_x == 'right' and tm_pos_y == nil then
				tm = panels[1]
			else
				tm = panels[HUDManager.PLAYER_PANEL-1]
			end
		end
		p = tm and tm._panel or self._temp_panel

		if tm then
			bag_panel:set_world_leftbottom(p:world_x(), p:world_y() - 2)
		else
			bag_panel:set_leftbottom(0, p:h())
		end
		if pos == "center" then
			bag_panel:set_world_center_x(self._temp_panel:world_center_x())
		elseif pos == "right" then
			bag_panel:set_world_right(p:world_right())
		else
			bag_panel:set_world_x(0)
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
		if Holo:ShouldModify("HUD", "Teammate") then
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