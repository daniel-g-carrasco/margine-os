local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "FloatFooter",
  "SignColumn",
  "LineNr",
  "EndOfBuffer",
  "FoldColumn",
  "StatusLine",
  "StatusLineNC",
  "TabLineFill",
  "WinSeparator",
  "VertSplit",
  "Pmenu",
  "PmenuSbar",
  "PmenuThumb",
  "NormalSB",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeWinSeparator",
  "SnacksNormal",
  "SnacksPicker",
  "LazyNormal",
  "MasonNormal",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "TelescopeResultsNormal",
  "TelescopeResultsBorder",
  "TelescopePreviewNormal",
  "TelescopePreviewBorder",
  "WhichKeyNormal",
}

local function apply_transparency()
  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end

  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#babbf1", bg = "NONE", bold = true })
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.schedule(apply_transparency)
        end,
      })
    end,
    opts = {
      flavour = "frappe",
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
      custom_highlights = function(colors)
        return {
          CursorLineNr = { fg = colors.lavender, bg = "NONE", bold = true },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
