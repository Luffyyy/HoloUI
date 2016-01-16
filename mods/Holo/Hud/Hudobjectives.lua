function HUDBGBox_create( panel, params, config )
	local box_panel = panel:panel( params )
	local color = config and config.color
	local alpha = config and config.alpha 
	local Frame_style = Holo.options.Frame_style
	local blend_mode = config and config.blend_mode
	if Holo.options.hudbox_enable then
		FrameColor = not Holo.options.assaultbox_enable and color == Color(1, 1, 1, 0) and color or HudFrame_color 
	else
		FrameColor = color == Color(1, 1, 1, 0) and color or color == Color(1, 1, 0, 0) and color or HudFrame_color 
	end
    local bg = box_panel:rect({
		name = "bg",
		halign = "grow",
		valign = "grow",
		blend_mode = "normal",
		alpha = alpha or 0.25,
		color = color or Color(1, 0, 0, 0),
		layer = -1
	})
 
	local left_top = box_panel:bitmap({
		name = "left_top",
		halign = "left",
		valign = "top",
		color = FrameColor,
		blend_mode = "normal",
		visible = Holo.options.Frame_enable,
		layer = 10,
		x = 0,
		y = 0
	})
	local left_bottom = box_panel:bitmap({
		name = "left_bottom",
		halign = "left",
		valign = "bottom",
		color = FrameColor,
		rotation = -90,
		blend_mode = "normal",
		visible = Holo.options.Frame_enable,
		layer = 10,
		x = 0,
		y = 0
	})
	local right_top = box_panel:bitmap({
		name = "right_top",
		halign = "right",
		valign = "top",
		color = FrameColor,
		rotation = 90,
		blend_mode = "normal",
		visible = Holo.options.Frame_enable,
		layer = 10,
		x = 0,
		y = 0
	})
	local right_bottom = box_panel:bitmap({
		name = "right_bottom",
		halign = "right",
		valign = "bottom",
		color = FrameColor,
		rotation = 180,
		blend_mode = "normal",
		visible = Holo.options.Frame_enable,
		layer = 10,
		x = 0,
		y = 0
	})
	if Frame_style == 1 then
	    right_bottom:set_image("guis/textures/pd2/hud_corner")
	    left_bottom:set_image("guis/textures/pd2/hud_corner")
	    left_top:set_image("guis/textures/pd2/hud_corner")
	    right_top:set_image("guis/textures/pd2/hud_corner") 
	    right_bottom:set_size(8,8)
	    left_bottom:set_size(8,8)
	    left_top:set_size(8,8)
	    right_top:set_size(8,8)
    elseif Frame_style == 2 then
	    left_bottom:set_size(box_panel:w() , 2)
	    left_bottom:set_halign("grow")
	    right_bottom:set_alpha(0)
	    left_bottom:set_rotation(0)
	    right_top:set_alpha(0)
	    left_top:set_alpha(0)
    elseif Frame_style == 3 then
 	    left_bottom:set_size(2 , box_panel:h())
	    right_bottom:set_alpha(0)
	    left_bottom:set_rotation(0)
	    right_top:set_alpha(0)
	    left_top:set_alpha(0)   
	elseif Frame_style == 4 then
	   	left_top:set_size(box_panel:w() , 2)
	    left_top:set_halign("grow")
	    right_bottom:set_alpha(0)
	    left_top:set_rotation(0)
	    right_top:set_alpha(0)
	    left_bottom:set_alpha(0) 	
    else
	    left_bottom:set_size(box_panel:w() , 2)
	    right_bottom:set_size(2, box_panel:h()) 
	    right_top:set_size(box_panel:w(), 2)
	    left_top:set_size(2, box_panel:h())
	    left_bottom:set_halign("grow")
	    right_top:set_halign("grow")
	    right_bottom:set_rotation(0)
	    left_bottom:set_rotation(0)
	    right_top:set_rotation(0)
	    left_top:set_rotation(0)
	end	
	right_bottom:set_right( box_panel:w())
	right_bottom:set_bottom( box_panel:h())
	right_top:set_right(box_panel:w())
	left_bottom:set_bottom(box_panel:h())
	return box_panel
end
 
function HUDObjectives:update()
	bg = self._bg_box:child("bg")
	local objectives_panel = self._hud_panel:child( "objectives_panel" )
	local amount_text = objectives_panel:child("amount_text")
	local objective_text = objectives_panel:child("objective_text")
	local icon_objectivebox = objectives_panel:child("icon_objectivebox")
	bg:set_alpha(HoloAlpha)
	bg:set_color(objective_box_color)
	icon_objectivebox:set_color(objective_box_color)
	objective_text:set_color(Objective_text_color)
	amount_text:set_color(Objective_text_color)
end

if Holo.options.hudbox_enable then 

local box_speed = 1000
function hudbox_animate_open_right( panel, wait_t, target_w, done_cb, color, icon  )
	panel:set_visible( false )
	panel:set_w( 0 )
	if wait_t then
		wait( wait_t )
	end
	panel:set_visible( true )
	local speed = box_speed
	local bg = panel:child( "bg" )
	bg:stop()
	bg:animate( callback( nil, _G, "hudbox_animate_bg" ), color, false, icon)
	local TOTAL_T = target_w/speed
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		panel:set_w( (1 - t/TOTAL_T) * target_w )
	end
	
	panel:set_w( target_w )
	if done_cb then
		done_cb()
	end
end
 
function hudbox_animate_open_left( panel, wait_t, target_w, done_cb, color, icon )
	panel:set_visible( false )
	local right = panel:right()
	panel:set_w( 0 )
	panel:set_right( right )
	if wait_t then
		wait( wait_t )
	end
	panel:set_visible( true )
	local speed = box_speed
	local bg = panel:child( "bg" )
	bg:stop()
    bg:animate( callback( nil, _G, "hudbox_animate_bg" ), color, true, icon)
	local TOTAL_T = target_w/speed
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		panel:set_w( (1 - t/TOTAL_T) * target_w )
		panel:set_right( right )
	end
	
	panel:set_w( target_w )
	panel:set_right( right )
	if done_cb then
		done_cb()
	end
end
 
 
function hudbox_animate_bg( bg, color, forever, icon )
	local TOTAL_T = 2
	local t = TOTAL_T
	if Holo.options.flashing_enable then
		while t > 0 or forever do
			if not Holo.options.flashing_enable then
				forever = false
			end
			local dt = coroutine.yield()
	 		t = t - dt	
	 		local cv = math.sin( t * 200 ) 
			local col = math.lerp(color, color * 1.5, cv)
			bg:set_color(col:with_alpha(1))
			if icon then
				icon:set_color(col:with_alpha(1))
			end
			bg:set_alpha(HoloAlpha)
	 	end
		bg:set_color(color)
		if icon then
			icon:set_color(color)
		end
	end
end
 
function HUDObjectives:init(hud)
	self._hud_panel = hud.panel
	if self._hud_panel:child("objectives_panel") then
		self._hud_panel:remove(self._hud_panel:child("objectives_panel"))
	end
	local objectives_panel = self._hud_panel:panel({
		visible = false,
		name = "objectives_panel",
		x = 0,
		y = 0,
		h = 100,
		w = 500,
		valign = "top"
	})
	if Holo.options.GageHud_support then
		objectives_panel:set_position(30,7)
	end
	local icon_objectivebox = objectives_panel:bitmap({
		halign = "left",
		valign = "top",
		name = "icon_objectivebox",
		blend_mode = "normal",
		color = objective_box_color,
		alpha = HoloAlpha,
		texture = "guis/textures/pd2/hud_icon_objectivebox",
		visible = not Holo.options.GageHud_support,
		layer = 0,
		x = 0,
		y = 0,
		w = 24,
		h = 24
	})	
	self._bg_box = HUDBGBox_create( objectives_panel,{ 
		w = 200,
		h = 30,
		x = 26,
		y = 0 }, {
		color = objective_box_color, 
		blend_mode = "normal", 
		alpha = HoloAlpha 
	})
	local objective_text = objectives_panel:text({ 
		name = "objective_text", 
		visible = false, 
		layer = 2, 
		color = Objective_text_color, 
		text="", 
		font_size = tweak_data.hud.active_objective_title_font_size - 4, 
		font = "fonts/font_large_mf" , 
		x = 0, 
		y = 4, 
		align = "left", 
		vertical = "top"
    })
	objective_text:set_x(self._bg_box:x() + 8)
	local amount_text = objectives_panel:text({ 
    	name = "amount_text",
    	visible = true, 
    	layer = 2, 
    	color = Objective_text_color, 
	    text="1/4", 
    	font_size = tweak_data.hud.active_objective_title_font_size - 4 , 
    	font = "fonts/font_large_mf", 
    	x = 6, 
	    y = 4, 
	    align = "left",
	    vertical = "top"
    })
end

function HUDObjectives:activate_objective( data )
	local objectives_panel = self._hud_panel:child( "objectives_panel" )
	local objective_text = objectives_panel:child( "objective_text" )
	local amount_text = objectives_panel:child( "amount_text" )
	local icon_objectivebox = objectives_panel:child("icon_objectivebox")

	self._active_objective_id = data.id
	objective_text:set_text( utf8.to_upper( data.text ) )
	local _,_,objective_w,_ = objective_text:text_rect()
	local _,_,amount_w,_ = amount_text:text_rect()	
	objectives_panel:set_visible( true )
    amount_size = 26
	if data.amount then 
	self:update_amount_objective( data )
	amount_size = amount_size + amount_w 
	end

	objective_text:set_visible( false )
	self._bg_box:stop()
	self._bg_box:animate(callback( nil, _G, "hudbox_animate_open_right" ), 0.66, objective_w + amount_size, callback( self, self, "open_right_done", data.amount and true or false ), objective_box_color, icon_objectivebox)
   
	amount_text:set_x( objective_text:x() + 5 + objective_w )	
	objectives_panel:stop()
	objectives_panel:animate( callback( self, self, "_animate_activate_objective" ) )
	
	objectives_panel:child( "amount_text" ):set_visible(false)
	if data.amount then
		self:update_amount_objective( data )
	end
end
function HUDObjectives:update_amount_objective(data)
	if data.id ~= self._active_objective_id then
		return
	end
	local current = data.current_amount or 0
	local amount = data.amount
	local objectives_panel = self._hud_panel:child("objectives_panel")
	objectives_panel:child("amount_text"):set_text(current .. "/" .. amount)
end
function HUDObjectives:complete_objective(data)
	if data.id ~= self._active_objective_id then
		return
	end
	local objectives_panel = self._hud_panel:child("objectives_panel")
	objectives_panel:stop()
	objectives_panel:animate(callback(self, self, "_animate_complete_objective"))
end
function HUDObjectives:remind_objective( id )
	if id ~= self._active_objective_id then
		return
	end
	
	local objectives_panel = self._hud_panel:child( "objectives_panel" )
	objectives_panel:stop()
	objectives_panel:animate( callback( self, self, "_animate_activate_objective" ) )
	
	local bg = self._bg_box:child( "bg" )
	
	bg:stop()
	bg:animate( callback( nil, _G, "hudbox_animate_bg" ), objective_box_color, false )
end

end
