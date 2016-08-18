CircleGuiObject = CircleGuiObject or class()
function CircleGuiObject:init(panel, config)
	self._panel = panel
	self._radius = config.radius or 20
	self._sides = config.sides or 10
	self._total = config.total or 1
	config.triangles = self:_create_triangles(config)
	config.w = self._radius * 2
	config.h = self._radius * 2
	self._circle = self._panel:polygon(config)
end
function CircleGuiObject:_create_triangles(config)
	local amount = 360 * (config.current or 1) / (config.total or 1)
	local s = self._radius
	local triangles = {}
	local step = 360 / self._sides
	for i = step, amount, step do
		local mid = Vector3(self._radius, self._radius, 0)
		table.insert(triangles, mid)
		table.insert(triangles, mid + Vector3(math.sin(i) * self._radius, -math.cos(i) * self._radius, 0))
		table.insert(triangles, mid + Vector3(math.sin(i - step) * self._radius, -math.cos(i - step) * self._radius, 0))
	end
	return triangles
end
function CircleGuiObject:set_current(current)
	local triangles = self:_create_triangles({
		current = current,
		total = self._total
	})
	self._circle:clear()
	self._circle:add_triangles(triangles)
end
function CircleGuiObject:set_position(x, y)
	self._circle:set_position(x, y)
end
function CircleGuiObject:set_layer(layer)
	self._circle:set_layer(layer)
end
function CircleGuiObject:layer()
	return self._circle:layer()
end
function CircleGuiObject:remove()
	self._panel:remove(self._circle)
end
Hooks:PostHook(CircleBitmapGuiObject, "init", "HoloInit", function(self)
	self._circle:set_image("guis/Holo/Circle" .. (Holo.RadialNames[Holo.Options:GetValue("Colors/Progress")]))
	self._circle:set_blend_mode("normal")
	if self._bg_circle then
		self._bg_circle:set_image("guis/Holo/CircleTransparent")
	end
end)
 
