function TweakData:UpdateHolo()
    if Holo.Options:GetValue("Colors/ColorizeTeammates") then
        self.chat_colors = {
            Holo:GetColor("Colors/TeammateHost"),
            Holo:GetColor("Colors/Teammate2"),
            Holo:GetColor("Colors/Teammate3"),
            Holo:GetColor("Colors/Teammate4"),
            Holo:GetColor("Colors/TeammateAI")
        }
        self.peer_vector_colors = {
            Vector3(self.chat_colors[1]:unpack()),
            Vector3(self.chat_colors[2]:unpack()),
            Vector3(self.chat_colors[3]:unpack()),
            Vector3(self.chat_colors[4]:unpack()),
            Vector3(self.chat_colors[5]:unpack()),
        }
    end
    if Holo.Options:GetValue("Base/Menu") then
        self.screen_colors.resource = Holo:GetColor("Colors/Marker")
        self.screen_colors.button_stage_2 = Holo:GetColor("Colors/Marker")
        self.screen_colors.button_stage_3 = Holo:GetColor("TextColors/Menu")
        self.screen_colors.item_stage_2 = Holo:GetColor("Colors/Marker")
        self.screen_colors.item_stage_3 = Holo:GetColor("TextColors/Menu")
        self.overlay_effects.spectator.color = Holo:GetColor("Colors/MenuBackground")
        self.overlay_effects.level_fade_in.color = Holo:GetColor("Colors/MenuBackground")
        self.overlay_effects.fade_in.color = Holo:GetColor("Colors/MenuBackground")
        self.overlay_effects.fade_out.color = Holo:GetColor("Colors/MenuBackground")
        self.overlay_effects.fade_out_permanent.color = Holo:GetColor("Colors/MenuBackground")
        self.overlay_effects.fade_out_in.color = Holo:GetColor("Colors/MenuBackground")
        self.overlay_effects.element_fade_in.color = Holo:GetColor("Colors/MenuBackground")
        self.overlay_effects.element_fade_out.color = Holo:GetColor("Colors/MenuBackground")
    end    
    if managers.criminals then 
        for _, char in ipairs(managers.criminals:characters()) do
            if alive(char.unit) then
                char.unit:movement():set_character_anim_variables()
            end
        end
    end
end
tweak_data:UpdateHolo()
