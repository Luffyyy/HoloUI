HoloMenu = HoloMenu or class()
function HoloMenu:init()
    MenuUI:new({
        background_alpha = 0.65,
        text_color = Holo:GetColor("TextColors/Menu"),        
        background_color = Holo:GetColor("Colors/MenuBackground"),
        text_highlight_color = Holo:GetColor("TextColors/MenuHighlighted"),
        marker_alpha = Holo.Options:GetValue("Menu/MarkerAlpha"),
        marker_highlight_color = Holo:GetColor("Colors/Marker"),
        mouse_press = callback(self, self, "MousePressed"),
        mouse_move = callback(self, self, "MouseMoved"),
        mouse_release = callback(self, self, "MouseReleased"),
        w = "half",
        align = "left",
        padding = 10,
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
        info = self:Menu("Info"),
        menu = self:Menu("Menu"),     
    }
    local textures = self:Menu("Textures")
    self._tabs:Button({
        name = "Back",
        text = "Holo/Back",
        localized = true,
        callback = MenuCallbackHandler.OpenHoloMenu
    })    
    self._current_menu = main    
    table.insert(Holo.AllColorsStrings, {
        text = "Holo/Custom",
        callback = callback(self, self, "SetCustomColor")
    })
    Holo.ColorsStrings = {}
    for k, v in pairs(Holo.AllColorsStrings) do
        if k ~= 1 then
            table.insert(Holo.ColorsStrings, v)
        end
    end
    self:CreateGroupOptions(Holo.Options._config.options)
    for texture, _ in pairs(Holo.Options._storage.AllowedTextures) do
        if texture:match("guis") then
            textures:Toggle({
                name = texture,
                text = texture,
                value = Holo.Options._storage.AllowedTextures[texture].value,
                callback = callback(self, self, "ToggleAllowedTexture"),
            })
        end
    end
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
function HoloMenu:CreateGroupOptions(group)
    for _, setting in ipairs(group) do  
        local group_name = group.name or "Main"
        local menu = self._menu:GetItem(group_name, true)
        if type(setting) == "table" and setting._meta ~= "option_set" then
            if setting._meta == "option_group" then
                self:CreateGroupOptions(setting)
            else
                local name = (group_name ~= "Main" and group_name .. "/" or "") .. setting.name
                if setting.menu then
                    menu = self._menu:GetItem(setting.menu, true)
                end         
                if not menu:GetItem(name) then
                    if group.name and group.name:match("Colors") and setting._meta == "option" and setting.type == "number" then
                        self:ComboBox(menu, name, Holo[setting.items] or Holo.AllColorsStrings, true, self:TitleColor(setting.name, group.name), false, setting.index)
                    else
                        if setting.type == "number" then       
                            if setting.menu_type == "combo" then
                                self:ComboBox(menu, name, Holo[setting.items] or Holo.AllColorsStrings, nil, "Holo/" .. setting.name, true, setting.index)
                            else
                                if setting.min and setting.max then
                                    self:Slider(menu, name, setting.min, setting.max, setting.floats, "Holo/" .. setting.name, true, setting.index)
                                else
                                    self:NumberBox(menu, name, setting.floats, "Holo/" .. setting.name, true, setting.index)
                                end
                            end
                        elseif setting.type == "boolean" then
                            self:Toggle(menu, name, self:BeforeText(setting.beforetext or "Enable", setting.name), false, setting.index)
                        elseif setting._meta == "div" then
                            self:Divider(menu, setting.text or setting.name, setting.beforetext and self:BeforeText(setting.beforetext, setting.name))
                        else
                            menu:KeyBind({
                                name = name,
                                text = "Holo/" .. setting.name,
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
function HoloMenu:Toggle(menu, name, text, loc, index)
    menu:Toggle({
        name = name,
        text = text,
        index = index,
        localized = loc,
        value = Holo.Options:GetValue(name),
        callback = callback(self, self, "MainClbk"),
    })
end
function HoloMenu:Slider(menu, name, min, max, floats, text, loc, index)
    menu:Slider({
        name = name,
        text = text,
        localized = true,
        min = min,
        max = max,
        index = index,
        floats = floats,
        value = Holo.Options:GetValue(name),
        callback = callback(self, self, "MainClbk"),
    })
end
function HoloMenu:NumberBox(menu, name, floats, text, loc, index)
    menu:NumberBox({
        name = name,
        text = text,
        localized = true,
        index = index,
        floats = floats,
        value = Holo.Options:GetValue(name),
        callback = callback(self, self, "MainClbk"),
    })
end
function HoloMenu:ComboBox(menu, name, items, color, text, loc, index)
    menu:ComboBox({
        name = name,
        text = text,
        localized = loc,
        localized_items = true,
        value = Holo.Options:GetValue(name),
        color = color and Holo:GetColor(name),
        items = items,
        index = index,
        callback = callback(self, self, "MainClbk"),
    })
end
function HoloMenu:Divider(menu, name, text)
    menu:Divider({
        name = name,
        text = text or "Holo/" .. name,
        text_color = Holo:GetColor("Colors/Marker"),
        color = Holo:GetColor("Colors/Marker"),
        localized = not text and true,
        items_size = 24,
        index = index,
    })
end
function HoloMenu:Menu(name)
    self._tabs:Button({
        name = name .. "Tab",
        text = "Holo/" .. name,
        localized = true,
        callback = callback(self, self, "SwitchMenu", name)
    })
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
    local ResetOptions = function(list)
        for _, item in pairs(list) do
            local option = Holo.Options:GetOption(item.name)
            if option then
                Holo.Options:SetValue(item.name, option.default_value)
                item:SetValue(Holo.Options:GetValue(item.name))
            end
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
function HoloMenu:ToggleAllowedTexture(menu, item)
	Holo.Options._storage.AllowedTextures[item.name].value = item.value
	Holo.Options:Save()
end
function HoloMenu:UpdateCustomColorDialog(menu, item)
    menu:GetItem("Preview").panel:child("bg"):set_alpha(1)
    menu:GetItem("Preview").panel:child("bg"):set_color(Color(menu:GetItem("red").value, menu:GetItem("green").value, menu:GetItem("blue").value))
end
function HoloMenu:SetCustomColor(menu, item)
    local value = item.value
    local col = Holo.Options._storage.CustomColors[item.name]
    local color = (col and col.value) or Color.white
    Holo.Dialog:show({
        title = "Create a Custom Color",
        items = {
            {
                type = "Slider",                
                name = "red",               
                text = "Red",
                callback = callback(self, self, "UpdateCustomColorDialog"),
                min = 0,
                max = 1,
                value = color.r,
            },
            {
                type = "Slider",                
                name = "green",               
                text = "Green",
                callback = callback(self, self, "UpdateCustomColorDialog"),
                min = 0,
                max = 1,
                value = color.g,
            },
            {
                type = "Slider",                
                name = "blue",               
                text = "Blue",
                callback = callback(self, self, "UpdateCustomColorDialog"),
                min = 0,
                max = 1,
                value = color.b,
            }
        },
        background_alpha = 0.8,
        background_color = Color(0.4, 0.4, 0.4),
        text_color = Holo:GetColor("TextColors/Menu"),
        text_highlight_color = Holo:GetColor("TextColors/MenuHighlighted"),
        marker_alpha = Holo.Options:GetValue("Menu/MarkerAlpha"),
        marker_highlight_color = Holo:GetColor("Colors/Marker"),       
        items_size = 24,
        yes = "Create",
        no = "Cancel",
        no_callback = function() 
            item:SetValue(value)
        end,
        callback = callback(self, self, "SetCustomColorYes", item.name),
        w = 600,
        h = 200,
    })        
    Holo.Dialog._menu:Divider({
        name = "Preview",
        items_size = 32,
        marker_color = color,
        index = 1,
    })
end
function HoloMenu:SetCustomColorYes(name, items)
    Holo.Options._storage.CustomColors[name] = {_meta = "option", type="colour", name = name, value = Color(items[1].value, items[2].value, items[3].value)}
    Holo.Options:Save()
    local item = self._menu:GetItem(name)
    item:SetValue(#item.items, true, true)
end
function HoloMenu:MainClbk(menu, item)
    if item then
        Holo.Options:SetValue(item.name, item.value)
        if item.color and item.SelectedItem and type(item:SelectedItem()) ~= "table" then
            Holo.Options._storage.CustomColors[item.name] = nil
        end        
    end
    self._menu:SetParam("toggle_key", Holo.Options:GetValue("OptionsKey"))
    Holo.Options:Save()    
    Holo:UpdateSettings()
end
function HoloMenu:BeforeText(beforetext, text)
    return managers.localization:text("Holo/" .. beforetext, {option = managers.localization:text("Holo/" .. text)})
end
function HoloMenu:TitleColor(setting, group)
    local is_text = group and group:match("Text")
    return self:BeforeText(is_text and "TextColor" or "Color", setting)  
end
 