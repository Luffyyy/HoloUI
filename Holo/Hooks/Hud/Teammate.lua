if not Holo:ShouldModify("Hud", "TeammateHud") then
	return
end
local Utils = Holo.Utils
local function resize_value_text(p, font_size)
	local l = p:child("Line")
	local t = p:child("Text")
	local ot = t:text()
	t:set_text("100 ")	
	t:set_font_size(font_size)
	managers.hud:make_fine_text(t)
	t:set_text(ot)
	t:set_color(Holo:GetColor("TextColors/Teammate"))
	l:set_h(t:h() - 2)
	p:set_size(t:w() + l:w() + 2, t:h())
end

local function value_text(panel, name)
	local p = panel:panel({name = name, layer = 5})
	local l = p:rect({
		name = "Line",
		valign = "grow",
		w = 2,
		color = Holo:GetColor("TextColors/"..name)
	})
	local t = p:text({
		name = "Text",
		x = l:right() + 2,
		text = "100 ",
		font_size = 18,
		color = Holo:GetColor("TextColors/Teammate"),
		vertical = "center",
		font = "fonts/font_large_mf"
	})
	return p
end

Holo:Post(HUDTeammate, "init", function(self)
	if not alive(self._player_panel) or not alive(self._player_panel:child("radial_health_panel")) then
		Holo:log("[ERROR] Failed to modify hudteammate")
		return
	end

	self._equipments_h = 0
	
	value_text(self._player_panel, "Health")
	value_text(self._player_panel, "Armor")
	value_text(self._player_panel, "ArmorAbsorb"):set_alpha(0)
	value_text(self._player_panel, "Skill"):set_alpha(0)
	value_text(self._player_panel, "DelayedDamage"):set_alpha(0)

	self._player_panel:rect({
		name = "Mainbg",
		vertical = "bottom",
		layer = 0,
	})

	self._player_panel:bitmap({
		name = "avatar",
		texture = "guis/textures/pd2/none_icon",
		layer = 10
	})
	self._panel:rect({name = "teammate_line", w = 2, layer = 5})
	self:layout_equipments()
	self:layout_special_equipments()
	self:UpdateHolo()
	Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
end)

Holo:Post(HUDTeammate, "set_name", function(self, teammate_name)
	self._panel:child("name"):set_text(Holo.Options:GetValue("UpperCaseNames") and teammate_name:upper() or teammate_name)
	self:UpdateHolo()
end)

function HUDTeammate:set_avatar()
	local peer = self._peer_id and managers.network:session():peer(self._peer_id) or nil
	local steam_id = peer and peer:user_id() or self._main_player and Steam:userid() or nil
	if steam_id and not self._ai then
		Steam:friend_avatar(Steam.LARGE_AVATAR, steam_id, function(texture)
			self._player_panel:child("avatar"):animate(function()
				wait(1)
				Steam:friend_avatar(Steam.LARGE_AVATAR, steam_id, function(texture)
					self:set_player_avatar(texture or "guis/textures/pd2/none_icon")
				end)
			end)
		end)
	else
		self:set_player_avatar(self._ai and "ui/custom/ai_text" or "guis/textures/pd2/none_icon")
	end
end

function HUDTeammate:set_player_avatar(texture, texture_rect)
	local avatar = self._player_panel:child("avatar")
	avatar:set_image(texture, texture_rect)
	avatar:set_color(self._ai and Holo:GetColor("TextColors/Teammate") or Color.white)
end

function HUDTeammate:DebugWithAI()
	self._ai = false
	self:set_deployable_equipment({icon = "equipment_ammo_bag", amount = 2})
	self:set_ammo_amount_by_type("primary", 100, 50, 50, 10)
	self:set_ammo_amount_by_type("secondary", 100, 50, 50, 10)
	self:set_avatar()
end

function HUDTeammate:GetNameWidth()
	local _,_,w,_ = self._panel:child("name"):text_rect()
	return w
end

function HUDTeammate:UpdateHolo()
	--if self._ai then
	--	self:DebugWithAI()
	--end
	self:set_avatar()
	managers.hud:align_teammate_panels()
	
	local weapons_panel = self._player_panel:child("weapons_panel")
	local secondary = weapons_panel:child("secondary_weapon_panel")
	local primary = weapons_panel:child("primary_weapon_panel")
	local bg = self._player_panel:child("Mainbg")
	local name_bg = self._panel:child("name_bg")
	local name = self._panel:child("name")
	local teammate_line = self._panel:child("teammate_line")
	local avatar = self._player_panel:child("avatar")
	local hp = self._player_panel:child("Health")
	local ap = self._player_panel:child("Armor")
	local abp = self._player_panel:child("ArmorAbsorb")
	local sp = self._player_panel:child("Skill")
	local ddp = self._player_panel:child("DelayedDamage")

	local me = self._main_player
	local bg_color = Holo:GetColor("Colors/Teammate")
	local text_color = Holo:GetColor("TextColors/Teammate")
	local avatar_enabled = Holo.Options:GetValue(me and "ShowAvatar" or "ShowTeammatesAvatar")
	local show_all = me or Holo.Options:GetValue("ShowTeammateFullAmmo")
	local compact = self._forced_compact or (self._ai or not self._main_player and Holo.Options:GetValue("CompactTeammate"))
	local font_size = compact and (me and 28 or 24) or (me and 18 or 14)
	
	name:configure({
		font_size = font_size,
		vertical = "center",
		font = "fonts/font_large_mf",
	})
	managers.hud:make_fine_text(name)
	
	bg:set_size(self._panel:w(), self._panel:h() - self._equipments_h)
	bg:set_rightbottom(self._panel:size())
	avatar:set_size(avatar_enabled and bg:h() or 0, bg:h())
	avatar:set_visible(avatar_enabled)
	avatar:set_leftbottom(bg:leftbottom())
	name_bg:set_size(name:w() + 4, name:h())
	name_bg:set_position(avatar:right() + 4, bg:top() + 3)
	
	if compact then
		name_bg:set_center_y(avatar:center_y())
	else
		resize_value_text(hp, font_size)
		resize_value_text(ap, font_size)
		resize_value_text(sp, font_size)
		resize_value_text(ddp, font_size)
		resize_value_text(abp, font_size)

		hp:set_position(name_bg:x(), name_bg:bottom() + 2)
		ap:set_position(name_bg:x(), hp:bottom() + 2)
		ddp:set_position(ap:position())
		local has_duke_perk
		if self._main_player then
			has_duke_perk = managers.skilltree:get_specialization_value("current_specialization") == 19
		else
			local peer = self._peer_id and managers.network:session():peer(self._peer_id)
			has_duke_perk = peer and managers.skilltree:unpack_from_string(peer:skills()).specializations[1] == "19" or false
		end
		ddp:set_alpha(self._main_player and has_duke_perk and 1 or 0)		
		ap:set_alpha(has_duke_perk and 0 or 1)
		sp:set_position(name_bg:right() + 2, hp:y())
		abp:set_position(name_bg:right() + 2, ap:y())
	end

	name:set_position(name_bg:x() + 3, name_bg:y())
	teammate_line:set_size(2, name:h() - 2)
	teammate_line:set_x(name_bg:x())
	teammate_line:set_center_y(name:center_y() - 1)
			
	--Weapons
	local ww = show_all and 54 or 48
	if show_all then
		weapons_panel:set_size(ww, 48)
	else
		weapons_panel:set_size(ww, 64)
	end
	weapons_panel:set_righttop(bg:right() - 8, hp:y())
	
	for i, panel in pairs({primary, secondary}) do
		panel:child("bg"):hide()
		panel:show()
		local selection = panel:child("weapon_selection")			
		local ammo_total = panel:child("ammo_total")			
		local ammo_clip = panel:child("ammo_clip")
		ammo_total:set_font_size(font_size)
		ammo_clip:set_font_size(font_size)
		ammo_clip:set_visible(show_all)
		selection:set_visible(show_all)
		selection:child("weapon_selection"):hide()
		ammo_clip:set_align("center")
		ammo_total:set_align("right")
		local _,_,w,h = ammo_clip:text_rect()
		panel:set_shape(0, 0, weapons_panel:w(), h)
		if show_all then
			ammo_total:set_size((ww / 2) - 2, panel:h())
			ammo_clip:set_size(ammo_total:size())
			selection:set_size(6, panel:h())

			ammo_total:set_righttop(panel:w(), 0)
			ammo_clip:set_righttop(ammo_total:lefttop())
			selection:set_righttop(ammo_clip:lefttop())

			 if i == 2 then
				panel:set_y(primary:bottom() + 2)
			end 
		else
			panel:set_size(weapons_panel:size())
			local sec = i==2
			 ammo_total:set_shape(0, -6, panel:size())
			ammo_total:set_align(sec and "right" or "left")
		end
		ammo_total:set_color(text_color)
		ammo_clip:set_color(text_color)
	end
	--Weapons end

	--Equipments	
	local dep = self._player_panel:child("deployable_equipment_panel")
	local cable = self._player_panel:child("cable_ties_panel")
	local nades = self._player_panel:child("grenades_panel")

	dep:set_shape(0, 0, (weapons_panel:right() - teammate_line:x()) / 3, font_size)		
	cable:set_shape(dep:shape())
	nades:set_shape(dep:shape())

	for _, v in pairs({dep, cable, nades}) do
		v:child("amount"):configure({
			font = "fonts/font_large_mf",
			font_size = font_size,
			color = text_color,
			vertical = "center",
			align = "right",
			x = 0, y = 0, w = dep:w() - 2, h = dep:h()
		})
	end
	local eq_size = dep:h() - 4
	
	--just call them icon we already know what these bitmaps are thanks to the panel.
	local nades_icon = nades:child("grenades_icon")
	for _, v in pairs({nades_icon, cable:child("cable_ties"), dep:child("equipment")}) do
		v:configure({
			w = eq_size,
			h = eq_size,
			x = 0,
			y = 2,
			color = text_color
		})
	end
	nades:child("grenades_radial"):set_shape(nades_icon:shape())
	nades:child("grenades_icon_ghost"):set_shape(nades_icon:shape())
	--create_waiting_panel

	local condition_icon = self._panel:child("condition_icon")
	local condition_timer = self._panel:child("condition_timer")
	local condition_font_size = 14
	condition_icon:set_size(condition_font_size, condition_font_size)
	condition_timer:set_font_size(condition_font_size)
	condition_timer:set_shape(condition_icon:shape())
	
	if compact then
		condition_icon:set_rightbottom(self._panel:w() - 2, self._panel:h() - 2)
		condition_timer:set_rightbottom(condition_icon:leftbottom())		
	else
		condition_icon:set_position(teammate_line:right() + 2, hp:y() + 1)
		condition_timer:set_leftbottom(condition_icon:rightbottom())		
	end

	--Equipments end
	
	--hide stuff that we don't need
	Holo.Utils:Apply({hp, ap, abp, sp, ddp, dep, cable, nades, weapons_panel}, {visible = not compact})
	Holo.Utils:Apply({name_bg, bg}, {color = bg_color, alpha = Holo.Options:GetValue("HudAlpha")})
	Utils:Apply({
		self._player_panel:child("carry_panel"), self._panel:child("name_bg"), primary:child("bg"), secondary:child("bg"),
		self._panel:child("callsign_bg"), self._panel:child("callsign"), cable:child("bg"), dep:child("bg"), nades:child("bg"),
	}, {visible = false, alpha = 0})
	name:set_color(text_color)
	self._player_panel:child("radial_health_panel"):hide()
	self._player_panel:child("interact_panel"):set_alpha(0)

	self:layout_equipments()
	self:recreate_weapon_firemode()
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
	local p = self._player_panel
	local avatar = p:child("avatar")
	local prev
	for _, equip in pairs({p:child("deployable_equipment_panel"), p:child("grenades_panel"), p:child("cable_ties_panel")}) do
		equip:set_leftbottom(avatar:right() + 6, avatar:bottom() - 2)
		if prev then
			equip:set_position(prev:righttop())
		end
		prev = equip
	end
	return prev
end

function HUDTeammate:_set_weapon_selected(id, hud_icon)
	local is_secondary = id == 1
	local wep_panel = self._player_panel:child("weapons_panel")
	
	play_value(wep_panel:child("secondary_weapon_panel"), "alpha", is_secondary and 1 or 0.65)
	play_value(wep_panel:child("primary_weapon_panel"), "alpha", is_secondary and 0.65 or 1)
end

function HUDTeammate:_set_amount_string(text, amount)
	text:set_text(amount)
	self:layout_equipments()
end

Holo:Post(HUDTeammate, "_set_amount_string", function(self, text)
	text:set_color(Color.white)
end)

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

function HUDTeammate:set_holo_health(data)
	local Health = self._player_panel:child("Health")
	local val = data.current / data.total
	play_color(Health:child("Line"), Holo:GetColor("Colors/Health") * val + Holo:GetColor("Colors/HealthNeg") * (1 - val))		
	Health:child("Text"):set_text(string.format("%i", data.current * tweak_data.gui.stats_present_multiplier))
end

Holo:Post(HUDTeammate, "set_stored_health_max", function(self, hp_ratio)
	if not self._main_player then
		return
	end
	self._player_panel:child("Skill"):set_alpha((math.min(hp_ratio, 1) > 0) and 1 or 0)
end)

Holo:Post(HUDTeammate, "set_ability_radial", function(self, data)
	local skill = self._player_panel:child("Skill")
	local p = data.current / data.total
	play_value(skill, "alpha", p > 0 and 1 or 0)
	skill:child("Text"):set_text(string.format("%i%%", p * 100))
	play_color(skill:child("Line"), Holo:GetColor("Colors/Skill") * p + Holo:GetColor("TextColors/Teammate") * (1 - p))	
end)

Holo:Post(HUDTeammate, "activate_ability_radial", function(self, time_left, time_total)
	local p = time_left / time_total
	local skill = self._player_panel:child("Skill")
	local skill_color = Holo:GetColor("Colors/Skill")
	local text_color = Holo:GetColor("TextColors/Teammate")
	skill:stop()
	skill:animate(function(o)
		o:set_alpha(1)
		local line = o:child("Line")
		local text = o:child("Text")
		over(time_left, function(t)
			local val = (p * math.lerp(1, 0, t))
			text:set_text(string.format("%i%%", tostring(val * 100)))
			line:set_color(skill_color * val + text_color * (1 - val))
		end)
		o:set_alpha(0)
	end)
end)

Holo:Post(HUDTeammate, "set_stored_health", function(self, hp_ratio)
	if not self._main_player or not managers.player:player_unit() or not managers.player:player_unit():character_damage() then
		return
	end
	local Skill = self._player_panel:child("Skill")
	local val = math.min(hp_ratio, 1)
	local curr = val * managers.player:player_unit():character_damage():_max_health()
	play_color(Skill:child("Line"), Holo:GetColor("Colors/Skill") * val + Holo:GetColor("TextColors/Teammate") * (1 - val))
	Skill:child("Text"):set_text(string.format("%i", tostring(curr * tweak_data.gui.stats_present_multiplier)))
end)

Holo:Post(HUDTeammate, "set_info_meter", function(self, data)
	if not self._main_player then
		return
	end
	local Skill = self._player_panel:child("Skill")
	local val = math.clamp(data.current / data.max, 0, 1)
	play_color(Skill:child("Line"), Holo:GetColor("Colors/Skill") * val + Holo:GetColor("TextColors/Teammate") * (1 - val))
	Skill:child("Text"):set_text(string.format("%i", data.current * tweak_data.gui.stats_present_multiplier))
end)

Holo:Post(HUDTeammate, "set_armor", function(self, data)
	local Armor = self._player_panel:child("Armor")
	Armor:set_alpha(data.total ~= 0 and 1 or 0)
	local val = data.current / data.total
	play_color(Armor:child("Line"), Holo:GetColor("Colors/Armor") * val + Holo:GetColor("Colors/ArmorNeg") * (1 - val))
	Armor:child("Text"):set_text(string.format("%i", data.current * tweak_data.gui.stats_present_multiplier))
end)

Holo:Post(HUDTeammate, "start_timer", function(self, data)
	self._panel:child("condition_timer"):set_font_size(self._panel:child("condition_icon"):h() - 2)
	self._player_panel:child("Health"):child("Text"):hide()
end)

Holo:Post(HUDTeammate, "set_condition", function(self, icon_data)
	local icon = self._panel:child("condition_icon")
	self._player_panel:child("Health"):child("Text"):set_visible(not icon:visible())
end)

--I'm really not sure about this, the perks code is really confusing me at some cases
Holo:Post(HUDTeammate, "update_delayed_damage", function(self)
	if not self._main_player then
		return
	end
	local damage = self._delayed_damage or 0
	local DelayedDamage = self._player_panel:child("DelayedDamage")
	local armor_current = self._armor_data.current	
	local health_max = self._health_data.total
	local health_current = self._health_data.current
	local health_ratio = self._player_panel:child("radial_health_panel"):child("radial_health"):color().r
	local armor_damage = damage < armor_current and damage or armor_current
	damage = damage - armor_damage
	local health_damage = damage < health_current and damage or health_current
	local val = health_damage / health_max
	play_color(DelayedDamage:child("Line"), Holo:GetColor("Colors/SkillNeg") * val + Holo:GetColor("Colors/Skill") * (1 - val))
	DelayedDamage:child("Text"):set_text(string.format("%i", health_damage * tweak_data.gui.stats_present_multiplier))
end)

function HUDTeammate:set_talking(talking)
	self._panel:child("teammate_line"):set_alpha(talking and 0.6 or 1)
end

function HUDTeammate:set_downed()
	if self._main_player then
		local Health = self._player_panel:child("Health")
		local Armor = self._player_panel:child("Armor")
		Health:child("Text"):set_text("0")
		play_color(Health:child("Line"), Holo:GetColor("Colors/HealthNeg"))
		play_color(Armor:child("Line"), Holo:GetColor("Colors/ArmorNeg"))
	end
end

function HUDTeammate:_animate_timer_flash()
	local t = 0
	local condition_timer = self._panel:child("condition_timer")
	local condition_icon = self._panel:child("condition_icon")
	local font_size = condition_icon:h() - 2
	while t < 0.5 do
		t = t + coroutine.yield()
		local n = 1 - math.sin(t * 180)
		local r = math.lerp(1 or self._point_of_no_return_color.r, 1, n)
		local g = math.lerp(0 or self._point_of_no_return_color.g, 0.8, n)
		local b = math.lerp(0 or self._point_of_no_return_color.b, 0.2, n)

		condition_timer:set_color(Color(r, g, b))
		condition_timer:set_font_size(math.lerp(font_size, font_size + 4, n))
	end

	condition_timer:set_font_size(font_size)
end

function HUDTeammate:Height()
	if self._main_player then
		return 92
	end
	local compact = (self._ai and Holo.Options:GetValue("CompactAI")) or Holo.Options:GetValue("CompactTeammate")
	return compact and 36 or 70
end

Holo:Pre(HUDTeammate, "add_special_equipment", function(self, data)
	data.amount = data.amount or 1
end)

function HUDTeammate:layout_special_equipments(no_align_hud)
	self._equipments_h = 0	
	local w = self._panel:w()
	local name = self._panel:child("name")
	local teammate_line = self._panel:child("teammate_line")
	local bg = self._player_panel:child("Mainbg")
	local text_color = Color.white
	local bg_color = Holo:GetColor("Colors/Teammate")
	local bg_alpha = Holo.Options:GetValue("HudAlpha")
	local padding = 2
	local rows = 1	
	local prev
	local h = 18
	
	for i, panel in pairs(self._special_equipment) do
		panel:set_size(30, 16)
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
				x = -padding,
				y = 0,			
				w = panel:w(),
				rotation = 0,
				h = panel:h(),
				visible = true,
				color = text_color
			})
			amount_bg:configure({
				texture = "units/white_df",
				w = panel:w(),
				h = panel:h(),
				rotation = 0,
				color = bg_color,
				alpha = bg_alpha,
				x = 0,
				y = 0,
				visible = true
			})
		end
		if alive(bitmap) then
			local s = panel:h() - 2
			bitmap:configure({
				color = text_color,
				visible = true,
				rotation = 0,
				x = padding,
				layer = 10,
				y = 1,
				w = s,
				h = s,
			})
		end

		panel:set_position(0, 0)
		if prev then
			if (prev:right() + panel:w()) > (bg:w() - 2) then
				panel:set_y(prev:bottom() + 2)
				h = h + (panel:h() + 2)
			else
				panel:set_position(prev:right() + 2, prev:y())
			end
		end
		prev = panel
		self._equipments_h = h
	end
	self:UpdateHolo()
end

--Do it from menu instead, kthx
Holo:Post(HUDTeammate, "set_waiting", function(self, waiting, peer)
	self._wait_panel:hide()
	self._panel:show()
	self:UpdateHolo()
end)

--Don't like this method, but anyway with the rework any radial would not work without fix
--From what I understand maniac's health absorb is more rare than the armor so I won't display it(tbh have no where to display it lol)
function HUDTeammate:_animate_update_absorb(o, radial_absorb_shield_name, radial_absorb_health_name, var_name, blink)
	if not self._main_player then
		return
	end

	repeat
		coroutine.yield()
	until alive(self._player_panel) and alive(self._player_panel:child("ArmorAbsorb")) and self[var_name] and self._armor_data and self._health_data

	local pp = self._player_panel
	local armor = pp:child("ArmorAbsorb")
	local rhp = pp:child("radial_health_panel")
	local radial_shield = rhp:child("radial_shield")
	local radial_health = rhp:child("radial_health")
	local radial_shield_rot = radial_shield:color().r
	local radial_health_rot = radial_health:color().r

	local current_absorb = 0
	local current_shield, current_health = nil
	local step_speed = 1
	local lerp_speed = 1
	local dt, update_absorb = nil
	local t = 0
	while alive(pp) do
		dt = coroutine.yield()

		if self[var_name] and self._armor_data and self._health_data then
			update_absorb = false
			current_shield = self._armor_data.current
			current_health = self._health_data.current
			if radial_shield:color().r ~= radial_shield_rot or radial_health:color().r ~= radial_health_rot then
				radial_shield_rot = radial_shield:color().r
				radial_health_rot = radial_health:color().r
				update_absorb = true
			end

			if current_absorb ~= self[var_name] then
				current_absorb = math.lerp(current_absorb, self[var_name], lerp_speed * dt)
				current_absorb = math.step(current_absorb, self[var_name], step_speed * dt)
				update_absorb = true
			end

			if update_absorb and current_absorb > 0 then
				local shield_ratio = current_shield == 0 and 0 or math.min(current_absorb / current_shield, 1)
				local shield = math.clamp(shield_ratio * radial_shield_rot, 0, 1)
				local text = string.format("%i", shield * 100)
				armor:child("Text"):set_text(text.."%")
				play_value(armor, "alpha", tonumber(text) > 0 and 1 or 0)
			end
		end
	end
end

Holo:Post(HUDTeammate, "set_grenades_amount", HUDTeammate.layout_equipments)
Holo:Post(HUDTeammate, "set_cable_ties_amount", HUDTeammate.layout_equipments)
Holo:Post(HUDTeammate, "set_deployable_equipment_amount", HUDTeammate.layout_equipments)
Holo:Post(HUDTeammate, "set_ai", HUDTeammate.UpdateHolo)
Holo:Post(HUDTeammate, "set_peer_id", HUDTeammate.UpdateHolo)
Holo:Post(HUDTeammate, "add_panel", HUDTeammate.UpdateHolo)
Holo:Post(HUDTeammate, "set_health", HUDTeammate.set_holo_health)
Holo:Post(HUDTeammate, "set_custom_radial", HUDTeammate.set_holo_health)
Holo:Post(HUDTeammate, "remove_panel", function(self)
	if not self._main_player then --testing this, hopefully it won't break anything, but it should reset once the panel is removed.
		self._peer_id = nil
		self._player_panel:child("Armor"):set_alpha(0)
		self:UpdateHolo()
	end
end)
Holo:Post(HUDTeammate, "set_callsign", function(self, id)
	self._panel:child("teammate_line"):set_color(tweak_data.chat_colors[id])
	self:UpdateHolo()
end)

function HUDTeammate:_create_primary_weapon_firemode() self:_create_firemode() end
function HUDTeammate:_create_secondary_weapon_firemode() self:_create_firemode(true) end
function HUDTeammate:set_state(state) self:UpdateHolo() end