" Vim Compiler File
" Compiler:    python
" References:
"              https://github.com/Konfekt/vim-compilers/blob/master/compiler/python.vim
" Last Change: 2023-05-27

if exists("current_compiler") | finish | endif
let current_compiler = "python"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

" Disable Python warnings
if !exists('$PYTHONWARNINGS')
  let $PYTHONWARNINGS="ignore"
endif
let $PYTHONUNBUFFERED=1

let s:cpo_save = &cpo
set cpo&vim

setlocal makeprg=python
setlocal errorformat=%A\ \ File\ \"%f\"\\\,\ line\ %l\\\,%m,
      \%C\ \ \ \ %.%#,
      \%+Z%.%#Error\:\ %.%#,
      \%A\ \ File\ \"%f\"\\\,\ line\ %l,
      \%+C\ \ %.%#,
      \%-C%p^,
      \%Z%m,
      \%-G%.%#

silent CompilerSet makeprg
silent CompilerSet errorformat

let &cpo = s:cpo_save
unlet s:cpo_save
