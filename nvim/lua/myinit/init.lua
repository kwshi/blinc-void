vim.api.nvim_set_option('shiftwidth', 2)
vim.api.nvim_buf_set_option(0, 'shiftwidth', 2)

vim.api.nvim_win_set_option(0, 'number', true)

vim.api.nvim_set_option('expandtab', true)
vim.api.nvim_buf_set_option(0, 'expandtab', true)

vim.api.nvim_set_option('termguicolors', true)
vim.api.nvim_command('colorscheme gruvbox')
