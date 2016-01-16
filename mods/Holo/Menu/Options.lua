
_G.Holo = _G.Holo or {}
Holo.options = Holo.options or {} 
Holo.mod_path = ModPath
Holo._data_path = SavePath .. "HoloSave.txt"
Holo.Textures = "assets/mod_overrides/HoloHud/guis/textures/"
Holo.colors = {
	 {color = Color(0.2 ,0.6 ,1 ), menu_name = "Holocolor_title"},
	 {color = Color(0.2, 0.6 ,1 ), menu_name = "Holocolor_Blue"},	  	 
	 {color = Color(1,0.6 ,0 ), menu_name = "Holocolor_Orange"},
	 {color = Color(0, 1, 0.1), menu_name = "Holocolor_Green"},	
	 {color = Color(1, 0.25, 0.7), menu_name = "Holocolor_Pink"},				 
	 {color = Color(0, 0, 0), menu_name = "Holocolor_Black"},		 		 
	 {color = Color(0.15, 0.15, 0.15), menu_name = "Holocolor_Grey"},
	 {color = Color(0.1, 0.1, 0.35), menu_name = "Holocolor_DarkBlue"},	
	 {color = Color(1, 0.1, 0), menu_name = "Holocolor_Red"},	
	 {color = Color(1, 0.8, 0.2), menu_name = "Holocolor_Yellow"},	
	 {color = Color(1, 1, 1), menu_name = "Holocolor_White"},
	 {color = Color(0, 1, 0.9), menu_name = "Holocolor_Cyan"},
	 {color = Color(0.5, 0, 1), menu_name = "Holocolor_Purple"},
	 {color = Color(0, 0.9, 0.5), menu_name = "Holocolor_SpringGreen"},
	 {color = Color(0.6,0.8,0.85), menu_name = "Holocolor_Light Blue"},
	 {color = Color(1, 0, 0.2), menu_name = "Holocolor_Crimson"},
     {color = Color(0.5,82,45), menu_name = "Holocolor_Brown"},
	 {color = Color(0.7, 0.9, 0), menu_name = "Holocolor_Lime"},
}
Holo.textsizes = {
	20,
	24,
	30
}
HoloColors = {} 
HoloRadialColors = {
    "Holocolor_Blue",
    "Holocolor_Orange",
    "Holocolor_Green", 
    "Holocolor_Pink", 
	"Holocolor_Yellow",
    "Holocolor_White", 
	"Holocolor_Red", 
	"Holocolor_Cyan",
	"Holocolor_SpringGreen",
	"Holocolor_DarkBlue",
	"Holocolor_Purple",
	"Holocolor_Lime",
	"Holocolor_Black",
} 
HoloMenuTextSizes = {
	"TextSixes_Small",
	"TextSixes_Normal",
	"TextSixes_Big"
}
HoloFrameStyles ={
	"FrameStyle_Normal",
	"FrameStyle_Underline",
	"FrameStyle_Sideline",
	"FrameStyle_Upperline",
	"FrameStyle_Fullframe",
}
function Holo:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
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
function Holo:clone( class )
	class.old = clone(class)
end
function Holo:Load()
	local file = io.open( "mods/saves/HoloSave.txt", "r" )
	if file then
		self.options = json.decode( file:read("*all") )
		file:close() 
	end
end
function Holo:CheckForHuds() 
	if io.open("lib/Native/HoxHud.dll", "rb") then 
		Holo.options.HoxHud_support = true 
	else
		Holo.options.HoxHud_support = false 
	end
	Holo.options.PDTHHud_support = file.DirectoryExists( "mods/PDTH Hud/mod.txt" ) and Holo.options.hudbox_enable 
	Holo.options.CopactHud_support = file.DirectoryExists( "mods/CompactHUD/mod.txt" )
	Holo.options.GageHud_support = file.DirectoryExists( "mods/GageHud/mod.txt" )
	Holo:Save()
end
function Holo:TextureExists( texture )
	local files = file.GetFiles("assets/mod_overrides/HoloHud/guis/textures/pd2")
	if files ~= false then
		for k, v in pairs(files) do
			if v == texture..".texture" then
				return true
			end
		end
	else
		return false
	end	
	return false
end

function Holo:init()
	Holo:CheckForHuds()
	Holo:Load()
    HoloAlpha = Holo.options.MainAlpha
    teammatebg_alpha = Holo.options.teammatebg_alpha
    teammate_text_color = self:GetColor("teammate_text_color")
    waypoints_alpha = Holo.options.waypoints_alpha
	--Top 
	objective_box_color = self:GetColor("objectivebox_color")
	Timerbg_color = self:GetColor("timerbox_color")
	Assault_color = self:GetColor("assaultbox_color")
	Hostage_color = self:GetColor("hostagebox_color")
	Noreturn_color = self:GetColor("noreturnbox_color")	
	Casing_color = self:GetColor("casingbox_color")	
	HudFrame_color = self:GetColor("boxframe_color")
	Objective_text_color = self:GetColor("objectivebox_text_color")
	Assault_text_color = self:GetColor("assaultbox_text_color")
	Casing_text_color = self:GetColor("casingbox_text_color")
	Hostage_text_color = self:GetColor("hostagebox_text_color")
	Noreturn_text_color = self:GetColor("noreturnbox_text_color")
	teammatebg_color = self:GetColor("teammatebg_color")
	--Lower 
	Selectwep_color = self:GetColor("selectwep_color")
	Pickups_color = self:GetColor("pickups_color")
	Equipments_color = self:GetColor("equipments_color")
    HealthNum_color = self:GetColor("HealthNum_text_color")
    HealthNum_negative = self:GetColor("HealthNum_negative_text_color")

    --Other
	StaminaNum_color = self:GetColor("StaminaNum_text_color")
	StaminaNum_negative_color = self:GetColor("StaminaNum_negative_text_color")	
	Timer_text_color = self:GetColor("timerbox_text_color")
	hintbox_color = self:GetColor("hintbox_color")
	hintbox_text_color = self:GetColor("hintbox_text_color")
	objremindbox_color = self:GetColor("objremindbox_color")
	objremindbox_text_color = self:GetColor("objremindbox_text_color")
	carrybox_color = self:GetColor("carrybox_color")
	carrybox_text_color = self:GetColor("carrybox_text_color")
	Waypoint_color = self:GetColor("Waypoint_color")
	--Info
    hudbox_enable = Holo.options.hudbox_enable
    Infohud_enable = Holo.options.Infohud_enable
    Infotimer_enable = Holo.options.Infotimer_enable
    enemies_enable = Holo.options.enemies_enable
    hostages_enable = Holo.options.hostages_enable
    civis_enable = Holo.options.civis_enable
    InfoTimers_max = Holo.options.Infotimer_max 
    InfoTimers_size = Holo.options.Infotimer_size or 48 
    InfoTimers_bg_color = self:GetColor("Infotimer_color")
    InfoTimers_bg_jammed_color = self:GetColor("Infojammed_color")
    InfoTimers_text_color = self:GetColor("Infotimer_text_color")
    Infobox_text_color = self:GetColor("Infobox_text_color")
    civis_bg_color = self:GetColor("civis_bg_color") 
    enemies_bg_color = self:GetColor("enemies_bg_color") 
	Stamina_size = Holo.options.Stamina_size or 42
	pagers_bg_color = self:GetColor("pagers_bg_color") 
	gagepacks_bg_color = self:GetColor("gagepacks_bg_color") 
	_G.Holo_Menu_enable = Holo.options.Menu_enable
	--Menu
    Holomenu_color_normal = self:GetColor("Menu_color")
    Holomenu_color_highlight = self:GetColor("Menu_highlight_color")
    Holomenu_color_background = self:GetColor("Menu_bgcolor")
    Holomenu_color_tab = self:GetColor("Menu_tabcolor")
    Holomenu_color_tabtext = self:GetColor("Menu_tab_textcolor")
    Holomenu_color_tab_highlight = self:GetColor("Menu_highlight_tabcolor")
    Holomenu_color_marker = self:GetColor("Menu_markercolor")
    Holomenu_markeralpha = Holo.options.Menu_markeralpha
    Holomenu_textsize = Holo.textsizes[Holo.options.Menu_textsize]
end
function Holo:update()
  	HoloColor = Holo.colors[math.min(Holo.options.Holocolor + 1, #self.colors)].color
	HoloAlpha = Holo.options.MainAlpha
  	teammatebg_alpha = Holo.options.teammatebg_alpha
    waypoints_alpha = Holo.options.waypoints_alpha
	Holo.colors[1].color = HoloColor

	teammate_text_color = self:GetColor("teammate_text_color")
	teammatebg_color = self:GetColor("teammatebg_color")
	objective_box_color = self:GetColor("objectivebox_color")
	Timerbg_color = self:GetColor("timerbox_color")
	Assault_color = self:GetColor("assaultbox_color")
	Hostage_color = self:GetColor("hostagebox_color")
	Noreturn_color = self:GetColor("noreturnbox_color")	
	Casing_color = self:GetColor("casingbox_color")	
	HudFrame_color = self:GetColor("boxframe_color")
	Selectwep_color = self:GetColor("selectwep_color")
	Pickups_color = self:GetColor("pickups_color")
	Equipments_color = self:GetColor("equipments_color")
    HealthNum_color = self:GetColor("HealthNum_text_color")
    HealthNum_negative = self:GetColor("HealthNum_negative_text_color")	
	StaminaNum_color = self:GetColor("StaminaNum_text_color")
	StaminaNum_negative_color = self:GetColor("StaminaNum_negative_text_color")	
	Objective_text_color = self:GetColor("objectivebox_text_color")
	Assault_text_color = self:GetColor("assaultbox_text_color")
	Casing_text_color = self:GetColor("casingbox_text_color")
	Hostage_text_color = self:GetColor("hostagebox_text_color")
	Noreturn_text_color = self:GetColor("noreturnbox_text_color")
	Timer_text_color = self:GetColor("timerbox_text_color")
    InfoTimers_max = Holo.options.Infotimer_max 
    InfoTimers_bg_jammed_color = self:GetColor("Infojammed_color")
    InfoTimers_size = Holo.options.Infotimer_size 
    InfoTimers_bg_color = self:GetColor("Infotimer_color")
    InfoTimers_text_color = self:GetColor("Infotimer_text_color")
    Infobox_text_color = self:GetColor("Infobox_text_color")
    civis_bg_color = self:GetColor("civis_bg_color")
    enemies_bg_color = self:GetColor("enemies_bg_color") 
    pagers_bg_color = self:GetColor("pagers_bg_color") 
    gagepacks_bg_color = self:GetColor("gagepacks_bg_color") 
   	hintbox_color = self:GetColor("hintbox_color")
	hintbox_text_color = self:GetColor("hintbox_text_color")
	Stamina_size = Holo.options.Stamina_size or 42
	Waypoint_color = self:GetColor("Waypoint_color")
    Holomenu_color_normal = self:GetColor("Menu_color")
    Holomenu_color_highlight = self:GetColor("Menu_highlight_color")
    Holomenu_color_background = self:GetColor("Menu_bgcolor")
    Holomenu_color_tab = self:GetColor("Menu_tabcolor")
    Holomenu_color_tabtext = self:GetColor("Menu_tab_textcolor")
    Holomenu_color_tab_highlight = self:GetColor("Menu_highlight_tabcolor")
    Holomenu_color_marker = self:GetColor("Menu_markercolor")
    Holomenu_markeralpha = Holo.options.Menu_markeralpha
    if managers.hud ~= nil then
		if hudbox_enable then
			managers.hud._hud_assault_corner:update()
			managers.hud._hud_objectives:update()
		    managers.hud._hud_heist_timer:update()
	    end
	    if managers.hud.waypoints_update then
	    	managers.hud:waypoints_update()
	    end
	    if Infohud_enable and self._hudinfo then
			self._hudinfo:update_infos()
	    end
		if managers.hud._teammate_panels[managers.hud.PLAYER_PANEL].update and (not Holo.options.PDTHHud_support or not pdth_hud.loaded_options.Ingame.MainHud) and not Holo.options.GageHud_support then
			managers.hud._teammate_panels[managers.hud.PLAYER_PANEL]:update()
			if managers.hud._teammate_panels[3] then
 				managers.hud._teammate_panels[3]:update()
			end			
			if managers.hud._teammate_panels[2] then
 				managers.hud._teammate_panels[2]:update()
			end			
			if managers.hud._teammate_panels[1] then
 				managers.hud._teammate_panels[1]:update()
			end
	    end
	    managers.hud._hud_hint:update()
	    if not Holo.options.PDTHHud_support or not pdth_hud.loaded_options.Ingame.Objectives then
	   		managers.hud._hud_presenter:update()
	   	end
	    managers.hud._hud_temp:update()  
	end
	Holo.menu:update()
end
function Holo:GetColor(option)
	if Holo.options[option] and Holo.colors[Holo.options[option]].color then
		return Holo.colors[Holo.options[option]].color or Color.white
	else
		return Color.white
	end
end
if not Holo.setup then
 	Holo:Load()
	for k, v in ipairs(Holo.colors) do
	    table.insert(HoloColors, v.menu_name)
	end
	Holo.options.Defaults = {
		assaultbox_color = 10,
		assaultbox_text_color = 6,
		casingbox_color = 1,
		casingbox_text_color = 11,
		noreturnbox_color = 9,
		noreturnbox_text_color = 6,
		hostagebox_color = 1,
		hostagebox_text_color = 6,
		objectivebox_color = 1,
		objectivebox_text_color = 11,
		objremindbox_color = 1,
		objremindbox_text_color = 11,
		hintbox_color = 1,
		hintbox_text_color = 6,
		carrybox_color = 1,
		carrybox_text_color = 11,
		timerbox_color = 1,
		timerbox_text_color = 11,
		boxframe_color = 11,
		selectwep_color = 1,
		equipments_color = 11,
		pickups_color = 1,
		StaminaNum_text_color = 11,
		StaminaNum_negative_text_color = 9,
		HealthNum_text_color = 1,
		HealthNum_negative_text_color = 9,
		Health_Color = 1,
		Progress_active_color = 1,
		waypoints_alpha = 0.75,
		waypoints_aiming_alpha = 0.5,
		Holo_lang = 1,
		Progress_invalid_color = 7,
		Waypoint_color = 1,
		HoxHud_support = false,
		Menu_enable = true,
		Assaultphase_enable = true,
		Shield_Color = 5,
		teammatebg_color = 6,
		teammate_text_color = 11,
		teammatebg_alpha = 0.4,
		Loading_enable = true,
		InfoTimers_enable = true,
		assaultbox_enable = true,
		MainAlpha = 0.8,
		hudline_enable = false,
		voice_enable = true,
		hudbox_enable = true,
		menu_color = 11,
		civis_bg_color = 1,
		enemies_bg_color = 1,
		Infobox_text_color = 6,
		HealthNum = true,
		HealthNumTM = true,
		stamina_enable = false,
		enemies_enable = true,
		flashing_enable = false,
		Menu_textsize = 2,
		civis_enable = true,
		chat_enable = true,
		Menu_highlight_tabcolor = 1,
		pagers_enable = true,
		pagers_bg_color = 1,
		Menu_bgcolor = 7,
		Menu_tabcolor = 11,
		hudteammate_enable = true,
		Menu_tab_textcolor = 6,
		Menu_markercolor = 1,
		Menu_markeralpha = 1,
		Menu_color = 11,
		Menu_highlight_color = 6,
		hostages_enable = true,
		Timerbg_enable = true,
		Holomenu_lobby = true,
		Holomenu_crimenet = true,
		Baganim_disable = true,
		Frame_enable = false,
		Infobox_max = 3,
		Holocolor = 1,
		truetime = false,
		Frame_style = 1,
		StaminaNum_color = 11,
		StaminaNum_negative_color = 9,
		totalammo_enable = false,
		colorbg_enable = true,
		info_ypos = 90,
		info_xpos = 1235,
		stamina_ypos = 360,
		stamina_xpos = 1145,
		Infohud_enable = true,
		Infotimer_enable = true,
		ECMtimer_enable = true,
		gagepacks_bg_color = 1,
		gagepacks_enable = false,
		Drilltimer_enable = true,
		Digitaltimer_enable = true,
		waypoints_enable = true,
		Infotimer_color = 1,
		Infojammed_color = 9,
		Infotimer_text_color = 6,
		Infotimer_size = 48,
		Stamina_size = 42,
		Infotimer_max = 5,
	}
	for option, value in pairs(Holo.options.Defaults) do
		if Holo.options[option] == nil then
			Holo.options[option] = value
		end
	end
	Holo.options.Holocolor = Holo.options.Holocolor or 1
  	HoloColor = Holo.colors[math.min(Holo.options.Holocolor + 1, #Holo.colors)].color
 	Holo.colors[1].color = HoloColor	
 	log("[HoloHUD] loaded all options")
 	Holo.setup = true
end
