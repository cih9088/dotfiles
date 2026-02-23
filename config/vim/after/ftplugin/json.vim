if executable('prettier') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=prettier\ --parser\ json
  setlocal formatexpr=
endif
