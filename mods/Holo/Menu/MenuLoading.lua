LevelLoadingScreenGuiScript = LevelLoadingScreenGuiScript or class()
function ColorRGB(r ,g, b) 
return Color(r/255 ,g/255 ,b/255)
end
function LevelLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer)
	local colors = {ColorRGB(0 ,150 ,255 ),ColorRGB(255,165 ,0 ),ColorRGB(0, 255, 20),ColorRGB(255, 105, 180),ColorRGB(60, 60, 60),ColorRGB(10, 30, 125),ColorRGB(250, 0, 0),ColorRGB(255, 200, 50),
	ColorRGB(255, 255, 255),ColorRGB(0, 255, 240),ColorRGB(150, 0, 255),ColorRGB(0, 250, 154),ColorRGB(173,216,230)}
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
		texture = "guis/textures/loading/loading_foreground",
		layer = 0,
		alpha = 1
	})
	level_image:set_color(colors[math.random(1,6)])
	level_image:set_size(level_image:parent():h() * (level_image:texture_width() / level_image:texture_height()), level_image:parent():h())
	level_image:set_position(0, 0)

	local background_fullpanel = self._back_drop_gui:get_new_background_layer()
	local background_safepanel = self._back_drop_gui:get_new_background_layer()
	self._back_drop_gui:set_panel_to_saferect(background_safepanel)
	self._indicator = background_safepanel:bitmap({
		name = "indicator",
		texture = "guis/textures/icon_loading",
		layer = 1,
	})
	self._level_title_text = background_safepanel:text({
		text_id = "debug_loading_level",
		font = "fonts/font_large_mf",
		font_size = 42,
		color = Color.white,
		align = "left",
		halign = "left",
		vertical = "bottom",
		layer = 1,
		h = 36
	})
		self._level_name_text = background_safepanel:text({
		y = 2,
		text = string.upper((self._level_tweak_data.name and self._level_tweak_data.name or "")),
		font = "fonts/font_large_mf",
		font_size = 42,
		color = Color.white,
        halign="grow",
        valign="bottom",
		layer = 1,
		h = 42
	})
		local _,_,level_name,_ = self._level_name_text:text_rect()
		self._level_name_text:set_w(level_name + 10)
		self._levelBG = background_safepanel:bitmap({
		name = "levelBG",
        color = ColorRGB(0, 130, 200),
 		layer = 0,
        align = "left",
		halign = "left",
		vertical = "bottom",
        h = 40, 
        w = self._level_name_text:w(),
        x = -5
	})

    	self._loadingBG = background_safepanel:bitmap({
		name = "loadingBG",
        color = ColorRGB(0, 130, 200),
 		layer = 0,
        align = "left",
		halign = "left",
        h = 40, 
        w = 170
	})
        self._line = background_safepanel:bitmap({
		name = "line",
        color = ColorRGB(200, 200, 200),
 		layer = 0,
        align = "right",
		halign = "bottom",
        h = 3, 
        w = self._loadingBG:w()
	})     
	    self._line2 = background_safepanel:bitmap({
		name = "line2",
        color = ColorRGB(200, 200, 200),
 		layer = 0,
        align = "right",
		halign = "bottom",
        h = 3, 
        w = self._levelBG:w()
	})         
	self._level_title_text:set_text(utf8.to_upper(self._level_title_text:text()))
	local _, _, w, h = self._level_title_text:text_rect()
	self._level_title_text:set_size(w, h)
	self._indicator:set_bottom(self._levelBG:bottom() + 40)
	self._loadingBG:set_bottom(self._levelBG:bottom() + 43)
	self._level_title_text:set_bottom(self._levelBG:bottom() + 46)

	self._indicator:set_right(self._levelBG:right() + 40)
	
	self._level_title_text:set_right(self._indicator:left() - 10)
    self._loadingBG:set_right(self._indicator:left() + 40)
    self._line:set_center(self._loadingBG:center())
    self._line:set_bottom(self._loadingBG:bottom())
    self._line2:set_center(self._levelBG:center())
    self._line2:set_bottom(self._levelBG:bottom())
end

function LevelLoadingScreenGuiScript:update(progress, t, dt)
	self._indicator:rotate(180 * dt)
end
