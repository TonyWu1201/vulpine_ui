---@class vulpine_ui_v0.responder
local responder = {}

local base_responder = plus.Class()
responder.base_responder = plus.Class()

---@alias vulpine_ui_v0.responder.type
---| "key" 捕获键盘、手柄和鼠标按键
---| "cursor" 捕获光标位置
---| "scalar" 捕获一个标量

---@alias vulpine_ui_v0.responder.state
---| "inactivated" 未被激活
---| "hovered" (光标)悬浮
---| "activated" 激活

function base_responder:init()
    ---@type vulpine_ui_v0.responder.type
    self.type = "key"
    self.state = "inactivated"
    self.timer = 0 --计时器
    self.state_timer = 0 --记录状态持续时间
    self.callback = {
        normal = {}, --常态调用
        on_press = {}, --变为激活状态时调用
        activated = {}, --激活时调用
        on_release = {}, --变为非激活状态时调用
    }
    self.group = ""
    self.enable = true
end

---@param state vulpine_ui_v0.responder.state
function base_responder:update(state)
    self.timer = self.timer + 1
    self.state_timer = self.state_timer + 1
    if self.enable then
        if self.state ~= state then
            self.state_timer = 0
            local previous_state = self.state
            self.state = state
            if state == "activated" then
                for _, f in ipairs(self.callback.on_press) do
                    f(self)
                end
            elseif previous_state == "activated" then
                for _, f in ipairs(self.callback.on_release) do
                    f(self)
                end
            end
        end
        for _, f in ipairs(self.callback.normal) do
            f(self)
        end
        if self.state == "activated" then
            for _, f in ipairs(self.callback.activated) do
                f(self)
            end
        end
    else
        self.state = "inactivated"
    end
end

function base_responder:set_group(group)
    self.group = group
    return self
end

function base_responder:set_enable(enable)
    self.enable = enable
    return self
end

function base_responder:register_callback(type, func)
    if self.callback[type] then
        table.insert(self.callback[type], func)
    end
    return self
end

local key_responder = plus.Class(base_responder)
responder.key_responder = key_responder

---@param capture_keys string[] | string
function key_responder.create(capture_keys)
    if type(capture_keys) == "string" then
        capture_keys = {capture_keys}
    end
    local instance = base_responder()
    instance.capture_keys = capture_keys
    return instance
end

local cursor_responder = plus.Class(base_responder)
responder.cursor_responder = cursor_responder

function cursor_responder.create()
    local instance = base_responder()
    instance.type = "cursor"
    instance.x = 0
    instance.y = 0
    instance.bound_left = 0
    instance.bound_right = 0
    instance.bound_bottom = 0
    instance.bound_top = 0
    instance.relative = true
    return instance
end

function cursor_responder:set_relative(relative)
    self.relative = relative
end

function cursor_responder:set_box_by_bound(l, r, b, t)
    self.bound_left = l
    self.bound_right = r
    self.bound_bottom = b
    self.bound_top = t
end

function cursor_responder:set_box_by_rect(width, height, anchor)
    self.bound_left = width * (-anchor[1])
    self.bound_right = width * (1 - anchor[1])
    self.bound_top = height * (-anchor[2])
    self.bound_bottom = height * (1 - anchor[2])
end

return responder