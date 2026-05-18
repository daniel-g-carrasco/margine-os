local M = {}

function M.apply(cfg)
    local commands = {
        cfg.home .. "/.local/bin/margine-import-session-environment",
        [[sh -lc 'sleep 1; exec "$HOME/.config/waybar/launch.sh"']],
        [[command -v swaync >/dev/null 2>&1 && ~/.config/swaync/launch.sh || mako]],
        cfg.home .. "/.local/bin/launch-hyprpaper",
        [[command -v hypridle >/dev/null 2>&1 && hypridle]],
        [[command -v swayosd-server >/dev/null 2>&1 && swayosd-server -s ~/.config/swayosd/style.css]],
        cfg.home .. "/.local/bin/margine-apply-desktop-defaults",
        [[sh -lc 'if command -v wsf >/dev/null 2>&1; then wsf apply; elif [ -x "$HOME/.local/bin/wsf" ]; then "$HOME/.local/bin/wsf" apply; fi']],
        cfg.menu_service,
        cfg.home .. "/.local/bin/hypr-workspace-layout",
        "systemctl --user start margine-framework-audio.service",
        cfg.home .. "/.local/bin/privacy-device-waybar-watch",
        cfg.home .. "/.local/bin/polkit-agent-launch",
        [[command -v koofr >/dev/null 2>&1 && koofr -silent]],
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store",
    }

    hl.on("hyprland.start", function()
        for _, command in ipairs(commands) do
            hl.exec_cmd(command)
        end
    end)
end

return M.apply
