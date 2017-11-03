Holo.Utils = Holo.Utils or {}
local Utils = Holo.Utils
function Utils:ModifyWallet()
 	local panel = Global.wallet_panel
 	if not panel then
 		return
 	end
	local w
	local items = {"money", "level", "skillpoint", "coins"}
	local prev
	for i, v in pairs(items) do
		local child = "wallet_" .. v
		local icon = panel:child(child .. "_icon")
		local text = panel:child(child .. "_text")
		if icon and icon:visible() then
			icon:set_leftbottom(prev and prev:right() + 10 or 4, Global.wallet_panel:h() - 4)				
			WalletGuiObject.make_fine_text(text)
			text:set_left(icon:right() + 2)
			text:set_y(math.round(icon:y() - 2))
			icon:set_color(Holo:GetColor("TextColors/Menu"))	
			text:set_color(Holo:GetColor("TextColors/Menu"))		
			w = text:right() + 2
			prev = text
		end
	end
	if panel:child("line") then
		panel:remove(panel:child("line"))
	end
	local line = panel:rect({
		name = "line",
		color = Holo:GetColor("Colors/Marker"),
		h = prev and prev:h() or 0,
		w = 2,
	})
	if prev then
		line:set_center_y(prev:center_y())
	end
end

function Utils:FixBackButton(this, back_button)
	if not back_button then
		if type(this._back_button) == "table" then
			back_button = this._back_button._text
		else
			back_button = this._panel:child("back_button")
		end
	end
	
	local really_ugly_button = this._fullscreen_panel and this._fullscreen_panel:child("back_button")
	if alive(really_ugly_button) then
		really_ugly_button:hide()
		really_ugly_button:set_w(0)
	end

	if not managers.menu:is_pc_controller() or not alive(back_button) then
		return
	end
	
	this._fixed_back_button = back_button
	back_button:configure({
		color = Holo:GetColor("TextColors/Menu"),
		font_size = 24,
		blend_mode = "normal"
	})
	back_button:set_shape(back_button:text_rect())	
	this._back_marker = back_button:parent():rect({
		color = Holo:GetColor("Colors/Marker"),
		w = 2,
		h = back_button:h(),
		rotation = 360,
		alpha = 0,
		layer = back_button:layer() - 1
	})
	this._back_marker:set_world_rightbottom(back_button:parent():world_rightbottom())
	back_button:set_rightbottom(this._back_marker:leftbottom())
	Holo:Post(this, "mouse_moved", function(this, o, x, y)
		local highlight = this._fixed_back_button:inside(x, y)
		this._back_button_highlighted = highlight
		this.back_button_highlighted = highlight
		this._fixed_back_button:stop()
		play_color(this._fixed_back_button, Holo:GetColor(highlight and "TextColors/MenuHighlighted" or "TextColors/Menu"))
		play_value(this._back_marker, "alpha", highlight and 1 or 0)
	end)
end

function Utils:FixDialog(dialog, info_area, button_list, focus_button, only_buttons)
	local has_buttons = button_list and #button_list > 0		
	local buttons_panel = info_area:child("buttons_panel")
	dialog._panel:child("title"):set_color(Holo:GetColor("TextColors/Menu"))
	info_area:child("info_bg"):set_color(Holo:GetColor("Colors/Menu"))
	if has_buttons then
		buttons_panel:child("selected"):configure({
			blend_mode = "normal",
			w = 2,
			h = 20,
			alpha = 1,
			color = Holo:GetColor("Colors/Marker"),
		})	
		if button_list then
			for _, child in pairs(buttons_panel:children()) do	
				if CoreClass.type_name(child) == "Panel" then
					child:child("button_text"):configure({
						blend_mode = "normal",
						color = Holo:GetColor("TextColors/Menu")
					})		
				end
			end
		end
		dialog:_set_button_selected(focus_button, true)	
	end
end

function Utils:SetBlendMode(o, ...)
    local ignore = {...}
    local toignore 
    if o.type_name == "Panel" then
        for _, child in pairs(o:children()) do
            self:SetBlendMode(child, ...)
        end
    else
        for _, v in ipairs(ignore) do
            if o:name():match(v) or o:parent():name():match(v) then
                toignore = true
            end
        end
        if not toignore or o.type_name == "Text" then
            o:set_blend_mode("normal")
        end
    end
end

function Utils:Apply(tbl, config)
	if tbl then
		for _, o in pairs(tbl) do
			o:configure(config)
		end
	end
end

function Utils:SetPosition(p, setting, offset)
	offset = offset or 0
	local position = Holo.Options:GetValue("Positions/"..setting)
	if position then
		local pos = Holo.Positions[position]
		local pp = p:parent()
		if pos:match("Center") then p:set_world_center(pp:world_center()) end
		if pos:match("Top") then p:set_world_y(pp:world_y()) end
		if pos:match("Bottom") then p:set_world_bottom(pp:world_bottom()) end
		if pos:match("Left") then p:set_world_left(pp:world_left() + offset) end
		if pos:match("Right") then p:set_world_right(pp:world_right() + offset) end
		for _, clbk in pairs(Holo.set_position_clbks) do
			clbk(setting, pos)
		end
	else
		Holo:log("[ERROR] No position setting for %s", setting)
	end
end

function Utils:RemoveBoxes(panel)
	for _, child in pairs(panel:children()) do 
		if child.child and child:child("BoxGui") then
			child:child("BoxGui"):hide()
		end
	end
end

function Utils:SetTexture(o, texture)
	local w,h = o:texture_width(), o:texture_height()
	o:set_image(texture, w, 0, -w, h)
end

function Utils:TabInit(this, text, panel)
	panel = panel or this._main_panel
	this._tab_text = this._tab_text or text
	this._line_select = panel:child("line_select") or panel:rect({
		name = "line_select",
		w = 0,
		h = 2,
		layer = 3,
		color = Holo:GetColor("Colors/Tab"),
	})
	this._line_select:set_world_y(this._tab_text:world_bottom() - 2)
	this.is_tab_selected = this.is_tab_selected or function(this)
		return this._active
	end
	Holo:AddUpdateFunc(ClassClbk(self, "TabUpdate", this))
end

function Utils:TabUpdate(this)
	if not alive(this._tab_text) then
		return
	end
	this._tab_text:set_color(Holo:GetColor("TextColors/Tab"))
	this._tab_text:set_blend_mode("normal")
	if this:is_tab_selected() then
		this._line_select:set_world_y(this._tab_text:world_bottom() - 2)
		play_anim(this._line_select, {w = this._tab_text:w(), world_center_x = this._tab_text:world_center_x()})
	end
end