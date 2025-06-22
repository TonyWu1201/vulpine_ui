local input = {}

local mouse = require("lstg.Input.Mouse")

local function getMousePositionToUI()
    local mx, my = lstg.GetMousePosition() -- 左下角为原点，y 轴向上
    -- 转换到 UI 视口
    mx = mx - screen.dx
    my = my - screen.dy
    mx = mx / screen.scale
    my = my / screen.scale
    return mx, my
end

---@class vulpine_ui_v0.utility.inputdata
local _ = {
    ["up"] = true,
    ["down"] = true,
    ["left"] = true,
    ["right"] = true,
    ["confirm"] = true,
    ["cancel"] = true,
    ["shift"] = true,
    ["escape"] = true,
    ["cursor_x"] = 0,
    ["cursor_y"] = 0,
    ["cursor_wheel_delta"] = 0 -- +向上转 -向下转
}

local capture_keys = {
    {"up", "up"},
    {"down", "down"},
    {"left", "left"},
    {"right", "right"},
    {"shoot", "confirm"},
    {"spell", "cancel"},
    {"special", "special"},
    {"slow", "shift"},
    {"menu", "escape"},
}

local last_cursor_x, last_cursor_y

function input.get_input()
    local inputstate = {}
    for _, info in ipairs(capture_keys) do
        inputstate[info[2]] = KeyIsDown(info[1])
    end
    local cursor_x, cursor_y = getMousePositionToUI()
    cursor_x = int(cursor_x)
    cursor_y = int(cursor_y)
    inputstate["cursor_active"] = false
    inputstate["cursor_x"] = cursor_x
    inputstate["cursor_y"] = cursor_y
    inputstate["cursor_wheel_delta"] = mouse.GetWheelDelta()
    if (last_cursor_x ~= cursor_x or last_cursor_y ~= cursor_y or inputstate["cursor_wheel_delta"] ~= 0) then
        inputstate["cursor_active"] = true
        last_cursor_x = cursor_x
        last_cursor_y = cursor_y
    end
    local list = {
        "Primary",
        "Left",
        "Middle",
        "Secondary",
        "Right",
        "X1",
        "XButton1",
        "X2",
        "XButton2"
    }
    for _, i in ipairs(list) do
        if mouse.GetKeyState(mouse[i]) then
            inputstate["cursor_active"] = true
            break
        end
    end
    return inputstate
end

return input