if Holo.Options:GetValue("Base/Info") then
Hooks:PostHook(DigitalGui, "setup", "HoloSetup", function(self)
    self._unit_names = {
        ID5a7e636bc31e53b2 = "Timer",
        ID261a2eb7b6bb561a = "TimeLock",
        ID2357cab539c926a6 = "Timer",
        IDbb08f05d77beb8e0 = "BFD",
        IDc8de64c4b6207e4c = "Timer",
     }
     self._unit_id = string.gsub(tostring(self._unit:name():t()), "@","")
     self._name = self._unit_names[self._unit_id]
     if self._unit_id  == "ID5a7e636bc31e53b2" and managers.job:current_level_id() == "shoutout_raid" then
        self._name = "Temp"
        self._temp_timer = true
     end  
end)

Hooks:PostHook(DigitalGui, "update", "HoloUpdate", function(self)
    if self.TYPE == "timer" and not self._timer_paused and self._timer_count_down then
        self:update_timer()
    end
end)

Hooks:PostHook(DigitalGui, "timer_start_count_down", "HoloTimerStartCountDown", function(self)
    if not Holo.Info then
        return 
    end             
    if not self._created and not self._temp_timer then
        Holo.Info:CreateInfo({
            timer = true,
            visible = true,
            name = self._unit:id(),
            panel = self._name,
        })              
        self._created = true
    end
end)

Hooks:PostHook(DigitalGui, "timer_pause", "HoloTimerPause", function(self)
    if not Holo.Info then
        return 
    end   
    Holo.Info:SetInfoValueColor(self._name, self._unit:id(), "Colors/" .. (self._unit_names[self._unit_id] ~= "Time" and "Timers" or "TimersJammed"))  
    if self._temp_timer then
        Holo.Info:RemoveInfoValue(self._name, self._unit:id())
        self._created = false
    elseif self._unit_names[self._unit_id] == "Time" then
        Holo.Info:RemoveInfoValue(self._name, self._unit:id())
        self._created = false
    end        
end)

Hooks:PostHook(DigitalGui, "timer_resume", "HoloTimerResume", function(self)
    if not Holo.Info then
        return 
    end             
    if not self._created and not self._temp_timer then
       Holo.Info:CreateInfo({
            timer = true,
            visible = true,
            name = self._unit:id(),
            panel = self._name,
        })  
        self._created = true
    else
        if self._timer > 0 then
            self:update_timer()
        end
    end
end)

Hooks:PostHook(DigitalGui, "timer_set", "HoloTimerSet", function(self)
   if self._timer > 0 then
        self:update_timer()
    end
end)

Hooks:PostHook(DigitalGui, "destroy", "HoloDestroy", function(self)
    if not Holo.Info then
        return 
    end            
    Holo.Info:RemoveInfoValue(self._name, self._unit:id())
end)

function DigitalGui:set_color_type(type)
    if not Holo.Info then
        return 
    end             
    self.COLOR_TYPE = type
    self.DIGIT_COLOR = DigitalGui.COLORS[self.COLOR_TYPE]
    self._title_text:set_color(self.DIGIT_COLOR)
    if self.DIGIT_COLOR == DigitalGui.COLORS.red then
        Holo.Info:RemoveInfoValue(self._name, self._unit:id())
        self._created = false
    end
end

function DigitalGui:update_timer()
    self._time = self._timer < 0 and 0 or self._timer
    if self._temp_timer and not self._created and not self._timer_count_down then
       Holo.Info:CreateInfo({
            timer = true,
            visible = true,
            name = self._unit:id(),
            panel = self._name,
        })  
        self._created = true
    end  
    if self._timer_count_down and self._timer <= 0 then  
        Holo.Info:RemoveInfoValue(self._name, self._unit:id())
        self._created = false
    end

    if self._created then
        Holo.Info:SetInfoTime(self._name, self._unit:id(), self._time, self._temp_timer)
    end
end

end