if Infohud_enable then
Holo:clone(DigitalGui)
function DigitalGui:setup(...)
    self.old.setup(self, ...)
    self._unit_names = {
        ID5a7e636bc31e53b2 = "Time",
        ID261a2eb7b6bb561a = "TimeLock",
        ID2357cab539c926a6 = "1",
        IDbb08f05d77beb8e0 = "BFD",
        IDc8de64c4b6207e4c = "3",
     }
     self._timer_id = string.gsub(math.random(99999999999999), "-", "")
     self._unit_id = string.gsub(tostring(self._unit:name():t()), "@","")
     self._name = self._unit_names[self._unit_id]
     if self._unit_id  == "ID5a7e636bc31e53b2" and managers.job:current_level_id() == "shoutout_raid" then
          self._temp_timer = true
     end  
     if self._unit_id == "ID261a2eb7b6bb561a" then
        self._timer_id = "ID261a2eb7b6bb561a"
     end
end

function DigitalGui:update(...)
    self.old.update(self, ...)
    if self.TYPE == "timer" and not self._timer_paused and self._timer_count_down then
        self:update_timer()
    end
    log(tostring(self._visible))
end

function DigitalGui:timer_start_count_down(...)
    self.old.timer_start_count_down(self, ...)
    if Holo._hudinfo then
        if not self._created and not self._temp_timer then
            Holo._hudinfo:create_timer(self._timer_id)
            self._created = true
        end
    end
end
function DigitalGui:timer_pause(...)
    self.old.timer_pause(self, ...)  
    if Holo._hudinfo then
        if self._temp_timer then
            Holo._hudinfo:remove_timer(self._timer_id)
            self._created = false
        elseif self._unit_names[self._unit_id] ~= "Time" then
            Holo._hudinfo:set_jammed(self._timer_id, self._time, self._name)
        else
            Holo._hudinfo:remove_timer(self._timer_id)
        end
    end
end
function DigitalGui:timer_resume(...)
    self.old.timer_resume(self, ...)
    if Holo._hudinfo then
        if not self._created and not self._temp_timer then
          Holo._hudinfo:create_timer(self._timer_id)
          self._created = true
        else
            if self._timer > 0 then
              self:update_timer()
            end
        end
    end
end
function DigitalGui:set_color_type(type)
    self.COLOR_TYPE = type
    self.DIGIT_COLOR = DigitalGui.COLORS[self.COLOR_TYPE]
    self._title_text:set_color(self.DIGIT_COLOR)
    if Holo._hudinfo then
        if self.DIGIT_COLOR == DigitalGui.COLORS.red then
           Holo._hudinfo:remove_timer(self._timer_id)
           self._created = false
        end
    end
end
function DigitalGui:timer_set(...)
    self.old.timer_set(self, ...)  
    if self._timer > 0 then
        self:update_timer()
    end
end
function DigitalGui:_timer_stop(...)
    self.old._timer_stop(self, ...)  
    if Holo._hudinfo then
        if not self._timer_paused then
            Holo._hudinfo:remove_timer(self._timer_id)
            self._created = false
        end 
    end
end
function DigitalGui:update_timer()
    if Holo._hudinfo then
        self._time = self._timer < 0 and 0 or self._timer
        local time = math.floor(self._time)
        local minutes = math.floor(time / 60)
        time = time - minutes * 60
        local seconds = math.round(time)
        if self._temp_timer and not self._created and not self._timer_count_down then
            Holo._hudinfo:create_timer(self._timer_id)
            self._created = true
        end  
        if self._timer_count_down and self._timer <= 0 then
            Holo._hudinfo:remove_timer(self._timer_id)
            self._created = false
        end

        if self._created then
            if self._temp_timer then
                Holo._hudinfo:set_timer(self._timer_id,seconds, "Temp", true)
            else
                Holo._hudinfo:set_timer(self._timer_id, self._time, self._name)
            end
        end
    end
end
function DigitalGui:destroy(...)
    self.old.destroy(self, ...)    
    if Holo._hudinfo then
        Holo._hudinfo:remove_timer(self._timer_id)
    end
end

end