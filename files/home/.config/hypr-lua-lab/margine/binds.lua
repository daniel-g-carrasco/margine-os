local M = {}

local function opts_with_description(description, opts)
    local result = {}

    if opts then
        for key, value in pairs(opts) do
            result[key] = value
        end
    end

    result.description = description
    return result
end

local function bindd(keys, description, dispatcher, opts)
    hl.bind(keys, dispatcher, opts_with_description(description, opts))
end

local function bind_exec(keys, description, command, opts)
    bindd(keys, description, hl.dsp.exec_cmd(command), opts)
end

function M.apply(cfg)
    local main = cfg.main_mod

    bind_exec(main .. " + SPACE", "Open Walker launcher", cfg.menu_walker)
    bind_exec(main .. " + SHIFT + SPACE", "Open Fuzzel fallback launcher", cfg.menu_fallback)
    bind_exec(main .. " + R", "Open primary launcher", cfg.menu)

    bind_exec(main .. " + RETURN", "Open terminal", cfg.terminal)
    bind_exec(main .. " + SHIFT + RETURN", "Open browser", cfg.browser)
    bind_exec(main .. " + SHIFT + P", "Restart waybar", cfg.home .. "/.config/waybar/launch.sh")
    bind_exec(main .. " + SHIFT + F", "Open file manager", cfg.file_manager)

    bind_exec(main .. " + CTRL + T", "Open btop in terminal", cfg.terminal .. " -e btop")
    bind_exec(main .. " + K", "Show Hyprland binds", cfg.terminal .. [[ -e sh -lc 'hyprctl binds | less -R']])
    bind_exec(main .. " + N", "Toggle notifications center", [[command -v swaync-client >/dev/null 2>&1 && swaync-client -t -sw]])

    bindd(main .. " + TAB", "Go to next workspace", hl.dsp.focus({ workspace = "e+1" }))
    bindd(main .. " + SHIFT + TAB", "Go to previous workspace", hl.dsp.focus({ workspace = "e-1" }))
    bindd(main .. " + CTRL + TAB", "Return to previous workspace", hl.dsp.focus({ workspace = "previous" }))

    for workspace = 1, 10 do
        local key = tostring(workspace % 10)

        bindd(main .. " + " .. key, "Go to workspace " .. workspace, hl.dsp.focus({ workspace = workspace }))
        bindd(main .. " + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = workspace }))
    end

    bindd(main .. " + S", "Toggle scratchpad workspace", hl.dsp.workspace.toggle_special("magic"))
    bindd(main .. " + ALT + S", "Send window to scratchpad workspace", hl.dsp.window.move({ workspace = "special:magic" }))

    bindd(main .. " + W", "Close active window", hl.dsp.window.close())
    bindd(main .. " + T", "Toggle floating mode", hl.dsp.window.float({ action = "toggle" }))
    bindd(main .. " + O", "Pin active window", hl.dsp.window.pin())
    bindd(main .. " + F", "Toggle fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
    bindd(main .. " + P", "Toggle pseudotile", hl.dsp.window.pseudo())
    bindd(main .. " + J", "Toggle split orientation", hl.dsp.layout("togglesplit"))

    bindd(main .. " + left", "Focus window left", hl.dsp.focus({ direction = "l" }))
    bindd(main .. " + right", "Focus window right", hl.dsp.focus({ direction = "r" }))
    bindd(main .. " + up", "Focus window up", hl.dsp.focus({ direction = "u" }))
    bindd(main .. " + down", "Focus window down", hl.dsp.focus({ direction = "d" }))

    bindd(main .. " + SHIFT + left", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
    bindd(main .. " + SHIFT + right", "Swap window right", hl.dsp.window.swap({ direction = "r" }))
    bindd(main .. " + SHIFT + up", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
    bindd(main .. " + SHIFT + down", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

    bindd(main .. " + equal", "Grow window width", hl.dsp.window.resize({ x = 40, y = 0, relative = true }))
    bindd(main .. " + minus", "Shrink window width", hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
    bindd(main .. " + SHIFT + equal", "Grow window height", hl.dsp.window.resize({ x = 0, y = 40, relative = true }))
    bindd(main .. " + SHIFT + minus", "Shrink window height", hl.dsp.window.resize({ x = 0, y = -40, relative = true }))

    bindd(main .. " + G", "Toggle group on active window", hl.dsp.group.toggle())
    bindd(main .. " + ALT + G", "Move window out of group", hl.dsp.window.move({ out_of_group = true }))
    bindd(main .. " + ALT + TAB", "Focus next window in group", hl.dsp.group.next())
    bindd(main .. " + ALT + SHIFT + TAB", "Focus previous window in group", hl.dsp.group.prev())
    bindd(main .. " + ALT + left", "Move window into group left", hl.dsp.window.move({ into_group = "l" }))
    bindd(main .. " + ALT + right", "Move window into group right", hl.dsp.window.move({ into_group = "r" }))
    bindd(main .. " + ALT + up", "Move window into group up", hl.dsp.window.move({ into_group = "u" }))
    bindd(main .. " + ALT + down", "Move window into group down", hl.dsp.window.move({ into_group = "d" }))

    hl.bind(main .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(main .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(main .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(main .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    bind_exec("Print", "Screenshot menu", cfg.home .. "/.local/bin/screenshot-menu")
    bind_exec("SHIFT + Print", "Screenshot region", cfg.home .. "/.local/bin/screenshot-menu region")
    bind_exec("CTRL + Print", "Screenshot active window", cfg.home .. "/.local/bin/screenshot-menu window:active")
    bind_exec(main .. " + Print", "Open recording menu", cfg.home .. "/.local/bin/screenrecord-menu")
    bind_exec(main .. " + SHIFT + Print", "Start region recording directly", cfg.home .. "/.local/bin/screenrecord-region-toggle --start")

    local repeat_locked = { locked = true, repeating = true }
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(cfg.home .. "/.local/bin/volume-osd up"), repeat_locked)
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(cfg.home .. "/.local/bin/volume-osd down"), repeat_locked)
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd(cfg.home .. "/.local/bin/volume-osd mute"), repeat_locked)
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(cfg.home .. "/.local/bin/volume-osd mic-mute"), repeat_locked)
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(cfg.home .. "/.local/bin/brightness-osd up"), repeat_locked)
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(cfg.home .. "/.local/bin/brightness-osd down"), repeat_locked)

    local locked = { locked = true }
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)

    bind_exec(main .. " + ESCAPE", "Open session actions menu", cfg.home .. "/.local/bin/open-session-actions-menu")
    bind_exec(main .. " + CTRL + L", "Lock screen", [[if [ -x "$HOME/.local/bin/margine-hyprlock" ]; then "$HOME/.local/bin/margine-hyprlock"; else loginctl lock-session; fi]])
end

return M.apply
