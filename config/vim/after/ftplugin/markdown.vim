if executable('prettier')
  setlocal formatprg=prettier\ --parser\ markdown
  setlocal formatexpr=
endif
