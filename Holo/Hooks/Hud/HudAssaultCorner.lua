Hooks:PostHook(HUDAssaultCorner, "init", "HoloInit", function(self)
	if self._hud_panel:child("hostages_panel") then
		self._hud_panel:child("hostages_panel"):set_visible(not Holo.Options:GetValue("Base/Info") and not Holo.Options:GetValue("Info/Infos"))
	end
	if self.UpdateHoloHUD then
		self:UpdateHoloHUD()
	end
end)
if Holo.Options:GetValue("Base/Hud") and Holo.Options:GetValue("TopHud") then
	function HUDAssaultCorner:UpdateHoloHUD()
		local hostages_panel = self._hud_panel:child("hostages_panel")
		local num_hostages = self._hostages_bg_box:child("num_hostages")
		local hostages_icon = hostages_panel:child("hostages_icon")
		local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
		local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
		local assault_panel = self._hud_panel:child("assault_panel")
		local casing_panel = self._hud_panel:child("casing_panel")
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		local icon_casingbox = casing_panel:child("icon_casingbox")
		local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
		local icon_assaultbox = assault_panel:child("icon_assaultbox")
		self._box_width = 242 
		self._box_height = 32
		HUDBGBox_recreate(self._bg_box,{
			w = self._box_width,
			h = self._box_height,
			alpha = not Holo.Options:GetValue("Assault") and 0.25,
			color = Holo.Options:GetValue("Assault") and Holo:GetColor("Colors/Assault"),
		})
		HUDBGBox_recreate(self._casing_bg_box,{
			w = self._box_width,
			h = self._box_height,
			alpha = not Holo.Options:GetValue("Casing") and 0.25,
			color = Holo.Options:GetValue("Casing") and Holo:GetColor("Colors/Casing"),
		})
		HUDBGBox_recreate(self._noreturn_bg_box,{
			w = self._box_width,
			h = self._box_height,
			alpha = not Holo.Options:GetValue("NoPointOfReturn") and 0.25,
			color = Holo.Options:GetValue("NoPointOfReturn") and Holo:GetColor("Colors/NoPointOfReturn"),
		})
		HUDBGBox_recreate(self._hostages_bg_box ,{
			w = self._box_height,
			h = self._box_height,
			color = Holo:GetColor("Colors/Hostages"),
		})
		self._hud_panel:child("buffs_panel"):set_alpha(0)
		assault_panel:set_size(400, 40)
		assault_panel:set_righttop(self._hud_panel:w(), 0)
		casing_panel:set_size(400, 40)
		casing_panel:set_righttop(self._hud_panel:w(), 0)
		point_of_no_return_panel:set_size(400, 40)
		point_of_no_return_panel:set_righttop(self._hud_panel:w(), 0)
		hostages_panel:set_size(200, 40)
		hostages_panel:set_righttop(self._hud_panel:w(), 0)
		icon_casingbox:configure({
			color = Holo.Options:GetValue("Casing") and Holo:GetColor("Colors/Casing"),
			w = 24,
			h = 24,
		})
		icon_assaultbox:configure({
			color = Holo.Options:GetValue("Assault") and Holo:GetColor("Colors/Assault"),
			w = 24,
			h = 24,
		})
		icon_noreturnbox:configure({
			color = Holo.Options:GetValue("NoPointOfReturn") and Holo:GetColor("Colors/NoPointOfReturn"),
			w = 24,
			h = 24,
		})
		icon_assaultbox:set_right(assault_panel:w())
		icon_casingbox:set_right(casing_panel:w())
		icon_noreturnbox:set_right(point_of_no_return_panel:w())
		self._bg_box:set_right(icon_assaultbox:left() - 3)
		self._casing_bg_box:set_right(icon_assaultbox:left() - 3)
		self._noreturn_bg_box:set_right(icon_assaultbox:left() - 3)
		point_of_no_return_text:set_color(Holo:GetColor("TextColors/NoPointOfReturn"))
		point_of_no_return_timer:set_color(Holo:GetColor("TextColors/NoPointOfReturn"))
		num_hostages:set_color(Holo:GetColor("TextColors/Hostages"))
		Holo:ApplySettings({point_of_no_return_timer, point_of_no_return_text, icon_assaultbox, icon_noreturnbox, icon_casingbox}, {blend_mode = "normal"})
	end	
	function HUDAssaultCorner:_show_icon_assaultbox(icon)
		local h = icon:h()
		icon:set_h(0)
		icon:set_alpha(1)
		GUIAnim.play(icon, "h", h)
	end
	if Holo.Options:GetValue("Assault") then
		Hooks:PostHook(HUDAssaultCorner, "_start_assault", "HoloStartAssault", function(self)
			self._bg_box:stop()
			self._bg_box:child("text_panel"):stop()
			self._bg_box:show()
			GUIAnim.play(self._bg_box, "left_grow", self._box_width)
	 		self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._bg_box, Holo:GetColor("TextColors/Assault"))
		end)
	end
	Hooks:PostHook(HUDAssaultCorner, "sync_set_assault_mode", "HoloSyncSetAssaultMode", function(self)
		self:UpdateHoloHUD()
	end)
	function HUDAssaultCorner:_animate_text(text_panel, bg_box, color, color_function)
		local text_list = (bg_box or self._bg_box):script().text_list
		local text_index = 0
		local texts = {}
		local padding = 10
		local function create_new_text(text_panel, text_list, text_index, texts)
			text_panel:set_size(600, text_panel:parent():h())
			text_panel:set_center_x(10)
			if texts[text_index] and texts[text_index].text then
				text_panel:remove(texts[text_index].text)
				texts[text_index] = nil
			end
			color_function = not (Holo.Options:GetValue("Assault")) and color_function
			local text_id = text_list[text_index]
			local text_string = ""
			if type(text_id) == "string" then
				text_string = managers.localization:to_upper_text(text_id)
			elseif text_id == Idstring("risk") then
				for i = 1, managers.job:current_difficulty_stars() do
					text_string = text_string .. managers.localization:get_default_macro("BTN_SKULL")
				end
			end
			local text = text_panel:text({
				text = text_string,
				align = "center",
				vertical = "center",
				blend_mode = color_function and "add",
				color = color_function and color_function() or color or self._assault_color,
				font_size = text_panel:h(),
				font = "fonts/font_large_mf",
			})
			local _, _, w, h = text:text_rect()
			text:set_size(w, h)
			texts[text_index] = {
				x = text_panel:w() + w * 0.5 + padding * 2,
				text = text
			}
		end
		while true do
			local dt = coroutine.yield()
			local last_text = texts[text_index]
			if last_text and last_text.text then
				if last_text.x + last_text.text:w() * 0.5 + padding < text_panel:w() then
					text_index = text_index % #text_list + 1
					create_new_text(text_panel, text_list, text_index, texts)
				end
			else
				text_index = text_index % #text_list + 1
				create_new_text(text_panel, text_list, text_index, texts)
			end
			local speed = 90
			for i, data in pairs(texts) do
				if data.text then
					data.text:configure({
						color = color_function and color_function() or color or self._assault_color,
						font_size = tweak_data.hud_corner.assault_size,
					})
					managers.hud:make_fine_text(data.text)
					data.x = data.x - dt * speed
					data.text:set_center_x(data.x)
					data.text:set_center_y(text_panel:h() * 0.5)
					if 0 > data.x + data.text:w() * 0.5 then
						text_panel:remove(data.text)
						data.text = nil
					end
				end
			end
		end
	end
	if Holo.Options:GetValue("Casing") then
		Hooks:PostHook(HUDAssaultCorner, "_animate_show_casing", "HoloAnimateShowCasing", function(self, casing_panel, delay_time)
			self._casing_bg_box:stop()
			self._casing_bg_box:child("text_panel"):stop()
			self._casing_bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._casing_bg_box, Holo:GetColor("TextColors/Casing"))
			self._casing_bg_box:stop()
			self._casing_bg_box:show()
			GUIAnim.play(self._casing_bg_box, "left_grow", self._box_width)
		end)
	end
	if Holo.Options:GetValue("NoPointOfReturn") then
		Hooks:PostHook(HUDAssaultCorner, "_animate_show_noreturn", "HoloAnimateShowNoReturn", function(self, point_of_no_return_panel)
			local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
			local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
			local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
			self._noreturn_bg_box:stop()
			self._noreturn_bg_box:show()
			GUIAnim.play(self._noreturn_bg_box, "left_grow", self._box_width, function()
				point_of_no_return_text:set_visible(true)
				point_of_no_return_timer:set_visible(true)
			end)
		end)
		function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
			local function flash_timer(o)
				local t = 0
				while t < 0.5 do
					t = t + coroutine.yield()
					local font_size = (tweak_data.hud_corner.noreturn_size)
					o:set_font_size(math.lerp(font_size, font_size * 1.25, n))
				end
			end
			local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
			point_of_no_return_timer:animate(flash_timer)
		end
	end
end
function HUDAssaultCorner:_show_hostages()
	if not self._point_of_no_return and not Holo.Options:GetValue("Base/Info") and not Holo.Options:GetValue("Info/Infos") and self._hud_panel:child("hostages_panel") then
		self._hud_panel:child("hostages_panel"):show()
	end
end