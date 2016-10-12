function HUDBGBox_recreate(panel, config)
	panel:configure({
		x = config.x,
		y = config.y,
		w = config.w,
		h = config.h,
	})
	if config.name then
		config.alpha = Holo:GetAlpha(config.name) or 0.25
		config.frame_style = Holo:GetFrameStyle(config.name)
		config.frame_color = Holo:GetFrameColor(config.name)
		config.color = Holo:GetColor("Colors/" .. config.name)
	end
	local color = config.color	
	panel:child("bg"):configure({
		alpha = config.alpha or Holo.Options:GetValue("HudAlpha"),
		color = color or Color(0, 0, 0),
	})
	HUDBGBox_create_frame(panel, config.frame_color, config.frame_style)
end
function HUDBGBox_create(panel, params, config)
	params = params or {}
	config = config or params
	local box_panel = panel:panel(params)
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
function HUDBGBox_create_frame(box_panel, color, frame_style)
	local FrameColor = color or Holo:GetColor("Colors/Frame")
	local FrameStyle = frame_style or Holo.Options:GetValue("FrameStyle")
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
	local none = Holo.FrameStyles
	local left_top = box_panel:bitmap({
		name = "left_top",
		halign = "left",
		valign = "top",
		rotation = 360,
		color = FrameColor,
		visible = FrameStyle ~= none,
		layer = 10,
	})
	local left_bottom = box_panel:bitmap({
		name = "left_bottom",
		halign = "left",
		valign = "bottom",
		rotation = 360,
		color = FrameColor,
		visible = FrameStyle ~= none,
		layer = 10,
	})
	local right_top = box_panel:bitmap({
		name = "right_top",
		halign = "right",
		valign = "top",
		rotation = 360,
		color = FrameColor,
		visible = FrameStyle ~= none,
		layer = 10,
	})
	local right_bottom = box_panel:bitmap({
		name = "right_bottom",
		halign = "right",
		valign = "bottom",
		rotation = 360,
		color = FrameColor,
		visible = FrameStyle ~= none,
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
	elseif FrameStyle ~= none then
		local vis = FrameStyle == 6
	    left_bottom:set_size(box_panel:w() , 1)
	    right_bottom:set_size(1, box_panel:h())
	    right_top:set_size(box_panel:w(), 1)
	    left_top:set_size(1, box_panel:h())
	    left_bottom:set_halign("grow")
	    right_top:set_halign("grow")		
	    left_bottom:set_visible(vis or FrameStyle == 2)
	    left_top:set_visible(vis or FrameStyle == 3)
	    right_bottom:set_visible(vis or FrameStyle == 4)
	    right_top:set_visible(vis or FrameStyle == 5)
	end
	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())
	right_top:set_right(box_panel:w())
	left_bottom:set_bottom(box_panel:h())
end
if Holo.Options:GetValue("HudBox") and Holo:ShouldModify("Hud", "Objective") then
	function HUDObjectives:UpdateHolo()
		local objectives_panel = self._hud_panel:child("objectives_panel")
		objectives_panel:child("icon_objectivebox"):hide()
		HUDBGBox_recreate(self._bg_box, {
			x = 0,
			name = "Objective",
			h = 28,
		})
		objectives_panel:child("objective_text"):configure({
			color = Holo:GetColor("TextColors/Objective"),
			font = "fonts/font_medium_noshadow_mf",
			font_size = self._bg_box:h() - 6,
		})
	end
	Hooks:PostHook(HUDObjectives, "init", "HoloInit", function(self)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)
	function HUDObjectives:activate_objective(data)
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local objective_text = objectives_panel:child("objective_text")
		objectives_panel:child("amount_text"):hide()
		self._active_objective_id = data.id
		self._has_amount = data.amount ~= nil
		local amount = self._has_amount and (data.current_amount or 0) .. "/" .. data.amount
		objective_text:set_text(string.format("%s %s", utf8.to_upper(data.text), amount or ""))
		local _,_,w,_ = objective_text:text_rect()
		self._bg_box:stop()
		if not data.no_reset then
			self._bg_box:set_w(0)
			objective_text:set_w(0)
			objective_text:show()
			objectives_panel:show()
			objectives_panel:stop()
			objectives_panel:animate(callback(self, self, "_animate_activate_objective"))
		end
		objective_text:set_position(4,2)
		Swoosh:work(objective_text, "w", w, "speed", 3)
		Swoosh:work(self._bg_box, "w", w + 8, "speed", 3)
	end
	Hooks:PostHook(HUDObjectives, "remind_objective", "HoloRemindObjective", function(self)
		self._bg_box:child("bg"):stop()
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local objective_text = objectives_panel:child("objective_text")
		local amount_text = objectives_panel:child("amount_text")
		amount_text:stop()
		objective_text:stop()
		amount_text:animate(callback(nil, Swoosh, "flash_icon"), 4, nil, true)
		objective_text:animate(callback(nil, Swoosh, "flash_icon"), 4, nil, true)
	end)
	Hooks:PostHook(HUDObjectives, "update_amount_objective", "HoloUpdateAmountObjective", function(self, data)
		data.no_reset = true
		self:activate_objective(data)
	end)
	function HUDObjectives:_animate_icon_objectivebox(icon)
		local x,y = icon:center()
		icon:set_h(0)
		Swoosh:work(icon,
			"w", 24,
			"h", 24,
			"speed", 5,
			"after", function()
				icon:set_center(x,y)
			end
		)
	end
end
