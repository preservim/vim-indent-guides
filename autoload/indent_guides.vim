" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

"
" Toggles the indent guides on and off for all buffers.
"
function! indent_guides#toggle()
  call indent_guides#init_matches()
  if empty(w:indent_guides_matches)
    call indent_guides#enable()

    " DEBUG
    "echo 'enable'
  else
    call indent_guides#disable()

    " DEBUG
    "echo 'disable'
  endif
endfunction

"
" Enables the indent guides for all buffers.
"
function! indent_guides#enable()
  call indent_guides#init_matches()
  call indent_guides#disable()

  if g:indent_guides_auto_colors
    call indent_guides#highlight_colors()
  endif

  " loop through each indent level and define a highlight pattern
  " will automagically figure out whether to use tabs or spaces
  for level in range(1, g:indent_guides_indent_levels)
    let group      = 'IndentGuides' . ((level % 2 == 0) ? 'Even' : 'Odd')
    let multiplier = (&l:expandtab == 1) ? &l:shiftwidth : 1
    let pattern    = '^\s\{' . (level * multiplier - multiplier) . '\}\zs'
    let pattern   .= '\s\{' . multiplier . '\}'
    let pattern   .= '\ze'

    " define the higlight pattern and add to list
    call add(w:indent_guides_matches, matchadd(group, pattern))

    if g:indent_guides_debug
      echo "matchadd ('" . group . "', '" . pattern . "')"
    end
  endfor

  " DEBUG
  "echo w:indent_guides_matches
endfunction

"
" Disables the indent guides for all buffers.
"
function! indent_guides#disable()
  call indent_guides#init_matches()

  if !empty(w:indent_guides_matches)

    " DEBUG
    "echo w:indent_guides_matches

    let index = 0
    for match_id in w:indent_guides_matches
      call matchdelete(match_id)
      call remove(w:indent_guides_matches, index)
      let index += index
    endfor
    "call filter(w:indent_guides_matches, 0)
  endif
endfunction

"
" Automagically calculates and defines the indent highlight colors.
"
function! indent_guides#highlight_colors()
  if g:indent_guides_auto_colors
    " capture the backgroud color from the normal highlight
    let hi_normal       = indent_guides#capture_highlight('normal')
    let hi_normal_guibg = matchstr(hi_normal, 'guibg=\zs#[0-9A-Fa-f]\{6\}\ze')

    " calculate the highlight background colors
    let hi_odd_bg  = indent_guides#lighten_or_darken_color(hi_normal_guibg)
    let hi_even_bg = indent_guides#lighten_or_darken_color(hi_odd_bg)

    " define the new highlights
    exe "hi IndentGuidesOdd  guibg=" . hi_odd_bg
    exe "hi IndentGuidesEven guibg=" . hi_even_bg
  endif
endfunction

"
" Takes a color and darkens or lightens it depending on whether a dark or
" light colorscheme is being used.
"
function! indent_guides#lighten_or_darken_color(color)
    let percent = g:indent_guides_auto_colors_change_percent

    let new_color = (&g:background == 'dark') ?
      \ color_helper#hex_color_lighten(a:color, percent) :
      \ color_helper#hex_color_darken (a:color, percent)

    return new_color
endfunction

"
" Captures and returns the output of highlight group definitions
"
" Example: indent_guides#capture_highlight('normal')
" Returns: 'Normal xxx guifg=#323232 guibg=#ffffff font=DejaVu Sans Mono 9'
"
function! indent_guides#capture_highlight(group_name)
    redir => output
    exe "silent hi " . a:group_name
    redir END

    return output
endfunction

function! indent_guides#init_matches()
  let w:indent_guides_matches =
    \ exists('w:indent_guides_matches') ?
    \ w:indent_guides_matches : []
endfunction

