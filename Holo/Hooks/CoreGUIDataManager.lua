if core then
	core:module("CoreGuiDataManager")
end
function GuiDataManager:layout_scaled_fullscreen_workspace(ws, scale, on_screen_scale)
    local res = RenderSettings.resolution
    local w = math.round((on_screen_scale * 1280) * (2 - scale)) 
    local h = math.round((on_screen_scale * 720) * (2 - scale))
    local safe_w = math.round(on_screen_scale * res.x)
    local safe_h = math.round(on_screen_scale * res.y)   
    local sh = math.min(safe_h, safe_w / (w / h))
    local sw = math.min(safe_w, safe_h * (w / h))
    local x = res.x / 2 - sh * (w / h) / 2
    local y = res.y / 2 - sw / (w / h) / 2
    ws:set_screen(w, h, x, y, math.min(sw, sh * (w / h)))
end
_G.Hooks:PostHook(GuiDataManager, "resolution_changed", "HoloResChanged", function(self)
	_G.Holo:UpdateSettings()
end)