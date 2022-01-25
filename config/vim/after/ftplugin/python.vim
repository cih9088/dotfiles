if executable('black')
  setlocal formatprg=black\ --quiet\ -
  setlocal formatexpr=
endif

let g:pyindent_open_paren = 'shiftwidth()'
let g:pyindent_nested_paren = 'shiftwidth()'
let g:pyindent_continue = 'shiftwidth()'
let g:pyindent_close_paren = '-shiftwidth()'
