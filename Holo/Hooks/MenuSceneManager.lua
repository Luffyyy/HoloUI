if not GameSetup and Holo:ShouldModify("Menu", "ColoredBackground") then 
	function MenuSceneManager:HoloUpdate()
		if self._camera_object then
			local fixed_fov = math.min(50, self._new_fov)
			if self._new_fov ~= fixed_fov then		
				self._new_fov = fixed_fov
				self._camera_object:set_fov(self._new_fov)
			end
		end		

		local cam = managers.viewport:get_current_camera()
		if type(cam) == "boolean" then
			return
		end
		local w,h = 1600, 900
		local a,b,c = cam:position() - Vector3(0, -486.5, 449.5):rotate_with(cam:rotation()) , Vector3(0, w, 0):rotate_with(cam:rotation()) , Vector3(0, 0, h):rotate_with(cam:rotation())
		if alive(self._background_ws) then
			self._background_ws:set_world(w,h,a,b,c)
			self._background_ws:panel():child("bg"):set_color(Holo:GetColor("Colors/Menu"))
			if self._shaker then
				self._shaker:stop_all()
			end
			managers.environment_controller:set_default_color_grading("color_off") --Remove if you wish the mod to not remove color grading.
			managers.environment_controller:refresh_render_settings()		
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
			self._bg_unit:effect_spawner(Idstring("e_money")):set_enabled(false)
			managers.environment_controller._vp:vp():set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
			local unwanted = {
				"units/menu/menu_scene/menu_cylinder",
				"units/menu/menu_scene/menu_smokecylinder1",
				"units/menu/menu_scene/menu_smokecylinder2",
				"units/menu/menu_scene/menu_smokecylinder3",
				"units/menu/menu_scene/menu_cylinder_pattern",
				"units/menu/menu_scene/menu_cylinder_pattern",
				"units/menu/menu_scene/menu_logo",
				"units/pd2_dlc_shiny/menu_showcase/menu_showcase",
				"units/payday2_cash/safe_room/cash_int_safehouse_saferoom",
			}
			for k, unit in pairs(World:find_units_quick("all")) do 
				for _, unit_name in pairs(unwanted) do
					if unit:name() == Idstring(unit_name) then
						unit:set_enabled(false)  
						unit:set_visible(false)  
					end
				end
			end		
		end		
	end	
	Hooks:PostHook(MenuSceneManager, "update", "HoloUpdate", function(self) self:HoloUpdate() end)		
	Hooks:PreHook(MenuSceneManager, "init", "HoloInit", function(self)
		if MenuBackgrounds then
			function MenuSceneManager:HoloUpdate() end
		end
	end)
end