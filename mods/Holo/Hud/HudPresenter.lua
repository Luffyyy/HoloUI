if not Holo.options.PDTHHud_support or not pdth_hud.loaded_options.Ingame.Objectives then
Holo:clone(HUDPresenter)
function HUDPresenter:init(...)
	self.old.init(self, ...)
	self._bg_box:child("bg"):set_color(objremindbox_color)
	self._bg_box:child("bg"):set_alpha(HoloAlpha)
	self._bg_box:child("title"):set_color(objremindbox_text_color)
	self._bg_box:child("title"):set_font_size(12)

	self._bg_box:child("title"):set_font(Idstring("fonts/font_large_mf"))	
	self._bg_box:child("text"):set_color(objremindbox_text_color)
	self._bg_box:child("text"):set_font_size(12)
	self._bg_box:child("text"):set_font(Idstring("fonts/font_large_mf"))
end

 function HUDPresenter:update()
	self._bg_box:child("bg"):set_color(objremindbox_color)
	self._bg_box:child("bg"):set_alpha(HoloAlpha)
	self._bg_box:child("title"):set_color(objremindbox_text_color)
	self._bg_box:child("text"):set_color(objremindbox_text_color)
end

 
function HUDPresenter:_animate_present_information(present_panel, params)	
	local title = self._bg_box:child("title")
	local text = self._bg_box:child("text")
	present_panel:set_visible(true)
	present_panel:set_alpha(1)
	title:set_visible(true)
	text:set_visible(true)
 
	local function open_done()
		wait(params.seconds)
		local function close_done()
			present_panel:set_visible(false)
			self:_present_done()
		end
		self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_center"), close_done)
	end
	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "animate_open_center"), self._bg_box:w(), open_done, title, text)
end

function animate_open_center( panel, target_w, done_cb )
	panel:set_visible( false )
	local center_x = panel:center_x()
	panel:set_w( 0 )
	panel:set_visible( true )
	local TOTAL_T = target_w/800
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		panel:set_w( (1 - t/TOTAL_T) * target_w )
		panel:set_center_x( center_x )
	end
	panel:set_w( target_w )
	panel:set_center_x( center_x )
	if done_cb then
		done_cb()
	end
end
end