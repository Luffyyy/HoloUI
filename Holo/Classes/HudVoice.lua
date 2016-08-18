HUDVoice = HUDVoice or class()
function HUDVoice:init(ws)
    self._fullscreen_ws_pnl = ws:panel()
    ws:connect_keyboard(Input:keyboard())
    ws:connect_mouse(Input:mouse())
    self._voices = {}
    self._voice_panel = self._fullscreen_ws_pnl:panel({
        name = "voice_panel",
        layer = 20,
        alpha = 0
    })
    self._times = 1
    self._boxes = {}
    self._comment_allow = true
    self._voice_panel:set_center(self._fullscreen_ws_pnl:center())

    self:addvoices()
    self._mouse_id = managers.mouse_pointer:get_id()
    self._fullscreen_ws_pnl:key_press(callback(self, self, "voice_trigger"))
    self._fullscreen_ws_pnl:key_release(callback(self, self, "voice_trigger_hold"))
end

function HUDVoice:voice_trigger(o, k)
    local key = LuaModManager:GetPlayerKeybind("Voice_key") or "q"
    if k == Idstring(key)   then
       self.key_pressed = k
       self._fullscreen_ws_pnl:animate(callback(self, self, "voice_hold"), k)
    end
end

function HUDVoice:voice_hold(o, k)
    wait(0.2)
    while self.key_pressed == k do
    if not self._active then
        managers.mouse_pointer:use_mouse({
            mouse_move = callback(self, self, "mouse_moved"),
            mouse_press = callback(self, self, "mouse_pressed"),
            id = self._mouse_id
        })
        GUIAnim.play(self._voice_panel, "alpha", 1)
        self._active = true
    end
        wait(0.01)
    end
    self:hide_voice()
end

function HUDVoice:hide_voice()
    if self._active then
        managers.mouse_pointer:remove_mouse(self._mouse_id)
        managers.mouse_pointer:set_mouse_world_position(self._voice_panel:center() + 20,self._voice_panel:top() + 90)
        self._selected = false
        self._active = false
        GUIAnim.play(self._voice_panel, "alpha", 0)
        for panel,_ in pairs(self._voices) do
            panel:child("bg"):set_color(Holo:GetColor("Colors/MenuBackground"))
        end
    end
end
function HUDVoice:voice_trigger_hold(o, k)
    if self.key_pressed == k then
        self.key_pressed = false
        if self._selected  then
           config = self._voices[self._selected]
           self:Play(config.id)
           if config.comment and config.allow_comment then
               managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", config.comment)
               self._voice_panel:animate( callback( self, self, "comment_stop" ), config)
           end
        end
    end
end

function HUDVoice:mouse_moved( o, x, y )
    for panel,_ in pairs(self._voices) do
        if panel and panel:inside(x, y) then
            self._selected = panel
            GUIAnim.play(panel:child("underline"), "bottom", panel:child("bg"):bottom(), 10)
        else
            GUIAnim.play(panel:child("underline"), "bottom", panel:child("bg"):bottom() + 2, 10)
        end
        if self._selected and not self._selected:inside(x, y) then
            self._selected = false
        end
    end
end
function HUDVoice:mouse_pressed( o, button, x, y )
    if button == Idstring("0") then
     for panel, config in pairs(self._voices) do
        if panel and panel:inside(x, y) then
            self:Play(config.id)
            if config.comment and config.allow_comment then
                managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", config.comment)
                self._voice_panel:animate(callback( self, self, "comment_stop" ), config)
            end
            self.key_pressed = false
        end
     end
    end
end

function HUDVoice:comment_stop(o ,config)
  t = 0
  while t < 20 do
      local dt = coroutine.yield()
      config.allow_comment = false
      t = t + dt
  end
  config.allow_comment = true
end

function HUDVoice:Play(id)
    local in_custody = managers.trade:is_peer_in_custody(managers.network:session():local_peer():id())
    if not in_custody and id ~= nil then
        return managers.player:player_unit():sound():say(id, true, true)
    end
end
function HUDVoice:addvoice(id, text, comment)
    local max_per_row = 5
    local space = 10
    local w = 128
    local h = 64
    voice_box = self._voice_panel:panel({
        w = w,
        h = h,
    })
    table.insert(self._boxes, voice_box)
    local bg = voice_box:rect({
        name = "bg",
        halign="grow",
        valign="grow",
        color = Holo:GetColor("Colors/MenuBackground"),
        alpha = 0.8,
        layer = -1
    })
    voice_box:rect({
        name = "underline",
        h = 2,
        color = Holo:GetColor("Colors/Marker"),
    }):set_bottom(bg:bottom() + 2)
    if #self._boxes > 1 then
        if #self._boxes < (max_per_row + 1) then
            voice_box:set_left(self._boxes[#self._boxes - 1]:right() + space)
        else
            if #self._boxes > (max_per_row * self._times) + max_per_row then
                self._times = self._times + 1
            end
            local num = #self._boxes - max_per_row * self._times
            if num ~= 1 then
                voice_box:set_left(self._boxes[#self._boxes - 1]:right() + space)
            end
            voice_box:set_y((h + space) * self._times)
        end
    end
    Input:keyboard():add_trigger(Idstring(tostring(#self._boxes)), function()
        if Input:keyboard():down(Idstring(LuaModManager:GetPlayerKeybind("Voice_key") or "q")) then
            self:Play(id)
        end
    end)
    local voice_text = voice_box:text({
        name = "text",
        text = text,
        vertical = "center",
        align = "center",
        w = voice_box:w(),
        h = voice_box:h(),
        color = Holo:GetColor("TextColors/Menu"),
        font = "fonts/font_large_mf",
        font_size = 16
    })
    self._voices[voice_box] = {
        id = id,
        comment = comment,
    }
    self._voice_panel:set_size((w + space) * max_per_row, (h + space) * self._times)
    self._voice_panel:set_center(self._fullscreen_ws_pnl:center())
end
function HUDVoice:addvoices()
    local sounds = {
        ["f40_any"] = "Move",
        ["l03x_sin"] = "And cuffs!",
        ["a01x_any"] = "Lets start",
        ["f38_any"] = "Follow me!",
        ["f02x_sin"] = "Down On" ..  "\n" .. "The Ground!",
        ["r01x_sin"] = "Ok",
        ["p45"] = "Help",
        ["p17"] = "Any Seconds",
        ["whistling_attention"] = "Whistle",
        ["f33y_any"] = "Cloacker!",
        ["v55"] = "Sniper!",
        ["f30x_any"] = "Dozer!",
        ["f31x_any"] = "Shield!",
        ["f32x_any"] = "Taser!",
        ["s05x_sin"] = "Thanks",
        ["g92"] = "Hooray!",
        ["g06"] = "Go Up",
        ["g05"] = "Go Down",
        ["g63"] = "One Minute",
        ["g65"] = "Two Minutes",
        ["g67"] = "Any Seconds",
        ["g24"] = "Fuck Yeah!",
        ["g28"] = "Just A Bit",
        ["g81x_plu"] = "Need Ammo!",
        ["g80x_plu"] = "Need Healing!",
        ["p19"] = "Coming!",
        ["g43"] = "Grenade!",
        ["g09"] = "Hurry!",
        ["g10"] = "Careful",
        ["p46"] = "Jump",
    }
    for id, text in pairs(sounds) do
        self:addvoice(id, text)
    end
end
