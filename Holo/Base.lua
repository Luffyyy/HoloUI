_G.Holo = _G.Holo or _G.ModCore:new(ModPath .. "ModConfig.xml", false, true)
function Holo:init()
	self:init_modules()
	self.setup = true
	self.init_colors = #Holo.Colors
	for k, v in pairs(Holo.Options:GetOption("CustomColors")) do
	    if type(v) == "table" and v.value then
            table.insert(Holo.Colors, {color = v.value.color, name = v.value.name, custom = true})
	    end
	end
	self:UpdateSettings()
	World:effect_manager():set_rendering_enabled(true)		
	self:LoadTextures()
	self:log("Done Loading")
end
function Holo:AddUpdateFunc(func)
    table.insert(self.Updaters, func)
end
function Holo:ModifyWallet()
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
function Holo:FixBackButton(this, back_button)
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
function Holo:SetBlendMode(o, ...)
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
function Holo:Apply(tbl, config)
	if tbl then
		for _, o in pairs(tbl) do
			o:configure(config)
		end
	end
end
function Holo:LoadTextures()
	local ids_strings = {}
	local function LoadTextures(path)
		for _, file in pairs(SystemFS:list(path)) do
			local file_path = BeardLib.Utils.Path:Combine(path, file)
			local in_path = file_path:gsub(".png", ""):gsub(self.ModPath, ""):gsub("Assets/", "")
			table.insert(ids_strings, Idstring(in_path))
			DB:create_entry(Idstring("texture"), Idstring(in_path), file_path)
		end
		for _, dir in pairs(SystemFS:list(path, true)) do
			LoadTextures(BeardLib.Utils.Path:Combine(path, dir))
		end
	end
	LoadTextures(BeardLib.Utils.Path:Combine(self.ModPath, "Assets"))
	Application:reload_textures(ids_strings)
	self.Options:Save()
	self:log("Loaded Textures")
end
function Holo:UpdateSettings()
	self.Colors[1].color = self:GetColor("Colors/Main")
	for _, func in pairs(self.Updaters) do
		func()
	end
end
function Holo:GetFrameColor(setting)
	return self.Options:GetValue("Extra/HudBoxFrameColor") and self:GetColor("Extra/FrameColor/" .. setting) or self:GetColor("Colors/Frame")  
end
function Holo:GetFrameStyle(setting)
	return self.Options:GetValue("Extra/HudBoxFrameStyle") and self.Options:GetValue("Extra/FrameStyle/" .. setting) or self.Options:GetValue("FrameStyle")
end
function Holo:GetAlpha(setting)
	return self.Options:GetValue("Extra/HudBoxAlpha") and self.Options:GetValue("Extra/Alpha/" .. setting) or self.Options:GetValue("HudAlpha")
end
function Holo:GetColor(setting, vec)
	local value = self.Options:GetValue(setting)		
	if value and value > #self.Colors then
		self.Options:SetValue(setting, self.Options:GetOption(setting).default_value)
		self.Options:Save()
	end
	if setting == "Colors/Main" then
		value = math.min(value + 1, #self.Colors)
	end
	local ret = Color.white
	if value and (self.Colors[value] and self.Colors[value].color) then
		ret = self.Colors[value].color
	else
		self:log("[ERROR] Color %s Doesn't exist!", setting)
	end
	return vec and Vector3(ret:unpack()) or ret
end
function Holo:ShouldModify(comp, option)  
	local LogInfo = function(a,b)
		self:log(string.format("[Info]Cannot modify %s because %s uses it", a, b))
	end
	local value = self.Options:GetValue(option)
	if comp and not Holo.Options:GetValue("Base/" .. comp) then
		return false
	end 
	if pdth_hud and pdth_hud.Options then
		if Holo.Options:GetValue("HudAssault") then
			pdth_hud.Options:SetValue("HUD/Assault", false)
		end
		if pdth_hud.Options:GetValue("HUD/MainHud") and option == "TeammateHud" then
			LogInfo(option, "PDTH Hud")	
			return false
		end
		if pdth_hud.Options:GetValue("HUD/Objectives") and option == "Presenter" then
			LogInfo(option, "PDTH Hud")
			return false
		end
		if pdth_hud.Options:GetValue("HUD/Interaction") and option == "Interaction" then
			LogInfo(option, "PDTH Hud")
			return false
		end
	end	
	return value
end
if not Holo.setup then
	Holo:init()
end
if Hooks then
	Hooks:Add("MenuManager_Base_SetupModOptionsMenu", "Voicekey_opt", function(menu_manager, nodes)
		lua_mod_options_menu_id = LuaModManager.Constants._lua_mod_options_menu_id
		MenuHelper:NewMenu(lua_mod_options_menu_id)
	end)
	if Holo.Options:GetValue("Base/Menu") then
		Hooks:Add("MenuComponentManagerInitialize", "HoloMenuComponentManagerInitialize", function(menu)
			Hooks:PostHook(NotificationsGuiObject, "init", "HoloInit", function(self)
				self._highlight_rect:hide()
				self._highlight_left_rect:hide()
				self._highlight_right_rect:hide()
			end)
		end)
	end
	Hooks:Add("MenuManager_Base_PopulateModOptionsMenu", "Voicekey_opt", function(menu_manager, nodes)			
		function MenuCallbackHandler:OpenHoloMenu()
			Holo.Menu._menu:toggle()
		end		
		Holo.Panel = managers.gui_data:create_fullscreen_workspace():panel()		
		Holo.Menu = HoloMenu:new()
		Holo.Dialog = MenuDialog:new({
			background_alpha = 0.65,
			text_color = Holo:GetColor("TextColors/Menu"),        
	        background_color = Holo:GetColor("Colors/MenuBackground"),
	        text_highlight_color = Holo:GetColor("TextColors/MenuHighlighted"),
	        marker_alpha = Holo.Options:GetValue("Menu/MarkerAlpha"),
	        marker_highlight_color = Holo:GetColor("Colors/Marker"),
		})
		MenuHelper:AddButton({
			id = "HoloOptions",
			title = "Holo/OptionsTitle",
			desc = "Holo/OptionsDesc",
			callback = "OpenHoloMenu",
			menu_id = lua_mod_options_menu_id,
			priority = -13,
		})
	end)
end