" Vim Compiler File
" Compiler:    flake8
" References:  https://github.com/Konfekt/vim-compilers/blob/master/compiler/flake8.vim
" Last Change: 2026-02-23

if exists("current_compiler") | finish | endif
let current_compiler = "flake8"

let s:cpo_save = &cpo
set cpo&vim

let &l:errorformat =
      \ '%E%f:%l: could not compile,%-Z%p^,' .
      \ '%A%f:%l:%c: %m,' .
      \ '%A%f:%l: %m,' .
      \ '%-G%.%#'

CompilerSet makeprg=flake8
silent CompilerSet errorformat

let &cpo = s:cpo_save
unlet s:cpo_save
