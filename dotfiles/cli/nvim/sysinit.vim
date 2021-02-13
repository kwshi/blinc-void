call plug#begin("/usr/local/share/nvim/site/vim-plug")

Plug 'gruvbox-community/gruvbox'
Plug 'junegunn/fzf.vim'

call plug#end()

set number termguicolors expandtab autochdir
set shiftwidth=2 
set tabstop=2
set signcolumn=number 
set wildmode=list:longest

nnoremap <silent> <leader><leader> :lua vim.lsp.buf.hover()<CR>

silent! colorscheme gruvbox

"lua require('myinit')
