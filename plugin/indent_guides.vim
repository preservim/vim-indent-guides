" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

function! s:IndentGuidesToggle()
  call indent_guides#toggle()
endfunction

function! s:IndentGuidesEnable()
  call indent_guides#enable()
endfunction

function! s:IndentGuidesDisable()
  call indent_guides#disable()
endfunction

" Commands
command! IndentGuidesToggle  call s:IndentGuidesToggle()
command! IndentGuidesEnable  call s:IndentGuidesEnable()
command! IndentGuidesDisable call s:IndentGuidesDisable()

" Default options
let g:indent_guides_indent_levels =
  \ exists('g:indent_guides_indent_levels') ?
  \ g:indent_guides_indent_levels : 50

let g:indent_guides_auto_colors =
  \ exists('g:indent_guides_auto_colors') ?
  \ g:indent_guides_auto_colors : 1

let g:indent_guides_auto_colors_change_percent =
  \ exists('g:indent_guides_auto_colors_change_percent') ?
  \ g:indent_guides_auto_colors_change_percent : 0.20

let g:indent_guides_debug =
  \ exists('g:indent_guides_debug') ?
  \ g:indent_guides_debug : 0

" Default mapping
nmap <Leader>ig :IndentGuidesToggle<CR>

