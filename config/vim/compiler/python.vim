" Vim Compiler File
" Compiler:    python
" References:  https://github.com/Konfekt/vim-compilers/blob/master/compiler/python.vim

if exists("current_compiler") | finish | endif
let current_compiler = "python"

let s:cpo_save = &cpo
set cpo&vim

if executable('python3')
  setlocal makeprg=python3
else
  setlocal makeprg=python
endif
silent CompilerSet makeprg
silent CompilerSet errorformat=%A\ \ File\ \"%f\"\\\,\ line\ %l\\\,%m,
      \%C\ \ \ \ %.%#,
      \%+Z%.%#Error\:\ %.%#,
      \%A\ \ File\ \"%f\"\\\,\ line\ %l,
      \%+C\ \ %.%#,
      \%-C%p^,
      \%Z%m,
      \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
