if Holo.options.HudBox_enable == true then 
CloneClass(HUDAssaultCorner)
if Holo.options.PDTHHud_support == true then 
function HUDAssaultCorner:init(hud, full_hud) 
	self._hud_panel = hud.panel
	self._full_hud_panel = full_hud.panel
	if self._hud_panel:child("assault_panel") then
		self._hud_panel:remove(self._hud_panel:child("assault_panel"))
	end
	local size = 200
	local assault_panel = self._hud_panel:panel({
		visible = false,
		name = "assault_panel",
		w = 400,
		h = 100
	})
	assault_panel:set_top(0)
	assault_panel:set_right(self._hud_panel:w())
	self._assault_color = Color(1, 1, 1, 0)
	local icon_assaultbox = assault_panel:bitmap({
		halign = "right",
		valign = "top",
		color = Color.yellow,
		name = "icon_assaultbox",
		blend_mode = "add",
		visible = true,
		layer = 0,
		texture = "guis/textures/pd2/hud_icon_assaultbox",
		x = 0,
		y = 0,
		w = 24,
		h = 24
	})
	icon_assaultbox:set_right(icon_assaultbox:parent():w())
	self._bg_box = HUDBGBox_create(assault_panel, {
		w = 242,
		h = 38,
		x = 0,
		y = 0
	}, {
		color = self._assault_color,
		blend_mode = "add"
	})
	self._bg_box:set_right(icon_assaultbox:left() - 3)
	local yellow_tape = assault_panel:rect({
		visible = false,
		name = "yellow_tape",
		h = tweak_data.hud.location_font_size * 1.5,
		w = size * 3,
		color = Color(1, 0.8, 0),
		layer = 1
	})
	yellow_tape:set_center(10, 10)
	yellow_tape:set_rotation(30)
	yellow_tape:set_blend_mode("add")
	assault_panel:panel({
		name = "text_panel",
		layer = 1,
		w = yellow_tape:w()
	}):set_center(yellow_tape:center())
	if self._hud_panel:child("hostages_panel") then
		self._hud_panel:remove(self._hud_panel:child("hostages_panel"))
	end
	local hostages_panel = self._hud_panel:panel({
		name = "hostages_panel",
		w = size,
		h = size,
		x = self._hud_panel:w() - size
	})
	self._hostages_bg_box = HUDBGBox_create(hostages_panel, {
		w = 38,
		h = 38,
		x = 0,
		y = 0
	}, {})
	self._hostages_bg_box:set_right(hostages_panel:w())
	local num_hostages = self._hostages_bg_box:text({
		name = "num_hostages",
		text = "0",
		valign = "center",
		align = "center",
		vertical = "center",
		w = self._hostages_bg_box:w(),
		h = self._hostages_bg_box:h(),
		layer = 1,
		x = 0,
		y = 0,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
		font_size = tweak_data.hud_corner.numhostages_size
	})
	local hostages_icon = hostages_panel:bitmap({
		name = "hostages_icon",
		texture = "guis/textures/pd2/hud_icon_hostage",
		valign = "top",
		layer = 1,
		x = 0,
		y = 0
	})
	hostages_icon:set_right(self._hostages_bg_box:left())
	hostages_icon:set_center_y(self._hostages_bg_box:h() / 2)
	if self._hud_panel:child("point_of_no_return_panel") then
		self._hud_panel:remove(self._hud_panel:child("point_of_no_return_panel"))
	end
	local size = 300
	local point_of_no_return_panel = self._hud_panel:panel({
		visible = false,
		name = "point_of_no_return_panel",
		w = size,
		h = 40,
		x = self._hud_panel:w() - size
	})
	self._noreturn_color = Color(1, 1, 0, 0)
	local icon_noreturnbox = point_of_no_return_panel:bitmap({
		halign = "right",
		valign = "top",
		color = self._noreturn_color,
		name = "icon_noreturnbox",
		blend_mode = "add",
		visible = true,
		layer = 0,
		texture = "guis/textures/pd2/hud_icon_noreturnbox",
		x = 0,
		y = 0,
		w = 24,
		h = 24
	})
	icon_noreturnbox:set_right(icon_noreturnbox:parent():w())
	self._noreturn_bg_box = HUDBGBox_create(point_of_no_return_panel, {
		w = 242,
		h = 38,
		x = 0,
		y = 0
	}, {
		color = self._noreturn_color,
		blend_mode = "add"
	})
	self._noreturn_bg_box:set_right(icon_noreturnbox:left() - 3)
	local w = point_of_no_return_panel:w()
	local size = 200 - tweak_data.hud.location_font_size
	local point_of_no_return_text = self._noreturn_bg_box:text({
		name = "point_of_no_return_text",
		text = "",
		blend_mode = "add",
		layer = 1,
		valign = "center",
		align = "right",
		vertical = "center",
		x = 0,
		y = 0,
		color = self._noreturn_color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})
	point_of_no_return_text:set_text(utf8.to_upper(managers.localization:text("hud_assault_point_no_return_in", {time = ""})))
	point_of_no_return_text:set_size(self._noreturn_bg_box:w(), self._noreturn_bg_box:h())
	local point_of_no_return_timer = self._noreturn_bg_box:text({
		name = "point_of_no_return_timer",
		text = "",
		blend_mode = "add",
		layer = 1,
		valign = "center",
		align = "center",
		vertical = "center",
		x = 0,
		y = 0,
		color = self._noreturn_color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})
	local _, _, w, h = point_of_no_return_timer:text_rect()
	point_of_no_return_timer:set_size(46, self._noreturn_bg_box:h())
	point_of_no_return_timer:set_right(point_of_no_return_timer:parent():w())
	point_of_no_return_text:set_right(math.round(point_of_no_return_timer:left()))
	if self._hud_panel:child("casing_panel") then
		self._hud_panel:remove(self._hud_panel:child("casing_panel"))
	end
	local size = 300
	local casing_panel = self._hud_panel:panel({
		visible = false,
		name = "casing_panel",
		w = size,
		h = 40,
		x = self._hud_panel:w() - size
	})
	self._casing_color = Color.white
	local icon_casingbox = casing_panel:bitmap({
		halign = "right",
		valign = "top",
		color = self._casing_color,
		name = "icon_casingbox",
		blend_mode = "add",
		visible = true,
		layer = 0,
		texture = "guis/textures/pd2/hud_icon_stealthbox",
		x = 0,
		y = 0,
		w = 24,
		h = 24
	})
	icon_casingbox:set_right(icon_casingbox:parent():w())
	self._casing_bg_box = HUDBGBox_create(casing_panel, {
		w = 242,
		h = 38,
		x = 0,
		y = 0
	}, {
		color = self._casing_color,
		blend_mode = "add"
	})
	self._casing_bg_box:set_right(icon_casingbox:left() - 3)
	local w = casing_panel:w()
	local size = 200 - tweak_data.hud.location_font_size
	casing_panel:panel({
		name = "text_panel",
		layer = 1,
		w = yellow_tape:w()
	}):set_center(yellow_tape:center())--Only when pdth hud is loaded.
end
end
Hooks:PostHook(HUDAssaultCorner, "init", "NewInit", function(self, hud, full_hud)
   local AssaultBG = self._bg_box:child( "bg" )
   local HostageBG = self._hostages_bg_box:child( "bg" )
   local CasingBG = self._casing_bg_box:child( "bg" )
   local NoreturnBG = self._noreturn_bg_box:child( "bg" )
   local point_of_no_return_text = self._noreturn_bg_box:child( "point_of_no_return_text" )
   local point_of_no_return_timer = self._noreturn_bg_box:child( "point_of_no_return_timer" )
   local assault_panel = self._hud_panel:child( "assault_panel" )
   local casing_panel = self._hud_panel:child("casing_panel")
   local hostages_panel = self._hud_panel:child("hostages_panel")
   local no_return_panel = self._hud_panel:child("point_of_no_return_panel")
   local casing_icon = casing_panel:child( "icon_casingbox" )
   local hostages_icon = hostages_panel:child( "hostages_icon" )
   local noreturn_icon = no_return_panel:child( "icon_noreturnbox" )
   local assault_icon = assault_panel:child( "icon_assaultbox" )
   local num_hostages = self._hostages_bg_box:child( "num_hostages" )
    
    --Blend mode
	CasingBG:set_blend_mode("normal") 
	NoreturnBG:set_blend_mode("normal") 
  	point_of_no_return_text:set_blend_mode("normal") 
	point_of_no_return_timer:set_blend_mode("normal") 
	noreturn_icon:set_blend_mode("normal") 	
	assault_icon:set_blend_mode("normal")
    casing_icon:set_blend_mode("normal")
	
	--Color
	CasingBG:set_color(Casing_color)
	NoreturnBG:set_color(Noreturn_color)
	point_of_no_return_text:set_color(Noreturn_text_color)
	point_of_no_return_timer:set_color(Noreturn_text_color)
	noreturn_icon:set_color(Noreturn_color) 	
	assault_icon:set_color(Assault_color)
    casing_icon:set_color(Casing_color)
	
	--Alpha
	noreturn_icon:set_alpha(HoloAlpha or 1)
	CasingBG:set_alpha(HoloAlpha or 1)
    NoreturnBG:set_alpha(HoloAlpha or 1)
    NoreturnBG:set_alpha(HoloAlpha or 1)
	noreturn_icon:set_alpha(HoloAlpha or 1)
	assault_icon:set_alpha(HoloAlpha or 1)
    casing_icon:set_alpha(HoloAlpha or 1)
	noreturn_icon:set_visible( true )
	if Holo.options.Assault_enable == true then
	 AssaultBG:set_blend_mode("normal") 	
	 AssaultBG:set_color(Assault_color) 
	 AssaultBG:set_alpha(HoloAlpha or 1)	
	 end
	if Holo.options.HoxHud_support == false then 	
   	 num_hostages:set_color(Hostage_text_color)
	 HostageBG:set_blend_mode("normal") 
	 HostageBG:set_color(Hostage_color)
	 HostageBG:set_alpha(HoloAlpha or 1)

      if Holo.options.Hostage_enable == true then 
	    assault_panel:set_right( self._hud_panel:w() - 30) 
	    self._hostages_bg_box:set_w(46)	
	    casing_panel:set_right( self._hud_panel:w() - 30)	 
        self._hostages_bg_box:set_right( hostages_panel:w() )
    	assault_icon:set_visible( false )
        casing_icon:set_visible( false )
	    hostages_icon:set_right( self._hostages_bg_box:left() + 30 )
     	hostages_icon:set_center_y( self._hostages_bg_box:h()/2 )	
    	num_hostages:set_x(15)
    	num_hostages:set_layer(2)
      else 
	  	assault_icon:set_visible( true )
        casing_icon:set_visible( true )
        assault_panel:set_right(self._hud_panel:w() )
	    casing_panel:set_right( self._hud_panel:w())
      end 	

	end
end)

function HUDAssaultCorner:_show_icon_assaultbox(icon_assaultbox, config)
	local TOTAL_T = 2
	local t = TOTAL_T
	local forever = config and config.forever or false
	while t > 0 or forever do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs((math.sin(t * 360 * 2 - HoloAlpha))))
		icon_assaultbox:set_alpha(alpha)
	end
	
	icon_assaultbox:set_alpha(HoloAlpha)
end
if Holo.options.Assault_enable == true then 	


function HUDAssaultCorner:_animate_assault( bg_box )
	local assault_panel = self._hud_panel:child( "assault_panel" )
	local icon_assaultbox = assault_panel:child( "icon_assaultbox" )

	icon_assaultbox:stop()
	icon_assaultbox:animate( callback( self, self, "_show_icon_assaultbox" ) )
			
	self._bg_box:animate( callback( nil, _G, "assault_animate_open_left" ), 0.85, 242, function() end, { attention_color = Assault_color, attention_forever = true } )
	local text_panel = self._bg_box:child( "text_panel" )
	text_panel:stop()
	text_panel:animate( callback( self, self, "_animate_text" ), self._bg_box, Assault_text_color)
end

end 

function HUDAssaultCorner:_animate_text( text_panel, bg_box, color )
	local text_list = (bg_box or self._bg_box):script().text_list
	local text_index = 0
	local texts = {}
	local padding = 8	
	local create_new_text = function( text_panel, text_list, text_index, texts )
		if( texts[text_index] and texts[text_index].text ) then
			text_panel:remove( texts[text_index].text )
			texts[text_index] = nil
		end
		local text_id = text_list[text_index]
		local text_string = ""
		
		if type( text_id ) == "string" then
			text_string = managers.localization:to_upper_text( text_id )
		elseif text_id == Idstring( "risk" ) then
			for i = 1, managers.job:current_difficulty_stars() do
				text_string =  text_string .. managers.localization:get_default_macro( "BTN_SKULL" )
			end
		end	
		local text = text_panel:text({
		text=text_string, 
		layer=2,
		align="center",
		vertical="center",
		blend_mode = "normal",
		color= color or self._assault_color,
		font_size= tweak_data.hud.active_objective_title_font_size, 
		font="fonts/font_large_mf",
		w=10,
		h=10 
	})
		local _, _, w, h = text:text_rect()
		text:set_size( w, h )
		
		texts[text_index] = { x=text_panel:w() + w*0.5 + padding*2, text=text }
	end	
	while true do
		local dt = coroutine.yield()
		local last_text = texts[text_index]
		if( last_text and last_text.text ) then
			if( last_text.x + last_text.text:w()*0.5 + padding < text_panel:w() ) then
				text_index = (text_index % #text_list) + 1
				create_new_text( text_panel, text_list, text_index, texts )
			end
		else
			text_index = (text_index % #text_list) + 1
			create_new_text( text_panel, text_list, text_index, texts )
		end	
		local speed = 90	
		for i, data in pairs( texts ) do
			if( data.text ) then
				data.x = data.x - dt * speed
				data.text:set_center_x( data.x )
				data.text:set_center_y( text_panel:h()*0.5 )
				
				if( data.x + data.text:w()*0.5 < 0 ) then
					text_panel:remove( data.text )
					data.text = nil
				end
			end
		end
	end
end

if Holo.options.HoxHud_support == false then 	
function HUDAssaultCorner:show_casing()
	local delay_time = self._assault and 1.2 or 0	
	self:_end_assault()

	local casing_panel = self._hud_panel:child( "casing_panel" )
	local text_panel = casing_panel:child("text_panel")
    text_panel:set_visible(true)
	text_panel:script().text_list = {}
	self._casing_bg_box:script().text_list = {}
	End = "hud_assault_end_line"
	for _, text_id in ipairs( { "hud_casing_mode_ticker", End, "hud_casing_mode_ticker", End } ) do
		table.insert( text_panel:script().text_list, text_id )
		table.insert( self._casing_bg_box:script().text_list, text_id )
	end	
	if self._casing_bg_box:child( "text_panel" ) then
		self._casing_bg_box:child( "text_panel" ):stop()
		self._casing_bg_box:child( "text_panel" ):clear()
	else
		self._casing_bg_box:panel( { name = "text_panel" } )
	end
	
	self._casing_bg_box:child( "bg" ):stop()
				
	self._hud_panel:child( "hostages_panel" ):set_visible( Holo.options.Hostage_enable )	
		
	casing_panel:stop()
	casing_panel:animate( callback( self, self, "_animate_show_casing" ), delay_time )
	
	self._casing = true
end 
function HUDAssaultCorner:_animate_show_casing( casing_panel, delay_time )
	local icon_casingbox = casing_panel:child( "icon_casingbox" )
	wait( delay_time )	
	casing_panel:set_visible( true )
	
	icon_casingbox:stop()
	icon_casingbox:animate( callback( self, self, "_show_icon_assaultbox" ) )
	
	local open_done = function()
		casing_text:animate( callback( self, self, "_animate_simple_text" ) )	
	end
	
	self._casing_bg_box:stop()		
	self._casing_bg_box:animate( callback( nil, _G, "casing_animate_open_left" ), 0.85, 242, open_done, { attention_color = Casing_color:with_alpha(HoloAlpha), attention_forever = true } )
	
	local text_panel = self._casing_bg_box:child( "text_panel" )
	text_panel:stop()
	text_panel:animate( callback( self, self, "_animate_text" ), self._casing_bg_box, Casing_text_color)
end
function HUDAssaultCorner:_hide_hostages()
    if Holo.options.Hostage_enable == true then 
	self._hud_panel:child( "hostages_panel" ):show()	
    else 
    self._hud_panel:child( "hostages_panel" ):hide()
    end 
end
function HUDAssaultCorner:set_control_info(data)
local num_hostages = self._hostages_bg_box:child("num_hostages")
	num_hostages:set_text("" .. data.nr_hostages)
	num_hostages:animate(callback(self, self, "_animate_show_texts"), {num_hostages})
end
end

function HUDAssaultCorner:_animate_show_noreturn(point_of_no_return_panel, delay_time)
	local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
	local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
	point_of_no_return_text:set_visible(false)
	local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
	point_of_no_return_timer:set_visible(false)
	wait(delay_time)
	point_of_no_return_panel:set_visible(true)
	icon_noreturnbox:stop()
	icon_noreturnbox:animate(callback(self, self, "_show_icon_assaultbox"))
	local function open_done()
		point_of_no_return_text:animate(callback(self, self, "_animate_show_texts"), {point_of_no_return_text, point_of_no_return_timer})
	end

	self._noreturn_bg_box:stop()
	self._noreturn_bg_box:animate(callback(nil, _G, "noreturn_animate_open_left"), 0.75, 242, open_done, {
		attention_color = self._casing_color,
		attention_forever = true
	})
end

function HUDAssaultCorner:flash_point_of_no_return_timer( beep )
	local flash_timer = function (o)
		local t = 0
		
		while t < 0.5 do
			t = t + coroutine.yield()
			
			local n = 1 - math.sin( t * 180 )
            			o:set_font_size( math.lerp( tweak_data.hud_corner.noreturn_size, tweak_data.hud_corner.noreturn_size * 1.25, n) )
		end
  	end
  	local point_of_no_return_timer = self._noreturn_bg_box:child( "point_of_no_return_timer" )

	point_of_no_return_timer:animate( flash_timer )
end
end