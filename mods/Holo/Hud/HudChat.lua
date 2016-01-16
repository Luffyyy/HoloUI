if Holo.options.chat_enable then
function HUDChat:init(ws, hud)
	self._ws = managers.gui_data:create_fullscreen_workspace()
	self._hud_panel = self._ws:panel()
	self:set_channel_id(ChatManager.GAME)
	self._output_width = 400
	self._panel_width = 500
	self._lines = {}
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._enter_callback = callback(self, self, "enter_key_callback")
	self._typing_callback = 0
	self._skip_first = false
	self._panel = self._hud_panel:panel({
		name = "chat_panel",
		x = 20,
		h = 500,
		layer = -1000,
		w = self._panel_width,
		halign = "left",
		valign = "bottom"
	})
	self._panel:set_bottom(self._panel:parent():h() - 112)
	local output_panel = self._panel:panel({
		name = "output_panel",
		x = 0,
		h = 10,
		w = self._output_width,
		layer = 1
	})	
	local scroll_panel = self._panel:panel({
		name = "scroll_panel",
		x = 0,
		layer = 2
	})
	local messages_panel = output_panel:panel({
		name = "messages_panel",
		x = 0,
		h = 10,
		w = self._output_width
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_up_indicator_arrow = scroll_panel:bitmap({
		name = "scroll_up_indicator_arrow",
		texture = texture,
		visible = false,		
		texture_rect = rect,
		layer = 2,
	})
	local scroll_down_indicator_arrow = scroll_panel:bitmap({
		name = "scroll_down_indicator_arrow", 
		texture = texture,
		visible = false,
		texture_rect = rect,
		layer = 2,
		rotation = 180
	})
	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()
	scroll_panel:rect({
		name = "scroll_bar",
		alpha = 0.5,
		w = 4,
		h = bar_h,
	})
	self._mouse_id = managers.mouse_pointer:get_id()
	self:_create_input_panel()
	self:_layout_input_panel()
	self:_layout_output_panel()
end
 function HUDChat:_create_input_panel()
	self._input_panel = self._panel:panel({
		alpha = 0,
		name = "input_panel",
		x = 12,
		h = 24,
		w = self._panel_width,
		layer = 1
	})
	self._input_panel:rect({
		name = "focus_indicator",
		visible = false,
		color = Color.white:with_alpha(0.2),
		layer = 0
	})
	local say = self._input_panel:text({
		name = "say",
		text = managers.localization:text("debug_chat_say"),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		align = "left",
		halign = "left",
		vertical = "center",
		hvertical = "center",
		layer = 1
	})
	local _, _, w, h = say:text_rect()
	say:set_size(w, self._input_panel:h())
	local input_text = self._input_panel:text({
		name = "input_text",
		text = "",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		align = "left",
		halign = "left",
		vertical = "center",
		hvertical = "center",
		blend_mode = "normal",
		layer = 1,
		wrap = true,
		word_wrap = false
	})
	local caret = self._input_panel:rect({
		name = "caret",
		layer = 2,
		w = 0,
		h = 0,
		color = Color(0.05, 1, 1, 1)
	})
	self._input_panel:gradient({
		name = "input_bg",
		color = Color.black,
		alpha = 0.2,
		layer = -1,
		valign = "grow",
		h = self._input_panel:h()
	})
end
function HUDChat:_layout_output_panel()
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = self._panel:child("scroll_panel")
	local messages_panel = output_panel:child("messages_panel")	
	local scroll_up_indicator_arrow = scroll_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = scroll_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = scroll_panel:child("scroll_bar")
	messages_panel:set_w(self._output_width)	
	output_panel:set_w(self._output_width)
	local line_height = HUDChat.line_height
	local lines = 0
	for i = #self._lines, 1, -1 do
		local line = self._lines[i]
		local line_text = line:child("text")
		line:set_w(messages_panel:w() - line:left())
		local _, _, w, h = line_text:text_rect()
		line:set_h(h)
		lines = lines + line_text:number_of_lines()
	end
	local scroll_at_bottom = messages_panel:bottom() == output_panel:h()
	output_panel:set_h(line_height * math.min(10, lines))
	messages_panel:set_h(math.round(line_height * lines))
	local y = 0
	for i = #self._lines, 1, -1 do
		local line = self._lines[i]
		local line_text = line:child("text")
		local _, _, w, h = line_text:text_rect()
		line:set_bottom(messages_panel:h() - y)
		y = y + line_height * line_text:number_of_lines()
	end
	output_panel:set_bottom(self._input_panel:top())
	if 10 >= lines or scroll_at_bottom then
		messages_panel:set_bottom(output_panel:h())
	end
	scroll_up_indicator_arrow:set_righttop(output_panel:left() + 10, output_panel:top() - 2)
	scroll_down_indicator_arrow:set_rightbottom(output_panel:left() + 10, output_panel:bottom() - 2)
	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()
	scroll_bar:set_h(output_panel:h() * (bar_h / messages_panel:h() ))
	local sh = messages_panel:h() ~= 0 and messages_panel:h() or 1
	scroll_bar:set_y(scroll_up_indicator_arrow:bottom() - messages_panel:y() * (output_panel:h() - scroll_up_indicator_arrow:h() * 2) / sh)
	scroll_bar:set_center_x(scroll_down_indicator_arrow:center_x())


	local visible = (messages_panel:h() > output_panel:h()) and self._focus
	local scroll_up_visible = visible and 0 > messages_panel:top()
	local scroll_dn_visible = visible and messages_panel:bottom() > output_panel:h()
	scroll_bar:set_visible(visible)
	scroll_down_indicator_arrow:set_alpha(scroll_dn_visible and 1 or visible and 0.5 or 0)
	scroll_up_indicator_arrow:set_alpha(scroll_up_visible and 1 or visible and 0.5 or 0)
end
 
function HUDChat:_on_focus()
	if self._focus then
		return
	end
	local scroll_panel = self._panel:child("scroll_panel")
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")		
	output_panel:stop()
	output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
	local visible = messages_panel:h() > output_panel:h()
	scroll_panel:child("scroll_bar"):set_visible(visible)
	scroll_panel:child("scroll_up_indicator_arrow"):set_visible(visible)
	scroll_panel:child("scroll_down_indicator_arrow"):set_visible(visible)
	scroll_panel:child("scroll_bar"):set_alpha(0.5)
	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_show_component"))
	self._focus = true
	self._input_panel:child("focus_indicator"):set_color(Color(0.8, 1, 0.8):with_alpha(0.2))
	self._ws:connect_keyboard(Input:keyboard())
	self._ws:connect_mouse(Input:mouse())
	managers.mouse_pointer:use_mouse({
          mouse_press = callback(self, self, "mouse_pressed"),
          mouse_release = callback(self, self, "mouse_released"),
          mouse_move = callback(self, self, "mouse_moved"),
          id = self._mouse_id     
    }) 
	self._input_panel:key_press(callback(self, self, "key_press"))
	self._input_panel:key_release(callback(self, self, "key_release"))
	self._enter_text_set = false
	self:set_layer(1100)
	self:update_caret()
end
function HUDChat:_loose_focus()
	if not self._focus then
		return
	end
	local scroll_panel = self._panel:child("scroll_panel")		
	scroll_panel:child("scroll_bar"):hide()
	scroll_panel:child("scroll_up_indicator_arrow"):hide()
	scroll_panel:child("scroll_down_indicator_arrow"):hide()
	self._focus = false
	self._input_panel:child("focus_indicator"):set_color(Color.white:with_alpha(0.2))
	self._ws:disconnect_keyboard()
	self._ws:disconnect_mouse()
	self._input_panel:key_press(nil)
	self._input_panel:enter_text(nil)
	self._input_panel:key_release(nil)
	managers.mouse_pointer:remove_mouse(self._mouse_id)
	self._panel:child("output_panel"):stop()
	self._panel:child("output_panel"):animate(callback(self, self, "_animate_fade_output"))
	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_hide_input"))
	local text = self._input_panel:child("input_text")
	text:stop()
	self._input_panel:child("input_bg"):stop()
	self:set_layer(1)
	self:update_caret()
end
function HUDChat:update_caret()
	local text = self._input_panel:child("input_text")
	local caret = self._input_panel:child("caret")
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()
	if s == 0 and e == 0 then
		if text:align() == "center" then
			x = text:world_x() + text:w() / 2
		else
			x = text:world_x()
		end
		y = text:world_y()
	end
	h = text:h()
	if w < 3 then
		w = 2
	end
	if not self._focus then
		w = 0
		h = 0
	end
	caret:set_world_shape(x, y + 2, w, h - 4)
	self:set_blinking(s == e and self._focus)
	local mid = x / self._input_panel:child("input_bg"):w()
end
function HUDChat:mouse_released(o, button, x, y)
	if self._grabbed_scroll_bar then
		self._grabbed_scroll_bar = nil
	end
end
function HUDChat:mouse_moved(x, y)
	if self._grabbed_scroll_bar then
		if (y - self._current_y) > 0 then
			self:scroll_up()
		elseif (y - self._current_y) < 0 then
			self:scroll_down()
		end
		log(y - self._current_y)
		self._current_y = y
	end
end
function HUDChat:mouse_pressed(o, button, x, y)
	if self._panel:child("output_panel"):inside(x, y) then
		if button == Idstring("mouse wheel down") then				
			self:scroll_down()
		elseif button == Idstring("mouse wheel up") then
			self:scroll_up()
		end
	end	
	local scroll_panel = self._panel:child("scroll_panel")
	if button == Idstring("0") then
		if scroll_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
			self:scroll_up()
		end
		if scroll_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
			self:scroll_down()
		end
		if scroll_panel:child("scroll_bar"):inside(x, y) then
			self._grabbed_scroll_bar = true
			self._current_y = y
		end		
	end
end
 
 
 
function HUDChat:scroll_up()
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = self._panel:child("scroll_panel")
	local scroll_bar = scroll_panel:child("scroll_bar")	
	local scroll_up_indicator_arrow = scroll_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = scroll_panel:child("scroll_down_indicator_arrow")						
	local messages_panel = output_panel:child("messages_panel")
	if messages_panel:h() > output_panel:h() then
		if messages_panel:top() == 0 then
			self._one_scroll_dn_delay = true
		end
		messages_panel:set_top(math.min(0, messages_panel:top() + ChatGui.line_height))
		local sh = messages_panel:h() ~= 0 and messages_panel:h() or 1
		scroll_bar:set_y(scroll_up_indicator_arrow:bottom() - messages_panel:y() * (output_panel:h() - scroll_up_indicator_arrow:h() * 2) / sh)

		local visible = messages_panel:h() > output_panel:h()
		local scroll_up_visible = visible and 0 > messages_panel:top()
		local scroll_dn_visible = visible and messages_panel:bottom() > output_panel:h()

		scroll_bar:set_visible(visible)
		scroll_down_indicator_arrow:set_alpha(scroll_dn_visible and 1 or visible and 0.5 or 0)
		scroll_up_indicator_arrow:set_alpha(scroll_up_visible and 1 or visible and 0.5 or 0)		
		return true
	end
end
function HUDChat:scroll_down()
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = self._panel:child("scroll_panel")	
	local scroll_bar = scroll_panel:child("scroll_bar")
	local scroll_up_indicator_arrow = scroll_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = scroll_panel:child("scroll_down_indicator_arrow")				
	local messages_panel = output_panel:child("messages_panel")
	if messages_panel:h() > output_panel:h() then
		if messages_panel:bottom() == output_panel:h() then
			self._one_scroll_up_delay = true
		end
		messages_panel:set_bottom(math.max(messages_panel:bottom() - ChatGui.line_height, output_panel:h()))
		local sh = messages_panel:h() ~= 0 and messages_panel:h() or 1
		scroll_bar:set_y(scroll_up_indicator_arrow:bottom() - messages_panel:y() * (output_panel:h() - scroll_up_indicator_arrow:h() * 2) / sh)

		local visible = messages_panel:h() > output_panel:h()
		local scroll_up_visible = visible and 0 > messages_panel:top()
		local scroll_dn_visible = visible and messages_panel:bottom() > output_panel:h()

		scroll_bar:set_visible(visible)
		scroll_down_indicator_arrow:set_alpha(scroll_dn_visible and 1 or visible and 0.5 or 0)
		scroll_up_indicator_arrow:set_alpha(scroll_up_visible and 1 or visible and 0.5 or 0)

		return true
	end
end

function HUDChat:receive_message(name, message, color, icon)
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")	
	local len = utf8.len(name) + 1
	local x = 12
	local icon_bitmap
	local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_data(icon)
	local message_panel = messages_panel:panel()	
	local bg = message_panel:rect({
		color = Color.black,
		alpha = 0.1,
		x = x,
		layer = 0
	})
	icon_bitmap = message_panel:bitmap({
		name = "icon",
		color = color,
		layer = 1,
		w = 2,
		x = x,
		y = 1
	})
	x = x + 4
	local line = message_panel:text({
		name = "text",
		text = name .. ": " .. message,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size - 2,
		x = x,
		y = 0,
		align = "left",
		halign = "left",
		vertical = "top",
		hvertical = "top",
		blend_mode = "normal",
		color = color,
		wrap = true,
		word_wrap = true,
		layer = 1
	})
	local total_len = utf8.len(line:text())
	local _, _, w, h = line:text_rect()
	icon_bitmap:set_h(h - 2)
	bg:set_h(h - 2)
	line:set_h(h)
	table.insert(self._lines, message_panel)
	line:set_kern(line:kern())
	self:_layout_output_panel()
	if not self._focus then
		local output_panel = self._panel:child("output_panel")
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
	end
end

end