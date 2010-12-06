" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

let s:hex_color_pattern = '#[0-9A-Fa-f]\{6\}'

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
  call s:IndentGuidesHighlightColors()

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

function! s:IndentGuidesHighlightColors()
  hi IndentLevelOdd  guibg=#FFFFFF
  hi IndentLevelEven guibg=#FBFBFB
endfunction

" Commands
command! IndentGuidesToggle  call s:IndentGuidesToggle()
command! IndentGuidesEnable  call s:IndentGuidesEnable()
command! IndentGuidesDisable call s:IndentGuidesDisable()

" Default options
let g:IndentGuides_indent_levels = 50
let g:IndentGuides_debug         = 0

" Default mapping
nmap <Leader>ig :IndentGuidesToggle<CR>

"
" Return hex string equivalent to given decimal string or number.
"
" Example: DecToHex(255, 2)
" Returns: 'FF'
"
" Example: DecToHex(255, 5)
" Returns: '000FF'
"
function! DecToHex(arg, padding)
  return toupper(printf('%0' . a:padding . 'x', a:arg + 0))
endfunction

"
" Return number equivalent to given hex string ('0x' is optional).
"
" Example: HexToDec('FF')
" Returns: 255
"
" Example: HexToDec('88')
" Returns: 136
"
" Example: HexToDec('00')
" Returns: 0
"
function! HexToDec(arg)
  return (a:arg =~? '^0x') ? a:arg + 0 : ('0x'.a:arg) + 0
endfunction

" Example: HexColorToRGB('#0088FF')
" Returns: [0, 136, 255]
function! HexColorToRGB(hex_color)
  let l:rgb = []
  if matchstr(a:hex_color, s:hex_color_pattern) == a:hex_color
    let l:red   = HexToDec(strpart(a:hex_color, 1, 2))
    let l:green = HexToDec(strpart(a:hex_color, 3, 2))
    let l:blue  = HexToDec(strpart(a:hex_color, 5, 2))
    let l:rgb = [l:red, l:green, l:blue]
  end
  return l:rgb
endfunction

"
" Example: RGBColorToHex([0, 136, 255])
" Returns: '#0088FF'
"
function! RGBColorToHex(rgb_color)
  let l:hex_color  = '#'
  let l:hex_color .= DecToHex(a:rgb_color[0], 2) " red
  let l:hex_color .= DecToHex(a:rgb_color[1], 2) " green
  let l:hex_color .= DecToHex(a:rgb_color[2], 2) " blue
  return l:hex_color
endfunction

"
" Example: HexColorBrighten('#000000', 0.10)
" Returns: '#191919'
"
function! HexColorBrighten(color, percent)
  let l:rgb = HexColorToRGB(a:color)
  let l:rgb_brightened = []
  for decimal in l:rgb
    call add(l:rgb_brightened, float2nr((255 - decimal) * a:percent))
  endfor
  return RGBColorToHex(l:rgb_brightened)
endfunction

"
" Example: HexColorDarken('#FFFFFF', 0.10)
" Returns: '#E5E5E5'
"
function! HexColorDarken(color, percent)
  let l:rgb = HexColorToRGB(a:color)
  let l:rgb_darkened = []
  for decimal in l:rgb
    call add(l:rgb_darkened, float2nr(decimal * (1 - a:percent)))
  endfor
  return RGBColorToHex(l:rgb_darkened)
endfunction

