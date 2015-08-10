
core:import("CoreMenuRenderer")

require "lib/managers/menu/MenuNodeGui"
require "lib/managers/menu/renderers/MenuNodeTableGui"
require "lib/managers/menu/renderers/MenuNodeStatsGui"
require "lib/managers/menu/renderers/MenuNodeCreditsGui"
require "lib/managers/menu/renderers/MenuNodeButtonLayoutGui"
require "lib/managers/menu/renderers/MenuNodeHiddenGui"
require "lib/managers/menu/renderers/MenuNodeCrimenetGui"
require "lib/managers/menu/renderers/MenuNodeUpdatesGui"
require "lib/managers/menu/renderers/MenuNodeReticleSwitchGui"

MenuRenderer = MenuRenderer or CloneClass( CoreMenuRenderer.Renderer )

function MenuRenderer:init( logic, ... )
	MenuRenderer.super.init( self, logic, ... )
	
	self._sound_source = SoundDevice:create_source( "MenuRenderer" )
end
function MenuRenderer:show_node( node )
	local gui_class = MenuNodeGui
	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable( node:parameters().gui_class )
	end
	local parameters = { 	font = tweak_data.menu.pd2_medium_font ,
							row_item_color = Holo.options.Menu_enable == true and Color.white or tweak_data.screen_colors.button_stage_3,
							row_item_hightlight_color = Holo.options.Menu_enable == true and ColorRGB(0, 150, 255) or tweak_data.screen_colors.button_stage_2, 
							row_item_blend_mode = Holo.options.Menu_enable == true and "normal" or "add",
							font_size = tweak_data.menu.pd2_medium_font_size,
							node_gui_class = gui_class, 
							spacing = node:parameters().spacing,
							marker_alpha = 0.6,
							marker_color = Holo.options.Menu_enable == true and Color.white:with_alpha(0.2) or tweak_data.screen_colors.button_stage_3:with_alpha(0.2),
							align = "right",
							to_upper = true,
	 					} 
	MenuRenderer.super.show_node( self, node, parameters )
end

function MenuRenderer:open(...)
	MenuRenderer.super.open( self, ... )
	
	self:_create_framing()
	
	-- self._menu_bg = self._main_panel:bitmap( { visible = false, texture = tweak_data.menu_themes[ managers.user:get_setting( "menu_theme" ) ][ "background" ] } )
	
	self._menu_stencil_align = "left"
	self._menu_stencil_default_image = "guis/textures/empty"
	self._menu_stencil_image = self._menu_stencil_default_image
	-- self._menu_stencil = self._main_panel:bitmap( { visible = false, texture = self._menu_stencil_image, layer = 1, blend_mode = "normal" } )
		
	-- managers.menu_component:create_newsfeed_gui()
	-- self:_create_newsfeed_gui()
	-- self:_create_chat_gui()
	
	self:_layout_menu_bg()
end

function MenuRenderer:_create_framing()
	local bh = CoreMenuRenderer.Renderer.border_height
	local scaled_size = managers.gui_data:scaled_size()
	self._bottom_line = self._main_panel:bitmap( { texture = "guis/textures/headershadow", rotation = 180, layer = 1, color = Color.white:with_alpha( 0.0 ), alpha=0, w = scaled_size.width, y = scaled_size.height - bh, blend_mode = "add" } )
	self._bottom_line:hide()
	MenuRenderer._create_bottom_text( self )
end

function MenuRenderer:_create_bottom_text()
	local scaled_size = managers.gui_data:scaled_size()
	self._bottom_text = self._main_panel:text( { text = "",
													wrap = true, word_wrap = true,
													font_size = tweak_data.menu.pd2_small_font_size, -- tweak_data.menu.small_font_size,
													align="right", halign="right", vertical="top", hvertical="top",
													font = tweak_data.menu.pd2_small_font,
													w = scaled_size.width*0.66,
													layer = 2,
													} )

	self._bottom_text:set_right( self._bottom_text:parent():w() )
	--self._bottom_text:set_top( self._bottom_line:top() - 2 )
end

function MenuRenderer:set_bottom_text( id )
	if not alive( self._bottom_text ) then
		return
	end
	if not id then
		self._bottom_text:set_text( "" )
		return
	end
	self._bottom_text:set_text( utf8.to_upper( managers.localization:text( id ) ) )
	local _,_,_,h = self._bottom_text:text_rect() 
	self._bottom_text:set_h( h )
end

function MenuRenderer:close( ... )
	MenuRenderer.super.close( self, ... )
	managers.menu_component:close_newsfeed_gui()
	-- self:_close_newsfeed_gui()
	-- self:_close_chat_gui()
end

function MenuRenderer:_layout_menu_bg()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()
		
	-- self._menu_bg:set_size( safe_rect_pixels.height*2, safe_rect_pixels.height )
	-- self._menu_bg:set_position( 0, 0 )
		
	self:set_stencil_align( self._menu_stencil_align, self._menu_stencil_align_percent )

	--self:_create_blackborders()
end

   function MenuRenderer:_create_blackborders()
	if alive( self._blackborder_workspace ) then
		Overlay:gui():destroy_workspace( self._blackborder_workspace )
		self._blackborder_workspace = nil
	end

	Application:debug( "MenuRenderer: Creating blackborders" )
	self._blackborder_workspace = managers.gui_data:create_fullscreen_workspace()

	self._blackborder_workspace:panel():rect( { name = "top_border", layer = 1000, color = Color.black } )
	self._blackborder_workspace:panel():rect( { name = "bottom_border", layer = 1000, color = Color.black } )
	self._blackborder_workspace:panel():rect( { name = "left_border", layer = 1000, color = Color.black } )
	self._blackborder_workspace:panel():rect( { name = "right_border", layer = 1000, color = Color.black } )

	local top_border = self._blackborder_workspace:panel():child( "top_border" )
	local bottom_border = self._blackborder_workspace:panel():child( "bottom_border" )
	local left_border = self._blackborder_workspace:panel():child( "left_border" )
	local right_border = self._blackborder_workspace:panel():child( "right_border" )

	local width = self._blackborder_workspace:panel():w()
	local height = self._blackborder_workspace:panel():h()

	local border_w = ( width - 1280 ) / 2
	local border_h = ( height - 720 ) / 2

	top_border:set_position( -1, -1 )
	top_border:set_size( width + 2, border_h + 2 )
	top_border:set_visible( border_h > 0 )

	bottom_border:set_position( border_w - 1, math.ceil( border_h ) + 720 - 1 )
	bottom_border:set_size( width + 2, border_h + 2 )
	bottom_border:set_visible( border_h > 0 )

	left_border:set_position( -1, -1 )
	left_border:set_size( border_w + 2, height + 2 )
	left_border:set_visible( border_w > 0 )

	right_border:set_position( math.floor( border_w ) + 1280 - 1, -1 )
	right_border:set_size( border_w + 2, height + 2 )
	right_border:set_visible( border_w > 0 )
end

function MenuRenderer:update( t, dt )
	MenuRenderer.super.update( self, t, dt )
	-- self:update_newsfeed_gui( t, dt )
end

local mugshot_stencil = { 
				random 		= { "bg_lobby_fullteam", 65 }, 
				undecided	= { "bg_lobby_fullteam", 65 },
				american 	= { "bg_hoxton", 65 },
				german 		= { "bg_wolf", 55 },
				russian 	= { "bg_dallas", 65 },
				spanish	    = { "bg_chains", 60 },
			}

function MenuRenderer:highlight_item( item, ... )
	MenuRenderer.super.highlight_item( self, item, ... )
	
	if self:active_node_gui().name == "play_single_player" then
		local character = managers.network:session():local_peer():character()
		managers.menu:active_menu().renderer:set_stencil_image( mugshot_stencil[ character ][ 1 ] )
		managers.menu:active_menu().renderer:set_stencil_align( "manual", mugshot_stencil[ character ][ 2 ] )
	end
	
	-- self._sound_source:post_event( "menu_down" )
	self:post_event( "highlight" )
end

function MenuRenderer:trigger_item( item )
	MenuRenderer.super.trigger_item( self, item )
	
	if( item and item:visible() and item:parameters().sound ~= "false" ) then
		local item_type = item:type()
				
		if( item_type == "" ) then
			self:post_event( "menu_enter" )
			
		elseif( item_type == "toggle" ) then
			if item:value() == "on" then
				self:post_event( "box_tick" )
			else
				self:post_event( "box_untick" )
			end
		elseif( item_type == "slider" ) then
			local percentage = item:percentage()
			if( percentage > 0 and percentage < 100 ) then
				-- self._sound_source:post_event( "menu_value_decrease" )
			end
		elseif( item_type == "multi_choice" ) then
			
		end
	end
end

function MenuRenderer:post_event( event )
	self._sound_source:post_event( event )
end

function MenuRenderer:navigate_back()
	MenuRenderer.super.navigate_back( self )
	
	self:active_node_gui():update_item_icon_visibility()
	self:post_event( "menu_exit" )
end

function MenuRenderer:resolution_changed( ... )
	MenuRenderer.super.resolution_changed( self, ... )
	self:_layout_menu_bg()
	self:active_node_gui():update_item_icon_visibility()
end

function MenuRenderer:set_bg_visible( visible )
	-- self._menu_bg:set_visible( false and visible )
end

function MenuRenderer:set_bg_area( area )
--[[
	if( self._menu_bg ) then 
		if area == "full" then
			self._menu_bg:set_size( self._menu_bg:parent():size() )
			self._menu_bg:set_position( 0, 0 )
		elseif area == "half" then
			self._menu_bg:set_size( self._menu_bg:parent():w() * 0.5, self._menu_bg:parent():h() )
			self._menu_bg:set_top( 0 )
			self._menu_bg:set_right( self._menu_bg:parent():w() )
		else
			self._menu_bg:set_size( self._menu_bg:parent():size() )
			self._menu_bg:set_position( 0, 0 )
		end
	end]]
end

function MenuRenderer:set_stencil_image( image )
	if not self._menu_stencil then
		return
	end
	
	self._menu_stencil_image_name = image
	image = tweak_data.menu_themes[ managers.user:get_setting( "menu_theme" ) ][ image ]
	
	if self._menu_stencil_image == image then
		return
	end 
	self._menu_stencil_image = image or self._menu_stencil_default_image
	self._menu_stencil:set_image( self._menu_stencil_image )
	self:set_stencil_align( self._menu_stencil_align, self._menu_stencil_align_percent )
end

function MenuRenderer:refresh_theme()
	self:set_stencil_image( self._menu_stencil_image_name )
	--[[if self._menu_bg.set_image then
		self._menu_bg:set_image( tweak_data.menu_themes[ managers.user:get_setting( "menu_theme" ) ][ "background" ] )
	end]]
end

function MenuRenderer:set_stencil_align( align, percent )
	if not self._menu_stencil then
		return
	end
		
	self._menu_stencil_align = align
	self._menu_stencil_align_percent = percent
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size() -- managers.viewport:get_safe_rect_pixels()
	
	local y = (safe_rect_pixels.height - tweak_data.load_level.upper_saferect_border * 2) + 2
	local m = self._menu_stencil:texture_width()/self._menu_stencil:texture_height()
	self._menu_stencil:set_size( y * m, y )
	self._menu_stencil:set_center_y( res.y/2 )
	local w = self._menu_stencil:texture_width()
	local h = self._menu_stencil:texture_height()
	
	if align == "right" then
		-- self._menu_stencil:set_texture_rect( w, 0, -w, h )
		self._menu_stencil:set_texture_rect( 0, 0, w, h )
		self._menu_stencil:set_right( res.x )
	elseif align == "left" then
		self._menu_stencil:set_texture_rect( 0, 0, w, h )
		self._menu_stencil:set_left( 0 )
	elseif align == "center" then
		self._menu_stencil:set_texture_rect( 0, 0, w, h )
		self._menu_stencil:set_center_x( res.x / 2 )
	elseif align == "center-right" then
		self._menu_stencil:set_texture_rect( 0, 0, w, h )
		self._menu_stencil:set_center_x( res.x * 0.66 )
	elseif align == "center-left" then
		self._menu_stencil:set_texture_rect( 0, 0, w, h )
		self._menu_stencil:set_center_x( res.x * 0.33 )
	elseif align == "manual" then
		self._menu_stencil:set_texture_rect( 0, 0, w, h )
		percent = percent / 100
		self._menu_stencil:set_left( res.x * percent - (y * m) * percent )
	end
end

-- Creates a menu path text as topic for a menu node (if topic_id is provided, it will be appended as well, because the current node is not ready when creating) 
function MenuRenderer:current_menu_text( topic_id )	
	local ids = {}
	for i,node_gui in ipairs( self._node_gui_stack ) do
		table.insert( ids, node_gui.node:parameters().topic_id )
	end
	table.insert( ids, topic_id )
	
	local s = ""
	for i,id in ipairs( ids ) do
		s = s .. managers.localization:text( id )
		s = s .. ((i < #ids) and " > " or "" )
	end
	
	return s
end

-- Reported from MenuInput
function MenuRenderer:accept_input( accept )
	managers.menu_component:accept_input( accept )
end

function MenuRenderer:input_focus()
	--[[
	if something_something_darkside() then
		return true
	end
	]]
	if self:active_node_gui() and self:active_node_gui().input_focus then
		local input_focus = self:active_node_gui():input_focus()
		if input_focus then
			return input_focus
		end
	end
	
	return managers.menu_component:input_focus()
end

function MenuRenderer:mouse_pressed( o, button, x, y )
	if self:active_node_gui() and self:active_node_gui().mouse_pressed and self:active_node_gui():mouse_pressed( button, x, y ) then
		return true
	end
	
	if managers.menu_component:mouse_pressed( o, button, x, y ) then
		return true
	end
	
	if managers.menu_scene and managers.menu_scene:mouse_pressed( o, button, x, y ) then
		return true
	end
end

function MenuRenderer:mouse_released( o, button, x, y )
	if self:active_node_gui() and self:active_node_gui().mouse_released and self:active_node_gui():mouse_released( button, x, y ) then
		return true
	end
	
	if managers.menu_component:mouse_released( o, button, x, y ) then
		return true
	end
		
	if managers.menu_scene and managers.menu_scene:mouse_released( o, button, x, y ) then
		return true
	end
	
	return false
end

function MenuRenderer:mouse_clicked( o, button, x, y )
	if managers.menu_component:mouse_clicked( o, button, x, y ) then
		return true
	end
	
	return false
end

function MenuRenderer:mouse_double_click( o, button, x, y )
	if managers.menu_component:mouse_double_click( o, button, x, y ) then
		return true
	end
	
	return false
end

function MenuRenderer:mouse_moved( o, x, y )
	local wanted_pointer = "arrow"
	local used, pointer = managers.menu_component:mouse_moved( o, x, y )
	wanted_pointer = pointer or wanted_pointer
	if used then
		return true, wanted_pointer
	end
	
	if managers.menu_scene then
		local used, pointer = managers.menu_scene:mouse_moved( o, x, y )
		wanted_pointer = pointer or wanted_pointer
		if used then
			return true, wanted_pointer
		end
	end
	
	if self:active_node_gui() and self:active_node_gui().mouse_moved then
		local used, pointer = self:active_node_gui():mouse_moved( o, x, y )
		wanted_pointer = pointer or wanted_pointer
		if used then
			return true, wanted_pointer
		end
	end
	
	
	return false, wanted_pointer
end

function MenuRenderer:scroll_up()
	return managers.menu_component:scroll_up()
end

function MenuRenderer:scroll_down()
	return managers.menu_component:scroll_down()
end

function MenuRenderer:move_up()
	if self:active_node_gui() and self:active_node_gui().move_up and self:active_node_gui():move_up() then
		return true
	end
	return managers.menu_component:move_up()
end

function MenuRenderer:move_down()
	if self:active_node_gui() and self:active_node_gui().move_down and self:active_node_gui():move_down() then
		return true
	end
	return managers.menu_component:move_down()
end

function MenuRenderer:move_left()
	if self:active_node_gui() and self:active_node_gui().move_left and self:active_node_gui():move_left() then
		return true
	end
	return managers.menu_component:move_left()
end

function MenuRenderer:move_right()
	if self:active_node_gui() and self:active_node_gui().move_right and self:active_node_gui():move_right() then
		return true
	end
	return managers.menu_component:move_right()
end

function MenuRenderer:next_page()
	if self:active_node_gui() and self:active_node_gui().next_page and self:active_node_gui():next_page() then
		return true
	end
	return managers.menu_component:next_page()
end

function MenuRenderer:previous_page()
	if self:active_node_gui() and self:active_node_gui().previous_page and self:active_node_gui():previous_page() then
		return true
	end
	return managers.menu_component:previous_page()
end

function MenuRenderer:confirm_pressed()
	if self:active_node_gui() and self:active_node_gui().confirm_pressed and self:active_node_gui():confirm_pressed() then
		return true
	end
	return managers.menu_component:confirm_pressed()
end

function MenuRenderer:back_pressed()
	return managers.menu_component:back_pressed()
end

function MenuRenderer:special_btn_pressed( ... )
	return managers.menu_component:special_btn_pressed( ... )
end




function MenuRenderer:ws_test()
	if alive( self._test_safe ) then
		Overlay:gui():destroy_workspace( self._test_safe )
	end
	if alive( self._test_full ) then
		Overlay:gui():destroy_workspace( self._test_full )
	end
	self._test_safe = Overlay:gui():create_screen_workspace()
	managers.gui_data:layout_workspace( self._test_safe )
	
	self._test_full = Overlay:gui():create_screen_workspace()
	managers.gui_data:layout_fullscreen_workspace( self._test_full )
	
	local x = 150
	local y = 200
	local fx, fy = managers.gui_data:safe_to_full( x, y )
		
	-- local screen_x = 0
	--- local screen_y = 0
	
	local safe = self._test_safe:panel():rect( { x = x, y = y, h = 48, w = 48, layer = 0, orientation = "vertical", color = Color.green } )
	local full = self._test_full:panel():rect( { x = fx, y = fy, h = 48, w = 48, layer = 0, orientation = "vertical", color = Color.red } )
end

