if not GameSetup then
	local ids_e_money = Idstring("e_money")
	Holo:Post(MenuSceneManager, "init", function(self)
		self._bg_unit:effect_spawner(ids_e_money):set_enabled(not Holo.Options:GetValue("ColoredBackground"))
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)

	local default_color = Color("26252e")
	local ids_a_reference = Idstring("a_reference")
	local char_pos = Vector3(-32, 10.66, -137)
	function MenuSceneManager:UpdateHolo()
		local bg_option = Holo.Options:GetValue("ColoredBackground")
		local current_template = self:get_current_scene_template()
		self:_use_environment(current_template)

		if not MenuBackgrounds and alive(self._background_ws) then
			self._background_ws:panel():child("bg"):set_color(Holo:GetColor("Colors/Menu") or default_color)
		end

		local visible = not bg_option
		self._menu_logo:set_visible(visible)
		self._bg_unit:set_visible(visible)
		self._menu_solid_bg:set_visible(visible)

		if self._workbench_room then
			self._workbench_room:set_visible(visible)
		end

		self._bg_unit:effect_spawner(ids_e_money):set_enabled(visible)

		if Holo:ShouldModify("Menu", "PlayerProfile") and current_template == "standard" then
			local c_ref = self._bg_unit:get_object(ids_a_reference)
			self._scene_templates.standard.character_pos = bg_option and char_pos or c_ref:position()
			self._character_unit:set_position(self._scene_templates.standard.character_pos)
		end
	end

	Holo:Post(MenuSceneManager, "_set_up_templates", function(self)
		if Holo:ShouldModify("Menu", "PlayerProfile") then
			local c_ref = self._bg_unit:get_object(ids_a_reference)
			self._scene_templates.standard.character_pos = Holo.Options:GetValue("ColoredBackground") and char_pos or c_ref:position()
		end
	end)

	Holo:Post(MenuSceneManager, "set_scene_template", function(self)
		if Holo.Options:GetValue("ColoredBackground") then
			self._menu_logo:set_visible(false)
		end
	end)

	Holo:Post(MenuSceneManager, "_setup_bg", function(self)
		if not self._menu_solid_bg then
			for _, unit in pairs(World:find_units_quick("all")) do
				if unit:name() == Idstring("units/menu/menu_scene/menu_solid_bg") then
					self._menu_solid_bg = unit
					break
				end
			end
		end

		if Holo.Options:GetValue("ColoredBackground") then
			self._bg_unit:set_visible(false)
			self._menu_solid_bg:set_visible(false)
		end
	end)

	Holo:Post(MenuSceneManager, "spawn_workbench_room", function(self)
		if Holo.Options:GetValue("ColoredBackground") then
			self._workbench_room:set_visible(false)
		end
	end)

	Holo:Post(MenuSceneManager, "_use_environment", function(self, name)
		local color_grading = "color_off"

		-- if there is no color grading for the current env, force standard's
		if Holo.Options:GetValue("MenuColorGrading") then
			local environments = self._environments
			local setting = environments[name]
			color_grading = setting and setting.color_grading or environments.standard.color_grading
		end

		if managers.environment_controller:default_color_grading() ~= color_grading then
			managers.environment_controller:set_default_color_grading(color_grading, true)
			managers.environment_controller:refresh_render_settings()
		end

		local vp = managers.viewport:first_active_viewport()
		if vp then
			local vp_obj = vp:vp()
			vp_obj:set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
		end
	end)

	local x = Vector3()
	local y = Vector3()
	local z = Vector3()
	Holo:Post(MenuSceneManager, "update", function(self, t, dt)
		if MenuBackgrounds then
			return
		end

		if self._shaker then
			self._shaker:stop_all()
		end

		local cam = managers.viewport:get_current_camera()
		if not cam then
			return
		end

		local w, h = 1920, 1080
		local pos = cam:position()
		local rot = cam:rotation()
		mvector3.set_static(x, 0, 0, -h / 2)
		mvector3.rotate_with(x, rot)
		mvector3.add(x, pos)

		mvector3.set_static(y, 0, w, 0)
		mvector3.rotate_with(y, rot)

		mvector3.set_static(z, 0, 0, h)
		mvector3.rotate_with(z, rot)

		local visible = Holo.Options:GetValue("ColoredBackground")
		if alive(self._background_ws) then
			self._background_ws:set_world(w, h, x, y, z)
			self._background_ws:panel():child("bg"):set_visible(visible)
		else
			self._background_ws = World:newgui():create_world_workspace(w, h, x, y, z)
			self._background_ws:panel():bitmap({
				name = "bg",
				color = Holo:GetColor("Colors/Menu") or default_color,
				layer = 20000,
				w = w,
				h = h,
				visible = visible
			})
			self._background_ws:set_billboard(Workspace.BILLBOARD_BOTH)
		end
	end)
end