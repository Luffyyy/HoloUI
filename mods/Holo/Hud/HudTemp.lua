CloneClass(HUDTemp)

Hooks:PostHook(HUDTemp, "init", "NewInit", function(self)
self._stamina_pnl = self._hud_panel:panel({
		visible = Holo.options.Stamina_enable,
		name = "stamina_pnl",
		layer = 0,
		w = 64,
		h = 128,
		halign = "right",
		valign = "center",
		alpha = 0
	})
		local Stamina_circle = self._stamina_pnl:bitmap({
		name = "Stamina_circle",
		texture = "guis/textures/pd2/hud_shield",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "alpha",
		w = StaminaSize,
		h = StaminaSize,
		layer = 2
	})
		local Stamina_circle_low = self._stamina_pnl:bitmap({
		name = "Stamina_circle_low",
		texture = "guis/textures/trial_apartment",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "alpha",
        alpha = 0,
		w = StaminaSize,
		h = StaminaSize,
		layer = 3
	})
	    local StaminaNum = self._stamina_pnl:text({
		name = "StaminaNum",
		visible = true,
		text = "",
		color = StaminaNum_color,
		blend_mode = "normal",
		layer = 3,
		w = StaminaSize,
		h = StaminaSize,
		vertical = "center",
		align = "center",
		font_size = StaminaSize / 2,
		font = "fonts/font_large_mf"
	})
	self._stamina_pnl:set_right(self._hud_panel:w())
	self._stamina_pnl:set_center_y(self._hud_panel:center_y() + 50)
end)

function HUDTemp:_animate_show_bag_panel(bag_panel)
	local w, h = self._bag_panel_w, self._bag_panel_h
	local scx = self._temp_panel:w() / 2
	local ecx = self._temp_panel:w() - w / 2
	local scy = self._temp_panel:h() / 2
	local ecy = self:_bag_panel_bottom() - self._bag_panel_h / 2
	local bottom = bag_panel:bottom()
	local center_y = bag_panel:center_y()
	local bag_text = self._bg_box:child("bag_text")
	local function open_done()
		bag_text:stop()
		bag_text:set_visible(true)
		bag_text:animate(callback(self, self, "_animate_show_text"))
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_center"), nil, w, open_done)
	bag_panel:set_size(w, h)
		if Holo.options.Baganim_disable == true then
		bag_panel:set_center_x(ecx)
		bag_panel:set_center_y(ecy)
		elseif Holo.options.Baganim_disable == false then
		bag_panel:set_center_x(scx)
		bag_panel:set_center_y(scy)
		end
        if Holo.options.Baganim_disable == false then
	wait(1)
    end
	local TOTAL_T = 0.5
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		if Holo.options.Baganim_disable == false then
		bag_panel:set_center_x(math.lerp(scx, ecx, 1 - t / TOTAL_T))
		bag_panel:set_center_y(math.lerp(scy, ecy, 1 - t / TOTAL_T))
		end
	end
	self._temp_panel:child("throw_instruction"):set_visible(true)
	bag_panel:set_size(w, h)
	bag_panel:set_center_x(ecx)
	bag_panel:set_center_y(ecy)
end

function HUDTemp:_animate_show_bag_panel_old(bag_panel)
	local w, h = self._bag_panel_w, self._bag_panel_h
	local scx = self._temp_panel:w() / 2
	local ecx = self._temp_panel:w() - w / 2
	local scy = self._temp_panel:h() / 2
	local ecy = self:_bag_panel_bottom() - self._bag_panel_h / 2
	local bottom = bag_panel:bottom()
	local center_y = bag_panel:center_y()
	local scale = 2
	bag_panel:set_size(w * scale, h * scale)
	local font_size = 24
	local bag_text = bag_panel:child("bag_text")
	bag_text:set_font_size(font_size * scale)
	bag_text:set_rotation(360)
	local _, _, tw, th = bag_text:text_rect()
	font_size = font_size * math.min(1, bag_panel:w() / (tw * 1.15))
	local TOTAL_T = 0.25
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local wm = math.lerp(0, w * scale, 1 - t / TOTAL_T)
		local hm = math.lerp(0, h * scale, 1 - t / TOTAL_T)
		bag_panel:set_size(wm, hm)
		if Holo.options.Baganim_disable == true then
		bag_panel:set_center_x(ecx)
		bag_panel:set_center_y(ecy)
	    elseif Holo.options.Baganim_disable == false then 
		bag_panel:set_center_x(scx)
		bag_panel:set_center_y(scy)
		end
		
		bag_text:set_font_size(math.lerp(0, font_size * scale, 1 - t / TOTAL_T))
	end
	wait(0.5)
	local TOTAL_T = 0.5
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local wm = math.lerp(w * scale, w, 1 - t / TOTAL_T)
		local hm = math.lerp(h * scale, h, 1 - t / TOTAL_T)
		bag_panel:set_size(wm, hm)
		if Holo.Baganim_disable == false then
		bag_panel:set_center_x(math.lerp(scx, ecx, 1 - t / TOTAL_T))
		bag_panel:set_center_y(math.lerp(scy, ecy, 1 - t / TOTAL_T))
		end
		bag_text:set_font_size(math.lerp(font_size * scale, font_size, 1 - t / TOTAL_T))
		
	end
	bag_panel:set_size(w, h)
	bag_panel:set_center_x(ecx)
	bag_panel:set_center_y(ecy)
	bag_text:set_font_size(font_size)
end
function HUDTemp:text_anim(anim_object, texts)
	for _, text in ipairs(texts) do
		text:set_visible(true)
	end
	local TOTAL_T = 0.5
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs((math.sin(t * 360 * 3))))
		for _, text in ipairs(texts) do
			text:set_alpha(alpha + 0.2)
		end
	end
	for _, text in ipairs(texts) do
		text:set_alpha(1)
	end
end
Hooks:PostHook(HUDTemp, "set_stamina_value", "set_stamina", function(self, value)
	self._curr_stamina = value
	local Stamina_circle = self._stamina_pnl:child("Stamina_circle")
	local Stamina_circle_low = self._stamina_pnl:child("Stamina_circle_low")
	local StaminaNum = self._stamina_pnl:child("StaminaNum")
	
	local Val = value / math.max(1, self._max_stamina)
	local Stamina = math.floor(Val * 100)
	StaminaNum:set_text(Stamina)
	Stamina_circle:set_color(Color(1, Val, 1, 1))
    self._stamina_pnl:set_alpha(Stamina < 100 and 1 or 0)
    
    StaminaNum:set_color(StaminaNum_color)
    Stamina_circle_low:set_color(Color(1, Val, 1, 1))

    Stamina_circle_low:set_alpha(Stamina < 40 and 1 or 0)
    Stamina_circle:set_alpha(Stamina < 40 and 0 or 1)
    StaminaNum:set_color(Stamina < 40 and Color.red or StaminaNum_color)
    if Stamina == 40 then
    if Stamina > 40 then
	Stamina_circle:animate(callback(self, self, "text_anim"), {Stamina_circle_low})
    else
	Stamina_circle_low:animate(callback(self, self, "text_anim"), {Stamina_circle})
    end
    StaminaNum:animate(callback(self, self, "text_anim"), {StaminaNum})
    end
	end)

function HUDTemp:set_max_stamina(value)
	self._max_stamina = value
	self._stamina_panel:child("stamina_threshold"):set_center_y(self._stamina_panel:h() - tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD / math.max(1, self._max_stamina) * self._stamina_panel:h())
end