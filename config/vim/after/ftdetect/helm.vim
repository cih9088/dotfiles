autocmd BufRead,BufNewFile */templates/*.tpl setlocal filetype=helm
autocmd BufRead,BufNewFile */templates/*.yaml setlocal filetype=helm
autocmd BufRead,BufNewFile */templates/*.yml setlocal filetype=helm
autocmd BufRead,BufNewFile */templates/*.txt setlocal filetype=helm

autocmd BufRead,BufNewFile helmfile*.yaml setlocal filetype=helm
autocmd BufRead,BufNewFile helmfile*.yml setlocal filetype=helm
autocmd BufRead,BufNewFile helmfile*.yaml.gotmpl setlocal filetype=helm
autocmd BufRead,BufNewFile helmfile*.yml.gotmpl setlocal filetype=helm

autocmd BufRead,BufNewFile values*.yaml setlocal filetype=yaml.helm-values
autocmd BufRead,BufNewFile values*.yml setlocal filetype=yaml.helm-values
