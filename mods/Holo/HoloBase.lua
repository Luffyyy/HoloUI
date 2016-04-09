_G.Holo = _G.Holo or {}
Holo.dofiles = {
	"Menu/Options.lua",
	"Menu/OptionsMenu.lua"
}
Holo.hook_files = {
 	["lib/setups/setup"] = "setup.lua",
 	["lib/managers/menu/items/menuitemmultichoice"] = "Menu/MenuItemmultichoice.lua",
    ["lib/managers/menu/blackmarketgui"] = "Menu/BlackmarketGUI.lua",
    ["lib/managers/menu/renderers/menunodebasegui"] = "Menu/MenuNodeBaseGUI.lua",
    ["lib/managers/menu/renderers/menunodeskillswitchgui"] = "Menu/Menunodeskillswitchgui.lua",
    ["lib/managers/menu/textboxgui"] = "Menu/TextBoxGUI.lua",
    ["lib/managers/menu/imageboxgui"] = "Menu/ImageBoxGUI.lua",
    ["lib/utils/levelloadingscreenguiscript"] = "Menu/MenuLoading.lua",
    ["lib/managers/menu/renderers/menunodepreplanninggui"] = "Menu/MenuPreplanning.lua",
    ["lib/managers/menu/playerprofileguiobject"] = "Menu/MenuProfile.lua", 
    ["lib/managers/menu/renderers/menunodecrimenetgui"] = "Menu/MenuCrimenet.lua",
    ["lib/managers/menu/menurenderer"] = "Menu/MenuRenderer.lua",
    ["lib/managers/menu/newsfeedgui"] = "Menu/NewsfeedGUI.lua",
    ["lib/managers/menumanager"] = "Menu/Menumanager.lua",
    
    ["lib/managers/menu/menupauserenderer"] = "Menu/MenuPause.lua", 
    -- ["lib/units/enemies/cop/copbrain"] = "Hud/copbrain.lua", -- missing
    ["lib/managers/menu/menunodegui"] = "Menu/MenuNodeGUI.lua",
    ["lib/managers/mousepointermanager"] = "Menu/MousePointerManager.lua",
    ["lib/managers/menu/menukitrenderer"] = "Menu/MenuKit.lua",
    ["lib/managers/menu/renderers/menunodeupdatesgui"] = "Menu/Menunodeupdatesgui.lua",
    ["lib/managers/menu/infamytreegui"] = "Menu/InfamyTreeGUI.lua",
    ["lib/managers/menu/boxguiobject"] = "Menu/Boxguiobject.lua",
    ["lib/managers/crimenetmanager"] = "Menu/Crimenetmanager.lua",
    ["lib/network/base/clientnetworksession"] = "Hud/Clientnetworksession.lua",
    ["lib/network/handlers/unitnetworkhandler"] = "Hud/Unitnetworkhandler.lua",
    ["lib/managers/menu/playerinventorygui"] = "Menu/PlayerInventoryGUI.lua",
    ["lib/managers/menu/stageendscreengui"] = "Menu/stageendscreengui.lua",
    ["lib/managers/menu/lootdropscreengui"] = "Menu/lootdropscreengui.lua",
    ["lib/managers/menu/menubackdropgui"] = "Menu/MenuBackdropGUI.lua",
    ["lib/managers/menu/renderers/menunodejukeboxgui"] = "Menu/Menunodejukeboxgui.lua",
    ["lib/managers/menu/items/menuitemcustomizecontroller"] = "Menu/Menuitemcustomizecontroller.lua",
    ["lib/managers/menu/skilltreegui"] = "Menu/SkillTreeGUI.lua",
    ["lib/managers/menu/missionbriefinggui"] = "Menu/Missionbriefinggui.lua", 

    ["lib/units/props/digitalgui"] = "Hud/DigitalGUI.lua",
    ["lib/units/props/timergui"] = "Hud/TimerGUI.lua",
    ["lib/units/equipment/ecm_jammer/ecmjammerbase"] = "Hud/ECMJammerBase.lua",
    ["lib/managers/hud/hudheisttimer"] = "Hud/HeistTimer.lua",
    ["lib/managers/hud/hudstageendscreen"] = "Hud/Hudstageendscreen.lua",
    ["lib/managers/hud/hudmissionbriefing"] = "Hud/HudMissionBriefing.lua",
    ["lib/managers/hud/hudlootscreen"] = "Hud/hudlootscreen.lua", 
    ["lib/managers/hud/hudplayerdowned"] = "Hud/HudDowned.lua", 
    ["lib/managers/hud/hudplayercustody"] = "Hud/HudCustody.lua",
    ["lib/managers/hud/hudassaultcorner"] = "Hud/AssaultBox.lua", 
    ["lib/managers/hud/hudstatsscreen"] = "Hud/Hudstatsscreen.lua", 
    ["lib/managers/hud/hudobjectives"] = "Hud/Hudobjectives.lua",
    ["lib/managers/hud/hudchat"] = "Hud/HudChat.lua",
    ["lib/managers/hud/hudteammate"] = "Hud/Hudteammate.lua",
    ["lib/managers/hud/hudtemp"] = "Hud/HudTemp.lua",
    ["lib/managers/hud/hudhint"] = "Hud/HudHint.lua",
    ["lib/managers/hud/hudpresenter"] = "Hud/HudPresenter.lua",
    ["lib/managers/hudmanager"] = "Hud/HudManager.lua",
    ["lib/managers/hudmanagerpd2"] = "Hud/HudManager.lua",
}
if not Holo.setup then
	for p, d in pairs(Holo.dofiles) do
		dofile("mods/Holo/" .. d)
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
		loc:load_localization_file( "mods/Holo/loc/EN.txt" )	
		if Holo.options.Holo_lang == 2 and io.open("mods/Holo/loc/RU.txt" ) then
			loc:load_localization_file( "mods/Holo/loc/EN.txt" )	
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
