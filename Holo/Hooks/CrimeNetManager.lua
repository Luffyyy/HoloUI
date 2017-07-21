if Holo.Options:GetValue("Menu") then

Hooks:PostHook(CrimeNetGui, "init", "HoloInit", function( self, ws, fullscreeen_ws, node )
	Holo.Utils:FixBackButton(self, self._panel:child("back_button"))
	Holo.Utils:SetBlendMode(self._panel, "focus")
	local no_servers = node:parameters().no_servers
	self._fullscreen_panel:child("vignette"):hide()
	self._fullscreen_panel:child("bd_light"):hide()
	self._fullscreen_panel:child("blur_top"):hide()
	self._fullscreen_panel:child("blur_right"):hide()
	self._fullscreen_panel:child("blur_bottom"):hide()
	self._fullscreen_panel:child("blur_left"):hide()
	for _, child in pairs(self._panel:children()) do
		child:configure({
			blend_mode = "normal"
		})
	end
	for _, child in pairs(self._map_panel:children()) do
		child:configure({
			blend_mode = "normal"
		})
	end
	self._map_panel:rect({
		name = "background",
		color = Holo:GetColor("Colors/Menu"),
		alpha = Holo.Options:GetValue("MenuBackground") and 1 or 0,
		valign = "scale",
		halign = "scale",
	})
	if not no_servers then
		self._panel:child("filter_button"):set_color(Holo:GetColor("TextColors/Menu"))
	end
	self._panel:child("legends_button"):set_color(Holo:GetColor("TextColors/Menu"))
	self._map_panel:child("map"):set_alpha(Holo.Options:GetValue("ColoredBackground") and 0 or 1)
end)

Hooks:PostHook(CrimeNetGui, "_create_job_gui", "HoloCreateJobGUI", function(self)
	Holo.Utils:SetBlendMode(self._panel, "focus")
end)
Hooks:PostHook(CrimeNetGui, "_create_polylines", "HoloCreatePolyLines", function( self, o, x, y )
	if self._region_panel then
		for _, child in pairs(self._region_panel:children()) do
			child:configure({
				blend_mode = "normal"
			})
		end
	end
end)
Hooks:PostHook(CrimeNetGui, "mouse_moved", "HoloMouseMoved", function( self, o, x, y )
	if not self._crimenet_enabled then
		return false
	end
	if managers.menu:is_pc_controller() then
		if self._panel:child("back_button"):inside(x, y) then
			if not self.back_highlighted then
				self.back_highlighted = true
				self._back_highlighted = true
				self._back_marker:show()
				self._panel:child("back_button"):set_color(Holo:GetColor("TextColors/MenuHighlighted"))
				managers.menu_component:post_event("highlight")
			end
			return true, "link"
		elseif self.back_highlighted then
			self._ack_highlighted = false
			self._back_highlighted = false
			self._back_marker:hide()
			self._panel:child("back_button"):set_color(Holo:GetColor("TextColors/Menu"))
		end
		if self._panel:child("legends_button"):inside(x, y) then
			if not self.legend_highlighted then
				self.legend_highlighted = true
				self._legend_highlighted = true
				self._panel:child("legends_button"):set_color(Holo:GetColor("Colors/Marker"))
				managers.menu_component:post_event("highlight")
			end
			return true, "link"
		elseif self.legend_highlighted then
			self.legend_highlighted = false
			self._legend_highlighted = false
			self._panel:child("legends_button"):set_color(Holo:GetColor("TextColors/Menu"))
		end
		if self._panel:child("filter_button") then
			if self._panel:child("filter_button"):inside(x, y) then
				if not self.filter_highlighted then
					self.filter_highlighted = true
					self._filter_highlighted = true
					self._panel:child("filter_button"):set_color(Holo:GetColor("Colors/Marker"))
					managers.menu_component:post_event("highlight")
				end
				return true, "link"
			elseif self.filter_highlighted then
				self._filter_highlighted = false
				self.filter_highlighted = false
				self._panel:child("filter_button"):set_color(Holo:GetColor("TextColors/Menu"))
			end
		end
	end
end)
end
