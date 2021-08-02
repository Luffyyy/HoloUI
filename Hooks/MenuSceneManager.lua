if not GameSetup and Holo:ShouldModify("Menu", "ColoredBackground") then
	if Holo:ShouldModify("Menu", "PlayerProfile") then
		Holo:Post(MenuSceneManager, "_set_up_templates", function(self)
			self._scene_templates.standard.character_pos = Vector3(-32, 10.66, -137)
		end)
	end

	function MenuSceneManager:HoloUpdate()
		local cam = managers.viewport:get_current_camera()
		if type(cam) == "boolean" then
			return
		end
		local w,h = 1920, 1080
		local a,b,c = cam:position() + Vector3(-1, 584, -h/2+1):rotate_with(cam:rotation()), Vector3(0, w, 0):rotate_with(cam:rotation()) , Vector3(0, 0, h):rotate_with(cam:rotation())
		if alive(self._background_ws) then
			self._background_ws:set_world(w,h,a,b,c)
			self._background_ws:panel():child("bg"):set_color(Holo:GetColor("Colors/Menu"))
			if self._shaker then
				self._shaker:stop_all()
			end
			if not Holo.Options:GetValue("MenuColorGrading") then
				managers.environment_controller:set_default_color_grading("color_off", true)
				managers.environment_controller:refresh_render_settings()
			end
		else
			self._background_ws = World:newgui():create_world_workspace(w,h,a,b,c)
			self._background_ws:panel():bitmap({
				name = "bg",
				color = Holo:GetColor("Colors/Menu"),
				layer = 20000,
				w = w,
				h = h,
			})
			self._background_ws:set_billboard(Workspace.BILLBOARD_BOTH)
		end
		World:effect_manager():set_rendering_enabled(Global.load_level)
		if managers.environment_controller._vp then
			managers.environment_controller._vp:vp():set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
		end
		local unwanted = {
			"units/menu/menu_scene/menu_cylinder",
			"units/menu/menu_scene/menu_smokecylinder1",
			"units/menu/menu_scene/menu_smokecylinder2",
			"units/menu/menu_scene/menu_smokecylinder3",
			"units/menu/menu_scene/menu_cylinder_pattern",
			"units/menu/menu_scene/menu_cylinder_pattern",
			"units/menu/menu_scene/menu_logo",
			"units/pd2_dlc_shiny/menu_showcase/menu_showcase",
			"units/payday2_cash/safe_room/cash_int_safehouse_saferoom"
		}
		for _, unit in pairs(World:find_units_quick("all")) do
			for _, unit_name in pairs(unwanted) do
				if unit:name() == unit_name:id() then
					unit:set_visible(false)
				end
			end
		end
	end
	Hooks:PostHook(MenuSceneManager, "update", "MenuBGsUpdate", function(self)
		if not MenuBackgrounds then
			self:HoloUpdate()
		end
	end)
end