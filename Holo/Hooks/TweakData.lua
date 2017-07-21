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
    if Holo.Options:GetValue("Menu") then
        self.screen_colors.resource = Holo:GetColor("Colors/Marker")
        self.screen_colors.button_stage_2 = Holo:GetColor("Colors/Marker")
        self.screen_colors.button_stage_3 = Holo:GetColor("TextColors/Menu")
        self.screen_colors.item_stage_2 = Holo:GetColor("Colors/Marker")
        self.screen_colors.item_stage_3 = Holo:GetColor("TextColors/Menu")
        self.screen_colors.text = Holo:GetColor("TextColors/Menu")
        self.overlay_effects.spectator.color = Holo:GetColor("Colors/Menu")
        if Holo:ShouldModify("Menu", "BlackScreen") then
            self.overlay_effects.level_fade_in.color = Holo:GetColor("Colors/Menu")
            self.overlay_effects.fade_in.color = Holo:GetColor("Colors/Menu")
            self.overlay_effects.fade_out.color = Holo:GetColor("Colors/Menu")
            self.overlay_effects.fade_out_permanent.color = Holo:GetColor("Colors/Menu")
            self.overlay_effects.fade_out_in.color = Holo:GetColor("Colors/Menu")
            self.overlay_effects.element_fade_in.color = Holo:GetColor("Colors/Menu")
            self.overlay_effects.element_fade_out.color = Holo:GetColor("Colors/Menu")
        end
    end    
    self.contour.deployable.standard_color = Holo:GetColor("Colors/DeployableStandard", true)   
    self.contour.deployable.selected_color = Holo:GetColor("Colors/DeployableSelected", true) 
    self.contour.deployable.active_color = Holo:GetColor("Colors/DeployableActive", true) 
    self.contour.deployable.interact_color = Holo:GetColor("Colors/DeployableInteract", true) 
    self.contour.deployable.disabled_color = Holo:GetColor("Colors/DeployableDisabled", true) 
    self.contour.deployable.standard_opacity = 1
    self.contour.interactable.standard_color = Holo:GetColor("Colors/Interactable", true)
    self.contour.interactable.selected_color = Holo:GetColor("Colors/InteractableSelected", true)
    self.contour.interactable.standard_opacity = 1
    self.contour.interactable_look_at.standard_color = Holo:GetColor("Colors/InteractableSelected", true)
    self.contour.interactable_look_at.selected_color = Holo:GetColor("Colors/InteractableSelected", true)
    self.contour.interactable_look_at.standard_opacity = 1
 
    if managers.criminals then 
        for _, char in ipairs(managers.criminals:characters()) do
            if alive(char.unit) then
                char.unit:movement():set_character_anim_variables()
            end
        end
    end
end
tweak_data:UpdateHolo()
Holo:AddUpdateFunc(callback(tweak_data, tweak_data, "UpdateHolo"))