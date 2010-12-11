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
  call indent_guides#clear_matches()

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
    let index = 0
    for match_id in w:indent_guides_matches
      call matchdelete(match_id)
      call remove(w:indent_guides_matches, index)
      let index += index
    endfor
  endif
endfunction

"
" Automagically calculates and defines the indent highlight colors.
"
function! indent_guides#highlight_colors()
  if g:indent_guides_auto_colors
    let hi_normal       = indent_guides#capture_highlight('normal')
    let hex_pattern     = 'guibg=\zs'. g:indent_guides_hex_color_pattern . '\ze'
    let name_pattern    = "guibg='\\?\\zs[0-9A-Za-z ]\\+\\ze'\\?"
    let hi_normal_guibg = ''

    " capture the backgroud color from the normal highlight
    if hi_normal =~ hex_pattern
      " hex color code is being used, eg. '#FFFFFF'
      let hi_normal_guibg = matchstr(hi_normal, hex_pattern)
    elseif hi_normal =~ name_pattern
      " color name is being used, eg. 'white'
      let color_name      = matchstr(hi_normal, name_pattern)
      let hi_normal_guibg = color_helper#color_name_to_hex(color_name)
    endif

    if hi_normal_guibg =~ g:indent_guides_hex_color_pattern
      " calculate the highlight background colors
      let hi_odd_bg  = indent_guides#lighten_or_darken_color(hi_normal_guibg)
      let hi_even_bg = indent_guides#lighten_or_darken_color(hi_odd_bg)

      " define the new highlights
      exe 'hi IndentGuidesOdd  guibg=' . hi_odd_bg
      exe 'hi IndentGuidesEven guibg=' . hi_even_bg
    end
  endif
endfunction

"
" Takes a color and darkens or lightens it depending on whether a dark or light
" colorscheme is being used.
"
function! indent_guides#lighten_or_darken_color(color)
  let percent = g:indent_guides_color_change_percent

  let new_color = (&g:background == 'dark') ?
    \ color_helper#hex_color_lighten(a:color, percent) :
    \ color_helper#hex_color_darken (a:color, percent)

  return new_color
endfunction

"
" Captures and returns the output of highlight group definitions.
"
" Example: indent_guides#capture_highlight('normal')
" Returns: 'Normal xxx guifg=#323232 guibg=#ffffff
"
function! indent_guides#capture_highlight(group_name)
  redir => output
  exe "silent hi " . a:group_name
  redir END

  return output
endfunction

"
" Init the w:indent_guides_matches variable.
"
function! indent_guides#init_matches()
  let w:indent_guides_matches =
    \ exists('w:indent_guides_matches') ? w:indent_guides_matches : []
endfunction

