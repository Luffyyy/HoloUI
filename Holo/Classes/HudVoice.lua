Holo.Voice = Holo.Voice or class()
local self = Holo.Voice
function self:Init()
    self._voice_panel = Holo.Panel:panel({
        name = "voice_panel",
        layer = 999,
        alpha = 0
    })
    self._delay = 0.5
    self._next_t = 0
    self._mouse_id = managers.mouse_pointer:get_id()
    self.Boxes = {}
    self._comment_allow = true
    for id, text in pairs(Holo.Voices) do
        self:Add(id, text)
    end
    Input:keyboard():add_trigger(Idstring(Holo.Options:GetValue("VoiceKey")), function()
        self._holding = true
    end)
    managers.hud:add_updator("Holo.VoiceUpdate", callback(self, self, "Update"))
end

function self:Update(t, dt)
    if self._wait then
        self._next_t = t + self._delay
        self._wait = false
    end
    if alive(managers.player:player_unit()) and self._holding and self._next_t <= t then
        if not self._showing then
            self._showing = true
            QuickAnim:Work(self._voice_panel, "alpha", 1, "stop", true)      
            managers.mouse_pointer:use_mouse({
                mouse_move = callback(self, self, "MouseMoved"),
                mouse_press = callback(self, self, "MousePressed"),
                mouse_release = callback(self, self, "MouseReleased"),
                id = self._mouse_id
            })
            self:SetMovingEnabled(false)
        end
    else
        if self._showing then
            if self._selected then
                self:Play(self._selected:name())
            end
            self._showing = false
            self._holding = false 
            managers.mouse_pointer:set_mouse_world_position(self._voice_panel:center_x(), self._voice_panel:center_y() - 5)
            managers.mouse_pointer:remove_mouse(self._mouse_id)
            self:SetMovingEnabled(true)
        end
        QuickAnim:Work(self._voice_panel, "alpha", 0, "stop", true)
    end
    if self._holding and not Input:keyboard():down(Idstring(Holo.Options:GetValue("VoiceKey"))) then
        self._holding = false
    end
end

function self:SetMovingEnabled(enabled)
    if managers.hud then
        managers.hud._chatinput_changed_callback_handler:dispatch(not enabled)
    end
end

function self:MouseReleased(o, x, y)
    if self._showing then
        managers.player:player_unit():base():controller():reset_cache(false)
    end
end

function self:MouseMoved(o, x, y)
    for panel, _ in pairs(self.Boxes) do
        if panel and panel:inside(x, y) then
            self._selected = panel
            panel:stop()
            QuickAnim:Work(panel:child("underline"), "speed", 10,"bottom", panel:child("Bg"):bottom())
        else
            if self._selected == panel then
                self._selected = nil
            end
            panel:stop()
            QuickAnim:Work(panel:child("underline"), "speed", 10,"top", panel:child("Bg"):bottom())
        end
    end
end

function self:MousePressed(o, button, x, y)
    if button == Idstring("0") and self._showing then
        for panel, config in pairs(self.Boxes) do
            if panel and panel:inside(x, y) then
                self:Play(config.id)
            end
        end
    end
end

function self:Play(id)
    if not managers.trade:is_peer_in_custody(managers.network:session():local_peer():id()) and id ~= nil then
        self._holding = false
        self._selected = nil
        self._wait = true
        return managers.player:player_unit():sound():say(id, true, true)
    end
end

function self:Add(id, text, comment)
    local space = 10
    local w = 128
    local h = 64
    local VBox = self._voice_panel:panel({
        name = id,
        w = w,
        h = h,
    })
    local Bg = VBox:rect({
        name = "Bg",
        halign="grow",
        valign="grow",
        color = Holo:GetColor("Colors/Menu"),
        alpha = 0.8,
        layer = -1
    })
    VBox:rect({
        name = "underline",
        layer = 0,
        color = Holo:GetColor("Colors/Marker"),
    }):set_top(Bg:bottom())
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
        font_size = 16,
        layer = 1
    })
    self.Boxes[VBox] = {id = id, comment = comment}
    local i = table.size(self.Boxes)
    times = math.ceil(i / Holo.VoiceMaxPerRow)
    local num = i % Holo.VoiceMaxPerRow
    num = num == 0 and Holo.VoiceMaxPerRow or num
    VBox:set_position((w + space) * (num - 1), (h + space) * (times - 1))         
    self._voice_panel:set_size((w + space) * Holo.VoiceMaxPerRow, (h + space) * times)
    self._voice_panel:set_world_center(Holo.Panel:world_center())
end