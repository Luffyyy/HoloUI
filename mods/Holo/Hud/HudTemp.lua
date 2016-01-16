Holo:clone(HUDTemp)
function HUDTemp:init( ... )
	self.old.init(self, ...)
	self._stamina_pnl = self._hud_panel:panel({
		visible = Holo.options.stamina_enable,
		name = "stamina_pnl",
		layer = 0,
		w = Stamina_size + 10,
		h = Stamina_size + 10,
		halign = "right",
		valign = "center",
		alpha = 0
	})
	local Stamina_circle = self._stamina_pnl:bitmap({
		name = "Stamina_circle",
		texture = "guis/textures/pd2/hud_progress_active",
		render_template = "VertexColorTexturedRadial",
		w = Stamina_size,
		h = Stamina_size,
		layer = 2
	})	
	local Stamina_circle_bg = self._stamina_pnl:bitmap({
		name = "Stamina_circle_bg",
		texture = "guis/textures/pd2/hud_progress_active",
		render_template = "VertexColorTexturedRadial",
		alpha = 0.2,
		w = Stamina_size,
		h = Stamina_size,
		layer = 2
	})
	local Stamina_circle_low = self._stamina_pnl:bitmap({
		name = "Stamina_circle_low",
		texture = "guis/textures/pd2/hud_progress_invalid",
		render_template = "VertexColorTexturedRadial",
        alpha = 0,
		w = Stamina_size,
		h = Stamina_size,
		layer = 3
	})
	local StaminaNum = self._stamina_pnl:text({
		name = "StaminaNum",
		visible = true,
		color = StaminaNum_color,
		layer = 3,
		w = Stamina_size,
		h = Stamina_size,
		vertical = "center",
		align = "center",
		font_size = Stamina_size / 2,
		font = "fonts/font_large_mf"
	})	  
	self._stamina_pnl:set_x(Holo.options.stamina_xpos)
	self._stamina_pnl:set_y(Holo.options.stamina_ypos)
	if not Holo.options.GageHud_support then
		local bag_panel = self._temp_panel:child("bag_panel")
		self._bg_box:child("bg"):set_color(carrybox_color)
		self._bg_box:child("bg"):set_alpha(HoloAlpha)
		bag_panel:set_size(170, 50)
		self._bg_box:set_size(170, 50)
		self._bag_panel_w = bag_panel:w()
		self._bag_panel_h = bag_panel:h()
		self._bg_box:child("bag_text"):move(0, 5)
		self._bg_box:child("bag_text"):set_font_size(20)
		self._bg_box:child("bag_text"):set_color(carrybox_text_color)
		self._bg_box:child("bag_text"):set_blend_mode("normal")
	end
end
function HUDTemp:_animate_hide_bag_panel(bag_panel)
	local w, h = self._bag_panel_w, self._bag_panel_h
	local x1 = self._temp_panel:w() - w
	local x2 = self._temp_panel:w() 
	local bottom = bag_panel:bottom()
	local bag_text = self._bg_box:child("bag_text")
	bag_text:set_visible(true)
	bag_panel:set_size(w, h)
	bag_panel:set_x(x1)
	bag_panel:set_y(self:_bag_panel_bottom() - h)
    local t = 0
    while t < 0.3 do
        t = t + coroutine.yield()
        local n = 1 - math.sin(t * 300)
        bag_panel:set_x(math.lerp(x2, x1, n))
   end
	bag_panel:set_visible(false)
	bag_panel:set_size(w, h)
	bag_panel:set_x(x2)	
end
function HUDTemp:_animate_show_bag_panel(bag_panel)
	local w, h = self._bag_panel_w, self._bag_panel_h
	local x1 = self._temp_panel:w() 
	local x2 = self._temp_panel:w() - w
	local bottom = bag_panel:bottom()
	local bag_text = self._bg_box:child("bag_text")
	self._bg_box:child("bg"):set_color(carrybox_color)
	self._bg_box:child("bg"):set_alpha(HoloAlpha)
	bag_text:set_visible(true)
	bag_panel:set_size(w, h)
	bag_panel:set_x(x1)
	bag_panel:set_y(self:_bag_panel_bottom() - h)
    local t = 0
    while t < 0.3 do
        t = t + coroutine.yield()
        local n = 1 - math.sin(t * 300)
        bag_panel:set_x(math.lerp(x2 ,x1, n))
   end

	bag_panel:set_size(w, h)
	bag_panel:set_x(x2)
end 

function HUDTemp:update()	
	if not Holo.options.GageHud_support then	
		self._bg_box:child("bg"):set_color(carrybox_color)
		self._bg_box:child("bg"):set_alpha(HoloAlpha)
		self._bg_box:child("bag_text"):set_color(carrybox_text_color)
	end
	self._stamina_pnl:set_x(Holo.options.stamina_xpos)
	self._stamina_pnl:set_y(Holo.options.stamina_ypos)
	self._stamina_pnl:set_size(Stamina_size + 10, Stamina_size + 10)
	self._stamina_pnl:set_visible(Holo.options.stamina_enable)
	self._stamina_pnl:child("Stamina_circle"):set_size(Stamina_size, Stamina_size)
	self._stamina_pnl:child("Stamina_circle_bg"):set_size(Stamina_size, Stamina_size)
	self._stamina_pnl:child("Stamina_circle_low"):set_size(Stamina_size, Stamina_size)
	self._stamina_pnl:child("StaminaNum"):set_size(Stamina_size, Stamina_size)
	self._stamina_pnl:child("StaminaNum"):set_font_size(Stamina_size / 2)
end
 
function HUDTemp:set_stamina_value(value)
	self.old.set_stamina_value(self, value)
	if self._max_stamina then
		self._curr_stamina = value
		local Stamina_circle = self._stamina_pnl:child("Stamina_circle")
		local Stamina_circle_low = self._stamina_pnl:child("Stamina_circle_low")
		local Stamina_circle_bg = self._stamina_pnl:child("Stamina_circle_bg")
		local StaminaNum = self._stamina_pnl:child("StaminaNum")
		local Value = value / math.max(1, self._max_stamina)
		local Stamina = math.floor(Value * 100) 	

		StaminaNum:set_text(Stamina.."%")
	    StaminaNum:set_color(StaminaNum_color)
	    Stamina_circle:set_color(Color(1, Value, 1, 1))
	    Stamina_circle_low:set_color(Color(1, Value, 1, 1))	
	    StaminaNum:set_color(Stamina < 40 and StaminaNum_negative_color or StaminaNum_color)	

	    Stamina_circle:set_alpha(Stamina < 40 and 0 or 1)
	    Stamina_circle:set_alpha(Stamina < 40 and 0 or 1)	
	   	self._stamina_pnl:set_alpha(Stamina < 100 and 1 or 0)
	    Stamina_circle_low:set_alpha(Stamina < 40 and 1 or 0)
	    Stamina_circle_bg:set_image(Stamina < 40 and "guis/textures/pd2/hud_progress_invalid" or "guis/textures/pd2/hud_progress_active")  
	end
end
