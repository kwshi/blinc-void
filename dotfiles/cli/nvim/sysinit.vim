call plug#begin("/usr/local/share/nvim/site/vim-plug")

Plug 'gruvbox-community/gruvbox'
Plug 'junegunn/fzf.vim'

call plug#end()

silent! colorscheme gruvbox

"lua require('myinit')
