if core then
	core:module("CoreGuiDataManager")
end
function GuiDataManager:layout_scaled_fullscreen_workspace(ws, scale, on_screen_scale)
    local base_res = {x = 1280, y = 720}
    local res = RenderSettings.resolution
    local sc = (2 - scale)
    local aspect_width = base_res.x / self:_aspect_ratio()
    local h = math.round(sc * math.max(base_res.y, aspect_width))
    local w = math.round(sc * math.max(base_res.x, aspect_width / h))

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