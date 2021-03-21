if not Holo:ShouldModify("HUD", "Interaction") then
	return
end

HUDInteraction.SHOW_CIRCLE = false --thanks

Holo:Post(HUDInteraction, "init", function(self)
	self._progress = self._hud_panel:rect({
		name = "line",
		alpha = 0,
		w = 0,
		h = 6,
	})
	self._progress_bg = self._hud_panel:rect({
		name = "line_bg",
		alpha = 0,
		w = 256,
		h = 6,
	})
	self:set_current_color(Holo:GetColor("TextColors/Interaction"))
end)

Holo:Post(HUDInteraction, "show_interaction_bar", function(self)
	local interact_text = self._hud_panel:child(self._child_name_text)
	local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)
	self._interact_circle:set_visible(false)	
	self._progress:stop()
	self._progress:set_w(0)
	self._progress:set_alpha(1)
	play_value(self._progress_bg, "alpha", 0.25)

	self:set_current_color(Holo:GetColor("Colors/Interaction"))
end)

Holo:Replace(HUDInteraction, "hide_interaction_bar", function(self, o, complete, ...)
	play_value(self._progress_bg, "alpha", 0)
	local function hide_func()
		play_value(self._progress, "alpha", 0, {callback = function()
			self:set_current_color(Holo:GetColor("TextColors/Interaction"))
			self._progress:set_w(0)
		end})
	end
	if complete then
		play_anim(self._progress, {set = {w = 0, center_x = {value = self._progress:center_x(), sticky = true}}, callback = hide_func})
	else
		hide_func()
	end
	if self._interact_circle then
		self._interact_circle:remove()
		self._interact_circle = nil
	end
	return o(self, false, ...)
end)

Holo:Post(HUDInteraction, "set_interaction_bar_width", function(self, current, total)
	local interact_text = self._hud_panel:child(self._child_name_text)
	local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)
	local _,_,w,h = interact_text:text_rect()
	self._progress:set_w(self._progress_bg:w() * (current / total))	
	self._progress_bg:set_center_x(self._hud_panel:w() / 2, self._hud_panel:h() / 2)
	self._progress_bg:set_y(interact_text:y() + h)
	self._progress:set_position(self._progress_bg:position())
end)

Holo:Post(HUDInteraction, "set_bar_valid", function(self, valid)
	self:set_current_color(valid and Holo:GetColor("Colors/Interaction") or Holo:GetColor("Colors/InteractionRed"))
end)

Holo:Replace(HUDInteraction, "show_interact", function(self, o, ...)
	local text = self._hud_panel:child(self._child_name_text)
	local visible = text:visible()
	if not visible then	
		text:set_alpha(0)
	end
	o(self, ...)
	play_value(text, "alpha", 1)
end)

Holo:Replace(HUDInteraction, "remove_interact", function(self, o, ...)
	local text = self._hud_panel:child(self._child_name_text)
	local visible = text:visible()
	o(self, ...)
	if visible then
		text:set_visible(true)
		play_value(text, "alpha", 0)
	end
end)

Holo:Post(HUDInteraction, "destroy", function(self)
	self._hud_panel:remove(self._progress)
	self._hud_panel:remove(self._progress_bg)
end)

function HUDInteraction:set_current_color(color)
	self._progress:set_color(color)
	self._progress_bg:set_color(color)
	self._hud_panel:child(self._child_name_text):set_color(color)
	self._hud_panel:child(self._child_ivalid_name_text):set_color(color)
end