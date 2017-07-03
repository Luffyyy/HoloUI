Holo.Menu = Holo.Menu or {}
local self = Holo.Menu
function self:Init()
    local accent_color = Holo:GetColor("TextColors/MenuHighlighted")
    local background_color = Holo:GetColor("Colors/MenuBackground")
    self._menu = MenuUI:new({
        accent_color = accent_color,
        text_highlight_color = accent_color,
        marker_highlight_color = false,
        always_mouse_press = callback(self, self, "MousePressed"),
        always_mouse_move = callback(self, self, "MouseMoved"),
        mouse_release = callback(self, self, "MouseReleased"),
        offset = {8, 6},
        toggle_key = Holo.Options:GetValue("OptionsKey"),
        toggle_clbk = function(enabled)
            if managers.hud then
                managers.hud._chatinput_changed_callback_handler:dispatch(enabled)
            end
        end,
    })
    self._tabs = self._menu:Menu({
        name = "tabs",
        background_alpha = 0.65,
        border_color = self._menu.text_highlight_color,
        background_color = background_color,
        h = 30,
        w = "half",
        items_size = 20,
        text_align = "center",
        position = {10, 0},
        size_by_text = true,
        align_method = "grid"
    })
    self._menus = {
        main = self:Menu("Main"),
        colors = self:Menu("Colors"),
        textcolors = self:Menu("TextColors"),
        extra = self:Menu("Extra"),
    }
    if Holo.Options:GetValue("TextColors/AutomaticTextColors") then
        self:Divider(self._menus.textcolors, "AutomaticTextColorsOptionIsOn")
    end
    local close = self._tabs:Button({
        name = "Close",
        text = "Holo/Close",
        ignore_align = true,
        position = function(item)
            item:Panel():set_rightbottom(item:Panel():parent():rightbottom())
        end,
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

    self._resize = self._menu._panel:panel({
        name = "resize_panel",
        w = 4,
        layer = self._menu._panel:layer() + 1,
        x = self._menus.main.panel:right(),
    })    
    self._resize:rect({color = Holo:GetColor("Colors/Marker")})
    self._color_dialog = ColorDialog:new({marker_highlight_color = accent_color, background_color = background_color, no_blur = true})
    self:SwitchMenu("Main")
end

function self:CreateGroupOptions(group, parent_name)
    local auto_text_colors = Holo.Options:GetValue("TextColors/AutomaticTextColors")
    for _, setting in ipairs(group) do  
        local group_name = group.name or "Main"
        local menu = self._menu:GetMenu(group_name)
        if type(setting) == "table" and setting._meta ~= "option_set" then
            if setting._meta == "option_group" then
                if parent_name == "Main" then
                    self:Group(menu, setting.name, setting.beforetext and self:BeforeText(setting.beforetext, setting.name), setting.text, setting.closed)
                end
                self:CreateGroupOptions(setting, group_name)
            else
                if parent_name and parent_name ~= "Main" then 
                    group_name = parent_name .. "/" .. group_name
                end
                local name = (group_name ~= "Main" and group_name .. "/" or "") .. setting.name
                local _menu = group.menu or setting.menu
                if _menu then
                    menu = self._menu:GetMenu(_menu)
                end         
                local txt = self:Loc(setting.name)
                if not menu:GetItem(name) then
                    local items = Holo[setting.items] or Holo.AllColorsStrings
                    local loc_items = items ~= Holo.AllColorsStrings and items ~= Holo.ColorsStrings
                    local type = setting.type
                    if group.name and group.name:match("Colors") and setting._meta == "option" and setting.type == "number" then
                        local outside = menu.name ~= group.name
                        local color = self:ComboBox(menu, name, outside and self:TitleColor(setting.name, group.name, setting.beforetext) or txt, items, nil, true, not outside, loc_items, setting.index, setting.help)
                        if group.name == "TextColors" and auto_text_colors and not setting.has_no_bg then
                            color:SetEnabled(false)
                        end
                    elseif type == "number" then       
                        if setting.menu_type == "combo" then
                            self:ComboBox(menu, name, txt, items, nil, not loc_items, true, loc_items, setting.index, setting.help)
                        elseif setting.min and setting.max then
                            self:Slider(menu, name, txt, setting.min, setting.max, nil, setting.floats, true, setting.index, setting.help)
                        else
                            self:NumberBox(menu, name, txt, nil, setting.floats, true, setting.index, setting.help)
                        end
                    elseif type == "color" then
                        self:Button(menu, name, txt, callback(self, self, "OpenSetColorDialog"), true, nil, setting.index, nil, setting.help)
                    elseif type == "boolean" then
                        self:Toggle(menu, name, self:BeforeText(setting.beforetext or "Enable", setting.text or setting.name), nil, false, setting.index, setting.help)
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

function self:SwitchMenu(name)
    local menu = self._menu:GetItem(name, true)
    if not menu then
        Holo:log("[ERROR] Failed switching to menu %s", name)
        return
    end
    self._current_menu = self._current_menu or self._menu:GetMenu("Main")
    self._current_menu:SetVisible(false)
    local tab = self._menu:GetItem(self._current_menu.name.."Tab")
    tab.text_color = self._menu.text_color
    tab:SetBorder({bottom = false})
    tab = self._menu:GetItem(name.."Tab")
    tab.text_color = self._menu.text_highlight_color
    tab:SetBorder({bottom = true})
    self._current_menu = menu
    menu:SetVisible(true)
end

function self:MouseMoved(x, y)
    if self._line_hold and self._menu._old_x then
        for _, menu in pairs(self._menu._menus) do
            menu:Panel():grow(x - self._menu._old_x)
        end
        self._resize:set_left(self._menus.main.panel:right())
    end
end

function self:ResetOptions(all, menu)   
    self:WorkValues(all, menu, function(item)
        local option = Holo.Options:GetOption(item.name)
        if option then
            Holo.Options:SetValue(item.name, option.default_value)
            item:SetValue(Holo.Options:GetValue(item.name))
        end        
    end)
end

function self:WorkValues(all, menu, func)
    local ResetOptions
    ResetOptions = function(list)
        for _, item in pairs(list) do
            if item.menu_type then
                ResetOptions(item._my_items)
            else
                func(item)
            end
        end 
        Holo.Options:Save()
        self:MainClbk()           
    end
    if all then
        for _, optmenu in pairs(self._menus) do
            ResetOptions(optmenu._my_items)
        end
    else
        ResetOptions(menu._my_items)
    end
end

function self:Set(name, value)
    Holo.Options:SetValue(name, value)        
    Holo.Options:Save()
end

function self:MainClbk(menu, item)
    if item then
        self:Set(item.name, item:Value())
        if item.items and item.color then
            item:SetColor(Holo:GetColor(item.name))
        end           
    end
    Holo:UpdateSettings()
    self._menu:SetParam("toggle_key", Holo.Options:GetValue("OptionsKey"))
end

function self:OpenSetColorDialog(menu, item)
	local option = item.name
    self._color_dialog:Show({
        color = Holo.Options:GetValue(option), 
        callback = function(color)
            self:Set(option, color)
            Holo:UpdateSettings()
        end, 
        create_items = function(menu)
            local m = menu:Menu({
                name = "premadcolors",
                align_method = "grid",
                size_by_text = true
            })
            local premade_color = function(name, color)
                m:Button({name = "color_"..name, text = name, marker_color = color})
            end
            premade_color("Blue", Color(0.2, 0.6 ,1))
            premade_color("Orange", Color(1, 0.6, 0))
            premade_color("Green", Color(0, 1, 0.1))
            premade_color("Pink", Color(1, 0.25, 0.7))
            premade_color("Black", Color(0, 0, 0))
            premade_color("Grey", Color(0.15, 0.15, 0.15))
            premade_color("DarkBlue", Color(0.1, 0.1, 0.35))
            premade_color("Red", Color(1, 0.1, 0))
            premade_color("Yellow", Color(1, 0.8, 0.2))
            premade_color("White", Color(1, 1, 1))
            premade_color("Cyan", Color(0, 1, 0.9))
            premade_color("Purple", Color(0.5, 0, 1))
            premade_color("SpringGreen", Color(0, 0.9, 0.5))
            premade_color("Light Blue", Color(0.6, 0.8, 0.85))
            premade_color("Crimson", Color(1, 0, 0.2))
            premade_color("Brown", Color(0.6, 0.3, 0.3))
            premade_color("Lime", Color(0.7, 0.9, 0))
        end
    })
end

function self:TitleColor(setting, group, add)
    local is_text = group and group:match("Text")
    return self:BeforeText(is_text and "TextColor" or "Color", setting, add)  
end

--Item creation functions
function self:Button(menu, name, text, clbk, loc, offset, index, opt, help)
    opt = opt or {}
    return menu:Button(table.merge({
        name = name,
        text = text or self:Loc(name),
        index = index,
        localized = loc,
        offset = offset,
        help = help and self:Loc(help),
        help_localized = true,
        inherit_from = self._menus.main,
        callback = clbk or callback(self, self, "MainClbk"),
    }, opt))
end

function self:Toggle(menu, name, text, clbk, loc, index, help)
    return menu:Toggle({
        name = name,
        text = text or self:Loc(name),
        index = index,
        localized = loc,
        help = help and self:Loc(help),
        help_localized = true,
        inherit_from = self._menus.main,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end

function self:Slider(menu, name, text, min, max, clbk, floats, loc, index, help)
    return menu:Slider({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        min = min,
        max = max,
        index = index,
        floats = floats,
        help = help and self:Loc(help),
        help_localized = true,
        inherit_from = self._menus.main,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end

function self:TextBox(menu, name, text, clbk, loc, index, help)
    return menu:TextBox({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        index = index,
        help = help and self:Loc(help),
        help_localized = true,
        inherit_from = self._menus.main,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end

function self:NumberBox(menu, name, text, clbk, floats, loc, index, help)
    return menu:NumberBox({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        index = index,
        help = help and self:Loc(help),
        help_localized = true,
        floats = floats,
        inherit_from = self._menus.main,
        value = Holo.Options:GetValue(name),
        callback = clbk or callback(self, self, "MainClbk"),
    })
end

function self:ComboBox(menu, name, text, items, clbk, color, loc, loc_items, index, help)
    return menu:ComboBox({
        name = name,
        text = text or self:Loc(name),
        localized = loc,
        searchbox = not not color,
        localized_items = loc_items,
        inherit_from = self._menus.main,
        help = help and self:Loc(help),
        help_localized = true,
        color = color and Holo:GetColor(name),
        value = Holo.Options:GetValue(name),
        items = items,
        index = index,
        callback = clbk or callback(self, self, "MainClbk"),
    })
end

function self:Group(menu, name, text, loc_text, closed, help)
    return menu:Group({
        name = name,
        closed = closed,
        text = text or self:Loc(loc_text or name),
        text_color = Holo:GetColor("Colors/Marker"),
        help = help and self:Loc(help),
        help_localized = true,
        color = Holo:GetColor("Colors/Marker"),
        localized = not text and true,
        inherit_from = self._menus.main,
        items_size = 22,
    })
end

function self:Divider(menu, name, text)
    return menu:Divider({
        name = name,
        text = text or self:Loc(name),
        text_color = Holo:GetColor("Colors/Marker"),
        color = Holo:GetColor("Colors/Marker"),
        localized = not text and true,
        inherit_from = self._menus.main,
        items_size = 22,
    })
end

function self:Menu(name)
    local tab = self._tabs:Button({
        name = name .. "Tab",
        text = self:Loc(name),
        localized = true,
        callback = callback(self, self, "SwitchMenu", name)
    })
    local new = self._menu:Menu({
        name = name,
        w = "half",
        items_size = 18,
        background_alpha = 0.65,
        background_color = Holo:GetColor("Colors/MenuBackground"),        
        visible = not self._current_menu,
        h = self._menu._panel:h() - 35,
        position = {self._tabs:Panel():left(), self._tabs:Panel():bottom()},
    })
    self._current_menu = self._current_menu or new
    return new
end

--Short functions
function self:BeforeText(beforetext, text, add) return managers.localization:text(self:Loc(beforetext), {option = managers.localization:text(self:Loc(text)) .. (add and managers.localization:text(self:Loc(add)) or "")}) end
function self:MousePressed(button, x, y) self._line_hold = button == Idstring("0") and self._resize:inside(x,y) end
function self:MouseReleased() self._line_hold = nil end
function self:Loc(s) return "Holo/" .. s end