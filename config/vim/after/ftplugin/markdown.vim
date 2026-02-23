if executable('prettier') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=prettier\ --parser\ markdown
  setlocal formatexpr=
endif
