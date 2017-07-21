function HUDBGBox_recreate(panel, config)
	if not alive(panel) then
		log(debug.traceback())
	end
	panel:configure({
		x = config.x,
		y = config.y,
		w = config.w,
		h = config.h,
	})
	if config.name then
		config.alpha = Holo.Options:GetValue("HudAlpha") or 0.25
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
function HUDBGBox_create_frame(box_panel, color, style)
	color = color or Holo:GetColor("Colors/Frame")
	style = style or Holo.Options:GetValue("FrameStyle")
	local width = 1
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
	local opt = {
		halign = "left",
		valign = "top",
		rotation = 360,
		color = color,
		visible = style ~= none,
		layer = 10,		
	}
	opt.name = "left_top"
	local left_top = box_panel:bitmap(opt)
	opt.name = "left_bottom"
	opt.valign = "bottom"
	local left_bottom = box_panel:bitmap(opt)
	opt.name = "right_top"
	opt.halign = "right"
	local right_top = box_panel:bitmap(opt)
	opt.name = "right_bottom"
	opt.valign = "bottom"
	local right_bottom = box_panel:bitmap(opt)
	if style == 1 then
	    right_bottom:set_image("guis/textures/custom/Frame", 8,8,8,8)
	    left_bottom:set_image("guis/textures/custom/Frame", 0,8,8,8)
	    left_top:set_image("guis/textures/custom/Frame", 0,0,8,8)
	    right_top:set_image("guis/textures/custom/Frame", 8,0,8,8)
		local s = 8
	    right_bottom:set_size(s,s)
	    left_bottom:set_size(s,s)
	    left_top:set_size(s,s)
	    right_top:set_size(s,s)    
	elseif style ~= none then
		local vis = style == 6
	    left_bottom:set_size(box_panel:w(), width)
	    right_bottom:set_size(width, box_panel:h())
	    right_top:set_size(box_panel:w(), width)
	    left_top:set_size(width, box_panel:h())
	    left_bottom:set_halign("grow")
	    right_top:set_halign("grow")		
	    left_bottom:set_visible(vis or style == 2)
	    left_top:set_visible(vis or style == 3)
	    right_bottom:set_visible(vis or style == 4)
	    right_top:set_visible(vis or style == 5)
	end
	right_bottom:set_rightbottom(box_panel:size())
	right_top:set_right(box_panel:w())
	left_bottom:set_bottom(box_panel:h())		
end
if Holo.Options:GetValue("HudBox") and Holo:ShouldModify("Hud", "Objective") then
	function HUDObjectives:UpdateHolo()
		self.ObjPanel = self._panel or self._hud_panel:child("objectives_panel")
		self.ObjText = self.ObjPanel:child("objective_text") or self._bg_box:child("objective_text")
		self.AmountText = self.ObjPanel:child("amount_text") or self._bg_box:child("amount_text")
		if self.ObjPanel:child("icon_objectivebox") then
			self.ObjPanel:child("icon_objectivebox"):hide()
		end
		local box_height = 28
		HUDBGBox_recreate(self._bg_box, {
			name = "Objective",
			x = 0,
			h = box_height,
		})
		self.ObjText:configure({
			color = Holo:GetColor("TextColors/Objective"),
			font_size = box_height - 6,
			vertical = "center",
			h = box_height,
			font = "fonts/font_large_mf"
		})
		self:PosObjectives()
	end

	Hooks:PostHook(HUDObjectives, "init", "HoloInit", function(self)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)

	function HUDObjectives:PosObjectives()
		Holo.Utils:SetPosition(self.ObjPanel, "Objective", WolfHUD and (WolfHUD:getSetting({"TabStats", "CLOCK_MODE"}, 3) == 4) and 80 or 0)
	end

	function HUDObjectives:activate_objective(data)
		self.AmountText:hide()
		self.AmountText:set_alpha(0)
		self._active_objective_id = data.id
		self._has_amount = data.amount ~= nil
		local amount = self._has_amount and (data.current_amount or 0) .. "/" .. data.amount
		self.ObjText:set_text(string.format("%s %s", utf8.to_upper(data.text), amount or ""))
		local _,_,w,_ = self.ObjText:text_rect()
		self._bg_box:stop()
		if not data.no_reset or not self.ObjPanel:visible() then
			self._bg_box:set_w(0)
			self.ObjText:set_w(0)
			self.ObjText:show()
			self.ObjPanel:show()
			self.ObjPanel:stop()
			self.ObjPanel:animate(callback(self, self, "_animate_activate_objective"))
		end
		self.ObjText:set_y(0)
		self.ObjText:set_x(4)
		self.ObjPanel:set_w(w + 8)
		QuickAnim:Work(self.ObjText, "w", w, "speed", 3)
		QuickAnim:Work(self._bg_box, "w", w + 8, "speed", 3)
		self:PosObjectives()
	end

	Hooks:PostHook(HUDObjectives, "remind_objective", "HoloRemindObjective", function(self)
		self._bg_box:child("bg"):stop()
		self.AmountText:stop()
		self.ObjText:stop()
		self.AmountText:animate(callback(nil, Holo, "flash_icon"), 4, nil, true)
		self.ObjText:animate(callback(nil, Holo, "flash_icon"), 4, nil, true)
	end)

	Hooks:PostHook(HUDObjectives, "update_amount_objective", "HoloUpdateAmountObjective", function(self, data)
		data.no_reset = true
		self:activate_objective(data)
	end)
end