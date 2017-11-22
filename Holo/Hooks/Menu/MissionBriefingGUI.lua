if not Holo:ShouldModify("Menu", "Lobby") then
	return
end
Holo:Post(MissionBriefingTabItem, "init", function(self)
	self._tab_select_rect:set_alpha(0)
	self._main_panel:set_y(89)
	Holo.Utils:TabInit(self)	
end)

function MissionBriefingTabItem:is_tab_selected() return self._selected end
Holo:Post(MissionBriefingTabItem, "select", ClassClbk(Holo.Utils, "TabUpdate"))
Holo:Post(MissionBriefingTabItem, "deselect", ClassClbk(Holo.Utils, "TabUpdate"))
Holo:Post(MissionBriefingTabItem, "mouse_moved", ClassClbk(Holo.Utils, "TabUpdate"))
Holo:Post(MissionBriefingTabItem, "update_tab_position", ClassClbk(Holo.Utils, "TabUpdate"))
Holo:Post(TeamLoadoutItem, "set_slot_outfit", function(self, slot, criminal_name, outfit)
	local player_slot = self._player_slots[slot]
	if not player_slot then
		return
	end

	if player_slot.box then
		player_slot.box:hide()
	end
end)

Holo:Post(MissionBriefingGui, "init", function(self)
	self._ready_button:set_blend_mode("normal")
	self._ready_button:set_font_size(tweak_data.menu.pd2_medium_font_size)
	managers.hud:make_fine_text(self._ready_button)
	self._ready_button:set_rightbottom(self._panel:w() - 8, self._panel:h() + 105)
	self._multi_profile_item:panel():set_leftbottom(8, self._panel:h() + 110)
	self._ready_tick_box:hide()
	self._fullscreen_panel:child("ready_big_text"):hide()
	Holo.Utils:RemoveBoxes(self._panel)
end)

function MissionBriefingGui:flash_ready() end
