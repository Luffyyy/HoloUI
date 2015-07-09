CloneClass(HUDTemp)
function HUDTemp:init(hud)
	self._hud_panel = hud.panel
	if self._hud_panel:child("temp_panel") then
		self._hud_panel:remove(self._hud_panel:child("temp_panel"))
	end
	self._temp_panel = self._hud_panel:panel({
		visible = true,
		name = "temp_panel",
		y = 0,
		valign = "scale",
		layer = 0
	})
	local throw_instruction = self._temp_panel:text({
		name = "throw_instruction",
		text = "",
		visible = false,
		alpha = 0.85,
		align = "right",
		vertical = "bottom",
		halign = "right",
		valign = "bottom",
		w = 300,
		h = 40,
		layer = 1,
		x = 8,
		y = 2,
		color = Color.white,
		font = "fonts/font_medium_mf",
		font_size = 24
	})
	self:set_throw_bag_text()
	local bag_panel = self._temp_panel:panel({
		visible = false,
		name = "bag_panel",
		halign = "right",
		valign = "bottom",
		layer = 10
	})
	self._bg_box = HUDBGBox_create(bag_panel, {
		w = 142,
		h = 56,
		x = 0,
		y = 0
	})
	bag_panel:set_size(self._bg_box:size())
	self._bg_box:text({
		name = "bag_text",
		text = [[
CARRYING:
CIRCUIT BOARDS]],
		vertical = "left",
		valign = "center",
		layer = 1,
		x = 8,
		y = 2,
		color = Color.white,
		font = "fonts/font_medium_mf",
		font_size = 24
	})
	local bag_text = bag_panel:text({
		name = "bag_text",
		visible = false,
		text = "HEJ",
		font = "fonts/font_large_mf",
		align = "center",
		vertical = "center",
		font_size = 42,
		halign = "scale",
		valign = "scale",
		color = Color.black,
		w = 128,
		h = 128
	})
	bag_text:set_size(bag_panel:size())
	bag_text:set_position(0, 4)
	self._bag_panel_w = bag_panel:w()
	self._bag_panel_h = bag_panel:h()
	bag_panel:set_right(self._temp_panel:w())
	bag_panel:set_bottom(self:_bag_panel_bottom())
	throw_instruction:set_bottom(bag_panel:top())
	throw_instruction:set_right(bag_panel:right())
	self._curr_stamina = 0
	self._max_stamina = 0
	self._stamina_panel = self._temp_panel:panel({
		visible = Holo.options.Stamina_enable,
		name = "stamina_panel",
		layer = 0,
		w = 64,
		h = 128,
		halign = "right",
		valign = "center",
		alpha = 0
	})
		local Stamina_circle = self._stamina_panel:bitmap({
		name = "Stamina_circle",
		texture = "guis/textures/pd2/hud_shield",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "alpha",
		w = StaminaSize,
		h = StaminaSize,
		layer = 2
	})
		local Stamina_circle_low = self._stamina_panel:bitmap({
		name = "Stamina_circle_low",
		texture = "guis/textures/trial_apartment",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "alpha",
        alpha = 0,
		w = StaminaSize,
		h = StaminaSize,
		layer = 2
	})
	    local StaminaNum = self._stamina_panel:text({
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
	self._stamina_panel:set_right(self._temp_panel:w())
	self._stamina_panel:set_center_y(self._temp_panel:center_y() + 50)
end

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


function HUDTemp:set_stamina_value(value)
	self._curr_stamina = value
	local Stamina_circle = self._stamina_panel:child("Stamina_circle")
	local Stamina_circle_low = self._stamina_panel:child("Stamina_circle_low")
	local StaminaNum = self._stamina_panel:child("StaminaNum")
	local Val = value / math.max(1, self._max_stamina)
	local Stamina = math.floor(Val * 100)
	StaminaNum:set_text(Stamina)
	Stamina_circle:set_color(Color(1, Val, 1, 1))
	if Stamina == 100 then 
    self._stamina_panel:set_alpha(0)
	end
	if Stamina < 100 then 
    self._stamina_panel:set_alpha(1)
	end
	if Stamina > 35 then
	Stamina_circle:set_alpha(1)
	Stamina_circle_low:set_alpha(0)
	StaminaNum:set_color(StaminaNum_color)
	end
	if Stamina < 35 then
	Stamina_circle:set_alpha(0)
	Stamina_circle_low:set_alpha(1)
	Stamina_circle_low:set_color(Color(1, Val, 1, 1))
	StaminaNum:set_color(Color.red)
	end
end

function HUDTemp:set_max_stamina(value)
	self._max_stamina = value
	--self._stamina_panel:child("stamina_threshold"):set_center_y(self._stamina_panel:h() - tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD / math.max(1, self._max_stamina) * self._stamina_panel:h())
end