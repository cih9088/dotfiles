if executable('prettier')
  setlocal formatprg=prettier\ --parser\ html
  setlocal formatexpr=
endif
