call plug#begin("/usr/local/share/nvim/site/vim-plug")

Plug 'gruvbox-community/gruvbox'
Plug 'junegunn/fzf'
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

let mapleader = ' '
nnoremap <space> <nop>
nnoremap <silent> <leader>F :Files<cr>

"au BufWritePre *.py Black

silent! colorscheme gruvbox

let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0


lua require 'init'

"lua require('myinit')
