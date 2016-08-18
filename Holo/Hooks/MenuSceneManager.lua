if not _G.MenuBackgrounds then 
	Hooks:PostHook(MenuSceneManager, "update", "HoloUpdateFov", function(self)
		if self._camera_object then
			local fixed_fov = math.min(50, self._new_fov)
			if self._new_fov ~= fixed_fov then		
				self._new_fov = fixed_fov
				self._camera_object:set_fov(self._new_fov)
			end
		end	
	end)
	Hooks:PostHook(MenuSceneManager, "set_scene_template", "HoloSetMenuBackground", function(self, template)
		self:add_callback(function()
			if not managers.environment_controller._vp then
				return
			end
			if not Utils:IsInGameState() then
				if self._shaker then
					self._shaker:stop_all()
				end
				managers.environment_controller._vp:vp():set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
				World:effect_manager():set_rendering_enabled(false)			
				managers.environment_controller:set_default_color_grading("color_off")
				managers.environment_controller:refresh_render_settings()		
			end
			if alive(self._background_ws) then
			    World:newgui():destroy_workspace(self._background_ws)
			end
			local units = {
				"bg_unit",
				"workbench_room",
				"economy_saferoom",
				"economy_safe"
			}
			for _, unit in pairs(units) do
				if self["_" .. unit] then
					self["_" .. unit]:set_visible(false)
				end
			end
			local cam = managers.viewport:get_current_camera()
			local gui = World:newgui()
			local w,h = 1600, 900
			self._background_ws = gui:create_world_workspace(w, h, cam:position() - Vector3(0, -486.5, 449.5):rotate_with(cam:rotation()) , Vector3(0, w, 0):rotate_with(cam:rotation()) , Vector3(0, 0, h):rotate_with(cam:rotation()))
			self._background_ws:panel():rect({
			    name = "bg",
			    color = Holo:GetColor("Colors/MenuBackground"),
			    layer = 2000000
			})
			self._background_ws:set_billboard(Workspace.BILLBOARD_BOTH)	
		end, 0.01)
	end)
end
