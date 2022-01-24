if executable('stylua')
  " setlocal formatprg=lua-format\ -i\ --indent-width=3\ --continuation-indent-width=3
  setlocal formatprg=stylua\ -s\ --indent-type\ Spaces\ --indent-width\ 3\ -
  setlocal formatexpr=
endif

setlocal tabstop=3
setlocal softtabstop=3
setlocal shiftwidth=3
