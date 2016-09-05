_G.Holo = _G.Holo or _G.ModCore:new(ModPath .. "ModConfig.xml", false, true)
function Holo:init()
	self:init_modules()
	for k, v in ipairs(self.Colors) do
		table.insert(self.AllColorsStrings, v.menu_name)
	end
	self.setup = true
	self:UpdateSettings()
	if not self.Options:GetValue("TopHud") then
		self.Options:SetValue("Objective", false)
		self.Options:SetValue("Assault", false)
		self.Options:SetValue("Casing", false)
		self.Options:SetValue("NoPointOfReturn", false)
		self.Options:SetValue("Presenter", false)
	end
	if pdth_hud and pdth_hud.Options then
		if self.Options:GetValue("Assault") then
			pdth_hud.Options:SetValue("HUD/Assault", false)
		end
		if pdth_hud.Options:GetValue("HUD/MainHud") then
			self.Options:SetValue("TeammateHud", false)
		end
		if pdth_hud.Options:GetValue("HUD/Objectives") then
			self.Options:SetValue("Presenter", false)
		end
	end
	World:effect_manager():set_rendering_enabled(true)		
	self:LoadTextures()
	self:log("Done Loading")
end
function Holo:ModifyWallet()
 	local panel = Global.wallet_panel
	local w
	local items = {"money", "level", "skillpoint", "gage_coins"}
	for i, v in pairs(items) do
		local child = "wallet_" .. v
		if i == 4 then
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
	this._back_marker = back_button:parent():bitmap({
		color = Holo:GetColor("Colors/Marker"),
		alpha = Holo.Options:GetValue("MarkerAlpha"),
		visible = false,
		layer = back_button:layer() - 1
	})
	back_button:set_shape(back_button:text_rect())
	back_button:set_world_rightbottom(back_button:parent():world_rightbottom())
	this._back_marker:set_size(300,back_button:h())
	this._back_marker:set_rightbottom(back_button:rightbottom())
	Hooks:PostHook(this, "mouse_moved", "HoloMouseMoved", function(this, o, x, y)
		if this._back_button:inside(x, y) then
			if not this.back_button_highlighted then
				this._back_button_highlighted = true
				this.back_button_highlighted = true
				this._back_button:set_color(Holo:GetColor("TextColors/MenuHighlighted"))
				this._back_marker:show()
				managers.menu_component:post_event("highlight")
			end
		elseif this.back_button_highlighted then
			this._back_button_highlighted = false
			this.back_button_highlighted = false
			this._back_marker:hide()
			this._back_button:set_color(Holo:GetColor("TextColors/Menu"))
		end
	end)
end
function Holo:FixBlendMode(panel)
	for k,v in pairs(panel:children()) do
		if v.children then
			self:FixBlendMode(v)
		else
			v:set_blend_mode("normal")
		end
	end
end
function Holo:ApplySettings(toset, config)
	if toset then
		for _, panel in pairs(toset) do
			if config then
				for k, v in pairs(config) do
					k = k == "texture" and "image" or k
					if panel["set_"..k] then
						panel["set_"..k](panel, v)
					end
				end
			end
		end
	end
end
function Holo:CreateSkillInfos()
	self.SkillInfo:CreateInfo({
        name = "Stamina",
        icon = "guis/textures/pd2/skilltree/icons_atlas",
		panel = "InfoBoxes",
        icon_rect = {67,511,55,66},		
		text = "0",
		func = "UpdateStamina",
	})	
	self.SkillInfo:CreateInfo({
        name = "InspireSkill",
        icon = "guis/textures/pd2/skilltree/icons_atlas",
		panel = "InfoBoxes",
		visible = true,
        icon_rect = {254,574,66,66},		
		text = "0",
		func = "ShowInspireCoolDown",
	})
end
function Holo:CreateInfos()
	self.Info:CreateInfo({
		name = "Hostages",
	    icon = "guis/textures/pd2/skilltree/icons_atlas",       
	    icon_rect = {255,449, 64, 64},
	    func = "CountHostages",
		panel = "InfoBoxes",
		visible = true,
		text = "0",
	})
	self.Info:CreateInfo({
		name = "Civilians",
	    icon = "guis/textures/pd2/skilltree/icons_atlas",
	    icon_rect = {386,447,64,64},
		panel = "InfoBoxes",
		text = "0",
        func = "CountInfo",   
        value_is_table = true,     
        value = callback(managers.enemy, managers.enemy, "all_civilians"),		
	})
	self.Info:CreateInfo({
		name = "Enemies",
	    icon = "guis/textures/pd2/skilltree/icons_atlas",
	    icon_rect = {2,319,64,64},
		panel = "InfoBoxes",
		text = "0",
        func = "CountInfo",        
        value_is_table = true,
        value = callback(managers.enemy, managers.enemy, "all_enemies"),
	})
	self.Info:CreateInfo({
        name = "Pagers",
        icon = "guis/textures/pd2/specialization/icons_atlas",
		panel = "InfoBoxes",
        icon_rect = {66,254,64,64},		
		text = "0",
		func = "CountPagers",
	})	
	self.Info:CreateInfo({
        name = "GagePacks",
        icon = "guis/textures/pd2/specialization/icons_atlas",
		panel = "InfoBoxes",
        icon_rect = {66,254,64,64},		
		text = "0",
		func = "CountInfo",
        value = callback(managers.gage_assignment, managers.gage_assignment, "count_active_units"),
	})		
	local rects = {
	    Money = {4, 3, 70, 59},
	    Diamonds = {72, 7, 53, 53},
	    Gold = {132, 9, 56, 52},
	    Weapons = {188, 3, 57, 62},
	    SmallLoot = {66, 59, 62, 57},
	}
	for typ, _ in pairs(self.Loot) do
		self.Info:CreateInfo({
			name = typ,
			visible = true,
		    icon = "guis/textures/custom/InfoIcons",
		    func = "CountLoot",
		    icon_rect = rects[typ] or rects.Money,
			panel = "InfoBoxes",
			text = "0",
		})	
	end
end
function Holo:AddLootType(name)
	self.Loot[name] = {}
end
function Holo:AddLoot(name, unit)
	if not self.Loot[name] then
		self:AddLootType(name)
	end
	if not table.contains(self.Loot[name], unit) then
    	table.insert(self.Loot[name], unit)
	end
end
function Holo:RemoveLoot(name, unit)
	if self.Loot[name] then
		table.delete(self.Loot[name], unit)
	end
end
function Holo:LoadTextures()
	local ids_strings = {}
	local function LoadTextures(path)
		for _, file in pairs(SystemFS:list(path)) do
			local file_path = BeardLib.Utils.Path:Combine(path, file)
			local in_path = file_path:gsub(".png", ""):gsub(self.ModPath, ""):gsub("Assets/", "")
			if not file_path:match("custom") then
				self.Options._storage.AllowedTextures[in_path] = {_meta = "option", type="boolean", name = in_path, value = true}
			end
			if file_path:match("custom") or self.Options._storage.AllowedTextures[in_path].value == true then
				table.insert(ids_strings, Idstring(in_path))
				DB:create_entry(Idstring("texture"), Idstring(in_path), file_path)
			end
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
	local updaters = {
		"_hud_assault_corner",
		"_hud_player_downed",
		"_hud_heist_timer",
		"_hud_objectives",
		"_hud_presenter",
		"_hud_hint",
		"_hud_temp",
	}
	if managers.hud then
		if self.Info then
			self.Info:UpdateHoloHUD()
		end		 
		if self.SkillInfo then
			self.SkillInfo:UpdateHoloHUD()
		end
		if managers.hud.UpdateHoloHUD then
			managers.hud:UpdateHoloHUD()
			for _, teammate in pairs(managers.hud._teammate_panels) do
				if teammate.UpdateHoloHUD then
					teammate:UpdateHoloHUD()
				end
			end
			for _, hud in pairs(updaters) do
				if managers.hud[hud].UpdateHoloHUD then
					managers.hud[hud]:UpdateHoloHUD()
				end
			end
		end
	end
	if tweak_data then
		tweak_data:UpdateHoloHUD()
	end
end
function Holo:GetColor(setting)
	local value = self.Options:GetValue(setting)		
	if setting == "Colors/Main" then
		value = math.min(value + 1, #self.Colors)
	end
	local col = self.Options._storage.CustomColors[setting]
	if value and (self.Colors[value] and self.Colors[value].color) or col then
		return (col and col.value) or self.Colors[value].color
	else
		self:log("[ERROR] Color %s Doesn't exist!", setting)
		return Color.white
	end
end
if not Holo.setup then
	Holo:init()
end
if Hooks then
	Hooks:Add("MenuManager_Base_SetupModOptionsMenu", "Voicekey_opt", function(menu_manager, nodes)
		lua_mod_options_menu_id = LuaModManager.Constants._lua_mod_options_menu_id
		MenuHelper:NewMenu(lua_mod_options_menu_id)
	end)
	Hooks:Add("MenuComponentManagerInitialize", "HoloMenuComponentManagerInitialize", function(menu)
		Hooks:PostHook(NotificationsGuiObject, "init", "HoloInit", function(self)
			self._highlight_rect:hide()
			self._highlight_left_rect:hide()
			self._highlight_right_rect:hide()
		end)
	end)
 
	Hooks:Add("MenuManager_Base_PopulateModOptionsMenu", "Voicekey_opt", function(menu_manager, nodes)			
		function MenuCallbackHandler:OpenHoloMenu()
			Holo.Menu._menu:toggle()
			if managers.hud then
				managers.hud._chatinput_changed_callback_handler:dispatch(closed)
			end
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