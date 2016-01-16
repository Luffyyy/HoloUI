if Holo.options.Menu_enable then
local oinit = PlayerInventoryGui.init
function PlayerInventoryGui:init(ws, fullscreen_ws, node)	
	oinit(self, ws, fullscreen_ws, node)
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
end
local omoved = PlayerInventoryGui.mouse_moved
function PlayerInventoryGui:mouse_moved(o, x, y)
	if self._panel:child("back_button"):inside(x, y) then
		used = true
		pointer = "link"
		if not self._back_button_highlighted then
			self._back_button_highlighted = true
			self._panel:child("back_button"):set_color(Holomenu_color_highlight)
			self._back_marker:show()
			managers.menu_component:post_event("highlight")
			return used, pointer
		end
	elseif self._back_button_highlighted then
		self._back_button_highlighted = false
		self._back_marker:hide()
		self._panel:child("back_button"):set_color(Holomenu_color_normal)
	end	
	omoved(self, o,x,y)
end

 
end

