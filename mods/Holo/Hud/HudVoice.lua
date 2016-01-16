HUDVoice = HUDVoice or class()
function HUDVoice:init(ws)
    self._fullscreen_ws_pnl = ws:panel() 
    ws:connect_keyboard(Input:keyboard())  
    ws:connect_mouse(Input:mouse())  
    self._voices = {}
    self._voice_panel = self._fullscreen_ws_pnl:panel({
        name = "voice_panel",
        w = 550,
        h = 1024,
        halign = "center", 
        align = "center",
        layer = 20,
        alpha = 0
    })  
    self._times = 1
    self._comment_allow = true
    self._voice_panel:set_center(self._fullscreen_ws_pnl:w() / 2.05, self._fullscreen_ws_pnl:h() )

    self:addvoices()
    self._mouse_id = managers.mouse_pointer:get_id()
    self._fullscreen_ws_pnl:key_press(callback(self, self, "voice_trigger"))    
    self._fullscreen_ws_pnl:key_release(callback(self, self, "voice_trigger_hold"))  
end

function HUDVoice:voice_trigger(o, k)
    key = LuaModManager:GetPlayerKeybind("Voice_key") or "q"
    if k == Idstring(key)   then
       self.key_pressed = k 
       self._fullscreen_ws_pnl:animate(callback(self, self, "voice_hold"), k)
    end
end

function HUDVoice:voice_hold(o, k)
  wait(0.3)
  while self.key_pressed == k do
    if not self._active then
      data = {}
      data.mouse_move = callback(self, self, "mouse_moved")
      data.mouse_press = callback(self, self, "mouse_pressed")
      data.id = self._mouse_id
      self._voice_panel:animate( callback( self, self, "animate_show_voices" ))
      managers.mouse_pointer:use_mouse(data) 
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
        self._voice_panel:animate( callback( self, self, "animate_hide_voices" ))
        self._active = false
        for panel,_ in pairs(self._voices) do
          panel:child("bg"):set_color(Color.white)    
        end
    end
end
function HUDVoice:voice_trigger_hold(o, k)
  if self.key_pressed == k then
    self.key_pressed = false
    if self._selected  then
       config = self._voices[self._selected]
       self:PlayID(config.soundid)
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
          panel:child("bg"):set_color(HoloColor)
      else
          panel:child("bg"):set_color(Color.white)       
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
            self:PlayID(config.soundid) 
            if config.comment and config.allow_comment then
                managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", config.comment)
                self._voice_panel:animate( callback( self, self, "comment_stop" ), config)
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

function HUDVoice:PlayID(soundid)
    local in_custody = managers.trade:is_peer_in_custody(managers.network:session():local_peer():id())
    if not in_custody and soundid ~= nil then
        return managers.player:player_unit():sound():say(soundid, true, true)
    end
end

function HUDVoice:animate_show_voices( panel )
  local t = 1
  while t > 0.5 do
    local dt = coroutine.yield()
    t = t - dt
    local alpha = math.abs((math.sin(t * 180 - 1))) 
    panel:set_alpha( alpha )
  end
    panel:set_alpha( 1 )
end
function HUDVoice:animate_hide_voices( panel )
  local t = 0.5
  while t > 0 do
    local dt = coroutine.yield()
    t = t - dt
    local alpha = math.abs((math.sin(t * 180 - 1)))
    panel:set_alpha( alpha )
  end
    panel:set_alpha( 0 )
end

function HUDVoice:addvoice( config )  
      voice_box = self._voice_panel:panel({
          y = 0, 
          w = 64, 
          h = 64,
          halign = "right", 
          align = "right"
      }) 
      voice_box:rect({
          name = "bg", 
          halign="grow", 
          valign="grow", 
          blend_mode = "normal", 
          alpha = 0.8, 
          color = Color.white, 
          layer = -1 
        }) 

    if not self._boxes then
      self._boxes = 1
    else
      self._boxes = self._boxes + 1
    end
    if self._boxes < 9 then
       voice_box:set_x(self._voice_panel:w() - (voice_box:w() + 2) * self._boxes)
       voice_box:set_y(0)
    else
        if self._boxes > (8 * self._times) + 8 then
            self._times = self._times + 1
        end
        local num = self._boxes - 8 * self._times
        voice_box:set_x(self._voice_panel:w() - (voice_box:w() + 2 ) * num)
        voice_box:set_y((voice_box:w() + 2) * self._times)
    end   

    voice_text = voice_box:text({
        name = "text",
        text = config.text,
        valign = "center",
        align = "center",
        vertical = "center",
        w = voice_box:w(),
        h = voice_box:h(),
        layer = 6,
        color = Color.black,
        font = tweak_data.hud_corner.assault_font,
        font_size = 16
    })  
    self._voices[voice_box] = config
    if config.comment then
       config.allow_comment = true
    end
end
function HUDVoice:addvoices()
       self:addvoice({
          soundid = "f40_any",
           text = "Move!"
       })
       self:addvoice({
          soundid = "l03x_sin",
          text = "and cuffs!"
       })
       self:addvoice({
          soundid = "a01x_any",
          text = "Lets start"
       })   
       self:addvoice({
          soundid = "f38_any",
          text = "follow"
       })
       self:addvoice({
          soundid = "f02x_sin",
          text = "Down on ".."\n".."the ground!"
       })
       self:addvoice({
          soundid = "r01x_sin",
          text = "ok"
       }) 
       self:addvoice({
          soundid = "p45",
          text = "Help",
       }) 
       self:addvoice({
          soundid = "p17",
          text = "Any seconds"
       })
       self:addvoice({
          soundid = "p17",
          text = "Any seconds"
       })
       self:addvoice({
          soundid = "whistling_attention",
          text = "Whistle"
       }) 
      self:addvoice({
          soundid = "f33y_any",
          text = "Cloacker"
       })        
      self:addvoice({
          soundid = "v55",
          text = "Sniper"
       })         
      self:addvoice({
          soundid = "s05x_sin",
          text = "Thanks!",
       })           
      self:addvoice({
          soundid = "g92",
          text = "Oh yeah!"
       })        
      self:addvoice({
          soundid = "g06",
          text = "Down"
       })     
      self:addvoice({
          soundid = "g05",
          text = "Up"
       })        
      self:addvoice({
          soundid = "g63",
          text = "Just a minute"
       })           
      self:addvoice({
          soundid = "g65",
          text = "two minutes"
       })             
      self:addvoice({
          soundid = "g67",
          text = "Any seconds"
       })       
      self:addvoice({
          soundid = "g24",
          text = "Fuck yeah!"
       })          
      self:addvoice({
          soundid = "g28",
          text = "Just a bit"
       })            
      self:addvoice({
          soundid = "g81x_plu",
          text = "Need ammo!",
       })        
      self:addvoice({
          soundid = "g80x_plu",
          text = "Need heal!",
       })         
      self:addvoice({
          soundid = "p19",
          text = "Coming"
       })             
        self:addvoice({
          soundid = "g23",
          text = "Fight"
       })                
      self:addvoice({
          soundid = "g43",
          text = "Grenade"
       })              
      self:addvoice({
          soundid = "f30x_any",
          text = "bulldozer!"
       })           
      self:addvoice({
          soundid = "f31x_any",
          text = "Shield!"
       })               
      self:addvoice({
          soundid = "f32x_any",
          text = "Taser!"
       })         
      self:addvoice({
          soundid = "g09",
          text = "Hurry!"
       })         
      self:addvoice({
          soundid = "g10",
          text = "Careful"
       })            
      self:addvoice({
          soundid = "p46",
          text = "Jump!"
       })                
end
