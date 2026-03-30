return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "frappe",
      transparent_background = true,
      custom_highlights = function(colors)
        local transparent = { bg = "NONE" }

        return {
          Normal = transparent,
          NormalNC = transparent,
          NormalFloat = transparent,
          FloatBorder = transparent,
          FloatTitle = transparent,
          SignColumn = transparent,
          LineNr = transparent,
          EndOfBuffer = transparent,
          FoldColumn = transparent,
          StatusLine = { bg = colors.mantle },
          StatusLineNC = { bg = colors.mantle },
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
