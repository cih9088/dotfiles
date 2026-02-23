if executable('shfmt') && &formatprg == "" && &formatexpr == ""
  setlocal formatprg=shfmt\ -ci\ -i\ 2\ -s\ -bn
  setlocal formatexpr=
endif

