if not Holo:ShouldModify(nil, "Chat") then
	return
end
HUDChat.max_lines = HUDChat.max_lines or 6
HUDChat.line_h = HUDChat.line_h or 16
HUDChat.lines_per_scroll = HUDChat.lines_per_scroll or 3

HUDChat.orig_init = HUDChat.orig_init or HUDChat.init
function HUDChat:init()
	local ws = managers.gui_data:create_fullscreen_workspace()
	self._mouse_id = managers.mouse_pointer:get_id()
	self:orig_init(ws, {panel = ws:panel()})
	self._panel_width = 280
	self._links = {}
	self._panel:set_layer(20)
	self._panel:set_size(self._panel_width, 400)
	self._panel:set_leftbottom(40, self._panel:parent():h() - 108)
	self._scroll = ScrollablePanelModified:new(self._panel:child("output_panel"), "Messages", {
        layer = 4, 
        padding = 0, 
        scroll_width = 6, 
        hide_shade = true, 
        scroll_speed = HUDChat.line_h * HUDChat.lines_per_scroll
	})
	self._canvas = self._scroll:canvas()
	self:_layout_input_panel()
	self:_layout_output_panel()
	self:UpdateHolo()
	Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
end

function HUDChat:UpdateHolo()
	self._panel:set_position(Holo.Options:GetValue("Positions/ChatX"), Holo.Options:GetValue("Positions/ChatY"))
	self:_layout_output_panel()
	local color = Holo:GetColor("Colors/Chat")
	local text_color = Holo:GetColor("TextColors/Chat")
	
	local text = self._input_panel:child("input_text")
	local input_bg = self._input_panel:child("input_bg")
	local output_panel = self._panel:child("output_panel")
	local bg = output_panel:child("output_bg")
	
	self._scroll:set_scroll_color(text_color:with_alpha(0.5))
	
	bg:set_blend_mode("normal")
	bg:set_gradient_points({0, color, 1, color})
	bg:set_alpha(Holo.Options:GetValue("HUDAlpha"))

	input_bg:set_blend_mode("normal")
	input_bg:set_gradient_points({0, color, 1, color})
	input_bg:set_alpha(Holo.Options:GetValue("HUDAlpha"))

	text:configure({
		wrap = true,
		word_wrap = true,
		font_size = 18,
		text_color = text_color,
		y = -2,
		h = self._input_panel:h(),
		selection_color = text_color:with_alpha(0.5),
		vertical = "bottom"
	})	
end

Holo:Post(HUDChat, "_create_input_panel", function(self)
	self._input_panel:set_x(0)
	self._input_panel:child("say"):set_w(0)
	self:update_caret(0)
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
	local lbs = text:line_breaks()
	if #lbs <= 2 then
		text:replace_text(s)
	end
	self:update_caret()
end

local KB = BeardLib.Utils.Input
function HUDChat:update_key_down(text, k)
	local first
  	while self._key_pressed == k do
		local s, e = text:selection()
		local n = utf8.len(text:text())
		if ctrl() then
	    	if KB:Down("a") then
	    		text:set_selection(0, text:text():len())
	    	elseif Input:keyboard():down(Idstring("c")) then
	    		Application:set_clipboard(tostring(text:selected_text()))
	    	elseif KB:Down("v") then
	    		if (self.filter == "number" and tonumber(Application:get_clipboard()) == nil) then
	    			return
				end
				local before_text = text:text()
				local paste = tostring(Application:get_clipboard())
				text:replace_text(paste)
				local lbs = text:line_breaks()
				if #lbs <= 2 then
					self._before_text = before_text
					local s,_ = text:selection()
					s = s + paste:len()
					text:set_selection(s, s)
				else
					text:set_text(before_text)		
				end
			elseif shift() then
                if KB:Down(Idstring("left")) then text:set_selection(s - 1, e)
                elseif KB:Down(Idstring("right")) then text:set_selection(s, e + 1) end
			elseif KB:Down("z") and self._before_text then
				local before_text = self._before_text
				self._before_text = text:text()
				text:set_text(before_text)
	    	end
	    elseif KB:Down("left shift") then
	  	    if KB:Down("left") then
				text:set_selection(s - 1, e)
			elseif KB:Down("right") then
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
            wait(0.5)
        end
	    wait(0.01)
  	end
end

function HUDChat:_layout_output_panel()
	local output_panel = self._panel:child("output_panel")
	if not alive(self._canvas) then
		return
	end
	local prev
	local h = 0
	local text_color = Holo:GetColor("TextColors/Chat")
	for _, line in pairs(self._lines) do
		if prev then
			line:set_y(prev:bottom() + 2)			
		else
			line:set_y(2)
		end
		prev = line
		h = h + line:h() + 2
	end
	local children = self._canvas:children()
	local max_h = 0
	output_panel:set_size(self._panel:w(), math.min((HUDChat.max_lines + 1) * HUDChat.line_h + 4, h))
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
    local lines = math.max(1, text:number_of_lines())
    local s, e = text:selection()
	local x, y = text:character_rect(self._select_neg and s or e)
	local caret = self._input_panel:child("caret")
	
    if s == 0 and e == 0 then
		caret:set_world_x(text:world_x())
		caret:set_center_y(self._input_panel:h() / 2)	
	else
		caret:set_world_position(x, y)
	end
    caret:set_size(2, text:font_size())
    caret:set_alpha(1)
    caret:set_visible(self._focus)
    caret:set_color(text:color():with_alpha(1))
end

function HUDChat:_animate_input_bg(o)
	local alpha = Holo.Options:GetValue("HUDAlpha")
	play_value(o, "alpha", alpha)
	play_value(self._panel:child("output_panel"):child("output_bg"), "alpha", alpha)
	self._scroll._scroll_bar:set_alpha(1)
	self._scroll:set_element_alpha_target("scroll_up_indicator_arrow", alpha, 100)
	self._scroll:set_element_alpha_target("scroll_down_indicator_arrow", alpha, 100)
end

function HUDChat:_animate_hide_input(o)
	play_value(o, "alpha", 0)
	play_value(self._panel:child("output_panel"):child("output_bg"), "alpha", 0)
	self._scroll._scroll_bar:set_alpha(0)
	self._scroll:set_element_alpha_target("scroll_up_indicator_arrow", 0, 100)
	self._scroll:set_element_alpha_target("scroll_down_indicator_arrow", 0, 100)
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
					text:set_range_color(s - 1, e, Color("0000EE"))
				end
			end
		end
	end
    if self._start_select and self._old_x then
        local i = text:point_to_index(x, y)
        local s, e = text:selection()
        local old = self._select_neg
        if self._select_neg == nil or (s == e) then
            self._select_neg = (x - self._old_x) < 0
        end
        if self._select_neg then
            text:set_selection(i - 1, self._start_select)
        else
            text:set_selection(self._start_select, i + 1)
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
	local message_panel = self._canvas:panel({x = 4, w = self._canvas:w() - 8, h = HUDChat.line_h})
	local icon_bitmap = message_panel:rect({
		name = "icon",
		color = color,
		w = 2,
	})
	local line = message_panel:text({
		name = "text",
		text = string.format("%s: %s", name, message),
		font = "fonts/font_large_mf",
		font_size = HUDChat.line_h,
		kerning = 0,
		color = color,
		x = icon_bitmap:right() + 2,
		y = 2,
		w = message_panel:w() - 4,
		halign = "left",
		vertical = "top",
		hvertical = "top",
		wrap = true,
		word_wrap = true,
	})
	local _,_,_,h = line:text_rect()
	line:set_h(h)
	message_panel:set_h(line:h() + 2)
	icon_bitmap:set_h(line:h() - 2)
	icon_bitmap:set_center_y(line:center_y() - 1)
	table.insert(self._lines, message_panel)
	self:_layout_output_panel()
	self:check_text(line:text())
	local chatgui = managers.menu_component._game_chat_gui
	if chatgui and chatgui:enabled() then
		self._panel:child("output_panel"):set_alpha(0)
		self._input_panel:set_alpha(0)
		return
	end

	if not self._focus then
		output_panel:child("output_bg"):set_alpha(0)
		self._scroll._scroll_bar:set_alpha(0)
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

function HUDChat:_animate_fade_output()
	local wait_t = 5
	local fade_t = 1
	local t = 0
	while t < wait_t do
		local dt = coroutine.yield()
		t = t + dt
	end

	local t = 0
	while t < fade_t do
		local dt = coroutine.yield()
		t = t + dt

		self:set_output_alpha(1 - t / fade_t)
	end

	self:set_output_alpha(0)
end


function HUDChat:set_layer() end