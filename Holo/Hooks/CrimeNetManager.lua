if not Holo.Options:GetValue("Menu") then
	return
end

Holo:Post(CrimeNetGui, "init", function( self, ws, fullscreeen_ws, node )
	Holo.Utils:FixBackButton(self)
	Holo.Utils:SetBlendMode(self._panel, "focus")
	Holo.Utils:SetBlendMode(self._map_panel, "focus")
	local no_servers = node:parameters().no_servers
	self._fullscreen_panel:child("vignette"):hide()
	self._fullscreen_panel:child("bd_light"):hide()
	self._fullscreen_panel:child("blur_top"):hide()
	self._fullscreen_panel:child("blur_right"):hide()
	self._fullscreen_panel:child("blur_bottom"):hide()
	self._fullscreen_panel:child("blur_left"):hide()
	self._rasteroverlay:hide()
	
	self._map_panel:rect({
		name = "background",
		color = Holo:GetColor("Colors/Menu"),
		alpha = Holo.Options:GetValue("MenuBackground") and 1 or 0,
		valign = "scale",
		halign = "scale",
	})
	self._panel:child("legends_button"):set_color(Holo:GetColor("TextColors/Menu"))
	self._map_panel:child("map"):set_alpha(Holo.Options:GetValue("ColoredBackground") and 0 or 1)
	for _, child in pairs(table.list_add(self._panel:children(), self._fullscreen_panel:children(), self._panel:child("legend_panel"):children())) do
		if child.render_template and child:render_template() == Idstring("VertexColorTexturedBlur3D") then
			child:set_alpha(0)
		end
	end
end)

Holo:Post(CrimeNetGui, "_create_job_gui", function(self)
	Holo.Utils:SetBlendMode(self._panel, "focus")
end)

Holo:Post(CrimeNetGui, "_create_polylines", function(self, o, x, y)
	if self._region_panel then
		Holo.Utils:SetBlendMode(self._region_panel)
	end
	if Holo.Options:GetValue("ColoredBackground") then
		for _, child in pairs(self._region_panel:children()) do
			child:hide()
		end
	end
end)