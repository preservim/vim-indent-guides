" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

function! s:IndentGuidesToggle()
  let g:IndentGuides_matches =
  \ exists('g:IndentGuides_matches') ? g:IndentGuides_matches : []

  if empty(g:IndentGuides_matches)
    IndentGuidesEnable
  else
    IndentGuidesDisable
  endif
endfunction

function! s:IndentGuidesEnable()
  IndentGuidesDisable

  for level in range(1, g:IndentGuides_indent_levels)
    let group      = 'IndentLevel' . ((level % 2 == 0) ? 'Even' : 'Odd')
    let multiplier = (&l:expandtab == 1) ? &l:shiftwidth : 1
    let pattern    = '^\s\{' . (level * multiplier - multiplier) . '\}\zs'
    let pattern   .= '\s\{' . multiplier . '\}'
    let pattern   .= '\ze'

    call add(g:IndentGuides_matches, matchadd(group, pattern))

    if g:IndentGuides_debug
      echo "matchadd ('" . group . "', '" . pattern . "')"
    end
  endfor
endfunction

function! s:IndentGuidesDisable()
  if !empty(g:IndentGuides_matches)
    let index = 0
    for item in g:IndentGuides_matches
      call matchdelete(item)
      call remove(g:IndentGuides_matches, index)
      let index += index
    endfor
  endif
endfunction

" Commands
command! IndentGuidesToggle  call s:IndentGuidesToggle()
command! IndentGuidesEnable  call s:IndentGuidesEnable()
command! IndentGuidesDisable call s:IndentGuidesDisable()

" Default options
let g:IndentGuides_indent_levels = 50
let g:IndentGuides_debug         = 0

" Default highlight colors
hi IndentLevelOdd  guibg=#252525
hi IndentLevelEven guibg=#303030

" Default mapping
nmap <Leader>ig :IndentGuidesToggle<CR>

