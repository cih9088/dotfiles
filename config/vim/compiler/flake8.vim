" Vim Compiler File
" Compiler:    python
" References:
"              https://github.com/Konfekt/vim-compilers/blob/master/compiler/flake8.vim
" Last Change: 2023-05-27

if exists("current_compiler") | finish | endif
let current_compiler = "flake8"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo&vim

let &l:errorformat =
      \ '%E%f:%l: could not compile,%-Z%p^,' .
      \ '%A%f:%l:%c: %m,' .
      \ '%A%f:%l: %m,' .
      \ '%-G%.%#'

CompilerSet makeprg=flake8\ %:S
silent CompilerSet errorformat

let &cpo = s:cpo_save
unlet s:cpo_save
