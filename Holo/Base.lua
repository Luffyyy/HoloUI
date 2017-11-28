if not ModCore then
	log("[ERROR][Holo] BeardLib is not installed!")
	return
end

Holo = Holo or ModCore:new(ModPath .. "Config.xml", false, true)
function Holo:Init()
	self:init_modules()
	self.Setup = true
	self.RefusedScripts = {}
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
			local in_path = file_path:gsub("%.png", ""):gsub("%.texture", ""):gsub(self.ModPath, ""):gsub("Assets/", "")
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

function Holo:GetAlpha(setting)
	return self.Options:GetValue("HUDAlpha")
end

function Holo:GetColor(setting, vec)
	local color = self.Options:GetValue(setting) or Color.white
	if setting:match("TextColors") then
		local bgname = setting:gsub("TextColors", "Colors")
		if self.Options:GetValue("TextColors/AutomaticTextColors") and self.Options:GetValue(bgname) and not Holo.NonContrastable[setting] then
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
		if Holo.Options:GetValue("Assault") then
			pdth_hud.Options:SetValue("HUD/Assault", false)
		end
	end
	if restoration and restoration.Options then
		if Holo.Options:GetValue("Teammate") then
			restoration.Options:SetValue("HUD/MainHud", false)  
		end		
		if Holo.Options:GetValue("Menu") then
			restoration.Options:SetValue("HUD/Loadouts", false)
		end
	end
end

function Holo:ShouldModify(c, o)
	if not self.Setup then
		return false
	end
	local function inform(a) 
		self:log(string.format("[Info]Cannot modify %s because %s uses it", o, a))
		self.RefusedScripts[RequiredScript] = true
	end
	if c and not Holo.Options:GetValue("" .. c) then
		return false
	end 
	if (CompactHUD or Fallout4hud or SAOHUD) and o == "Teammate" then
		return false
	end
	if NepgearsyMM and o == "PlayerProfile" then
		inform("Nepgearsy Main Menu")	
		return false
	end
	if pdth_hud and pdth_hud.Options then
		if pdth_hud.Options:GetValue("HUD/MainHud") and o == "Teammate" then
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
		if restoration.Options:GetValue("HUD/AssaultPanel") and o == "Assault" then
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
		if o == "Teammate" and WolfHUD:getSetting({"CustomHUD", "ENABLED"}) then
			inform("WolfHUD")
			return false			
		end
		if o == "Chat" and HUDChat and HUDChat.WIDTH then --No actual option to disable it! GREAT
			inform("WolfHUD")
			return false	
		end
	end
	if o == "Teammate" and HUDTeammateCustom then
		inform("CustomHUD")
		return false
	end
	local res = true
	if o then
		res = self.Options:GetValue(o) 
	end
	if not res then
		self.RefusedScripts[RequiredScript] = true
	end
	return res
end

function Holo:Post(clss, func, after_orig)
	Hooks:PostHook(clss, func, "HoloUI"..func, after_orig)
end

function Holo:Pre(clss, func, before_orig)
	Hooks:PreHook(clss, func, "HoloUIPre"..func, before_orig)
end

function Holo:Replace(clss, func, new_func)
	clss["holo_orig_"..func] = clss["holo_orig_"..func] or clss[func]
	clss[func] = function(this, ...)
		return new_func(this, clss["holo_orig_"..func], ...)
	end
end

if not Holo.Setup then
	if BeardLib.Version and tonumber(BeardLib.Version) and BeardLib.Version >= 2.6 then
        Holo:Init()
    else
        log("[ERROR] HoloUI requires at least version 2.6 of BeardLib installed!")
        return
    end
end

if Hooks then
	Hooks:Add("MenuManagerSetupCustomMenus", "HoloMenuInit", function(self, nodes)			
		function MenuCallbackHandler:OpenHoloMenu() Holo.Menu._menu:toggle() end		
		Holo.Menu:Init()
		MenuHelperPlus:AddButton({
			id = "HoloOptions",
			title = "Holo/OptionsTitle",
			desc = "Holo/OptionsDesc",
			callback = "OpenHoloMenu",
			node = nodes.blt_options,
		})
	end)
end