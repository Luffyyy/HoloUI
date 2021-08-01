function Holo:Init()
	self.RefusedScripts = {}
	self.set_position_clbks = {}
	self:CheckOtherMods()
	self:UpdateSettings()
	World:effect_manager():set_rendering_enabled(true)
	self:LoadTextures()
end

function Holo:AddUpdateFunc(func)
    table.insert(self.Updaters, func)
end

function Holo:LoadTextures()
	local ids_strings = {}
	local function LoadTextures(path)
		for _, file in pairs(FileIO:GetFiles(path)) do
			local file_path = BeardLib.Utils.Path:Combine(path, file)
			local in_path = file_path:gsub("%.png", ""):gsub("%.texture", ""):gsub(self.ModPath, ""):gsub("Assets/", "")
			table.insert(ids_strings, Idstring(in_path))
			DB:create_entry(Idstring("texture"), Idstring(in_path), file_path)
		end
		for _, dir in pairs(FileIO:GetFolders(path)) do
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

function Holo:GetFrameColor(setting, can_return_null)
	return self.Options:GetValue("FrameColors/Enable") and self:GetColor("FrameColors/" .. setting, nil, can_return_null) or not can_return_null and self:GetColor("Colors/Frame") or nil
end

function Holo:GetFrameStyle(setting)
	return self.Options:GetValue("FrameStyles/Enable") and self.Options:GetValue("FrameStyles/" .. setting) or self.Options:GetValue("FrameStyle")
end

function Holo:GetAlpha(setting)
	return self.Options:GetValue("HUDAlpha")
end

function Holo:GetColor(setting, vec, can_return_null)
	local color = self.Options:GetValue(setting) or not can_return_null and Color.white or nil
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
		if self.Options:GetValue("Assault") then
			pdth_hud.Options:SetValue("HUD/Assault", false)
		end
	end
	if restoration and restoration.Options then
		if self.Options:GetValue("Teammate") then
			restoration.Options:SetValue("HUD/Teammate", false)  
		end		
		if self.Options:GetValue("Menu") then
			restoration.Options:SetValue("HUD/Loadouts", false)
		end
	end
end

function Holo:ShouldModify(c, o)
	local function inform(a) 
		self:log(string.format("[Info]Cannot modify %s because %s uses it", o, a))
		self.RefusedScripts[RequiredScript] = true
	end
	if c and not self.Options:GetValue("" .. c) then
		return false
	end 
	if (CompactHUD or Fallout4hud or SAOHUD) and o == "Teammate" then
		return false
	end
	if NepgearsyMM and o == "PlayerProfile" then
		inform("Nepgearsy Main Menu")
		return false
	end
	
	if VoidUI then
		if c == "HUD" or o == "Chat" or o == "Blackscreen" then
			inform("Void UI")	
			return false
		end
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
		local hud = restoration.Options:GetValue("HUD/MainHUD")
		local assault = restoration.Options:GetValue("HUD/AssaultPanel") and o == "Assault"
		local presenter = restoration.Options:GetValue("HUD/Presenter") and o == "Presenter"
		local objective = restoration.Options:GetValue("HUD/ObjectivesPanel") and o == "Objective"
		local hint = restoration.Options:GetValue("HUD/Hint") and o == "Hint"
		local carry = restoration.Options:GetValue("HUD/Carry") and o == "Carrying"
		local down = restoration.Options:GetValue("HUD/Down") and o == "PlayerDowned"
		if hud and (assault or presenter or objective or hint or carry or down) then
			inform("Resotration")
			return false
		end
	end
	local WolfHUD = WolfHUD or VHUDPlus
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

Hooks:Add("MenuManagerPopulateCustomMenus", "HoloMenuInit", function(self, nodes)
	--Called more than once for some reason....
	function MenuCallbackHandler:OpenHoloMenu() Holo.Menu._menu:Enable() end		
	Holo.Menu:Init()
	MenuHelperPlus:AddButton({
		id = "HoloOptions",
		title = "Holo/OptionsTitle",
		desc = "Holo/OptionsDesc",
		callback = "OpenHoloMenu",
		node = nodes.blt_options,
	})
end)
 
Hooks:Add("GameSetupUpdate", "HoloUpdate", function(t, dt)
	if not Holo._hooked_to_poco then
		if PocoHud3Class and PocoHud3Class.TPocoHud3 then
			Holo:Post(PocoHud3Class.TPocoHud3, "_updatePlayers", function(self, t)
				local just_updated_holo
				for i=1,4 do
					local cdata = managers.criminals:character_data_by_peer_id(i)
					if cdata and self['pnl_'..i] then
						local me = i==self.pid
						local tm = managers.hud._teammate_panels[me and HUDManager.PLAYER_PANEL or cdata.panel_id]
						if tm then
							local x,y = managers.gui_data:scaled_to_full(managers.hud._saferect, tm._player_panel:world_x(), 0) --Can't get this shit to convert properly
							self['pnl_'..i]:set_world_x(x - 150)
							if not self._updated_holo then
								tm:UpdateHolo()
								just_updated_holo = true
							end
						end
					else
						self._updated_holo = false
					end
				end
				if just_updated_holo and not self._updated_holo then
					self._updated_holo = true
				end
			end)
		end
		Holo._hooked_to_poco = true
	end
end)
