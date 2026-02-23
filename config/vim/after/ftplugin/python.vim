execute "compiler python"

if executable('black') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=black\ --quiet\ -
  setlocal formatexpr=
endif

setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

" black style indent
let g:pyindent_open_paren = 'shiftwidth()'
let g:pyindent_nested_paren = 'shiftwidth()'
let g:pyindent_continue = 'shiftwidth()'
let g:pyindent_close_paren = '-shiftwidth()'
