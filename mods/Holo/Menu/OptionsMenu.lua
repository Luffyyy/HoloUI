Holomenu = Holomenu or class()
Holomenu._allcolors = {}

function Holomenu:init()
	local ws = managers.gui_data:create_fullscreen_workspace()
	self._fullscreen_ws = ws
    self._fullscreen_ws_pnl = ws:panel() 
    ws:connect_keyboard(Input:keyboard())  
    ws:connect_mouse(Input:mouse())  
    self._options_row_max = 20
    self._options = {}
    self._pages = {}
    self._menu_panel = self._fullscreen_ws_pnl:panel({
        name = "menu_panel",
        halign = "center", 
        align = "center",
        layer = 1000,
        w = self._fullscreen_ws_pnl:w() / 1.45,
        alpha = 0
    })  
    self._menu_panel:rect({
      	name = "menu_bg", 
      	halign="grow", 
      	valign="grow", 
      	alpha = 0.8, 
        color = Color.black, 
        layer = 19 
    })  
    self._menu_line = self._menu_panel:bitmap({
		name = "line",
		y = -2,
		w = 6,
	    color = Holomenu_color_marker,
		layer = 30
	})  
	self._help_panel = self._menu_panel:panel({
        name = "help_panel",
        x = 30,
	    y = 10,
	    w = self._menu_panel:w() - 100,
        layer = 20,
     })   
    self._help_panel:rect()
    self._help_panel:rect({
    	name = "line",
    	w = 2,
    	color = Holomenu_color_marker,
    })
	self._help_text = self._help_panel:text({
	    name = "help_text",
	    text = "",
	    layer = 1,
	    wrap = true,
	    x = 4,
	    word_wrap = true,
	    valign = "left",
	    align = "left",
	    vertical = "top",	    
	    color = Color.black,
	    font = "fonts/font_large_mf",
	    font_size = 16
	})  
	local _,_,w,h = self._help_text:text_rect()
	self._help_panel:set_size(w + 10,h)
	for k, v in pairs(Holo.colors) do
		Holomenu._allcolors[v.menu_name] = v.color
	end
	self._menu_line:set_right(self._menu_panel:right())
    self._times = 1
    self._menu_closed = true
    self:CreateItems()
    self._fullscreen_ws_pnl:key_press(callback(self, self, "key_press"))    
end

function Holomenu:HideOptions()
	self._menu_panel:set_alpha(0)
	self._menu_closed = true
	if managers.hud then
     	 managers.hud._chatinput_changed_callback_handler:dispatch(false)
    end
	managers.mouse_pointer:remove_mouse(self._mouse_id)
end
function Holomenu:ShowOptions()
	self._menu_panel:set_alpha(1)
	self._menu_closed = false
	managers.mouse_pointer:use_mouse({
		mouse_move = callback(self, self, "mouse_moved"),
		mouse_press = callback(self, self, "mouse_pressed"),
		mouse_release = callback(self, self, "mouse_release"),
		id = self._mouse_id
	}) 	
	if managers.hud then
		 managers.hud._chatinput_changed_callback_handler:dispatch(true)
	end
end
function Holomenu:update()
 	for _,item in pairs(self._options) do
    	if item.highlight then
        	item.panel:child("bg"):set_color(Holomenu_color_marker)
        end
        if item.type == "slider" then
        	local color = Holomenu_color_marker / 1.2
        end
        if item.type == "combo" and item.items[item.value] == "Holocolor_title" then
        	item.panel:child("color_preview"):set_color(HoloColor)
        end	
    end       
    self._allcolors["Holocolor_title"] = HoloColor
    self._menu_line:set_color(Holomenu_color_marker)
   	self._help_panel:child("line"):set_color(Holomenu_color_marker)
end
function Holomenu:CreateColorOption(config)
   if config.color then 
      	self:CreateItem({
	        name = config.name .. "_color",
	        text = managers.localization:text(config.name.."_title") .. managers.localization:text("color_option_title"),
	        help = config.help or managers.localization:text("color_option_desc") .. string.lower(managers.localization:text(config.name.."_title")),
	        callback = config.callback or nil,
	        items = HoloColors,
	        color_preview = true,
	        localize = false,
	        page = config.page or "coloroptions",
	        type = "combo"  
    	}) 
    end
    if config.text then 
        self:CreateItem({
	        name = config.name .. "_text_color",
	        text = managers.localization:text(config.name.."_title") .. managers.localization:text("textcolor_option_title"),
	        help = config.help or managers.localization:text("textcolor_option_desc") .. string.lower(managers.localization:text(config.name.."_title")),
	        callback = config.callback or nil,
	        color_preview = true,
		    localize = false,        
	        items = HoloColors ,
	        page = config.page or "textcoloroptions",
	        type = "combo"  
    	})    
    end    
end
function Holomenu:key_press( o, button, x, y )
	if not self._mouse_id then
		self._mouse_id = managers.mouse_pointer:get_id() 
	end
	local optionskey = 	_G.LuaModManager:GetPlayerKeybind("holo_options_key") or "f3"
	if self._menu_closed and button == Idstring(optionskey) then
		self:ShowOptions()
	elseif not self._menu_closed and (button == Idstring(optionskey) or button == Idstring("esc")) then
		self:HideOptions()
		if self._openlist then
		 	self._menu_panel:child(self._openlist.name .. "list"):set_visible(false)
		 	self._openlist = nil
		 	return
		end			
	end
	if self._page and not self._menu_closed then
		for _, item in pairs(self._page.children) do
			if item.type ~= "page" and item.highlight then
				if button == Idstring("enter") then
					if item.callback and item.type ~= "slider" and item.type ~= "combo" then
						if item.type == "toggle" then
							item.value = not item.value
						end	
						Holomenu[item.callback](self, item)
						managers.menu_component:post_event("menu_enter")
						Holomenu:set_value(item, item.value)
					elseif item.type == "combo" then
						 local combo_list = self._menu_panel:child(item.name .. "list")
						 if not self._openlist then
						 	combo_list:set_visible(true)
						 	self._openlist = item
						 	return
						 end
						 if self._openlist then
						 	self._menu_panel:child(self._openlist.name .. "list"):set_visible(false)
						 	self._openlist = nil
						 	return
						 end				 
					end
				end
			end
		end
	end
end
function Holomenu:mouse_moved( o, x, y )
	if self._line_hold and self._old_x then
		self._menu_panel:grow(x - self._old_x)
		self._menu_line:set_right(self._menu_panel:right())
	end
	if self._slider_hold and self._old_x then
		local slider_bg = self._slider_hold.panel:child("slider_bg")
		local where = (x - slider_bg:world_left()) / (slider_bg:world_right() - slider_bg:world_left())
		self._slider_hold.value = tonumber(math.clamp(where * self._slider_hold.max, self._slider_hold.min, self._slider_hold.max))
      	Holomenu[self._slider_hold.callback](self, self._slider_hold)
      	Holomenu:set_value(self._slider_hold, self._slider_hold.value)
    end
  	if self._openlist then
  	 	for k, v in pairs(self._openlist.items) do
      	 	local combo_list = self._menu_panel:child(self._openlist.name .. "list") 
      	 	if combo_list:child("bg"..k):inside(x,y) then 		
      	 		combo_list:child("bg"..k):set_color(Holomenu_color_marker)
      	 	else
				combo_list:child("bg"..k):set_color(Color.white)
      	 	end
  	 	end
  	end
    for _,item in pairs(self._options) do
      	if item.type == "page" or item.type == "backbutton" then
      		if (not item.page and self._pages[item.index] and not self._pages[item.index].visible) or item.type == "backbutton" then
      			if item.panel:inside(x,y) then
	        		item.panel:child("bg"):set_color(Holomenu_color_marker) 
	        		item.highlight = true  
	        		self:set_help(item.localize and managers.localization:text(item.help) or item.help)
	        	else
		        	item.panel:child("bg"):set_color(Color.white)  
		        	item.highlight = false	   	        		
	        	end
        	end
        end
   	end
   	for _, item in pairs(self._page.children) do
   		if not self._openlist and not self._slider_hold and not self._line_hold then
		    if item.panel:inside(x, y) then
			    item.panel:child("bg"):set_color(Holomenu_color_marker)
				item.panel:child("text"):set_color(Color.black)	    
			    self:set_help(item.localize and managers.localization:text(item.help) or item.help)
			    item.highlight = true
			    if item.type == "toggle" then
			    	item.panel:child("toggle"):set_color(Color.black)
			    end
		    else 
		    	item.panel:child("bg"):set_color(Color.white:with_alpha(0))
		 	  	item.panel:child("text"):set_color(Color.white)   	
		        item.highlight = false
			    if item.type == "toggle" then
			    	item.panel:child("toggle"):set_color(Color.white)
			    end        
		    end
		end
   	end
   	self._old_x = x
end

function Holomenu:set_help(help)
	self._help_text:set_text(help)
	local _,_,w,h = self._help_text:text_rect()
	self._help_panel:set_size(w + 10,h)
 
end
function Holomenu:mouse_release( o, button, x, y )
	if self._slider_hold then
		self._slider_hold = nil
	end
	if self._line_hold then
		self._line_hold = false
	end
end
function Holomenu:mouse_pressed( o, button, x, y )
	if self._menu_line:inside(x,y) then
		self._line_hold = true
	else
		self._line_hold = false
	end
	if self._openlist and button == Idstring("0") and self._menu_panel:child(self._openlist.name .. "list"):inside(x,y) then
	 	for k, v in pairs(self._openlist.items) do
	 		if self._openlist and self._menu_panel:child(self._openlist.name .. "list"):child("item"..k):inside(x,y) then
	 			self._openlist.value = k
				Holomenu[self._openlist.callback](self, self._openlist)
				managers.menu_component:post_event("menu_enter")
				Holomenu:set_value(self._openlist, self._openlist.value)

	 			self._menu_panel:child(self._openlist.name .. "list"):set_visible(false)
	 	 		self._openlist = nil
	 	 		return
	 		end
		end 	
	elseif self._openlist and button == Idstring("0") then
			self._menu_panel:child(self._openlist.name .. "list"):set_visible(false)
			self._openlist = nil
			return
	end
	for _, item in pairs(self._options) do
		if button == Idstring("0") then
			if item.type == "backbutton" and item.panel:inside(x,y) then	
				Holomenu[item.callback](self, item)
				managers.menu_component:post_event("menu_exit")
				if self._openlist then
					self._menu_panel:child(self._openlist.name .. "list"):set_visible(false)
					self._openlist = nil
				end	
			end					
			if item.type == "page" and item.panel:inside(x,y) then						
				for _,child in pairs(self._pages[item.index].children) do
					child.panel:set_visible(true)
				end
				managers.menu_component:post_event("menu_enter")
				if self._openlist then
				 	self._menu_panel:child(self._openlist.name .. "list"):set_visible(false)
				 	self._openlist = nil
				end	
				item.visible = true
				self._page = self._pages[item.index]

				item.panel:child("bg"):set_color(Holomenu_color_marker)
				for index,page in pairs(self._pages) do					
					if page ~= self._pages[item.index] then
						for _,child in pairs(page.children) do
							if child.name ~= "backbutton" then
								child.panel:set_visible(false)
							end
						end
						self._pages[index].panel:child("bg"):set_color(Color.white)
						page.visible = false
					end
				end		
			end
		end
	end
	for _, item in pairs(self._page.children) do
		if button == Idstring("0") and item.panel:inside(x,y) then	 
			if item.callback and item.type ~= "slider" and item.type ~= "combo" then
				if item.type == "toggle" then
					item.value = not item.value
				end	
				self[item.callback](self, item)
				managers.menu_component:post_event("menu_enter")
				self:set_value(item, item.value)
			elseif item.type == "slider" then
				if item.panel:child("slider_icon"):inside(x,y) then		
					self._slider_hold = item
					return
				elseif item.panel:child("slider_bg"):inside(x,y) or item.panel:child("slider"):inside(x,y) then
					local slider_bg = item.panel:child("slider_bg")
					local where = (x - slider_bg:world_left()) / (slider_bg:world_right() - slider_bg:world_left())
					item.value = tonumber(math.clamp(where * item.max, item.min, item.max))
					self[item.callback](self, item)
					managers.menu_component:post_event("menu_enter")
					self:set_value(item, item.value)
					self._slider_hold = item
					return
				end
			elseif item.type == "combo" then
				local combo_list = self._menu_panel:child(item.name .. "list")
				if not self._openlist and item.panel:inside(x,y) then
				 	combo_list:set_visible(true)
				 	self._openlist = item
				 	return
				end		 
			end
		elseif button == Idstring("mouse wheel up") and item.type == "combo" then
			if not self._openlist and item.panel:inside(x,y) then
				if (item.value - 1) ~= 0 then
					item.value = item.value - 1
					self[item.callback](self, item)	
					managers.menu_component:post_event("menu_enter")
					self:set_value(item, item.value)
					return
				end
			end
		elseif button == Idstring("mouse wheel down") and item.type == "combo" then
			if not self._openlist and item.panel:inside(x,y) then
				if (item.value + 1) < (#item.items + 1) then
					item.value = item.value + 1
					self[item.callback](self, item)	
					managers.menu_component:post_event("menu_enter")
					self:set_value(item, item.value)
					return
				end
			end			
		end
	end
end
 

function Holomenu:set_value(item, value)
	if item.type == "toggle" then
		if value == true then
			item.panel:child("toggle"):set_texture_rect(24,0,24,24)
		else
			item.panel:child("toggle"):set_texture_rect(0,0,24,24)			
		end
	elseif item.type == "slider" then
		local slider = item.panel:child("slider")
		local slider_value = item.panel:child("slider_value")
		local slider_icon = item.panel:child("slider_icon")
		slider:set_w(180 * (value / item.max))
		slider_icon:set_right(slider:right())
		slider_value:set_text(string.format("%.2f", value))
 	elseif item.type == "combo" then
		item.panel:child("combo_selected"):set_text(item.localize_items and managers.localization:text(item.items[value]) or item.items[value])
		if self._allcolors[item.items[value]] then
			item.panel:child("color_preview"):set_color(self._allcolors[item.items[value]])
		else
			item.panel:child("color_preview"):set_visible(false)
		end
	end
end 
function Holomenu:CreateItem( config )    
	local item_panel = self._menu_panel:panel({ 
		name = config.name,
      	y = 80, 
      	x = 30,
      	w = 390, 
      	visible = not config.page or self._first_page == self._pages[self._options[config.page].index],
      	h = 24,
      	layer = 21,
    })    
    local marker = item_panel:rect({
      	name = "bg", 
      	color = Color.white:with_alpha(config.page and 0 or 1),
      	halign="grow", 
      	valign="grow", 
        layer = -1 
    })
    config.localize = config.localize == nil and true or config.localize 
    if config.localize then
	    config.text = config.text or config.name.."_title"
	    config.help = config.help or config.name.."_desc"
	end	 
 
    local item_text = item_panel:text({
	    name = "text",
	    text = config.localize and managers.localization:text(config.text) or config.text,
	    vertical = "center",
	    align = config.page and "left" or "center",
	    x = 2,
	    layer = 6,
	    color = config.page and Color.white or Color.black,
	    font = "fonts/font_medium_mf",
	    font_size = config.page and 16 or 18
	})  	
	local _,_,w,h = item_text:text_rect()
	item_text:set_w(w)
    config.panel = item_panel  
    config.option = config.option or config.name
    if config.type == "toggle" then
    	config.value = Holo.options[config.option] or false
    else
    	config.value = Holo.options[config.option] or 1
    end
    self._options[config.name] = config
    if config.page then
		if config.type == "toggle" then
			config.callback = config.callback or "toggleclbk"
		elseif config.type ~= "button" then
			config.callback = config.callback or "valueclbk"
		end
		local page = self._options[config.page].index
	    if not self._pages[page].children then
	        self._pages[page].children[1] = config
	    else
	        self._pages[page].children[#self._pages[page].children + 1] = config
	    end
	    config.index = #self._pages[page].children
	   	if config.index >= self._options_row_max then
	    	item_panel:set_x(450)
	    end
	   	if config.index ~= self._options_row_max and config.index ~= 1 then
	    	item_panel:set_top(self._pages[page].children[config.index - 1].panel:bottom() + 4)
	    end
	end	       
	if config.type == "page" then    
		item_panel:set_y(45)
 	    item_panel:set_w(135)
 	    config.visible = true
 	    config.children = {}
 	    item_text:set_w(135)
	    if not self._first_page then
	    	self._pages[1] = config
	    	config.index = 1
	    	self._first_page = config
	    	marker:set_color(Holomenu_color_marker)   
	    	self._page = config
	    else
	    	self._pages[#self._pages + 1] = config
	    	config.index = #self._pages
	    	item_panel:set_left(self._pages[#self._pages - 1].panel:right() + 2)
	    	self._pages[config.index].visible = false
	    end
	elseif config.type == "backbutton" then
		config.index = #self._pages
		item_panel:set_left(self._pages[#self._pages].panel:right() + 2)
		item_panel:set_y(45)
 	    item_panel:set_w(120) 
	    item_text:set_w(120)
	elseif config.type == "toggle" and config.page then 
	    local toggle = item_panel:bitmap({
	        name = "toggle",
	        x = 2,
	        w = item_panel:h() -2,
	        h = item_panel:h() -2,
	        layer = 6,
	        color = Color.white,
	        texture = "guis/textures/menu_tickbox",
	        texture_rect = config.value and {24,0,24,24} or {0,0,24,24}
	    })  
	    toggle:set_world_right(item_panel:right() - 4)
	elseif config.type == "combo" and config.page then 
		config.localize_items = config.localize_items == nil and true or config.localize_items
	    local combo_selected = item_panel:text({
		    name = "combo_selected",
		    text = config.localize_items and managers.localization:text(config.items[config.value]) or config.items[config.value],
		    valign = "center",
		    align = "center",
		    vertical = "center",
		    w = item_panel:w(),
		    h = item_panel:h(),
		    x = 2,
		    layer = 6,
		    color = Color.black,
		    font = "fonts/font_large_mf",
		    font_size = 16
		}) 			    
		local list_icon = item_panel:text({
		    name = "list_icon",
		    text = "^",
		    rotation = 180,
		    valign = "right",
		    align = "right",
		    vertical = "center",
		    w = 18,
		    h = 18,
		    x = 2,
		    layer = 6,
		    color = Color.black,
		    font = "fonts/font_large_mf",
		    font_size = 16
		}) 		
		local combo_bg = item_panel:bitmap({
	        name = "combo_bg",
	        y = 4,
	        w = 180,
	        h = 16,
	        layer = 5,
	        color = Color(0.8, 0.8, 0.8),
	    })	
	    combo_bg:set_world_right(item_panel:right() - 4)
	    combo_selected:set_center(combo_bg:center())
	    local color = self._allcolors[config.items[config.value]] and self._allcolors[config.items[config.value]] or Color.white
	    local color_preview = item_panel:bitmap({
	        name = "color_preview",
	        valign = "center",
	        align = "center",
	        vertical = "center",
	        visible = config.color_preview == true,
	        x = 2,
	        y = 6,
	        w = 12,
	        h = 12,
	        layer = 5,
	        color = color,
	    })		
		local combo_list = self._menu_panel:panel({
			name = config.name.."list",
	      	y = 0, 
	      	w = 120, 
	      	h = #config.items * 18,
	      	layer = 40,
	      	visible = false,
	      	halign = "left", 
	      	align = "left"
	    })    
	    combo_list:rect({
	      	name = "bg", 
	      	halign="grow", 
	      	valign="grow", 
	      	blend_mode = "normal", 
	      	alpha = 1, 
	        color = Color.white, 
	        layer = -1 
	    })   
	    if config.index < 12 then
	    	combo_list:set_lefttop(combo_bg:world_left(), combo_bg:world_bottom() + 4)
		else
	    	combo_list:set_leftbottom(combo_bg:world_left(), combo_bg:world_top() - 4)			
		end
	    color_preview:set_left(combo_bg:left() + 2)
	    list_icon:set_left(combo_bg:right() - 12)
	    for k, text in pairs(config.items) do
	    	local combo_item = combo_list:text({
			    name = "item"..k,
			    text = config.localize_items and managers.localization:text(text) or text,
			    align = "center",
			    w = combo_list:w(),
			    h = 18,
			    y = 18 * (k - 1),
			    layer = 6,
			    color = Color.black,
			    font = "fonts/font_large_mf",
			    font_size = 16
			}) 
			local combo_item_bg = combo_list:bitmap({
			    name = "bg"..k,
			    align = "center",
			    w = combo_list:w(),
			    h = 18,
			    y = 18 * (k - 1),
			    layer = 5,
			    color = Color.white,
			}) 							
	    end
	elseif config.type == "slider" and config.page then 
		local slider_value = item_panel:text({
		    name = "slider_value",
		    text = tostring(string.format("%.2f", config.value)),
		    valign = "center",
		    align = "center",
		    vertical = "center",
		    w = item_panel:w(),
		    h = item_panel:h(),
		    x = 2,
		    layer = 8,
		    color = Color.black,
		    font = "fonts/font_large_mf",
		    font_size = 16
		}) 	
		local slider_bg = item_panel:bitmap({
	        name = "slider_bg",
	        y = 4,
	        w = 180,
	        h = 16,
	        layer = 5,
	        color = Color(0.8, 0.8, 0.8),
	    })			
	    local slider = item_panel:bitmap({
	        name = "slider",
	        y = 4,
	        w = 180 * (config.value / config.max),
	        h = 16,
	        layer = 6,
	        alpha = 0.5,
	        color = Holomenu_color_marker / 1.4
	    })			    
	    local slider_icon = item_panel:bitmap({
	        name = "slider_icon",
	        w = 4,
	        layer = 7,
	        color = Color(0.4, 0.4, 0.4)
	    })	
	    slider_bg:set_world_right(item_panel:right() - 4)
	    slider:set_left(slider_bg:left())
	    slider_value:set_center(slider_bg:center())
	    slider_icon:set_right(slider:right())
	end
end

function Holomenu:Item( name )  
	for _,item in pairs(self._options) do
		if item.name == name then
			return item
		end
	end
end  
function Holomenu:reset(item, value)
	if item and item.type ~= "button" then
		item.value = value
		Holomenu[item.callback](self, item)
		Holomenu:set_value(item, item.value)
		Holo:Save()
	end
end

function Holomenu:CreateItems()
    self:CreateItem({
        name = "mainoptions",
        text = "Holomainoptions_title",
        help = "Holomainoptions_desc",
        type = "page"  
    })            
    self:CreateItem({
        name = "menuoptions",
        type = "page"  
    })         
    self:CreateItem({
        name = "coloroptions",
        type = "page"  
    })      
    self:CreateItem({
        name = "textcoloroptions",
        type = "page"  
    })         
    self:CreateItem({
        name = "infohudoptions",
        type = "page"  
    }) 
   	self:CreatemainoptionsOptions()
    self:CreateInfoOptions()
 	self:CreateMenuOptions()
 	local HoloColorTable = {}
 	for k, v in pairs(HoloColors) do
 		if k ~= 1 then
 			table.insert(HoloColorTable, v)
 		end
 	end
    self:CreateItem({
        name = "Holocolor",
        color_preview = true,
        items = HoloColorTable,
        page = "coloroptions",
        type = "combo"  
    })    
	self:CreateColorOption({
	    name = "assaultbox",
		value = 10,
		textvalue = 2,
	    color = true,  
	    text = true
	})
	self:CreateColorOption({
	    name = "casingbox",
	    color = true,  
	    text = true
	})
	self:CreateColorOption({
	    name = "noreturnbox",
	    value = 9,
	    color = true,  
	    text = true
	})
	self:CreateColorOption({
	    name = "hostagebox",
	    color = true,  
	    text = true,
	    textvalue = 2
	})
	self:CreateColorOption({
	    name = "objectivebox",
	    color = true,  
	    text = true
	})
	self:CreateColorOption({  
	    name = "objremindbox",
	    color = true,  
	    text = true
	})
	self:CreateColorOption({ 
	    name = "hintbox",
	    color = true,  
	    text = true,
	    textvalue = 2
	})
	self:CreateColorOption({ 
	    name = "carrybox",
	    color = true,  
	    text = true
	})
	self:CreateColorOption({
	    name = "timerbox",
	    color = true,  
	    text = true
	})
	self:CreateColorOption({
	    name = "boxframe",
	    value = 11,
	    color = true,  
	})
	self:CreateColorOption({
	    name = "selectwep",
	    color = true,  
	})
	self:CreateColorOption({
	    name = "equipments",
	    value = 11,
	    color = true,  
	})
	self:CreateColorOption({
	    name = "pickups",
	    color = true,  
	})	
	self:CreateColorOption({
	    name = "StaminaNum",
	    textvalue = 11,
	    text = true,  
	})	
	self:CreateColorOption({
	    name = "StaminaNum_negative",
	    textvalue = 9,
	    text = true,  
	})
	self:CreateColorOption({
	    name = "HealthNum",
	    text = true,  
	})
	self:CreateColorOption({
	    name = "HealthNum_negative",
	    textvalue = 11,
	    text = true,  
	})  
	self:CreateColorOption({
	    name = "teammatebg",
	    color = true,  
	})		   	
	self:CreateColorOption({
	    name = "teammate",
	    callback = "teammate_text",
	    text = true,  
	})		   	
	self:CreateColorOption({
	    name = "Waypoint",
	    color = true,  
	})		       
    self:CreateItem({
        name = "backbutton",
        callback = "backcallback", 
        type = "backbutton"  
    })         
    self:CreateItem({
        name = "Health_Color",
        callback = "Health_Color",
        items = HoloRadialColors,
        color_preview = true,
        page = "coloroptions",
        type = "combo"  
    })     
    self:CreateItem({
        name = "Shield_Color",
        callback = "Shield_Color",
        items = HoloRadialColors,
        color_preview = true,
        page = "coloroptions",
        type = "combo"  
    })     
    self:CreateItem({
        name = "Progress_active_color",
        text = "Progress_active_title",
        callback = "Progress_active_color",
        items = HoloRadialColors,
        color_preview = true,
        page = "coloroptions",
        type = "combo"  
    })     
    self:CreateItem({
        name = "Progress_invalid_color",
        text = "Progress_invalid_title",
        callback = "Progress_invalid_color",
        items = HoloRadialColors,
        color_preview = true,
        page = "coloroptions",
        type = "combo"  
    })         
    self:CreateItem({
        name = "resetall",
        text = "Holoresetall_title",
        help = "Holoresetall_desc",
        page = "mainoptions",
        callback = "resetall", 
        type = "button"  
    })        
    self:CreateItem({
        name = "resetcolors",
        page = "coloroptions",
        callback = "resetcolors", 
        type = "button"  
    })           
    self:CreateItem({
        name = "resettextcolors",
        page = "textcoloroptions",
        callback = "resettextcolors", 
        type = "button"  
    })       
 end
function Holomenu:CreateMenuOptions()
	self:CreateItem({
        name = "Menu_enable",
        callback = "enablemenu",
        page = "menuoptions",
        type = "toggle"  
    }) 
    self:CreateItem({
        name = "Holomenu_lobby",
        page = "menuoptions",
        type = "toggle"  
    })      
    self:CreateItem({
        name = "Holomenu_crimenet",
        page = "menuoptions",
        type = "toggle"  
    })  
    self:CreateItem({
        name = "Loading_enable",
        page = "menuoptions",
        type = "toggle"  
    })        
    self:CreateItem({
        name = "colorbg_enable",
        page = "menuoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "Menu_color",
        page = "menuoptions",
       	color_preview = true,
	    items = HoloColors,
        type = "combo"  
    })        
    self:CreateItem({
        name = "Menu_highlight_color",
        page = "menuoptions",
       	color_preview = true,
	    items = HoloColors,
        type = "combo"  
    })    	    
    self:CreateItem({
        name = "Menu_bgcolor",
        page = "menuoptions",
       	color_preview = true,
	    items = HoloColors,
        type = "combo"  
    })    	
    self:CreateItem({
	    name = "Menu_tabcolor",
	    color_preview = true,
	    items = HoloColors,
	   	page = "menuoptions",
	    type = "combo"  
    })      
    self:CreateItem({
	    name = "Menu_highlight_tabcolor",
	    color_preview = true,
	    items = HoloColors,
	   	page = "menuoptions",
	    type = "combo"  
    })      
    self:CreateItem({
	    name = "Menu_tab_textcolor",
	    color_preview = true,
	    items = HoloColors,
	   	page = "menuoptions",
	    type = "combo"  
    })        
    self:CreateItem({
	    name = "Menu_markercolor",
	    color_preview = true,
	    items = HoloColors,
	   	page = "menuoptions",
	    type = "combo"  
    })        
    self:CreateItem({
	    name = "Menu_textsize",
	    items = HoloMenuTextSizes,
	   	page = "menuoptions",
	    type = "combo"  
    })        
    self:CreateItem({
	    name = "Menu_markeralpha",
	    color_preview = true,
	   	page = "menuoptions",
	   	max = 1,
	   	min = 0,
	    type = "slider"  
    })        
    self:CreateItem({
	    name = "resetmenu",
	   	page = "menuoptions",
	   	callback = "resetmenu",
	    type = "button"  
    })    

end
function Holomenu:CreatemainoptionsOptions()   
	self:CreateItem({
        name = "Holo_lang",
        items = {"English", "Русский"},
        localize_items = false,
        page = "mainoptions",
        type = "combo"  
    })   
   self:CreateItem({
        name = "hudbox_enable",
        page = "mainoptions",
        type = "toggle"  
    })     
    self:CreateItem({
        name = "stamina_enable",
        page = "mainoptions",
        type = "toggle"  
    })   
    self:CreateItem({
        name = "HealthNum",
        page = "mainoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "HealthNumTM",
        page = "mainoptions",
        type = "toggle"  
    })   
    self:CreateItem({
        name = "Timerbg_enable",
        page = "mainoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "Frame_enable",
        page = "mainoptions",
        type = "toggle"  
    })        
    self:CreateItem({
        name = "assaultbox_enable",
        page = "mainoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "flashing_enable",
        page = "mainoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "totalammo_enable",
        page = "mainoptions",
        type = "toggle"  
    }) 
    self:CreateItem({
        name = "voice_enable",
        page = "mainoptions",
        type = "toggle"  
    })            
    self:CreateItem({
        name = "chat_enable",
        page = "mainoptions",
        type = "toggle"  
    })      
    self:CreateItem({
        name = "waypoints_enable",
        page = "mainoptions",
        type = "toggle"  
    })           
    self:CreateItem({
        name = "MainAlpha",
        page = "mainoptions",
        min = 0,
        max = 1,
        type = "slider"  
    })      
    self:CreateItem({
        name = "waypoints_alpha",
        page = "mainoptions",
        min = 0,
        max = 1,
        type = "slider"  
    })       
    self:CreateItem({
        name = "teammatebg_alpha",
        page = "mainoptions",
        min = 0,
        max = 1,
        type = "slider"  
    })   
    self:CreateItem({
        name = "Frame_style",
        page = "mainoptions",
        items = HoloFrameStyles,
        type = "combo"  
    })     
 
end
function Holomenu:CreateInfoOptions()
   self:CreateItem({
        name = "Infohud_enable",
        page = "infohudoptions",
        type = "toggle"  
    })    
   self:CreateItem({
        name = "Infotimer_text_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })          
    self:CreateItem({
        name = "Infobox_text_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })              
    self:CreateItem({
        name = "Infotimer_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })       
    self:CreateItem({
        name = "Infojammed_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })       
    self:CreateItem({
        name = "enemies_bg_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })         
    self:CreateItem({
        name = "civis_bg_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })           
    self:CreateItem({
        name = "pagers_bg_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })       
    self:CreateItem({
        name = "gagepacks_bg_color",
        color_preview = true,
        page = "infohudoptions",
        items = HoloColors,
        type = "combo"  
    })       
    self:CreateItem({
        name = "Infotimer_max",
        localize_items = false,
        page = "infohudoptions",
        items = {"1","2","3","4","5","6","7","8","9","10", "11", "12", "13", "14", "15"},
        type = "combo"  
    })      
    self:CreateItem({
        name = "Infobox_max",
        localize_items = false,
        page = "infohudoptions",
        items = {"1","2","3","4","5","6","7","8","9","10", "11", "12", "13", "14", "15"},
        type = "combo"  
    })  
    self:CreateItem({
        name = "Infotimer_size",
        page = "infohudoptions",
        min = 24,
        max = 128,
        type = "slider"  
    })       
    self:CreateItem({
        name = "Stamina_size",
        page = "infohudoptions",
        min = 16,
        max = 128,
        type = "slider"  
    })      
    self:CreateItem({
        name = "info_xpos",
        page = "infohudoptions",
        min = 0,
        max = 1500,
        type = "slider"  
    })      
    self:CreateItem({
        name = "info_ypos",
        page = "infohudoptions",
        min = 0,
        max = 1500,
        type = "slider"  
    })      
    self:CreateItem({
        name = "stamina_xpos",
        page = "infohudoptions",
        min = 0,
        max = 1500,
        type = "slider"  
    })      
    self:CreateItem({
        name = "stamina_ypos",
        page = "infohudoptions",
        min = 0,
        max = 1500,
        type = "slider"  
    })  
    self:CreateItem({
        name = "enemies_enable",
        page = "infohudoptions",
        type = "toggle"  
    })             
    self:CreateItem({
        name = "civis_enable",
        page = "infohudoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "hostages_enable",
        page = "infohudoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "Infotimer_enable",
        page = "infohudoptions",
        type = "toggle"  
    })        
    self:CreateItem({
        name = "Drilltimer_enable",
        page = "infohudoptions",
        type = "toggle"  
    })       
    self:CreateItem({
        name = "ECMtimer_enable",
        page = "infohudoptions",
        type = "toggle"  
    })   
    self:CreateItem({
        name = "Digitaltimer_enable",
        page = "infohudoptions",
        type = "toggle"  
    })        
    self:CreateItem({
        name = "pagers_enable",
        page = "infohudoptions",
        type = "toggle"  
    })          
    self:CreateItem({
        name = "gagepacks_enable",
        page = "infohudoptions",
        type = "toggle"  
    })       	   
    self:CreateItem({
        name = "truetime",
        page = "infohudoptions",
        type = "toggle"  
    })   	
	self:CreateItem({
        name = "resetinfo",
        page = "infohudoptions",
        callback = "resetinfo", 
        type = "button"  
    })   
end

function Holomenu:resetcolors(show_msg)
	local function resetcolors()
	 	for _, item in pairs(self:Item("coloroptions").children) do
			self:reset(item, Holo.options.Defaults[item.option])
		end
	end
	if show_msg then
		QuickMenu:new( managers.localization:text("Holo_info"), managers.localization:text("resetcolors_title").."?", 
		{
			[1] = {text = managers.localization:text("Holo_yes"),callback = function()	
				resetcolors()
			end},
			[2] = {text = managers.localization:text("Holo_no"), is_cancel_button = true} 
		}, true)
	else
		resetcolors()
	end		
end
function Holomenu:resettextcolors(show_msg)
	local function resettextcolors()
		for _, item in pairs(self:Item("textcoloroptions").children) do
			self:reset(item, Holo.options.Defaults[item.option])
		end
	end
	if show_msg then
		QuickMenu:new( managers.localization:text("Holo_info"), managers.localization:text("resettextcolors_title").."?", 
		{
			[1] = {text = managers.localization:text("Holo_yes"),callback = function()	
				resettextcolors()
			end},
			[2] = {text = managers.localization:text("Holo_no"), is_cancel_button = true}
		}, true)
	else
		resettextcolors()
	end
end
function Holomenu:resetall()
	local function resetall(show_msg)
		for _, item in pairs(self:Item("mainoptions").children) do
			self:reset(item, Holo.options.Defaults[item.option])
		end
		self:resetcolors(show_msg)
		self:resettextcolors(show_msg)
		self:resetmenu(show_msg)
		self:resetinfo(show_msg)
	end
	QuickMenu:new( managers.localization:text("Holo_sure"), managers.localization:text("Holoresetall_desc"), 
	{	
		[1] = {text = managers.localization:text("Holo_yes"),callback = function()	
			resetall(false)
		end},
		[3] = {text = managers.localization:text("Holo_decide"),callback = function()	
			resetall(true)
		end},
		[2] = {text = managers.localization:text("Holo_no"), is_cancel_button = true}
	},true)	
end
function Holomenu:resetmenu(show_msg)
	local function resetmenu()
		for _, item in pairs(self:Item("menuoptions").children) do
			self:reset(item, Holo.options.Defaults[item.option])
		end
	end
	if show_msg then
		QuickMenu:new( managers.localization:text("Holo_info"), managers.localization:text("resetinfo_title").."?", 
		{
			[1] = {text = managers.localization:text("Holo_yes"),callback = function()	
				resetmenu()
			end},
			[2] = {text = managers.localization:text("Holo_no"), is_cancel_button = true}
		}, true)
	else
		resetmenu()
	end
end
function Holomenu:resetinfo(show_msg)
	local function resetinfo()
		for _, item in pairs(self:Item("infohudoptions").children) do
			self:reset(item, Holo.options.Defaults[item.option])
		end
	end
	if show_msg then
		QuickMenu:new( managers.localization:text("Holo_info"), managers.localization:text("resetmenu_title").."?", 
		{
			[1] = {text = managers.localization:text("Holo_yes"),callback = function()	
				resetinfo()
			end},
			[2] = {text = managers.localization:text("Holo_no"), is_cancel_button = true}
		}, true)
	else
		resetinfo()
	end
end
 
function Holomenu:backcallback(item)
	self:HideOptions()
end
function Holomenu:toggleclbk(item)
	if item.value then
		managers.menu_component:post_event("box_tick")
	else
		managers.menu_component:post_event("box_untick")
	end
	Holo.options[item.option] = item.value
	Holo:Save()
	Holo:update()
end
function Holomenu:valueclbk(item)
	if item.name:match("box") and not Holo.options.hudbox_enable then
		QuickMenu:new( managers.localization:text("Holo_info"), managers.localization:text("Holo_requires_tophud"), 
		{[1] = {text = managers.localization:text("Holo_yes"),callback = function()	
			self:reset(self:Item("hudbox_enable"), true)
	  		QuickMenu:new( managers.localization:text("Holo_info"), managers.localization:text("Holo_restart"), {}, true) 
  		end
  		},[2] = {text = managers.localization:text("Holo_no"), is_cancel_button = true}}, true)
	else	
		Holo.options[item.option] = item.value
		Holo:Save()
		Holo:update()
	end
end
function Holomenu:teammate_text(item)
	Holo.options[item.option] = item.value
	Holo:Save()
	Holo:update()
	self:reset(self:Item("equipments_color"), item.value)
end
function Holomenu:Replace(NewFile, OldFile)
	NewFile = NewFile:gsub("Holocolor_","")
	local NewF = io.open(NewFile, "rb")
	if NewF == nil then
		QuickMenu:new( ":/", managers.localization:text("Holo_file")..NewFile..managers.localization:text("Holo_missing"), {}, true )
	else
		local GetTexture = NewF:read("*all")
		local OldF = io.open(Holo.Textures .. "pd2/" .. OldFile, "wb")  
		if OldF then
			OldF:write(GetTexture)
			os.remove(Holo.Textures .. "pd2/" .. OldFile)
			OldF:close()
			NewF:close()
	    end
	end
end
	

function Holomenu:enablemenu(item)
	Holo.options[item.option] = item.value
	Holo:Save()
	Holo:update()
	self:reset(self:Item("Holomenu_lobby"), item.value)
	self:reset(self:Item("Holomenu_crimenet"), item.value)
	self:reset(self:Item("Loading_enable"), item.value)

end

function Holomenu:Progress_active_color(item)
	Holo.options.Progress_active_color = item.value
	Holo:Save()
	Holomenu:Replace(Holo.mod_path.."Hud/Textures/Progress"..HoloRadialColors[item.value]..".texture", "hud_progress_active.texture")		
end
function Holomenu:Progress_invalid_color(item)
	Holo.options.Progress_invalid_color = item.value
	Holo:Save()
	Holomenu:Replace(Holo.mod_path.."/Hud/Textures/Progress"..HoloRadialColors[item.value]..".texture", "hud_progress_invalid.texture")		
end
function Holomenu:Health_Color(item)
	Holo.options.Health_Color = item.value
	Holo:Save()
	Holomenu:Replace(Holo.mod_path.."Hud/Textures/Health"..HoloRadialColors[item.value]..".texture", "hud_health.texture")		
    Holomenu:Replace(Holo.mod_path.."Hud/Textures/other/Radial_bg.texture", "hud_radialbg.texture")		
    Holomenu:Replace(Holo.mod_path.."Hud/Textures/other/Radial_rim.texture", "hud_radial_rim.texture")		
    Holomenu:Replace(Holo.mod_path.."Hud/Textures/other/Swansong.texture", "hud_swansong.texture")				
end
function Holomenu:Shield_Color(item)
	Holo.options.Shield_Color = item.value
	Holo:Save()
	Holomenu:Replace(Holo.mod_path.."Hud/Textures/Shield"..HoloRadialColors[item.value]..".texture", "hud_shield.texture")			
    Holomenu:Replace(Holo.mod_path.."Hud/Textures/other/Radial_bg.texture", "hud_radialbg.texture")		
    Holomenu:Replace(Holo.mod_path.."Hud/Textures/other/Radial_rim.texture", "hud_radial_rim.texture")		
    Holomenu:Replace(Holo.mod_path.."Hud/Textures/other/Swansong.texture", "hud_swansong.texture")				
end
