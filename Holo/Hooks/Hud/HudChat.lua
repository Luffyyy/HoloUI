--I should really rewrite this ¯\_(ツ)_/¯ 
if Holo:ShouldModify(nil, "Chat") then
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
	self._links = {}
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
		h = 10,
		w = self._output_width,
		layer = 1
	})
	local messages_panel = output_panel:panel({
		name = "messages_panel",
		h = 10,
		w = self._output_width
	})
	local scroll_panel = output_panel:panel({
		name = "scroll_panel",
		h = 4,
		w = 3,
		layer = 2
	})
	scroll_panel:rect({
		name = "scroll_bar",
		visible = false,
		alpha = 0.5,
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
		text = managers.localization:to_upper_text("debug_chat_say"),
		font = tweak_data.menu.pd2_small_font,
		font_size = 16,
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
		font_size = 16,
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
function HUDChat:enter_text(o, s)
	if (managers.hud and managers.hud:showing_stats_screen()) or Input:keyboard():down(Idstring("left ctrl")) then
		return
	end
	if self._skip_first then
		self._skip_first = false
		return
	end
	local text = self._input_panel:child("input_text")
	if type(self._typing_callback) ~= "number" then
		self._typing_callback()
	end
	text:replace_text(s)
	local lbs = text:line_breaks()
	if #lbs > 1 then
		local s = lbs[2]
		local e = utf8.len(text:text())
		text:set_selection(s, e)
		text:replace_text("")
	end
	self:update_caret()
end
function HUDChat:update_key_down(text, k)
	local first
  	while self._key_pressed == k do
		local s, e = text:selection()
		local n = utf8.len(text:text())
		if Input:keyboard():down(Idstring("left ctrl")) then
	    	if Input:keyboard():down(Idstring("a")) then
	    		text:set_selection(0, text:text():len())
	    	elseif Input:keyboard():down(Idstring("c")) then
	    		Application:set_clipboard(tostring(text:selected_text()))
	    	elseif Input:keyboard():down(Idstring("v")) then
	    		if (self.filter == "number" and tonumber(Application:get_clipboard()) == nil) then
	    			return
	    		end
	    		self._before_text = text:text()
				text:replace_text(tostring(Application:get_clipboard()))
				local lbs = text:line_breaks()
				if #lbs > 1 then
					local s = lbs[2]
					local e = utf8.len(text:text())
					text:set_selection(s, e)
					text:replace_text("")
				end
			elseif Input:keyboard():down(Idstring("z")) and self._before_text then
				local before_text = self._before_text
				self._before_text = text:text()
				text:set_text(before_text)
	    	end
	    elseif Input:keyboard():down(Idstring("left shift")) then
	  	    if Input:keyboard():down(Idstring("left")) then
				text:set_selection(s - 1, e)
			elseif Input:keyboard():down(Idstring("right")) then
				text:set_selection(s, e + 1)
			end
	    elseif self._key_pressed == Idstring("backspace") or self._key_pressed == Idstring("delete") then
			if s == e and s > 0 then
				text:set_selection(s - 1, e)
			end

			if not (utf8.len(text:text()) < 1) or type(self._esc_callback) ~= "number" then
				text:replace_text("")
			end
		elseif k == Idstring("left") then
			if s < e then
				text:set_selection(s, s)
			elseif s > 0 then
				text:set_selection(s - 1, s - 1)
			end
		elseif k == Idstring("right") then
			if s < e then
				text:set_selection(e, e)
			elseif s < n then
				text:set_selection(s + 1, s + 1)
			end
		else
			self._key_pressed = nil
	    end
		self:update_caret()
        if not first then
            first = true
            wait(1)
        end
	    wait(0.03)
  	end
end
function HUDChat:_layout_output_panel()
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
	messages_panel:set_w(self._output_width)
	output_panel:set_w(self._output_width)
	local line_height = 16.6
	local lines = 0
	for i = #self._lines, 1, -1 do
		local line = self._lines[i]
		local line_text = line:child("text")
		local _, _, w, h = line_text:text_rect()
		line:set_h(h)
		lines = lines + line_text:number_of_lines()
	end
	local scroll_at_bottom = messages_panel:bottom() == output_panel:h()
	output_panel:set_h(math.round(line_height * math.min(10, lines)))

	messages_panel:set_h(math.round(line_height * lines))
	local y = 0
	for i = #self._lines, 1, -1 do
		local line = self._lines[i]
		local line_text = line:child("text")
		line:set_bottom(messages_panel:h() - y)
		y = y + line_text:h()
	end
	output_panel:set_bottom(self._input_panel:top())
	if 10 >= lines or scroll_at_bottom then
		messages_panel:set_bottom(output_panel:h())
	end
end
function HUDChat:set_layer()
end
function HUDChat:_on_focus()
	if self._focus then
		return
	end
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
	local scroll_panel = output_panel:child("scroll_panel")

	output_panel:stop()
	output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
	local visible = messages_panel:h() > output_panel:h()
	scroll_panel:child("scroll_bar"):set_visible(visible)
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
	self:AlignScrollBar()
	self:update_caret()
end
function HUDChat:_loose_focus()
	if not self._focus then
		return
	end
	local scroll_panel = self._panel:child("output_panel"):child("scroll_panel")
	scroll_panel:child("scroll_bar"):hide()
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
	self:AlignScrollBar()
	self:update_caret()
end
function HUDChat:update_caret()
	local text = self._input_panel:child("input_text")
	local caret = self._input_panel:child("caret")
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()
	local selected_characters = s - e
	if s == 0 and e == 0 then
		if text:align() == "center" then
			x = text:world_x() + text:w() / 2
		else
			x = text:world_x()
		end
		y = text:world_y()
	end
	h = text:h()
	if not self._focus then
		w = 0
		h = 0
	end
	text:set_selection_color(Holo:GetColor("Colors/Main"))
	caret:set_world_shape(x, y + 2, 2, h - 4)
	self:set_blinking(s == e and self._focus)
	local mid = x / self._input_panel:child("input_bg"):w()
	caret:set_visible(self._focus and selected_characters == 0)
end
function HUDChat:mouse_released(o, button, x, y)
	if self._grabbed_scroll_bar then
		self._panel:child("output_panel"):child("scroll_panel"):child("scroll_bar"):set_color(Color.white)
		self._grabbed_scroll_bar = nil
	end
	self._start_select = nil
	self:update_caret()
end
function HUDChat:mouse_moved(o, x, y)
	local text = self._input_panel:child("input_text")
	local output_panel = self._panel:child("output_panel")
    if self._grabbed_scroll_bar then
        local where = (y - output_panel:world_top()) / (output_panel:world_bottom() - output_panel:world_top())
        self:scroll(where * output_panel:child("messages_panel"):h())
    end
	    for i, panel in pairs(output_panel:child("messages_panel"):children()) do
	    	local text = panel:child("text")
	    	local p = text:point_to_index(x, y)
	    	for _, link in pairs(self._links[i]) do
	    		local s, e = unpack(link)
	    		text:clear_range_color(s - 1, e)
	    		if text:inside(x,y) then
		    		if p > 0 and (p == s or p == e or (p > s and p < e)) then
		    			text:set_range_color(s - 1, e, Holo:GetColor("Colors/Main"))
		    		end
	    		end
	    	end
		end   	    
    if self._start_select and self._old_x then
    	local i = text:point_to_index(x, y)
        local s, e = text:selection()
        local old = self._select_neg
        if i > 0 then
	        if self._select_neg == nil or (s == e) then
	            self._select_neg = (x - self._old_x) < 0
	        end
	        if self._select_neg then
	            text:set_selection(i - 1, self._start_select)
	        else
	            text:set_selection(self._start_select, i + 1)
	        end
        end
        self:update_caret()
    end
    self._old_x = x
end
function HUDChat:mouse_pressed(o, button, x, y)
	local text = self._input_panel:child("input_text")
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
	local scroll_panel = output_panel:child("scroll_panel")
	local scroll_bar = scroll_panel:child("scroll_bar")

    if button == Idstring("mouse wheel down") then
        self:scroll_down()
        self:mouse_moved( o, x, y )
        return true
    elseif button == Idstring("mouse wheel up") then
        self:scroll_up()
        self:mouse_moved( o, x, y )
        return true
    end
    if button == Idstring("0") then
	    for i, panel in pairs(messages_panel:children()) do
	    	local text = panel:child("text")
	    	if text:inside(x,y) then
		    	local p = text:point_to_index(x, y)
		    	for _, link in pairs(self._links[i]) do
		    		local s, e = unpack(link)
		    		if p > 0 and (p == s or p == e or (p > s and p < e)) then
		    			Steam:overlay_activate("url", text:text():sub(s,e))
		    		end
		    	end
	    	end
		end   	
        if scroll_bar:inside(x, y) then
            self._grabbed_scroll_bar = self
            scroll_bar:set_color(Color(0.8, 0.8, 0.8))
            return true
        end
        if not self._grabbed_scroll_bar and scroll_panel:inside(x, y) then
            self._grabbed_scroll_bar = self
            scroll_bar:set_color(Color(0.8, 0.8, 0.8))
            local where = (y - output_panel:world_top()) / (output_panel:world_bottom() - output_panel:world_top())
            self:scroll(where * messages_panel:h())
            return true
        end
        local i = text:point_to_index(x, y)
        self._start_select = i
        self._select_neg = nil
        text:set_selection(i, i)
        self:update_caret()
        return true
    end
    self:update_caret()
end
function HUDChat:scroll_up()
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
    if messages_panel:h() > output_panel:h() then
        messages_panel:set_top(math.min(0, messages_panel:top() + ChatGui.line_height))
        self:AlignScrollBar()
        return true
    end
end
function HUDChat:scroll_down()
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
    if messages_panel:h() > output_panel:h() then
        messages_panel:set_bottom(math.max(messages_panel:bottom() - ChatGui.line_height, output_panel:h()))
        self:AlignScrollBar()
        return true
    end
end

function HUDChat:scroll(y)
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
    if messages_panel:h() > output_panel:h() then
        messages_panel:set_y(math.clamp(-y, -messages_panel:h() ,0))
        messages_panel:set_bottom(math.max(messages_panel:bottom(), output_panel:h()))
        messages_panel:set_top(math.min(0, messages_panel:top()))
        self:AlignScrollBar()
        return true
    end
end

function HUDChat:AlignScrollBar()
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
    local scroll_bar = output_panel:child("scroll_panel")
    local scroll_bar_rect = scroll_bar:child("scroll_bar")
    local bar_h = output_panel:top() - output_panel:bottom()
    scroll_bar:set_h(output_panel:h())
    scroll_bar_rect:set_h(math.abs( output_panel:h() * (bar_h / messages_panel:h())))
    scroll_bar_rect:set_y( -(messages_panel:y()) * output_panel:h() / messages_panel:h())
    scroll_bar:set_visible(messages_panel:h() > output_panel:h())
end

function HUDChat:receive_message(name, message, color, icon)
	local output_panel = self._panel:child("output_panel")
	local messages_panel = output_panel:child("messages_panel")
	local len = utf8.len(name) + 1
	local message_panel = messages_panel:panel({
		x = 8,
		w = messages_panel:w() - 4,
	})
	local icon_bitmap = message_panel:rect({
		name = "icon",
		color = color,
		w = 2,
	})
	local line = message_panel:text({
		name = "text",
		text = string.format("%s: %s", name, message),
		font = "fonts/font_medium_mf",
		font_size = 16,
		w = message_panel:w() - 2,
		x = icon_bitmap:right() + 2,
		y = 0,
		align = "left",
		halign = "left",
		vertical = "top",
		hvertical = "top",
		color = color,
		wrap = true,
		word_wrap = true,
		layer = 1
	})
	local _,_,_,h = line:text_rect()
	line:set_h(h)
	icon_bitmap:set_h(line:h() - 4)
	icon_bitmap:set_center_y(line:center_y())
	table.insert(self._lines, message_panel)
	self:_layout_output_panel()
	self:check_text(line:text())
	if not self._focus then
		local output_panel = self._panel:child("output_panel")
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
	end
end
function HUDChat:check_text(text)
	table.insert(self._links, {})
	local curr = ""
	local current_link
	local link = self._links[#self._links]
	for i=1, text:len() do --Find a better way
		curr = curr .. text:sub(i, i)
		if curr:match("https?://[%w-_%.%?%.:/%+=&]+") and not current_link then
			table.insert(link, {word_start_i or 1, text:len()})
			current_link = #link
		elseif text:sub(i, i) == " " then
			if current_link then
				link[current_link][2] = i - 1
				current_link = nil
			end
			word_start_i = i + 1
	 		curr = ""
		end
	end		 
end
end
