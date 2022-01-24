if executable('prettier')
  setlocal formatprg=prettier\ --parser\ css
  setlocal formatexpr=
endif
