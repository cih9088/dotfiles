" Vim Compiler File
" Compiler:    shellcheck
" References:  https://github.com/Konfekt/vim-compilers/blob/master/compiler/shellcheck.vim
" Last Change: 2026-02-23

if exists("current_compiler")
  finish
endif
let current_compiler = "shellcheck"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=shellcheck\ -f\ gcc
CompilerSet errorformat=%f:%l:%c:\ %trror:\ %m\ [SC%n],
		       \%f:%l:%c:\ %tarning:\ %m\ [SC%n],
		       \%f:%l:%c:\ %tote:\ %m\ [SC%n],
		       \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
