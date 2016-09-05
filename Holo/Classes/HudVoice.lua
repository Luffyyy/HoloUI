HUDVoice = HUDVoice or class()
function HUDVoice:init()
    self._voice_panel = Holo.Panel:panel({
        name = "voice_panel",
        layer = 999,
        alpha = 0
    })
    self._mouse_id = managers.mouse_pointer:get_id()
    self.Boxes = {}
    self._comment_allow = true
    for id, text in pairs(Holo.Voices) do
        self:Add(id, text)
    end
    managers.hud:add_updator("HoloVoiceUpdate", callback(self, self, "Update"))
end
function HUDVoice:Update(t, dt)
    if alive(managers.player:player_unit()) and Input:keyboard():down(Idstring(Holo.Options:GetValue("VoiceKey"))) then
        if not self._showing then
            self._showing = true
            self._voice_panel:stop()
            GUIAnim.play(self._voice_panel, "alpha", 1, 1, function()
                managers.mouse_pointer:use_mouse({
                    mouse_move = callback(self, self, "MouseMoved"),
                    mouse_press = callback(self, self, "MousePressed"),
                    id = self._mouse_id
                })
            end)
        end
    else
        if self._showing then
            self._showing = false
            managers.mouse_pointer:remove_mouse(self._mouse_id)
            managers.mouse_pointer:set_mouse_world_position(self._voice_panel:center() + 20,self._voice_panel:top() + 90)
        end
        self._voice_panel:stop()
        GUIAnim.play(self._voice_panel, "alpha", 0, 1)
    end
end
function HUDVoice:MouseMoved(o, x, y)
    for panel, _ in pairs(self.Boxes) do
        if panel and panel:inside(x, y) then
            self._selected = panel
            panel:stop()
            GUIAnim.play(panel:child("underline"), "bottom", panel:child("Bg"):bottom(), 10)
        else
            panel:stop()
            GUIAnim.play(panel:child("underline"), "bottom", panel:child("Bg"):bottom() + 2, 10)
        end
        self._selected = self._selected and self._selected:inside(x, y) and self._selected
    end
end
function HUDVoice:MousePressed(o, button, x, y)
    if button == Idstring("0") then
        for panel, config in pairs(self.Boxes) do
            if panel and panel:inside(x, y) then
                self:Play(config.id)
            end
        end
    end
end
function HUDVoice:Play(id)
    if not managers.trade:is_peer_in_custody(managers.network:session():local_peer():id()) and id ~= nil then
        return managers.player:player_unit():sound():say(id, true, true)
    end
end
function HUDVoice:Add(id, text, comment)
    local max_per_row = 5
    local space = 10
    local w = 128
    local h = 64
    local VBox = self._voice_panel:panel({
        w = w,
        h = h,
    })
    local Bg = VBox:rect({
        name = "Bg",
        halign="grow",
        valign="grow",
        color = Holo:GetColor("Colors/MenuBackground"),
        alpha = 0.8,
        layer = -1
    })
    VBox:rect({
        name = "underline",
        h = 2,
        color = Holo:GetColor("Colors/Marker"),
    }):set_bottom(Bg:bottom() + 2)
    Input:keyboard():add_trigger(Idstring(tostring(#self.Boxes)), function()
        if Input:keyboard():down(Idstring(LuaModManager:GetPlayerKeybind("Voice_key") or "q")) then
            self:Play(id)
        end
    end)
    local voice_text = VBox:text({
        name = "text",
        text = text,
        vertical = "center",
        align = "center",
        w = VBox:w(),
        h = VBox:h(),
        color = Holo:GetColor("TextColors/Menu"),
        font = "fonts/font_large_mf",
        font_size = 16
    })
    self.Boxes[VBox] = {
        id = id,
        comment = comment,
    }
    local i = table.size(self.Boxes)
    times = math.ceil(i / max_per_row)
    local num = i % max_per_row
    num = num == 0 and max_per_row or num
    VBox:set_position((w + space) * (num - 1), (h + space) * (times - 1))         
    self._voice_panel:set_size((w + space) * max_per_row, (h + space) * times)
    self._voice_panel:set_world_center(Holo.Panel:world_center())
end
 