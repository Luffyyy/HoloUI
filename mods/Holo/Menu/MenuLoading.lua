
local oinit = LevelLoadingScreenGuiScript.init
function LevelLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer)
	local file = io.open( "mods/saves/HoloSave.txt", "r" )
	self.holo_options = {}
	if file then
		self.holo_options = json.decode( file:read("*all") )
		file:close()
	end 
	if self.holo_options.Loading_enable == nil then
		self.holo_options.Loading_enable = true
	end
	if self.holo_options.Loading_enable then
		self._scene_gui = scene_gui
		self._res = res
		self._base_layer = base_layer
		self._level_tweak_data = arg.load_level_data.level_tweak_data
		self._gui_tweak_data = arg.load_level_data.gui_tweak_data
		self._menu_tweak_data = arg.load_level_data.menu_tweak_data
		self._scale_tweak_data = arg.load_level_data.scale_tweak_data
		self._coords = arg.load_level_data.controller_coords or false
		self._gui_data = arg.load_level_data.gui_data
		self._workspace_size = self._gui_data.workspace_size
		self._saferect_size = self._gui_data.saferect_size
		local challenges = arg.load_level_data.challenges
		local safe_rect_pixels = self._gui_data.safe_rect_pixels
		local safe_rect = self._gui_data.safe_rect
		local aspect_ratio = self._gui_data.aspect_ratio
		self._safe_rect_pixels = safe_rect_pixels
		self._safe_rect = safe_rect
		self._gui_data_manager = GuiDataManager:new(self._scene_gui, res, safe_rect_pixels, safe_rect, aspect_ratio)
		self._back_drop_gui = MenuBackdropGUI:new(nil, self._gui_data_manager, true)		
		local base_panel = self._back_drop_gui:get_new_base_layer()		
		local level_image = base_panel:bitmap({
			color = Color(0.1, 0.2, 0.5),
			layer = 0,
		})
		if Holo.options.colorbg_enable then
			self._back_drop_gui:enable_light(false)
			self._back_drop_gui._panel:child("base_layer"):child("bd_base_layer"):hide()
			self._back_drop_gui._panel:child("particles_layer"):hide()
		else
			self._back_drop_gui:set_pattern("guis/textures/loading/loading_foreground", 1)
			level_image:set_image(self._gui_data.bg_texture)
			level_image:set_color(Color.white)
		end


		local colors = {
			Color(0.2, 0.6 ,1 ),	  	 
			Color(0.2, 0.6 ,1 ),	  	 
			Color(1,0.6 ,0 ),
			Color(0, 1, 0.1),
			Color(1, 0.25, 0.7),		 
			Color(0, 0, 0), 		 
			Color(0.15, 0.15, 0.15), 
			Color(0.1, 0.1, 0.35), 	
			Color(1, 0.1, 0),
			Color(1, 0.8, 0.2),
			Color(1, 1, 1),
			Color(0, 1, 0.9),
			Color(0.5, 0, 1), 
			Color(0, 0.9, 0.5), 
			Color(0.6,0.8,0.85), 
			Color(1, 0, 0.2),
		    Color(0.5,82,45), 
			Color(0.7, 0.9, 0), 
		}

		local background_fullpanel = self._back_drop_gui:get_new_background_layer()
		local background_safepanel = self._back_drop_gui:get_new_background_layer()
		self._back_drop_gui:set_panel_to_saferect(background_safepanel)
		self._indicator = background_safepanel:bitmap({
			name = "indicator",
			texture = "guis/textures/pd2/skilltree/drillgui_icon_restarter",
			w = 32,
			h = 32,
			layer = 1,
		})		
		self._level_title_text = background_safepanel:text({
			text_id = "debug_loading_level",
			font = "fonts/font_large_mf",
			font_size = 42,
			align = "left",
			halign = "left",
			vertical = "bottom",
			layer = 1,
			h = 36
		})
		self._level_title_text:set_text(string.upper(self._level_title_text:text()))
		self._level_name_text = background_safepanel:text({
			y = 2,
			text = string.upper((self._level_tweak_data.name and self._level_tweak_data.name or "")),
			font = "fonts/font_large_mf",
			font_size = 42,
	        halign="grow",
	        valign="bottom",
			layer = 1,
			h = 42
		})		
		local brief_text = background_safepanel:text({
			y = 2,
			text_id = self._level_tweak_data.briefing_id,
			font = "fonts/font_large_mf",
			font_size = 16,
			align = "right",
	        halign="grow",
	        valign="bottom",
	        wrap = true,
			layer = 1,
			w = 500
		})
		local line = background_safepanel:bitmap({
			name = "line",
			h = 2,
			layer = 1,
		})					
		local _,_,w,h = self._level_name_text:text_rect()
		self._level_name_text:set_size(w,h)
		if self.holo_options.Holocolor then
			colors[1] = colors[math.min(self.holo_options.Holocolor + 1, #colors)]
			line:set_color(colors[math.min(self.holo_options.Holocolor + 1, #colors)])			
		end 
 		if self.holo_options.Menu_bgcolor and Holo.options.colorbg_enable then			
 			level_image:set_color(colors[self.holo_options.Menu_bgcolor])			
 		end
		local _, _, w2, h2 = self._level_title_text:text_rect()
		self._level_title_text:set_size(w2, h2)
		if w > w2 then
			line:set_w(w + 2)
		else
			line:set_w(w2 + 2)
		end
		self._level_title_text:set_lefttop(self._level_name_text:left(), self._level_name_text:bottom())
		self._indicator:set_leftbottom(self._level_title_text:right(), self._level_title_text:bottom() - 6)
		line:set_lefttop(self._level_title_text:left(), self._level_title_text:bottom())
		local _,_,_,h = brief_text:text_rect()
		brief_text:set_h(h)
		brief_text:set_righttop(background_safepanel:right() - 50, background_safepanel:top() - 20)
	else
		oinit(self, scene_gui, res, progress, base_layer)
	end
end

 