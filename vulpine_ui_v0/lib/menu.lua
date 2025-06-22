---@class vulpine_ui_v0.menu
local menu = {}

local Vector2 = require("lstg.Vector2")

local base_menu = plus.Class()
menu.base_menu = base_menu

---@alias vulpine_ui_v0.menu.update_state
---| "active" 活动状态 正常处理输入信息
---| "disable" 非活动状态 所有选项处于未激活状态
---| "fixed" 非活动状态 被选中的选项处于激活状态


---@param container vulpine_ui_v0.container.base_container
function base_menu:init(container)
    self.position = Vector2.create(0, 0)
    self.lerp_show = 0
    self.lerp_view_active = 0
    ---@type vulpine_ui_v0.menu.update_state
    self.update_state = "disable"
    self.layer = 0

    self.container = container
    self.responders = {} --处理外部输入信息
    self.item_pos = 0 --列表选中光标
    self.items = {} --处理列表逻辑
    self.elements = {} --呈现的元素

    self.timer = 0

    self.enable_cursor = false --是否启用鼠标输入
end

function base_menu:frame(input_data)
    self.timer = self.timer + 1
    if self.controller then
        if self.controller.process_input then
            self.controller:process_input(self.update_state, input_data, self.enable_cursor)
        end
        if self.controller.update_list_items then 
            self.controller:update_list_items(self.update_state)
        end
        if self.controller.update_element then
            self.controller:update_element()
        end
    end
end

function base_menu:render()
    if self.controller then
        if self.controller.render_elements then
            self.controller:render_elements()
        end
    end
end

return menu