function set_buf_opt(k, v)
  vim.api.nvim_set_option(k, v)
  vim.api.nvim_buf_set_option(0, k, v)
end

set_buf_opt('shiftwidth', 2   )
set_buf_opt('tabstop'   , 2   )
set_buf_opt('expandtab' , true)

vim.api.nvim_win_set_option(0, 'number', true)
vim.api.nvim_win_set_option(0, 'signcolumn', 'number')
vim.api.nvim_set_option('termguicolors', true)
vim.api.nvim_set_option('wildmode', 'list:longest')
vim.api.nvim_set_option('autochdir', true)
vim.api.nvim_command('colorscheme gruvbox')

vim.api.nvim_command('autocmd BufWritePre *.ml lua vim.lsp.buf.formatting_sync(nil, 1000)')
vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', {silent=true, noremap = true})

vim.api.nvim_set_var('prettier#autoformat', 1)
vim.api.nvim_set_var('prettier#autoformat_require_pragma', 0)

local lsp = require 'lspconfig'
lsp.ocamllsp.setup {}
lsp.tsserver.setup {}
lsp.pyls.setup {}
lsp.gopls.setup {}
lsp.elmls.setup {}
