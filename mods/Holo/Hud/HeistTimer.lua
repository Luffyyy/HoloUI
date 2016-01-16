Holo:clone(HUDHeistTimer)
function HUDHeistTimer:init( ... )
    self.old.init(self, ...)
    if Holo.options.hudbox_enable == true and Holo.options.Timerbg_enable == true then 
        self._bg_box = HUDBGBox_create( self._heist_timer_panel, { w = 60, h = 25, x = 0, y = 0, align = "center", vertical = "top"}, { color = Timerbg_color, blend_mode = "normal", alpha = HoloAlpha } )
        self._bg_box:child("bg"):set_color(Timerbg_color)
        self._bg_box:child("bg"):set_alpha(HoloAlpha)
        self._bg_box:set_center(self._timer_text:center())
        self._timer_text:set_font_size(24)
        local _,y,_,_ = self._timer_text:text_rect()
        self._bg_box:set_y(y)
        self._timer_text:set_y(1)
    end
    self._timer_text:set_color(Timer_text_color)
end

function HUDHeistTimer:update()
    if self._bg_box then
        bg = self._bg_box:child("bg")
        bg:set_alpha(HoloAlpha)
        bg:set_color(Timerbg_color)
    end
    self._timer_text:set_color(Timer_text_color)
end
function HUDHeistTimer:set_time( ... )
    self.old.set_time(self, ...)
    if self._bg_box and Holo.options.HoxHud_support == true then 
        if managers.hud._hud_assault_corner._assault then
            self._bg_box:set_visible(false)
        elseif managers.hud._hud_assault_corner._point_of_no_return then
            self._bg_box:set_visible(false)
        else
            self._bg_box:set_visible(true)            
        end
        if managers.hud._hud_assault_corner._assault and Holo.options.assaultbox_enable then
            self._timer_text:set_color(Assault_text_color)
            self._timer_text:set_y(0)
        end  
    end
end

