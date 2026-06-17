return {
  "2giosangmitom/nightfall.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nightfall").setup({
      transparent = true,
    })
    vim.cmd("colorscheme nightfall")
  end
}
