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

  call indent_guides#init_script_vars()
  call indent_guides#highlight_colors()
  call indent_guides#clear_matches()

  " loop through each indent level and define a highlight pattern
  " will automagically figure out whether to use tabs or spaces
  for l:level in range(s:start_level, s:indent_levels)
    let l:group      = 'IndentGuides' . ((l:level % 2 == 0) ? 'Even' : 'Odd')
    let l:pattern    = '^\s\{' . (l:level * s:indent_size - s:indent_size) . '\}\zs'
    let l:pattern   .= '\s\{' . s:guide_size . '\}'
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
  if s:auto_colors
    if has('gui_running')
      call indent_guides#gui_highlight_colors()
    else
      call indent_guides#basic_highlight_colors()
    endif
  endif
endfunction

"
" Defines some basic indent highlight colors that work for Terminal Vim and
" gVim when colors can't be automatically calculated.
"
function! indent_guides#basic_highlight_colors()
  let l:cterm_colors = (&g:background == 'dark') ? ['darkgrey', 'black'] : ['lightgrey', 'white']
  let l:gui_colors   = (&g:background == 'dark') ? ['grey15', 'grey30']  : ['grey70', 'grey85']

  exe 'hi IndentGuidesEven guibg=' . l:gui_colors[0] . ' ctermbg=' . l:cterm_colors[0]
  exe 'hi IndentGuidesOdd  guibg=' . l:gui_colors[1] . ' ctermbg=' . l:cterm_colors[1]
endfunction

"
" Automagically calculates and defines the indent highlight colors for gui
" vim.
"
function! indent_guides#gui_highlight_colors()
  let l:hi_normal_guibg = ''

  " capture the backgroud color from the normal highlight
  if s:hi_normal =~ s:color_hex_bg_pat
    " hex color code is being used, eg. '#FFFFFF'
    let l:hi_normal_guibg = matchstr(s:hi_normal, s:color_hex_bg_pat)

  elseif s:hi_normal =~ s:color_name_bg_pat
    " color name is being used, eg. 'white'
    let l:color_name = matchstr(s:hi_normal, s:color_name_bg_pat)
    let l:hi_normal_guibg = color_helper#color_name_to_hex(l:color_name)

  else
    " background color could not be detected, default to basic colors
    call indent_guides#basic_highlight_colors()
  endif

  if l:hi_normal_guibg =~ s:color_hex_pat
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
  let l:new_color = ''

  if (&g:background == 'dark')
    let l:new_color = color_helper#hex_color_lighten(a:color, s:change_percent)
  else
    let l:new_color = color_helper#hex_color_darken (a:color, s:change_percent)
  endif

  return l:new_color
endfunction

"
" Define default highlights.
"
function! indent_guides#define_default_highlights()
  exe 'hi IndentGuidesOdd  guibg=NONE ctermbg=NONE'
  exe 'hi IndentGuidesEven guibg=NONE ctermbg=NONE'
endfunction

"
" Init the w:indent_guides_matches variable.
"
function! indent_guides#init_matches()
  let w:indent_guides_matches = exists('w:indent_guides_matches') ? w:indent_guides_matches : []
endfunction

"
" We need to initialize these vars every time a buffer is entered while the
" plugin is enabled.
"
function! indent_guides#init_script_vars()
  let s:indent_size = indent_guides#get_indent_size()
  let s:guide_size  = indent_guides#calculate_guide_size()
  let s:hi_normal   = indent_guides#capture_highlight('Normal')

  " remove 'font=<value>' from the s:hi_normal string (only seems to happen on Vim startup in Windows)
  let s:hi_normal = substitute(s:hi_normal, ' font=[A-Za-z0-9:]\+', "", "")

  " shortcuts to the global variables - this makes the code easier to read
  let s:debug             = g:indent_guides_debug
  let s:indent_levels     = g:indent_guides_indent_levels
  let s:auto_colors       = g:indent_guides_auto_colors
  let s:change_percent    = g:indent_guides_color_change_percent / 100.0
  let s:color_hex_pat     = g:indent_guides_color_hex_pattern
  let s:color_hex_bg_pat  = g:indent_guides_color_hex_guibg_pattern
  let s:color_name_bg_pat = g:indent_guides_color_name_guibg_pattern
  let s:start_level       = g:indent_guides_start_level

  if s:debug
    echo 's:indent_size = '       . s:indent_size
    echo 's:guide_size = '        . s:guide_size
    echo 's:hi_normal = '         . s:hi_normal
    echo 's:indent_levels = '     . s:indent_levels
    echo 's:auto_colors = '       . s:auto_colors
    echo 's:change_percent = '    . string(s:change_percent)
    echo 's:color_hex_pat = '     . s:color_hex_pat
    echo 's:color_hex_bg_pat = '  . s:color_hex_bg_pat
    echo 's:color_name_bg_pat = ' . s:color_name_bg_pat
    echo 's:start_level = '       . s:start_level
  endif
endfunction

"
" Calculate the indent guide size. Ensures the guide size is less than or
" equal to the actual indent size, otherwise some weird things can occur.
"
" NOTE: Currently, this only works when soft-tabs are being used.
"
function! indent_guides#calculate_guide_size()
  let l:guide_size  = g:indent_guides_guide_size
  let l:indent_size = indent_guides#get_indent_size()

  if l:indent_size > 1 && l:guide_size >= 1
    let l:guide_size = (l:guide_size > s:indent_size) ? s:indent_size : l:guide_size
  else
    let l:guide_size = s:indent_size
  endif

  return l:guide_size
endfunction

"
" Gets the indent size, which depends on whether soft-tabs or hard-tabs are
" being used.
"
function! indent_guides#get_indent_size()
  return (&l:expandtab == 1) ? &l:shiftwidth : 1
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

  let l:output = substitute(l:output, "\n", "", "")
  return l:output
endfunction

