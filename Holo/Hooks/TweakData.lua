function TweakData:UpdateHolo()
    if Holo.Options:GetValue("Colors/ColorizeTeammates") then
        self.chat_colors[1] = Holo:GetColor("Colors/TeammateHost")
        self.chat_colors[2] = Holo:GetColor("Colors/Teammate2")
        self.chat_colors[3] = Holo:GetColor("Colors/Teammate3")
        self.chat_colors[4] = Holo:GetColor("Colors/Teammate4")
        self.chat_colors[5] = Holo:GetColor("Colors/TeammateAI")

        self.peer_vector_colors[1] = Vector3(self.chat_colors[1]:unpack())
        self.peer_vector_colors[2] = Vector3(self.chat_colors[2]:unpack())
        self.peer_vector_colors[3] = Vector3(self.chat_colors[3]:unpack())
        self.peer_vector_colors[4] = Vector3(self.chat_colors[4]:unpack())
        self.peer_vector_colors[5] = Vector3(self.chat_colors[5]:unpack())
    end
    if Holo.Options:GetValue("Menu") then
        self.screen_colors.resource = Holo:GetColor("Colors/Marker")
        self.screen_colors.button_stage_2 = Holo:GetColor("Colors/Marker")
        self.screen_colors.button_stage_3 = Holo:GetColor("TextColors/Menu")
        self.screen_colors.item_stage_2 = Holo:GetColor("Colors/Marker")
        self.screen_colors.item_stage_3 = Holo:GetColor("TextColors/Menu")
        self.screen_colors.title = Holo:GetColor("TextColors/Menu")
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

    local scale_multiplier = self.scale.default_font_multiplier
	local small_scale_multiplier = self.scale.small_font_multiplier
    local font_size = Holo.Options:GetValue("FontSize")
    self.menu.small_font_size = font_size * small_scale_multiplier
	self.menu.meidum_font_size = (font_size * 1.166) * scale_multiplier
	self.menu.eroded_font_size = font_size * 6.5
	self.menu.pd2_massive_font_size = font_size * 6.5
	self.menu.pd2_large_font_size = font_size * 3.5
    self.menu.pd2_medium_font_size = font_size * 2
    self.menu.pd2_small_font_size = font_size * 1.666    
	self.menu.pd2_tiny_font_size = font_size * 1.166
	self.menu.default_font_size = (font_size * 1.166) * scale_multiplier

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