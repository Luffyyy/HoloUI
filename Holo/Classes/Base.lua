if not ModCore then
	log("[ERROR][Holo] BeardLib is not installed!")
	return
end

Holo = Holo or ModCore:new(ModPath .. "Config.xml", false, true)
function Holo:init()
	self:init_modules()
	self.setup = true
	self.set_position_clbks = {}
	self:CheckOtherMods()
	self:UpdateSettings()
	World:effect_manager():set_rendering_enabled(true)		
	self:LoadTextures()
	self:log("Done Loading")
end

function Holo:AddUpdateFunc(func)
    table.insert(self.Updaters, func)
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
	for _, func in pairs(self.Updaters) do
		func()
	end
end

function Holo:GetFrameColor(setting)
	return self.Options:GetValue("FrameColors/Enable") and self:GetColor("FrameColors/" .. setting) or self:GetColor("Colors/Frame")  
end

function Holo:GetFrameStyle(setting)
	return self.Options:GetValue("FrameStyles/Enable") and self.Options:GetValue("FrameStyles/" .. setting) or self.Options:GetValue("FrameStyle")
end

function Holo:GetColor(setting, vec)
	local color = self.Options:GetValue(setting) or self.Options:GetValue("Colors/Main") or Color.white
	if setting:match("TextColors") then
		local bgname = setting:gsub("TextColors", "Colors")
		if self.Options:GetValue("TextColors/AutomaticTextColors") and self.Options:GetValue(bgname) and setting ~= "TextColors/Health" then
			color = self:GetColor(bgname):contrast()
		end
	end
	return vec and Vector3(color:unpack()) or color
end

function Holo:AddSetPositionClbk(clbk)
	table.insert(self.set_position_clbks, clbk)
end

function Holo:CheckOtherMods()
	if pdth_hud and pdth_hud.Options then
		if Holo.Options:GetValue("HudAssault") then
			pdth_hud.Options:SetValue("HUD/Assault", false)
		end
	end
	if restoration and restoration.Options then
		if Holo.Options:GetValue("TeammateHud") then
			restoration.Options:SetValue("HUD/MainHud", false)  
		end		
		if Holo.Options:GetValue("Menu") then
			restoration.Options:SetValue("HUD/Loadouts", false)
		end
	end
end

function Holo:ShouldModify(c, o)  
	local function inform(a) self:log(string.format("[Info]Cannot modify %s because %s uses it", o, a)) end
	if c and not Holo.Options:GetValue("" .. c) then
		return false
	end 
	if (CompactHUD or Fallout4hud or SAOHUD) and o == "TeammateHud" then
		return false
	end
	if pdth_hud and pdth_hud.Options then
		if pdth_hud.Options:GetValue("HUD/MainHud") and o == "TeammateHud" then
			inform("PDTH Hud")	
			return false
		end
		if pdth_hud.Options:GetValue("HUD/Objectives") and o == "Presenter" then
			inform("PDTH Hud")
			return false
		end
		if pdth_hud.Options:GetValue("HUD/Interaction") and o == "Interaction" then
			inform("PDTH Hud")
			return false
		end
	end	
	if restoration and restoration.Options then
		if restoration.Options:GetValue("HUD/AssaultPanel") and o == "HudAssault" then
			inform("Resotration")
			return false
		end
		if restoration.Options:GetValue("HUD/Presenter") and o == "Presenter" then
			inform("Resotration")
			return false
		end
		if restoration.Options:GetValue("HUD/ObjectivesPanel") and o == "Objective" then
			inform("Resotration")
			return false
		end		
		if restoration.Options:GetValue("HUD/MainHud") and (o == "Hint" or o == "Carrying")  then
			inform("Resotration")
			return false
		end
	end
	if WolfHUD then
		if o == "TeammateHud" and WolfHUD:getSetting("use_customhud", "boolean") then
			inform("WolfHUD")
			return false			
		end
		if o == "Chat" and HUDChat.WIDTH then --No actual option to disable it! GREAT
			inform("WolfHUD")
			return false	
		end
	end
	return self.Options:GetValue(o)
end

if not Holo.setup then
	Holo:init()
end

if Hooks then
	Hooks:Add("MenuManager_Base_SetupModOptionsMenu", "Voicekey_opt", function(menu_manager, nodes)
		lua_mod_options_menu_id = LuaModManager.Constants._lua_mod_options_menu_id
		MenuHelper:NewMenu(lua_mod_options_menu_id)
	end)	
	if Holo.Options:GetValue("Menu") then
		Hooks:Add("MenuComponentManagerInitialize", "HoloMenuComponentManagerInitialize", function(menu)
			Hooks:PostHook(NotificationsGuiObject, "init", "HoloInit", function(self)
				self._highlight_rect:hide()
				self._highlight_left_rect:hide()
				self._highlight_right_rect:hide()
			end)
		end)
	end
	Hooks:Add("MenuManager_Base_PopulateModOptionsMenu", "VoicekeyOpt", function(menu_manager, nodes)			
		function MenuCallbackHandler:OpenHoloMenu() Holo.Menu._menu:toggle() end		
		Holo.Workspace = managers.gui_data:create_fullscreen_workspace()		
		Holo.Panel = Holo.Workspace:panel()
		Holo.Menu:Init()
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