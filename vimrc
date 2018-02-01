" ==================  vim-plug  ================
if has('nvim')
    " automatic installation (for Neovim: ~/.local/share/nvim/site/autoload/plug.vim)
    if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
        silent !curl -flo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd vimenter * pluginstall --sync | source $myvimrc
    endif
    " Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
    call plug#begin('~/.local/share/nvim/plugged')
    " Make sure you use single quotes
else
    " automatic installation (for vim: ~/.vim/autoload/plug.vim)
    if empty(glob('~/.vim/autoload/plug.vim'))
        silent !curl -flo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd vimenter * pluginstall --sync | source $myvimrc
    endif
    " Specify a directory for plugins (for vim: ~/.vim/plugged)
    call plug#begin('~/.vim/plugged')
    " Make sure you use single quotes
endif

" Prettier vim
Plug 'flazz/vim-colorschemes'
Plug 'jacoborus/tender.vim'
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'

" Language specific
Plug 'hdima/python-syntax'
Plug 'Vimjas/vim-python-pep8-indent'

" Convenient coding
Plug 'w0rp/ale'
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'zchee/deoplete-jedi'
Plug 'Sirver/ultisnips'
Plug 'honza/vim-snippets'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdcommenter'
Plug 'Yggdroot/indentLine'
Plug 'raimondi/delimitmate'
Plug 'terryma/vim-smooth-scroll'
Plug 'christoomey/vim-tmux-navigator'
"Plug 'tpope/vim-repeat'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'kshenoy/vim-signature'
" Plug 'tpope/vim-sensible'
Plug 'junegunn/vim-easy-align'

" etc.
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
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
"nnoremap / /\v
"vnoremap / /\v
set listchars=tab:▸\ ,eol:¬
" To toggle showing the non-printable characters
noremap <F12> :set list!<CR>
inoremap <F12> <Esc>:set list!<CR>a

" Colors
set t_Co=256 " for ubuntu
syntax enable       " enable syntax processing
set background=dark " lihgt / dark
if has('termguicolors')
   set termguicolors
   "let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
   "let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
" colorscheme tender
" colorscheme base16-default-dark
" colorscheme base16-eighties
" colorscheme PaperColor
" colorscheme gruvbox
colorscheme hybrid

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

" NERDtree------------------------------------
    nmap <leader>n :NERDTreeToggle<CR>
    let NERDTreeQuitOnOpen = 1
    let NERDTreeMinimalUI = 1
    let NERDTreeDirArrows = 1
    " automatically close nerdtree if it is the only left window
    " autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" NERDcommenter-------------------------------
    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1
    " Use compact syntax for prettified multi-line comments
    let g:NERDCompactSexyComs = 1
    " Align line-wise comment delimiters flush left instead of following code indentation
    let g:NERDDefaultAlign = 'left'
    " Set a language to use its alternate delimiters by default
    let g:NERDAltDelims_java = 1
    " Add your own custom formats or override the defaults
    let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
    " Allow commenting and inverting empty lines (useful when commenting a region)
    let g:NERDCommentEmptyLines = 1
    " Enable trimming of trailing whitespace when uncommenting
    let g:NERDTrimTrailingWhitespace = 1

" Airline-------------------------------------
    let g:airline_theme = 'tomorrow'
    let g:airline#extensions#tabline#enabled = 1
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#ale#enabled = 1

" ale------------------------------------------
    " let g:ale_echo_msg_error_str = 'E'
    " let g:ale_echo_msg_warning_str = 'W'
    " let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
    " let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
    " let g:ale_linters = {
    "             \ 'python': ['flake8']
    "             \}
    let g:ale_sign_error = '>>'
    let g:ale_sign_warning = '--'

" ultisnips-----------------------------------
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpforwardTrigger='<tab>'
    let g:UltiSnipsJumpBackwardTrigger='<s-tab>'
    " let g:UltiSnipsEditSplit="vertical"

" easymotion-----------------------------------
    let g:EasyMotion_do_mapping = 0 " Disable default mappings
    " Jump to anywhere you want with minimal keystrokes, with just one key binding
    " `s{char}{char}{label}`
    nmap s <Plug>(easymotion-overwin-f2)
    " Turn on case insensitive feature
    let g:EasyMotion_smartcase = 1
    " JK motions: Line motions
    map <Leader>j <Plug>(easymotion-j)
    map <Leader>k <Plug>(easymotion-k)

" multiplecusors--------------------------------
    " Disable Deoplete when selecting multiple cursors starts
    function! Multiple_cursors_before()
        if exists('*deoplete#disable')
            exe 'call deoplete#disable()'
        elseif exists(':NeoCompleteLock') == 2
            exe 'NeoCompleteLock'
        endif
    endfunction

    " Enable Deoplete when selecting multiple cursors ends
    function! Multiple_cursors_after()
        if exists('*deoplete#enable')
            exe 'call deoplete#enable()'
        elseif exists(':NeoCompleteUnlock') == 2
            exe 'NeoCompleteUnlock'
        endif
    endfunction

" easyalign-------------------------------------
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)

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
    autocmd! User GoyoEnter Limelight
    autocmd! User GoyoLeave Limelight!

" smoothscroll----------------------------------
    noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 30, 2)<CR>
    noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 30, 2)<CR>
    " noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 30, 4)<CR>
    " noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 30, 4)<CR>

" Tagbar---------------------------------------
    nmap <Leader>b :TagbarToggle<CR>
    "autocmd VimEnter * nested :TagbarOpen

" Signature-----------------------------------
    let g:SignatureMarkTextHLDynamic = 1

" deoplete------------------------------------
    let g:deoplete#enable_at_startup = 1
    " call deoplete#custom#set('ultisnips', 'matchers', ['matcher_fuzzy'])
