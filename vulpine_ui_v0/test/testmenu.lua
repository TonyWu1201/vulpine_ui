---@type vulpine_ui_v0
local lib = require("vulpine_ui_v0.lib")

local menu = plus.Class(lib.menu.base_menu)

-- menu.position.x = 100
-- menu.position.y = 100

function menu:after_init()
    self.controller = lib.controller.base_controller(self)
    table.insert(self.responders, lib.responder.key_responder.create({"up"}))
end

function menu:render()
    SetImageState("white", "", Color(255, 200, 0, 0))
    Render4V("white", 
        self.position.x, self.position.y, 0.5,
        self.position.x + 100, self.position.y, 0.5,
        self.position.x + 100, self.position.y + 100, 0.5,
        self.position.x, self.position.y + 100, 0.5)
end

return menu