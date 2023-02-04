if executable('prettier')
  setlocal formatprg=prettier\ --parser\ yaml
  setlocal formatexpr=
endif
