execute "compiler cargo"

if executable('rustfmt') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=rustfmt
  setlocal formatexpr=
endif
