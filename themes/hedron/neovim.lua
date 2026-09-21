-- Nearest LazyVim colorscheme for the Hedron lapis field.
-- Copper accent is Hedron's own (shell borders, keyboard.rgb). Kanagawa
-- does not reproduce it. There is no Hedron-native colorscheme.
return {
  { "rebelot/kanagawa.nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
