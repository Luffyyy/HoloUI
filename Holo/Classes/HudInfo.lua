HUDInfo = HUDInfo or class()
function HUDInfo:init(hud)
    self._full_hud = hud
    self._timer_panel = self._full_hud:panel({
        name = "Timer_panel",
        w = (self:TimerSize() * (Holo.Options:GetValue("Info/RowMaxTimers") + 1)),
        layer = -11,
        valign = "top",
        halign = "right",
        visible = Holo.Options:GetValue("Info/Timers"),
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
        name = "Hostages",
        visible = true,
        icon = "guis/textures/pd2/skilltree/icons_atlas",
        func = "CountHostages",
        icon_rect = {255,449, 64, 64}
    })
    self:create_info({
        name = "Enemies",
        hide = true,
        func = "CountInfo",
        icon = "guis/textures/pd2/skilltree/icons_atlas",
        icon_rect = {2,319,64,64},
        info = managers.enemy:all_enemies(),
        count = true
    })
    self:create_info({
        name = "Civilians",
        hide = true,
        func = "CountInfo",
        icon = "guis/textures/pd2/skilltree/icons_atlas",
        icon_rect = {386,447,64,64},
        info = callback(managers.enemy, managers.enemy, "all_civilians"),
        count = true
    })
    self:create_info({
        name = "Pagers",
        func = "CountPagers",
        icon = "guis/textures/pd2/specialization/icons_atlas",
        icon_rect = {66,254,64,64},
    })
    local rects = {
        money = {4, 3, 70, 59},
        diamonds = {72, 7, 53, 53},
        gold = {132, 9, 56, 52},
        weapons = {188, 3, 57, 62},
    }
    for typ, _ in pairs(Holo.Loot) do
        self:create_info({
            name = typ,
            visible = true,
            color = "Loot",
            func = "CountLoot",
            icon = "guis/Holo/InfoIcons",
            icon_rect = rects[typ] or rects.money,
        })      
    end
    self:create_info({
        name = "GagePacks",
        func = "CountPacks",
        icon = "guis/Holo/InfoIcons",
        icon_rect = {10,66,45,45},
    })
    self._info_panel:set_top(Holo.Options:GetValue("Info/InfoPosY"))
    self._timer_panel:set_top(self._info_panel:bottom())
    self._info_panel:set_right(Holo.Options:GetValue("Info/InfoPosX"))
    self._timer_panel:set_right(Holo.Options:GetValue("Info/InfoPosX"))
end

function HUDInfo:create_info(config)
    local scale = Holo.Options:GetValue("HudScale")
    if not config.visible then
        config.option = "Info/" .. config.name
    end
    config.visible = config.visible or Holo.Options:GetValue(config.option)
    local size = self:TimerSize()
    local panel = HUDBGBox_create(self._info_panel,{
        name = config.name,
        w = 42 * size,
        h = 42 * size,
		},{color = Holo:GetColor("Colors/" .. (config.color or config.name)), alpha = Holo.Options:GetValue("HudAlpha")
    })
    local info_text = panel:text({
        name = "info",
        text = self:Text(config.name, "0"),
        wrap = true,
        vertical = "center",
        align = "center",
        w = size,
        h = size,
        layer = 2,
        color = Holo:GetColor("TextColors/Infos"),
        font = "fonts/font_large_mf",
        font_size = size / 3
    })
    table.insert(self._infos, config)
end

function HUDInfo:update_infos()
    if Holo.Options:GetValue("Info/Timers") then
        for i, timer in ipairs(self._timers) do
            if timer then
                HUDBGBox_recreate(timer,{
                    w = self:TimerSize(),
                    h = self:TimerSize(),
                    alpha = Holo.Options:GetValue("HudAlpha"),
                    color = Holo:GetColor("Colors/Timers"),
                })                
                timer:child("info"):set_font_size(timer:h() / 3)
                timer:child("info"):set_size(timer:size())
                timer:child("info"):set_color(Holo:GetColor("TextColors/Timers"))
            end
        end
    end
    for i, config in ipairs(self._infos) do
        local info = self._info_panel:child(config.name)
        local scale = Holo.Options:GetValue("HudScale")
        if info then
            HUDBGBox_recreate(info,{
                w = 42 * scale,
                h = 42 * scale,
                alpha = Holo.Options:GetValue("HudAlpha"),
                color = Holo:GetColor("Colors/" .. (config.color or config.name)),
            })               
            info:child("info"):set_color(Holo:GetColor("TextColors/Infos"))
            info:child("info"):set_font_size(info:h() / 3)
            info:child("info"):set_size(info:size())
        end
    end
    self._info_panel:set_top(Holo.Options:GetValue("Info/InfoPosY"))
    self._timer_panel:set_top(self._info_panel:bottom())
    self._info_panel:set_right(Holo.Options:GetValue("Info/InfoPosX") - 2)
    self._timer_panel:set_right(Holo.Options:GetValue("Info/InfoPosX"))
    self:layout_timers(true)
end
function HUDInfo:Text(name, time)
    return string.format("%s" .. "\n" .. "%s", name, time)
end
function HUDInfo:TimerSize()
    return 48 * Holo.Options:GetValue("HudScale")
end
function HUDInfo:create_timer(timer_id)
    if not Holo.Options:GetValue("Info/Timers") then
        return
    end
    if timer_id and not self._timer_panel:child("timer" .. timer_id) then
        local size = self:TimerSize()
        local new_timer = HUDBGBox_create(self._timer_panel,{
            name = "timer" .. timer_id,
            w = size,
            h = size,
            halign = "right",
            align = "right"
        },{color = Holo:GetColor("Colors/Timers"), alpha = Holo.Options:GetValue("HudAlpha")
        })
        local text = new_timer:text({
            name = "info",
            text = self:Text("Drill", "0s"),
            color = Holo:GetColor("TextColors/Timers"),
            layer = 1,
            h = size,
            w = size,
            wrap = true,
            vertical = "center",
            align = "center",
            font_size = size / 3,
            font = "fonts/font_large_mf"
        })
        local rows = 1
        local scale = Holo.Options:GetValue("HudScale")
        table.insert(self._timers, new_timer)
        if #self._timers < Holo.Options:GetValue("Info/RowMaxTimers") + 1 then
            new_timer:set_x(self._timer_panel:w() - (new_timer:w() + 2) * (#self._timers -1))
            new_timer:set_y(0)
        else
            while #self._timers > ((Holo.Options:GetValue("Info/RowMaxTimers") * rows) + 1) do
                rows = rows + 1
            end
            local position = (#self._timers - 1) - Holo.Options:GetValue("Info/RowMaxTimers") * rows
            new_timer:set_x(self._timer_panel:w() - (new_timer:w() + (2 * scale)) * position)
            new_timer:set_y((new_timer:w() + (2 * scale)) * rows)
        end
        self:layout_timers()
    end
end

function HUDInfo:set_timer(timer_id, time, name, customtime)
    if not Holo.Options:GetValue("Info/Timers") then
        return
    end
    if time then
        if self._timer_panel:child("timer" .. timer_id) then
            local panel = self._timer_panel:child("timer" .. timer_id)
            local timerbg = panel:child("bg")
            local time_text = time
            name = name or "Timer"
            if not customtime and Holo.Options:GetValue("Info/TimerInSeconds") then
                time_text = time .. "s"
            elseif customtime then
                time_text = type(time) == "number" and math.floor(time) or time
            else
                time_text = math.floor(time)
                local minutes = math.floor(time_text / 60)
                time_text = time_text - minutes * 60
                local seconds = math.round(time_text)
                time_text = (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
            end
            panel:child("info"):set_text(self:Text(name, time_text))
            timerbg:set_color(Holo:GetColor("Colors/Timers"))
        end
    end
    if time <= 0 then
        self:remove_timer(timer_id)
    end
end
function HUDInfo:set_jammed(timer_id)
    if timer_id then
        if not Holo.Options:GetValue("Info/Timers") then
            return
        end
        if self._timer_panel and self._timer_panel:child("timer" .. timer_id) then
            local panel = self._timer_panel:child("timer" .. timer_id)
            panel:child("bg"):set_color(Holo:GetColor("Colors/TimersJammed"))
        end
    end
end
function HUDInfo:remove_timer(timer_id)
    if not Holo.Options:GetValue("Info/Timers") then
        return
    end
    if timer_id then
        for i, timer in ipairs(self._timers) do
            if timer:name() == ("timer" .. timer_id) then
            	GUIAnim.play(timer, "move", (timer:w() + 10))
            	GUIAnim.play(timer, "alpha", 0)
                if timer then
                    table.remove(self._timers, i)
                    self._timer_panel:remove(timer)
                    self:layout_timers()
                end
                return
            end
        end
    end
end
function HUDInfo:remove_timers()
    if not Holo.Options:GetValue("Info/Timers") then
        return
    end
    for i, timer in ipairs(self._timers) do
        timer:animate(callback(self, self, "remove_animate"), i)
    end
end
function HUDInfo:layout_timers(no_anim)
    local times = 1
    if self._timer_panel:w() ~= (self:TimerSize() * (Holo.Options:GetValue("Info/RowMaxTimers") + 1)) then
        self._timer_panel:set_w(self:TimerSize() * (Holo.Options:GetValue("Info/RowMaxTimers") + 1))
        self._timer_panel:set_right(self._full_hud:w() - 43)
        self:layout_timers()
    end
    for i, timer in ipairs(self._timers) do
        local x, y = 0,0
        timer:stop()
        local move = 2 * Holo.Options:GetValue("HudScale")
        if i < Holo.Options:GetValue("Info/RowMaxTimers") + 1 then
            x = self._timer_panel:w() - (timer:w() + move) * i
        else
            if i > (Holo.Options:GetValue("Info/RowMaxTimers") * times) + Holo.Options:GetValue("Info/RowMaxTimers") then
                times = times + 1
            end
            local num = i - Holo.Options:GetValue("Info/RowMaxTimers") * times
            x = self._timer_panel:w() - (timer:w() + move) * num
            y = (timer:w() + move) * times
        end
        if no_anim then
            timer:set_position(x,y)
        else
            GUIAnim.play(timer, "x", x)
            GUIAnim.play(timer, "y", y)
        end
    end
end
function HUDInfo:InfoUpdater()
    if #self._infos > 0 then
        for k, config in pairs(self._infos) do
            if not config.option or Holo.Options:GetValue(config.option) then 
                HUDInfo[config.func](self, config)
            else
                config.visible = false
            end
        end
        self:layout_infos()
    end
end
function HUDInfo:CountInfo(config)
    local info_text = self._info_panel:child(config.name):child("info")
    local info_num = 0
    for k, v in pairs(config.info) do
        info_num = info_num + 1
    end
    for k, typ in pairs(Holo.Loot) do
        for _, unit in pairs(typ) do
            if not unit:enabled() then
                Holo:RemoveLoot(k, unit)
            end
        end
    end
    if info_num == 0 then
        config.visible = false
    else
        config.visible = true
    end
    local text = self:Text(config.name, info_num)    
    if info_text:text() ~= text then
        info_text:animate(callback(nil, GUIAnim, "flash_icon"), 1, nil, true)        
        info_text:set_text(text)
    end
end
function HUDInfo:CountPacks(config)
    local info_text = self._info_panel:child(config.name):child("info")
    local info_num = managers.gage_assignment:count_active_units()
    local text = self:Text(config.name, info_num)
    config.visible = managers.gage_assignment:count_active_units() ~= 0
    if info_text:text() ~= text then    
        info_text:animate(callback(nil, GUIAnim, "flash_icon"), 1, nil, true)        
        info_text:set_text(text)
    end
end
function HUDInfo:CountPagers(config)
    local info_text = self._info_panel:child(config.name):child("info")
    local info_num = 4 - managers.groupai:state()._nr_successful_alarm_pager_bluffs
    local text = self:Text(config.name, info_num)
    config.visible = managers.groupai:state():whisper_mode()
    if info_text:text() ~= text then
        info_text:animate(callback(nil, GUIAnim, "flash_icon"), 1, nil, true)        
        info_text:set_text(text)
    end
end
function HUDInfo:CountLoot(config)
    local info_text = self._info_panel:child(config.name):child("info")
    local info_num = #Holo.Loot[config.name]
    local text = self:Text(config.name, info_num)
    config.visible = info_num > 0
    if info_text:text() ~= text then
        info_text:animate(callback(nil, GUIAnim, "flash_icon"), 1, nil, true)       
        info_text:set_text(text)
    end    
end
function HUDInfo:CountHostages(config)
    local info_text = self._info_panel:child(config.name):child("info")
    local info_num = managers.groupai:state()._hostage_headcount
    local text = self:Text(config.name, info_num)
    if info_text:text() ~= text then
        info_text:animate(callback(nil, GUIAnim, "flash_icon"), 1, nil, true)        
        info_text:set_text(text)
    end
end
function HUDInfo:layout_infos(no_anim)
    local times = 0
    local i = 1
    for _, config in pairs(self._infos) do
        local infobox = self._info_panel:child(config.name)
        if config.visible then
            infobox:stop()
            GUIAnim.play(infobox, "alpha", 1)
            if i > (Holo.Options:GetValue("Info/RowMaxInfos") * times) + Holo.Options:GetValue("Info/RowMaxInfos") then
                times = times + 1
            end
            i = i + 1
            local move = 4 * Holo.Options:GetValue("HudScale")
            local x = self._info_panel:w() - (infobox:w() + move) * (( i - (Holo.Options:GetValue("Info/RowMaxInfos") * times )) - 1)
            local y = times * (infobox:h() + move)
            if no_anim then
                infobox:set_position(x,y)                
            else
                GUIAnim.play(infobox, "right", x)
                GUIAnim.play(infobox, "y", y)
            end
        else
            GUIAnim.play(infobox, "alpha", 0)
        end
    end
    if self._timer_panel:top() ~= self._info_panel:bottom() then
    	GUIAnim.play(self._timer_panel, "top", self._info_panel:bottom())
    end
   --self._info_panel:set_h(Holo.Options:GetValue("InfoSize") * (times + 1))
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
