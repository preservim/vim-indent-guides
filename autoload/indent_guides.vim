function! indent_guides#toggle()
  let g:indent_guides_matches =
  \ exists('g:indent_guides_matches') ? g:indent_guides_matches : []

  if empty(g:indent_guides_matches)
    call indent_guides#enable()
  else
    call indent_guides#disable()
  endif
endfunction

function! indent_guides#enable()
  call indent_guides#disable()
  call indent_guides#highlight_colors()

  for level in range(1, g:indent_guides_indent_levels)
    let group      = 'IndentLevel' . ((level % 2 == 0) ? 'Even' : 'Odd')
    let multiplier = (&l:expandtab == 1) ? &l:shiftwidth : 1
    let pattern    = '^\s\{' . (level * multiplier - multiplier) . '\}\zs'
    let pattern   .= '\s\{' . multiplier . '\}'
    let pattern   .= '\ze'

    call add(g:indent_guides_matches, matchadd(group, pattern))

    if g:indent_guides_debug
      echo "matchadd ('" . group . "', '" . pattern . "')"
    end
  endfor
endfunction

function! indent_guides#disable()
  if !empty(g:indent_guides_matches)
    let index = 0
    for item in g:indent_guides_matches
      call matchdelete(item)
      call remove(g:indent_guides_matches, index)
      let index += index
    endfor
  endif
endfunction

function! indent_guides#highlight_colors()
  hi IndentLevelOdd  guibg=#FFFFFF
  hi IndentLevelEven guibg=#FBFBFB
endfunction

