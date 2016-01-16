Holo:clone(HUDAssaultCorner)
function HUDAssaultCorner:init( ... )
	self.old.init(self, ...)
	local hostages_panel = self._hud_panel:child("hostages_panel") 
	local num_hostages = self._hostages_bg_box:child( "num_hostages" )
	local HostageBG = self._hostages_bg_box:child( "bg" )
	local hostages_icon = hostages_panel:child( "hostages_icon" )
	if Holo.options.hudbox_enable then 
		local AssaultBG = self._bg_box:child( "bg" )
		local CasingBG = self._casing_bg_box:child( "bg" )
		local NoreturnBG = self._noreturn_bg_box:child( "bg" )
		local point_of_no_return_text = self._noreturn_bg_box:child( "point_of_no_return_text" )
		local point_of_no_return_timer = self._noreturn_bg_box:child( "point_of_no_return_timer" )
		local vipBG = self._vip_bg_box:child("bg")
		local vip_icon = self._vip_bg_box:child("vip_icon")
		local assault_panel = self._hud_panel:child( "assault_panel" )
		local casing_panel = self._hud_panel:child("casing_panel")
		local no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		local casing_icon = casing_panel:child( "icon_casingbox" )
		local noreturn_icon = no_return_panel:child( "icon_noreturnbox" )
		local assault_icon = assault_panel:child( "icon_assaultbox" )
		CasingBG:set_color(Casing_color)	   	
		casing_icon:set_color(Casing_color)
		casing_icon:set_blend_mode("normal")
	   	NoreturnBG:set_color(Noreturn_color)	   	
	   	noreturn_icon:set_color(Noreturn_color)
	   	noreturn_icon:set_blend_mode("normal")
	   	point_of_no_return_text:set_color(Noreturn_text_color)
	   	point_of_no_return_timer:set_color(Noreturn_text_color)
	   	Holo:ApplySettings({CasingBG, NoreturnBG}, {alpha = HoloAlpha}) 
		noreturn_icon:show()

		if Holo.options.assaultbox_enable then
			AssaultBG:set_alpha(HoloAlpha)
			Holo:ApplySettings({AssaultBG, assault_icon},{color = Assault_color})
			assault_icon:set_blend_mode("normal")
			vipBG:hide()
			vip_icon:hide()
			self._vip_bg_box:set_shape(assault_icon:shape())	
		end
	end
	if Holo.options.hostages_enable and Infohud_enable then 	
		self._hostages_bg_box:hide(0)
		self._hostages_bg_box:set_alpha(0)		
		hostages_icon:hide()
		hostages_icon:set_blend_mode("normal")
		hostages_icon:set_alpha(0)
    elseif Holo.options.hudbox_enable and not Holo.options.HoxHud_support then
		HostageBG:set_color(Hostage_color)			
		HostageBG:set_alpha(HoloAlpha)
    	num_hostages:set_color(Hostage_text_color)
	end
end

if Holo.options.hudbox_enable then 

function HUDAssaultCorner:_show_icon_assaultbox(icon_assaultbox, config)
	local TOTAL_T = 2
	local t = TOTAL_T
	local forever = config and config.forever or false
	while t > 0 or forever do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs((math.sin(t * 360 * 2))))
		icon_assaultbox:set_alpha(alpha)
	end
	icon_assaultbox:set_alpha(1)
end
if Holo.options.assaultbox_enable then 	
function HUDAssaultCorner:_start_assault(text_list)
	text_list = text_list or {""}
	local assault_panel = self._hud_panel:child("assault_panel")
	local text_panel = assault_panel:child("text_panel")
	self:_set_text_list(text_list)
	self._assault = true
	if self._bg_box:child("text_panel") then
		self._bg_box:child("text_panel"):stop()
		self._bg_box:child("text_panel"):clear()
	else
		self._bg_box:panel({name = "text_panel"})
	end
	self._bg_box:child("bg"):stop()
	assault_panel:show()
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	icon_assaultbox:stop()
	icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))
	if not Holo.options.HoxHud_support and not Holo.options.GageHud_support then 
		self:_hide_hostages()
	end
	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "hudbox_animate_open_left"), 0.75, 242, nil, Assault_color ,icon_assaultbox)
	local box_text_panel = self._bg_box:child("text_panel")
	box_text_panel:stop()
	box_text_panel:animate( callback( self, self, "_animate_text" ), self._bg_box, Assault_text_color)
end
end	
 
function HUDAssaultCorner:_offset_hostage(is_offseted, hostage_panel)
	local TOTAL_T = 0.18
	local OFFSET = self._bg_box:h() + 8
	local from_y = is_offseted and 0 or OFFSET
	local target_y = is_offseted and OFFSET or 0
	local t = (1 - math.abs(hostage_panel:y() - target_y) / OFFSET) * TOTAL_T
	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = math.min(t + dt, TOTAL_T)
		local lerp = t / TOTAL_T
		if not Holo.options.Infohud_enable then
			hostage_panel:set_y(math.lerp(from_y, target_y, lerp))
		end
		if self._start_assault_after_hostage_offset and lerp > 0.4 then
			self._start_assault_after_hostage_offset = nil
			self:start_assault_callback()
		end
	end
	if self._start_assault_after_hostage_offset then
		self._start_assault_after_hostage_offset = nil
		self:start_assault_callback()
	end
end
function HUDAssaultCorner:set_buff_enabled(buff_name, enabled)
	self._hud_panel:child("buffs_panel"):set_visible(enabled)
end
function HUDAssaultCorner:_end_assault()
	if not self._assault then
		return
	end
	self:_set_feedback_color(nil)
	self._assault = false
	self._bg_box:child("text_panel"):stop()
	self._bg_box:child("text_panel"):clear()
	local function close_done()
		self._bg_box:hide()
		local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_hide_icon_assaultbox"))
		self:sync_set_assault_mode("normal")
	end
	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)
end
function HUDAssaultCorner:sync_set_assault_mode(mode)
	if self._assault_mode == mode then
		return
	end
	self._assault_mode = mode
	self._current_assault_color = color
	self:_set_text_list(self:_get_assault_strings())
	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	local image = mode == "phalanx" and "guis/textures/pd2/hud_icon_padlockbox" or "guis/textures/pd2/hud_icon_assaultbox"
	icon_assaultbox:set_image(image)
end
function HUDAssaultCorner:_get_assault_strings()
	if self._assault_mode == "normal" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")
			return {
				"hud_assault_assault",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line"
			}
		else
			return {
				"hud_assault_assault",
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line"
			}
		end
	end
	if self._assault_mode == "phalanx" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")
			return {
				"hud_assault_vip",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_vip",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line"
			}
		else
			return {
				"hud_assault_vip",
				"hud_assault_end_line",
				"hud_assault_vip",
				"hud_assault_end_line",
				"hud_assault_vip",
				"hud_assault_end_line"
			}
		end
	end
end
function HUDAssaultCorner:_show_icon_assaultbox(icon_assaultbox)
	local TOTAL_T = 2
	local t = TOTAL_T
	icon_assaultbox:show()
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs((math.sin(t * 360 * 2))))
		icon_assaultbox:set_alpha(alpha)
	end
	icon_assaultbox:set_alpha(1)
end
function HUDAssaultCorner:_hide_icon_assaultbox(icon_assaultbox)
	local TOTAL_T = 1
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local alpha = math.round(math.abs((math.cos(t * 360 * 2))))
		icon_assaultbox:set_alpha(alpha)
	end
	icon_assaultbox:hide()
	icon_assaultbox:set_alpha(1)
	if not self._casing and not Holo.options.HoxHud_support and not Holo.options.GageHud_support then 
		self:_show_hostages()
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
			align = "center",
			vertical ="center",
			blend_mode = "normal",
			color = color or self._assault_color,
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

if not Holo.options.HoxHud_support and not Holo.options.GageHud_support then 	
function HUDAssaultCorner:show_casing(mode)
	local delay_time = self._assault and 1.2 or 0
	self:_end_assault()
	local casing_panel = self._hud_panel:child("casing_panel")
	local text_panel = casing_panel:child("text_panel")
	text_panel:script().text_list = {}
	self._casing_bg_box:script().text_list = {}
	local msg
	if mode == "civilian" then
		msg = {
			"hud_casing_mode_ticker_clean",
			"hud_assault_end_line",
			"hud_casing_mode_ticker_clean",
			"hud_assault_end_line"
		}
	else
		msg = {
			"hud_casing_mode_ticker",
			"hud_assault_end_line",
			"hud_casing_mode_ticker",
			"hud_assault_end_line"
		}
	end
	for _, text_id in ipairs(msg) do
		table.insert(text_panel:script().text_list, text_id)
		table.insert(self._casing_bg_box:script().text_list, text_id)
	end
	if self._casing_bg_box:child("text_panel") then
		self._casing_bg_box:child("text_panel"):stop()
		self._casing_bg_box:child("text_panel"):clear()
	else
		self._casing_bg_box:panel({name = "text_panel"})
	end
	self:_hide_hostages()

	casing_panel:stop()
	casing_panel:animate(callback(self, self, "_animate_show_casing"), delay_time)
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
	self._casing_bg_box:animate( callback( nil, _G, "hudbox_animate_open_left" ), 0.85, 242, open_done, Casing_color, icon_casingbox )
	
	local text_panel = self._casing_bg_box:child( "text_panel" )
	text_panel:stop()
	text_panel:animate( callback( self, self, "_animate_text" ), self._casing_bg_box, Casing_text_color)
end
function HUDAssaultCorner:_hide_hostages()
	self._hud_panel:child( "hostages_panel" ):hide()	
end

end

function HUDAssaultCorner:_animate_show_noreturn(point_of_no_return_panel, delay_time)
	local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
	local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
	point_of_no_return_text:hide()
	local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
	point_of_no_return_timer:hide()
	wait(delay_time)
	point_of_no_return_panel:show()
	icon_noreturnbox:stop()
	icon_noreturnbox:animate(callback(self, self, "_show_icon_assaultbox"))
	local function open_done()
		point_of_no_return_text:animate(callback(self, self, "_animate_show_texts"), {point_of_no_return_text, point_of_no_return_timer})
	end

	self._noreturn_bg_box:stop()
	self._noreturn_bg_box:animate(callback(nil, _G, "hudbox_animate_open_left"), 0.75, 242, open_done, Noreturn_color, icon_noreturnbox)
end

function HUDAssaultCorner:show_point_of_no_return_timer()
	local delay_time = self._assault and 1.2 or 0
	self:_end_assault()
	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
	point_of_no_return_panel:stop()
	point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
	self:_set_feedback_color(self._noreturn_color)
	self._point_of_no_return = true
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

function HUDAssaultCorner:update()
  if Holo.options.hudbox_enable then 
   local AssaultBG = self._bg_box:child( "bg" )
   local HostageBG = self._hostages_bg_box:child( "bg" )
   local CasingBG = self._casing_bg_box:child( "bg" )
   local NoreturnBG = self._noreturn_bg_box:child( "bg" )
   local point_of_no_return_text = self._noreturn_bg_box:child( "point_of_no_return_text" )
   local point_of_no_return_timer = self._noreturn_bg_box:child( "point_of_no_return_timer" )
   local vipBG = self._vip_bg_box:child("bg")
   local vip_icon = self._vip_bg_box:child("vip_icon")
   local assault_panel = self._hud_panel:child( "assault_panel" )
   local casing_panel = self._hud_panel:child("casing_panel")
   local hostages_panel = self._hud_panel:child("hostages_panel")
   local no_return_panel = self._hud_panel:child("point_of_no_return_panel")
   local casing_icon = casing_panel:child( "icon_casingbox" )
   local hostages_icon = hostages_panel:child( "hostages_icon" )
   local noreturn_icon = no_return_panel:child( "icon_noreturnbox" )
   local assault_icon = assault_panel:child( "icon_assaultbox" )
   local num_hostages = self._hostages_bg_box:child( "num_hostages" )
   	CasingBG:set_color(Casing_color)
   	NoreturnBG:set_color(Noreturn_color)
   	point_of_no_return_text:set_color(Noreturn_text_color)
   	point_of_no_return_timer:set_color(Noreturn_text_color)
   	casing_icon:set_color(Casing_color)		   		
   	Holo:ApplySettings({CasingBG, NoreturnBG}, {alpha = HoloAlpha}) 
   	noreturn_icon:set_color(Noreturn_color)	   		

    if Holo.options.assaultbox_enable then
		AssaultBG:set_alpha(HoloAlpha)
		Holo:ApplySettings({AssaultBG, assault_icon},{color = Assault_color})
	end
    if not Holo.options.HoxHud_support then 
		HostageBG:set_color(Hostage_color)			
		HostageBG:set_alpha(HoloAlpha)
    	num_hostages:set_color(Hostage_text_color)
    end	
  end
end

