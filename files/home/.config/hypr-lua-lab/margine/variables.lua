local home = os.getenv("HOME") or "~"

return {
    home = home,
    main_mod = "SUPER",
    terminal = "kitty",
    file_manager = "nautilus",
    menu = home .. "/.local/bin/margine-launcher",
    menu_fallback = home .. "/.local/bin/margine-launcher --fallback",
    menu_walker = home .. "/.local/bin/margine-launcher-walker",
    menu_service = home .. "/.local/bin/margine-launcher-service",
    browser = "firefox",
}
