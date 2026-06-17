return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = {
          normal   = { c = { fg = "#c8c8c8", bg = "none" } },
          inactive = { c = { fg = "#666666", bg = "none" } },
          insert   = { c = { fg = "#c8c8c8", bg = "none" } },
          visual   = { c = { fg = "#c8c8c8", bg = "none" } },
          replace  = { c = { fg = "#c8c8c8", bg = "none" } },
          command  = { c = { fg = "#c8c8c8", bg = "none" } },
        },
        section_separators = "",
        component_separators = "",
      },
    })
  end,
}
