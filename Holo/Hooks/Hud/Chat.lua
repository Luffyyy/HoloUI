if not Holo:ShouldModify(nil, "Chat") then
	return
end
HUDChat.max_lines = HUDChat.max_lines or 10
HUDChat.line_height = HUDChat.line_height or 14
HUDChat.lines_per_scroll = HUDChat.lines_per_scroll or 3

HUDChat.orig_init = HUDChat.orig_init or HUDChat.init
function HUDChat:init(ws, hud)
	local ws = managers.gui_data:create_fullscreen_workspace()	
	self._mouse_id = managers.mouse_pointer:get_id()
	self:orig_init(ws, {panel = ws:panel()})
	self._panel_width = 350
	self._links = {}
	
	self._panel:set_layer(-50)
	self._panel:set_size(self._panel_width, 400)
	self._panel:set_leftbottom(40, self._panel:parent():h() - 108)
	local output_panel = self._panel:child("output_panel")
	local bg = output_panel:child("output_bg")
	bg:set_blend_mode("normal")
	local color = Holo:GetColor("Colors/Chat")
	bg:set_gradient_points({0, color:with_alpha(0), 0.2, color:with_alpha(0.25), 1, color:with_alpha(0)})
	bg:set_alpha(Holo.Options:GetValue("HudAlpha"))
	self._scroll = ScrollablePanelModified:new(output_panel, "Messages", {
        layer = 4, 
        padding = 0.0001, 
        scroll_width = 6, 
        hide_shade = true, 
        color = Color.white,
        scroll_speed = HUDChat.line_height * HUDChat.lines_per_scroll
	})
	self._canvas = self._scroll:canvas()
	self:_layout_input_panel()
	self:_layout_output_panel()
end

Holo:Post(HUDChat, "_create_input_panel", function(self)
	self._input_panel:set_x(0)
	self._input_panel:child("say"):set_w(0)
	local text = self._input_panel:child("input_text")
	local bg = self._input_panel:child("input_bg")
	bg:set_blend_mode("normal")
	local color = Holo:GetColor("Colors/Chat")
	bg:set_gradient_points({0, color:with_alpha(0), 0.2, color:with_alpha(0.25), 1, color:with_alpha(0)})
	bg:set_alpha(Holo.Options:GetValue("HudAlpha"))

	text:set_font_size(18)
	text:set_selection_color(text:color():with_alpha(0.5))
end)

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
	if not alive(self._canvas) then
		return
	end
	local prev
	local h = 0
	for _, line in pairs(self._lines) do
		if prev then
			line:set_y(prev:bottom())			
		else
			line:set_y(0)
		end
		prev = line
		h = h + line:h()
	end
	local children = self._canvas:children()
	local max_h = 0
	output_panel:set_size(self._panel:w(), math.min(HUDChat.max_lines * HUDChat.line_height, h))
	output_panel:set_bottom(self._input_panel:top() - 2)
	self._scroll:set_size(output_panel:w(), output_panel:h())
	self._scroll:update_canvas_size()
	if self._canvas:h() > self._scroll:scroll_panel():h() then
		self._canvas:set_bottom(output_panel:h())
		self._scroll:_set_scroll_indicator()
		self._scroll:_check_scroll_indicator_states()
	end
end

Holo:Pre(HUDChat, "_on_focus", function(self)
	managers.mouse_pointer:use_mouse({
		mouse_press = callback(self, self, "mouse_pressed"),
		mouse_release = callback(self, self, "mouse_released"),
		mouse_move = callback(self, self, "mouse_moved"),
		id = self._mouse_id
    })
end)

Holo:Pre(HUDChat, "_loose_focus", function(self)
	managers.mouse_pointer:remove_mouse(self._mouse_id)
end)

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
	caret:set_world_shape(x, y + 2, 2, h - 4)
	self:set_blinking(s == e and self._focus)
	local mid = x / self._input_panel:child("input_bg"):w()
	caret:set_visible(self._focus and selected_characters == 0)
end

function HUDChat:mouse_released(o, button, x, y)
	self._scroll:mouse_released(button, x, y)
	self._start_select = nil
	self:update_caret()
end

function HUDChat:mouse_moved(o, x, y)
	local text = self._input_panel:child("input_text")
	local output_panel = self._panel:child("output_panel")
	local _, pointer = self._scroll:mouse_moved(nil, x, y) 
	if pointer then
		if managers.mouse_pointer.set_pointer_image then
			managers.mouse_pointer:set_pointer_image(pointer)
		end
		return true
	else
		if managers.mouse_pointer.set_pointer_image then
			managers.mouse_pointer:set_pointer_image("arrow")
		end
	end
	
	for i, panel in pairs(self._canvas:children()) do
		local text = panel:child("text")
		local p = text:point_to_index(x, y)
		for _, link in pairs(self._links[i]) do
			local s, e = unpack(link)
			text:clear_range_color(s - 1, e)
			if text:inside(x,y) then
				if p > 0 and (p == s or p == e or (p > s and p < e)) then
					text:set_range_color(s - 1, e, Color.purple)
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
	if button == Idstring("0") then
		if self._scroll:mouse_pressed(button, x, y) then
			return true
		end
	    for i, panel in pairs(self._canvas:children()) do
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
        local i = text:point_to_index(x, y)
        self._start_select = i
        self._select_neg = nil
        text:set_selection(i, i)
        self:update_caret()
		return true
	elseif button == Idstring("mouse wheel down") and self._scroll:is_scrollable() then
		if self._scroll:scroll(x, y, -1) then
			return true
		end
	elseif button == Idstring("mouse wheel up")  and self._scroll:is_scrollable() then
		if self._scroll:scroll(x, y, 1) then
			return true
		end
    end
    self:update_caret()
end

function HUDChat:receive_message(name, message, color, icon)
	local output_panel = self._panel:child("output_panel")
	local len = utf8.len(name) + 1
	local message_panel = self._canvas:panel({h = HUDChat.line_height,})
	local icon_bitmap = message_panel:rect({
		name = "icon",
		color = color,
		w = 2,
	})
	local line = message_panel:text({
		name = "text",
		text = string.format("%s: %s", name, message),
		font = "fonts/font_large_mf",
		font_size = HUDChat.line_height,
		w = message_panel:w() - 2,
		x = icon_bitmap:right() + 2,
		y = 2,
		halign = "left",
		vertical = "top",
		hvertical = "top",
		wrap = true,
		word_wrap = true,
	})
	local _,_,_,h = line:text_rect()
	line:set_h(h)
	message_panel:set_h(line:h())
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
	local line = {}
	table.insert(self._links, line)
	for s,e in string.gmatch(text, "()https?://[%w-_%.%?%.:/%+=&]+()") do --MUCH BETTER
		table.insert(line, {s,e})
	end
end

function HUDChat:set_layer() end