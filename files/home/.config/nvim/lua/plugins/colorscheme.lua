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
          FloatFooter = transparent,
          SignColumn = transparent,
          LineNr = transparent,
          CursorLineNr = { fg = colors.lavender, bg = "NONE", bold = true },
          EndOfBuffer = transparent,
          FoldColumn = transparent,
          StatusLine = transparent,
          StatusLineNC = transparent,
          TabLineFill = transparent,
          WinSeparator = transparent,
          VertSplit = transparent,
          Pmenu = transparent,
          PmenuSbar = transparent,
          PmenuThumb = transparent,
          NormalSB = transparent,
          NeoTreeNormal = transparent,
          NeoTreeNormalNC = transparent,
          NeoTreeWinSeparator = transparent,
          SnacksNormal = transparent,
          SnacksPicker = transparent,
          LazyNormal = transparent,
          MasonNormal = transparent,
          TelescopeNormal = transparent,
          TelescopeBorder = transparent,
          TelescopePromptNormal = transparent,
          TelescopePromptBorder = transparent,
          TelescopeResultsNormal = transparent,
          TelescopeResultsBorder = transparent,
          TelescopePreviewNormal = transparent,
          TelescopePreviewBorder = transparent,
          WhichKeyNormal = transparent,
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
