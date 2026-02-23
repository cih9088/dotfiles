if executable('prettier') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=prettier\ --parser\ html
  setlocal formatexpr=
endif
