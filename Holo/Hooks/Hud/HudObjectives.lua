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
	local scale = Holo.Options:GetValue("HudScale")
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
		rotation = -90,
		visible = FrameStyle ~= 5,
		layer = 10,
	})
	local right_top = box_panel:bitmap({
		name = "right_top",
		halign = "right",
		valign = "top",
		color = FrameColor,
		rotation = 90,
		visible = FrameStyle ~= 5,
		layer = 10,
	})
	local right_bottom = box_panel:bitmap({
		name = "right_bottom",
		halign = "right",
		valign = "bottom",
		color = FrameColor,
		rotation = 180,
		visible = FrameStyle ~= 5,
		layer = 10,
	})
	if FrameStyle == 1 then
	    right_bottom:set_image("guis/textures/pd2/hud_corner")
	    left_bottom:set_image("guis/textures/pd2/hud_corner")
	    left_top:set_image("guis/textures/pd2/hud_corner")
	    right_top:set_image("guis/textures/pd2/hud_corner")
		local s = 8 * scale
	    right_bottom:set_size(s,s)
	    left_bottom:set_size(s,s)
	    left_top:set_size(s,s)
	    right_top:set_size(s,s)
    elseif FrameStyle == 2 then
	    left_bottom:set_size(box_panel:w() , 1 * scale)
	    left_bottom:set_halign("grow")
	    right_bottom:set_alpha(0)
	    left_bottom:set_rotation(0)
	    right_top:set_alpha(0)
	    left_top:set_alpha(0)
    elseif FrameStyle == 3 then
 	    left_bottom:set_size(1 * scale, box_panel:h())
	    right_bottom:set_alpha(0)
	    left_bottom:set_rotation(0)
	    right_top:set_alpha(0)
	    left_top:set_alpha(0)
	elseif FrameStyle == 4 then
	   	left_top:set_size(box_panel:w(), 1 * scale)
	    left_top:set_halign("grow")
	    right_bottom:set_alpha(0)
	    left_top:set_rotation(0)
	    right_top:set_alpha(0)
	    left_bottom:set_alpha(0)
    else
	    left_bottom:set_size(box_panel:w() , 1 * scale)
	    right_bottom:set_size(1 * scale, box_panel:h())
	    right_top:set_size(box_panel:w(), 1 * scale)
	    left_top:set_size(1 * scale, box_panel:h())
	    left_bottom:set_halign("grow")
	    right_top:set_halign("grow")
	    right_bottom:set_rotation(0)
	    left_bottom:set_rotation(0)
	    right_top:set_rotation(0)
	    left_top:set_rotation(0)
	end
	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())
	right_top:set_right(box_panel:w())
	left_bottom:set_bottom(box_panel:h())
end
if Holo.Options:GetValue("Base/Hud") and Holo.Options:GetValue("TopHud") and Holo.Options:GetValue("Objective") then
	function HUDObjectives:UpdateHoloHUD()
		local scale = Holo.Options:GetValue("HudScale")
		local objectives_panel = self._hud_panel:child("objectives_panel")
		objectives_panel:set_size(500 * scale, 100 * scale)
		objectives_panel:child("icon_objectivebox"):configure({
			color = Holo:GetColor("Colors/Objective"),
			alpha = Holo.Options:GetValue("HudAlpha"),
			w = 24 * scale,
			h = 24 * scale,
		})
		objectives_panel:child("objective_text"):configure({
			visible = true,
			color = Holo:GetColor("TextColors/Objective"),
			font = "fonts/font_large_mf",
			font_size = 22 * scale,
			x = 34 * scale,
			y = 4 * scale,
		})
		local _,_,w,_ = objectives_panel:child("objective_text"):text_rect()
		objectives_panel:child("amount_text"):configure({
			color = Holo:GetColor("TextColors/Objective"),
			font = "fonts/font_large_mf",
			font_size = 22 * scale,
			x = objectives_panel:child("objective_text"):x() + (5 * scale) + w,
			y = 4 * scale,
		})
		local amount_size = 26 * scale
		local _,_,amount_w, _ = objectives_panel:child("amount_text"):text_rect()
		if self._has_amount then
			amount_size = amount_size + amount_w
		end
		HUDBGBox_recreate(self._bg_box, {
			w = w + amount_size,
			h = 30 * scale,
			x = 26 * scale,
			color = Holo:GetColor("Colors/Objective"),
		})
	end
	Hooks:PostHook(HUDObjectives, "init", "HoloInit", function(self)
		self:UpdateHoloHUD()
	end)
	function HUDObjectives:activate_objective(data)
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local objective_text = objectives_panel:child("objective_text")
		local amount_text = objectives_panel:child("amount_text")
		local scale = Holo.Options:GetValue("HudScale")
		self._active_objective_id = data.id
		self._has_amount = data.amount ~= nil
		objective_text:set_text(utf8.to_upper(data.text))
		local _,_,obj_w,_ = objective_text:text_rect()
		objectives_panel:set_visible(true)
	    amount_size = 26 * scale
		amount_text:set_visible(false)
		if data.amount then
			self:update_amount_objective(data)
			local _,_,amount_w,_ = amount_text:text_rect()
			amount_size = amount_size + amount_w
		end
		self._bg_box:stop()
		self._bg_box:set_w(0)
		objective_text:hide()
		amount_text:hide()
		GUIAnim.play(self._bg_box, "w", obj_w + amount_size, 2)
		objective_text:show()
		amount_text:show()
		self._bg_box:set_w( obj_w + amount_size)
		amount_text:set_x(objective_text:x() + (5 * scale) + obj_w)
		objectives_panel:stop()
		objectives_panel:animate(callback(self, self, "_animate_activate_objective"))
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
