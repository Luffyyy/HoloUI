if not Holo:ShouldModify("HUD", "Presenter") then
	return
end

Holo:Post(HUDHint, "init", function(self, hud)
	self._queue = {}
	self._showing = 0
	self._bg_box = HUDBGBox_create(self._hint_panel)
	self:UpdateHolo()
	Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	BeardLib:AddUpdater("HUDHintUpdate", callback(self, self, "update"))		
end)

function HUDHint:UpdateHolo()
	self._hint_panel:set_h(38)
	self._hint_panel:set_y(56)
	self._hint_panel:set_world_center_x(self._hint_panel:parent():world_center_x())
	HUDBGBox_recreate(self._bg_box, {
		name = "Presenter",
		h = 48,
	})
	local clip_panel = self._hint_panel:child("clip_panel")
	clip_panel:child("bg"):hide()
	clip_panel:child("hint_text"):configure({
		color = Holo:GetColor("TextColors/Presenter"),
		font = "fonts/font_large_mf",
		font_size = 20,
		align = "center",
		vertical = "center",
		alpha = 1,
		visible = true,
	})
	self._hint_panel:child("marker"):set_h(0)
end

function HUDHint:update(t, dt)
	if self._showing > 0 then
		self._showing = self._showing - dt
		if self._showing < 0 then
			play_value(self._hint_panel, "alpha", 0)
		end
	elseif self._queue[1] then
		self:show(table.remove(self._queue, 1))
	end
end

Holo:Replace(HUDHint, "show", function(self, orig, params, ...)
	self._showing = self._showing or 0
	self._queue = self._queue or {}
	if self._showing > 0 then
		table.insert(self._queue, params)
		return
	end
	orig(self, params, ...)	
	
	self._showing = params.time or 3
	local clip_panel = self._hint_panel:child("clip_panel")
	self._hint_panel:stop()
	local t = clip_panel:child("hint_text")
	managers.hud:make_fine_text(t)
	t:set_size(t:w() + 12, t:h() + 12)
	clip_panel:set_shape(0, 0, t:size())
	t:set_h(clip_panel:h())
	self._hint_panel:set_size(clip_panel:size())
	self._hint_panel:set_world_center_x(self._hint_panel:parent():w() / 2)	
	self._hint_panel:set_alpha(0)
	self._hint_panel:show()	
	HUDBGBox_recreate(self._bg_box, {
		name = "Presenter",
		w = clip_panel:w(),
		h = clip_panel:h(),
	})
	play_value(self._hint_panel, "alpha", 1)
end)

function HUDHint:stop()
	play_value(self._hint_panel, "alpha", 0)
end