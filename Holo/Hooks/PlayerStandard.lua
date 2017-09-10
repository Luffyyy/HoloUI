if Holo.Options:GetValue("Hud") then
    Holo:Post(PlayerStandard, "_start_action_equip_weapon", function(self, t)
        self._is_weapon = true
    end)
    Holo:Pre(PlayerStandard, "_update_equip_weapon_timers", function(self, t)
        if self._is_weapon and self._equip_weapon_expire_t then
            if t >= self._equip_weapon_expire_t then
                self._is_weapon = nil
                managers.hud:show_switching(self._ext_inventory:equipped_selection())
            else
                local total = (self._equipped_unit:base():weapon_tweak_data().timers.equip or 0.7) / self:_get_swap_speed_multiplier()
                local curr = total - (self._equip_weapon_expire_t - t)
                managers.hud:show_switching(self._ext_inventory:equipped_selection(), curr, total)
            end
        end
    end)
end
 