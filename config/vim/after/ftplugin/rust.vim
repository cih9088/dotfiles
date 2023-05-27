execute "compiler cargo"

if executable('rustfmt')
  setlocal formatprg=rustfmt
  setlocal formatexpr=
endif
