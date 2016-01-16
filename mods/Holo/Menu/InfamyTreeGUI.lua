if Holo.options.Menu_enable then

Hooks:PostHook(InfamyTreeGui, "_setup", "setup", function(self, ws, fullscreen_ws, node)
	local back_button = self._panel:child("back_button")
	back_button:set_color(Holomenu_color_normal)
	back_button:set_font_size(tweak_data.menu.pd2_medium_font_size)
	self._fullscreen_panel:child("back_button"):set_visible(false)

	self._back_marker = self._panel:bitmap({
		color = Holomenu_color_marker,
		alpha = Holomenu_markeralpha,
		visible = false,
		layer = back_button:layer() - 1
	})
	x,y,w,h = back_button:text_rect()
	self._back_marker:set_shape(x,y,313,h)
	self._back_marker:set_right(x + w)
end)

function InfamyTreeGui:mouse_moved(o, x, y)
	local used = false
	local pointer = "arrow"
	for index, item in pairs(self._tree_items) do
		if item.panel:inside(x, y) then
			used = true
			pointer = "link"
			if self._selected_item ~= index then
				self:_select_item(index)
				managers.menu_component:post_event("highlight")
			end
		end
	end
	if managers.menu:is_pc_controller() then
		local back_button = self._panel:child("back_button")
		if not used and back_button:inside(x, y) then
			used = true
			pointer = "link"
			if not self._back_highlight then
				self._back_highlight = true
				back_button:set_color(Holomenu_color_highlight)
				self._back_marker:show()
				managers.menu_component:post_event("highlight")
				self:_select_item("infamy_root")
			end
		elseif self._back_highlight then
			self._back_highlight = false
			self._back_marker:hide()
			back_button:set_color(Holomenu_color_normal)
		end
	end
	used = used or self._panel:inside(x, y)
	return used, pointer
end
end