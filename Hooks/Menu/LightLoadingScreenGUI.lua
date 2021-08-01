local orig_init = LightLoadingScreenGuiScript.init
function LightLoadingScreenGuiScript:init(...)
    orig_init(self, ...)
    local data = arg and arg.Holo
    if not data and (Holo and Holo:ShouldModify("Menu", "Loading")) then
        data = {
            background_color = Holo:GetColor("Colors/Menu"),
            text_color = Holo:GetColor("TextColors/Menu"),
            colored_background = Holo.Options:GetValue("ColoredBackground")
        }
    end
    if data then
        self._bg_gui:hide()
        self._new_bg_gui = self._panel:bitmap({
            texture = not data.colored_background and "guis/textures/loading/loading_bg",
            color = data.colored_background and data.background_color or nil,
			w = self._panel:w(),
			h = self._panel:h(),
            layer = self._base_layer - 4
        })
        local color = data.text_color or Color.white
        self._stonecold_small_logo:set_color(color)
        self._title_text:set_color(color)
        self._indicator:set_image("guis/textures/pd2/skilltree/drillgui_icon_restarter") -- Colors better
        self._indicator:set_color(color)
    end
end