function HUDBGBox_recreate(panel, config)
	local color = config.color
	panel:configure({
		x = config.x,
		y = config.y,
		w = config.w,
		h = config.h,
	})
	panel:child("bg"):configure({
		alpha = config.alpha or Holo.Options:GetValue("HudAlpha"),
		color = color or Color(0, 0, 0),
	})
	HUDBGBox_create_frame(panel, color == Color(1, 1, 0) and color or color == Color(1, 0, 0) and color)
end
function HUDBGBox_create(panel, params, config )
	params = params or {}
	config = config or params
	local box_panel = panel:panel( params )
	local color = config.color
    local bg = box_panel:rect({
		name = "bg",
		halign = "grow",
		valign = "grow",
		alpha = config.alpha or 0.25,
		color = color or Color(0, 0, 0),
		layer = -1
	})
	HUDBGBox_create_frame(box_panel, color == Color(1, 1, 0) and color or color == Color(1, 0, 0) and color)
	return box_panel
end
function HUDBGBox_create_frame(box_panel, color)
	local FrameColor = color or Holo:GetColor("Colors/Frame")
	local FrameStyle = Holo.Options:GetValue("FrameStyle")
	if alive(box_panel:child("left_top")) then
		box_panel:remove(box_panel:child("left_top"))
	end
	if alive(box_panel:child("left_bottom")) then
		box_panel:remove(box_panel:child("left_bottom"))
	end
	if alive(box_panel:child("right_top")) then
		box_panel:remove(box_panel:child("right_top"))
	end
	if alive(box_panel:child("right_bottom")) then
		box_panel:remove(box_panel:child("right_bottom"))
	end

	local left_top = box_panel:bitmap({
		name = "left_top",
		halign = "left",
		valign = "top",
		color = FrameColor,
		visible = FrameStyle ~= 5,
		layer = 10,
	})
	local left_bottom = box_panel:bitmap({
		name = "left_bottom",
		halign = "left",
		valign = "bottom",
		color = FrameColor,
		visible = FrameStyle ~= 5,
		layer = 10,
	})
	local right_top = box_panel:bitmap({
		name = "right_top",
		halign = "right",
		valign = "top",
		color = FrameColor,
		visible = FrameStyle ~= 5,
		layer = 10,
	})
	local right_bottom = box_panel:bitmap({
		name = "right_bottom",
		halign = "right",
		valign = "bottom",
		color = FrameColor,
		visible = FrameStyle ~= 5,
		layer = 10,
	})
	if FrameStyle == 1 then
	    right_bottom:set_image("guis/textures/custom/Frame", 8,8,8,8)
	    left_bottom:set_image("guis/textures/custom/Frame", 0,8,8,8)
	    left_top:set_image("guis/textures/custom/Frame", 0,0,8,8)
	    right_top:set_image("guis/textures/custom/Frame", 8,0,8,8)
		local s = 8
	    right_bottom:set_size(s,s)
	    left_bottom:set_size(s,s)
	    left_top:set_size(s,s)
	    right_top:set_size(s,s)
    elseif FrameStyle == 2 then
	    left_bottom:set_size(box_panel:w() , 1)
	    left_bottom:set_halign("grow")
	    right_bottom:set_alpha(0)
	    right_top:set_alpha(0)
	    left_top:set_alpha(0)
    elseif FrameStyle == 3 then
 	    left_bottom:set_size(1, box_panel:h())
	    right_bottom:set_alpha(0)
	    right_top:set_alpha(0)
	    left_top:set_alpha(0)
	elseif FrameStyle == 4 then
	   	left_top:set_size(box_panel:w(), 1)
	    left_top:set_halign("grow")
	    right_bottom:set_alpha(0)
	    right_top:set_alpha(0)
	    left_bottom:set_alpha(0)
    else
	    left_bottom:set_size(box_panel:w() , 1)
	    right_bottom:set_size(1, box_panel:h())
	    right_top:set_size(box_panel:w(), 1)
	    left_top:set_size(1, box_panel:h())
	    left_bottom:set_halign("grow")
	    right_top:set_halign("grow")
	end
	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())
	right_top:set_right(box_panel:w())
	left_bottom:set_bottom(box_panel:h())
end
if Holo.Options:GetValue("Base/Hud") and Holo.Options:GetValue("TopHud") and Holo.Options:GetValue("Objective") then
	function HUDObjectives:UpdateHolo()
		local objectives_panel = self._hud_panel:child("objectives_panel")
		objectives_panel:child("icon_objectivebox"):set_color(Holo:GetColor("Colors/Objective"))
		HUDBGBox_recreate(self._bg_box, {
			color = Holo:GetColor("Colors/Objective"),
			h = 26,
		})
		objectives_panel:child("objective_text"):configure({
			color = Holo:GetColor("TextColors/Objective"),
			font = "fonts/font_large_mf",
			font_size = self._bg_box:h() - 4,
			y = 1,
		})
	end
	Hooks:PostHook(HUDObjectives, "init", "HoloInit", function(self)
		self:UpdateHolo()
	end)
	function HUDObjectives:activate_objective(data)
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local objective_text = objectives_panel:child("objective_text")
		objectives_panel:child("amount_text"):hide()
		self._active_objective_id = data.id
		self._has_amount = data.amount ~= nil
		objective_text:set_text(string.format("%s %s", utf8.to_upper(data.text), data.amount or ""))
		local _,_,w,_ = objective_text:text_rect()
		self._bg_box:stop()
		self._bg_box:set_w(0)
		objective_text:set_w(0)
		objective_text:show()
		objective_text:set_x(self._bg_box:x() + 4)
		objectives_panel:show()
		objectives_panel:stop()
		objectives_panel:animate(callback(self, self, "_animate_activate_objective"))
		GUIAnim.play(objective_text, "w", w, 2)
		GUIAnim.play(self._bg_box, "w", w + 8, 2)
	end
	Hooks:PostHook(HUDObjectives, "remind_objective", "HoloRemindObjective", function(self)
		self._bg_box:child("bg"):stop()
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local objective_text = objectives_panel:child("objective_text")
		local amount_text = objectives_panel:child("amount_text")
		amount_text:stop()
		objective_text:stop()
		amount_text:animate(callback(nil, GUIAnim, "flash_icon"), 4, nil, true)
		objective_text:animate(callback(nil, GUIAnim, "flash_icon"), 4, nil, true)
	end)
	function HUDObjectives:_animate_icon_objectivebox(icon)
		local h = icon:h()
		icon:set_h(0)
		GUIAnim.play(icon, "h", h)
	end
end
