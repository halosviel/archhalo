return {
  "vyfor/cord.nvim",
  build = "./build",
  event = "VimEnter",
  config = function()
    require("cord").setup({
      usercmds = true,
      reconnect = {
        enabled = true,
        interval = 5000,
      },
    })
  end,
}
