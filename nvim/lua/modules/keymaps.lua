-- keymaps.lua

-- toggle explorer
vim.keymap.set("n", "<C-e>", function()
  require("snacks").explorer({
    cwd = "~/",
    reveal = true,
    hidden = true,
    auto_close = false
  })
end)

-- ctrl+d to dashboard
vim.keymap.set("n", "<C-d>", function()
  if vim.bo.filetype == "snacks_dashboard" then return end
  pcall(function()
    require("snacks").explorer.close()
  end)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  Snacks.dashboard()
end)
