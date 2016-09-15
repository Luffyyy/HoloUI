HoloInfo = HoloInfo or class()
function HoloInfo:init(type)
    self._infos = {}
    self._type = type
    local scale = Holo.Options:GetValue("HudScale")    
    self._info_panel = Holo.Panel:panel({
        name = type .. "Panel",
        w = 200 * scale,
        --h = 128 * scale,       
        x = Holo.Options:GetValue("Info/" .. type .. "PosX"),
        y = Holo.Options:GetValue("Info/" .. type .. "PosY"),
        layer = -11,
        visible = Holo.Options:GetValue("Info/Timers"),
    })    
    managers.hud:add_updator(type .. "Update", callback(self, self, "Update"))
    self:UpdateHolo()
end
function HoloInfo:UpdateHolo()
    local scale = Holo.Options:GetValue("HudScale")    
    self._info_panel:set_w(math.max(200 * scale, (50 * scale) * Holo.Options:GetValue("Info/RowMaxInfos")))
	self._info_panel:set_position(Holo.Options:GetValue("Info/" .. self._type .. "PosX"), Holo.Options:GetValue("Info/" .. self._type .. "PosY"))
	local UpdateInfoLayout = function(info, color)
		local panel = info.panel and self._info_panel:child(info.panel) or self._info_panel:child(info.name)
		local box_panel = panel:child(info.panel and info.name or "name")
        HUDBGBox_recreate(box_panel,{
            w = (info.panel and 50 or 100) * scale,
            h = info.h or (info.panel and 24 or 32) * scale,
            alpha = Holo.Options:GetValue("HudAlpha"),
            color = Holo:GetColor(color or info.color),
        })      		
		if info.icon then
			box_panel:child("icon"):set_color(Holo:GetColor("TextColors/Infos"))
			box_panel:child("icon"):set_size(box_panel:h(), box_panel:h())
			box_panel:child("icon"):set_x(2 * scale)
		end
		box_panel:child("text"):configure({
			color = Holo:GetColor("TextColors/Infos"),
			x = info.icon and 10 * scale,
	        font_size = (info.panel and 20 or 24) * scale
		}) 		
		local _,_,w,h = box_panel:child("text"):text_rect()
		box_panel:set_size(math.max(box_panel:w(), w + (4 * scale)), info.h or math.max(box_panel:h(), h + (4 * scale)))
		box_panel:child("text"):set_size(box_panel:size())
		if info.icon then
			box_panel:child("icon"):set_size(box_panel:h(), box_panel:h())
		end  		
	end
	for _, info in pairs(self._infos) do
		UpdateInfoLayout(info)
		for _, value in pairs(info.values) do
			UpdateInfoLayout(value, info.timer and info.color)
		end
	end
	self:AlignInfos()
end
function HoloInfo:CreateInfo(params)
	if params.panel and not self:GetInfo(params.panel) then
		if params.timer then
			self:CreateInfo({
				name = params.panel,
				visible = true,
				timer = true,
			})
		else
			self:CreateInfo({				
				name = params.panel,
				visible = true,
				h = 0,
			})			
		end
	end
	if self:GetInfo(params.name) then
		return
	end
    local scale = Holo.Options:GetValue("HudScale")
    if not params.visible then
        params.option = "Info/" .. params.name
    end
    params.color = "Colors/" .. (params.color or params.name)
    params.name = params.name and tostring(params.name)
    params.values = {}
    local panel = params.panel and self._info_panel:child(params.panel) or self._info_panel:panel({
    	name = params.name,
        x = -(self._info_panel:w() * scale),
        h = 64 * scale,    	
    })    
    local box_panel = HUDBGBox_create(panel,{
        name = params.panel and params.name or "name",
        w = (params.panel and 50 or 100) * scale,
        h = params.h or (params.panel and 24 or 32) * scale,
        x = params.panel and panel:children()[#panel:children()],
        y = params.panel and panel:bottom(),
		},{color = Holo:GetColor(params.color), alpha = Holo.Options:GetValue("HudAlpha")
    })
    if params.icon then
        box_panel:bitmap({
	        name = "icon",
	        texture = params.icon,
	        texture_rect = params.icon_rect or {0,0},
	        color = Holo:GetColor("TextColors/Infos"),
	        w = box_panel:h(),
	        h = box_panel:h(),
	        layer = 2,
	        x = 2 * scale,
    	})	
    end
    box_panel:text({
        name = "text",
        text = params.text or not params.panel and managers.localization:text("Holo/" .. params.name) or "0:00",
        wrap = true,
        vertical = "center",
        x = params.icon and 10 * scale,
        align = "center",
        layer = 2,
        color = Holo:GetColor("TextColors/Infos"),
        font = "fonts/font_large_mf",
        font_size = (params.panel and 20 or 24) * scale
    }) 
	local _,_,w,h = box_panel:child("text"):text_rect()
	box_panel:set_size(math.max(box_panel:w(), w + (4 * scale)), params.h or math.max(box_panel:h(), h + (4 * scale)))
	box_panel:child("text"):set_size(box_panel:size())  
	if params.icon then
		box_panel:child("icon"):set_size(box_panel:h(), box_panel:h())
	end  
    if not params.panel then
    	table.insert(self._infos, params)
    else
    	table.insert(self:GetInfo(params.panel).values, params)
    end    
    self:AlignInfos()
end
function HoloInfo:AlignInfos()
    local i = 1
    local scale = Holo.Options:GetValue("HudScale")
    local last_panel 
    for _, info in pairs(self._infos) do            
        local panel = self._info_panel:child(info.name)
        if info.visible then
            i = i + 1
            GUIAnim.play(panel, "alpha", 1) 
            panel:set_w(self._info_panel:w())
            panel:set_x(0)
            panel:set_y(last_panel and (last_panel:bottom() + (2 * scale)) or 0)
            local times = 1
            local vi = 0
            for _, value in pairs(info.values) do                   
                local value_panel = panel:child(value.name)
                if value.visible then
                    vi = vi + 1
                    times = math.ceil(vi / Holo.Options:GetValue("Info/RowMaxInfos"))
                    local num = vi % Holo.Options:GetValue("Info/RowMaxInfos")
                    num = num == 0 and Holo.Options:GetValue("Info/RowMaxInfos") or num
                    value_panel:stop()
                    GUIAnim.play(value_panel, "alpha", 1)      
                    local x = panel:w() - value_panel:w() * num
                    if Holo.Options:GetValue("Info/" .. self._type .. "FromLeft")  then
                        x = value_panel:w() * (num - 1)
                    end        
                    GUIAnim.play(value_panel, "x", x, 3)              
                    GUIAnim.play(value_panel, "y", panel:child("name"):bottom() + (value_panel:h() * (times - 1)), 3)               
                else
                    GUIAnim.play(value_panel, "alpha", 0)
                end
				if value.unit and (not alive(value.unit) or not value.unit:timer_gui()._visible)  then
					self:RemoveInfoValue(value.panel, value.name)
				end				
            end
            last_panel = panel
            panel:set_h(panel:child("name"):h() + (times * (24 * scale)))
        else
            GUIAnim.play(panel, "alpha", 0) 
        end
    end
end
function HoloInfo:RemoveInfo(name)
	for i, info in pairs(self._infos) do
		if info.name == tostring(name) then
			self._info_panel:remove(self._info_panel:child(info.name))
			table.remove(self._infos, i)
			self:AlignInfos()
			return true
		end
	end
	return false
end
function HoloInfo:RemoveInfoValue(info, name)
	local wanted_info = self:GetInfo(info)
	if not wanted_info then
		return
	end
	local info_values = wanted_info.values
	for i, value in pairs(info_values) do
		if value.name == tostring(name) then
			self._info_panel:child(info):remove(self._info_panel:child(info):child(value.name))
			table.remove(info_values, i)
			self:AlignInfos()
			return true
		end
	end
	return false
end
function HoloInfo:SetInfoValueColor(info, name, color_name)
	local wanted_info = self:GetInfo(info)
	if not wanted_info then
		return
	end
	local info_values = wanted_info.values
	for i, value in pairs(info_values) do
		if value.name == tostring(name) then
			value.color = "Colors/" .. color_name
			return true
		end
	end
	return false
end
function HoloInfo:GetInfo(name)
	for _, info in pairs(self._infos) do
		if info.name == tostring(name) then
			return info
		end
	end
end
function HoloInfo:SetInfoName(info, name)
	self._info_panel:child(info):child("name"):child("text"):set_text(tostring(name))	
end
function HoloInfo:SetInfoTime(info, val_name, time, force_seconds)
    local time_text = math.floor(time or 0)
    local minutes = math.floor(time_text / 60)
    time_text = time_text - minutes * 60
    local seconds = math.round(time_text)
    time_text = (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
    self:SetInfoValue(info, val_name, force_seconds and seconds or time_text)
end
function HoloInfo:SetInfoValue(info, val_name, value)
	if info and val_name and value then
		if self._info_panel:child(info) and self._info_panel:child(info):child(tostring(val_name)) then
			self._info_panel:child(info):child(tostring(val_name)):child("text"):set_text(tostring(value))	
		end
	end
end
function HoloInfo:Update(t, dt)
    for k, typ in pairs(Holo.Loot) do
        for _, unit in pairs(typ) do
            if not unit:enabled() then
                Holo:RemoveLoot(k, unit)
            end
        end
    end	
	for i, info in pairs(self._infos) do
		if info.timer then
			info.visible = #info.values > 0
		else
			for i, value in pairs(info.values) do
	            if value.func and (not value.option or Holo.Options:GetValue(value.option)) then 
	                self[value.func](self, value)
	            else
	                value.visible = false
	            end
			end	
		end
	end
	self:AlignInfos()
end
function HoloInfo:CountInfo(info)
    local i = info.value_is_table and table.size(info.value()) or info.value()
    if info.name == "Enemies" or "Civilians" and type(info.value()) == "table" then
		for _, ene in pairs(info.value()) do
			if ene.unit:brain()._logic_data and ene.unit:brain()._logic_data.is_tied then
				i = i - 1
			end
		end
    end
    info.visible = i > 0
    self:SetInfoValue("InfoBoxes", info.name, i)     
end
function HoloInfo:CountPagers(info)
    info.visible = managers.groupai:state():whisper_mode()        
    self:SetInfoValue("InfoBoxes", info.name, 4 - managers.groupai:state()._nr_successful_alarm_pager_bluffs)
end
function HoloInfo:CountLoot(info)
	local i = #Holo.Loot[info.name]
    info.visible = i > 0
    self:SetInfoValue("InfoBoxes", info.name, i) 
end
function HoloInfo:UpdateMeleeCharge(info)
	local ply = managers.player:player_unit()
	if not ply or not ply:movement() or not ply:movement():current_state() then
		return
	end
	local state = ply:movement():current_state()
	local max_charge_time = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time
	local start_t = state._state_data and state._state_data.melee_start_t
    info.visible = state._state_data.meleeing
	if start_t then
		local p = math.clamp(managers.player:player_timer():time() - state._state_data.melee_start_t, 0, max_charge_time) / max_charge_time
    	self:SetInfoValue("InfoBoxes", info.name, math.floor(p * 100) .. "%")
	end
end
function HoloInfo:UpdateStamina(info)
	local ply = managers.player:player_unit()
	if not ply or not ply:movement() then
		return
	end
	local stamina = ply:movement()._stamina / ply:movement():_max_stamina()
    info.visible = stamina < 1
    self:SetInfoValue("InfoBoxes", info.name, math.floor(stamina * 100) .. "%")
end
function HoloInfo:ShowInspireCoolDown(info)
	local ply = managers.player:player_unit()	
	if not ply or not ply:movement():rally_skill_data() then
		return
	end
	local t = managers.player:player_timer():time() - ply:movement():rally_skill_data().morale_boost_delay_t
    info.visible = t < 0
    self:SetInfoValue("InfoBoxes", info.name, string.format("%.1f", math.abs(info.visible and t or 0)))
end
function HoloInfo:CountHostages(info)
    self:SetInfoValue("InfoBoxes", info.name, managers.groupai:state()._hostage_headcount) 
end