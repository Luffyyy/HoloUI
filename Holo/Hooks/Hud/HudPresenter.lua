if Holo.Options:GetValue("Presenter") then
	Hooks:PostHook(HUDPresenter, "init", "HoloInit", function(self)
		self:UpdateHoloHUD()
	end)
	function HUDPresenter:UpdateHoloHUD()
	 	local scale = Holo.Options:GetValue("HudScale")
	 	local color = Holo:GetColor("Colors/Presenter")
	 	local title = self._bg_box:child("title")
	 	local text = self._bg_box:child("text")
		title:configure({
			color = Holo:GetColor("TextColors/Presenter"),
			font = "fonts/font_large_mf",
			font_size = 24 * scale,
			h = 24 * scale,
		})
		text:configure({
			color = Holo:GetColor("TextColors/Presenter"),
			font = "fonts/font_large_mf",
			font_size = 20 * scale,
			h = 20 * scale,
		})
		local _, _, w, _ = title:text_rect()
		title:set_w(w)
		local _, _, w2, _ = text:text_rect()
		text:set_w(w2)
	 	local w = math.max(w, w2) + (24 * scale)
		local h = 68 * scale
		local x = math.round(self._hud_panel:w() / 2 - w / 2)
		local y = 86 * scale
		HUDBGBox_recreate(self._bg_box, {
			x = x,
			y = y,
			w = w,
			h = h,
			color = Holo:GetColor("Colors/Presenter"),
		})
		self._box_width = w
		title:set_bottom(math.floor(self._bg_box:h() / 2))
		text:set_top(math.ceil(self._bg_box:h() / 2) - (4 * scale))
	end
	function HUDPresenter:_animate_present_information(present_panel, params)
		present_panel:set_visible(true)
		present_panel:set_alpha(1)
		local scale = Holo.Options:GetValue("HudScale")
		local title = self._bg_box:child("title")
		local text = self._bg_box:child("text")
		local _, _, w, _ = title:text_rect()
		title:set_w(w)
		local _, _, w2, _ = text:text_rect()
		text:set_w(w2)
		local _w = math.max(w, w2) + (24 * scale)
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
		self._bg_box:set_center_x(self._hud_panel:w() / 2)
		GUIAnim.play(self._bg_box, "center_grow", self._box_width, open_done)
	end
end
