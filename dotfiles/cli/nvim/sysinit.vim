call plug#begin("/usr/local/share/nvim/site/vim-plug")

Plug 'gruvbox-community/gruvbox'
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'

call plug#end()

set number termguicolors expandtab autochdir
set shiftwidth=2 
set tabstop=2
set signcolumn=number 
set wildmode=list:longest

nnoremap <silent> <leader><leader> :lua vim.lsp.buf.hover()<CR>

silent! colorscheme gruvbox

lua << EOF

local on_attach = function(client, buf)
  local set_key = function(k, v) 
    vim.api.nvim_buf_set_keymap(buf, 'n', k, v, {
      noremap = true,
      silent = true,
    })
  end
  set_key('K', '<Cmd>lua vim.lsp.buf.hover()<CR>') 
  vim.api.nvim_exec('au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)', false)
end

require 'lspconfig'.tsserver.setup {
  on_attach = on_attach
}

EOF

"lua require('myinit')
