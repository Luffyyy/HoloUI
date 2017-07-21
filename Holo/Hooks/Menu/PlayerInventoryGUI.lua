if Holo.Options:GetValue("Menu") then
	Hooks:PostHook(PlayerInventoryGui, "init", "HoloInit", function(self)
		Holo.Utils:FixBackButton(self, self._panel:child("back_button"))
		Holo.Utils:SetBlendMode(self._panel, "detection")
	end)
	Hooks:PostHook(PlayerInventoryGui, "mouse_moved", "HoloMouseMoved2", function(self, o, x, y)
		for _, button in ipairs(self._text_buttons) do
				if alive(button.panel) and button.panel:visible() then
					if button.panel:inside(x, y) then
						if not button._highlighted then
							button._highlighted = true
							button.highlighted = true
							managers.menu_component:post_event("highlight")
							if alive(button.text) then
								button.text:set_color(Holo:GetColor("Colors/Marker"))
							end
						end
						used, pointer = true, "link"
					elseif button._highlighted then
						button._highlighted = false
						button.highlighted = false
						button.text:set_color(Holo:GetColor("TextColors/Menu"))
					end
				end
			end
	end)
	Hooks:PostHook(PlayerInventoryGui, "setup_player_stats", "HoloSetupPlayerStats", function(self, panel, data)
		self._player_stats_titles.skill:set_color(Holo:GetColor("Colors/Marker"))
		for i, stat in ipairs(self._player_stats_shown) do
			self._player_stats_texts[stat.name].skill:set_blend_mode("normal")
			self._player_stats_texts[stat.name].skill:set_color(Holo:GetColor("Colors/Marker"))
		end
	end)
	Hooks:PostHook(PlayerInventoryGui, "set_skilltree_stats", "HoloSetSkillTreeStats", function(self, panel, data)
		self._stats_titles.aced:set_color(Holo:GetColor("Colors/Marker"))
		for i, stat in ipairs(data) do
			self._stats_texts[stat.name].aced:set_blend_mode("normal")
			self._stats_texts[stat.name].aced:set_color(Holo:GetColor("Colors/Marker"))
		end
	end)
	Hooks:PostHook(PlayerInventoryGui, "set_weapon_stats", "HoloSetWeaponStats", function(self, panel, data)
		self._stats_titles.skill:set_color(Holo:GetColor("Colors/Marker"))
		for i, stat in ipairs(data) do
			self._stats_texts[stat.name].skill:set_blend_mode("normal")
			self._stats_texts[stat.name].skill:set_color(Holo:GetColor("Colors/Marker"))
		end
	end)
	Hooks:PostHook(PlayerInventoryGui, "set_melee_stats", "HoloSetMeleeStats", function(self, panel, data)
		self._stats_titles.skill:set_color(Holo:GetColor("Colors/Marker"))
		for i, stat in ipairs(data) do
			self._stats_texts[stat.name].skill:set_blend_mode("normal")
			self._stats_texts[stat.name].skill:set_color(Holo:GetColor("Colors/Marker"))
		end
	end)
	Hooks:PostHook(PlayerInventoryGui, "create_text_button", "HoloCreateTextButton", function(self, params)
		for _, button in ipairs(self._text_buttons) do
			button.text:configure({
				color = Holo:GetColor("TextColors/Menu"),
				blend_mode = "normal"
			})
		end
	end)
	local o_create_box = PlayerInventoryGui.create_box
	function PlayerInventoryGui:create_box(params, index)
	    params.text_selected_color = Holo:GetColor("TextColors/Menu")
	    params.text_unselected_color = Holo:GetColor("TextColors/Menu")
	    params.box_selected_sides = {0, 0, 0, 2}
	    params.box_unselected_sides = {0, 0, 0, 2}
		return o_create_box(self, params, index)
	end
end