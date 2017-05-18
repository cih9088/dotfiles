" ==================  vim-plug  ================
" automatic installation (for Neovim: ~/.local/share/nvim/site/autoload/plug.vim)
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -flo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd vimenter * pluginstall --sync | source $myvimrc
endif

" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')
" Make sure you use single quotes

" let Vundle manage Vundle, required
Plug 'flazz/vim-colorschemes'
Plug 'jacoborus/tender.vim'
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"Plug 'scrooloose/syntastic'
Plug 'w0rp/ale'

Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular'
Plug 'easymotion/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdcommenter'
Plug 'Yggdroot/indentLine'
Plug 'raimondi/delimitmate'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'terryma/vim-smooth-scroll'
Plug 'christoomey/vim-tmux-navigator'
Plug 'majutsushi/tagbar'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'Sirver/ultisnips'
Plug 'honza/vim-snippets'
Plug 'kien/ctrlp.vim'
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'ervandew/supertab'
Plug 'Valloric/YouCompleteMe'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'terryma/vim-expand-region' 
"Plug 'metakirby5/codi.vim'

" Initialize plugin system
call plug#end()


" ==================  vim setting ================
filetype plugin indent on   " Enable filetype plugins
set autoread                " Set to auto read when a file is changed from the outside
syntax on

set nocompatible            " do not compatible to original vi
set wrap
set nowrapscan              " do not go back to the first of the line when it reaches at the end of the line
set nobackup                " do not create backup file
set noswapfile              " do not create swap file
set visualbell              " visualbell on
set fencs=ucs-bom,utf-8,euc-kr.latin1   " hangle goes euc-kr, unicode goes unicode
set fileencoding=utf-8      " file saving encoding
set tenc=utf-8              " terminal encoding
set backspace=eol,start,indent          " go to earlier line where the cursor is positioned at end of the line, start of the line and indent 
set hidden                  " unsaved changes in buffer is hidden not quit
set history=1000            " remember more commands and search history
set undolevels=1000         " use many muchos levels of undo
set laststatus=2            " status bar is always on
"set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\
set linebreak
set colorcolumn=90          " color column to limit coding length
set pastetoggle=<F2>        " when in insert mode, press <F2> to go to
                            " pasete mode, where you can paste mass data
                            " that won't be autoindent

" Turns off vim's crazy default regex characters
nnoremap / /\v
vnoremap / /\v
"set listchars=tab:▸\ ,eol:¬
"set list

" Colors
"set t_Co=256 " for ubuntu
syntax enable       " enable syntax processing
set background=dark " lihgt / dark
if has('termguicolors')
   set termguicolors
   let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
   let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
colorscheme tender
"colorscheme base16-default-dark
"colorscheme base16-eighties
"colorscheme PaperColor
"let g:PaperColor_Theme_Options = {
  "\   'language': {
  "\     'python': {
  "\       'highlight_builtins' : 1
  "\     },
  "\     'cpp': {
  "\       'highlight_standard_library': 1
  "\     },
  "\     'c': {
  "\       'highlight_builtins' : 1
  "\     }
  "\   }
  "\ }

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Spaces & Tabs
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set shiftwidth=4    " auto indent 4
set cindent         " indent only for C language
set smartindent     " smart indentation
set copyindent      " copy the previous indentation on autoindenting 
set autoindent      " always set autoindenting on

" UI Config
set ruler           " show line and col
set relativenumber  " show relative line numbers
set number          " show absolute line numbers where your cursor is
set numberwidth=2   " keep the line number gutter narrow"
set showcmd         " show command in bottom bar
set cursorline      " highlight current line
filetype indent on  " load filetype-specific index files
set wildmenu        " visual autocomplete for command menu
set showmatch       " highlight matching [{()}]
set title           " change the terminal's title
set lazyredraw      " redraw only when we need to

" Searching
set incsearch       " show search matches as you type
set hlsearch        " highlight mtches
set ignorecase      " ignore case when searching
set smartcase       " ignore case if search pattern is all lowercase,
                    " case-sensitive otherwise

" Folding
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
set foldmethod=indent   " fold based on indent level
nnoremap <space> za

" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" turn off search highlight
nmap <leader><space> :nohlsearch<CR>
" buffer next
nmap <leader>] :bnext<CR>
" buffer previous
nmap <leader>[ :bprevious<CR>
" buffer quit
nmap <leader>bq :bp <BAR> bd #<CR>
" new buffer
nmap <leader>bn :enew<CR>

" Vim Split navigations
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-L> <C-W><C-L>
nmap <C-H> <C-W><C-H>
set splitbelow
set splitright

" Vim Split command remapping like tmux
nmap <C-W>h <C-W>s
nmap <C-W>x <C-W>q


" ==================  Plugin Setting  ================

" NERDTree------------------------------------
    nmap <leader>n :NERDTreeToggle<CR>
    let NERDTreeQuitOnOpen = 1

" Airline-------------------------------------
    let g:airline#extensions#tabline#enabled = 1
    let g:airline_powerline_fonts = 1
    call airline#parts#define_function('ALE', 'ALEGetStatusLine')
    call airline#parts#define_condition('ALE', 'exists("*ALEGetStatusLine")')
    let g:airline_section_error = airline#section#create_right(['ALE'])

" CtrlP---------------------------------------
    nmap <leader>p :CtrlP<CR>
    let g:ctrlp_working_path_mode = 'ra'
    set wildignore+=*/tmp/*,*.so,*.swp,*.zip    " Linux/MacOSX

" Syntastic-----------------------------------
    "set statusline+=%#warningmsg#
    "set statusline+=%{SyntasticStatuslineFlag()}
    "set statusline+=%*
    "let g:syntastic_always_populate_loc_list = 1
    "let g:syntastic_auto_loc_list = 1
    "let g:syntastic_check_on_open = 1
    "let g:syntastic_check_on_wq = 0

"Asynchronous Lint Engine---------------------
    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
    let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
    let g:ale_linters = {
                \ 'python': ['flake8']
                \}

" youcompleteme-------------------------------
    let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
    let g:ycm_confirm_extra_conf = 0
    "to avoid conflict snippets
    let g:ycm_key_list_select_completion = ['<tab>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<s-tab>', '<Up>']
    let g:ycm_autoclose_preview_window_after_completion = 1
    nnoremap <leader>g :YcmCompleter GoTo<CR>
    "nnoremap <leader>gg :YcmCompleter GoToImprecise<CR>
    nnoremap <leader>d :YcmCompleter GoToDeclaration<CR>
    nnoremap <leader>t :YcmCompleter GetType<CR>
    nnoremap <leader>p :YcmCompleter GetParent<CR>

" supertab------------------------------------
    let g:SuperTabDefaultCompletionType = '<tab>'

" ultisnips-----------------------------------
    let g:UltiSnipsExpandTrigger='<tab>'
    let g:UltiSnipsJumpforwardTrigger='<C-n>'
    let g:UltiSnipsJumpBackwardTrigger='<C-p>'

" Tabular-------------------------------------
    nmap <Leader>a= :Tabularize /=<CR>
    vmap <Leader>a= :Tabularize /=<CR>
    nmap <Leader>a: :Tabularize /:\zs<CR>
    vmap <Leader>a: :Tabularize /:\zs<CR>

" Easy motion---------------------------------
    let g:EasyMotion_do_mapping = 0 " Disable default mappings
    " Jump to anywhere you want with minimal keystrokes, with just one key binding
    " `s{char}{char}{label}`
    nmap s <Plug>(easymotion-overwin-f2)
    " Turn on case insensitive feature
    let g:EasyMotion_smartcase = 1
    " JK motions: Line motions
    map <Leader>j <Plug>(easymotion-j)
    map <Leader>k <Plug>(easymotion-k)

" Indentlines----------------------------------
    let g:indentLine_eenabled = 1

" Limelight------------------------------------
    " Color name (:help cterm-colors) or ANSI code
    let g:limelight_conceal_ctermfg = 'gray'
    let g:limelight_conceal_ctermfg = 240
    " Color name (:help gui-colors) or RGB color
    let g:limelight_conceal_guifg = 'DarkGray'
    let g:limelight_conceal_guifg = '#777777'
    " Default: 0.5
    let g:limelight_default_coefficient = 0.7
    " Number of preceding/following paragraphs to include (default: 0)
    let g:limelight_paragraph_span = 1
    " Beginning/end of paragraph
    "   When there's no empty line between the paragraphs
    "   and each paragraph starts with indentation
    let g:limelight_bop = '^\s'
    let g:limelight_eop = '\ze\n^\s'
    " Highlighting priority (default: 10)
    "   Set it to -1 not to overrule hlsearch
    let g:limelight_priority = -1

" vim-smooth-scroll----------------------------
    noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 30, 2)<CR>
    noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 30, 2)<CR>
    noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 30, 4)<CR>
    noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 30, 4)<CR>

" Tagbar---------------------------------------
    nmap <Leader>b :TagbarToggle<CR>
