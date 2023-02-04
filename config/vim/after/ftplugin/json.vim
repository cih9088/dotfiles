if executable('prettier')
  setlocal formatprg=prettier\ --parser\ json
  setlocal formatexpr=
endif
