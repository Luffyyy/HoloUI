if Holo.Options:GetValue("Menu") then
	function ChatGui:set_righttop(right, top)
		self._panel:set_x(self._panel:w())
		self._panel:set_bottom(self._panel:h() - top)
	end
	function ChatGui:set_leftbottom(left, bottom)
		self._panel:set_left(left)
		self._panel:set_bottom(self._panel:parent():h() - bottom)
	end
	if BigLobbyGlobals then
		ChatGui.PRESETS.default = {
			right = true,
			top = -150,
			layer = 20
		}
	else
		ChatGui.PRESETS.default.bottom = 30
	end
	if Holo.Options:GetValue("Chat") then
		function ChatGui:receive_message(name, message, color, icon)
			if not alive(self._panel) or not managers.network:session() then
				return
			end
			local output_panel = self._panel:child("output_panel")
			local scroll_panel = output_panel:child("scroll_panel")
			local local_peer = managers.network:session():local_peer()
			local peers = managers.network:session():peers()
			local len = utf8.len(name) + 1
			local x = 12
			local icon_bitmap = scroll_panel:bitmap({
				name = "icon",
				color = color,
				layer = 1,
				w = 2,
				x = x,
				y = 1
			})
			local line = scroll_panel:text({
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
			line:set_range_color(0, len, color)
			line:set_range_color(len, total_len, Color.white)
			local _, _, w, h = line:text_rect()
			local line_bg = scroll_panel:rect({
				color = Color.black,
				alpha = 0.1,
				x = x,
				layer = 0
			})
			line_bg:set_h(h - 2)
			icon_bitmap:set_h(h - 2)
			line:set_h(h)
			line:set_kern(line:kern())
			table.insert(self._lines, {
				line,
				line_bg,
				icon_bitmap
			})
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
			local line_height = ChatGui.line_height 
			local max_lines = self._max_lines
			local lines = 0
			for i = #self._lines, 1, -1 do
				local line = self._lines[i][1]
				local line_bg = self._lines[i][2]
				local icon = self._lines[i][3]
				line:set_w(scroll_panel:w() - line:left())
				local _, _, w, h = line:text_rect()
				line:set_h(h)
				line_bg:set_w(w + line:left() + 2)
				line_bg:set_h(line_height * line:number_of_lines())
				lines = lines + line:number_of_lines()
			end
			local scroll_at_bottom = scroll_panel:bottom() == output_panel:h()
			output_panel:set_h(math.round(line_height * math.min(max_lines, lines)))
			scroll_panel:set_h(math.round(line_height * lines))
			local y = 0
			for i = #self._lines, 1, -1 do
				local line = self._lines[i][1]
				local line_bg = self._lines[i][2]
				local icon = self._lines[i][3]
				local _, _, w, h = line:text_rect()
				line:set_bottom(scroll_panel:h() - y)
				icon:set_bottom(line:bottom())
				line_bg:set_bottom(line:bottom())
				if icon then
					line:set_left(icon:right() + 4)
				end
				y = y + line_height * line:number_of_lines()
			end
			output_panel:set_bottom(math.round(self._input_panel:top()))
			if max_lines >= lines or scroll_at_bottom then
				scroll_panel:set_bottom(output_panel:h())
			end
			self:set_scroll_indicators(force_update_scroll_indicators)
		end
	end
end