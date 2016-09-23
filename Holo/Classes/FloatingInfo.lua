FloatingInfo = FloatingInfo or class()
function FloatingInfo:init(unit, world)
    if not managers.hud then
        return 
    end
    local panel 
    if world then
	    self._ws = World:newgui():create_linked_workspace(100, 100, unit, unit:position() + unit:rotation():y() * 25, unit:rotation():x() * 50, unit:rotation():y() * 50)
	    self._ws:set_billboard(self._ws.BILLBOARD_BOTH)
        panel = self._ws:panel()
    else
        panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel 
    end
    
	self._panel = panel:panel({
		name = "floating_label" .. #managers.hud._floating_infos + 1
	})
	local text = self._panel:text({
		name = "amount",
        text = "2 / 4",
        w = 0,
        x = 4,
        align = "center",
        vertical = "center",
		font = "fonts/font_large_mf",
        color = Color.white,
        render_template = "OverlayVertexColorTextured",
		font_size = 32,
	})
    local _,_,_,h = text:text_rect()
    text:set_h(h)
    self._panel:rect({
        name = "curr_line",
        w = w,
        y = h,
        h = 2,
        render_template = "OverlayVertexColor",
        color = Holo:GetColor("Colors/Main"),
    })
   	self._panel:rect({
        name = "bg_line",
        w = w,
        y = h,
        h = 2,
        color = Color.white,
        render_template = "OverlayVertexColor",      
        layer = -1,
    })   
    self.text = ""
    self.percent = 0
    self.unit = unit
    self.color = Holo:GetColor("Colors/Main")
    self.in_world = world
	table.insert(managers.hud._floating_infos, self)
end
local nl_w_pos = Vector3()
local nl_pos = Vector3()
local nl_dir = Vector3()
local nl_dir_normalized = Vector3()
local nl_cam_forward = Vector3()
function FloatingInfo:update(t, dt)
    if self.unit and (not alive(self.unit) or (self.unit.timer_gui and self.unit:timer_gui() and not self.unit:timer_gui()._visible)) then
        self:destroy() --force destroy if unit is dead
    end
	if alive(self._panel) and alive(self.unit) then
        local amount = self._panel:child("amount")
        local curr_line = self._panel:child("curr_line")
        local bg_line = self._panel:child("bg_line")
	    amount:set_text(self.text)
        local _,_,w,h = amount:text_rect()
        amount:set_size(math.max(amount:w(), w + 4), h)
        curr_line:set_color(self.color)
        curr_line:set_w(amount:w() * self.percent)
        bg_line:set_w(amount:w())
        if not self.in_world then
            local cam = managers.viewport:get_current_camera()
            if not cam then
                return
            end
            local player = managers.player:local_player()
            local in_steelsight = alive(player) and player:movement() and player:movement():current_state() and player:movement():current_state():in_steelsight() or false
            local cam_pos = managers.viewport:get_current_camera_position()
            local cam_rot = managers.viewport:get_current_camera_rotation()
            mrotation.y(cam_rot, nl_cam_forward)
            local pos = self.unit:position()
            mvector3.set(nl_w_pos, pos)
            mvector3.set_z(nl_w_pos, pos.z + 50)
            mvector3.set(nl_pos, managers.hud._workspace:world_to_screen(cam, nl_w_pos))
            mvector3.set(nl_dir, nl_w_pos)
            mvector3.subtract(nl_dir, cam_pos)
            mvector3.set(nl_dir_normalized, nl_dir)
            mvector3.normalize(nl_dir_normalized)
            local dot = mvector3.dot(nl_cam_forward, nl_dir_normalized)
            if dot < 0 or self._panel:parent():outside(mvector3.x(nl_pos), mvector3.y(nl_pos)) then
                if self._panel:visible() then
                    self._panel:set_visible(false)
                end
            else
                self._panel:set_alpha(math.clamp(dot, 0, 1) or 1)
                self._panel:set_visible(mvector3.distance_sq(cam_pos, nl_w_pos) < 300000)
                if dot > 0.99 then
                    self._panel:show()
                end
            end
            if self._panel:visible() then
                self._panel:set_position(nl_pos.x, nl_pos.y)
            end       
        end
	end
end
function FloatingInfo:destroy()
    if self.in_world and alive(self._ws) then
        World:newgui():destroy_workspace(self._ws)
    elseif alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
end

 