 Hooks:PostHook(CopDamage, "init", "HoloInit", function(self)
    self._info = FloatingInfo:new(self._unit:get_object(Idstring("Head")), true)
    self._info.text = string.format("%.0f", self._health * 10)
    self._info.percent = self._health / self._HEALTH_INIT
end)
Hooks:PostHook(CopDamage, "die", "HoloDie", function(self)
    if self._info then
        self._info:destroy() 
        self._info = nil
    end
end)
Hooks:PostHook(CopDamage, "destroy", "HoloDestroy", function(self)
    if self._info then
        self._info:destroy() 
        self._info = nil
    end
end)
Hooks:PostHook(CopDamage, "_update_debug_ws", "HoloUpdateGUI", function(self, damage_info)
    if self._info and self._health then
        self._info.text = string.format("%.0f", self._health * 10)
        self._info.percent = self._health / self._HEALTH_INIT
		if damage_info and damage_info.damage > 0 then
            self._info._ws:panel():text({
                rotation = 360,
                text = string.format("%.0f", damage_info.damage * 10),
                y = -20,
                h = 40,
                w = 40,
                font = "fonts/font_large_mf",
                align = "center",
                vertical = "center",
                font_size = 32,
                render_template = "OverlayVertexColorTextured"
            }):animate(function(o)
                local mt = 8
                local t = mt
                local dir = math.sin(Application:time() * 1000)
                while t > 0 do
                    local dt = coroutine.yield()
                    t = math.clamp(t - dt, 0, mt)
                    local speed = dt * 100
                    o:move(0, (1 - math.abs(dir)) * -speed)
                    o:set_alpha(t / mt)
                end
                self._info._ws:panel():remove(o)
            end)
		end
    end
end)