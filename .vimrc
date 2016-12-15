" easy editing of vimrc file
nmap <silent> <leader>ev :tabe $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

set number
set nowrap
set showmatch

" remaps
imap hh <Esc>
nnoremap ; :

" search
set ignorecase
set smartcase
set incsearch
