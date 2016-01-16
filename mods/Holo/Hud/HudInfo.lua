HUDInfo = HUDInfo or class()
function HUDInfo:init(hud)  
    self._full_hud = hud
    self._timer_panel = self._full_hud:panel({
        name = "Timer_panel", 
        w = InfoTimers_size * InfoTimers_max + 10,
        h = 1024,
        layer = -11,
        valign = "top", 
        halign = "right",
        visible = InfoTimers_enable,
        blend_mode = "normal"
    })
    self._timers = {}
    self._infos = {}
    self._active_infos = {}
    managers.hud:add_updator("InfoUpdate", callback(self, self, "InfoUpdater"))
    self._info_panel = self._full_hud:panel({
        name = "info_panel",
        valign = "top", 
        halign = "right",
        layer = -11,
        w = 512,
        h = 84,
    })
    self:create_info({
       name = "hostages",
       color = Hostage_color,
       option = "hostages_enable", 
       icon = "guis/textures/pd2/skilltree/icons_atlas",
       func = "CountHostages",
       icon_rect = {255,449, 64, 64}
    })    
    self:create_info({
       name = "enemies",
       color = enemies_bg_color,
       hide = true,
       option = "enemies_enable", 
       func = "CountInfo",
       icon = "guis/textures/pd2/skilltree/icons_atlas",
       icon_rect = {2,319,64,64},
       info = managers.enemy:all_enemies(),
       count = true
    })   
    self:create_info({
       name = "civis",
       color = civis_bg_color,
       hide = true,
       func = "CountInfo",
       option = "civis_enable", 
       icon = "guis/textures/pd2/skilltree/icons_atlas",
       icon_rect = {386,447,64,64},
       info = managers.enemy:all_civilians(),
       count = true
    })        
    self:create_info({
       name = "pagers",
       color = pagers_bg_color,
       option = "pagers_enable", 
       func = "CountPagers",
       icon = "guis/textures/pd2/specialization/icons_atlas",
       icon_rect = {66,254,64,64},
    })      
    self:create_info({
       name = "gagepacks",
       color = gagepacks_bg_color,
       option = "gagepacks_enable", 
       func = "CountPacks",
       icon = "guis/textures/pd2/skilltree/icons_atlas",
       icon_rect = {3,515,64,64},
    })     
    self._info_panel:set_top(Holo.options.info_ypos)
    self._timer_panel:set_top(self._info_panel:bottom())
    self._info_panel:set_right(Holo.options.info_xpos - 2)    
    self._timer_panel:set_right(Holo.options.info_xpos)
end
  
function HUDInfo:create_info(config)
    config.visible = Holo.options[config.option] or true
    info_box = HUDBGBox_create(self._info_panel,{
        name = config.name,
        w = 30,
        h = 30,
        x = 0,
        y = 0
        },{color = config.color, alpha = HoloAlpha
    })    
    info_text = info_box:text({
        name = "text",
        text = "0",
        valign = "center",
        align = "center",
        vertical = "center",
        w = info_box:w(),
        h = info_box:h(),
        layer = 1,
        color = Infobox_text_color,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })  
    info_icon = self._info_panel:bitmap({
        name = config.name.."_icon",
        texture = config.icon,
        texture_rect = config.icon_rect or {0,0},
        w = config.icon_size or 36,
        h = config.icon_size or 36,
        valign = "top",
        layer = 2,
        x = -3,
        y = -3
    })
    if #self._infos < 1 then
        info_box:set_right(info_box:parent():w())
    else
        info_box:set_right(self._info_panel:child(self._infos[#self._infos].name):left() - 45)
    end
    info_icon:set_right( info_box:left() - 4)
    table.insert(self._infos, config)
end

function HUDInfo:update_infos()
    if Infotimer_enable then
       for i, timer in ipairs(self._timers) do
          if timer then
             timer:child("bg"):set_color(InfoTimers_bg_color)
             timer:child("bg"):set_alpha(HoloAlpha)
             timer:child("timer"):set_color(InfoTimers_text_color)
          end
       end
    end
    for i, config in ipairs(self._infos) do
        if self._info_panel:child(config.name) then
          if config.name == "enemies" then
              self._info_panel:child(config.name):child("bg"):set_color(enemies_bg_color) 
          elseif config.name == "civis" then
              self._info_panel:child(config.name):child("bg"):set_color(civis_bg_color) 
          elseif config.name == "hostages" then
              self._info_panel:child(config.name):child("bg"):set_color(Hostage_color) 
          elseif config.name == "pagers" then
              self._info_panel:child(config.name):child("bg"):set_color(pagers_bg_color)        
          elseif config.name == "gagepacks" then
              self._info_panel:child(config.name):child("bg"):set_color(gagepacks_bg_color) 
          end              
            self._info_panel:child(config.name):child("text"):set_color(Infobox_text_color)        
            self._info_panel:child(config.name):child("bg"):set_alpha(HoloAlpha)
        end  
    end
    self._info_panel:set_top(Holo.options.info_ypos)
    self._timer_panel:set_top(self._info_panel:bottom())
    self._info_panel:set_right(Holo.options.info_xpos - 2)    
    self._timer_panel:set_right(Holo.options.info_xpos)
    self:layout_timers()
end

function HUDInfo:create_timer(timer_id)
    if not Infotimer_enable then
        return
    end
    if timer_id and not self._timer_panel:child("pnl"..timer_id) then
        local new_timer = HUDBGBox_create(self._timer_panel,{
            name = "pnl"..timer_id, 
            y = 0, 
            w = InfoTimers_size, 
            h = InfoTimers_size, 
            halign = "right", 
            align = "right"
            },{color = InfoTimers_bg_color, alpha = HoloAlpha
        })    
        local timer_text = new_timer:text({
            name = "timer", 
            visible = true, 
            text = "0s".."\n".."Drill",  
            color = InfoTimers_text_color , 
            blend_mode = "normal", 
            layer = 3, 
            y = InfoTimers_size / 5, 
            vertical = "top", 
            align = "center", 
            font_size = InfoTimers_size / 3, 
            font = "fonts/font_large_mf"
        }) 
        local rows = 1
        table.insert(self._timers, new_timer)
        if #self._timers < InfoTimers_max + 1 then
            new_timer:set_x(self._timer_panel:w() - (new_timer:w() + 2) * (#self._timers -1))
            new_timer:set_y(0)
        else
            while #self._timers > ((InfoTimers_max * rows) + 1) do
                rows = rows + 1
            end
            local position = (#self._timers - 1) - InfoTimers_max * rows
            new_timer:set_x(self._timer_panel:w() - (new_timer:w() + 2) * position)
            new_timer:set_y((InfoTimers_size + 2) * rows)
        end
        self:layout_timers()
    end
end

function HUDInfo:set_timer(timer_id, time, name, customtime)
     if not Infotimer_enable then
        return
     end
    local truetime = truetime or Holo.options.truetime
    if time then
        if self._timer_panel:child("pnl"..timer_id) then
            local panel = self._timer_panel:child("pnl"..timer_id)
            local timer = panel:child("timer")
            local timerbg = panel:child("bg")
            name = name and name or "Timer"
            if not customtime and not truetime then
                timer:set_text(name.."\n".. string.format("%.2f", tonumber(time) or 0).."s")
            elseif customtime then
              if type(time) == "number" then
                  timer:set_text(name.."\n"..math.floor(time))
              else 
                  timer:set_text(name.."\n"..time)
              end              
            else
                local time = math.floor(time)
                local minutes = math.floor(time / 60)
                time = time - minutes * 60
                local seconds = math.round(time)
                timer:set_text(name.."\n".. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds))
            end
            timerbg:stop()
            timerbg:set_color(InfoTimers_bg_color)
            if string.match(name, "\n") and InfoTimers_size > 36 then
                timer:set_y(InfoTimers_size / 14)
            end 
            if string.len(name) > 7 then
              timer:set_font_size(InfoTimers_size / 3.5)
            end             
            if InfoTimers_size < 36 then
              timer:set_text(time)
              timer:set_font_size(InfoTimers_size / 3)
            end
        end
    end
    if time == -1 then
        self:remove_timer(timer_id)
    end
end
function HUDInfo:set_jammed(timer_id, time, name, customtime)
    if not Infotimer_enable then
        return
    end
    local truetime = truetime or Holo.options.truetime
    if time then
        if self._timer_panel:child("pnl"..timer_id) then
            local panel = self._timer_panel:child("pnl"..timer_id)
            local timer = panel:child("timer")
            local timerbg = panel:child("bg")
            name = name and name or "Timer"
            if not customtime and not truetime then
                timer:set_text(name.."\n".. string.format("%.2f", tonumber(time) or 0).."s")
            elseif customtime then
                timer:set_text(name.."\n"..math.floor(time))
            else
                local time = math.floor(time)
                local minutes = math.floor(time / 60)
                time = time - minutes * 60
                local seconds = math.round(time)
                timer:set_text(name.."\n".. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds))
            end
            timerbg:set_color(InfoTimers_bg_jammed_color)
            timerbg:animate(callback(self, self, "flash"), true)

            if string.match(name, "\n")  and InfoTimers_size > 36 then
                timer:set_y(InfoTimers_size / 14)
            end 
            if InfoTimers_size < 36 then
                timer:set_text(time)
                timer:set_font_size(InfoTimers_size / 3)
            end
            if string.len(name) > 7 then
              timer:set_font_size(InfoTimers_size / 3.5)
            end  
        end
    end
end
function HUDInfo:remove_timer(timer_id)
   if not Infotimer_enable then
      return
     end
    if timer_id then
       for i, timer in ipairs(self._timers) do
            if timer:name() == "pnl"..timer_id then
               timer:animate(callback(self, self, "remove_animate"), i)
               return
            end
        end
    end
end
function HUDInfo:layout_timers()
  local times = 1
  for i, timer in ipairs(self._timers) do
    if i < InfoTimers_max + 1 then
        timer:animate(callback(self, self, "timers_animate"), self._timer_panel:w() - (timer:w() + 2) * i , timer:x(), 1)
        timer:animate(callback(self, self, "timers_animate"), 0 , timer:y(), 2) 
    else
        if i > (InfoTimers_max * times) + InfoTimers_max then
            times = times + 1
        end
        local num = i - InfoTimers_max * times
        timer:animate(callback(self, self, "timers_animate"),self._timer_panel:w() - (timer:w() + 2) * num, timer:x(), 1)
        timer:animate(callback(self, self, "timers_animate"), (InfoTimers_size + 2) * times, timer:y(), 2) 
    end
  end  
end

function HUDInfo:InfoUpdater() 
   if #self._infos > 0 then
        for k, config in pairs(self._infos) do 
            HUDInfo[config.func](self, config)   
        end
        self:layout_infos()
    end
end
function HUDInfo:CountInfo(config)
    if Holo.options[config.option] then
        local info_text = self._info_panel:child(config.name):child("text") 
        local info_num = 0
        for k, v in pairs(config.info) do 
            info_num = info_num + 1
        end
        if info_num == 0 then
           config.visible = false
        else
            config.visible = true
        end
        if tonumber(info_text:text()) ~= info_num then
            info_text:set_text(info_num)
            info_text:animate(callback(self, self, "flash_text"))
        end      
    else
        config.visible = false
    end 
end
function HUDInfo:CountPacks(config)
    if Holo.options[config.option] then
        config.visible = managers.gage_assignment:count_active_units() ~= 0
        local info_text = self._info_panel:child(config.name):child("text") 
        local max_units = managers.gage_assignment:count_all_units()
        local remaining = managers.gage_assignment:count_active_units()

        if info_text:text() ~= (tostring(max_units - remaining) .."/".. tostring(max_units))then
            info_text:set_text(tostring(max_units - remaining) .."/".. tostring(max_units))
        end 
    else
        config.visible = false
    end  
end
function HUDInfo:CountPagers(config)
    if Holo.options[config.option] then
        local info_text = self._info_panel:child(config.name):child("text") 
        local info_num = 4 - managers.groupai:state()._nr_successful_alarm_pager_bluffs 
        config.visible = managers.groupai:state():whisper_mode()
        if tonumber(info_text:text()) ~= info_num then
            info_text:set_text(info_num)
            info_text:animate(callback(self, self, "flash_text"))
        end 
    else
        config.visible = false
    end    
end

function HUDInfo:SetTop(rect, Top , icon)
    local t = 0
    local top = rect:top()
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)
        rect:set_top(math.lerp(Top, top, n))
        if icon then
            icon:set_top(math.lerp(Top, top, n))
        end
    end
    rect:set_top(Top)
    if icon then
        icon:set_top(Top)
    end
end
function HUDInfo:SetRight(rect, Right, icon)
    local t = 0
    local right = rect:right()
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)
        rect:set_right(math.lerp(Right, right, n))
        if icon then
            icon:set_right(rect:left())
        end
    end
    rect:set_right(Right)
    if icon then
        icon:set_right(rect:left())
    end
end
function HUDInfo:SetAlpha(rect, Alpha, icon)
    local t = 0
    local alpha = rect:alpha()
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)
        rect:set_alpha(math.lerp(Alpha, alpha, n))
        if icon then
            icon:set_alpha(math.lerp(Alpha, alpha, n))
        end
    end
    rect:set_alpha(Alpha)
    if icon then
        icon:set_alpha(Alpha)
    end
end
function HUDInfo:SetTopRight(rect, Top, Right, icon)
    local t = 0
    local top = rect:top()
    local right = rect:right()
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)
        rect:set_righttop(math.lerp(Right, right, n), math.lerp(Top, top, n))
        if icon then
            icon:set_righttop(rect:left(), math.lerp(Top, top, n))
        end
    end
    rect:set_righttop(Right, Top)
    if icon then
        icon:set_righttop(rect:left(), Top)
    end
end
function HUDInfo:CountHostages(config)
    local info_text = self._info_panel:child(config.name):child("text") 
    local info_num = managers.groupai:state()._hostage_headcount
    if tonumber(info_text:text()) ~= info_num then
        info_text:set_text(info_num)
        info_text:animate(callback(self, self, "flash_text"))
    end     
end
function HUDInfo:layout_infos()
  local i = 0
  local times = 0
  for _, config in pairs(self._infos) do 
      infobox = self._info_panel:child(config.name)
      info_icon = self._info_panel:child(config.name.."_icon")
      if config.visible then
          infobox:animate(callback(self, self, "SetAlpha"), 1)
          info_icon:animate(callback(self, self, "SetAlpha"), 1)
          i = i + 1
          if i > (Holo.options.Infobox_max * times) + Holo.options.Infobox_max then
              times = times + 1
          end
          infobox:animate(callback(self, self, "SetTopRight"), times * 45, infobox:parent():w() - (infobox:w() + 45) * (( i - (Holo.options.Infobox_max * times )) - 1), info_icon)
      else
          infobox:animate(callback(self, self, "SetAlpha"), 0)
          info_icon:animate(callback(self, self, "SetAlpha"), 0)
      end
  end     
  if self._timer_panel:top() ~= self._info_panel:bottom() then
      self._timer_panel:animate(callback(self, self, "SetTop"), self._info_panel:bottom())
  end  
  self._info_panel:set_h(44 * (times + 1))
end
 
function HUDInfo:timers_animate(timer, a, b, set)
    local t = 0
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)
        if set == 1 then
            timer:set_x(math.lerp(a, b, n))
        else
            timer:set_y(math.lerp(a, b, n))      
        end
    end
    if set == 1 then
        timer:set_x(a)  
    else
        timer:set_y(a)  
    end
    if self._timer_panel:w() ~= InfoTimers_size * InfoTimers_max + 10 then
        self._timer_panel:set_w(InfoTimers_size * InfoTimers_max + 10)
        self._timer_panel:set_right(self._full_hud:w() - 43)
        self:layout_timers()
    end
end
function HUDInfo:remove_animate(timer, i)
    local t = 0
    local x = timer:x()
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)
        timer:set_x(math.lerp(x + (timer:w() + 10),timer:x() , n))
        timer:set_alpha(math.lerp(0, 1, n))
    end
    table.remove(self._timers, i)
    self._timer_panel:remove(timer)
    self:layout_timers()  
end

function HUDInfo:flash( rect, forever )
    local t = 0
    while t > 0 or forever do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)
        rect:set_alpha(math.lerp(HoloAlpha / 1.5, HoloAlpha, n))
    end
    rect:set_alpha(HoloAlpha)
end

function HUDInfo:flash_text(text)
    local t = 0.5
    while t > 0 do
        t = t - coroutine.yield()
        local alpha = math.round(math.abs((math.sin(t * 360 * 3))))
        text:set_alpha(alpha)
    end
    text:set_alpha(1)
end


  