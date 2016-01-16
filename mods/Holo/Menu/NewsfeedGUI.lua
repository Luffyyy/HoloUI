if Holo.options.Menu_enable then

CloneClass(TextBoxGui)
NewsFeedGui.PRESENT_TIME = 0.5
NewsFeedGui.SUSTAIN_TIME = 6
NewsFeedGui.REMOVE_TIME = 0.5
NewsFeedGui.MAX_NEWS = 5
function NewsFeedGui:update(t, dt)
	if not self._titles then
		return
	end
	if self._news and #self._titles > 0 then
		local color = Holomenu_color_normal
		local Highlight = Holomenu_color_marker
		self._title_panel:child("title"):set_color(self._mouse_over and Highlight or color)
		if self._next then
			self._next = nil
			self._news.i = self._news.i + 1
			if self._news.i > #self._titles then
				self._news.i = 1
			end
			self._title_panel:child("title"):set_text(utf8.to_upper(self._news.i .. "/" .. #self._titles .. " - " .. self._titles[self._news.i]))
			local _, _, w, h = self._title_panel:child("title"):text_rect()
			self._title_panel:child("title"):set_h(h)
			self._title_panel:set_w(w + 10)
			self._title_panel:set_h(h)
			self._title_panel:set_left(self._panel:w())
			self._title_panel:set_bottom(self._panel:h())
			self._present_t = t + self.PRESENT_TIME
		end
		if self._present_t then
			self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()) * ((self._present_t - t) / self.PRESENT_TIME))
			if t > self._present_t then
				self._title_panel:set_left(0)
				self._present_t = nil
				self._sustain_t = t + self.SUSTAIN_TIME
			end
		end
		if self._sustain_t and t > self._sustain_t then
			self._sustain_t = nil
			self._remove_t = t + self.REMOVE_TIME
		end
		if self._remove_t then
			self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()) * (1 - (self._remove_t - t) / self.REMOVE_TIME))
			if t > self._remove_t then
				self._title_panel:set_left(0 - (managers.gui_data:safe_scaled_size().x + self._title_panel:w()))
				self._remove_t = nil
				self._next = true
			end
		end
	end
end

end