" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

if exists('g:loaded_indent_guides') || &cp || !has('gui_running')
  finish
endif

let g:loaded_indent_guides = 1

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
  \ g:indent_guides_indent_levels : 30

let g:indent_guides_auto_colors =
  \ exists('g:indent_guides_auto_colors') ?
  \ g:indent_guides_auto_colors : 1

let g:indent_guides_color_change_percent =
  \ exists('g:indent_guides_color_change_percent') ?
  \ g:indent_guides_color_change_percent : 0.05

let g:indent_guides_debug =
  \ exists('g:indent_guides_debug') ?
  \ g:indent_guides_debug : 0

let g:indent_guides_autocmds_enabled = 0

"
" Regex pattern for a hex color.
"
" Example matches:
" - '#123ABC'
" - '#ffffff'
" - '#000000'
"
let g:indent_guides_hex_color_pattern = '#[0-9A-Fa-f]\{6\}'

" Default mapping
nmap <Leader>ig :IndentGuidesToggle<CR>

" Auto commands
augroup indent_guides
  autocmd!
  autocmd BufEnter,WinEnter * call indent_guides#process_autocmds()
augroup END

