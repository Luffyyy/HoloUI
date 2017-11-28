if not Holo:ShouldModify("Menu", "Inventory") then
	return
end

Holo:Post(PlayerInventoryGui, "init", function(self)
	Holo.Utils:FixBackButton(self)
	Holo.Utils:SetBlendMode(self._panel, "detection")
end)

Holo:Post(PlayerInventoryGui, "mouse_moved", function(self, o, x, y)
	for _, button in pairs(self._text_buttons) do
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

Holo:Post(PlayerInventoryGui, "setup_player_stats", function(self, panel, data)
	self._player_stats_titles.skill:set_color(Holo:GetColor("Colors/Marker"))
	for i, stat in pairs(self._player_stats_shown) do
		self._player_stats_texts[stat.name].skill:set_blend_mode("normal")
		self._player_stats_texts[stat.name].skill:set_color(Holo:GetColor("Colors/Marker"))
	end
end)

Holo:Post(PlayerInventoryGui, "set_skilltree_stats", function(self, panel, data)
	self._stats_titles.aced:set_color(Holo:GetColor("Colors/Marker"))
	for i, stat in pairs(data) do
		self._stats_texts[stat.name].aced:set_blend_mode("normal")
		self._stats_texts[stat.name].aced:set_color(Holo:GetColor("Colors/Marker"))
	end
end)

Holo:Post(PlayerInventoryGui, "set_weapon_stats", function(self, panel, data)
	self._stats_titles.skill:set_color(Holo:GetColor("Colors/Marker"))
	for i, stat in pairs(data) do
		self._stats_texts[stat.name].skill:set_blend_mode("normal")
		self._stats_texts[stat.name].skill:set_color(Holo:GetColor("Colors/Marker"))
	end
end)

Holo:Post(PlayerInventoryGui, "set_melee_stats", function(self, panel, data)
	self._stats_titles.skill:set_color(Holo:GetColor("Colors/Marker"))
	for i, stat in pairs(data) do
		self._stats_texts[stat.name].skill:set_blend_mode("normal")
		self._stats_texts[stat.name].skill:set_color(Holo:GetColor("Colors/Marker"))
	end
end)

Holo:Post(PlayerInventoryGui, "create_text_button", function(self, params)
	for _, button in pairs(self._text_buttons) do
		button.text:configure({
			color = Holo:GetColor("TextColors/Menu"),
			blend_mode = "normal"
		})
	end
end)

--Weirdly a prehook makes it break
Holo:Replace(PlayerInventoryGui, "create_box", function(self, orig, params, ...)
	params.text_selected_color = Holo:GetColor("TextColors/Menu")
	params.text_unselected_color = Holo:GetColor("TextColors/Menu")
	params.box_selected_sides = {0, 0, 0, 2}
	params.box_unselected_sides = {0, 0, 0, 0}
	return orig(self, params, ...)
end)