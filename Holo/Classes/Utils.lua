Holo.Utils = Holo.Utils or {}
local Utils = Holo.Utils

function Utils:ModifyWallet()
 	local panel = Global.wallet_panel
	local w
	local items = {"money", "level", "skillpoint", "coins", "gage_coins"}
	for i, v in pairs(items) do
		local child = "wallet_" .. v
		if i == 5 then -- tbh idk what's the point 
			child = v
		end
		local icon = panel:child(child .. "_icon")
		local text = panel:child(child .. "_text")
		if icon then
			local text_before = i > 1 and panel:child("wallet_" .. items[i - 1] .. "_text")
			icon:set_leftbottom(text_before and text_before:right() + 10 or 4, Global.wallet_panel:h() - 4)
			WalletGuiObject.make_fine_text(text)
			text:set_left(icon:right() + 2)
			text:set_y(math.round(icon:y() - 2))
			icon:set_color(Holo:GetColor("TextColors/Menu"))	
			text:set_color(Holo:GetColor("TextColors/Menu"))		
			w = text:right() + 2
		end
	end
	if panel:child("line") then
		panel:remove(panel:child("line"))
	end
	panel:rect({
		name = "line",
		color = Holo:GetColor("Colors/Marker"),	
		w = w,
		h = 2,
	}):set_bottom(panel:h())	
end

function Utils:FixBackButton(this, back_button)
	if not managers.menu:is_pc_controller() or not alive(back_button) then
		return
	end
	this._back_button = back_button
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
	back_button:set_world_rightbottom(back_button:parent():world_rightbottom())
	this._back_marker:set_rightbottom(back_button:right() + 4, back_button:bottom())
	Hooks:PostHook(this, "mouse_moved", "HoloMouseMoved", function(this, o, x, y)
		if this._back_button:inside(x, y) then
			if not this.back_button_highlighted then
				this._back_button_highlighted = true
				this.back_button_highlighted = true
				this._back_marker:stop()
				this._back_button:stop()
				Swoosh:color(this._back_button, Holo:GetColor("TextColors/MenuHighlighted"))
				Swoosh:work(this._back_marker, 
					"alpha", Holo.Options:GetValue("Menu/MarkerAlpha"),
					"speed", 5
				)	
				managers.menu_component:post_event("highlight")
			end
		elseif this.back_button_highlighted then
			this._back_button_highlighted = false
			this.back_button_highlighted = false
			this._back_marker:stop()
			this._back_button:stop()
			Swoosh:color(this._back_button, Holo:GetColor("TextColors/Menu"))
			Swoosh:work(this._back_marker, 
				"alpha", 0,
				"speed", 5
			)			
		end
	end)
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

function Utils:SetPosition(p, setting)
	local position = Holo.Options:GetValue("Extra/Positions/"..setting)
	if position then
		local pos = Holo.Positions[position]
		local pp = p:parent()
		if pos:match("Center") then p:set_world_center(pp:world_center()) end
		if pos:match("Top") then p:set_world_y(pp:world_y()) end
		if pos:match("Bottom") then p:set_world_bottom(pp:world_bottom()) end
		if pos:match("Left") then p:set_world_left(pp:world_left()) end
		if pos:match("Right") then p:set_world_right(pp:world_right()) end
		for _, clbk in pairs(Holo.set_position_clbks) do
			clbk(setting, pos)
		end
	else
		Holo:log("[ERROR] No position setting for %s", setting)
	end
end

function Utils:NotUglyTab(tab, text)
	text:configure({
		blend_mode = "normal",
		color = Holo:GetColor("TextColors/Tab"),
	})
	tab:configure({
		texture = "units/white_df",
		visible = true,
	})
	tab:set_shape(text:shape())
end