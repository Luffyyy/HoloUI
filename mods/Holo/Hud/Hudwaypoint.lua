core:import("CoreEvent")
--Working on it.
Hooks:PostHook(HUDManager, "add_waypoint", "waypoint_color", function(self, id, data)
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	local waypoint_panel = hud.panel
	local waypoint = waypoint_panel:child("bitmap".. id)
	local arrow = waypoint_panel:child("arrow".. id)
	if data.distance then
	local distance = waypoint_panel:child("distance".. id)
	distance:set_color(Color.white)
    end
	waypoint:set_color(SpringGreen)
	arrow:set_color(waypoint:color())
	waypoint:set_blend_mode("normal")
	waypoint:set_alpha(0.8)
end)
