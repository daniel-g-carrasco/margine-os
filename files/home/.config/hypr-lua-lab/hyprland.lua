-- Margine Hyprland 0.55 Lua lab entrypoint.
--
-- Keep this file outside ~/.config/hypr/hyprland.lua until the production
-- wrapper, bootstrap validators, repair validators, and VM acceptance checks
-- intentionally select the Lua path.

require("margine.monitors")
local cfg = require("margine.variables")

require("margine.environment")
require("margine.autostart")(cfg)
require("margine.look_and_feel")
require("margine.theme_generated")
require("margine.input")
require("margine.binds")(cfg)
require("margine.rules")
