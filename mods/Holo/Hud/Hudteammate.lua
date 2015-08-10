
if Holo.options.PDTHHud_support == false then
CloneClass(HUDTeammate)
local bg_color = ColorRGB(58, 58, 58):with_alpha(0.5)

Hooks:PostHook(HUDTeammate, "init", "NewInit", function(self)
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = teammate_panel:child("radial_health_panel")
	local radial_shield = radial_health_panel:child("radial_shield")
	local radial_health = radial_health_panel:child("radial_health")	
	local grenades_panel = self._player_panel:child("grenades_panel")
	local cable_ties_panel = self._player_panel:child("cable_ties_panel")
	local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
	local grenades_bg = grenades_panel:child("grenades")
	local HealthNumTM = Holo.options.HealthNumTM
	local HP_style = Holo.options.HealthNum_style
	local name = self._panel:child("name")
	local callsign_bg = self._panel:child("callsign_bg")
	local cable_ties_bg = cable_ties_panel:child("cable_ties")
	local deployable_bg = deployable_equipment_panel:child("equipment")
	radial_health:set_blend_mode("normal")
	radial_shield:set_blend_mode("normal")
	grenades_bg:set_color(Equipments_color)
	cable_ties_bg:set_color(Equipments_color)
	deployable_bg:set_color(Equipments_color)
	local bg_rect = {
		84,
		0,
		44,
		32
	}
	local cs_rect = {
		84,
		34,
		19,
		19
	}
	local csbg_rect = {
		105,
		34,
		19,
		19
	}
    
    local bg_color = ColorRGB(58, 58, 58):with_alpha(0.5)
	local tabs_texture = "guis/textures/pd2/hud_tabs"
	local HealthNum = teammate_panel:text({
		name = "HealthNum",
		visible = HealthNumTM == false and self._main_player and Holo.options.HealthNum or Holo.options.HealthNum,
		text = "100",
		color = HealthNum_color,
		blend_mode = "normal",
		layer = 3,
		w = name:w(),
		h = name:h(),
		vertical = "bottom",
		align = HP_style == 1 and "left" or "center",
		font_size = HP_style == 1 and tweak_data.hud_players.name_size or self._main_player and 22 or 18,
		font = HP_style == 1 and tweak_data.hud_players.name_font or "fonts/font_large_mf"
	})
		local HPCircle = teammate_panel:bitmap({
		name = "HPCircle",
		texture = tabs_texture,
		texture_rect = cs_rect,
		layer = 0,
		visible = Holo.options.HealthNum and (HP_style == 1 and true or false) or false,
		color = HealthNum_color,
		blend_mode = "normal",
	    x = callsign_bg:x(),
	    y = self._main_player and 10 or 15  + HealthNum:y(),
		w = HealthNum:h() - 2,
		h = HealthNum:h() - 2,
	})
		
		local HPCircleBG = teammate_panel:bitmap({
		name = "HPCircleBG",
		texture = tabs_texture,
		texture_rect = csbg_rect,
		layer = -1,
		visible = Holo.options.HealthNum and (HP_style == 1 and true or false) or false,
		color = bg_color,
		blend_mode = "normal",
	    x = callsign_bg:x(),
	    y = self._main_player and 10 or 15 + HealthNum:y(),
		w = HealthNum:h() - 2,
		h = HealthNum:h() - 2,
	})
    if HP_style == 1 then
    HealthNum:set_bottom(name:top() - 2)
	HealthNum:set_right(name:right() + 2)	

    else
   
    HealthNum:set_size(radial_health:w(),radial_health:h())
    HealthNum:set_left(radial_health_panel:left()) 
    center = self._main_player and 4 or 10 
    HealthNum:set_top(radial_health_panel:center() - center)
    end

	local HealthBG = teammate_panel:bitmap({
		name = "HealthBG",
		texture = tabs_texture,
		texture_rect = bg_rect,
		visible = Holo.options.HealthNum and (HP_style == 1 and true or false) or false,
		layer = 0,
		color = callsign_bg:color(),
		x = HealthNum:x() - 2,
		y = HealthNum:y(),
		w = 25,
		h = name:h()
	})

   if Holo.options.Old_radial == true then
      self:set_old()
   end
end)

function HUDTeammate:set_old()
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = teammate_panel:child("radial_health_panel")
	local radial_shield = radial_health_panel:child("radial_shield")
	local radial_health = radial_health_panel:child("radial_health")	
	radial_shield:set_layer(radial_health:layer() + 1)
end
function HUDTeammate:set_new()
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = teammate_panel:child("radial_health_panel")
	local radial_shield = radial_health_panel:child("radial_shield")
	local radial_health = radial_health_panel:child("radial_health")	
	radial_shield:set_layer(radial_health:layer() - 1)
end
function HUDTeammate:_set_weapon_selected(id, hud_icon)
	local is_secondary = id == 1
	local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
	local secondary_weapon_BG = secondary_weapon_panel:child("bg")		
	local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")	
	local primary_weapon_BG = primary_weapon_panel:child("bg")	
	local Selectwep_color = Selectwep_color:with_alpha(0.5)

	if Holo.options.Selectwep_enable == true then
	primary_weapon_BG:set_color(is_secondary and bg_color or Selectwep_color)
	secondary_weapon_BG:set_color(is_secondary and Selectwep_color or bg_color)
	primary_weapon_panel:set_alpha(is_secondary and 1 or 1)
	secondary_weapon_panel:set_alpha(is_secondary and 1 or 1)
	elseif Holo.options.Selectwep_enable == false then
	primary_weapon_panel:set_alpha(is_secondary and 0.5 or 1)
	secondary_weapon_panel:set_alpha(is_secondary and 1 or 0.5)
	end

end
if Holo.options.totalammo_enable == true then
function HUDTeammate:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max)
	local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")
	weapon_panel:set_visible(true)
	local low_ammo = current_left <= math.round(max_clip / 2)
	local low_ammo_clip = current_clip <= math.round(max_clip / 4)
	local out_of_ammo_clip = current_clip <= 0
	local out_of_ammo = current_left <= 0
	local color_total = out_of_ammo and Holo.options.Selectwep_enable == false and Color(1, 0.9, 0.3, 0.3) or Color.white
	color_total = color_total or low_ammo and Holo.options.Selectwep_enable == false and Color(1, 0.9, 0.9, 0.3) or Color.white
	color_total = color_total or Color.white
	local color_clip = out_of_ammo_clip and Holo.options.Selectwep_enable == false and Color(1, 0.9, 0.3, 0.3) or Color.white
	color_clip = color_clip or low_ammo_clip and Holo.options.Selectwep_enable == false and Color(1, 0.9, 0.9, 0.3) or Color.white
	color_clip = color_clip or Color.white
	local ammo_clip = weapon_panel:child("ammo_clip")
	local zero = current_clip < 10 and "00" or current_clip < 100 and "0" or ""
	ammo_clip:set_text(zero .. tostring(current_clip))
	ammo_clip:set_color(color_clip)
	ammo_clip:set_range_color(0, string.len(zero), color_clip:with_alpha(0.5))
	local ammo_total = weapon_panel:child("ammo_total")
	local total_ammo = current_left - current_clip 

	local zero = total_ammo < 10 and "00" or total_ammo < 100 and "0" or ""
	ammo_total:set_text(zero .. tostring(total_ammo))
	ammo_total:set_color(color_total)
	ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
end


end


Hooks:PostHook(HUDTeammate, "set_health", "set_hpvalue", function(self, data)
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = teammate_panel:child("radial_health_panel")
	local HealthNum = teammate_panel:child("HealthNum")
	local HPCircleBG = teammate_panel:child("HPCircleBG")
	local HealthBG = teammate_panel:child("HealthBG")
	local HPCircle = teammate_panel:child("HPCircle")
	local condition_timer = teammate_panel:child("condition_timer")
 
	local red = data.current / data.total
	local Value = math.floor(red * 100)	
       HealthNum:set_color(HealthNum_color * (math.round(red * 100) / 100) + HealthNum_negative * (1 - math.round(red * 100) / 100))
	   HPCircle:set_color(HealthNum_color * (math.round(red * 100) / 100) + HealthNum_negative * (1 - math.round(red * 100) / 100))

	if red ~= 0 then  
		HealthNum:set_text(Value)
	end
   
	if Value < 40 and red ~= 0 then
       HealthNum:animate(callback(self, self, "_animate_hp"))
	end
      
	if Holo.options.HealthNum_style == 1 then

	  if red > 0 then
       HealthBG:set_w(25)
	  end
  else
  	HealthNum:set_text(Value)
    end

end)
function HUDTeammate:set_downed()
  if self._main_player then
     self._panel:child("player"):child("HealthNum"):set_text("Downed")
     self._panel:child("player"):child("HealthNum"):set_color(HealthNum_negative)
     self._panel:child("player"):child("HealthBG"):set_w(52)
  end
end

function HUDTeammate:set_callsign(id)
	local teammate_panel = self._panel
	print("id", id)
	Application:stack_dump()
	local callsign = teammate_panel:child("callsign")
	local name = teammate_panel:child("name")
	local alpha = callsign:color().a
	callsign:set_color(tweak_data.chat_colors[id]:with_alpha(alpha))
	name:set_color(tweak_data.chat_colors[id]:with_alpha(alpha))
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
			panel:set_y(0)
		else
			panel:set_x(120 + panel:w() * (i - 1))
			panel:set_y(8)
		end
	end
end

if Holo.options.HealthNum_style == 1 then
function HUDTeammate:set_condition(icon_data, text)
	local condition_icon = self._panel:child("condition_icon")
	local teammate_panel = self._panel:child("player")
	local HealthNum = teammate_panel:child("HealthNum")
	local HealthBG = teammate_panel:child("HealthBG")
	local HPCircle = teammate_panel:child("HPCircle")
	if icon_data == "mugshot_downed" then
    HealthNum:set_text("Downed")
    HealthBG:set_w(52)
    HealthNum:set_color(HealthNum_negative)
    HPCircle:set_color(HealthNum_negative)
	end
	if icon_data == "mugshot_in_custody" then
     HealthNum:set_text("In custody")
     HealthBG:set_w(65)
     HealthNum:set_color(HealthNum_negative)
     HPCircle:set_color(HealthNum_negative)
	end 
	if icon_data == "mugshot_normal" then

		condition_icon:set_visible(false)
	else
		condition_icon:set_visible(true)
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(icon_data)
		condition_icon:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])
	end
end
end
function HUDTeammate:teammate_progress(enabled, tweak_data_id, timer, success)
	self._player_panel:child("radial_health_panel"):set_alpha(enabled and 0.2 or 1)
	self._player_panel:child("interact_panel"):stop()
	self._player_panel:child("interact_panel"):set_visible(enabled)
	if enabled then
		self._player_panel:child("interact_panel"):animate(callback(HUDManager, HUDManager, "_animate_label_interact"), self._interact, timer)
	elseif success then
		local panel = self._player_panel
		local bitmap = panel:bitmap({
			rotation = 360,
			texture = "guis/textures/pd2/hud_progress_active",
			blend_mode = "alpha",
			align = "center",
			valign = "center",
			layer = 2
		})
		bitmap:set_size(self._interact:size())
		bitmap:set_position(self._player_panel:child("interact_panel"):x() + 4, self._player_panel:child("interact_panel"):y() + 4)
		local radius = self._interact:radius()
		local circle = CircleBitmapGuiObject:new(panel, {
			rotation = 360,
			radius = radius,
			color = Color.white:with_alpha(1),
			blend_mode = "normal",
			layer = 3
		})
		circle:set_position(bitmap:position())
		bitmap:animate(callback(HUDInteraction, HUDInteraction, "_animate_interaction_complete"), circle)
	end
end


function HUDTeammate:_animate_hp()
	local t = 0
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = teammate_panel:child("radial_health_panel")
	local HealthNum = teammate_panel:child("HealthNum")
	local Healthnum_size = Holo.options.HealthNum_style == 1 and tweak_data.hud_players.name_size or self._main_player and 22 or 18

	while t < 0.5 do
		t = t + coroutine.yield()
		local n = 1 - math.sin(t * 180)
		HealthNum:set_font_size(math.lerp(Healthnum_size + 1, Healthnum_size + 3, n))
	end
	HealthNum:set_font_size(Healthnum_size)
end
end