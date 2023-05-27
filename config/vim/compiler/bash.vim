" Vim Compiler File
" Compiler:    python
" References:
"              https://github.com/Konfekt/vim-compilers/blob/master/compiler/bash.vim
" Last Change: 2023-05-27

if exists("current_compiler") | finish | endif
let current_compiler = "bash"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=bash\ -n\ --\ %:S
CompilerSet errorformat=%f:\ line\ %l:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
