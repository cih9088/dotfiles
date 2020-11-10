" =============================================================================
" Filename: autoload/lightline/colorscheme/miramare_modified.vim
" OriginalAuthor: chen-siyuan
" Author: Andy Cho
" License: MIT License
" Last Change: 2020/06/08 11:34:11.
" =============================================================================
let s:dark = [ '#262626', 235 ]
let s:green = [ '#87af87', 108 ]
let s:grey = [ '#444444', 238 ]
let s:lgrey = [ '#5b5b5b', '245' ]
let s:light = [ '#e6d6ac', 223 ]
let s:bg0 = [ '#2A2426', '235']
let s:fg = [ '#e3d6b6','223' ]

let s:replace = [ '#a7c080', 142 ]
let s:visual = [ '#ff87d7', 212 ]
let s:normal = [ '#ff5959', 214 ]
let s:insert = [ '#d75f5f', 167 ]

let s:errorbg = [ '#ec7279', '203' ]
let s:warningbg = [ '#deb974', '179' ]
let s:hintbg = [ '#a7c080', 142 ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.middle = [ [ s:fg, s:bg0 ] ]
let s:p.normal.left = [ [ s:dark, s:normal, 'bold' ], [ s:light, s:dark ] ]
let s:p.normal.right = [ [ s:dark, s:light ], [ s:light, s:dark ] ]

let s:p.insert.middle = [ [ s:fg, s:bg0 ] ]
let s:p.insert.left = [ [ s:dark, s:insert, 'bold' ], [ s:light, s:dark ] ]
let s:p.insert.right = [ [ s:dark, s:light ], [ s:light, s:dark ] ]

let s:p.visual.middle = [ [ s:fg, s:bg0 ] ]
let s:p.visual.left = [ [ s:dark, s:visual, 'bold' ], [ s:light, s:dark ] ]
let s:p.visual.right = [ [ s:dark, s:light ], [ s:light, s:dark ] ]

let s:p.replace.middle = [ [ s:fg, s:bg0 ] ]
let s:p.replace.left = [ [ s:dark, s:replace, 'bold' ], [ s:light, s:dark ] ]
let s:p.replace.right = [ [ s:dark, s:light ], [ s:light, s:dark ] ]

let s:p.inactive.middle = [ [ s:fg, s:bg0 ] ]
let s:p.inactive.left =  [ [ s:light, s:bg0 ], [ s:light, s:bg0 ] ]
let s:p.inactive.right = [ [ s:light, s:bg0 ], [ s:light, s:bg0 ] ]

let s:p.tabline.middle = [ [ s:fg, s:bg0 ] ]
let s:p.tabline.left = [ [ s:light, s:grey, ], [ s:light, s:dark ] ]
let s:p.tabline.right = [ [ s:light, s:dark ], [ s:dark, s:replace ] ]
let s:p.tabline.tabsel = [ [ s:dark, s:normal, 'bold' ] ]
let s:p.tabline.middle = [ [ s:fg, s:bg0] ]

let s:p.normal.error = [ [ s:dark, s:errorbg ] ]
let s:p.normal.warning = [ [ s:dark, s:warningbg ] ]
let s:p.normal.hint = [ [ s:dark, s:hintbg ] ]

let g:lightline#colorscheme#miramare_modified#palette = lightline#colorscheme#flatten(s:p)
