return {
  "2giosangmitom/nightfall.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("nightfall").setup({
      transparent = true,
    })
    vim.cmd("colorscheme nightfall")
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#9463ff" })
  end
}
