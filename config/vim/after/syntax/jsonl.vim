" copied from https://github.com/kyoh86/vim-jsonl/blob/main/syntax/jsonl.vim
"
if !exists("_jsonl")
  " quit when a syntax file was already loaded
  if exists("b:_jsonl")
    finish
  endif
  let _jsonl = 'jsonl'
endif

runtime syntax/json.vim

syntax clear jsonMissingCommaError

syntax match jsonMissingCommaError /\("\|\]\|\d\)\zs\_s\+\ze"/
syntax match jsonMissingCommaError /\(\]\|\}\)\_s\+\ze"/ "arrays/objects as values
syntax match jsonMissingCommaError /\(true\|false\)\_s\+\ze"/ "true/false as value
