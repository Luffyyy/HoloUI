_G.Holo = _G.Holo or {}
Holo.dofiles = {
	"menu/options.lua",
	"menu/optionsmenu.lua"
}
Holo.hook_files = {
 	["lib/setups/setup"] = "setup.lua",
 	["lib/managers/menu/items/menuitemmultichoice"] = "menu/menuitemmultichoice.lua",
    ["lib/managers/menu/blackmarketgui"] = "menu/blackmarketgui.lua",
    ["lib/managers/menu/renderers/menunodebasegui"] = "menu/menunodebasegui.lua",
    ["lib/managers/menu/renderers/menunodeskillswitchgui"] = "menu/menunodeskillswitchgui.lua",
    ["lib/managers/menu/textboxgui"] = "menu/textboxgui.lua",
    ["lib/managers/menu/imageboxgui"] = "menu/imageboxgui.lua",
    ["lib/utils/levelloadingscreenguiscript"] = "menu/menuloading.lua",
    ["lib/managers/menu/renderers/menunodepreplanninggui"] = "menu/menupreplanning.lua",
    ["lib/managers/menu/playerprofileguiobject"] = "menu/menuprofile.lua", 
    ["lib/managers/menu/renderers/menunodecrimenetgui"] = "menu/menucrimenet.lua",
    ["lib/managers/menu/menurenderer"] = "menu/menurenderer.lua",
    ["lib/managers/menu/newsfeedgui"] = "menu/newsfeedgui.lua",
    ["lib/managers/menumanager"] = "menu/menumanager.lua",
    
    ["lib/managers/menu/menupauserenderer"] = "menu/menupause.lua", 
    ["lib/units/enemies/cop/copbrain"] = "hud/copbrain.lua",
    ["lib/managers/menu/menunodegui"] = "menu/menunodegui.lua",
    ["lib/managers/mousepointermanager"] = "menu/mousepointermanager.lua",
    ["lib/managers/menu/menukitrenderer"] = "menu/menukit.lua",
    ["lib/managers/menu/renderers/menunodeupdatesgui"] = "menu/menunodeupdatesgui.lua",
    ["lib/managers/menu/infamytreegui"] = "menu/infamytreegui.lua",
    ["lib/managers/menu/boxguiobject"] = "menu/boxguiobject.lua",
    ["lib/managers/crimenetmanager"] = "menu/crimenetmanager.lua",
    ["lib/network/base/clientnetworksession"] = "hud/clientnetworksession.lua",
    ["lib/network/handlers/unitnetworkhandler"] = "hud/unitnetworkhandler.lua",
    ["lib/managers/menu/playerinventorygui"] = "menu/playerinventorygui.lua",
    ["lib/managers/menu/stageendscreengui"] = "menu/stageendscreengui.lua",
    ["lib/managers/menu/lootdropscreengui"] = "menu/lootdropscreengui.lua",
    ["lib/managers/menu/menubackdropgui"] = "menu/menubackdropgui.lua",
    ["lib/managers/menu/renderers/menunodejukeboxgui"] = "menu/menunodejukeboxgui.lua",
    ["lib/managers/menu/items/menuitemcustomizecontroller"] = "menu/menuitemcustomizecontroller.lua",
    ["lib/managers/menu/skilltreegui"] = "menu/skilltreegui.lua",
    ["lib/managers/menu/missionbriefinggui"] = "menu/missionbriefinggui.lua", 

    ["lib/units/props/digitalgui"] = "hud/digitalgui.lua",
    ["lib/units/props/timergui"] = "hud/timergui.lua",
    ["lib/units/equipment/ecm_jammer/ecmjammerbase"] = "hud/ecmjammerbase.lua",
    ["lib/managers/hud/hudheisttimer"] = "hud/heisttimer.lua",
    ["lib/managers/hud/hudstageendscreen"] = "hud/hudstageendscreen.lua",
    ["lib/managers/hud/hudmissionbriefing"] = "hud/hudmissionbriefing.lua",
    ["lib/managers/hud/hudlootscreen"] = "hud/hudlootscreen.lua", 
    ["lib/managers/hud/hudplayerdowned"] = "hud/huddowned.lua", 
    ["lib/managers/hud/hudplayercustody"] = "hud/hudcustody.lua",
    ["lib/managers/hud/hudassaultcorner"] = "hud/assaultbox.lua", 
    ["lib/managers/hud/hudstatsscreen"] = "hud/hudstatsscreen.lua", 
    ["lib/managers/hud/hudobjectives"] = "hud/hudobjectives.lua",
    ["lib/managers/hud/hudchat"] = "hud/hudchat.lua",
    ["lib/managers/hud/hudteammate"] = "hud/hudteammate.lua",
    ["lib/managers/hud/hudtemp"] = "hud/hudtemp.lua",
    ["lib/managers/hud/hudhint"] = "hud/hudhint.lua",
    ["lib/managers/hud/hudpresenter"] = "hud/hudpresenter.lua",
    ["lib/managers/hudmanager"] = "hud/hudmanager.lua",
    ["lib/managers/hudmanagerpd2"] = "hud/hudmanager.lua",
}
if not Holo.setup then
	for p, d in pairs(Holo.dofiles) do
		dofile("mods/holo/" .. d)
	end
	Holo:init()
end
if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if Holo.hook_files[requiredScript] then
 		dofile( ModPath .. Holo.hook_files[requiredScript] )
	end	
end

if Hooks then
	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Holo", function( loc )
		loc:load_localization_file( "mods/holo/loc/en.txt" )	
		if Holo.options.Holo_lang == 2 and io.open("mods/holo/loc/ru.txt" ) then
			loc:load_localization_file( "mods/holo/loc/ru.txt" )	
		end
	end)
	Hooks:Add("MenuManager_Base_SetupModOptionsMenu", "Voicekey_opt", function( menu_manager, nodes )
		keybinds_menu_id = LuaModManager.Constants._keybinds_menu_id
	    lua_mod_options_menu_id = LuaModManager.Constants._lua_mod_options_menu_id
		MenuHelper:NewMenu( keybinds_menu_id )
		MenuHelper:NewMenu( lua_mod_options_menu_id )
	end)
	Hooks:Add("MenuManager_Base_PopulateModOptionsMenu", "Voicekey_opt", function( menu_manager, nodes )
		local key = LuaModManager:GetPlayerKeybind("Voice_key") or "q"
		local key2 = LuaModManager:GetPlayerKeybind("holo_options_key") or "f3"
		MenuCallbackHandler.openholohudoption = function(self)
			Holo.menu:ShowOptions()
		end	
		_G.Holo.menu = Holomenu:new()
		MenuHelper:AddKeybinding({
			id = "Voice_key",
			title = "HoloHud Voice commands",
			connection_name = "Voice_key",
			button = key,
			binding = key,
			menu_id = keybinds_menu_id,
			localized = false,
			priority = -13,
		})		
		MenuHelper:AddKeybinding({
			id = "holo_options_key",
			title = "HoloHud options menu",
			desc = "Set a key to quickly show Holohud's options menu",
			connection_name = "holo_options_key",
			button = key2,
			binding = key2,
			menu_id = keybinds_menu_id,
			localized = false,
			priority = -14,
		})	
		MenuHelper:AddButton({
			id = "HoloOptions",
			title = "Holo_Options_title",
			desc = "Holo_Options_desc",
	 		callback = "openholohudoption",
			menu_id = lua_mod_options_menu_id,
			priority = -13,
		})
	end)
	if LuaModManager:GetNumberOfJsonKeybinds() == 0 then
		Hooks:Add("MenuManager_Base_BuildModOptionsMenu", "Voicekey_opt_build", function( menu_manager, nodes )
			nodes[keybinds_menu_id] = MenuHelper:BuildMenu( keybinds_menu_id )
			MenuHelper:AddMenuItem( nodes.options, keybinds_menu_id, "base_options_menu_keybinds", "base_options_menu_keybinds_desc", "lua_mod_options_menu", "after" )
		end)
	end
end