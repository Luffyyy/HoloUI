HoloMenu = HoloMenu or class()
function HoloMenu:init()
    MenuUI:new({
        background_alpha = 0.65,
        text_color = Holo:GetColor("TextColors/Menu"),        
        background_color = Holo:GetColor("Colors/MenuBackground"),
        text_highlight_color = Holo:GetColor("TextColors/MenuHighlighted"),
        marker_alpha = 0,
        marker_highlight_color = Holo:GetColor("Colors/Marker"),
        mouse_press = callback(self, self, "MousePressed"),
        mouse_move = callback(self, self, "MouseMoved"),
        mouse_release = callback(self, self, "MouseReleased"),
        w = "half",
        align = "left",
        offset = 4,
        toggle_key = Holo.Options:GetValue("OptionsKey"),
        toggle_clbk = function(closed)
            if managers.hud then
                managers.hud._chatinput_changed_callback_handler:dispatch(not closed)
            end
        end,
        create_items = callback(self, self, "CreateItems"),
    })
end
function HoloMenu:CreateItems(menu)
    self._menu = menu
    self._tabs = menu:NewMenu({
        background_alpha = 0,
        name = "tabs",
        h = 30,
        w = "full",
        items_size = 20,
        align = "center",
        visible = true,
        position = {10, 10},
        size_by_text = true,
        row_max = 1,
    })
    self._menus = {
        main = self:Menu("Main"),
        colors = self:Menu("Colors"),
        textcolors = self:Menu("TextColors"),
        extra = self:Menu("Extra"),
    }
    self._customcolors = self:Menu("CustomColors")
    local close = self._tabs:Button({
        name = "Close",
        text = "Holo/Close",
        localized = true,
        callback = MenuCallbackHandler.OpenHoloMenu
    })
    close:Panel():child("bg"):set_h(2)
    close:Panel():child("bg"):set_rotation(360)
    close:Panel():child("bg"):set_y(close:Panel():h() + 2)

    self._current_menu = main    
    for k, v in ipairs(Holo.Colors) do
        table.insert(Holo.AllColorsStrings, v.custom and v.name or managers.localization:text("Holo/" .. v.name))
    end
    Holo.ColorsStrings = {}
    for k, v in pairs(Holo.AllColorsStrings) do
        if k ~= 1 then
            table.insert(Holo.ColorsStrings, v)
        end
    end
    self:CreateGroupOptions(Holo.Options._config.options)
    self:CreateCustomColorsMenu(self._customcolors)
    for k, optmenu in pairs(self._menus) do
        optmenu:Button({
            name = "Reset",
            text = "Holo/Reset",
            localized = true,
            callback = callback(self, self, "ResetOptions", false),
        })
    end
    self._menus.main:Button({
        name = "Reset",
        text = "Holo/ResetAll",
        localized = true,
        callback = callback(self, self, "ResetOptions", true),
    })
    local panel = self._menu._fullscreen_ws_pnl

    local resize_panel = panel:panel({
        name = "resize_panel",
        w = 4,
        layer = self._menu._panel:layer() + 1,
        x = self._menu._panel:right(),
    })    
    resize_panel:rect({
        color = Holo:GetColor("Colors/Marker")
    })
end

function HoloMenu:Loc(s)
    return "Holo/" .. s
end

function HoloMenu:CreateGroupOptions(group, parent_name)
    for _, setting in ipairs(group) do  
        local group_name = group.name or "Main"
        local menu = self._menu:GetItem(group_name, true)
        if type(setting) == "table" and setting._meta ~= "option_set" then
            if setting._meta == "option_group" then
                self:CreateGroupOptions(setting, group_name)
            else
                if parent_name and parent_name ~= "Main" then 
                    group_name = parent_name .. "/" .. group_name
                end
                local name = (group_name ~= "Main" and group_name .. "/" or "") .. setting.name
                local _menu = group.menu or setting.menu
                if _menu then
                    menu = self._menu:GetItem(_menu, true)
                end         
                local txt = self:Loc(setting.name)
                if not menu:GetItem(name) then
                    local items = Holo[setting.items] or Holo.AllColorsStrings
                    local loc_items = items ~= Holo.AllColorsStrings and items ~= Holo.ColorsStrings
                    if group.name and group.name:match("Colors") and setting._meta == "option" and setting.type == "number" then
                        local outside = menu.name ~= group.name
                        self:ComboBox(menu, name, outside and self:TitleColor(setting.name, group.name, setting.beforetext) or txt, items, nil, true, not outside, loc_items, setting.index)
                    else
                        if setting.type == "number" then       
                            if setting.menu_type == "combo" then
                                self:ComboBox(menu, name, txt, items, nil, not loc_items, true, loc_items, setting.index)
                            else
                                if setting.min and setting.max then
                                    self:Slider(menu, name, txt, setting.min, setting.max, nil, setting.floats, true, setting.index)
                                else
                                    self:NumberBox(menu, name, txt, nil, setting.floats, true, setting.index)
                                end
                            end
                        elseif setting.type == "boolean" then
                            self:Toggle(menu, name, self:BeforeText(setting.beforetext or "Enable", setting.text or setting.name), nil, false, setting.index)
                        elseif setting._meta == "div" then
                            self:Divider(menu, setting.text or setting.name, setting.beforetext and self:BeforeText(setting.beforetext, setting.name))
                        else
                            menu:KeyBind({
                                name = name,
                                text = txt,
                                localized = true,
                                value = Holo.Options:GetValue(name),
                                callback = callback(self, self, "MainClbk")
                            })
                        end
                    end                    
                end
            end
        end
    end
end
function HoloMenu:CreateCustomColorsMenu(menu)
    self:Divider(menu, "CustomColorsDesc")
    self:Divider(menu, "Preview", "")
    self:TextBox(menu, "Name", nil, callback(self, self, "UpdateColor"), true)
    self:Slider(menu, "Red", nil, 0, 1, callback(self, self, "UpdateColor"), 2, true)
    self:Slider(menu, "Green", nil, 0, 1, callback(self, self, "UpdateColor"), 2, true)
    self:Slider(menu, "Blue", nil, 0, 1, callback(self, self, "UpdateColor"), 2, true)
    self:Button(menu, "Apply", nil, callback(self, self, "ApplyColor"), true, {8, 4})
    self:Button(menu, "New", nil, callback(self, self, "SetCurrentCustomColor"), true, {8, 4})
    self:UpdateColor(menu)
    self:Divider(menu, "Saved")
    for k, v in pairs(Holo.Options:GetOption("CustomColors")) do
        if type(v) == "table" and v.value then
            self:CreateColor(menu, k, v.value.name, v.value.color)
        end
    end
end
function HoloMenu:CreateColor(menu, i, name, color)
    local btn = menu:GetItem(self._current or i)
    if self._current and self._current ~= i then
        Holo.Options._storage.CustomColors[self._current] = nil
        btn.name = i
        self._current = i
    end
    if not btn then
        btn = self:Button(menu, i, name, callback(self, self, "SetCurrentCustomColor"), false, {16, 2}, "After|Saved")
        menu:Button({
            name = "delete_" .. i,
            text = "x",
            override_parent = btn,
            size_by_text = true,
            position = "RightTop",
            align = "center",
            callback = function()
                local v = Holo.init_colors + i
                self:WorkValues(true, nil, function(item)
                   if item.items and item.color and item.value > v then
                        Holo.Options:SetValue(item.name, item.value - 1)   
                    end                  
                end)
                Holo.Options._storage.CustomColors[i] = nil
                Holo.Options:Save()
                if self._current == i then
                    menu:GetItem("New"):RunCallback()
                end
                menu:RemoveItem(btn)
            end,
            marker_highlight_color = Color.red,
        })        
    end
    btn:SetColor(color)
    btn:SetText(name)
end
function HoloMenu:SetCurrentCustomColor(menu, item)
    local name = menu:GetItem("Name")
    local red = menu:GetItem("Red")
    local green = menu:GetItem("Green")
    local blue = menu:GetItem("Blue")
    local curr = menu:GetItem(self._current)         
    if curr then
        curr:SetParam("text_color", Holo:GetColor("TextColors/Menu"))
        curr:SetParam("text_highlight_color", Holo:GetColor("TextColors/MenuHighlighted"))
        curr:Panel():child("title"):set_color(Holo:GetColor("TextColors/Menu"))       
    end
    local same = self._current == item.name
    self._current = nil
    name:SetValue("", true)
    red:SetValue(1, true)
    green:SetValue(1, true)
    blue:SetValue(1, true)   
    if item.name == "New" or same then
        return
    end        
    self._current = item.name
    local col = Holo:GetColor("TextColors/MenuHighlighted")
    item:SetParam("text_color", col)
    item:SetParam("text_highlight_color", col)
    item:Panel():child("title"):set_color(col)
    name:SetValue(item.text, true)
    red:SetValue(item.color.r, true)
    green:SetValue(item.color.g, true)
    blue:SetValue(item.color.b, true)
end
function HoloMenu:CurrentCustomColor()
    local menu = self._customcolors
    return Color(menu:GetItem("Red").value, menu:GetItem("Green").value, menu:GetItem("Blue").value)
end
function HoloMenu:UpdateColor(menu)
    menu:GetItem("Preview"):SetParam("marker_color", self:CurrentCustomColor())
    menu:GetItem("Preview"):SetParam("marker_highlight_color", self:CurrentCustomColor())
    menu:GetItem("Preview"):SetParam("marker_alpha", 1)
    menu:GetItem("Preview"):Panel():child("bg"):set_alpha(1)
    menu:GetItem("Preview"):Panel():child("bg"):set_color(self:CurrentCustomColor())
end
function HoloMenu:ApplyColor(menu)
    local name = menu:GetItem("Name").value
    if name:len() <= 0 then
        QuickMenu:new(managers.localization:text("Holo/Error"), managers.localization:text("Holo/ColorNameError"), {{text = managers.localization:text("Holo/Ok"), is_cancel_button = true}}, true)
        return
    end
    local color = self:CurrentCustomColor()
    local i = self._current or #Holo.Options._storage.CustomColors + 1
    Holo.Options._storage.CustomColors[i] = {_meta = "option", type="option", name = i, value = {
        name = name,
        color = color,
    }}
    Holo.Options:Save()
    self:CreateColor(menu, i, name, color)
end
function HoloMenu:SwitchMenu(menu)
    menu = self._menu:GetItem(menu, true)
    if not menu then
        Holo:log("[ERROR] Failed switching to menu %s", menu)
        return
    end
    self._current_menu = self._current_menu or self._menu:GetItem("Main", true)
    self._current_menu:SetVisible(false)
    self._current_menu = menu
    menu:SetVisible(true)
end
function HoloMenu:Button(menu, name, text, clbk, loc, offset, index)
    return menu:Button({
        name = name,
        text = text or self:Loc(name),
        index = index,
        localized = loc,
        offset = offset,
        callback = clbk or callback(self, self, "MainClbk"),
    })
end
function HoloMenu:Toggle(menu, name, text, clbk, loc, index)
    return menu:Toggle({
        name = name,
        text = text or self:Loc(name),
        index = index,
        localized = loc,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end
function HoloMenu:Slider(menu, name, text, min, max, clbk, floats, loc, index)
    return menu:Slider({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        min = min,
        max = max,
        index = index,
        floats = floats,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end
function HoloMenu:TextBox(menu, name, text, clbk, loc, index)
    return menu:TextBox({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        index = index,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end
function HoloMenu:NumberBox(menu, name, text, clbk, floats, loc, index)
    return menu:NumberBox({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        index = index,
        floats = floats,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end
function HoloMenu:ComboBox(menu, name, text, items, clbk, color, loc, loc_items, index)
    return menu:ComboBox({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        localized_items = loc_items,
        color = color and Holo:GetColor(name), --MenuUI Acting weird with this.. :cc
        value = Holo.Options:GetValue(name),
        items = items,
        index = index,
        callback = clbk or callback(self, self, "MainClbk"),
    })
end
function HoloMenu:Divider(menu, name, text)
    return menu:Divider({
        name = name,
        text = text or self:Loc(name),
        text_color = Holo:GetColor("Colors/Marker"),
        color = Holo:GetColor("Colors/Marker"),
        localized = not text and true,
        items_size = 22,
        index = index,
    })
end
function HoloMenu:Menu(name)
    local tab = self._tabs:Button({
        name = name .. "Tab",
        text = self:Loc(name),
        localized = true,
        callback = callback(self, self, "SwitchMenu", name)
    })
    tab:Panel():child("bg"):set_h(2)
    tab:Panel():child("bg"):set_rotation(360)
    tab:Panel():child("bg"):set_y(tab:Panel():h() + 2)

    local new = self._menu:NewMenu({
        name = name,
        w = "full",
        override_size_limit = true,
        items_size = 18,
        visible = not self._current_menu,
        w = self._menu._panel:w() - 30,
        h = self._menu._panel:h() - 60,
        position = {self._tabs:Panel():left(), self._tabs:Panel():bottom()},
    })
    self._current_menu = self._current_menu or new
    return new
end
function HoloMenu:MousePressed(button, x, y)
    self._line_hold = button == Idstring("0") and self._menu._fullscreen_ws_pnl:child("resize_panel"):inside(x,y)
end
function HoloMenu:MouseReleased()
    self._line_hold = nil
end
function HoloMenu:MouseMoved(x, y)
    if self._line_hold and self._menu._old_x then
        self._menu._panel:grow(x - self._menu._old_x)
        self._menu._fullscreen_ws_pnl:child("resize_panel"):set_left(self._menu._panel:right())
    end
end
function HoloMenu:ResetOptions(all, menu)   
    self:WorkValues(all, menu, function(item)
        local option = Holo.Options:GetOption(item.name)
        if option then
            Holo.Options:SetValue(item.name, option.default_value)
            item:SetValue(Holo.Options:GetValue(item.name))
        end        
    end)
end
function HoloMenu:WorkValues(all, menu, func)
    local ResetOptions = function(list)
        for _, item in pairs(list) do
            func(item)
        end 
        Holo.Options:Save()
        self:MainClbk()           
    end
    if all then
        for _, optmenu in pairs(self._menus) do
            ResetOptions(optmenu._items)
        end
    else
        ResetOptions(menu._items)
    end
end
function HoloMenu:MainClbk(menu, item)
    if item then
        Holo.Options:SetValue(item.name, item.value)        
        Holo.Options:Save()   
        if item.items and item.color then
            item:SetColor(Holo:GetColor(item.name))
        end           
    end
    Holo:UpdateSettings()        
    self._menu:SetParam("toggle_key", Holo.Options:GetValue("OptionsKey"))
end
function HoloMenu:BeforeText(beforetext, text, add)
    return managers.localization:text(self:Loc(beforetext), {option = managers.localization:text(self:Loc(text)) .. (add and managers.localization:text(self:Loc(add)) or "")})
end
function HoloMenu:TitleColor(setting, group, add)
    local is_text = group and group:match("Text")
    return self:BeforeText(is_text and "TextColor" or "Color", setting, add)  
end
 