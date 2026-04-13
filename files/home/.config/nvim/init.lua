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

local function apply_transparent_background()
  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end

  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#babbf1", bg = "NONE", bold = true })
end

local transparent_augroup = vim.api.nvim_create_augroup("margine_transparent_nvim", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = transparent_augroup,
  pattern = "*",
  callback = apply_transparent_background,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = transparent_augroup,
  callback = apply_transparent_background,
})

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
