Holo.Menu = Holo.Menu or {}
local self = Holo.Menu
function self:Init()
    local accent_color = Holo:GetColor("TextColors/MenuHighlighted")
    local background_color = Holo:GetColor("Colors/Menu")
    self._menu = MenuUI:new({
        accent_color = accent_color,
        text_highlight_color = accent_color,
        marker_highlight_color = false,
        always_mouse_press = callback(self, self, "MousePressed"),
        always_mouse_move = callback(self, self, "MouseMoved"),
        mouse_release = callback(self, self, "MouseReleased"),
        offset = {8, 6},
        layer = 400,
        toggle_key = Holo.Options:GetValue("OptionsKey"),
        toggle_clbk = function(enabled)
            if managers.hud then
                managers.hud._chatinput_changed_callback_handler:dispatch(enabled)
            end
        end,
    })
    self._tabs = self._menu:Menu({
        name = "tabs",
        background_alpha = 0.5,
        border_color = self._menu.text_highlight_color,
        background_color = background_color,
        h = 30,
        w = "half",
        items_size = 20,
        text_align = "center",
        size_by_text = true,
        align_method = "grid"
    })
    self._menus = {
        main = self:Menu("Main"),
        colors = self:Menu("Colors"),
        extra = self:Menu("Extra"),
    }
    local close = self._tabs:Button({
        name = "Close",
        text = "Holo/Close",
        ignore_align = true,
        position = function(item) item:Panel():set_rightbottom(item:Panel():parent():rightbottom()) end,
        localized = true,
        callback = MenuCallbackHandler.OpenHoloMenu
    })
    close:Panel():child("bg"):configure({h = 2, rotation = 360, y = close:Panel():h() + 2})

    self._resize = self._menu._panel:panel({
        name = "resize_panel",
        w = 4,
        x = self._menus.main.panel:right(),
        layer = self._menu._panel:layer() + 1,
    })
    self._resize:rect({color = Holo:GetColor("Colors/Marker")})
    self._color_dialog = ColorDialog:new({marker_highlight_color = accent_color, background_color = background_color, no_blur = true})
    for name, menu in pairs(self._menus) do
        self["Create"..string.capitalize(name).."Menu"](self, menu)
    end
    self:SwitchMenu("Main")
end

function self:CreateItem(upper, setting, menu)
    if setting.menu then
        menu = menu:GetMenu(setting.menu)
    end
    local type = setting.type
    local name = setting.name
    local opt = {
        text = setting.beforetext and self:BeforeText(setting.beforetext, setting.text or name),
        localized = not setting.beforetext,
        items_small = setting.items_small,
        index = setting.index,
        help = setting.help,
        floats = setting.floats,
        items = setting.items,
        min = setting.min,
        max = setting.max
    }
    if upper then
        name = upper.."/"..name
    end
    if menu and (not menu:GetItem(name) or setting._meta and not menu:GetMenu(name)) then
        if type == "number" then
            if setting.menu_type == "combo" then
                self:ComboBox(menu, name, opt)
            elseif setting.min and setting.max then
                self:Slider(menu, name, opt)
            else
                self:NumberBox(menu, name, opt)
            end
        elseif type == "boolean" then
            self:Toggle(menu, name, opt)
        elseif setting._meta == "div" then
            self:DivGroup(menu, name, opt)
        elseif type == "string" then
            self:KeyBind(menu, name, opt)
        end
    end
end

function self:CreateMainMenu(menu)
    menu:ClearItems()
    self:Button(menu, "ResetAll", {callback = callback(self, self, "ResetOptions", true)})
    self:Button(menu, "Reset", {callback = callback(self, self, "ResetOptions")})
    for _, setting in ipairs(Holo.Options._config.options) do
        self:CreateItem(nil, setting, menu)
    end
end

function self:CreateExtraMenu(menu)
    menu:ClearItems()
    self:Button(menu, "Reset", {callback = callback(self, self, "ResetOptions")})
    for _, v in ipairs(Holo.Options._config.options) do
        if v.name == "Positions" or v.name == "FrameStyles" then
            local group = menu:DivGroup({name = self:Loc(v.name), localized = true})
            for _, setting in ipairs(v) do
               self:CreateItem(v.name, setting, group)
            end
        end
    end
end

function self:CreateColorsMenu(menu)
    menu:ClearItems()
    self:Button(menu, "Reset", {callback = callback(self, self, "ResetOptions")})
    self:Toggle(menu, "Colors/ColorizeTeammates", {text = "ColorizeTeammates"})
    local auto_textcolor = self:Toggle(menu, "TextColors/AutomaticTextColors", {text = "AutomaticTextColors", help = "AutomaticTextColorsHelp"})
    self:ColorTextBox(menu, "Colors/Main")    
    local other = menu:DivGroup({name = "Other", text = self:Loc("Other"), localized = true, align_method = "grid"})

    local options = {
        {name = "Casing", background = true, text = true, frame = true},
        {name = "Assault", background = true, text = true, frame = true},
        {name = "NoPointOfReturn", background = true, text = true, frame = true},
        {name = "Hostages", background = true, text = true, frame = true},
        {name = "Objective", background = true, text = true, frame = true},
        {name = "WavesSurvived", background = true, text = true, frame = true},
        {name = "Presenter", background = true, text = true, frame = true},
        {name = "Carrying", background = true, text = true, frame = true},
        {name = "Timer", background = true, text = true, frame = true},
        {name = "Menu", background = true, text = true, custom = function(option, group, w)
            self:ColorTextBox(group, "TextColors/MenuHighlighted", {w = w, text = "Highlight"})
        end},
        {name = "Tab", background = true, text = true, custom = function(option, group, w)
            self:ColorTextBox(group, "Colors/TabHighlighted", {w = w, text = "Highlight"})
        end},
        {name = "Hint", background = true, text = true},
        {name = "Teammate", background = true, text = true},
        {name = "Health", text = true, custom = function(option, group, w)
            self:ColorTextBox(group, "TextColors/HealthNeg", {w = w, text = "HealthNeg"})
        end},
        {name = "Marker", color = true},
        {name = "Pickups", color = true},
        {name = "SelectedWeapon", color = true},
        {name = "Frame", color = true},
        {name = "TeammateHost", color = true},
        {name = "Teammate2", color = true},
        {name = "Teammate3", color = true},
        {name = "Teammate4", color = true},
        {name = "TeammateAI", color = true},
        {name = "Waypoints", color = true},
        {name = "Interactable", color = true},
        {name = "InteractableSelected", color = true},
        {name = "DeployableStandard", color = true},
        {name = "DeployableSelected", color = true},
        {name = "DeployableActive", color = true},
        {name = "DeployableInteract", color = true},
        {name = "DeployableDisabled", color = true},
        {name = "Captions", text = true},
    }
    for _, option in pairs(options) do
        local i = table.size(option) - 1
        local group
        local text
        if i == 1 then
            group = other
            text = option.name
        else
            group = menu:DivGroup({name = self:Loc(option.name), localized = true, align_method = "grid", index = other:Index()})
        end
        local w = group:Width() / i
        if option.color then
            self:ColorTextBox(group, "Colors/"..option.name, {w = w, text = text or "Color"})
        end
        if option.background then
            self:ColorTextBox(group, "Colors/"..option.name, {w = w, text = text or "Background"})
        end
        if option.text then
            self:ColorTextBox(group, "TextColors/"..option.name, {w = w, text = text or "Text", enabled = not auto_textcolor:Value() and option.background})
        end
        if option.frame then
            self:ColorTextBox(group, "FrameColors/"..option.name, {w = w, text = text or "Frame"})
        end
        if option.custom then
            option.custom(option, group, w)
        end
    end
    self:ComboBox(other, "Colors/Health", {items = "RadialColors", text = "Health"})
    self:ComboBox(other, "Colors/Armor", {items = "RadialColors", text = "Armor"})
    self:ComboBox(other, "Colors/Progress", {items = "RadialColors", text = "Progress"})
    self:ComboBox(other, "Colors/ProgressRed", {items = "RadialColors", text = "ProgressRed"})
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
    tab:SetBorder({bottom = false})
    tab = self._menu:GetItem(name.."Tab")
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
        if item.name == "TextColors/AutomaticTextColors" then
            self:CreateColorsMenu(self._menus.colors)
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
            item:SetValue(color:to_hex())
            Holo:UpdateSettings()
        end, 
        create_items = function(menu)
            local m = menu:Menu({
                name = "premadcolors",
                align_method = "grid",
                auto_height = true,
                size_by_text = true
            })
            local premade_color = function(name, color)
                m:Button({name = "color_"..name, text = name, auto_text_color = true, marker_color = color, marker_highlight_color = color, callback = function()
                    self._color_dialog:set_color(color)
                end})
            end
            premade_color("Blue", Color(0.2, 0.6 ,1))
            premade_color("Orange", Color(1, 0.6, 0))
            premade_color("Green", Color(0, 1, 0.1))
            premade_color("Pink", Color(1, 0.25, 0.7))
            premade_color("Black", Color(0, 0, 0))
            premade_color("Grey", Color(0.15, 0.15, 0.15))
            premade_color("Light Grey", Color(0.8, 0.8, 0.8))
            premade_color("Dark Blue", Color(0.1, 0.1, 0.35))
            premade_color("Red", Color(1, 0.1, 0))
            premade_color("Yellow", Color(1, 0.8, 0.2))
            premade_color("White", Color(1, 1, 1))
            premade_color("Cyan", Color(0, 1, 0.9))
            premade_color("Purple", Color(0.5, 0, 1))
            premade_color("Spring Green", Color(0, 0.9, 0.5))
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
function self:BasicItem(menu, name, opt)
    opt = opt or {}
    local splt = string.split(name, "/")
    local text = opt.text or splt[#splt]
    local help = opt.help
    local items = Holo[opt.items]
    opt.text = nil
    opt.items = nil
    opt.help = nil
    return table.merge({
        name = name,
        text = opt.localized ~= false and self:Loc(text) or text,
        items = items,
        localized = true,
        localized_items = true,
        inherit = self._menus.main,
        help = help and self:Loc(help),
        help_localized = true,
        size_by_text = menu.align_method == "grid",
        value = Holo.Options:GetValue(name),
        callback = callback(self, self, "MainClbk"),        
    }, opt)
end

function self:Toggle(menu, name, opt)
    return menu:Toggle(self:BasicItem(menu, name, opt))
end

function self:Slider(menu, name, opt)
    return menu:Slider(self:BasicItem(menu, name, opt))
end

function self:NumberBox(menu, name, opt)
    return menu:NumberBox(self:BasicItem(menu, name, opt))
end

function self:ComboBox(menu, name, opt)
    return menu:ComboBox(self:BasicItem(menu, name, opt))
end

function self:KeyBind(menu, name, opt)
    return menu:KeyBind(self:BasicItem(menu, name, opt))
end

function self:Button(menu, name, opt)
    return menu:Button(self:BasicItem(menu, name, opt))
end

function self:DivGroup(menu, name, opt)
    return menu:DivGroup(self:BasicItem(menu, name, table.merge(opt, {
        align_method = opt.items_small and "grid",
        private = {
            text_color = Holo:GetColor("Colors/Marker"),
            color = Holo:GetColor("Colors/Marker"),
            last_y_offset = 0,
            items_size = 22
        },
    })))
end

function self:ColorTextBox(menu, name, opt)
    return menu:ColorTextBox(self:BasicItem(menu, name, table.merge(opt or {}, {
        value = Holo.Options:GetValue(name):to_hex(),
        show_color_dialog = callback(self, self, "OpenSetColorDialog")
    })))
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
        background_alpha = 0.5,
        background_color = Holo:GetColor("Colors/Menu"),        
        visible = not self._current_menu,
        h = self._menu._panel:h() - 35,
        position = {self._tabs:Panel():left(), self._tabs:Panel():bottom()},
    })
    self._current_menu = self._current_menu or new
    return new
end

--Short functions
function self:BeforeText(beforetext, text, add)
    local loc = managers.localization
    return loc:text(self:Loc(beforetext), {option = loc:text(self:Loc(text)) .. (add and loc:text(self:Loc(add)) or "")}) 
end
function self:MousePressed(button, x, y) self._line_hold = button == Idstring("0") and self._resize:inside(x,y) end
function self:MouseReleased() self._line_hold = nil end
function self:Loc(s) return "Holo/" .. s end