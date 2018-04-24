Holo.Menu = Holo.Menu or {}
local self = Holo.Menu
function self:Init()
    local accent_color = Holo:GetColor("TextColors/MenuHighlighted")
    local background_color = Holo:GetColor("Colors/Menu"):with_alpha(0.65)
    self._menu = MenuUI:new({
        accent_color = accent_color,
        foreground_highlight = accent_color,
        highlight_color = false,
        always_mouse_press = callback(self, self, "MousePressed"),
        always_mouse_move = callback(self, self, "MouseMoved"),
        mouse_release = callback(self, self, "MouseReleased"),
        offset = {16, 6},
        layer = 1000,
		animate_toggle = true,
		use_default_close_key = true,
        toggle_key = Holo.Options:GetValue("OptionsKey"),
        toggle_clbk = callback(self, self, "SetEnabled"),
    })
    self._tabs = self._menu:Menu({
        name = "tabs",
        border_color = self._menu.foreground_highlight,
        background_color = background_color,
        h = 30,
        w = "half",
        items_size = 20,
        text_align = "center",
		size_by_text = true,
		scrollbar = false,
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
        position = "RightOffset-x",
        localized = true,
        callback = MenuCallbackHandler.OpenHoloMenu
    })
    close.bg:configure({h = 2, rotation = 360, y = close:Panel():h() + 2})
    close.highlight_bg:configure({h = 2, rotation = 360, y = close:Panel():h() + 2})

    self._resize = self._menu._panel:panel({
        name = "resize_panel",
        w = 4,
        x = self._menus.main.panel:right() + 1,
        layer = self._menu._panel:layer() + 1,
    })
    self._resize:rect({color = Holo:GetColor("Colors/Marker")})
    for name, menu in pairs(self._menus) do
        self["Create"..string.capitalize(name).."Menu"](self, menu)
    end
    self:SwitchMenu("Main")
end

function self:SetEnabled(enabled)
    if managers.hud then
        managers.hud._chatinput_changed_callback_handler:dispatch(enabled)
    end
end

function self:should_close()
    return self._menu:ShouldClose()
end

function self:hide()
    self:SetEnabled(false)
    return true
end

function self:CreateItem(upper, setting, menu)
    if setting.menu then
        menu = menu:GetMenu(setting.menu)
    end
    local type = setting.type
    local name = setting.name
    local opt = {
        text = setting.beforetext and self:BeforeText(setting.beforetext, setting.text or name) or setting.text,
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
    for _, setting in ipairs(Holo.Options._config.options) do
        self:CreateItem(nil, setting, menu)
    end
    local base = self._menu:GetMenu("Base")
    self:Button(base, "ResetAll", {callback = callback(self, self, "ResetOptions", true), index = 1})
    self:Button(base, "Reset", {callback = callback(self, self, "ResetOptions"), index = 1})
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
    local auto_textcolor_value = not auto_textcolor:Value()
    local quick_opt = {help = "QuickOptionHelp", localized = false, callback = callback(self, self, "OpenSetColorDialog"), color_clbk = callback(self, self, "QuickOptAccentClbk")}
    self:Button(menu, self:BeforeText("QuickOption", "Accent"), quick_opt)
    quick_opt.color_clbk = callback(self, self, "QuickOptBackgroundClbk")    
    self:Button(menu, self:BeforeText("QuickOption", "Backgrounds"), quick_opt)
    quick_opt.color_clbk = callback(self, self, "QuickOptForegroundClbk")
    quick_opt.help = "QuickOptionHelp"
    quick_opt.enabled = auto_textcolor_value
    self:Button(menu, self:BeforeText("QuickOption", "Foregrounds"), quick_opt)
    
    local other = menu:DivGroup({name = "Other", text = self:Loc("Other"), localized = true, align_method = "grid"})
    local options = {
        {name = "Menu", background = true, text = true, custom = function(option, group, w)
            self:ColorTextBox(group, "TextColors/MenuHighlighted", {w = w, text = "Highlight"})
        end},
        {name = "Marker", color = true},
        {name = "Health", color = true, custom = function(option, group, w)
            self:ColorTextBox(group, "Colors/HealthNeg", {w = w, text = "HealthNeg"})
        end},
        {name = "Armor", color = true, custom = function(option, group, w)
            self:ColorTextBox(group, "Colors/ArmorNeg", {w = w, text = "ArmorNeg"})
        end},
        {name = "Skill", color = true, custom = function(option, group, w)
            self:ColorTextBox(group, "Colors/SkillNeg", {w = w, text = "Negative"})
        end},
        {name = "Interaction", color = true, text = true, ignore_custom = true, custom = function(option, group, w)
            self:ColorTextBox(group, "Colors/InteractionRed", {w = w, text = "Invalid"})
        end},
        {name = "Teammate", background = true, text = true},        
        {name = "Casing", background = true, text = true, frame = true},
        {name = "Assault", background = true, text = true, frame = true},
        {name = "NoPointOfReturn", background = true, text = true, frame = true},
        {name = "Hostages", background = true, text = true, frame = true},
        {name = "Objective", background = true, text = true, frame = true},
        {name = "WavesSurvived", background = true, text = true, frame = true},
        {name = "Presenter", background = true, text = true, frame = true},
        {name = "Carrying", background = true, text = true, frame = true},
        {name = "Timer", background = true, text = true, frame = true},
        {name = "Chat", background = true, text = true},        
        {name = "Tab", color = true, text = true},
        {name = "Captions", text = true},
        {name = "Pickups", color = true},
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
    }
    for _, option in pairs(options) do
        local i = table.size(option) - 1 - (option.ignore_custom and 2 or 0)
        local group
        local text
        if i == 1 then
            group = other
            text = option.name
        else
            group = menu:DivGroup({name = self:Loc(option.name), localized = true, align_method = "grid", index = other:Index()})
        end
        local w = group:ItemsWidth() / i - group:Offset()[1] * 2
        if option.color then
            self:ColorTextBox(group, "Colors/"..option.name, {w = w, text = text or "Color"})
        end
        if option.background then
            self:ColorTextBox(group, "Colors/"..option.name, {w = w, text = text or "Background"})
        end
        if option.text then
            local enabled
            if not auto_textcolor_value and option.background then
                enabled = false
            end
            self:ColorTextBox(group, "TextColors/"..option.name, {w = w, text = text or "Text", enabled = enabled})
        end
        if option.frame then
            self:ColorTextBox(group, "FrameColors/"..option.name, {w = w, text = text or "Frame"})
        end
        if option.custom then
            option.custom(option, group, w)
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

function self:SetColorsByDefault(tblname, def_color, color)
    for _, option in pairs(Holo.Options._storage[tblname]) do
        if type(option) == "table" and option.default_value == def_color then
            self:Set(tblname.."/" .. option.name, color)
            local item = self._menu:GetItem(tblname.."/"..option.name)
            if item then
                item:SetValue(color:to_hex())
            else
                Holo:log("Seems like an item is missing for the color %s", tostring(option.name))
            end
        end
    end
end

function self:QuickOptAccentClbk(color)
    local def_color = Color(0.2, 0.44, 1)
    self:SetColorsByDefault("Colors", def_color, color)
    self:SetColorsByDefault("TextColors", def_color, color)
    self:SetColorsByDefault("FrameColors", def_color, color)
end

function self:QuickOptForegroundClbk(color)
    self:SetColorsByDefault("TextColors", Color.white, color)
end

function self:QuickOptBackgroundClbk(color)
    self:SetColorsByDefault("Colors", Color(0.1, 0.1, 0.1), color)
end

function self:OpenSetColorDialog(item)
    local option = item.name    
    local accent_color = Holo:GetColor("TextColors/MenuHighlighted")
    local background_color = Holo:GetColor("Colors/Menu")  
    self._color_dialog = self._color_dialog or ColorDialog:new({highlight_color = accent_color, background_color = background_color, no_blur = true})
    self._color_dialog:Show({
        color = Holo.Options:GetValue(option), 
        callback = function(color)
            if item.type_name == "ColoredTextBox" then
                self:Set(option, color)
                item:SetValue(color:to_hex())
            elseif item.color_clbk then
                item.color_clbk(color)
            end
            Holo:UpdateSettings()
        end, 
        create_items = function(menu)
            local m = menu:Menu({
                name = "premadcolors",
                align_method = "centered_grid",
                auto_height = true,
                size_by_text = true
            })
            local premade_color = function(name, color)
                m:Button({name = "color_"..name, text = name, auto_foreground = true, marker_color = color, background_color = color, highlight_color = false, callback = function()
                    self._color_dialog:set_color(color)
                end})
            end
            premade_color("Blue", Color(0.2, 0.44, 1))
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
    }, clone(opt))
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
    return menu:DivGroup(self:BasicItem(menu, name, table.merge({
        align_method = opt.items_small and "grid",
        private = {
            foreground = Holo:GetColor("Colors/Marker"),
            color = Holo:GetColor("Colors/Marker"),
            last_y_offset = 0,
            items_size = 22
        },
    }, clone(opt))))
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
        background_color = Holo:GetColor("Colors/Menu"):with_alpha(0.65),        
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