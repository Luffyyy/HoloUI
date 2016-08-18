_G.Holo = _G.Holo or _G.ModCore:new(ModPath .. "ModConfig.xml", false, true)
Holo.ModPath = ModPath
Holo.Data = LuaModManager:GetMod(Holo.ModPath).definition
Holo.CustomTextures = {}
Holo.Colors = {
	 {color = Color(0.2 ,0.6 ,1), menu_name = "Holo/Prefered"},
	 {color = Color(0.2, 0.6 ,1 ), menu_name = "Holo/Blue"},	  	 
	 {color = Color(1,0.6 ,0), menu_name = "Holo/Orange"},
	 {color = Color(0, 1, 0.1), menu_name = "Holo/Green"},	
	 {color = Color(1, 0.25, 0.7), menu_name = "Holo/Pink"},				 
	 {color = Color(0, 0, 0), menu_name = "Holo/Black"},		 		 
	 {color = Color(0.15, 0.15, 0.15), menu_name = "Holo/Grey"},
	 {color = Color(0.1, 0.1, 0.35), menu_name = "Holo/DarkBlue"},	
	 {color = Color(1, 0.1, 0), menu_name = "Holo/Red"},	
	 {color = Color(1, 0.8, 0.2), menu_name = "Holo/Yellow"},	
	 {color = Color(1, 1, 1), menu_name = "Holo/White"},
	 {color = Color(0, 1, 0.9), menu_name = "Holo/Cyan"},
	 {color = Color(0.5, 0, 1), menu_name = "Holo/Purple"},
	 {color = Color(0, 0.9, 0.5), menu_name = "Holo/SpringGreen"},
	 {color = Color(0.6,0.8,0.85), menu_name = "Holo/Light Blue"},
	 {color = Color(1, 0, 0.2), menu_name = "Holo/Crimson"},
     {color = Color(0.5,82,45), menu_name = "Holo/Brown"},
	 {color = Color(0.7, 0.9, 0), menu_name = "Holo/Lime"},
}
Holo.Loot = {}
Holo.TextSizes = {
	20,
	24,
	30
}
Holo.AllColorsStrings = Holo.AllColorsStrings or {} 
Holo.RadialColors = {
    "Holo/Blue",
    "Holo/Orange",
    "Holo/Green", 
    "Holo/Pink", 
	"Holo/Yellow",
    "Holo/White", 
	"Holo/Red", 
	"Holo/Cyan",
	"Holo/SpringGreen",
	"Holo/DarkBlue",
	"Holo/Purple",
	"Holo/Lime",
	"Holo/Black",
} 
Holo.RadialNames = {
    "Blue",
    "Orange",
    "Green", 
    "Pink", 
	"Yellow",
    "White", 
	"Red", 
	"Cyan",
	"SpringGreen",
	"arkBlue",
	"Purple",
	"Lime",
	"Black",
} 
Holo.TextSizesStrings = {
	"Holo/Small",
	"Holo/Normal",
	"Holo/Big"
}
Holo.FrameStyles ={
	"Holo/Normal",
	"Holo/Underline",
	"Holo/Sideline",
	"Holo/Upperline",
	"Holo/Fullframe",
	"Holo/None",
}
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
	x,y,w,h = back_button:text_rect()
	back_button:set_shape(x,y,w,h)
	back_button:set_world_rightbottom(back_button:parent():world_rightbottom())
	this._back_marker:set_size(300,h)
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
function Holo:Version()
	return Holo.Data.version
end
function Holo:LoadTextures()
	local ids_strings = {}
	local function LoadTextures(path)
		for _, file in pairs(SystemFS:list(path)) do
			local file_path = BeardLib.Utils.Path:Combine(path, file)
			local in_path = file_path:gsub(".png", ""):gsub(self.ModPath, ""):gsub("Assets/", "")
			if not file_path:match("guis/Holo") then
				self.Options._storage.AllowedTextures[in_path] = {_meta = "option", type="boolean", name = in_path, value = true}
			end
			if file_path:match("guis/Holo") or self.Options._storage.AllowedTextures[in_path].value == true then
				table.insert(ids_strings, Idstring(in_path))
				DB:create_entry(Idstring("texture"), Idstring(in_path), file_path)
			end
		end
		for _, dir in pairs(SystemFS:list(path, true)) do
			LoadTextures(BeardLib.Utils.Path:Combine(path, dir))
		end
	end
	LoadTextures(BeardLib.Utils.Path:Combine(self.ModPath, "Assets"))
	self:log("Loading textures")
	Application:reload_textures(ids_strings)
	self.Options:Save()
end
function Holo:init()
	for k, v in ipairs(self.Colors) do
		table.insert(self.AllColorsStrings, v.menu_name)
	end
	self:log("Done loading options")
	self.setup = true
	self:init_modules()
	 local col = self.Options._storage.CustomColors["Colors/Main"]
	self.Colors[1].color = self:GetColor("Colors/Main")
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
	self:LoadTextures()
 end
function Holo:UpdateSetting()
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
		 if self.NewInfo then
 			self.NewInfo:UpdateHoloHUD()
 		end
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