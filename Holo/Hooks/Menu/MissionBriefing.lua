if not Holo:ShouldModify("Menu", "Lobby") then
	return
end

Holo:Post(HUDMissionBriefing, "init", function(self)	    
	if not alive(self._job_schedule_panel) then
		return 
	end
	local text_font_size = tweak_data.menu.pd2_small_font_size - (BigLobbyGlobals and 3 or 0)
	local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4

	self._ready_slot_panel:set_h((text_font_size + 16) * num_player_slots + 24)	    
	if not BigLobbyGlobals then
		self._ready_slot_panel:set_right(self._foreground_layer_one:w())
		self._ready_slot_panel:set_bottom(self._foreground_layer_one:h() - 12)
	else
		self._ready_slot_panel:set_x(0)
		self._ready_slot_panel:set_bottom(self._foreground_layer_one:h() - 32)
	end
	if self._ready_slot_panel:child("BoxGui") then
		self._ready_slot_panel:remove(self._ready_slot_panel:child("BoxGui"))
	end
	for i = 1, 7 do
		self._job_schedule_panel:child("day_" .. tostring(i)):hide()
		self._job_schedule_panel:child("ghost_" .. tostring(i)):hide()
	end
	for i = 1, managers.job:current_stage() or 0 do
		self._job_schedule_panel:child("stage_done_" .. tostring(i)):hide()
	end
	if Holo.Options:GetValue("DisableLobbyVideo") and alive(self._background_layer_two:child("panel")) then
		self._background_layer_two:child("panel"):hide()
	end
	local num_stages = self._current_job_chain and #self._current_job_chain or 0
	local ghost = managers.job:is_job_stage_ghostable(managers.job:current_real_job_id(), managers.job:current_stage()) and managers.localization:get_default_macro("BTN_GHOST") or ""
	self._foreground_layer_one:child("job_overview_text"):set_text(managers.localization:to_upper_text("menu_day_short", {day = managers.job:current_stage() .. "/" .. num_stages .. " " .. ghost}))
	self._job_schedule_panel:child("payday_stamp"):hide()
	self._foreground_layer_one:child("pg_text"):set_text(managers.localization:to_upper_text(tweak_data.difficulty_name_ids[Global.game_settings.difficulty]))
	managers.hud:make_fine_text(self._foreground_layer_one:child("pg_text"))		
	self._foreground_layer_one:child("pg_text"):set_right(self._paygrade_panel:right())
	self._paygrade_panel:hide()
	if not self._singleplayer then
		local prev
		for i = 1, num_player_slots do
			local slot = self._ready_slot_panel:child("slot_" .. tostring(i))
			slot:set_h(text_font_size + 16)
			if prev then
				slot:set_y(prev:bottom() + 1)
			else
				slot:set_y(0)
			end
			prev = slot
			slot:rect({
				name = "bg",
				alpha = 0.4,
				color = Color(0, 0, 0),
				layer = -2,
			})
			local avatar = slot:bitmap({
				name = "avatar",
				texture = "guis/textures/pd2/none_icon",
				x = 2,
				w = slot:h() - 4,
				h = slot:h() - 4,
				layer = 1,
			})
			local center_y = slot:h() / 2
			local criminal = slot:child("criminal")
			local name = slot:child("name")
			local status = slot:child("status")
			local detection = slot:child("detection")
			local detection_value = slot:child("detection_value")
			local infamy = slot:child("infamy")
			local voice = slot:child("voice")
			avatar:set_center_y(center_y)
			criminal:set_blend_mode("normal")
			criminal:set_x(avatar:right() + 8)
			criminal:set_center_y(center_y)
			voice:set_center_y(center_y)
			voice:set_x(criminal:right() + 20)
			infamy:set_center_y(center_y - 1)
			infamy:set_x(voice:right() + 2)
			infamy:show()
			name:set_blend_mode("normal")
			name:set_center_y(center_y)
			name:set_x(infamy:right())
			status:set_blend_mode("normal")
			status:set_w(128)
			status:set_center_y(center_y)
			status:set_right(slot:w() - 8)
			detection:set_x(status:left() - 4)
			detection:set_center_y(center_y)
			detection:child("detection_left_bg"):set_blend_mode("normal")				
			detection:child("detection_left"):set_blend_mode("normal")
			detection:child("detection_right_bg"):set_blend_mode("normal")
			detection:child("detection_right"):set_blend_mode("normal")
			detection_value:set_blend_mode("normal")
			detection_value:set_center_y(center_y)
			detection_value:set_x(detection:right() + 4)
		end
		self._ready_slot_panel:rect({
			name = "line",
			color = Holo:GetColor("Colors/Tab"),
			x = prev:x(),
			w = prev:w(),
			h = 2,
			layer = -1,
		}):set_y(prev:bottom())	
	end
end)

Holo:Post(HUDMissionBriefing, "set_player_slot", function(self, nr, params)
	local slot = self._ready_slot_panel:child("slot_" .. tostring(nr))
	if not slot or not alive(slot) then
		return
	end
	local peer = managers.network:session():peer(nr) or nil
	local steam_id = peer and peer:user_id() or nr == 1 and Steam:userid() or nil
	if steam_id then
		--Make sure we have the texture loaded, lets choose large so it's loaded in cache
		local avatar = slot:child("avatar")
		Steam:friend_avatar(Steam.LARGE_AVATAR, steam_id, function(texture) --ovk pls fix, it returns question mark avatar without waiting
			avatar:animate(function()
				wait(1)
				Steam:friend_avatar(Steam.LARGE_AVATAR, steam_id, function(texture)
					avatar:set_image(texture or "guis/textures/pd2/none_icon")
				end)
			end)
		end)
	end
end)

Holo:Post(HUDMissionBriefing, "set_slot_ready", function(self, peer, peer_id)
	local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))
	if alive(slot) then
		slot:child("status"):set_blend_mode("normal")	
	end 
end)