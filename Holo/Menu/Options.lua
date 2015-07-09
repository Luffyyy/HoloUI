_G.Holo = _G.Holo or {}
Holo.mod_path = ModPath
Holo._data_path = SavePath .. "HoloSave.txt"
Holo.options = {} 
Holo.options_menu = "Holo_menu"
Holo.Textures = "assets/mod_overrides/HoloHud/guis/textures/"
Holo.options_colors = "Holo_colors_menu"
Holo.options_text = "Holo_text_menu"
local Infomsg = QuickMenu:new( "Warning!", "To change this option color you have to enable HoloHud top Hud.", {} )
function Holo:Save()

	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end
function Holo:Replace(NewFile, OldFile)
local NewF = io.open(NewFile, "rb")
 if NewF == nil then
 local Errormsg = QuickMenu:new( "Error!", "The file : "..NewFile.." is missing. the selected color cannot be applied, for the problem to be fixed try to reinstall HoloHud or force update.", {} )
 Errormsg:Show()
 else
  local GetTexture = NewF:read("*all") --Getting the new file
  local OldF = io.open(Holo.Textures .. "pd2/" .. OldFile, "wb")  
  OldF:write(GetTexture) --Replacing the new with old.
  os.remove(Holo.Textures .. "pd2/" .. OldFile)
  OldF:close()
  NewF:close()
 end

end

function RemoveOLD(texture) --Removes unused textures.

os.remove(Holo.Textures .."pd2/"..texture..".texture")

end

function Huds_Check(ToCheck) 
if ToCheck == HoxHud then 
local Check = io.open("lib/Native/HoxHud.dll", "rb" )
if Check == nil then 
Holo.options.HoxHud_support = false 
else
Holo.options.HoxHud_support = true 
end
end
if ToCheck == PDTH then 
local Check = io.open("mods/PDTH Hud/mod.txt", "rb" )
if Check == nil then 
Holo.options.PDTHHud_support = false 
else
Holo.options.PDTHHud_support = true 
end
end
Holo:Save()
end
function Holo:Load()
	local file = io.open( self._data_path, "r" )

	if file then
		self.options = json.decode( file:read("*all") )
		file:close()
	end
end
if not Holo.setup then
	Holo:Load()
	Huds_Check(HoxHud)
	Huds_Check(PDTHHud)
	if Holo.options.Health_Color == nil then
	Holo.options.Health_Color = 1
	Holo:Save()
	end
	if Holo.options.HoxHud_support == nil then
	Holo.options.HoxHud_support = false
	Holo:Save()
	end
	if Holo.options.Menu_enable == nil then
	Holo.options.Menu_enable = true
	Holo:Save()
	end
	if Holo.options.Shield_Color == nil then
	Holo.options.Shield_Color = 1
	Holo:Save()
	end
	if Holo.options.MainAlpha == nil then
	Holo.options.MainAlpha = 0.8
	Holo:Save()
	end
	if Holo.options.HudBox_enable == nil then 
	Holo.options.HudBox_enable = true
	Holo:Save()
	end
	if Holo.options.HealthNum == nil then 
	Holo.options.HealthNum = true
	Holo:Save()
	end
	if Holo.options.HealthNumTM == nil then 
	Holo.options.HealthNumTM = true
	Holo:Save()
	end
	if Holo.options.Stamina_enable == nil then 
	Holo.options.Stamina_enable = true
	Holo:Save()
	end
	if Holo.options.Hostage_enable == nil then 
	Holo.options.Hostage_enable = true
	Holo:Save()
	end
	if Holo.options.Selectwep_enable == nil then 
	Holo.options.Selectwep_enable = true
	Holo:Save()
	end
    if Holo.options.Timerbg_enable == nil then 
	Holo.options.Timerbg_enable = true
	Holo:Save()
	end
    if Holo.options.Baganim_disable == nil then 
	Holo.options.Baganim_disable = true
	Holo:Save()
	end
	if Holo.options.Frame_enable == nil then 
	Holo.options.Frame_enable = false
	Holo:Save()
	end
	if Holo.options.Holo_color == nil then 
	Holo.options.Holo_color = 1
	Holo:Save()
	end
	if Holo.options.Obj_color == nil then 
	Holo.options.Obj_color = 1
	Holo:Save()
	end
	if Holo.options.Frame_color == nil then 
	Holo.options.Frame_color = 11
	Holo:Save()
    if Holo.options.Timerbg_color == nil then 
	Holo.options.Timerbg_color = 1
	Holo:Save()
	end
	if Holo.options.Equipments_color == nil then 
	Holo.options.Equipments_color = 1
	Holo:Save()
	end
	if Holo.options.Select_language == nil then 
	Holo.options.Select_language = 1
	Holo:Save()
	end
	if Holo.options.Pickups_color == nil then 
	Holo.options.Pickups_color = 1
	Holo:Save()
	end
	if Holo.options.Assault_color == nil then 
	Holo.options.Assault_color = 10
	Holo:Save()
	end
	if Holo.options.Casing_color == nil then 
	Holo.options.Casing_color = 1
	Holo:Save()
	end
	if Holo.options.Hostage_color == nil then 
	Holo.options.Hostage_color = 1
	Holo:Save()
	end
  	if Holo.options.HealthNum_color == nil then 
	Holo.options.HealthNum_color = 2
	Holo:Save()
	end  
	if Holo.options.Assault_enable == nil then 
	Holo.options.Assault_enable = true 
	Holo:Save()
	end  
	 if Holo.options.StaminaNum_color == nil then 
	Holo.options.StaminaNum_color = 10
	Holo:Save()
	end  
    if Holo.options.Assault_text == nil then 
	Holo.options.Assault_text = 2
	Holo:Save()
	end
    if Holo.options.Casing_text == nil then 
	Holo.options.Casing_text = 1
	Holo:Save()
	end
    if Holo.options.Noreturn_text == nil then 
	Holo.options.Noreturn_text = 1
	Holo:Save()
	end
    if Holo.options.Objective_text == nil then 
	Holo.options.Objective_text = 1
	Holo:Save()
	end
    if Holo.options.Timer_text == nil then 
	Holo.options.Timer_text = 1
	Holo:Save()
	end
    if Holo.options.Hostage_text == nil then 
	Holo.options.Hostage_text = 1
	Holo:Save()
	end
	if Holo.options.Noreturn_color == nil then 
	Holo.options.Noreturn_color = 9
	Holo:Save()
	end
	if Holo.options.Selectwep_color == nil then 
	Holo.options.Selectwep_color = 1
	Holo:Save()
	end
	Holo:Load()
	Holo.setup = true
	log("Holohud-Loaded settings.")
end
local Holo_color = { 
	"Holo_Color1",
    "Holo_Color2",
    "Holo_Color3",
    "Holo_Color4",
    "Holo_Color5",
    "Holo_Color6",
	"Holo_Color7",
	"Holo_Color8",
	"Holo_Color9",
    "Holo_Color10",
    "Holo_Color11",
    "Holo_Color12",
    "Holo_Color13",
    "Holo_Color14",
}

local HoloColors = {
    "Holo_Color", --Follows Holo_color	
    "Holo_Color1", --Blue
    "Holo_Color2", --Orange
    "Holo_Color3", --Green
    "Holo_Color4", --Pink
    "Holo_Color5", --Black
    "Holo_Color6", --Grey
    "Holo_Color7", --DBlue
	"Holo_Color8", --Red
	"Holo_Color9", --Yellow
	"Holo_Color10",--White
	"Holo_Color11",--Cyan
	"Holo_Color12", --Purple
	"Holo_Color13", --Spring green
	"Holo_Color14", --Light blue 
} 
local Radial_Colors = {
    "Holo_Color1",
    "Holo_Color2",
    "Holo_Color3", 
    "Holo_Color4", 
	"Holo_Color9",
    "Holo_Color10", 
	"Holo_Color8", 
	"Holo_Color11",
} 

local Tex_Colors_Dir = {
    "Blue.texture",
    "Orange.texture",
    "Green.texture", 
    "Pink.texture", 
	"Yellow.texture",
    "White.texture", 
	"Red.texture", 
	"Cyan.texture",
} 
local TextColors = {
    "Holo_Color10",--White
    "Holo_Color5", --Black
	
} 
Holo.Languages = {
   "en.txt",
   "pl.txt",
} 
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Holo", function( loc )
	
	Holo.options.Language = Holo.options.Language or 1

	local selected_language = Holo.Languages[Holo.options.Language]
	
	loc:load_localization_file( Holo.mod_path .. "/loc/" .. selected_language)
	
	-- Load default localization as a backup for strings that don't exist
	loc:load_localization_file( Holo.mod_path .. "/loc/" .. "en.txt", false )
end)


	Hooks:Add("MenuManagerSetupCustomMenus", "HolohudOptions", function( menu_manager, nodes )
		MenuHelper:NewMenu( Holo.options_menu )
		MenuHelper:NewMenu( Holo.options_colors )
		MenuHelper:NewMenu( Holo.options_text )
	end)
  
	Hooks:Add("MenuManagerPopulateCustomMenus", "HolohudOptions", function( menu_manager, nodes )
    MenuCallbackHandler.Select_language = function(self, item)
		Holo.options.Language = tonumber(item:value())
		Holo:Save()
	end
	MenuCallbackHandler.HudBox_enable = function(self, item)
		Holo.options.HudBox_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end
		MenuCallbackHandler.Hostage_enable = function(self, item)
		Holo.options.Hostage_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end		
	    MenuCallbackHandler.Selectwep_enable = function(self, item)
		Holo.options.Selectwep_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end  
	    MenuCallbackHandler.Menu_enable = function(self, item)
		Holo.options.Menu_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end
        MenuCallbackHandler.Timerbg_enable = function(self, item)
		Holo.options.Timerbg_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end
        MenuCallbackHandler.Baganim_disable = function(self, item)
		Holo.options.Baganim_disable = (item:value() == "on" and true or false)
		Holo:Save()
	end
		MenuCallbackHandler.Health_Color = function(self, item)
		Holo.options.Health_Color = item:value()
		Holo:Save()
		Holo:Replace(Holo.mod_path .."Hud/Textures/Health"..Tex_Colors_Dir[item:value()], "hud_health.texture")		
	end
		MenuCallbackHandler.Shield_Color = function(self, item)
		Holo.options.Shield_Color = item:value()
		Holo:Save()
		Holo:Replace(Holo.mod_path .."Hud/Textures/Shield"..Tex_Colors_Dir[item:value()], "hud_shield.texture")		
	end
	    MenuCallbackHandler.Frame_enable = function(self, item)
		Holo.options.Frame_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end
		MenuCallbackHandler.HealthNum = function(self, item)
		Holo.options.HealthNum = (item:value() == "on" and true or false)
		
		
		Holo:Save()
	end
		MenuCallbackHandler.Stamina_enable = function(self, item)
		Holo.options.Stamina_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end
		MenuCallbackHandler.Assault_enable = function(self, item)
		Holo.options.Assault_enable = (item:value() == "on" and true or false)
		Holo:Save()
	end
	    MenuCallbackHandler.HealthNum_color = function(self, item)
		Holo.options.HealthNum_color = item:value()		
		Holo:Save()
	end
		MenuCallbackHandler.StaminaNum_color = function(self, item)
		Holo.options.StaminaNum_color = item:value()
		Holo:Save()
	end
	    MenuCallbackHandler.HealthNumTM = function(self, item)
		Holo.options.HealthNumTM = (item:value() == "on" and true or false)
		Holo:Save()
	end
		MenuCallbackHandler.Holo_color = function(self, item)
		Holo.options.Holo_color = item:value()
		Holo:Save()
	end
    	MenuCallbackHandler.Timerbg_color = function(self, item)
		Holo.options.Timerbg_color = item:value()
		Holo:Save()
	end
		MenuCallbackHandler.Obj_color = function(self, item)
		Holo.options.Obj_color = item:value()
		Holo:Save()
	end	
		MenuCallbackHandler.Selectwep_color = function(self, item)
		Holo.options.Selectwep_color = item:value()
		Holo:Save()
		
	end	
		MenuCallbackHandler.Equipments_color = function(self, item)
		Holo.options.Equipments_color = item:value()
		Holo:Save()
	end	
		MenuCallbackHandler.Pickups_color = function(self, item)
		Holo.options.Pickups_color = item:value()
		Holo:Save()
	end	
		MenuCallbackHandler.Assault_color = function(self, item)
		Holo.options.Assault_color = item:value()
        if Holo.options.HudBox_enable == false then Infomsg:Show() end
		Holo:Save()
	end	
        MenuCallbackHandler.Assault_text = function(self, item)
		Holo.options.Assault_text = item:value()
		if Holo.options.HudBox_enable == false then Infomsg:Show() end
		Holo:Save()
	end	
        MenuCallbackHandler.Casing_text = function(self, item)
		Holo.options.Casing_text = item:value()
		if Holo.options.HudBox_enable == false then Infomsg:Show() end
		Holo:Save()
	end	
        MenuCallbackHandler.Noreturn_text = function(self, item)
		Holo.options.Noreturn_text = item:value()
		if Holo.options.HudBox_enable == false then Infomsg:Show() end
		Holo:Save()
	end	
        MenuCallbackHandler.Objective_text = function(self, item)
		Holo.options.Objective_text = item:value()
		if Holo.options.HudBox_enable == false then Infomsg:Show() end
		Holo:Save()
	end	
        MenuCallbackHandler.Timer_text = function(self, item)
		Holo.options.Timer_text = item:value()
		Holo:Save()
	end	
        MenuCallbackHandler.Hostage_text = function(self, item)
		Holo.options.Hostage_text = item:value()
		Holo:Save()
	end	
        MenuCallbackHandler.Frame_color = function(self, item)
		Holo.options.Frame_color = item:value()
		Holo:Save()
	end	
		MenuCallbackHandler.Casing_color = function(self, item)
		Holo.options.Casing_color = item:value()
		Holo:Save()
	end	
		MenuCallbackHandler.Hostage_color = function(self, item)
		Holo.options.Hostage_color = item:value()
		Holo:Save()
	end	
		MenuCallbackHandler.Noreturn_color = function(self, item)
		Holo.options.Noreturn_color = item:value()
		Holo:Save()
	end
		MenuCallbackHandler.MainAlpha = function(self, item)
		Holo.options.MainAlpha = item:value()
		Holo:Save()
	end	
		MenuCallbackHandler.Reset_button = function(self, item)
		local Toggle_boxes = {
			["HudBox_enable"] = true,
			["Hostage_enable"] = true,
            ["Selectwep_enable"] = true,
            ["Timerbg_enable"] = true,
            ["Baganim_disable"] = true,       
            ["Frame_enable"] = true,			
            ["HealthNum"] = true,			
            ["HealthNumTM"] = true,			
            ["Stamina_enable"] = true,			
            ["Menu_enable"] = true,			
		}
		local Unticked = {["Frame_enable"] = true}
		local Main_Opacity = {["MainAlpha"] = true}
		local Assault_enable = {["Assault_enable"] = true}
		MenuHelper:ResetItemsToDefaultValue( item, Toggle_boxes, true )
		MenuHelper:ResetItemsToDefaultValue( item, Unticked, false )
		MenuHelper:ResetItemsToDefaultValue( item, Main_Opacity , 0.80)
		MenuHelper:ResetItemsToDefaultValue( item, Assault_enable , true)
	end
		MenuCallbackHandler.Reset_colors = function(self, item)
		local ResetToOne = {
            ["Holo_color"] = true,		
			["Timerbg_color"] = true,	
			["Health_Color"] = true,	
   			["Obj_color"] = true,	
			["Hostage_color"] = true,				
			["Casing_color"] = true,				
            ["Equipments_color"] = true,			
            ["Pickups_color"] = true,		
			["Selectwep_color"] = true,
		}
		local Noreturn_color = { ["Noreturn_color"] = true }
		local Assault_color = { ["Assault_color"] = true }
		local Frame_color = { ["Frame_color"] = true }
		local Shield_Color = { ["Shield_Color"] = true }
		MenuHelper:ResetItemsToDefaultValue( item, ResetToOne , 1 )
		MenuHelper:ResetItemsToDefaultValue( item, Shield_Color , 5 )
		MenuHelper:ResetItemsToDefaultValue( item, Noreturn_color, 9 )
		MenuHelper:ResetItemsToDefaultValue( item, Assault_color , 10 )
		MenuHelper:ResetItemsToDefaultValue( item, Frame_color , 11 )
	end 
		MenuCallbackHandler.Reset_text = function(self, item)
		local ResetToOne = {
   			["Casing_text"] = true,	
			["Noreturn_text"] = true,				
			["Objective_text"] = true,				
            ["Timer_text"] = true,			
            ["Hostage_text"] = true,	
		}
		local ResetToTwo = {
	    ["Assault_text"] = true,	
	    ["HealthNum_color"] = true,			
		}
		local StaminaNum_color = {["StaminaNum_color"] = true }
		MenuHelper:ResetItemsToDefaultValue( item, ResetToOne , 1 )
		MenuHelper:ResetItemsToDefaultValue( item, ResetToTwo , 2 )
		MenuHelper:ResetItemsToDefaultValue( item, StaminaNum_color, 10 )
	end 
			MenuHelper:AddMultipleChoice({
			id = "Select_language",
			title = "Select_language_title",
			desc = "Select_language_desc",
			callback = "Select_language",
			menu_id = Holo.options_menu,
			value = Holo.options.Language,
			items = {
			[1] = "en",
			[2] = "pl",
			},
			priority = 13,
			
		})
			MenuHelper:AddToggle({
			id = "HudBox_enable",
			title = "HudBox_enable_title",
			desc = "HudBox_enable_desc",
			callback = "HudBox_enable",
			icon_by_text = false,
			menu_id = Holo.options_menu,
			value = Holo.options.HudBox_enable,
			priority = 12,
	    })	
		    MenuHelper:AddToggle({
			id = "Stamina_enable",
			title = "Stamina_enable_title",
			desc = "Stamina_enable_desc",
			callback = "Stamina_enable",
			icon_by_text = false,
			menu_id = Holo.options_menu,
			value = Holo.options.Stamina_enable,
			priority = 11,
	    })	
		
		    MenuHelper:AddToggle({
			id = "HealthNum",
			title = "HealthNum_title",
			desc = "HealthNum_desc",
			callback = "HealthNum",
			icon_by_text = false,
			menu_id = Holo.options_menu,
			value = Holo.options.HealthNum,
			priority = 10,
	    })	
		    MenuHelper:AddToggle({
			id = "HealthNumTM",
			title = "HealthNumTM_title",
			desc = "HealthNumTM_desc",
			callback = "HealthNumTM",
			icon_by_text = false,
			menu_id = Holo.options_menu,
			value = Holo.options.HealthNumTM,
			priority = 9,
	    })	
        	MenuHelper:AddToggle({
			id = "Timerbg_enable",
			title = "Timerbg_enable_title",
			desc = "Timerbg_enable_desc",
			callback = "Timerbg_enable",
			icon_by_text = false,
			menu_id = Holo.options_menu,
			value = Holo.options.Timerbg_enable,
			priority = 8,
	    })	
		MenuHelper:AddToggle({
			id = "Hostage_enable",
			title = "Hostage_enable_title",
			desc = "Hostage_enable_desc",
			callback = "Hostage_enable",
			icon_by_text = false,
			disabled_color = Color.black,
			menu_id = Holo.options_menu,
			value = Holo.options.Hostage_enable,
			priority = 7,
	    })		
        	MenuHelper:AddToggle({
			id = "Baganim_disable",
			title = "Baganim_disable_title",
			desc = "Baganim_disable_desc",
			callback = "Baganim_disable",
			icon_by_text = false,
			disabled_color = Color.black,
			menu_id = Holo.options_menu,
			value = Holo.options.Baganim_disable,
			priority = 6,
	    })		
		    MenuHelper:AddToggle({
			id = "Frame_enable",
			title = "Frame_enable_title",
			desc = "Frame_enable_desc",
			callback = "Frame_enable",
			icon_by_text = false,
			disabled_color = Color.black,
			menu_id = Holo.options_menu,
			value = Holo.options.Frame_enable,
			priority = 5,
	    })		
			MenuHelper:AddToggle({
			id = "Selectwep_enable",
			title = "Selectwep_enable_title",
			desc = "Selectwep_enable_desc",
			callback = "Selectwep_enable",
			icon_by_text = false,
			disabled_color = Color.black,
			menu_id = Holo.options_menu,
			value = Holo.options.Selectwep_enable,
			priority = 4,
		})	
			MenuHelper:AddToggle({
			id = "Menu_enable",
			title = "Menu_enable_title",
			desc = "Menu_enable_desc",
			callback = "Menu_enable",
			icon_by_text = false,
			disabled_color = Color.black,
			menu_id = Holo.options_menu,
			value = Holo.options.Menu_enable,
			priority = 3,
		})	
			MenuHelper:AddToggle({
			id = "Assault_enable",
			title = "Assault_enable_title",
			desc = "Assault_enable_desc",
			callback = "Assault_enable",
			icon_by_text = false,
			disabled_color = Color.black,
			menu_id = Holo.options_menu,
			value = Holo.options.Assault_enable,
			priority = 3,
		})	
			MenuHelper:AddSlider({
            id = "MainAlpha",
            title = "MainAlpha_title",
            desc = "MainAlpha_desc",
            callback = "MainAlpha",
            value = Holo.options.MainAlpha,
            min = 0,
            max = 1,
            step = 0.5,
            show_value = true,
            menu_id = Holo.options_menu,
            priority = 0  
		})     	
		MenuHelper:AddDivider({
         id = "divider",
         size = 32,
         menu_id = Holo.options_menu,
         priority = -1,
         })
		 MenuHelper:AddButton({
			id = "Reset_button",
			title = "Reset_button_title",
			desc = "Reset_button_desc",
			callback = "Reset_button",
			menu_id = Holo.options_menu,
			priority = -2,
        })			
        --Colors menu		
			MenuHelper:AddMultipleChoice({
			id = "Holo_color",
			title = "Holo_Color_title",
			desc = "Holo_Color_desc",
			callback = "Holo_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Holo_color,
			items = Holo_color,
			priority = 13,
			
		})
			MenuHelper:AddMultipleChoice({
			id = "Health_Color",
			title = "Health_Color_title",
			desc = "Health_Color_desc",
			callback = "Health_Color",
			menu_id = Holo.options_colors,
			value = Holo.options.Health_Color,
			items = Radial_Colors,
			priority = 12,
		})   
			MenuHelper:AddMultipleChoice({
			id = "Shield_Color",
			title = "Shield_Color_title",
			desc = "Shield_Color_desc",
			callback = "Shield_Color",
			menu_id = Holo.options_colors,
			value = Holo.options.Shield_Color,
			items = Radial_Colors,
			priority = 11,
		})   
			MenuHelper:AddMultipleChoice({
			id = "Assault_color",
			title = "Assault_color_title",
			desc = "Assault_color_desc",
			callback = "Assault_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Assault_color,
			items = HoloColors,
			priority = 10,
		})   

		MenuHelper:AddMultipleChoice({
			id = "Noreturn_color",
			title = "Noreturn_color_title",
			desc = "Noreturn_color_desc",
			callback = "Noreturn_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Noreturn_color,
			items = HoloColors,
		    priority = 9,
		}) 
			MenuHelper:AddMultipleChoice({
			id = "Obj_color",
			title = "Obj_color_title",
			desc = "Obj_color_desc",
			callback = "Obj_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Obj_color,
			items = HoloColors,
			priority = 8,
		})  
		    MenuHelper:AddMultipleChoice({
			id = "Casing_color",
			title = "Casing_color_title",
			desc = "Casing_color_desc",
			callback = "Casing_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Casing_color,
			items = HoloColors,
			priority = 7,
		}) 		
		    MenuHelper:AddMultipleChoice({
			id = "Selectwep_color",
			title = "Selectwep_color_title",
			desc = "Selectwep_color_desc",
			callback = "Selectwep_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Selectwep_color,
			items = HoloColors,
			priority = 6,
		}) 
    		MenuHelper:AddMultipleChoice({
			id = "Hostage_color",
			title = "Hostage_color_title",
			desc = "Hostage_color_desc",
			callback = "Hostage_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Hostage_color,
			items = HoloColors,
			priority = 5,
		})  
            MenuHelper:AddMultipleChoice({
			id = "Timerbg_color",
			title = "Timerbg_color_title",
			desc = "Timerbg_color_desc",
			callback = "Timerbg_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Timerbg_color,
			items = HoloColors,
			priority = 4,
		})  
		    MenuHelper:AddMultipleChoice({
			id = "Equipments_color",
			title = "Equipments_color_title",
			desc = "Equipments_color_desc",
			callback = "Equipments_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Equipments_color,
			items = HoloColors,
			priority = 3,
		})  
		    MenuHelper:AddMultipleChoice({
			id = "Pickups_color",
			title = "Pickups_color_title",
			desc = "Pickups_color_desc",
			callback = "Pickups_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Pickups_color,
			items = HoloColors,
			priority = 2,
		})  
			MenuHelper:AddMultipleChoice({
			id = "Frame_color",
			title = "Frame_color_title",
			desc = "Frame_color_desc",
			callback = "Frame_color",
			menu_id = Holo.options_colors,
			value = Holo.options.Frame_color,
			items = HoloColors,
			priority = -1,
		})  
		    MenuHelper:AddDivider({
            id = "divider2",
            size = 32,
            menu_id = Holo.options_colors,
            priority = -16,
        })
			MenuHelper:AddButton({
			id = "Reset_colors",
			title = "Reset_colors_title",
			desc = "Reset_colors_desc",
			callback = "Reset_colors",
			menu_id = Holo.options_colors,
			priority = -17,
        })		
        --Text menu
        	MenuHelper:AddMultipleChoice({
			id = "HealthNum_color",
			title = "HealthNum_color_title",
			desc = "HealthNum_color_desc",
			callback = "HealthNum_color",
			menu_id = Holo.options_text,
			value = Holo.options.HealthNum_color,
			items = HoloColors,
			priority = 10,
		})  
			MenuHelper:AddMultipleChoice({
			id = "StaminaNum_color",
			title = "StaminaNum_color_title",
			desc = "StaminaNum_color_desc",
			callback = "StaminaNum_color",
			menu_id = Holo.options_text,
			value = Holo.options.StaminaNum_color,
			items = HoloColors,
			priority = 9,
		})  
        	MenuHelper:AddMultipleChoice({
			id = "Assault_text",
			title = "Assault_text_title",
			desc = "Assault_text_desc",
			callback = "Assault_text",
			menu_id = Holo.options_text,
			value = Holo.options.Assault_text,
			items = TextColors,
			priority = 8,
		})  
            MenuHelper:AddMultipleChoice({
			id = "Casing_text",
			title = "Casing_text_title",
			desc = "Casing_text_desc",
			callback = "Casing_text",
			menu_id = Holo.options_text,
			value = Holo.options.Casing_text,
			items = TextColors,
			priority = 7,
		})  
            MenuHelper:AddMultipleChoice({
			id = "Noreturn_text",
			title = "Noreturn_text_title",
			desc = "Noreturn_text_desc",
			callback = "Noreturn_text",
			menu_id = Holo.options_text,
			value = Holo.options.Noreturn_text,
			items = TextColors,
			priority = 6,
		})  
            MenuHelper:AddMultipleChoice({
			id = "Objective_text",
			title = "Objective_text_title",
			desc = "Objective_text_desc",
			callback = "Objective_text",
			menu_id = Holo.options_text,
			value = Holo.options.Objective_text,
			items = TextColors,
			priority = 5,
		})  
            MenuHelper:AddMultipleChoice({
			id = "Timer_text",
			title = "Timer_text_title",
			desc = "Timer_text_desc",
			callback = "Timer_text",
			menu_id = Holo.options_text,
			value = Holo.options.Timer_text,
			items = TextColors,
			priority = 4,
		})  
            MenuHelper:AddMultipleChoice({
			id = "Hostage_text",
			title = "Hostage_text_title",
			desc = "Hostage_text_desc",
			callback = "Hostage_text",
			menu_id = Holo.options_text,
			value = Holo.options.Hostage_text,
			items = TextColors,
			priority = 3,
		})  
        	MenuHelper:AddButton({
			id = "Reset_text",
			title = "Reset_colors_title",
			desc = "Reset_colors_desc",
			callback = "Reset_text",
			menu_id = Holo.options_text,
			priority = 2,
        })		
end)

Hooks:Add("MenuManagerBuildCustomMenus", "HolohudOptions", function(menu_manager, nodes)
		nodes[Holo.options_menu] = MenuHelper:BuildMenu( Holo.options_menu )
		MenuHelper:AddMenuItem( MenuHelper.menus.lua_mod_options_menu, Holo.options_menu, "Options_title", "Options_desc", 1 )

		nodes[Holo.options_colors] = MenuHelper:BuildMenu(Holo.options_colors )
		MenuHelper:AddMenuItem( MenuHelper.menus[Holo.options_menu], Holo.options_colors , "Options_colors_title", "Options_colors_desc", 15)
		
		nodes[Holo.options_text] = MenuHelper:BuildMenu(Holo.options_text )
		MenuHelper:AddMenuItem( MenuHelper.menus[Holo.options_menu], Holo.options_text , "Options_text_title", "Options_text_desc", 16)
	end)
end