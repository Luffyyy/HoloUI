HoloInfo = HoloInfo or class()
function HoloInfo:init(hud)
    self._full_hud = hud
    self._infos = {}
    local scale = Holo.Options:GetValue("HudScale")    
    self._info_panel = self._full_hud:panel({
        name = "info_panel",
        w = 200 * scale,
        --h = 128 * scale,       
        x = Holo.Options:GetValue("Info/InfoPosX"),
        y = Holo.Options:GetValue("Info/InfoPosY"),
        layer = -11,
        visible = Holo.Options:GetValue("Info/Timers"),
    })    
	self:CreateInfo({
		name = "Hostages",
	    icon = "guis/textures/pd2/skilltree/icons_atlas",       
	    icon_rect = {255,449, 64, 64},
	    func = "CountHostages",
		panel = "InfoBoxes",
		visible = true,
		text = "0",
	})
	self:CreateInfo({
		name = "Civilians",
	    icon = "guis/textures/pd2/skilltree/icons_atlas",
	    icon_rect = {386,447,64,64},
		panel = "InfoBoxes",
		text = "0",
        func = "CountInfo",   
        value_is_table = true,     
        value = callback(managers.enemy, managers.enemy, "all_civilians"),		
	})
	self:CreateInfo({
		name = "Enemies",
	    icon = "guis/textures/pd2/skilltree/icons_atlas",
	    icon_rect = {2,319,64,64},
		panel = "InfoBoxes",
		text = "0",
        func = "CountInfo",        
        value_is_table = true,
        value = callback(managers.enemy, managers.enemy, "all_enemies"),
	})
	self:CreateInfo({
        name = "Pagers",
        icon = "guis/textures/pd2/specialization/icons_atlas",
		panel = "InfoBoxes",
        icon_rect = {66,254,64,64},		
		text = "0",
		func = "CountPagers",
	})	
	self:CreateInfo({
        name = "GagePacks",
        icon = "guis/textures/pd2/specialization/icons_atlas",
		panel = "InfoBoxes",
        icon_rect = {66,254,64,64},		
		text = "0",
		func = "CountInfo",
        value = callback(managers.gage_assignment, managers.gage_assignment, "count_active_units"),
	})
	local rects = {
	    Money = {4, 3, 70, 59},
	    Diamonds = {72, 7, 53, 53},
	    Gold = {132, 9, 56, 52},
	    Weapons = {188, 3, 57, 62},
	    SmallLoot = {66, 59, 62, 57},
	}
	for typ, _ in pairs(Holo.Loot) do
		self:CreateInfo({
			name = typ,
			visible = true,
		    icon = "guis/Holo/InfoIcons",
		    func = "CountLoot",
		    icon_rect = rects[typ] or rects.Money,
			panel = "InfoBoxes",
			text = "0",
		})	
	end
    managers.hud:add_updator("InfoUpdate", callback(self, self, "Update"))
    self:UpdateHoloHUD()
end
function HoloInfo:UpdateHoloHUD()
    local scale = Holo.Options:GetValue("HudScale")    
    self._info_panel:set_w(math.max(200 * scale, (50 * scale) * Holo.Options:GetValue("Info/RowMaxInfos")))
	self._info_panel:set_position(Holo.Options:GetValue("Info/InfoPosX"), Holo.Options:GetValue("Info/InfoPosY"))
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
    params.color = params.color or "Colors/" .. params.name
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
        x = params.panel and -(50 * scale),
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
        text = params.text or managers.localization:text("Holo/" .. params.name),
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
	        panel:stop()
	       	panel:set_w(self._info_panel:w())
	        panel:set_y(last_panel and (last_panel:bottom() + (2 * scale)) or 0)
	        GUIAnim.play(panel, "x", 0)
	       	local times = 1
	       	local vi = 0
	        for _, value in pairs(info.values) do		        	
	        	local value_panel = panel:child(value.name)
	        	if value.visible then
		        	vi = vi + 1
		        	times = math.ceil(vi / Holo.Options:GetValue("Info/RowMaxInfos"))
		            local num = vi % Holo.Options:GetValue("Info/RowMaxInfos")
		            num = num == 0 and Holo.Options:GetValue("Info/RowMaxInfos") or num
		            value_panel:set_y(panel:child("name"):bottom() + (value_panel:h() * (times - 1)))
		            value_panel:stop()
		            GUIAnim.play(value_panel, "x", value_panel:w() * (num - 1), 3)	        	
		        else
		        	GUIAnim.play(value_panel, "x", -value_panel:w(), 3)	
	        	end
	    	end
			last_panel = panel
	    	panel:set_h(panel:child("name"):h() + (times * (24 * scale)))
	    else
	    	GUIAnim.play(panel, "x", -panel:w(), 3)	
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
			value.color = color_name
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
	if self._info_panel:child(info) and self._info_panel:child(info):child(tostring(val_name)) then
		self._info_panel:child(info):child(tostring(val_name)):child("text"):set_text(tostring(value))	
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
    if info.name == "Enemies" or "Civilians" then
		for _, ene in pairs(info.value()) do
			if ene.unit:brain()._logic_data.is_tied then
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
function HoloInfo:CountHostages(info)
    self:SetInfoValue("InfoBoxes", info.name, managers.groupai:state()._hostage_headcount) 
end