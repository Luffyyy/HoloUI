if Holo.options.Holomenu_crimenet then

function CrimeNetGui:init(ws, fullscreeen_ws, node)
	self._tweak_data = tweak_data.gui.crime_net
	self._crimenet_enabled = true
	managers.menu_component:post_event("crime_net_startup")
	managers.menu_component:close_contract_gui()
	local no_servers = node:parameters().no_servers
	if no_servers then
		managers.crimenet:start_no_servers()
	else
		managers.crimenet:start()
	end
	managers.menu:active_menu().renderer.ws:hide()
	local safe_scaled_size = managers.gui_data:safe_scaled_size()
	self._ws = ws
	self._fullscreen_ws = fullscreeen_ws
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({name = "fullscreen"})
	self._panel = self._ws:panel():panel({name = "main"})
	local full_16_9 = managers.gui_data:full_16_9_size()
	self._fullscreen_panel:bitmap({
		name = "blur_top",
		texture = "guis/textures/test_blur_df",
		w = self._fullscreen_ws:panel():w(),
		h = full_16_9.convert_y * 2,
		x = 0,
		y = -full_16_9.convert_y,
		render_template = "VertexColorTexturedBlur3D",
		layer = 1001,
		rotation = 360
	})
	self._fullscreen_panel:bitmap({
		name = "blur_right",
		texture = "guis/textures/test_blur_df",
		w = full_16_9.convert_x * 2,
		h = self._fullscreen_ws:panel():h(),
		x = self._fullscreen_ws:panel():w() - full_16_9.convert_x,
		y = 0,
		render_template = "VertexColorTexturedBlur3D",
		layer = 1001,
		rotation = 360
	})
	self._fullscreen_panel:bitmap({
		name = "blur_bottom",
		texture = "guis/textures/test_blur_df",
		w = self._fullscreen_ws:panel():w(),
		h = full_16_9.convert_y * 2,
		x = 0,
		y = self._fullscreen_ws:panel():h() - full_16_9.convert_y,
		render_template = "VertexColorTexturedBlur3D",
		layer = 1001,
		rotation = 360
	})
	self._fullscreen_panel:bitmap({
		name = "blur_left",
		texture = "guis/textures/test_blur_df",
		w = full_16_9.convert_x * 2,
		h = self._fullscreen_ws:panel():h(),
		x = -full_16_9.convert_x,
		y = 0,
		render_template = "VertexColorTexturedBlur3D",
		layer = 1001,
		rotation = 360
	})
	self._panel:rect({
		w = self._panel:w(),
		h = 2,
		x = 0,
		y = 0,
		layer = 1,
		color = Color.white,
		blend_mode = "normal"
	})
	self._panel:rect({
		w = self._panel:w(),
		h = 2,
		x = 0,
		y = 0,
		layer = 1,
		color = Color.white,
		blend_mode = "normal"
	}):set_bottom(self._panel:h())
	self._panel:rect({
		w = 2,
		h = self._panel:h(),
		x = 0,
		y = 0,
		layer = 1,
		color = Color.white,
		blend_mode = "normal"
	}):set_right(self._panel:w())
	self._panel:rect({
		w = 2,
		h = self._panel:h(),
		x = 0,
		y = 0,
		layer = 1,
		color = Color.white,
		blend_mode = "normal"
	})
	self._rasteroverlay = self._fullscreen_panel:bitmap({
		name = "rasteroverlay",
		texture = "guis/textures/crimenet_map_rasteroverlay",
		texture_rect = {
			0,
			0,
			32,
			256
		},
		wrap_mode = "wrap",
		blend_mode = "mul",
		layer = 3,
		color = Color(1, 1, 1, 1),
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h()
	})
	self._fullscreen_panel:bitmap({
		name = "vignette",
		texture = "guis/textures/crimenet_map_vignette",
		layer = 2,
		color = Color(1, 1, 1, 1),
		visible = false,
		w = self._fullscreen_panel:w(),
		h = self._fullscreen_panel:h()
	})
	local bd_light = self._fullscreen_panel:bitmap({
		name = "bd_light",
		texture = "guis/textures/pd2/menu_backdrop/bd_light",
		visible = false,
		layer = 4
	})
	bd_light:set_size(self._fullscreen_panel:size())
	bd_light:set_alpha(0)
	bd_light:set_blend_mode("add")
	local function light_flicker_animation(o)
		local alpha = 0 
		local acceleration = 0
		local wanted_alpha = math.rand(1) * 0.3
		local flicker_up = true
		while true do
			wait(0.009, self._fixed_dt)
			over(0.045, function(p)
				o:set_alpha(math.lerp(alpha, wanted_alpha, p))
			end, self._fixed_dt)
			flicker_up = not flicker_up
			alpha = o:alpha()
			if not flicker_up then
			else
			end
			wanted_alpha = math.rand(flicker_up and alpha or 0.2, alpha or 0.3)
		end
	end
	bd_light:animate(light_flicker_animation)
	local back_button = self._panel:text({
		name = "back_button",
		text = managers.localization:to_upper_text("menu_back"),
		align = "right",
		vertical = "bottom",
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = Holomenu_color_normal,
		layer = 40,
		blend_mode = "normal"
	})
	self:make_fine_text(back_button)
	back_button:set_right(self._panel:w() - 10)
	back_button:set_bottom(self._panel:h() - 10)
	back_button:set_visible(managers.menu:is_pc_controller())
	self._back_marker = self._panel:bitmap({
		color = Holomenu_color_marker,
		alpha = Holomenu_markeralpha,
		visible = false,
		layer = back_button:layer() - 1
	})
	local x,y,w,h = back_button:text_rect()
	self._back_marker:set_shape(x,y,313,h)
	self._back_marker:set_right(x + w)
	
	local blur_object = self._panel:bitmap({
		name = "controller_legend_blur",
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = back_button:layer() - 1
	})
	blur_object:set_shape(back_button:shape())
	if not managers.menu:is_pc_controller() then
		blur_object:set_size(self._panel:w() * 0.5, tweak_data.menu.pd2_medium_font_size)
		blur_object:set_rightbottom(self._panel:w() - 2, self._panel:h() - 2)
	end

	WalletGuiObject.set_wallet(self._panel)
	WalletGuiObject.set_layer(30)
	WalletGuiObject.move_wallet(10, -10)
	local text_id = Global.game_settings.single_player and "menu_crimenet_offline" or "cn_menu_num_players_offline"
	local num_players_text = self._panel:text({
		name = "num_players_text",
		text = managers.localization:to_upper_text(text_id, {amount = "1"}),
		align = "left",
		vertical = "top",
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text,
		layer = 40
	})
	self:make_fine_text(num_players_text)
	num_players_text:set_left(10)
	num_players_text:set_top(10)
	local blur_object = self._panel:bitmap({
		name = "num_players_blur",
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = num_players_text:layer() - 1
	})
	blur_object:set_shape(num_players_text:shape())

	local legends_button = self._panel:text({
		name = "legends_button",
		text = managers.localization:to_upper_text("menu_cn_legend_show", {
			BTN_X = managers.localization:btn_macro("menu_toggle_legends")
		}),
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text,
		layer = 40,
		blend_mode = "normal"
	})
	self:make_fine_text(legends_button)
	legends_button:set_left(num_players_text:left())
	legends_button:set_top(num_players_text:bottom())
	local blur_object = self._panel:bitmap({
		name = "legends_button_blur",
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		layer = legends_button:layer() - 1
	})
	blur_object:set_shape(legends_button:shape())

	if managers.menu:is_pc_controller() then
		legends_button:set_color(Holomenu_color_normal)
	end
	do
		local w, h
		local mw, mh = 0, nil
		local legend_panel = self._panel:panel({
			name = "legend_panel",
			layer = 40,
			visible = false,
			x = 10,
			y = legends_button:bottom() + 4
		})
		local host_icon = legend_panel:bitmap({
			texture = "guis/textures/pd2/crimenet_legend_host",
			x = 10,
			y = 10
		})
		local host_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_icon:right() + 2,
			y = host_icon:top(),
			text = managers.localization:to_upper_text("menu_cn_legend_host"),
			blend_mode = "normal"
		})
		mw = math.max(mw, self:make_fine_text(host_text))
		local join_icon = legend_panel:bitmap({
			texture = "guis/textures/pd2/crimenet_legend_join",
			x = 10,
			y = host_text:bottom()
		})
		local join_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_text:left(),
			y = join_icon:top(),
			text = managers.localization:to_upper_text("menu_cn_legend_join"),
			blend_mode = "normal"
		})
		mw = math.max(mw, self:make_fine_text(join_text))
		self:make_color_text(join_text, tweak_data.screen_colors.regular_color)
		local friends_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_text:left(),
			y = join_text:bottom(),
			text = managers.localization:to_upper_text("menu_cn_legend_friends"),
			blend_mode = "normal"
		})
		mw = math.max(mw, self:make_fine_text(friends_text))
		self:make_color_text(friends_text, tweak_data.screen_colors.friend_color)
		if managers.crimenet:no_servers() then
			join_icon:hide()
			join_text:hide()
			friends_text:hide()
			friends_text:set_bottom(host_text:bottom())
		end
		local risk_icon = legend_panel:bitmap({
			texture = "guis/textures/pd2/crimenet_legend_risklevel",
			x = 10,
			y = friends_text:bottom()
		})
		local risk_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_text:left(),
			y = risk_icon:top(),
			text = managers.localization:to_upper_text("menu_cn_legend_risk"),
			color = tweak_data.screen_colors.risk,
			blend_mode = "normal"
		})
		mw = math.max(mw, self:make_fine_text(risk_text))
		local pro_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_text:left(),
			y = risk_text:bottom(),
			text = managers.localization:to_upper_text("menu_cn_legend_pro"),
			color = tweak_data.screen_colors.pro_color,
			blend_mode = "normal"
		})
		mw = math.max(mw, self:make_fine_text(pro_text))
		local ghost_icon = legend_panel:bitmap({
			texture = "guis/textures/pd2/cn_minighost",
			x = 7,
			y = pro_text:bottom() + 2 + 2,
			color = tweak_data.screen_colors.ghost_color
		})
		local ghost_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_text:left(),
			y = pro_text:bottom(),
			text = managers.localization:to_upper_text("menu_cn_legend_ghostable"),
			blend_mode = "normal",
			color = tweak_data.screen_colors.ghost_color
		})
		mw = math.max(mw, self:make_fine_text(ghost_text))
		local kick_none_icon = legend_panel:bitmap({
			texture = "guis/textures/pd2/cn_kick_marker",
			x = 10,
			y = ghost_text:bottom() + 2
		})
		local kick_none_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_text:left(),
			y = ghost_text:bottom(),
			text = managers.localization:to_upper_text("menu_cn_kick_disabled"),
			blend_mode = "normal"
		})
		mw = math.max(mw, self:make_fine_text(kick_none_text))
		local kick_vote_icon = legend_panel:bitmap({
			texture = "guis/textures/pd2/cn_votekick_marker",
			x = 10,
			y = kick_none_text:bottom() + 2
		})
		local kick_vote_text = legend_panel:text({
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			x = host_text:left(),
			y = kick_none_text:bottom(),
			text = managers.localization:to_upper_text("menu_kick_vote"),
			blend_mode = "normal"
		})
		mw = math.max(mw, self:make_fine_text(kick_vote_text))
		local last_text = kick_vote_text
		local job_plan_loud_icon, job_plan_loud_text, job_plan_stealth_icon, job_plan_stealth_text
		if MenuCallbackHandler:bang_active() then
			job_plan_loud_icon = legend_panel:bitmap({
				texture = "guis/textures/pd2/cn_playstyle_loud",
				x = 10,
				y = kick_vote_text:bottom() + 2
			})
			job_plan_loud_text = legend_panel:text({
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				x = host_text:left(),
				y = kick_vote_text:bottom(),
				text = managers.localization:to_upper_text("menu_plan_loud"),
				blend_mode = "normal"
			})
			mw = math.max(mw, self:make_fine_text(job_plan_loud_text))
			job_plan_stealth_icon = legend_panel:bitmap({
				texture = "guis/textures/pd2/cn_playstyle_stealth",
				x = 10,
				y = job_plan_loud_text:bottom() + 2
			})
			job_plan_stealth_text = legend_panel:text({
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				x = host_text:left(),
				y = job_plan_loud_text:bottom(),
				text = managers.localization:to_upper_text("menu_plan_stealth"),
				blend_mode = "normal"
			})
			mw = math.max(mw, self:make_fine_text(job_plan_stealth_text))
			last_text = job_plan_stealth_text
		end
		if managers.crimenet:no_servers() then
			kick_none_icon:hide()
			kick_none_text:hide()
			kick_vote_icon:hide()
			kick_vote_text:hide()
			kick_vote_text:set_bottom(ghost_text:bottom())
			if MenuCallbackHandler:bang_active() then
				job_plan_loud_icon:hide()
				job_plan_loud_text:hide()
				job_plan_stealth_icon:hide()
				job_plan_stealth_text:hide()
			end
		end
		legend_panel:set_size(host_text:left() + mw + 10, last_text:bottom() + 10)
		legend_panel:rect({
			color = Color.black,
			alpha = 0.4,
			layer = -1
		})
		BoxGuiObject:new(legend_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		legend_panel:bitmap({
			texture = "guis/textures/test_blur_df",
			w = legend_panel:w(),
			h = legend_panel:h(),
			render_template = "VertexColorTexturedBlur3D",
			layer = -1
		})
	end
	do
		local w, h
		local mw, mh = 0, nil
		local global_bonuses_panel = self._panel:panel({
			name = "global_bonuses_panel",
			layer = 40,
			y = 10,
			h = 30
		})
		local mul_to_procent_string = function(multiplier)
			local pro = math.round(multiplier * 100)
			local procent_string
			if pro == 0 and multiplier ~= 0 then
				procent_string = string.format("%0.2f", math.abs(multiplier * 100))
			else
				procent_string = tostring(math.abs(pro))
			end
			return procent_string, multiplier >= 0
		end
		local has_ghost_bonus = managers.job:has_ghost_bonus()
		if has_ghost_bonus then
			do
				local ghost_bonus_mul = managers.job:get_ghost_bonus()
				local job_ghost_string = mul_to_procent_string(ghost_bonus_mul)
				local ghost_text = global_bonuses_panel:text({
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					align = "center",
					text = managers.localization:to_upper_text("menu_ghost_bonus", {exp_bonus = job_ghost_string}),
					blend_mode = "normal",
					color = tweak_data.screen_colors.ghost_color
				})
			end
			local skill_bonus = managers.player:get_skill_exp_multiplier()
			skill_bonus = skill_bonus - 1
			if skill_bonus > 0 then
				local skill_string = mul_to_procent_string(skill_bonus)
				local skill_text = global_bonuses_panel:text({
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					align = "center",
					text = managers.localization:to_upper_text("menu_cn_skill_bonus", {exp_bonus = skill_string}),
					blend_mode = "normal",
					color = tweak_data.screen_colors.skill_color
				})
			end
			local infamy_bonus = managers.player:get_infamy_exp_multiplier()
			infamy_bonus = infamy_bonus - 1
			if infamy_bonus > 0 then
				local infamy_string = mul_to_procent_string(infamy_bonus)
				local infamy_text = global_bonuses_panel:text({
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					align = "center",
					text = managers.localization:to_upper_text("menu_cn_infamy_bonus", {exp_bonus = infamy_string}),
					blend_mode = "normal",
					color = tweak_data.lootdrop.global_values.infamy.color
				})
			end
			local limited_bonus = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
			limited_bonus = limited_bonus - 1
			if limited_bonus > 0 then
				local limited_string = mul_to_procent_string(limited_bonus)
				local limited_text = global_bonuses_panel:text({
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					align = "center",
					text = managers.localization:to_upper_text("menu_cn_limited_bonus", {exp_bonus = limited_string}),
					blend_mode = "normal",
					color = Holomenu_color_marker
				})
			end
		end
		if 1 < #global_bonuses_panel:children() then
			for i, child in ipairs(global_bonuses_panel:children()) do
				child:set_alpha(0)
			end
			local function global_bonuses_anim(panel)
				local child_num = 1
				local viewing_child = panel:children()[child_num]
				local t = 0
				local dt = 0
				while alive(viewing_child) do
					if not self._crimenet_enabled then
						coroutine.yield()
					else
						viewing_child:set_alpha(0)
						over(0.5, function(p)
							viewing_child:set_alpha(math.sin(p * 90))
						end)
						viewing_child:set_alpha(1)
						over(4, function(p)
							viewing_child:set_alpha((math.cos(p * 360 * 2) + 1) * 0.5 * 0.2 + 0.8)
						end)
						over(0.5, function(p)
							viewing_child:set_alpha(math.cos(p * 90))
						end)
						viewing_child:set_alpha(0)
						child_num = child_num % #panel:children() + 1
						viewing_child = panel:children()[child_num]
					end
				end
			end
			global_bonuses_panel:animate(global_bonuses_anim)
		elseif #global_bonuses_panel:children() == 1 then
			local function global_bonuses_anim(panel)
				while alive(panel) do
					if not self._crimenet_enabled then
						coroutine.yield()
					else
						over(2, function(p)
							panel:set_alpha((math.sin(p * 360) + 1) * 0.5 * 0.2 + 0.8)
						end)
					end
				end
			end
			global_bonuses_panel:animate(global_bonuses_anim)
		end
	end
	if not no_servers and not is_xb1 then
		local id = is_x360 and "menu_cn_friends" or "menu_cn_filter"
		local filter_button = self._panel:text({
			name = "filter_button",
			text = managers.localization:to_upper_text(id, {
				BTN_Y = managers.localization:btn_macro("menu_toggle_filters")
			}),
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = tweak_data.screen_colors.text,
			layer = 40,
			blend_mode = "normal"
		})
		self:make_fine_text(filter_button)
		filter_button:set_right(self._panel:w() - 10)
		filter_button:set_top(10)
		do
			local blur_object = self._panel:bitmap({
				name = "filter_button_blur",
				texture = "guis/textures/test_blur_df",
				render_template = "VertexColorTexturedBlur3D",
				layer = filter_button:layer() - 1
			})
			blur_object:set_shape(filter_button:shape())
		end
		if managers.menu:is_pc_controller() then
			filter_button:set_color(Holomenu_color_normal)
		end
		if is_ps3 or is_ps4 then
			local invites_button = self._panel:text({
				name = "invites_button",
				text = managers.localization:get_default_macro("BTN_BACK") .. " " .. managers.localization:to_upper_text("menu_view_invites"),
				font_size = tweak_data.menu.pd2_medium_font_size,
				font = tweak_data.menu.pd2_medium_font,
				color = tweak_data.screen_colors.text,
				layer = 40,
				blend_mode = "normal"
			})
			self:make_fine_text(invites_button)
			invites_button:set_right(filter_button:right())
			invites_button:set_top(filter_button:bottom())
			do
				local blur_object = self._panel:bitmap({
					name = "invites_button_blur",
					texture = "guis/textures/test_blur_df",
					render_template = "VertexColorTexturedBlur3D",
					layer = filter_button:layer() - 1
				})
				blur_object:set_shape(invites_button:shape())
			end
			if not self._ps3_invites_controller then
				local invites_cb = callback(self, self, "ps3_invites_callback")
				self._ps3_invites_controller = managers.controller:create_controller("ps3_invites_controller", managers.controller:get_default_wrapper_index(), false)
				self._ps3_invites_controller:add_trigger("back", invites_cb)
			end
			self._ps3_invites_controller:set_enabled(true)
		end
	end
	self._map_size_w = 2048
	self._map_size_h = 1024
	local aspect = 1.7777778
	local sw = math.min(self._map_size_w, self._map_size_h * aspect)
	local sh = math.min(self._map_size_h, self._map_size_w / aspect)
	local dw = self._map_size_w / sw
	local dh = self._map_size_h / sh
	self._map_size_w = dw * 1280
	self._map_size_h = dh * 720
	local pw, ph = self._map_size_w, self._map_size_h
	self._pan_panel_border = 2.7777777
	self._pan_panel_job_border_x = full_16_9.convert_x + self._pan_panel_border * 2
	self._pan_panel_job_border_y = full_16_9.convert_y + self._pan_panel_border * 2
	self._pan_panel = self._panel:panel({
		name = "pan",
		w = pw,
		h = ph,
		layer = 0
	})
	self._pan_panel:set_center(self._fullscreen_panel:w() / 2, self._fullscreen_panel:h() / 2)
	self._jobs = {}
	self._deleting_jobs = {}
	self._map_panel = self._fullscreen_panel:panel({
		name = "map",
		w = pw,
		h = ph
	})
	self._map_panel:bitmap({
		name = "map",
		texture = "guis/textures/crimenet_map",
		layer = 0,
		alpha = Holo.options.colorbg_enable and 0 or 1,
		valign = "scale",
		halign = "scale",
		w = pw,
		h = ph
	})
	self._map_panel:child("map"):set_halign("scale")
	self._map_panel:child("map"):set_valign("scale")
	self._map_panel:rect({
		name = "background",
		color = Holomenu_color_background,
		visible = Holo.options.colorbg_enable,
		valign = "scale",
		halign = "scale",
	})
	self._map_panel:set_shape(self._pan_panel:shape())
	self._map_x, self._map_y = self._map_panel:position()
	if not managers.menu:is_pc_controller() then
		managers.mouse_pointer:confine_mouse_pointer(self._panel)
		managers.menu:active_menu().input:activate_controller_mouse()
		managers.mouse_pointer:set_mouse_world_position(managers.gui_data:safe_to_full(self._panel:world_center()))
	end
	self.MIN_ZOOM = 1
	self.MAX_ZOOM = 9
	self._zoom = 1
	local cross_indicator_h1 = self._fullscreen_panel:bitmap({
		name = "cross_indicator_h1",
		texture = "guis/textures/pd2/skilltree/dottedline",
		w = self._fullscreen_panel:w(),
		h = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1,
		wrap_mode = "wrap"
	})
	local cross_indicator_h2 = self._fullscreen_panel:bitmap({
		name = "cross_indicator_h2",
		texture = "guis/textures/pd2/skilltree/dottedline",
		w = self._fullscreen_panel:w(),
		h = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1,
		wrap_mode = "wrap"
	})
	local cross_indicator_v1 = self._fullscreen_panel:bitmap({
		name = "cross_indicator_v1",
		texture = "guis/textures/pd2/skilltree/dottedline",
		h = self._fullscreen_panel:h(),
		w = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1,
		wrap_mode = "wrap"
	})
	local cross_indicator_v2 = self._fullscreen_panel:bitmap({
		name = "cross_indicator_v2",
		texture = "guis/textures/pd2/skilltree/dottedline",
		h = self._fullscreen_panel:h(),
		w = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1,
		wrap_mode = "wrap"
	})
	local line_indicator_h1 = self._fullscreen_panel:rect({
		name = "line_indicator_h1",
		w = 0,
		h = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1
	})
	local line_indicator_h2 = self._fullscreen_panel:rect({
		name = "line_indicator_h2",
		w = 0,
		h = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1
	})
	local line_indicator_v1 = self._fullscreen_panel:rect({
		name = "line_indicator_v1",
		h = 0,
		w = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1
	})
	local line_indicator_v2 = self._fullscreen_panel:rect({
		name = "line_indicator_v2",
		h = 0,
		w = 2,
		blend_mode = "normal",
		layer = 17,
		color = Color.white,
		alpha = 0.1
	})
	local fw = self._fullscreen_panel:w()
	local fh = self._fullscreen_panel:h()
	cross_indicator_h1:set_texture_coordinates(Vector3(0, 0, 0), Vector3(fw, 0, 0), Vector3(0, 2, 0), Vector3(fw, 2, 0))
	cross_indicator_h2:set_texture_coordinates(Vector3(0, 0, 0), Vector3(fw, 0, 0), Vector3(0, 2, 0), Vector3(fw, 2, 0))
	cross_indicator_v1:set_texture_coordinates(Vector3(0, 2, 0), Vector3(0, 0, 0), Vector3(fh, 2, 0), Vector3(fh, 0, 0))
	cross_indicator_v2:set_texture_coordinates(Vector3(0, 2, 0), Vector3(0, 0, 0), Vector3(fh, 2, 0), Vector3(fh, 0, 0))
	self:_create_locations()
	self._num_layer_jobs = 0
	local player_level = managers.experience:current_level()
	local positions_tweak_data = tweak_data.gui.crime_net.map_start_positions
	local start_position
	for _, position in ipairs(positions_tweak_data) do
		if player_level <= position.max_level then
			start_position = position
		else
		end
	end
	if start_position then
		self:_goto_map_position(start_position.x, start_position.y)
	end
	self._special_contracts_id = {}
	self:add_special_contracts(node:parameters().no_casino)
	managers.features:announce_feature("crimenet_welcome")
	if is_win32 then
		managers.features:announce_feature("thq_feature")
	end
	if is_win32 and Steam:logged_on() and not managers.dlc:has_pd2_clan() and math.random() < 0.2 then
		managers.features:announce_feature("join_pd2_clan")
	end
	if managers.dlc:is_dlc_unlocked("gage_pack_jobs") then
		managers.features:announce_feature("dlc_gage_pack_jobs")
	end
	managers.features:announce_feature("crimenet_heat")
	managers.features:announce_feature("election_changes")
	managers.challenge:fetch_challenges()
	return
end
function CrimeNetGui:_create_polylines()
	local regions = tweak_data.gui.crime_net.regions
	if alive(self._region_panel) then
		self._map_panel:remove(self._region_panel)
		self._region_panel = nil
	end
	self._region_panel = self._map_panel:panel({halign = "scale", valign = "scale"})
	self._region_locations = {}
	local xs, ys, num, vectors, my_polyline
	local tw = math.max(self._map_panel:child("map"):texture_width(), 1)
	local th = math.max(self._map_panel:child("map"):texture_height(), 1)
	local region_text_data, region_text, x, y
	for _, region in ipairs(regions) do
		xs = region[1]
		ys = region[2]
		num = math.min(#xs, #ys)
		vectors = {}
		my_polyline = self._region_panel:polyline({
			line_width = 2,
			alpha = 0.2,
			layer = 1,
			closed = region.closed,
			halign = "scale",
			valign = "scale",
			color = Color.white
		})
		for i = 1, num do
			table.insert(vectors, Vector3(xs[i] / tw * self._map_size_w * self._zoom, ys[i] / th * self._map_size_h * self._zoom, 0))
		end
		my_polyline:set_points(vectors)
		vectors = {}
		my_polyline = self._region_panel:polyline({
			line_width = 5,
			alpha = 0.2,
			layer = 1,
			closed = region.closed,
			halign = "scale",
			valign = "scale",
			color = Color.white
		})
		for i = 1, num do
			table.insert(vectors, Vector3(xs[i] / tw * self._map_size_w * self._zoom, ys[i] / th * self._map_size_h * self._zoom, 0))
		end
		my_polyline:set_points(vectors)
		region_text_data = region.text
		if region_text_data then
			x = region_text_data.x / tw * self._map_size_w * self._zoom
			y = region_text_data.y / th * self._map_size_h * self._zoom
			if region_text_data.title_id then
				region_text = self._region_panel:text({
					font = tweak_data.menu.pd2_large_font,
					font_size = tweak_data.menu.pd2_large_font_size,
					text = managers.localization:to_upper_text(region_text_data.title_id),
					layer = 1,
					alpha = 0.6,
					halign = "scale",
					valign = "scale",
					rotation = 0
				})
				local _, _, w, h = region_text:text_rect()
				region_text:set_size(w, h)
				region_text:set_center(x, y)
				table.insert(self._region_locations, {
					object = region_text,
					size = region_text:font_size()
				})
			end
			if region_text_data.sub_id then
				region_text = self._region_panel:text({
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					text = managers.localization:to_upper_text(region_text_data.sub_id),
					align = "center",
					vertical = "center",
					layer = 1,
					alpha = 0.6,
					halign = "scale",
					valign = "scale",
					rotation = 0
				})
				local _, _, w, h = region_text:text_rect()
				region_text:set_size(w, h)
				if region_text_data.title_id then
					region_text:set_position(self._region_locations[#self._region_locations].object:left(), self._region_locations[#self._region_locations].object:bottom() - 5)
				else
					region_text:set_center(x, y)
				end
				table.insert(self._region_locations, {
					object = region_text,
					size = region_text:font_size()
				})
			end
		end
	end
	if Application:production_build() and tweak_data.gui.crime_net.debug_options.regions then
		for _, data in ipairs(tweak_data.gui.crime_net.locations) do
			local location = data[1]
			if location and location.dots then
				for _, dot in ipairs(location.dots) do
					self._region_panel:rect({
						w = 1,
						h = 1,
						color = Color.red,
						x = dot[1] / tw * self._map_size_w * self._zoom,
						y = dot[2] / th * self._map_size_h * self._zoom,
						halign = "scale",
						valign = "scale",
						layer = 1000
					})
				end
			end
		end
	end
end
 
function CrimeNetGui:mouse_moved(o, x, y)
	if not self._crimenet_enabled then
		return false
	end
	if managers.menu:is_pc_controller() then
		if self._panel:child("back_button"):inside(x, y) then
			if not self._back_highlighted then
				self._back_highlighted = true
				self._back_marker:show()
				self._panel:child("back_button"):set_color(Holomenu_color_highlight)
				managers.menu_component:post_event("highlight")
			end
			return true, "link"
		elseif self._back_highlighted then
			self._back_highlighted = false
			self._back_marker:hide()
			self._panel:child("back_button"):set_color(Holomenu_color_normal)
		end
		if self._panel:child("legends_button"):inside(x, y) then
			if not self._legend_highlighted then
				self._legend_highlighted = true
				self._panel:child("legends_button"):set_color(Holomenu_color_marker)
				managers.menu_component:post_event("highlight")
			end
			return true, "link"
		elseif self._legend_highlighted then
			self._legend_highlighted = false
			self._panel:child("legends_button"):set_color(Holomenu_color_normal)
		end
		if self._panel:child("filter_button") then
			if self._panel:child("filter_button"):inside(x, y) then
				if not self._filter_highlighted then
					self._filter_highlighted = true
					self._panel:child("filter_button"):set_color(Holomenu_color_marker)
					managers.menu_component:post_event("highlight")
				end
				return true, "link"
			elseif self._filter_highlighted then
				self._filter_highlighted = false
				self._panel:child("filter_button"):set_color(Holomenu_color_normal)
			end
		end
	end
	if self._grabbed_map then
		local left = x > self._grabbed_map.x
		local right = not left
		local up = y > self._grabbed_map.y
		local down = not up
		local mx = x - self._grabbed_map.x
		local my = y - self._grabbed_map.y
		if left and self._map_panel:x() > -self:_get_pan_panel_border() then
			mx = math.lerp(mx, 0, 1 - self._map_panel:x() / -self:_get_pan_panel_border())
		end
		if right and self._fullscreen_panel:w() - self._map_panel:right() > -self:_get_pan_panel_border() then
			mx = math.lerp(mx, 0, 1 - (self._fullscreen_panel:w() - self._map_panel:right()) / -self:_get_pan_panel_border())
		end
		if up and self._map_panel:y() > -self:_get_pan_panel_border() then
			my = math.lerp(my, 0, 1 - self._map_panel:y() / -self:_get_pan_panel_border())
		end
		if down and self._fullscreen_panel:h() - self._map_panel:bottom() > -self:_get_pan_panel_border() then
			my = math.lerp(my, 0, 1 - (self._fullscreen_panel:h() - self._map_panel:bottom()) / -self:_get_pan_panel_border())
		end
		table.insert(self._grabbed_map.dirs, 1, {mx, my})
		self._grabbed_map.dirs[10] = nil
		self:_set_map_position(mx, my)
		self._grabbed_map.x = x
		self._grabbed_map.y = y
		return true, "grab"
	end
	local closest_job
	local closest_dist = 100000000
	local closest_job_x, closest_job_y = 0, 0
	local job_x, job_y
	local dist = 0
	local inside_any_job = false
	local math_x, math_y
	for id, job in pairs(self._jobs) do
		local inside = job.marker_panel:child("select_panel"):inside(x, y) and self._panel:inside(x, y)
		inside_any_job = inside_any_job or inside
		if inside then
			job_x, job_y = job.marker_panel:child("select_panel"):world_center()
			math_x = job_x - x
			math_y = job_y - y
			dist = math_x * math_x + math_y * math_y
			if closest_dist > dist then
				closest_job = job
				closest_dist = dist
				closest_job_x = job_x
				closest_job_y = job_y
			end
		end
	end
	for id, job in pairs(self._jobs) do
		local inside = job == closest_job and 1 or inside_any_job and 2 or 3
		self:update_job_gui(job, inside)
	end
	if not managers.menu:is_pc_controller() then
		local to_left = x
		local to_right = self._panel:w() - x - 19
		local to_top = y
		local to_bottom = self._panel:h() - y - 23
		local panel_border = self._pan_panel_border
		to_left = 1 - math.clamp(to_left / panel_border, 0, 1)
		to_right = 1 - math.clamp(to_right / panel_border, 0, 1)
		to_top = 1 - math.clamp(to_top / panel_border, 0, 1)
		to_bottom = 1 - math.clamp(to_bottom / panel_border, 0, 1)
		local mouse_pointer_move_x = managers.mouse_pointer:mouse_move_x()
		local mouse_pointer_move_y = managers.mouse_pointer:mouse_move_y()
		local mp_left = -math.min(0, mouse_pointer_move_x)
		local mp_right = -math.max(0, mouse_pointer_move_x)
		local mp_top = -math.min(0, mouse_pointer_move_y)
		local mp_bottom = -math.max(0, mouse_pointer_move_y)
		local push_x = mp_left * to_left + mp_right * to_right
		local push_y = mp_top * to_top + mp_bottom * to_bottom
		if push_x ~= 0 or push_y ~= 0 then
			self:_set_map_position(push_x, push_y)
		end
	end
	if inside_any_job then
		return true, "link"
	end
	if self._panel:inside(x, y) then
		return true, "hand"
	end
end
end