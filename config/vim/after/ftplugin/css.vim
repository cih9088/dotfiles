if executable('prettier') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=prettier\ --parser\ css
  setlocal formatexpr=
endif
