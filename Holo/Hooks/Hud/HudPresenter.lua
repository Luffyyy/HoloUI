if Holo:ShouldModify("Hud", "Presenter") then
	Hooks:PostHook(HUDPresenter, "init", "HoloInit", function(self)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)
	function HUDPresenter:UpdateHolo()
	 	local color = Holo:GetColor("Colors/Presenter")
	 	local title = self._bg_box:child("title")
	 	local text = self._bg_box:child("text")
		title:configure({
			color = Holo:GetColor("TextColors/Presenter"),
			font = "fonts/font_large_mf",
			font_size = 24,
			h = 24,
		})
		text:configure({
			color = Holo:GetColor("TextColors/Presenter"),
			font = "fonts/font_large_mf",
			font_size = 20,
			h = 20,
		})
		local _, _, w, _ = title:text_rect()
		title:set_w(w)
		local _, _, w2, _ = text:text_rect()
		text:set_w(w2)
	 	local w = math.max(w, w2) + 24
		local h = 68
		local x = math.round(self._hud_panel:w() / 2 - w / 2)
		local y = 86 
		HUDBGBox_recreate(self._bg_box, {
			name = "Presenter",
			x = x,
			y = y,
			w = w,
			h = h,
		})
		self._box_width = w
		title:set_bottom(math.floor(self._bg_box:h() / 2))
		text:set_top(math.ceil(self._bg_box:h() / 2) - 4)
	end
	function HUDPresenter:_animate_present_information(present_panel, params)
		present_panel:set_visible(true)
		present_panel:set_alpha(1)
		local title = self._bg_box:child("title")
		local text = self._bg_box:child("text")
		local _, _, w, _ = title:text_rect()
		title:set_w(w)
		local _, _, w2, _ = text:text_rect()
		text:set_w(w2)
		local _w = math.max(w, w2) + 24
		self._box_width = _w
 		local function open_done()
			title:set_visible(true)
			text:set_visible(true)
			title:animate(callback(self, self, "_animate_show_text"), text)
			wait(params.seconds)
			title:animate(callback(self, self, "_animate_hide_text"), text)
			wait(0.5)
			local function close_done()
				present_panel:set_visible(false)
				self:_present_done()
			end
			self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_center"), close_done)
		end
		self._bg_box:stop()
		self._bg_box:set_w(0)
		local center_x = self._hud_panel:w() / 2
		self._bg_box:set_center_x(center_x)
		QuickAnim:Work(self._bg_box, 
			"w", self._box_width,
			"speed", 4, 
			"sticky_center_x", center_x, 
			"callback", open_done
		)
	end
end
