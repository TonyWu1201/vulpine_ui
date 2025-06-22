---@class vulpine_ui_v0
local lib = {}

local lib_path_prefix = "vulpine_ui_v0.lib"

---@type vulpine_ui_v0.container
lib.container = require(lib_path_prefix .. ".container")

---@type vulpine_ui_v0.controller
lib.controller = require(lib_path_prefix .. ".controller")

---@type vulpine_ui_v0.element
lib.element = require(lib_path_prefix .. ".element")

---@type vulpine_ui_v0.item
lib.item = require(lib_path_prefix .. ".item")

---@type vulpine_ui_v0.menu
lib.menu = require(lib_path_prefix .. ".menu")

---@type vulpine_ui_v0.responder
lib.responder = require(lib_path_prefix .. ".responder")

---@type vulpine_ui_v0.utility
lib.utility = require(lib_path_prefix .. ".utility")

lib.version = {
    major = 0,
    minor = 0,
    patch = 0,
    discription = "dev ver"
}

return lib