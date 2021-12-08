if executable('black')
  setlocal formatprg=black\ --quiet\ -
  setlocal formatexpr=
endif
