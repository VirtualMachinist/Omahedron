-- Nearest LazyVim colorscheme for the Hedron Light sky field
-- (pale background, deep lapis text). Bronze accent stays on the shell,
-- borders, and keyboard. There is no Hedron-native colorscheme.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "latte",
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-latte",
    },
  },
}
