
if Holo.Options:GetValue("Menu") then

Holo:Post(CrimeNetSidebarItem, "init", function(self, sidebar, panel, parameters)
	self:set_color(Holo:GetColor("TextColors/Menu"))
	self:set_highlight_color(Holo:GetColor("TextColors/Marker"))
end)

end