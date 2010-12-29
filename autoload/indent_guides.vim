" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

"
" Toggles the indent guides on and off.
"
function! indent_guides#toggle()
  call indent_guides#init_matches()

  if empty(w:indent_guides_matches)
    call indent_guides#enable()
  else
    call indent_guides#disable()
  endif
endfunction

"
" Called from autocmds, keeps indent guides enabled or disabled when entering
" other buffers and windows.
"
function! indent_guides#process_autocmds()
  if g:indent_guides_autocmds_enabled
    call indent_guides#enable()
  else
    call indent_guides#disable()
  end
endfunction

"
" Enables the indent guides for the current buffer and any other buffer upon
" entering it.
"
function! indent_guides#enable()
  let g:indent_guides_autocmds_enabled = 1
  call indent_guides#highlight_colors()
  call indent_guides#clear_matches()

  " loop through each indent level and define a highlight pattern
  " will automagically figure out whether to use tabs or spaces
  for l:level in range(1, g:indent_guides_indent_levels)
    let l:group      = 'IndentGuides' . ((l:level % 2 == 0) ? 'Even' : 'Odd')
    let l:multiplier = (&l:expandtab == 1) ? &l:shiftwidth : 1
    let l:pattern    = '^\s\{' . (l:level * l:multiplier - l:multiplier) . '\}\zs'
    let l:pattern   .= '\s\{' . l:multiplier . '\}'
    let l:pattern   .= '\ze'

    " define the higlight pattern and add to list
    call add(w:indent_guides_matches, matchadd(l:group, l:pattern))
  endfor
endfunction

"
" Disables the indent guides for the current buffer and any other buffer upon
" entering it.
"
function! indent_guides#disable()
  let g:indent_guides_autocmds_enabled = 0
  call indent_guides#clear_matches()
endfunction

"
" Clear all highlight matches for the current window.
"
function! indent_guides#clear_matches()
  call indent_guides#init_matches()
  if !empty(w:indent_guides_matches)
    let l:index = 0
    for l:match_id in w:indent_guides_matches
      call matchdelete(l:match_id)
      call remove(w:indent_guides_matches, l:index)
      let l:index += l:index
    endfor
  endif
endfunction

"
" Automagically calculates and defines the indent highlight colors.
"
function! indent_guides#highlight_colors()
  if g:indent_guides_auto_colors
    if has('gui_running')
      call indent_guides#gui_highlight_colors()
    else
      call indent_guides#cterm_highlight_colors()
    endif
  endif
endfunction

"
" Defines the indent highlight colors for terminal vim.
"
" NOTE: This function contains no magic at the moment, it will simply use some
" light or dark preset colors depending on the `set background=` value.
"
function! indent_guides#cterm_highlight_colors()
  let l:colors = (&g:background == 'dark') ?
    \ ['darkgrey', 'black'] : ['lightgrey', 'white']

  exe 'hi IndentGuidesEven ctermbg=' . l:colors[0]
  exe 'hi IndentGuidesOdd  ctermbg=' . l:colors[1]
endfunction

"
" Automagically calculates and defines the indent highlight colors for gui
" vim.
"
function! indent_guides#gui_highlight_colors()
  let l:hi_normal       = indent_guides#capture_highlight('Normal')
  let l:hex_pattern     = 'guibg=\zs'. g:indent_guides_hex_color_pattern . '\ze'
  let l:name_pattern    = "guibg='\\?\\zs[0-9A-Za-z ]\\+\\ze'\\?"
  let l:hi_normal_guibg = ''

  " capture the backgroud color from the normal highlight
  if l:hi_normal =~ l:hex_pattern
    " hex color code is being used, eg. '#FFFFFF'
    let l:hi_normal_guibg = matchstr(l:hi_normal, l:hex_pattern)
  elseif l:hi_normal =~ l:name_pattern
    " color name is being used, eg. 'white'
    let l:color_name      = matchstr(l:hi_normal, l:name_pattern)
    let l:hi_normal_guibg = color_helper#color_name_to_hex(l:color_name)
  endif

  if l:hi_normal_guibg =~ g:indent_guides_hex_color_pattern
    " calculate the highlight background colors
    let l:hi_odd_bg  = indent_guides#lighten_or_darken_color(l:hi_normal_guibg)
    let l:hi_even_bg = indent_guides#lighten_or_darken_color(l:hi_odd_bg)

    " define the new highlights
    exe 'hi IndentGuidesOdd  guibg=' . l:hi_odd_bg
    exe 'hi IndentGuidesEven guibg=' . l:hi_even_bg
  end
endfunction

"
" Takes a color and darkens or lightens it depending on whether a dark or light
" colorscheme is being used.
"
function! indent_guides#lighten_or_darken_color(color)
  let l:percent = g:indent_guides_color_change_percent

  let l:new_color = (&g:background == 'dark') ?
    \ color_helper#hex_color_lighten(a:color, l:percent) :
    \ color_helper#hex_color_darken (a:color, l:percent)

  return l:new_color
endfunction

"
" Captures and returns the output of highlight group definitions.
"
" Example: indent_guides#capture_highlight('normal')
" Returns: 'Normal xxx guifg=#323232 guibg=#ffffff
"
function! indent_guides#capture_highlight(group_name)
  redir => l:output
  exe "silent hi " . a:group_name
  redir END

  return l:output
endfunction

"
" Init the w:indent_guides_matches variable.
"
function! indent_guides#init_matches()
  let w:indent_guides_matches =
    \ exists('w:indent_guides_matches') ? w:indent_guides_matches : []
endfunction

"
" Define default highlights.
"
function! indent_guides#define_default_highlights()
  exe 'hi IndentGuidesOdd  guibg=NONE ctermbg=NONE'
  exe 'hi IndentGuidesEven guibg=NONE ctermbg=NONE'
endfunction

