hl.config({
    input = {
        kb_layout = "it",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        resolve_binds_by_sym = true,
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            tap_to_click = true,
            clickfinger_behavior = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
