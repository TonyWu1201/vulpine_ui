---@class vulpine_ui_v0.controller
local controller = {}

local base_controller = plus.Class()
controller.base_controller = base_controller

function base_controller:init(menu, list_controller)
    self.menu = menu
    self.list_controller = list_controller
end

---将输入的信息传递给responder
---@param update_state vulpine_ui_v0.menu.update_state
---@param input_data table
function base_controller:process_input(update_state, input_data)
    for _, resp in ipairs(self.menu.responders) do
        if resp.type == "cursor" then
            
        elseif resp.type == "key" then
            local state = "inactivated"
            if update_state == "active" then
                for _, key in ipairs(resp.capture_keys) do
                    print(key)
                    if input_data[key] then
                        state = "activated"
                        break
                    end
                end
            end
            resp:update(state)
        elseif resp.type == "scalar" then

        end
    end
end

return controller