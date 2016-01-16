Holo:clone(HUDTeammate)
if Holo.options.hudteammate_enable and (not Holo.options.PDTHHud_support or not pdth_hud.loaded_options.Ingame.MainHud) and not Holo.options.GageHud_support then 
function HUDTeammate:init( ... )
	self.old.init(self, ...)
	local radial_health_panel = self._player_panel:child("radial_health_panel")
	local weapons_panel = self._player_panel:child("weapons_panel")
	local name = self._panel:child("name")
	local name_bg = self._panel:child("name_bg")
	local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
 	local cable_ties_panel = self._player_panel:child("cable_ties_panel")
  	local grenades_panel = self._player_panel:child("grenades_panel")
	local grenades = grenades_panel:child("grenades")
	local grenades_bg = grenades_panel:child("bg")	
	local cable_ties = cable_ties_panel:child("cable_ties")
	local cable_ties_bg = cable_ties_panel:child("bg")	
	local deployable = self._player_panel:child("deployable_equipment_panel"):child("equipment")
	local deployable_bg = self._player_panel:child("deployable_equipment_panel"):child("bg")	
	local amount_deployable = deployable_equipment_panel:child("amount")
	local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
	local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")

	self._player_panel:child("carry_panel"):set_alpha(0)
	radial_health_panel:child("radial_health"):set_blend_mode("normal")
	radial_health_panel:child("radial_health"):set_image("guis/textures/pd2/hud_health")
	radial_health_panel:child("radial_shield"):set_blend_mode("normal")		
	radial_health_panel:child("radial_shield"):set_image("guis/textures/pd2/hud_shield")
	radial_health_panel:child("damage_indicator"):hide()
	if self._main_player then	
		radial_health_panel:child("radial_rip"):set_blend_mode("normal")	
	end
    
	grenades:set_color(Equipments_color)
	cable_ties:set_color(Equipments_color)
	deployable:set_color(Equipments_color)	

	primary_weapon_panel:child("weapon_selection"):child("weapon_selection"):hide()
	secondary_weapon_panel:child("weapon_selection"):child("weapon_selection"):hide()

		
	Holo:ApplySettings({name_bg,primary_weapon_panel:child("bg"), secondary_weapon_panel:child("bg")},
	{
		color = teammatebg_color,
		alpha = teammatebg_alpha, 
		texture = "units/white_df"
	})  
	Holo:ApplySettings({secondary_weapon_panel:child("bg"),primary_weapon_panel:child("bg")},{w = 2, alpha = 0.4})
	Holo:ApplySettings({self._panel:child("callsign_bg"),self._panel:child("callsign"),cable_ties_panel:child("bg"),deployable_bg,grenades_panel:child("bg")},{visible = false})

	Holo:ApplySettings({name, secondary_weapon_panel:child("ammo_total"), secondary_weapon_panel:child("ammo_clip"),primary_weapon_panel:child("ammo_total"),
	primary_weapon_panel:child("ammo_clip"),cable_ties_panel:child("amount"),grenades_panel:child("amount"),deployable_equipment_panel:child("amount")},{color = teammate_text_color
	})
	local HealthNum = radial_health_panel:text({
		name = "HealthNum",
		visible = (Holo.options.HealthNum and self._main_player) and true or (Holo.options.HealthNumTM and not self._main_player) and true or false,
		text = "100",
		color = HealthNum_color,
		blend_mode = "normal",
		layer = 3,
		w = radial_health_panel:w(),
		h = radial_health_panel:h(),
		vertical = "center",
		align = "center",
		font_size = self._main_player and 22 or 18,
		font = "fonts/font_large_mf"
	})
	local teammate_line = self._panel:rect({
		name = "teammate_line",
		layer = 1,
		w = 2,
	})
	if self._main_player then
		name_bg:hide()
		name:hide()
		local Mainbg = self._player_panel:bitmap({
			name = "Mainbg",
			vertical = "bottom",
			visible = true,
			layer = 0,
			color = teammatebg_color,
			alpha = (not CompactHUD and not Fallout4hud) and teammatebg_alpha or 0,
			w = 130,
			h = 68,
		})	
	 	Mainbg:set_y(weapons_panel:y())
	 	Mainbg:set_x(weapons_panel:x())
	 	teammate_line:hide()
	else
		weapons_panel:set_alpha(0)
		local EquipmentsBG = self._player_panel:bitmap({
			name = "EquipmentsBG",
			vertical = "bottom",
			color = teammatebg_color,
			layer = 0,
			alpha = (not CompactHUD and not Fallout4hud) and teammatebg_alpha or 0,
			w = deployable_bg:w() * 3,
			h = deployable_bg:h(),
		})		
		EquipmentsBG:set_bottom(self._player_panel:bottom() - 6)
		EquipmentsBG:set_left(radial_health_panel:right() + 2)
		name_bg:set_left(radial_health_panel:right())
		name_bg:set_bottom(EquipmentsBG:top())
		name:set_bottom(EquipmentsBG:top())
		name:set_left(name_bg:left())
		teammate_line:set_h(name_bg:h() + EquipmentsBG:h())
		teammate_line:set_right(EquipmentsBG:left())

		deployable_equipment_panel:set_left(EquipmentsBG:left())
 		cable_ties_panel:set_left(deployable_equipment_panel:right())
  		grenades_panel:set_left(cable_ties_panel:right())		

  		deployable_equipment_panel:set_bottom(EquipmentsBG:bottom())
 		cable_ties_panel:set_bottom(EquipmentsBG:bottom())
  		grenades_panel:set_bottom(EquipmentsBG:bottom())
  		teammate_line:set_bottom( EquipmentsBG:bottom())

  		self:layout_equipments()
	end	 	
 end

function HUDTeammate:_create_primary_weapon_firemode()
	local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")
	local weapon_selection_panel = primary_weapon_panel:child("weapon_selection")
	local old_tick1 = weapon_selection_panel:child("tick1")
	local old_tick2 = weapon_selection_panel:child("tick2")
	local old_tick3 = weapon_selection_panel:child("tick3")
	if alive(old_tick1) then
		weapon_selection_panel:remove(old_tick1)
	end
	if alive(old_tick2) then
		weapon_selection_panel:remove(old_tick2)
	end	
	if alive(old_tick3) then
		weapon_selection_panel:remove(old_tick3)
	end
	if self._main_player then
		local equipped_primary = managers.blackmarket:equipped_primary()
		local weapon_tweak_data = tweak_data.weapon[equipped_primary.weapon_id]
		local fire_mode = weapon_tweak_data.FIRE_MODE
		local can_toggle_firemode = weapon_tweak_data.CAN_TOGGLE_FIREMODE
		local locked_to_auto = managers.weapon_factory:has_perk("fire_mode_auto", equipped_primary.factory_id, equipped_primary.blueprint)
		local locked_to_single = managers.weapon_factory:has_perk("fire_mode_single", equipped_primary.factory_id, equipped_primary.blueprint)
		local tick1 = weapon_selection_panel:rect({
			color = teammate_text_color,
			name = "tick1",
			w = 2,
			h = 6,
			x = 3,
			layer = 1
		})
		tick1:set_bottom(weapon_selection_panel:h() - 2)
		local tick2 = weapon_selection_panel:rect({
			color = teammate_text_color,			
			name = "tick2",
			w = 2,
			h = 6,
			layer = 2
		})
		tick2:set_left(tick1:right())
		tick2:set_bottom(weapon_selection_panel:h() - 2)
		tick2:set_alpha(0.5)
		tick2:move(0.5)
		local tick3 = weapon_selection_panel:rect({
			color = teammate_text_color,			
			name = "tick3",
			w = 2,
			h = 6,
			layer = 3
		})
		tick3:set_left(tick2:right())
		tick3:move(0.5)
		tick3:set_bottom(weapon_selection_panel:h() - 2)
		tick3:set_alpha(0.5)
		if locked_to_single or not locked_to_auto and fire_mode == "single" then
		else
			tick2:set_alpha(1)
			tick3:set_alpha(1)
		end
	end
end

function HUDTeammate:_create_secondary_weapon_firemode()
	local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
	local weapon_selection_panel = secondary_weapon_panel:child("weapon_selection")
	local old_tick1 = weapon_selection_panel:child("tick1")
	local old_tick2 = weapon_selection_panel:child("tick2")
	local old_tick3 = weapon_selection_panel:child("tick3")
	if alive(old_tick1) then
		weapon_selection_panel:remove(old_tick1)
	end
	if alive(old_tick2) then
		weapon_selection_panel:remove(old_tick2)
	end	
	if alive(old_tick3) then
		weapon_selection_panel:remove(old_tick3)
	end
	if self._main_player then
		local equipped_secondary = managers.blackmarket:equipped_secondary()
		local weapon_tweak_data = tweak_data.weapon[equipped_secondary.weapon_id]
		local fire_mode = weapon_tweak_data.FIRE_MODE
		local can_toggle_firemode = weapon_tweak_data.CAN_TOGGLE_FIREMODE
		local locked_to_auto = managers.weapon_factory:has_perk("fire_mode_auto", equipped_secondary.factory_id, equipped_secondary.blueprint)
		local locked_to_single = managers.weapon_factory:has_perk("fire_mode_single", equipped_secondary.factory_id, equipped_secondary.blueprint)
		local tick1 = weapon_selection_panel:rect({
			color = teammate_text_color,
			name = "tick1",
			w = 2,
			h = 6,
			x = 3,
			layer = 1
		})
		tick1:set_bottom(weapon_selection_panel:h() - 2)
		local tick2 = weapon_selection_panel:rect({
			color = teammate_text_color,
			name = "tick2",
			w = 2,
			h = 6,
			layer = 2
		})
		tick2:set_left(tick1:right())
		tick2:set_bottom(weapon_selection_panel:h() - 2)
		tick2:set_alpha(0.5)
		tick2:move(0.5)
		local tick3 = weapon_selection_panel:rect({
			color = teammate_text_color,
			name = "tick3",
			w = 2,
			h = 6,
			layer = 3
		})
		tick3:set_left(tick2:right())
		tick3:move(0.5)
		tick3:set_bottom(weapon_selection_panel:h() - 2)
		tick3:set_alpha(0.5)
		if locked_to_single or not locked_to_auto and fire_mode == "single" then
		else
			tick2:set_alpha(1)
			tick3:set_alpha(1)
		end
	end
end

function HUDTeammate:set_weapon_firemode(id, firemode)
	local is_secondary = id == 1
	local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
	local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")
	local weapon_selection = is_secondary and secondary_weapon_panel:child("weapon_selection") or primary_weapon_panel:child("weapon_selection")
	if alive(weapon_selection) then
		local tick2 = weapon_selection:child("tick2")
		local tick3 = weapon_selection:child("tick3")
		if alive(tick2) and alive(tick3) then
			if firemode == "single" then
				tick2:set_alpha(0.5)
				tick3:set_alpha(0.5)
			else
				tick2:set_alpha(1)
				tick3:set_alpha(1)
			end
		end
	end
end


function HUDTeammate:update()
	local radial_health_panel = self._player_panel:child("radial_health_panel")
	local grenades = self._player_panel:child("grenades_panel"):child("grenades")
	local cable_ties = self._player_panel:child("cable_ties_panel"):child("cable_ties")
	local deployable = self._player_panel:child("deployable_equipment_panel"):child("equipment")
	local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
	local secondary_weapon_bg = secondary_weapon_panel:child("bg")		
	local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")	
	local primary_weapon_bg = primary_weapon_panel:child("bg")	
	local bg = self._main_player and self._player_panel:child("Mainbg") or self._player_panel:child("EquipmentsBG")
	local name_bg = self._panel:child("name_bg")
	local name = self._panel:child("name")
	local sec_selection = secondary_weapon_panel:child("weapon_selection")
	local prim_selection = primary_weapon_panel:child("weapon_selection")
	local Healthnum_visible = (Holo.options.HealthNum and self._main_player) and true or (Holo.options.HealthNumTM and not self._main_player) and true or false
    self:update_special_equipments()
	grenades:set_color(Equipments_color)
	cable_ties:set_color(Equipments_color)
	deployable:set_color(Equipments_color)
	secondary_weapon_bg:set_color(Selectwep_color)
	primary_weapon_bg:set_color(Selectwep_color)
	Holo:ApplySettings({name_bg, bg},
	{
		color = teammatebg_color,
		alpha = teammatebg_alpha, 
	})
	Holo:ApplySettings({name, sec_selection:child("tick1"),sec_selection:child("tick2"),sec_selection:child("tick3"), prim_selection:child("tick1"), prim_selection:child("tick2"), prim_selection:child("tick3"),secondary_weapon_panel:child("ammo_total"), secondary_weapon_panel:child("ammo_clip"),primary_weapon_panel:child("ammo_total"),
	primary_weapon_panel:child("ammo_clip"),self._player_panel:child("cable_ties_panel"):child("amount"),self._player_panel:child("grenades_panel"):child("amount"),
	self._player_panel:child("deployable_equipment_panel"):child("amount")},{color = teammate_text_color})

	radial_health_panel:child("HealthNum"):set_visible(Healthnum_visible)
end

function HUDTeammate:set_grenades_amount(data)
	if not PlayerBase.USE_GRENADES then
		return
	end
	local teammate_panel = self._panel:child("player")
	local grenades_panel = self._player_panel:child("grenades_panel")
	local amount = grenades_panel:child("amount")
	grenades_panel:child("grenades"):set_visible(data.amount ~= 0)
	self:_set_amount_string(amount, data.amount)
	amount:set_visible(data.amount ~= 0)
	self:layout_equipments()	
end

function HUDTeammate:set_cable_ties_amount(amount)
	local visible = amount ~= 0
	local cable_ties_panel = self._player_panel:child("cable_ties_panel")
	local cable_ties_amount = cable_ties_panel:child("amount")
	cable_ties_amount:set_visible(visible)
	if amount == -1 then
		cable_ties_amount:set_text("--")
	else
		self:_set_amount_string(cable_ties_amount, amount)
	end
	local cable_ties = cable_ties_panel:child("cable_ties")
	cable_ties:set_visible(visible)
	self:layout_equipments()	
end

function HUDTeammate:set_deployable_equipment_amount(index, data)
	local teammate_panel = self._panel:child("player")
	local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
	local amount = deployable_equipment_panel:child("amount")
	deployable_equipment_panel:child("equipment"):set_visible(data.amount ~= 0)
	self:_set_amount_string(amount, data.amount)
	amount:set_visible(data.amount ~= 0)
	self:layout_equipments()
end

function HUDTeammate:layout_equipments()
	local radial_health_panel = self._player_panel:child("radial_health_panel")
	local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
	local cable_ties_panel = self._player_panel:child("cable_ties_panel")
	local grenades_panel = self._player_panel:child("grenades_panel")
	local EquipmentsBG = self._player_panel:child("EquipmentsBG")
	local name = self._panel:child("name")
	local name_bg = self._panel:child("name_bg")
	local teammate_line = self._panel:child("teammate_line")
	local vis = 0
	local deployable_visible = deployable_equipment_panel:child("amount"):visible()
	local cable_ties_visible = cable_ties_panel:child("amount"):visible()
	if self._main_player then

	else
		if deployable_visible then
			deployable_equipment_panel:set_left(EquipmentsBG:left())
			if cable_ties_visible then
		 		cable_ties_panel:set_left(deployable_equipment_panel:right())
		  		grenades_panel:set_left(cable_ties_panel:right())	
		  	else
		  		grenades_panel:set_left(deployable_equipment_panel:right())
		  	end
		else
			if cable_ties_visible then
		 		cable_ties_panel:set_left(EquipmentsBG:left())
		  		grenades_panel:set_left(cable_ties_panel:right())	
		  	else
		  		grenades_panel:set_left(EquipmentsBG:left())
		  	end
	  	end
	end
end

function HUDTeammate:set_state(state)
	local is_player = state == "player"
	self._panel:child("player"):set_alpha(is_player and 1 or 0)
	local name = self._panel:child("name")
	local radial_health_panel = self._player_panel:child("radial_health_panel")
	local name_bg = self._panel:child("name_bg")
	local teammate_line = self._panel:child("teammate_line")
	local EquipmentsBG = self._player_panel:child("EquipmentsBG")
	if not self._main_player then
		if is_player then
			name_bg:set_left(radial_health_panel:right())
			name:set_left(name_bg:left())
			name_bg:set_bottom(EquipmentsBG:top())
			name:set_bottom(EquipmentsBG:top())
			teammate_line:set_h(name_bg:h() + EquipmentsBG:h())
			teammate_line:set_right(EquipmentsBG:left())
	  		teammate_line:set_bottom(EquipmentsBG:bottom())
		else
			name:set_x(48 + name:h() + 4)
			name:set_bottom(self._panel:h())		
			name_bg:set_position(name:x(), name:y() - 1)
		
			teammate_line:set_h(name_bg:h())
			teammate_line:set_right(name_bg:left())
			teammate_line:set_bottom(name_bg:bottom())
		end

	end
end

function HUDTeammate:_set_weapon_selected(id, hud_icon)
	local is_secondary = id == 1
	local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
	local secondary_weapon_bg = secondary_weapon_panel:child("bg")		
	local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")	
	local primary_weapon_bg = primary_weapon_panel:child("bg")	
	primary_weapon_bg:set_color(is_secondary and teammatebg_color or Selectwep_color)
	secondary_weapon_bg:set_color(is_secondary and Selectwep_color or teammatebg_color)
	primary_weapon_bg:set_alpha(is_secondary and 0 or 1)
	secondary_weapon_bg:set_alpha(is_secondary and 1 or 0)
end

function HUDTeammate:set_name(teammate_name)
	local teammate_panel = self._panel
	local name = teammate_panel:child("name")
	local name_bg = teammate_panel:child("name_bg")
	local callsign = teammate_panel:child("callsign")
	name:set_text(" " .. string.upper(teammate_name))
	local h = name:h()
	managers.hud:make_fine_text(name)
	name:set_h(h)
	name_bg:set_w(name:w() + 4)
end

function HUDTeammate:_set_amount_string(text, amount)
	if not PlayerBase.USE_GRENADES then
		text:set_text(tostring(amount))
		return
	end
	local zero = self._main_player and amount < 10 and "0" or ""
	text:set_text(zero .. amount)
	self:layout_equipments()
end

function HUDTeammate:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max)
	local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")	
	weapon_panel:show()
	if Holo.options.totalammo_enable and ((type == "primary" and managers.blackmarket:equipped_primary().weapon_id ~= "saw") or (type == "secondary" and managers.blackmarket:equipped_secondary().weapon_id ~= "saw_secondary") ) then
		current_left = current_left - current_clip
	end
	local ammo_clip = weapon_panel:child("ammo_clip")	
	local ammo_total = weapon_panel:child("ammo_total")
	ammo_clip:set_text(tostring(current_clip))
	ammo_total:set_text(tostring(current_left))
end

function HUDTeammate:set_health(data)
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = teammate_panel:child("radial_health_panel")
	local radial_health = radial_health_panel:child("radial_health")
	local radial_rip = radial_health_panel:child("radial_rip")
	local radial_rip_bg = radial_health_panel:child("radial_rip_bg")
	local HealthNum = radial_health_panel:child("HealthNum")
	local red = data.current / data.total	
	self:_damage_taken()
	radial_health:animate(callback(self, self, "animate_radial"), red)
	HealthNum:set_color(HealthNum_color * (math.round(red * 100) / 100) + HealthNum_negative * (1 - math.round(red * 100) / 100))	
	HealthNum:animate(callback(self, self, "animate_number"), red)
	if alive(radial_rip) then
		radial_rip:set_rotation((1 - radial_health:color().r) * 360)
		radial_rip_bg:set_rotation((1 - radial_health:color().r) * 360)
	end
end

function HUDTeammate:animate_number(text, red)
	local t = 0
	local oldvalue = tonumber(text:text())
	local value = math.floor(red * 100)
	while t < 0.5 do
		t = t + coroutine.yield()
		local n = 1 - math.sin(t * 180)
		local health = math.floor(math.lerp(value, oldvalue, n))
		text:set_text(tostring(math.clamp(health, 0, 100)))
	end
	text:set_text(tostring(math.clamp(value, 0, 100)))
end

function HUDTeammate:animate_radial(radial, red)
	local t = 0
	local old_red = radial:color().r
	while t < 0.5 do
		t = t + coroutine.yield()
		local n = 1 - math.sin(t * 180)
		radial:set_color(Color(math.lerp(red, old_red, n), 0, 0))
	end
 	radial:set_color(Color(red, 0, 0))
end

function HUDTeammate:set_talking(talking)
	local callsign = self._panel:child("callsign")
	callsign:set_alpha(talking and 0.6 or 1)
end

function HUDTeammate:set_downed()
	if self._main_player then
		self._player_panel:child("radial_health_panel"):child("HealthNum"):set_text("0")
		self._player_panel:child("radial_health_panel"):child("HealthNum"):set_color(HealthNum_negative)
	end
end

function HUDTeammate:set_callsign(id)
	print("id", id)
	Application:stack_dump()
	local callsign = self._panel:child("teammate_line")
	callsign:set_color(tweak_data.chat_colors[id])
end

function HUDTeammate:add_special_equipment(data)
	local teammate_panel = self._panel

	local special_equipment = self._special_equipment
	local id = data.id
	local equipment_panel = teammate_panel:panel({
		name = id,
		layer = 0,
		y = 0
	})
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
	equipment_panel:set_size(24, 24)	
	local bitmap = equipment_panel:bitmap({
		name = "bitmap",
		texture = icon,
		color = Pickups_color,
		layer = 1,
		texture_rect = texture_rect,
		w = equipment_panel:w(),
		h = equipment_panel:w()
	})
	local amount, amount_bg
	if data.amount then
		amount = equipment_panel:child("amount") or equipment_panel:text({
			name = "amount",
			text = tostring(data.amount),
			font = "fonts/font_small_noshadow_mf",
			font_size = 12,
			color = Color.black,
			align = "center",
			vertical = "center",
			layer = 4,
			w = equipment_panel:w(),
			h = equipment_panel:h()
		})
		amount:set_visible(1 < data.amount)
		amount_bg = equipment_panel:child("amount_bg") or equipment_panel:bitmap({
			name = "amount_bg",
			texture = "guis/textures/pd2/equip_count",
			color = Color.white,
			layer = 3,
			w = 20,
			h = 20
		})
		amount_bg:set_visible(1 < data.amount)
	end
	local flash_icon = equipment_panel:bitmap({
		name = "bitmap",
		texture = icon,
		color = Color(200/255, 200/255, 200/255),
		layer = 2,
		texture_rect = texture_rect,
		w = equipment_panel:w() + 2,
		h = equipment_panel:w() + 2
	})
	table.insert(special_equipment, equipment_panel)
	local w = teammate_panel:w()
	equipment_panel:set_x(w - (equipment_panel:w() - 3) * #special_equipment)
	if amount then
		amount_bg:set_center(bitmap:center())
		amount_bg:move(7, 7)
		amount:set_center(amount_bg:center())
	end
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	flash_icon:set_center(bitmap:center())
	flash_icon:animate(hud.flash_icon, nil, equipment_panel)
	self:layout_special_equipments()
end
function HUDTeammate:layout_special_equipments()
	local teammate_panel = self._panel
	local special_equipment = self._special_equipment
	local name = teammate_panel:child("name")
	local w = teammate_panel:w()
	for i, panel in ipairs(special_equipment) do
		if self._main_player then
			panel:set_x(w - (panel:w() + 0) * i)
			panel:set_y(20)
		else
			if i == 1 then
				panel:set_x(0)
			else
				panel:set_left(special_equipment[i - 1]:right())
			end
			panel:set_y(10)
		end
	end
end
function HUDTeammate:update_special_equipments()
	local special_equipment = self._special_equipment
	for i, panel in ipairs(special_equipment) do
		panel:child("bitmap"):set_color(Pickups_color)
	end
end
 
function HUDTeammate:teammate_progress(enabled, tweak_data_id, timer, success)
	self._player_panel:child("interact_panel"):stop()
	self._player_panel:child("interact_panel"):set_visible(false)
end


end

if Holo.options.GageHud_support or not Holo.options.hudteammate_enable then
	function HUDTeammate:init(...)
		self.old.init(self, ...)
		if self._player_panel:child("radial_health_panel") then
			local radial_health_panel = self._player_panel:child("radial_health_panel")
			radial_health_panel:child("radial_shield"):set_blend_mode("normal")
			radial_health_panel:child("radial_health"):set_blend_mode("normal")
		end
		if self._health_panel then
			self._health_panel:child("radial_health"):set_blend_mode("normal")
			self._health_panel:child("radial_shield"):set_blend_mode("normal")	
		end
	end
end