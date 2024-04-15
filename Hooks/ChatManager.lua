if not Holo:ShouldModify("Menu", "Chat") then
	return
end

ChatGui.max_lines = ChatGui.max_lines or BigLobbyGlobals and 12 or 16
ChatGui.line_h = ChatGui.line_h or 16
Holo:Post(ChatGui, "set_scroll_indicators", function(self)
	self._scroll_indicator_box_class._panel:hide()
end)

function ChatGui:set_righttop(right, top)
	self._panel:set_x(self._panel:w())
	self._panel:set_bottom(self._panel:h() - top)
end

function ChatGui:set_leftbottom(left, bottom)
	self._panel:set_left(left)
	self._panel:set_bottom(self._panel:parent():h() - bottom)
end
if BigLobbyGlobals then
	ChatGui.PRESETS.default.left = 600
	ChatGui.PRESETS.default.bottom = 30
else
	ChatGui.PRESETS.default.bottom = 30
end

function ChatGui:receive_message(name, message, color, icon)
	if not alive(self._panel) or not managers.network:session() then
		return
	end

	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")

	local len = utf8.len(name) + 1
	local message_panel = scroll_panel:panel({x = 4, w = scroll_panel:w() - 8, h = ChatGui.line_h})
	local icon_bitmap = message_panel:rect({
		name = "icon",
		color = color,
		w = 2,
	})
	local line = message_panel:text({
		name = "text",
		text = string.format("%s: %s", name, message),
		font = "fonts/font_large_mf",
		font_size = ChatGui.line_h,
		kerning = 0,
		color = color,
		x = icon_bitmap:right() + 2,
		y = 2,
		w = message_panel:w() - 2,
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
	if not self._focus then
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
		self:start_notify_new_message()
	end
end

function ChatGui:_layout_output_panel(force_update_scroll_indicators)
	local output_panel = self._panel:child("output_panel")
	local scroll_panel = output_panel:child("scroll_panel")
	scroll_panel:set_w(self._output_width)
	output_panel:set_w(self._output_width)
	local max_lines = self._max_lines
	local scroll_at_bottom = scroll_panel:bottom() == output_panel:h()
	local lines = 0
	local prev
	for _, line in pairs(self._lines) do
		if prev then
			line:set_y(prev:bottom() + 2)			
		else
			line:set_y(2)
		end
		prev = line
	end
	local h = prev and prev:bottom() + 2 or 0
	output_panel:set_h(math.min((ChatGui.max_lines + 1) * ChatGui.line_h + 4, h))
	scroll_panel:set_h(h)
	if lines <= max_lines or scroll_at_bottom then
		scroll_panel:set_bottom(output_panel:h())
	end
	output_panel:set_bottom(self._input_panel:top() - 2)
	self:set_scroll_indicators(force_update_scroll_indicators)
end
