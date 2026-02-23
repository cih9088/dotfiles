if executable('prettier') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=prettier\ --parser\ yaml
  setlocal formatexpr=
endif
