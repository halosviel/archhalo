--# transparent bg on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local hl = vim.api.nvim_set_hl

    hl(0, "Normal", { bg = "none" })
    hl(0, "NormalNC", { bg = "none" })
    hl(0, "NormalFloat", { bg = "none" })
  end
})

--# stops auto comment on new line if prev line was a comment
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.schedule(function()
      vim.opt_local.formatoptions:remove({"r", "o"})
    end)
  end
})
