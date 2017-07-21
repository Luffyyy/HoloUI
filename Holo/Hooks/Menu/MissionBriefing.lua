if Holo:ShouldModify("Menu", "Lobby") then	
	Hooks:PostHook(HUDMissionBriefing, "init", "HoloInit", function(self)	    
		if not alive(self._job_schedule_panel) then
			return 
		end
		local text_font_size = tweak_data.menu.pd2_small_font_size
		local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4

		self._ready_slot_panel:set_h(text_font_size * (num_player_slots * 2))	    
		self._ready_slot_panel:set_bottom(self._foreground_layer_one:h())
	    if not BigLobbyGlobals then
	        self._ready_slot_panel:set_right(self._foreground_layer_one:w())
	    else
	        self._ready_slot_panel:set_bottom(self._foreground_layer_one:h() + 90)
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
	    	for i = 1, num_player_slots do
	    		local slot = self._ready_slot_panel:child("slot_" .. tostring(i))
	    		slot:set_h(30)
	    		slot:set_y((i - 1) * 32)
		 		local bg = slot:rect({
					name = "bg",
					alpha = 0.5,
					color = Color(0.1, 0.1, 0.1),
					layer = -2,
				})
				local linebg = slot:rect({
					name = "linebg",
					color = Holo:GetColor("Colors/TabHighlighted"):with_alpha(0.5),
					layer = -2,
					h = 2
				})
				linebg:set_bottom(bg:bottom())
				local line = slot:rect({
					name = "line",
					color = Holo:GetColor("Colors/TabHighlighted"),
					w = 0,
					y = linebg:y(),
					layer = -1,
					h = 2
				})		
				slot:child("criminal"):set_blend_mode("normal")
				slot:child("criminal"):move(4, 4)
				slot:child("name"):set_blend_mode("normal")
				slot:child("name"):move(0, 4)
				slot:child("status"):set_blend_mode("normal")
				slot:child("status"):move(0, 4)
				slot:child("detection"):move(0, 4)
				slot:child("detection"):child("detection_left_bg"):set_blend_mode("normal")				
				slot:child("detection"):child("detection_left"):set_blend_mode("normal")
				slot:child("detection"):child("detection_right_bg"):set_blend_mode("normal")
				slot:child("detection"):child("detection_right"):set_blend_mode("normal")
				slot:child("detection_value"):set_blend_mode("normal")
				slot:child("detection_value"):move(0, 4)
				slot:child("status"):set_right(slot:w() - 4)
	    	end
	    end
	end)
	Hooks:PostHook(HUDMissionBriefing, "set_slot_ready", "HoloSetSlotReady", function(self, peer, peer_id)
		local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))
		if alive(slot) then
			slot:child("status"):set_blend_mode("normal")	
		end 
	end)
 	Hooks:PostHook(HUDMissionBriefing, "set_slot_not_ready", "HoloSetSlotNotReady", function(self, peer, peer_id)
		local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))
		if alive(slot) then
			slot:child("line"):set_w(slot:child("linebg"):w()) 
		end 
 	end)
  	Hooks:PostHook(HUDMissionBriefing, "set_dropin_progress", "HoloSetDropInProgress", function(self, peer_id, progress_percentage, mode)
		local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))
		if alive(slot) then
			slot:child("line"):set_w(slot:child("linebg"):w() * (progress_percentage / 100)) 
		end
  	end)
  	Hooks:PostHook(HUDMissionBriefing, "remove_player_slot_by_peer_id", "HoloRemovePlayerSlotByPeerID", function(self, peer, reason)
		local slot = self._ready_slot_panel:child("slot_" .. tostring(peer_id))
		if alive(slot) then
			slot:child("line"):set_w(0) 
		end  		
  	end)
end