local orig_init = LightLoadingScreenGuiScript.init
function LightLoadingScreenGuiScript:init(...)
    orig_init(self, ...)
    local background_color = Holo and Holo:GetColor("Colors/Menu")
    local text_color = Holo and Holo:GetColor("TextColors/Menu")
    if arg and arg.Holo then
        background_color = arg.Holo.background_color
        text_color = arg.Holo.text_color
    end
    if background_color and (not Holo or Holo:ShouldModify("Menu", "Loading")) then
        self._bg_gui:set_color(background_color)
        self._title_text:set_color(text_color)
    end
end