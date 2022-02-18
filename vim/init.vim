" vim:fdm=marker

" plugins {{{
call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-commentary' " commenting functionality
Plug 'iCyMind/NeoSolarized' " the solarized color scheme for neovim
if !exists('g:started_by_firenvim')
    Plug 'vim-airline/vim-airline' " a statusline plugin
    Plug 'vim-airline/vim-airline-themes' " themes for vim-airline
    Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'tpope/vim-fugitive' " general git plugin
    Plug 'nvim-lua/plenary.nvim' " general lua helpers
    Plug 'lewis6991/gitsigns.nvim' " display git status for each line
endif
Plug 'PProvost/vim-ps1' " Powershell syntax highlighting and folding
Plug 'tpope/vim-surround' " surround text in quotes, HTML tags, etc.
Plug 'dag/vim-fish' " fish syntax highlighting etc.
Plug 'tmhedberg/SimpylFold' " syntax folding for Python
Plug 'cespare/vim-toml' " TOML syntax highlighting
Plug 'rust-lang/rust.vim' " Rust plugin
Plug 'leafgarland/typescript-vim' " typescript syntax highlighting
Plug 'jelera/vim-javascript-syntax' " javascript syntax highlighting
Plug 'ElmCast/elm-vim' " Elm plugin
Plug 'editorconfig/editorconfig-vim' " .editorconfig support
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } } " usage in browsers
Plug 'tpope/vim-repeat' " repeatable plugin actions
Plug 'inkarkat/vim-ReplaceWithRegister' " easy replacement without overwriting registers
Plug 'christoomey/vim-system-copy' " easy copying/pasting to/from the system clipboard
Plug 'kana/vim-textobj-user' " framework for creating custom text objects
Plug 'kana/vim-textobj-entire' " text object of the entire buffer
Plug 'kana/vim-textobj-indent' " text object of an indented block
Plug 'kana/vim-textobj-lastpat' " text object of the last search pattern
Plug 'kana/vim-textobj-line' " text object of the current line
call plug#end()
" }}}
" leader keys {{{
let mapleader = ',' " semicolon is the leader key
let maplocalleader = '\\' " backslash is the localleader key
" }}}
" remaps {{{
" easier remappings of common commands {{{
inoremap uu <Esc>| " use "uu" to exit insert mode
inoremap hh <Esc>:w<CR>| " use "hh" to exit insert mode and save
nnoremap <space> :| " remap space to : in normal mode for ease of use
vnoremap <space> :| " remap space to : in visual mode for ease of use
nnoremap <space><space> :wq<CR>| " remap space twice to save and quit for ease of use
nnoremap <BS> :w<CR>| " remap backspace to save in normal mode
vnoremap <BS> :w<CR>| " remap backspace to save in visual mode
nnoremap <CR><CR> :q<CR>| " remap enter twice to quit
" }}}
" use H and L to go to beginning and end of lines {{{
" NOTE: nmap is used here rather than nnoremap in order for the .txt filetype
" configuration to be able to make use of these mappings. If a better way to
" deal with this is found, it will be changed.
noremap H ^| " H moves to first non-blank character of line
noremap L g_| " L moves to last non-blank character of line
" }}}
" easier scrolling/scrolling that doesn't conflict with existing mappings {{{
nnoremap <c-h> <c-e>| " scroll down
nnoremap <c-n> <c-y>| " scroll up
" }}}
" do case sensitive search with * and # {{{
noremap * /\<<C-R>=expand('<cword>')<CR>\><CR>
noremap # ?\<<C-R>=expand('<cword>')<CR>\><CR>
" }}}
" use <leader>t for <c-w> {{{

" Move between windows.
nnoremap <leader>th <c-w>h
nnoremap <leader>tj <c-w>j
nnoremap <leader>tk <c-w>k
nnoremap <leader>tl <c-w>l
nnoremap <leader>tb <c-w>b
nnoremap <leader>tt <c-w>t
nnoremap <leader>tw <c-w>w
nnoremap <leader>tW <c-w>W

" Resize windows.
nnoremap <leader>t= <c-w>=
nnoremap <leader>t_ <c-w>_
nnoremap <leader>t\| <c-w>\|
nnoremap + <c-w>>
nnoremap - <c-w><

" Move windows.
nnoremap <leader>tH <c-w>H
nnoremap <leader>tJ <c-w>J
nnoremap <leader>tK <c-w>K
nnoremap <leader>tL <c-w>L
nnoremap <leader>tr <c-w>r
nnoremap <leader>tR <c-w>R

" Open and close windows.
nnoremap <leader>ts <c-w>s
nnoremap <leader>tv <c-w>v
nnoremap <leader>to <c-w>o
nnoremap <leader>tc <c-w>c
" }}}
" use <leader>nn to clear search highlighting {{{
noremap <leader>nn :nohlsearch<CR>
" }}}
" use <leader>r to reload the buffer with :edit {{{
noremap <leader>r :edit<CR>
" }}}
" make gf open the file even if it doesn't exist {{{
noremap gf :e <cfile><cr>
" }}}
" remap ':' to ',' so that you can move backwards for f and t {{{
noremap : ,
" }}}
" <leader>h, <leader>m, and <leader>l for moving the cursor to the top, middle, and bottom of the screen {{{
noremap <leader>h H
noremap <leader>m M
noremap <leader>l L
" }}}
" swap meanings of ` and ' since one is easier to hit than the other {{{
noremap ` '
noremap ' `
" }}}
" remap <c-^> to M, which has more editor support {{{
nnoremap M <c-^>
" }}}
" easy switching between cpp and header files {{{
function! s:toggle_c() abort
    if expand('%:e') == 'h'
        edit %<.cpp
    elseif expand('%:e') == 'cpp'
        edit %<.h
    endif
endfunction
nnoremap <leader>ch :call <sid>toggle_c()<cr>
" }}}
" }}}
" autocmds {{{
" fixes the problem detailed at http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text {{{
" Without this, folds open and close at will as you type code.
augroup fixfolds
    autocmd!
    autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
    autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
augroup END
" }}}
" highlight word under cursor {{{
augroup highlight_word_under_cursor
    autocmd!
    autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))
augroup END
" }}}
" turn off spelling in the terminal {{{
augroup terminal_nospell
    autocmd!
    autocmd TermOpen * setlocal nospell
augroup END
" }}}
" }}}
" filetype configuration {{{
" .txt files {{{
augroup txt_files
    autocmd!
    autocmd FileType text setlocal wrap linebreak " set linewrapping

    " standard motion commands should move by wrapped lines
    autocmd FileType text noremap <buffer> <silent> k gk
    autocmd FileType text noremap <buffer> <silent> j gj
    autocmd FileType text noremap <buffer> <silent> 0 g0
    autocmd FileType text noremap <buffer> <silent> $ g$
    autocmd FileType text noremap <buffer> <silent> ^ g^
    autocmd FileType text noremap <buffer> <silent> H g^
    autocmd FileType text noremap <buffer> <silent> L g$| " TODO: this should be changed to gg_ or whatever the linewrapping version of g_ is
    "autocmd FileType text noremap <buffer> <silent> g_ gg_| " TODO: is there a linewrapping version of g_?
augroup END
" }}}
" go files {{{
augroup go_files
    autocmd!
    autocmd FileType go setlocal rtp+=$GOPATH/src/github.com/golang/lint/misc/vim " add golint for vim to the runtime path
    autocmd BufWritePost,FileWritePost *.go execute 'mkview!' | execute 'Lint' | execute 'silent! loadview'| " execute the Lint command on write
augroup END
" }}}
" xaml files {{{
augroup xaml_files
    autocmd!
    autocmd BufNewFile,BufRead *.xaml set ft=xml " XAML is basically just XML
augroup END
" }}}
" html files {{{
augroup html_files
    autocmd!
    autocmd FileType html setlocal tabstop=2 " tabs count as 2 spaces
    autocmd FileType html setlocal softtabstop=2 " tabs count as 2 spaces while performing editing operations (yeah, I don't really understand this either)
    autocmd FileType html setlocal shiftwidth=2 " number of spaces used for autoindent
augroup END
" }}}
" help files {{{
augroup help_files
    autocmd!
    " make concealed characters in help files visible
    autocmd FileType help setlocal conceallevel=0
    autocmd FileType help hi link HelpBar Normal
    autocmd FileType help hi link HelpStar Normal
augroup END
" }}}
" }}}
" plugin configuration {{{
" NeoSolarized {{{
set termguicolors " enables 24-bit RGB color in the TUI
set background=dark " use the dark background theme for NeoSolarized
" }}}
" vim-airline {{{
if !exists('g:started_by_firenvim')
    set laststatus=2 " show the statusline all the time, rather than only when a split is created
    let g:airline_powerline_fonts=1 " use the fonts that give you the cool arrows in the status line
    set encoding=utf8 " make sure we're using the correct encoding for the symbols
    if exists('g:fvim_loaded')
        set guifont=Ubuntu\ Mono\ derivative\ Powerline:h18
    else
        set guifont=Ubuntu_Mono_derivative_Powerlin:h14
    endif
    let g:airline_theme='dark' " set the airline theme to dark
    noremap <c-l> :AirlineRefresh<cr><c-l>| " Refresh vim-airline when Ctrl+L is pressed in addition to the display
endif
" }}}
" denite {{{
if !exists('g:started_by_firenvim')
    " use ripgrep for file content search
    call denite#custom#var('grep', 'command', ['rg'])
    call denite#custom#var('grep', 'default_opts',
        \ ['--hidden', '--vimgrep', '--smart-case'])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])

    " use scantree.py (which comes with denite) for file search
    " I think it's supposed to be faster? Also, it uses `wildignore`.
    call denite#custom#var('file/rec', 'command', ['scantree.py', '--path', ':directory'])

    " settings while in the filtered list
    autocmd FileType denite call s:denite_settings()
    function! s:denite_settings() abort
        nnoremap <silent><buffer><expr> <CR>
                \ denite#do_map('do_action', 'open')
        nnoremap <silent><buffer><expr> <C-v>
                \ denite#do_map('do_action', 'vsplit')
        nnoremap <silent><buffer><expr> p
                \ denite#do_map('do_action', 'preview')
        nnoremap <silent><buffer><expr> <Esc>
                \ denite#do_map('quit')
        nnoremap <silent><buffer><expr> q
                \ denite#do_map('quit')
        nnoremap <silent><buffer><expr> i
                \ denite#do_map('open_filter_buffer')
    endfunction

    " settings while in the filter edit
    autocmd FileType denite-filter call s:denite_filter_settings()
    function! s:denite_filter_settings() abort
        nnoremap <silent><buffer><expr> <Esc>
                \ denite#do_map('quit')
        nnoremap <silent><buffer><expr> q
                \ denite#do_map('quit')
    endfunction

    nnoremap <C-p> :<C-u>Denite file/rec -start-filter<CR>| " search for file names
    nnoremap <leader>/ :<C-u>Denite -start-filter -filter-updatetime=0 grep:::!<CR>| " search for file contents in interactive mode
    nnoremap <leader>8 :<C-u>DeniteCursorWord grep:.<CR>| " search for the word under the cursor
    nnoremap <leader>dr :<C-u>Denite -resume -refresh -cursor-pos=+1<CR>| " continue the last denite search
endif
" }}}
" vim-fugitive {{{
if !exists('g:started_by_firenvim')
    nnoremap <leader>gd :Gvdiff<CR>| " display a diff view of the current file
endif
" }}}
" rust.vim {{{
let g:rustfmt_autosave=1 " run rustfmt on save
let g:rust_recommended_style=0 " don't force textwidth=99
" }}}
" vim-system-copy {{{
if has('win32')
    " This is necessary to work on Windows, since uname isn't defined.
    let g:system_copy#copy_command = 'clip'
    let g:system_copy#paste_command ='paste'
endif
" }}}
" gitsigns {{{
if !exists('g:started_by_firenvim')
    lua << END
        require('gitsigns').setup {
            on_attach = function(bufnr)
                local function map(mode, lhs, rhs, opts)
                    local opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
                    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
                end

                -- Navigation
                map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<cr>'", {expr = true})
                map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<cr>'", {expr = true})

                -- Actions
                map('n', '<leader>gss', ':Gitsigns stage_hunk<cr>')
                map('v', '<leader>gss', ':Gitsigns stage_hunk<cr>')
                map('n', '<leader>gsr', ':Gitsigns reset_hunk<cr>')
                map('v', '<leader>gsr', ':Gitsigns reset_hunk<cr>')
                map('n', '<leader>gsS', '<cmd>Gitsigns stage_buffer<cr>')
                map('n', '<leader>gsu', '<cmd>Gitsigns undo_stage_hunk<cr>')
                map('n', '<leader>gsR', '<cmd>Gitsigns reset_buffer<cr>')
                map('n', '<leader>gsp', '<cmd>Gitsigns preview_hunk<cr>')
                map('n', '<leader>gsb', '<cmd>lua require"gitsigns".blame_line{full=true}<cr>')
                map('n', '<leader>gstb', '<cmd>Gitsigns toggle_current_line_blame<cr>')
                map('n', '<leader>gsd', '<cmd>lua require"gitsigns".diffthis("~")<cr>')
                map('n', '<leader>gstd', '<cmd>Gitsigns toggle_deleted<cr>')

                -- Text object
                map('o', 'igsh', ':<c-u>Gitsigns select_hunk<cr>')
                map('x', 'igsh', ':<c-u>Gitsigns select_hunk<cr>')
            end
        }
END
endif
" }}}
" }}}
" easy editing of vimrc file {{{
nnoremap <silent> <leader>ev :tabe $MYVIMRC<CR>| " open .vimrc in new tab
nnoremap <silent> <leader>sv :so $MYVIMRC<CR>| " resource .vimrc
" }}}
" color scheme {{{
colorscheme NeoSolarized " set the color scheme to use NeoSolarized
" }}}
" search {{{
set ignorecase " make search case insensitive
set smartcase " ignore case if only lowercase characters used in search text
set incsearch " show search results incrementally as you type
set gdefault " always do global substitutions

" search the file system using ripgrep
if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

command! -nargs=+ Grep execute 'silent grep! <args>' | copen
" }}}
" tabs {{{
set expandtab " tabs are expanded to spaces
set tabstop=4 " tabs count as 4 spaces
set softtabstop=4 " tabs count as 4 spaces while performing editing operations (yeah, I don't really understand this either)
set shiftwidth=4 " number of spaces used for autoindent
set shiftround " should round indents to multiple of shiftwidth
set autoindent " automatically indent lines
set smarttab " be smart about how you use shiftwidth vs tabstop or softtabstop I think
" }}}
" show whitespace {{{
set list " display whitespace characters
set listchars=tab:>.,trail:.,extends:#,nbsp:. " specify which whitespace characters to display ('trail' is for trailing spaces, and 'extends' is for when the line extends beyond the right end of the screen)
" }}}
" misc. settings {{{
set number " show line numbers
set relativenumber " show relative line numbers
set nowrap " don't wrap lines
set showmatch " show matching bracket when one is inserted
set wildignore+=.git " ignore the .git directory when expanding wildcards, also works with denite file/rec
set title " title of window set to titlename/currently edited file
set visualbell " use visual bell instead of beeping
set foldmethod=syntax " fold based on the language syntax (e.g. #region tags)
set colorcolumn=80,120 " highlight the 80th and 120th columns for better line-length management
set wildmode=longest,full " in command line, first <tab> press complete to longest common string, next show full match
set cursorline " highlight the current line
set cursorcolumn " highlight the current column
set nojoinspaces " don't add an extra space after a period for J and gq
set spell " always have spellchecking on
" }}}
" custom functions and commands {{{
" toggle between number and relativenumber
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc

" format json
function! FormatJson()
    %!python -m json.tool
endfunc
" }}}
" editor configuration {{{
" fvim {{{
if exists('g:fvim_loaded')
    " Toggle between normal and fullscreen
    nnoremap <A-CR> :<C-u>FVimToggleFullScreen<CR>

    " Cursor tweaks
    FVimCursorSmoothMove v:true
    FVimCursorSmoothBlink v:false

    " Background composition
    " FVimBackgroundComposition 'acrylic'   " 'none', 'blur' or 'acrylic'
    " FVimBackgroundOpacity 0.85            " value between 0 and 1, default bg opacity.
    " FVimBackgroundAltOpacity 0.85         " value between 0 and 1, non-default bg opacity.
    " FVimBackgroundImage 'C:/foobar.png'   " background image
    " FVimBackgroundImageVAlign 'center'    " vertial position, 'top', 'center' or 'bottom'
    " FVimBackgroundImageHAlign 'center'    " horizontal position, 'left', 'center' or 'right'
    " FVimBackgroundImageStretch 'fill'     " 'none', 'fill', 'uniform', 'uniformfill'
    " FVimBackgroundImageOpacity 0.85       " value between 0 and 1, bg image opacity

    " Title bar tweaks
    " FVimCustomTitleBar v:false             " themed with colorscheme

    " Debug UI overlay
    FVimDrawFPS v:false

    " Font tweaks
    FVimFontAntialias v:true
    FVimFontAutohint v:true
    FVimFontHintLevel 'full'
    FVimFontLigature v:true
    " FVimFontLineHeight '+1.0' " can be 'default', '14.0', '-1.0' etc.
    FVimFontSubpixel v:true
    " FVimFontNoBuiltInSymbols v:true " Disable built-in Nerd font symbols

    " Try to snap the fonts to the pixels, reduces blur
    " in some situations (e.g. 100% DPI).
    FVimFontAutoSnap v:true

    " Font weight tuning, possible valuaes are 100..900
    " FVimFontNormalWeight 400
    " FVimFontBoldWeight 700

    " Font debugging -- draw bounds around each glyph
    FVimFontDrawBounds v:false

    " UI options
    " FVimUIMultiGrid v:false     " per-window grid system -- work in progress
    " FVimUIPopupMenu v:false      " external popup menu
    " FVimUITabLine v:false       " external tabline -- not implemented
    " FVimUICmdLine v:false       " external cmdline -- not implemented
    " FVimUIWildMenu v:false      " external wildmenu -- not implemented
    " FVimUIMessages v:false      " external messages -- not implemented
    " FVimUITermColors v:false    " not implemented
    " FVimUIHlState v:false       " not implemented

    " Detach from a remote session without killing the server
    " If this command is executed on a standalone instance,
    " the embedded process will be terminated anyway.
    " FVimDetach
endif
" }}}
" firenvim {{{
if exists('g:started_by_firenvim')
    set laststatus=0 " disable statusline in the browser
    set nonumber " disable line numbers
    set norelativenumber " also necessary to disable line numbers
    set wrap " enable line wrapping
    set guifont=Ubuntu_Mono_derivative_Powerlin:h12

    let g:firenvim_config = {} " initialize a default config
    let g:firenvim_config['localSettings'] = {}
    let g:firenvim_config['localSettings']['.*'] = { 'takeover': 'never' } " never take over the text area automatically
endif
" }}}
" }}}
