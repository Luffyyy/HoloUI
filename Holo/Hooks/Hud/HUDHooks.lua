if not Holo.Options:GetValue("Hud") then
	return
end
--Like MenuHooks this contains code that is too short to be in a separated file
local F = table.remove(string.split(RequiredScript, "/"))
local Holo = Holo

if F == "timergui" then
    TimerGui.upgrade_colors.upgrade_color_0 = Color(0.09, 0.12, 0.14)
    TimerGui.upgrade_colors.upgrade_color_1 = Color.white
elseif F == "hudsuspicion" then
    Holo:Post(HUDSuspicion, "init", function(self)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)
	function HUDSuspicion:UpdateHolo()
		self._suspicion_panel:set_center(self._suspicion_panel:parent():w() / 2, self._suspicion_panel:parent():h() / 2)
		Holo.Utils:SetBlendMode(self._suspicion_panel)
    end
elseif F == "coresubtitlepresenter" then
    core:module("CoreSubtitlePresenter")
    core:import("CoreClass")
    OverlayPresenter = OverlayPresenter or CoreClass.class(SubtitlePresenter or CoreClass.class())
    function OverlayPresenter:UpdateHolo()
        if self.__subtitle_panel and self.__subtitle_panel:child("label") then
            self.__subtitle_panel:child("label"):set_color(Holo:GetColor("TextColors/Captions"))
        end
    end
    Holo:Post(OverlayPresenter, "init", function(self) Holo:AddUpdateFunc(callback(self, self, "UpdateHolo")) end)
    Holo:Post(OverlayPresenter, "show_text", OverlayPresenter.UpdateHolo)
elseif F == "hudpresenter" and Holo:ShouldModify("Hud", "Presenter") then
    Holo:Post(HUDPresenter, "init", function(self)
		self._bg_box:hide()
		self._bg_box:set_alpha(0)
	end)
	function HUDPresenter:_present_information(params)
		managers.hud._hud_hint:show({text = string.format("%s %s", utf8.to_upper(params.title or "ERROR"), utf8.to_upper(params.text))})
    end
elseif F == "circleguiobject" and Holo:ShouldModify("Hud", "Interaction") then
    Holo:Post(CircleBitmapGuiObject, "init", function(self)
        self._circle:set_blend_mode("normal")
    end)
end