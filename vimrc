set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-surround'
Plugin 'Valloric/YouCompleteMe'
Plugin 'godlygeek/tabular'
Plugin 'ervandew/supertab'
Plugin 'terryma/vim-multiple-cursors'
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line:

syntax on
filetype plugin indent on

set nocompatible " 오리지날 VI와 호환하지 않음
set wrap
set nowrapscan " 검색할 때 문서의 끝에서 처음으로 안돌아감
set nobackup " 백업 파일을 안만듬
set visualbell " 키를 잘못눌렀을 때 화면 프레시
set fencs=ucs-bom,utf-8,euc-kr.latin1 " 한글 파일은 euc-kr로, 유니코드는 유니코드로
set fileencoding=utf-8 " 파일저장인코딩
set tenc=utf-8      " 터미널 인코딩
set backspace=eol,start,indent "  줄의 끝, 시작, 들여쓰기에서 백스페이스시 이전줄로
set history=1000    " remember more commands and search history
set undolevels=1000 " use many muchos levels of undo
set laststatus=2    " 상태바 표시를 항상한다
"set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\
set lbr


" Colors
set t_Co=256 " for ubuntu
let g:solarized_termcolors=256
syntax enable       " enable syntax processing
set background=dark " lihgt / dark
colorscheme jellybeans

" Spaces & Tabs
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set shiftwidth=4    " 자동 들여쓰기 4칸
set cindent         " C 프로그래밍용 자동 들여쓰기
set smartindent     " smart indentation
set copyindent      " copy the previous indentation on autoindenting 
set autoindent      " always set autoindenting on

" UI Config
set ruler           " 화면 우측 하단에 현재 커서의 위치(줄,칸) 표시
set number          " show line numbers
set showcmd         " show command in bottom bar
set cursorline      " highlight current line
filetype indent on  " load filetype-specific index files
set wildmenu        " visual autocomplete for command menu
set showmatch       " highlight matching [{()}]
set title           " change the terminal's title
"set lazyredraw      " redraw only when we need to

" Searching
set incsearch       " show search matches as you type
set hlsearch        " highlight mtches
set ignorecase      " ignore case when searching
set smartcase       " ignore case if search pattern is all lowercase,
                    " case-sensitive otherwise
" turn off search highlight

" Folding
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
set foldmethod=indent   " fold based on indent level
nnoremap <space> za

" Movement
" highlight last inserted text
"nnoremap gV `[v`]

" Airline Setting
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" CtrlP Setting
let g:ctrlp_working_path_mode = 0
set wildignore+=*/tmp/*,*.so,*.swp,*.zip    " Linux/MacOSX

" Syntastic setting
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Indent Guide setting
let g:indent_guides_start_level = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 0

" YouCompleteMe setting
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
"To avoid conflict snippets
let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
let g:ycm_autoclose_preview_window_after_completion = 1

" Mapping
" turn off search highlight
nmap <leader><space> :nohlsearch<CR>
" toggle Gundo
nmap <leader>u :GundoToggle<CR>
" toggle NerdTree
nmap <leader>n :NERDTreeToggle<CR>      
" toggle CtrlP
nmap <leader>c :CtrlP<CR>
" buffer next
nmap <leader>] :bnext<CR>
" buffer previous
nmap <leader>[ :bprevious<CR>
" buffer quit
nmap <leader>bq :bp <BAR> bd #<CR>
" new buffer
nmap <leader>bn :enew<CR>

" Tabular
"if exists(':Tabularize')
    nmap <Leader>a= :Tabularize /=<CR>
    vmap <Leader>a= :Tabularize /=<CR>
    nmap <Leader>a: :Tabularize /:\zs<CR>
    vmap <Leader>i: :Tabularize /:\zs<CR>
"endif

" Split navigations
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>
nmap <C-L> <C-W><C-L>
nmap <C-H> <C-W><C-H>
set splitbelow
set splitright

"nnoremap <leader>g :YcmCompleter GoTo<CR>
"nnoremap <leader>gg :YcmCompleter GoToImprecise<CR>
"nnoremap <leader>d :YcmCompleter GoToDeclaration<CR>
"nnoremap <leader>t :YcmCompleter GetType<CR>
"nnoremap <leader>p :YcmCompleter GetParent<CR>


"" dispaly indent guide lines
"set list listchars=tab:❘-,trail:·,extends:»,precedes:«,nbsp:×
"" convert spaces to tabs when reading file
"autocmd! bufreadpost * set noexpandtab | retab! 4
"" convert tabs to spaces before writing file
"autocmd! bufwritepre * set expandtab | retab! 4
"" convert spaces to tabs after writing file (to show guides again)
"autocmd! bufwritepost * set noexpandtab | retab! 4
