if Holo:ShouldModify("Hud", "TeammateHud") then
	Hooks:PostHook(HUDTeammate, "init", "HoloInit", function(self)
		if not alive(self._player_panel) or not alive(self._player_panel:child("radial_health_panel")) then
			Holo:log("[ERROR] Something went wrong when trying to modify HUDTeammate")
			return
		end
		local radial_health_panel = self._player_panel:child("radial_health_panel")
		local weapons_panel = self._player_panel:child("weapons_panel")
		local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
	 	local cable_ties_panel = self._player_panel:child("cable_ties_panel")
	  	local grenades_panel = self._player_panel:child("grenades_panel")
		local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
		local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")
		self._player_panel:child("carry_panel"):set_alpha(0)
		primary_weapon_panel:child("weapon_selection"):child("weapon_selection"):hide()
		secondary_weapon_panel:child("weapon_selection"):child("weapon_selection"):hide()
		primary_weapon_panel:rect({
			name = "switch_bg",
			alpha = 0.1,
			w = 0,
			valign = "grow"
		})
		secondary_weapon_panel:rect({
			name = "switch_bg",
			alpha = 0.1,
			w = 0,
			valign = "grow"
		})
		Holo.Utils:Apply({self._panel:child("name_bg"), primary_weapon_panel:child("bg"), secondary_weapon_panel:child("bg")}, {texture = "units/white_df"})
		Holo.Utils:Apply({self._panel:child("callsign_bg"), self._panel:child("callsign"),cable_ties_panel:child("bg"),deployable_equipment_panel:child("bg"),grenades_panel:child("bg")},{visible = false})
		radial_health_panel:text({
			name = "Health",
			text = "100",
			color = Holo:GetColor("TextColors/Health"),
			layer = 3,
			w = radial_health_panel:w(),
			h = radial_health_panel:h(),
			vertical = "center",
			align = "center",
			font_size = self._main_player and 22 or 18,
			font = "fonts/font_large_mf"
		})
		self._player_panel:rect({
			name = "Mainbg",
			vertical = "bottom",
			layer = 0,
			color = Holo:GetColor("Colors/Teammate"),
			alpha = Holo.Options:GetValue("HudAlpha"),
			w = 130,
			h = 64
		})
		self._panel:rect({name = "teammate_line", w = 2})
		self:layout_equipments()
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)

	function HUDTeammate:show_switching(id, curr, total)
		local is_secondary = id == 1
		local weapons_panel = self._player_panel:child("weapons_panel")
		local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")
		local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
		QuickAnim:Work((is_secondary and secondary_weapon_panel or primary_weapon_panel):child("switch_bg"), "alpha", curr and 0.1 or 0)
		if not curr then
			return
		end
		secondary_weapon_panel:child("switch_bg"):set_w(is_secondary and (curr / total) * weapons_panel:w() or 0)
		primary_weapon_panel:child("switch_bg"):set_w(is_secondary and 0 or (curr / total) * weapons_panel:w())
	end

    function HUDTeammate:UpdateHolo()
        managers.hud:align_teammate_panels()
        local radial_health_panel = self._player_panel:child("radial_health_panel")
        local deployable_panel = self._player_panel:child("deployable_equipment_panel")
        local cableties_panel = self._player_panel:child("cable_ties_panel")
        local grenades_panel = self._player_panel:child("grenades_panel")
        local grenades = grenades_panel:child("grenades")
        local cable_ties = cableties_panel:child("cable_ties")
        local deployable = deployable_panel:child("equipment")
        local weapons_panel = self._player_panel:child("weapons_panel")
        local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")
        local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
        local bg = self._player_panel:child("Mainbg")
        local name_bg = self._panel:child("name_bg")
        local name = self._panel:child("name")
        local teammate_line = self._panel:child("teammate_line")
        local me = self._main_player    
		local bg_color = Holo:GetColor("Colors/Teammate")        
		local text_color = Holo:GetColor("TextColors/Teammate")        
        name:configure({
            color = text_color,
            font_size = 20,
            font = "fonts/font_medium_noshadow_mf",
        })
        managers.hud:make_fine_text(name)
        bg:set_size(me and 120 or 180, me and 64 or 21.33)

        if me then 
            bg:set_rightbottom(self._panel:size())
        else 
            bg:set_leftbottom(48, self._panel:h()) 
        end

        name_bg:set_size(name:w() + 4, name:h())
        name_bg:set_leftbottom(bg:left(), self._ai and bg:bottom() or bg:top())
        name:set_position(name_bg:x() + 2, name_bg:y())
        teammate_line:set_size(2, name_bg:h() + ((self._ai or me) and 0 or bg:h()))
        teammate_line:set_rightbottom(name_bg:leftbottom())
        
        Holo.Utils:Apply({name_bg, name, teammate_line}, {visible = Holo.Options:GetValue("MyName") or not self._main_player})
        Holo.Utils:Apply({name_bg, bg}, {color = bg_color, alpha = Holo.Options:GetValue("HudAlpha")})
        radial_health_panel:child("Health"):set_font_size(me and 22 or 18)      
        radial_health_panel:child("Health"):set_visible(me and Holo.Options:GetValue("HealthText") or not me and Holo.Options:GetValue("HealthTextTeammate"))
        self:set_radials()
		
	--Weapons
        if me then
            weapons_panel:set_size(80, radial_health_panel:h())
            weapons_panel:set_leftbottom(radial_health_panel:rightbottom())
        else
            weapons_panel:set_size(64, 30)
            weapons_panel:set_rightbottom(bg:right(), self._panel:h())
        end
        for i, panel in pairs({primary_weapon_panel, secondary_weapon_panel}) do
            panel:show()
            panel:child("ammo_total"):set_font_size(22)
            if me then
                panel:set_size(weapons_panel:w(), 32)
                panel:child("weapon_selection"):set_shape(panel:w() - panel:child("weapon_selection"):w(),0 ,12, panel:h())
                panel:child("ammo_clip"):set_font_size(32)
                panel:child("ammo_clip"):set_shape(0, 0, 38, panel:h())
                panel:child("ammo_total"):set_shape(panel:child("ammo_clip"):w(), 0, 30, panel:h())
                panel:child("bg"):set_size(2, panel:h())
                panel:child("bg"):set_color(Holo:GetColor("Colors/SelectedWeapon"))
                if i == 2 then
                    panel:set_y(primary_weapon_panel:bottom())
                end
            else
                panel:set_shape(0,0, 32, 30)
                panel:child("ammo_total"):set_shape(0,1, panel:size())
                panel:child("bg"):set_size(panel:w(), 2)
                panel:child("bg"):set_bottom(panel:h())
                if i == 2 then
                    panel:set_left(primary_weapon_panel:right())
                end
            end
            panel:child("ammo_total"):set_color(text_color)
            panel:child("ammo_clip"):set_color(text_color)
        end
	--Weapons end

	--Equipments
        deployable_panel:set_shape(weapons_panel:right() + 2, weapons_panel:y() - 1, 36, 21.33)
        local eq_size = deployable_panel:h() - 4
        
        deployable:set_color(text_color)
		for _, v in pairs({deployable_panel, cableties_panel, grenades_panel}) do
			v:child("amount"):configure({
				font = "fonts/font_large_mf",
				font_size = 20,
				color = text_color,
				x = 0, y = 2, w = deployable_panel:w(), h = deployable_panel:h()
			})
		end
		for _, v in pairs({deployable, cable_ties, grenades}) do
			v:configure({
				w = eq_size,
				h = eq_size,
				color = text_color
			})
			v:set_center_y(v:parent():child("amount"):center_y())
		end
        cableties_panel:set_shape(deployable_panel:shape())
        grenades_panel:set_shape(cableties_panel:shape())

        self._panel:child("condition_icon"):set_shape(radial_health_panel:shape())
        self._panel:child("condition_timer"):set_shape(radial_health_panel:shape())
	--Equipments end
        if self._main_player then
            cableties_panel:set_top(deployable_panel:bottom())
            grenades_panel:set_top(cableties_panel:bottom())
        else
            self:layout_equipments()
        end
        self:update_special_equipments()
        self:layout_special_equipments()
        self:recreate_weapon_firemode()
    end

    function HUDTeammate:set_radials()
        local panel = self._player_panel:child("radial_health_panel")
        local radial_size = self._main_player and 64 or 48
        panel:set_size(radial_size,radial_size)
        panel:set_rightbottom(self._player_panel:child("Mainbg"):left() - 2, self._player_panel:child("Mainbg"):bottom())
        for _, child in pairs(panel:children()) do
            child:set_size(panel:size())
        end
        if Holo.Options:GetValue("HealthAndArmor") then
            panel:child("radial_health"):set_blend_mode("normal")
            panel:child("radial_health"):set_image("guis/textures/custom/Health" .. Holo.RadialNames[Holo.Options:GetValue("Colors/Health")])
            panel:child("radial_bg"):set_image("guis/textures/custom/RadialBG")
            panel:child("damage_indicator"):set_image("guis/textures/custom/HealthRed")
            panel:child("radial_custom"):set_image("guis/textures/custom/HealthCyan")
            panel:child("radial_shield"):set_blend_mode("normal")
            panel:child("radial_shield"):set_image("guis/textures/custom/Circle" .. Holo.RadialNames[Holo.Options:GetValue("Colors/Armor")])
            panel:child("damage_indicator"):hide()          
        end
        local interact_panel = self._player_panel:child("interact_panel")
        interact_panel:set_size(panel:size())
        interact_panel:set_world_position(panel:child("radial_shield"):world_position())
        self._interact._circle:set_shape(0, 0, interact_panel:h(), interact_panel:h())
        self._interact._bg_circle:set_shape(0, 0, self._interact._circle:size())

        if self._stamina_bar and self._stamina_line then
            self._stamina_bar:set_image("guis/textures/custom/HealthWhite")
            self._stamina_bar:set_size(panel:w() * 0.37, panel:h() * 0.37)
            self._stamina_bar:set_world_center(panel:world_center())
            self._stamina_line:set_size(panel:w() * 0.05, 2)
            self._stamina_line:set_world_center(panel:world_center())
        end
    end

	function HUDTeammate:_create_firemode(is_secondary)
		local weapon_panel = self._player_panel:child("weapons_panel"):child((is_secondary and "secondary" or "primary") .. "_weapon_panel")
		local weapon_selection_panel = weapon_panel:child("weapon_selection")
		local firemode = weapon_selection_panel:child("firemode")
		if alive(firemode) then	weapon_selection_panel:remove(firemode) end
		if self._main_player then
			local equipped_wep = managers.blackmarket and (is_secondary and managers.blackmarket:equipped_secondary() or managers.blackmarket:equipped_primary())
			local weapon_tweak_data = tweak_data.weapon[equipped_wep.weapon_id]
			local fire_mode = weapon_tweak_data.FIRE_MODE
			local can_toggle_firemode = weapon_tweak_data.CAN_TOGGLE_FIREMODE
			local locked_to_auto = managers.weapon_factory:has_perk("fire_mode_auto", equipped_wep.factory_id, equipped_wep.blueprint)
			local locked_to_single = managers.weapon_factory:has_perk("fire_mode_single", equipped_wep.factory_id, equipped_wep.blueprint)
			local firemode = weapon_selection_panel:text({
				name = "firemode",
				color = Holo:GetColor("TextColors/Teammate"),
				text = ":",
				font = "fonts/font_medium_mf",
				font_size = 24,
				x = 4,
				w = 24,
				h = 24,
			})
			firemode:set_bottom(weapon_selection_panel:h() - 1)
			if locked_to_single or not locked_to_auto and fire_mode == "single" then firemode:set_text(".") end
		end
	end

	function HUDTeammate:set_weapon_firemode(id, firemode)
		local weapon_panel = self._player_panel:child("weapons_panel"):child((id == 1 and "secondary" or "primary") .. "_weapon_panel")
		local weapon_selection_panel = weapon_panel:child("weapon_selection")
		local firemode_text = weapon_selection_panel:child("firemode")
		if alive(firemode_text) then firemode_text:set_text(firemode == "single" and "." or ":") end
	end

    function HUDTeammate:layout_equipments()
        local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
        local cable_ties_panel = self._player_panel:child("cable_ties_panel")
        local grenades_panel = self._player_panel:child("grenades_panel")
        local Mainbg = self._player_panel:child("Mainbg")
        local deployable_visible = deployable_equipment_panel:child("amount"):visible()
        local cable_ties_visible = cable_ties_panel:child("amount"):visible()
        if not self._main_player then
            deployable_equipment_panel:set_leftbottom(Mainbg:leftbottom())
            cable_ties_panel:set_y(Mainbg:y())
            grenades_panel:set_y(Mainbg:y())
            if deployable_visible then
                if cable_ties_visible then
                    cable_ties_panel:set_left(deployable_equipment_panel:right() - 4)
                    grenades_panel:set_left(cable_ties_panel:right() - 4)
                else
                    grenades_panel:set_left(deployable_equipment_panel:right() - 4)
                end
            else
                if cable_ties_visible then
                    cable_ties_panel:set_left(Mainbg:left() - 4)
                    grenades_panel:set_left(cable_ties_panel:right() - 4)
                else
                    grenades_panel:set_left(Mainbg:left() - 4)
                end
            end
        end
    end

	function HUDTeammate:set_state(state)
		if alive(self._player_panel) then self._player_panel:set_alpha(state == "player" and 1 or 0) end
	end

	function HUDTeammate:_set_weapon_selected(id, hud_icon)
		local is_secondary = id == 1
		local s = self._main_player and "w" or "h"
		local wep_panel = self._player_panel:child("weapons_panel")
		local secondary_bg = wep_panel:child("secondary_weapon_panel"):child("bg")
		local primary_bg = wep_panel:child("primary_weapon_panel"):child("bg")
		primary_bg:set_color(Holo:GetColor("Colors/SelectedWeapon"))
		secondary_bg:set_color(Holo:GetColor("Colors/SelectedWeapon"))
		QuickAnim:Work(primary_bg, 
			"alpha", is_secondary and 0 or 1,
			s, is_secondary and 0 or 2,
			"speed", 10
		)
		QuickAnim:Work(secondary_bg, 
			"alpha", is_secondary and 1 or 0,
			s, is_secondary and 2 or 0,
			"speed", 10
		)
	end

	Hooks:PostHook(HUDTeammate, "set_name", "HoloSetName", function(self, teammate_name)
		self._panel:child("callsign"):hide()
		self._panel:child("callsign_bg"):hide()
		self._panel:child("name"):set_text(Holo.Options:GetValue("UpperCaseNames") and teammate_name:upper() or teammate_name)
		self:UpdateHolo()
	end)

	function HUDTeammate:_set_amount_string(text, amount)
		local zero = self._main_player and amount < 10 and "0" or ""
		text:set_text(zero .. amount)
		self:layout_equipments()
	end

	function HUDTeammate:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max)
		local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")
		weapon_panel:show()
		if Holo.Options:GetValue("FixedAmmoTotal") and ((type == "primary" and managers.blackmarket:equipped_primary().weapon_id ~= "saw") or (type == "secondary" and managers.blackmarket:equipped_secondary().weapon_id ~= "saw_secondary") ) then
			current_left = current_left - current_clip
		end
		local ammo_clip = weapon_panel:child("ammo_clip")
		local ammo_total = weapon_panel:child("ammo_total")
		ammo_clip:set_text(tostring(current_clip))
		ammo_total:set_text(tostring(current_left))
	end

	Hooks:PostHook(HUDTeammate, "set_health", "HoloSetHealth", function(self, data)
		local radial_health_panel = self._player_panel:child("radial_health_panel")
		local Health = radial_health_panel:child("Health")
		local val = data.current / data.total
		QuickAnim:WorkColor(Health, Holo:GetColor("TextColors/Health") * val + Holo:GetColor("TextColors/HealthNeg") * (1 - val))
		Health:set_text(string.format("%.0f", data.current * 10))
	end)

	function HUDTeammate:set_talking(talking)
		local callsign = self._panel:child("callsign")
		callsign:set_alpha(talking and 0.6 or 1)
	end

	function HUDTeammate:set_downed()
		if self._main_player then
			self._player_panel:child("radial_health_panel"):child("Health"):set_text("0")
			self._player_panel:child("radial_health_panel"):child("Health"):set_color(Holo:GetColor("TextColors/HealthNeg"))
		end
	end

	function HUDTeammate:layout_special_equipments()
		local special_equipment = self._special_equipment
		local name = self._panel:child("name")
		local w = self._panel:w()
		for i, panel in ipairs(special_equipment) do
			panel:set_size(24, 24)
			for _, child in pairs(panel:children()) do
				if child:name() == "bitmap" then
					child:set_size(panel:size())
					child:set_position(0,0)
					if child:layer() == 2 then
						child:set_color(Holo:GetColor("Colors/Main"))
					end
				end
			end
			if panel:child("amount") then
				panel:child("amount"):set_size(panel:size())
				panel:child("amount"):set_font_size(12)
				panel:child("amount_bg"):set_size(20)
				panel:child("amount_bg"):set_center(panel:child("bitmap"):center())
				panel:child("amount_bg"):move(7, 7)
				panel:child("amount"):set_center(panel:child("amount_bg"):center())
			end

			if self._main_player then
				panel:set_x(w - (panel:w() * i))
				panel:set_bottom((Holo.Options:GetValue("MyName") and self._panel:child("name") or self._player_panel:child("Mainbg")):top() - 2)
			else
				panel:set_bottom(self._panel:child("name"):top() - 2)
				if i == 1 then
					panel:set_x(0)
				else
					panel:set_left(special_equipment[i - 1]:right())
				end
			end
		end
	end

	function HUDTeammate:update_special_equipments()
		local special_equipment = self._special_equipment
		for i, panel in ipairs(special_equipment) do
			panel:child("bitmap"):set_color(Holo:GetColor("Colors/Pickups"))
		end
	end

    Hooks:PostHook(HUDTeammate, "set_grenades_amount", "HoloSetGrenadesAmount", function(self) self:layout_equipments() end)
    Hooks:PostHook(HUDTeammate, "set_cable_ties_amount", "HoloSetCableTiesAmount", function(self) self:layout_equipments() end)
    Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount", "HoloSetDeployableEquipmentAmount", function(self) self:layout_equipments() end)
    function HUDTeammate:_create_primary_weapon_firemode() self:_create_firemode() end
    function HUDTeammate:_create_secondary_weapon_firemode() self:_create_firemode(true) end
    function HUDTeammate:set_callsign(id) self._panel:child("teammate_line"):set_color(tweak_data.chat_colors[id]) end
end