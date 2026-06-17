return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = {
          normal = { c = { bg = "none" } },
          inactive = { c = { bg = "none" } },
        },
        section_separators = "",
        component_separators = "",
      },
    })
  end,
}
