GUIAnim = GUIAnim or {}
function GUIAnim:play(func, ...)
	if GUIAnim["set_" .. func] then
		self:animate(callback(GUIAnim, GUIAnim, "set_" .. func), ...)
	elseif GUIAnim[func] then
		self:animate(callback(GUIAnim, GUIAnim, func), ...)
	else
		self:animate(callback(GUIAnim, GUIAnim, "animate"), func ,...)
	end
end
function GUIAnim:animate(o, func, v, speed, clbk)
	speed = speed or 2
	speed = math.abs(o[func](o) - v) * speed
	speed = speed < 1 and 1 or speed
    while o[func](o) ~= v do
		o["set_" .. func](o, math.step(o[func](o), v, coroutine.yield() * speed))
    end
	o["set_" .. func](o, v)
    if clbk then
    	clbk()
    end
end
function GUIAnim:animate2(o, func, v1, v2, clbk)
   	local t = 0
   	local o_v1, o_v2 = o[func](o)
    while t < 0.3 do
        t = t + coroutine.yield()
        local n = 1 - math.sin(t * 300)
        o["set_" .. func](o, math.lerp(v1, o_v1, n), math.lerp(v2, o_v2, n))
    end
    o["set_" .. func](o, v1, v2)
    if clbk then
    	clbk()
    end
end
function GUIAnim:left_grow(o, v, clbk)
	wait(0.25)
	local speed = 4
	speed = math.abs(o:w() - v) * speed
	speed = speed < 1 and 1 or speed
	local right = o:right()
	o:set_w(0)
    while o:w() ~= v do
		o:set_w(math.step(o:w(), v, coroutine.yield() * speed))
		o:set_right(right)
    end
	o:set_w(v)
    if clbk then
    	clbk()
    end
end
function GUIAnim:center_grow(o, v, clbk)
	local speed = 4
	speed = math.abs(o:w() - v) * speed
	speed = speed < 1 and 1 or speed
	local center_x = o:center_x()
	o:set_w(0)
    while o:w() ~= v do
		o:set_w(math.step(o:w(), v, coroutine.yield() * speed))
		o:set_center_x(center_x)
    end
	o:set_w(v)
    if clbk then
    	clbk()
    end
end
function GUIAnim:set_lefttop(o, ...)
	self:animate2(o, "lefttop", ...)
end

function GUIAnim:set_righttop(o, ...)
	self:animate2(o, "righttop", ...)
end

function GUIAnim:set_leftbottom(o, ...)
	self:animate2(o, "leftbottom", ...)
end

function GUIAnim:set_rightbottom(o, ...)
	self:animate2(o, "rightbottom", ...)
end

function GUIAnim:set_position(o, ...)
	self:animate2(o, "position", ...)
end
function GUIAnim:set_color(o, v, speed, clbk)
	speed = speed or 10
    while o:color() ~= v do
		local n = coroutine.yield() * speed
       	o:set_color(Color(math.step(o:color().r, v.r, n), math.step(o:color().g, v.g, n), math.step(o:color().b, v.b, n)))
	end
    o:set_color(v)
    if clbk then
    	clbk()
    end
end
function GUIAnim:set_number(o, v, clbk)
	local t = 0
	local o_v = tonumber(o:text())
	while t < 0.5 do
		t = t + coroutine.yield()
		o:set_text(string.format("%.0f", math.lerp(v, o_v, 1 - math.sin(t * 180))))
	end
	o:set_text(string.format("%.0f", v))
end

function GUIAnim:move(o,x,y,clbk)
	self:animate2(o, "position", o:x() + x, o:y() + y,clbk)
end

function GUIAnim:grow(o,w,h,clbk)
	self:animate2(o, "size", o:w() + w, o:h() + h,clbk)
end
