if Holo.Options:GetValue("Base/Menu") then 
	Hooks:PostHook(TextBoxGui, "add_background", "HoloAddBackground", function(self)
		self._background:hide()
	end)
	Hooks:PostHook(TextBoxGui, "_setup_buttons_panel", "HoloSetupButtonsPanel", function(self, info_area, button_list, focus_button, only_buttons)
		local has_buttons = button_list and #button_list > 0		
		local buttons_panel = info_area:child("buttons_panel")
		info_area:child("info_bg"):set_color(Holo:GetColor("Colors/MenuBackground"))
		if has_buttons then
			buttons_panel:child("selected"):configure({
				blend_mode = "normal",
				w = 2,
				h = 20,
				color = Holo:GetColor("Colors/Marker"),
				alpha = Holo.Options:GetValue("Menu/MarkerAlpha")
			})	
			if button_list then
				for _, child in pairs(buttons_panel:children()) do	
					if CoreClass.type_name(child) == "Panel" then
						child:child("button_text"):configure({
							blend_mode = "normal",
							color = Holo:GetColor("TextColors/Menu")
						})		
					end
				end
			end
			self:_set_button_selected(focus_button, true)	
		end
	end)

	function TextBoxGui:_set_button_selected(index, is_selected)
		local button_panel = self._text_box_buttons_panel:child(index - 1)
		if button_panel then
			local button_text = button_panel:child("button_text")
			local selected = self._text_box_buttons_panel:child("selected")
			if is_selected then
				button_text:set_color(Holo:GetColor("TextColors/MenuHighlighted"))
	 			selected:set_x(button_panel:right() + 2)
	 			selected:set_rotation(360)
				QuickAnim:Work(selected, "y", button_panel:y() - 1, "speed", 15)
			else
				button_text:set_color(Holo:GetColor("TextColors/Menu"))
			end
		end
	end
end
