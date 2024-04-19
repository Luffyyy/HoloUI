if not Holo:ShouldModify("HUD", "Teammate") or Holo.Options:GetValue("AltTeammate") then
	return
end
Holo:Post(HUDTeammate, "init", function(self)
	if not alive(self._player_panel) or not alive(self._player_panel:child("radial_health_panel")) then
		Holo:log("[ERROR] Something went wrong when trying to modify HUDTeammate")
		return
	end
	local radial_health_panel = self._player_panel:child("radial_health_panel")
	local weapons_panel = self._player_panel:child("weapons_panel")
	local dep = self._player_panel:child("deployable_equipment_panel")
	local cable = self._player_panel:child("cable_ties_panel")
	local nades = self._player_panel:child("grenades_panel")
	local primary = weapons_panel:child("primary_weapon_panel")
	local secondary= weapons_panel:child("secondary_weapon_panel")
	self._player_panel:child("carry_panel"):set_alpha(0)
	self._panel:child("name"):set_font_size(24)
	Holo.Utils:Apply({
		self._panel:child("name_bg"),
		self._panel:child("callsign_bg"),
		self._panel:child("callsign"),
		cable:child("bg"),
		dep:child("bg"),
		nades:child("bg"),
		primary:child("bg"), 
		secondary:child("bg"),
		primary:child("weapon_selection"):child("weapon_selection"),
		secondary:child("weapon_selection"):child("weapon_selection")
	},{visible = false})
	HUDBGBox_create(self._player_panel, {name = "Mainbg"})
	HUDBGBox_create(self._panel, {name = "Namebg"})
	self:UpdateHolo()
	Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
end)

function HUDTeammate:DebugWithAI()
	if not self._ai then
		return
	end

	self:set_health({current = 1, total = 1})
	self:set_armor({current = 1, total = 1})

	self._ai = false
	self._player_panel:set_alpha(1)
	self:set_deployable_equipment({icon = "equipment_ammo_bag", amount = 2})
	self:set_ammo_amount_by_type("primary", 100, 999, 999, 10)
	self:set_ammo_amount_by_type("secondary", 100, 999, 999, 10)
end

function HUDTeammate:UpdateHolo()
	--self:DebugWithAI()
	local radial_health_panel = self._player_panel:child("radial_health_panel")
	local deployable_panel = self._player_panel:child("deployable_equipment_panel")
	local cableties_panel = self._player_panel:child("cable_ties_panel")
	local grenades_panel = self._player_panel:child("grenades_panel")
	local grenades = grenades_panel:child("grenades_icon")
	local cable_ties = cableties_panel:child("cable_ties")
	local deployable = deployable_panel:child("equipment")
	local weapons_panel = self._player_panel:child("weapons_panel")
	local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")
	local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
	local bg = self._player_panel:child("Mainbg")
	local nbg = self._panel:child("Namebg")
	local name_bg = self._panel:child("name_bg")
	local callsign = self._panel:child("callsign")
	local name = self._panel:child("name")
	local me = self._main_player
	local bg_color = Holo:GetColor("Colors/Teammate")
	local text_color = Holo:GetColor("TextColors/Teammate")

	local minime = me and Holo.Options:GetValue("CompactPlayer")
	local minitm = minime or not me and Holo.Options:GetValue("CompactTeammates")
	local mightbeme = me or Holo.Options:GetValue("ShowTeammatesFullAmmo")

	local weap_w = minime and 68 or 80
	local weap_h = minitm and 48 or 64
	local radial_size = minitm and 48 or 64

	if not me then
		if minitm then
			if mightbeme then
				weap_w = 56
			else
				weap_w = 26
			end
		elseif mightbeme then
			weap_w = 68
		else
			weap_w = 36
		end
	end

	HUDBGBox_recreate(bg, {
		name = "Teammate",
		x = radial_size + 8,
		w = weap_w + (minitm and 50 or 54),
		h = self._ai and 0 or (weap_h + (minitm and 12 or 8))
	})
	name:configure({
		color = Holo.Options:GetValue("NameColored") and callsign:color() or text_color,
		font_size = minitm and 16 or 20,
		visible = Holo.Options:GetValue("MyName") or not self._main_player,
		font = "fonts/font_large_mf",
	})
	local _,_,w,_ = name:text_rect()
	local pw = bg:right()-8
	name:set_font_size(math.clamp(name:font_size() * pw / w, 8, name:font_size()))

	managers.hud:make_fine_text(name)

	HUDBGBox_recreate(nbg, {
		name = "TeammateName",
		visible = name:visible(),
		frame_color = callsign:color(),
		x = radial_health_panel:x(),
		y = bg:bottom() - 2,
		w = name:w() + 8,
		h = name:visible() and name:h() + 8 or 0
	})
	bg:set_bottom(self:calc_panel_height())
	if self._ai then
		nbg:set_bottom(self:calc_panel_height())
	else
		nbg:set_bottom(bg:y() - 4)
	end
	name:set_position(nbg:x() + 4, nbg:y() + 5)

	self:set_radials()

	--Weapons

	weapons_panel:set_size(weap_w, weap_h)
	weapons_panel:set_x(bg:x() + 7)
	weapons_panel:set_center_y(bg:center_y())

	for i, panel in pairs({primary_weapon_panel, secondary_weapon_panel}) do
		local ammo_total = panel:child("ammo_total")
		local ammo_clip = panel:child("ammo_clip")
		local weapon_selection = panel:child("weapon_selection")
		panel:show()
		panel:set_shape(0,0, weapons_panel:w(), weapons_panel:h()/2)
		ammo_clip:set_font_size(minitm and 24 or 28)
		ammo_total:set_font_size(minitm and 24 or 28)
		ammo_clip:set_visible(mightbeme)
		if mightbeme then
			ammo_clip:set_shape(0, 0, weapons_panel:h()/2, panel:h())
			ammo_total:set_shape(ammo_clip:right()+4, 0, 32, panel:h())
			weapon_selection:set_shape(panel:w() - weapon_selection:w(), 0, 12, panel:h())
		else
			ammo_total:set_shape(0,1, panel:size())
		end
		if i == 2 then
			panel:set_y(primary_weapon_panel:bottom())
		end
		ammo_total:set_color(text_color)
		ammo_clip:set_color(text_color)
	end
	--Weapons end

	--Equipments
	deployable_panel:set_shape(weapons_panel:right() + 2, weapons_panel:y() - (minitm and 2 or -1), minitm and 32 or 36, minitm and 16 or 20)
	local eq_size = deployable_panel:h() - 4
	
	deployable:set_color(text_color)
	for _, v in pairs({deployable_panel, cableties_panel, grenades_panel}) do
		v:child("amount"):configure({
			font = "fonts/font_large_mf",
			font_size = minitm and 16 or 18,
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

    self._condition_icon:set_size(28, 28)
    if (self._ai) then
        self._condition_icon:set_position(name:right() + 6)
        self._condition_icon:set_center_y(name:center_y() - 1)
    else
        self._condition_icon:set_center(radial_health_panel:center())
    end
    local condition_timer = self._panel:child("condition_timer")
    condition_timer:set_shape(self._condition_icon:shape())
    condition_timer:set_font_size(24)
    condition_timer:move(0, 2)

    local revive_panel = self._player_panel:child("revive_panel")
    revive_panel:set_right(self._player_panel:right())
    revive_panel:set_y(name:y() - 4)
    revive_panel:child("revive_bg"):set_alpha(0)
	--Equipments end
	cableties_panel:set_top(deployable_panel:bottom())
	grenades_panel:set_top(cableties_panel:bottom())

	self:update_special_equipments()
	self:layout_special_equipments()
	self:recreate_weapon_firemode()
	managers.hud:align_teammate_panels()
end

function HUDTeammate:calc_panel_height()
	return self._player_panel:child("Mainbg"):h()+self._panel:child("Namebg"):h()+(self._ai and 22 or 30)
end

function HUDTeammate:set_radials()
	local minime = self._main_player and Holo.Options:GetValue("CompactPlayer")
	local minitm = minime or not self._main_player and Holo.Options:GetValue("CompactTeammates")
	local panel = self._player_panel:child("radial_health_panel")
	local radial_size = minitm and 48 or 64
	local bg = self._player_panel:child("Mainbg")
	local nbg = self._panel:child("Namebg")
	panel:set_size(radial_size,radial_size)
	panel:set_x(0)
	panel:set_center_y(bg:center_y()+2)
	for _, child in pairs(panel:children()) do
		if child:name() ~= "arrow" then
			child:set_size(panel:size())
		end
	end
	
	local full_size = {
		"radial_bg",
		"radial_health",
		"radial_shield",
		"damage_indicator",
		"radial_custom",
		"radial_ability",
		"radial_delayed_damage",
		"radial_rip",
		"radial_rip_bg",
		"radial_absorb_shield_active",
		"radial_absorb_health_active",
		"radial_info_meter",
		"radial_info_meter_bg"
	}

	for _, name in pairs(full_size) do
		local o = panel:child(name)
		if alive(o) then
			o:set_size(panel:size())
		end
	end

	local radial_ability = panel:child("radial_ability")
	local ability_meter = radial_ability:child("ability_meter")
	local ability_icon = radial_ability:child("ability_icon")
	ability_meter:set_size(panel:size())
	ability_icon:set_size(radial_size*0.5, radial_size*0.5)
	ability_icon:set_center(radial_ability:center())

	local delayed_damage = panel:child("radial_delayed_damage")
	delayed_damage:child("radial_delayed_damage_armor"):set_size(panel:size())
	delayed_damage:child("radial_delayed_damage_health"):set_size(panel:size())

	local interact_panel = self._player_panel:child("interact_panel")
	interact_panel:set_size(radial_size * 1.25, radial_size * 1.25)
	interact_panel:set_center(panel:center())

	self._interact._radius = interact_panel:h() / 2 - 4
	local s = self._interact._radius*2
	self._interact._circle:set_shape(4, 4, s, s)
	self._interact._bg_circle:set_shape(4, 4, s,s)

	if self._stamina_bar and self._stamina_line then
		self._stamina_bar:set_size(panel:w() * 0.37, panel:h() * 0.37)
		self._stamina_bar:set_world_center(panel:world_center())
		self._stamina_line:set_size(panel:w() * 0.05, 2)
		self._stamina_line:set_world_center(panel:world_center())
	end

	if self._standalone_stamina_circle then
		self._standalone_stamina_circle:set_size(panel:w()*0.8, panel:h()*0.8)
		self._standalone_stamina_circle:set_world_center(panel:world_center())
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

function HUDTeammate:set_state(state)
	if alive(self._player_panel) then self._player_panel:set_alpha(state == "player" and 1 or 0) end
	self:UpdateHolo()
end

function HUDTeammate:_set_weapon_selected(id, hud_icon)
	local is_secondary = id == 1
	local wep_panel = self._player_panel:child("weapons_panel")
	play_value(wep_panel:child("primary_weapon_panel"), "alpha", is_secondary and 0.75 or 1)
	play_value(wep_panel:child("secondary_weapon_panel"), "alpha", is_secondary and 1 or 0.75)
end

Holo:Post(HUDTeammate, "set_name", function(self, teammate_name)
	self._panel:child("callsign"):hide()
	self._panel:child("callsign_bg"):hide()
	self._panel:child("name"):set_text(Holo.Options:GetValue("UpperCaseNames") and teammate_name:upper() or teammate_name)
	self:UpdateHolo()
end)

function HUDTeammate:_set_amount_string(text, amount)
	local zero = self._main_player and amount < 10 and "0" or ""
	text:set_text(zero .. amount)
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

function HUDTeammate:set_talking(talking)
	local callsign = self._panel:child("callsign")
	callsign:set_alpha(talking and 0.6 or 1)
end

function HUDTeammate:layout_special_equipments(no_align_hud)
	self._equipments_h = 0	
	local w = self._panel:w()
	local name = self._panel:child("name")
	local bg = self._player_panel:child("Mainbg")
	local nbg = self._panel:child("Namebg")
	local text_color = Color.white
	local bg_color = Holo:GetColor("Colors/Teammate")
	local bg_alpha = Holo.Options:GetValue("HUDAlpha")
	local rows = 1	
	local prev
	local minime = self._main_player and Holo.Options:GetValue("CompactPlayer")
	local minitm = minime or not self._main_player and Holo.Options:GetValue("CompactTeammates")
	local base_h = minitm and 16 or 20
	local h = base_h
	for i, panel in pairs(self._special_equipment) do
		panel:set_size(minitm and 26 or 31, base_h)
		local amount = panel:child("amount")
		local amount_bg = panel:child("amount_bg")
		local bitmap = panel:child("bitmap")
		if not bitmap:script().fixed then
			local main = panel:child("bitmap")
			main:set_name("bitmap_temp")
			local flash = panel:child("bitmap")
			if alive(flash) then
				flash:set_name("bitmap_flash")
				flash:hide()
			end
			main:set_name("bitmap")
			main:script().fixed = true
		end
		
		if alive(amount) then
			amount:configure({
				font_size = panel:h(),
				font = "fonts/font_small_mf",
				vertical = "center",
				align = "right",
				x = 0,
				y = 0,
				w = panel:w(),
				rotation = 0,
				h = panel:h(),
				visible = true,
				color = text_color
			})
			amount_bg:set_w(0)
			amount_bg:set_alpha(0)
		end
		if alive(bitmap) then
			local s = panel:h() - 2
			bitmap:configure({
				color = text_color,
				visible = true,
				rotation = 0,
				layer = 10,
				y = 1,
				w = s,
				h = s,
			})
		end

		panel:set_rightbottom(bg:right(), nbg:y() - 4)
		if prev then
			if (prev:x() - panel:w()) < 0 then
				panel:set_bottom(prev:y() - 2)
				h = h + (panel:h() + 2)
			else
				panel:set_righttop(prev:x() - 1, prev:y())
			end
		end
		prev = panel
		self._equipments_h = h
	end
end

function HUDTeammate:update_special_equipments()
	local special_equipment = self._special_equipment
	for i, panel in ipairs(special_equipment) do
		panel:child("bitmap"):set_color(Holo:GetColor("Colors/Pickups"))
	end
end

Holo:Post(HUDTeammate, "set_callsign", function(self) self:UpdateHolo() end)
Holo:Post(HUDTeammate, "add_special_equipment", function(self) self:UpdateHolo() end)
Holo:Post(HUDTeammate, "remove_special_equipment", function(self) self:UpdateHolo() end)

function HUDTeammate:_create_primary_weapon_firemode() self:_create_firemode() end
function HUDTeammate:_create_secondary_weapon_firemode() self:_create_firemode(true) end

--Do it from menu instead, kthx
Holo:Post(HUDTeammate, "set_waiting", function(self, waiting, peer)
	self._wait_panel:hide()
	self._panel:show()
	self:UpdateHolo()
end)