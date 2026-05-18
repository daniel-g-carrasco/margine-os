hl.layer_rule({
    match = {
        namespace = "^swaync-notification-window$",
    },
    no_anim = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "reaper-opaque-xwayland",
    match = {
        class = "^(REAPER|reaper)$",
        xwayland = true,
    },
    opacity = "1.0 1.0",
})

hl.window_rule({
    name = "float-modal-dialogs",
    match = {
        modal = true,
        fullscreen = false,
    },
    float = true,
    center = true,
})

hl.window_rule({
    name = "float-file-dialogs",
    match = {
        title = "^(Open|Save|Select|Choose|File Upload|Apri|Salva|Seleziona|Scegli).*$",
        fullscreen = false,
    },
    float = true,
    center = true,
    min_size = { 760, 520 },
})

hl.window_rule({
    name = "float-network-editor",
    match = {
        class = "^(nm-connection-editor|org\\.gnome\\.nm-connection-editor)$",
        fullscreen = false,
    },
    float = true,
    center = true,
    min_size = { 760, 520 },
})

hl.window_rule({
    name = "float-virtual-machine-viewers",
    match = {
        class = "^(qemu|qemu-system-.*|virt-manager|virt-viewer|remote-viewer|org\\.virt_manager\\.virt-manager)$",
        fullscreen = false,
    },
    float = true,
    center = true,
    min_size = { 960, 640 },
})

hl.window_rule({
    name = "move-hyprland-run",
    match = {
        class = "hyprland-run",
    },
    move = { "20", "monitor_h-120" },
    float = true,
})
