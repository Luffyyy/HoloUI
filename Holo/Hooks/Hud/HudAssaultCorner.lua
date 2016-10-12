if Holo.Options:GetValue("HudBox") and Holo:ShouldModify("Hud", "HudAssault") then
	function HUDAssaultCorner:UpdateHolo()
		if not alive(self._bg_box) then -- Try not to crash :c
			Holo:log("[ERROR] Something went wrong when trying to modify HUDAssaultCorner")
			return
		end
		local hostages_panel = self._hud_panel:child("hostages_panel")
		local num_hostages = self._hostages_bg_box:child("num_hostages")
		local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
		local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
		local assault_panel = self._hud_panel:child("assault_panel")
		local casing_panel = self._hud_panel:child("casing_panel")
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		self._box_width = 242 
		self._box_height = 32
		HUDBGBox_recreate(self._bg_box,{
			name = "Assault",
			w = self._box_width,
			h = self._box_height,
		})
		HUDBGBox_recreate(self._casing_bg_box,{
			name = "Casing",
			w = self._box_width,
			h = self._box_height,
		})
		HUDBGBox_recreate(self._noreturn_bg_box,{
			name = "NoPointOfReturn",
			w = self._box_width,
			h = self._box_height,
		})
		HUDBGBox_recreate(self._hostages_bg_box ,{
			name = "Hostages",
			w = self._box_height,
			h = self._box_height,
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
		if self._is_offseted then
			hostages_panel:set_y(self._bg_box:h() + 8)
		end
		self._bg_box:set_right(assault_panel:w())
		self._casing_bg_box:set_right(assault_panel:w())
		self._noreturn_bg_box:set_right(assault_panel:w())
		self._hostages_bg_box:set_right(hostages_panel:w())
		hostages_panel:child("hostages_icon"):set_right(self._hostages_bg_box:left())
		assault_panel:child("icon_assaultbox"):hide()
		casing_panel:child("icon_casingbox"):hide()
		point_of_no_return_panel:child("icon_noreturnbox"):hide()
		point_of_no_return_text:set_color(Holo:GetColor("TextColors/NoPointOfReturn"))
		point_of_no_return_timer:set_color(Holo:GetColor("TextColors/NoPointOfReturn"))
		num_hostages:set_color(Holo:GetColor("TextColors/Hostages"))
		num_hostages:set_shape(0,0,num_hostages:parent():size())
		Holo:Apply({point_of_no_return_timer, point_of_no_return_text, num_hostages}, {blend_mode = "normal", font = "fonts/font_medium_noshadow_mf", font_size = self._box_height - 6, y = -4})
		num_hostages:set_y(-2)
	end	
	Hooks:PostHook(HUDAssaultCorner, "init", "HoloInit", function(self)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)
	function HUDAssaultCorner:_show_icon_assaultbox(icon)
		icon:set_alpha(1)
		Swoosh:work(icon, "rotation", 360, "callback", function()
			icon:set_rotation(0)
		end)
	end
	function HUDAssaultCorner:left_grow(o, clbk)
		local right = o:right()
		Swoosh:work(o, 
			"w", self._box_width, 
			"speed", 4,
			"after", function()
				o:set_right(right)
			end,
			"callback", clbk
		)
	end	
	Hooks:PostHook(HUDAssaultCorner, "_start_assault", "HoloStartAssault", function(self)
		if alive(self._bg_box) then
			self._bg_box:stop()
			self._bg_box:child("text_panel"):stop()
			self._bg_box:show()
			self:left_grow(self._bg_box)
	 		self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._bg_box, Holo:GetColor("TextColors/Assault"))
	 	end
	end)
	Hooks:PostHook(HUDAssaultCorner, "sync_set_assault_mode", "HoloSyncSetAssaultMode", function(self)
		self:UpdateHolo()
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
			color_function = nil
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
				font_size = text_panel:h() - 6,
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
						font_size = text_panel:h() - 6,
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
			start_speed = nil
		end
	end
	Hooks:PostHook(HUDAssaultCorner, "_animate_show_casing", "HoloAnimateShowCasing", function(self, casing_panel, delay_time)
		if alive(self._casing_bg_box) then
			self._casing_bg_box:child("text_panel"):stop()
			self._casing_bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._casing_bg_box, Holo:GetColor("TextColors/Casing"))
			self._casing_bg_box:stop()
			self._casing_bg_box:show()
			self:left_grow(self._casing_bg_box)
		end
	end)
	Hooks:PostHook(HUDAssaultCorner, "_animate_show_noreturn", "HoloAnimateShowNoReturn", function(self, point_of_no_return_panel)
		if alive(self._noreturn_bg_box) then
			local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
			local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
			local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
			self._noreturn_bg_box:stop()
			self._noreturn_bg_box:show()
			self:left_grow(self._noreturn_bg_box, function()
				point_of_no_return_text:show()
				point_of_no_return_timer:show()
			end)
		end
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
	Hooks:PostHook(HUDAssaultCorner, "_set_hostage_offseted", "HoloSetHostageOffested", function(self, is_offseted)
		self._is_offseted = is_offseted
	end)
	Hooks:PostHook(HUDAssaultCorner, "set_control_info", "HoloSetControlInfo", function(self)
		if alive(self._hostages_bg_box) then
			self._hostages_bg_box:child("bg"):stop()
			self._hostages_bg_box:child("num_hostages"):stop()
			self._hostages_bg_box:child("num_hostages"):animate(callback(nil, Swoosh, "flash_icon"), 2, nil, true)
		end
	end)
end
 
 