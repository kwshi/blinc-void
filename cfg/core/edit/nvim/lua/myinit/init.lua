function set_buf_opt(k, v)
  vim.api.nvim_set_option(k, v)
  vim.api.nvim_buf_set_option(0, k, v)
end

set_buf_opt('shiftwidth', 2   )
set_buf_opt('tabstop'   , 2   )
set_buf_opt('expandtab' , true)

vim.api.nvim_win_set_option(0, 'number', true)
vim.api.nvim_set_option('termguicolors', true)
vim.api.nvim_set_option('wildmode', 'longest')
vim.api.nvim_command('colorscheme gruvbox')

local lsp = require 'lspconfig'
lsp.ocamllsp.setup {}
lsp.tsserver.setup {}
