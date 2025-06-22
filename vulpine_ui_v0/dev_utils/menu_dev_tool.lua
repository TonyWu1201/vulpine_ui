local tool = {}

local lib_path = "vulpine_ui_v0.lib"
local label = "##vulpineuimenudevtool"

local update_state_to_index = {
    active = 1,
    disable = 2,
    fixed = 3
}

local update_state = {
    "active",
    "disable",
    "fixed"
}

---@type vulpine_ui_v0
local lib = require(lib_path)

local debuglib = require("lib.Ldebug")

local imgui = require("imgui")

local target_path = "vulpine_ui_v0.test.testmenu"

local target_menu_name = "test"

tool.container = plus.Class(lib.container.base_container)

function tool.container:init()
    lib.container.base_container.init(self)

    self.target_menu_class = require(target_path)
    self.refresh_lib = false

    self.background_rgb = {1, 1, 1}
    self.show_coordinate = false

    self:create_menus({
        {target_menu_name, self.target_menu_class}
    })
    self.target_menu = self:get_menu(target_menu_name)

    self.imgui_ui = {enable = true}
    self.imgui_ui.getWindowName = function () return "Vulpine UI Menu Dev Tool" end
    self.imgui_ui.getMenuItemName = function () return "Vulpine UI Menu Dev Tool" end
    self.imgui_ui.getMenuGroupName = function () return "Tool" end
    self.imgui_ui.getEnable = function (_self) return _self.enable end
    self.imgui_ui.setEnable = function (_self, v) _self.enable = v end
    self.imgui_ui.update = function (_self)
        
    end
    self.imgui_ui.layout = function (_self)
        if imgui.ImGui.CollapsingHeader("Hot Reload" .. label) then
            _, self.refresh_lib = imgui.ImGui.Checkbox("reload lib" .. label, self.refresh_lib)
            imgui.ImGui.SameLine()
            if imgui.ImGui.Button("reload" .. label) then
                self:reload()
            end
        end
        if imgui.ImGui.CollapsingHeader("Container Properties" .. label) then
            _, self.background_rgb = imgui.ImGui.ColorEdit3("background color" .. label, self.background_rgb)
            _, self.show_coordinate = imgui.ImGui.Checkbox("show coordinate" .. label, self.show_coordinate)
        end
        if imgui.ImGui.CollapsingHeader("Input Data" .. label) then
            local list = {
                "up",
                "down",
                "left",
                "right",
                "confirm",
                "cancel",
                "special",
                "shift",
                "escape",
                "cursor_x",
                "cursor_y",
                "cursor_wheel_delta",
                "cursor_active"
            }
            for _, index in ipairs(list) do
                if self.input_data then
                    imgui.ImGui.Text(index .. ": " .. tostring(self.input_data[index]))
                else
                    imgui.ImGui.Text(index .. ": " .. tostring(self.inputstate[index]))
                end
            end
        end
        if imgui.ImGui.CollapsingHeader("Menu Properties" .. label) then
            imgui.ImGui.Text("name: " .. target_menu_name)
            do
                local pos_changed, new_pos_x, new_pos_y, tmp
                pos_changed, new_pos_x = imgui.ImGui.SliderFloat("position: x" .. label, self.target_menu.position.x, -100, screen.width + 100)
                tmp, new_pos_y = imgui.ImGui.SliderFloat("position: y" .. label, self.target_menu.position.y, -100, screen.height + 100)
                pos_changed = pos_changed or tmp
                if pos_changed then
                    self.target_menu.position.x = new_pos_x
                    self.target_menu.position.y = new_pos_y
                end
            end
            do
                local lerp_show_changed, new_lerp_show = imgui.ImGui.SliderFloat("lerp_show" .. label, self.target_menu.lerp_show, 0, 1)
                if lerp_show_changed then
                    self.target_menu.lerp_show = new_lerp_show
                end
            end
            do
                local lerp_view_active_changed, new_lerp_view_active = imgui.ImGui.SliderFloat("lerp_view_active" .. label, self.target_menu.lerp_view_active, 0, 1)
                if lerp_view_active_changed then
                    self.target_menu.lerp_view_active = new_lerp_view_active
                end
            end
            do
                local update_state_changed, new_update_state_index = imgui.ImGui.Combo("update_state" .. label, update_state_to_index[self.target_menu.update_state], update_state)
                if update_state_changed then
                    self.target_menu.update_state = update_state[new_update_state_index]
                end
            end
            imgui.ImGui.Text("timer: " .. tostring(self.target_menu.timer))
        end
        if imgui.ImGui.CollapsingHeader("Menu Responders" .. label) then
            if type(self.target_menu.responders) == "table" then
                for i, t in ipairs(self.target_menu.responders) do
                    local responder_name = "#" .. tostring(i) .. " [name:" .. (t.name or "[None]") .. "]"
                    if imgui.ImGui.TreeNode(responder_name .. label) then
                        imgui.ImGui.Text("name: " .. (t.name or "[None]"))
                        imgui.ImGui.Text("group: " .. (t.group or "[None]"))
                        imgui.ImGui.Text("type: " .. t.type)
                        imgui.ImGui.Text("state: " .. t.state)
                        _, t.enable = imgui.ImGui.Checkbox("enable" .. label, t.enable)
                        if self.target_menu.update_state ~= "active" then
                            imgui.ImGui.SameLine()
                            imgui.ImGui.TextColored(imgui.ImVec4(1, 1, 0, 1), "[Notice] menu update state is not active")
                        end
                        if (t.type == "key") then
                            local capture_keys = table.concat(t.capture_keys, ", ")
                            imgui.ImGui.Text("capture keys: " .. capture_keys)
                        else

                        end
                        imgui.ImGui.Text("timer: " .. tostring(t.timer))
                        imgui.ImGui.Text("state timer: " .. tostring(t.state_timer))
                        imgui.ImGui.TreePop()
                    end
                end
            end
        end
    end

    debuglib.addView("vulpine_ui_v0.menu_dev_tool", self.imgui_ui)
end

function tool.container:reload()
    if self.refresh_lib then
        for modname, _ in pairs(package.loaded) do
            local b = string.find(modname, lib_path, 1, true)
            if b == 1 then
                package.loaded[modname] = nil
            end
        end
        lib = require(lib_path)
    end
    package.loaded[target_path] = nil
    self.target_menu_class = require(target_path)
    self:create_menus({
        {target_menu_name, self.target_menu_class}
    })
    self.target_menu = self:get_menu(target_menu_name)
end

function tool.container:frame()
    self.inputstate = lib.utility.input.get_input()
    lib.container.base_container.frame(self)
end

function tool.container:render()
    SetViewMode("ui")
    SetImageState("white", "", Color(255, 255 * self.background_rgb[1], 255 * self.background_rgb[2], 255 * self.background_rgb[3]))
    Render4V("white",
        0, 0, 0.5,
        screen.width, 0, 0.5,
        screen.width, screen.height, 0.5,
        0, screen.height, 0.5
    )
    if self.show_coordinate then
        
        local rcolor = Color(100, 255 * (1 - self.background_rgb[1]), 255 * (1 - self.background_rgb[2]), 255 * (1 - self.background_rgb[3]))
        SetImageState("white", "", rcolor)
        for x = 0, screen.width, 50 do
            Render4V("white",
                x - 1, 0, 0.5,
                x + 1, 0, 0.5,
                x + 1, screen.height, 0.5,
                x - 1, screen.height, 0.5
            )
            RenderTTF2("menuttf", tostring(x), x + 2, x + 4, 3, 10, 1, rcolor, "left", "bottom")
        end
        for y = 0, screen.height, 50 do
            Render4V("white",
                0, y - 1, 0.5,
                0, y + 1, 0.5,
                screen.width, y + 1, 0.5,
                screen.width, y - 1, 0.5
            )
            RenderTTF2("menuttf", tostring(y), 3, 10, y + 2, y + 4, 1, rcolor, "left", "bottom")
        end
    end
    SetViewMode("world")
    lib.container.base_container.render(self)
end

return tool