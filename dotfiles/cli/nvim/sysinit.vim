call plug#begin("/usr/local/share/nvim/site/vim-plug")

Plug 'gruvbox-community/gruvbox'
Plug 'junegunn/fzf.vim'
Plug 'neovim/nvim-lspconfig'

Plug 'prettier/vim-prettier'
Plug 'evanleck/vim-svelte'

call plug#end()

set number termguicolors expandtab autochdir
set shiftwidth=2 
set tabstop=2
set signcolumn=number 
set wildmode=list:longest

nnoremap <silent> <leader><leader> :lua vim.lsp.buf.hover()<CR>

silent! colorscheme gruvbox

let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

lua require 'init'

"lua require('myinit')
