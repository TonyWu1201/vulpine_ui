---@class vulpine_ui_v0.container
local container = {}

local lib_path_prefix = "vulpine_ui_v0.lib"
local utility = require(lib_path_prefix .. ".utility")

---@class vulpine_ui_v0.container.base_container
local base_container = plus.Class()
container.base_container = base_container

function base_container:init()
    self.menus = {}
    self.ordered_menus = {}
    self.temp_data = {}
    self.layer_update = false
end

---@return vulpine_ui_v0.container.base_container
function base_container.create()
    return base_container()
end

---@class vulpine_ui_v0.container.menuinfo
---@field [1] string menu_name
---@field [2] table menu_class

---创建菜单
---@param menuinfos vulpine_ui_v0.container.menuinfo[]
function base_container:create_menus(menuinfos)
    self.menus = {}
    self.ordered_menus = {}
    for _, v in ipairs(menuinfos) do
        self.menus[v[1]] = v[2](self)
    end
    for _, o in pairs(self.menus) do
        if o.after_init then o:after_init(self) end
    end
    self.layer_update = true
end

---@param name string menu_name
---@return table | false
function base_container:get_menu(name)
    if self.menus[name] then
        return self.menus[name]
    else
        return false
    end
end

---@param menu table
---@param layer number
function base_container:set_layer(menu, layer)
    menu.layer = layer
    self.layer_update = true
end

---@param current table
---@param next table
---@param params_current table
---@param params_next table
function base_container:switch_menu(current, next, params_current, params_next)
    if type(current.exit) == "function" then
        current:exit(unpack(params_current or {}))
    end
    if type(next.enter) == "function" then
        next:enter(unpack(params_next or {}))
    end
end

function base_container:frame()
    self.input_data = utility.input.get_input()
    for _, o in pairs(self.menus) do
        if o.frame then o:frame(self.input_data) end
    end
    if self.layer_update then
        self.layer_update = false
        local tmp = {}
        for _, o in pairs(self.menus) do
            if not o.layer then
                o.layer = 0
            end
            table.insert(tmp, o)
        end
        table.sort(tmp, function (a, b)
            return a.layer < b.layer
        end)
        self.ordered_menus = tmp
    end
end

function base_container:render()
    SetViewMode("ui")
    for _, o in ipairs(self.ordered_menus) do
        if o.render then o:render() end
    end
    SetViewMode("world")
end

---@class vulpine_ui_v0.container.stack_container : vulpine_ui_v0.container.base_container
local stack_container = plus.Class(base_container)
container.stack_container = stack_container

function stack_container:init()
    base_container.init(self)
    self.stack = {}
end

---@return vulpine_ui_v0.container.stack_container
function stack_container.create()
    return stack_container()
end

---@param menu table
---@param callback_func function
function stack_container:push_stack(menu, callback_func)
    local info = {menu = menu, callback_func = callback_func}
    table.insert(self.stack, info)
end

---@return table | false
function stack_container:pop_stack()
    if #self.stack > 0 then
        return table.remove(self.stack, #self.stack)
    else
        return false
    end
end

function stack_container:lastmenu_flyback()
    local lastmenu_info = self:pop_stack()
    if lastmenu_info then
        lastmenu_info.callback_func(lastmenu_info.menu)
    end
end

return container