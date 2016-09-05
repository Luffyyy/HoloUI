if core then
	core:module("CoreGuiDataManager")
end
function GuiDataManager:layout_scaled_fullscreen_workspace(ws, scale, on_screen_scale)
	local res = self._static_resolution or RenderSettings.resolution
 	local w = self._fullrect_data.w * (2 - scale)
 	local h = self._fullrect_data.h * (2 - scale)
 	local sfw = self._fullrect_data.w * (1.25 * on_screen_scale)
 	local sfh = self._fullrect_data.h * (1.25 * on_screen_scale)
 	local sh = math.min(sfh, sfw / (w / h))
	local sw = math.min(sfw, sfh * (w / h))
	local x = res.x / 2 - sh * (w / h) / 2
	local y = res.y / 2 - sw / (w / h) / 2
    local osw = math.min(sfw, sfh * (w / h))
	ws:set_screen(w, h, x, y, osw)
end