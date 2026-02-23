if executable('stylua') && &formatprg == "" && &formatexpr == ""
  " setlocal formatprg=lua-format\ -i\ --indent-width=3\ --continuation-indent-width=3
  setlocal formatprg=stylua\ -s\ -
  setlocal formatexpr=
endif
