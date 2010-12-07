" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

"
" Regex pattern for a hex color.
"
" Examples:
" - '#123ABC'
" - '#FFFFFF'
" - '#000000'
"
let s:hex_color_pattern = '#[0-9A-Fa-f]\{6\}'

"
" Return hex string equivalent to given decimal string or number.
"
" Example: color_helper#dec_to_hex(255, 2)
" Returns: 'FF'
"
" Example: color_helper#dec_to_hex(255, 5)
" Returns: '000FF'
"
function! color_helper#dec_to_hex(arg, padding)
  return toupper(printf('%0' . a:padding . 'x', a:arg + 0))
endfunction

"
" Return number equivalent to given hex string ('0x' is optional).
"
" Example: color_helper#hex_to_dec('FF')
" Returns: 255
"
" Example: color_helper#hex_to_dec('88')
" Returns: 136
"
" Example: color_helper#hex_to_dec('00')
" Returns: 0
"
function! color_helper#hex_to_dec(arg)
  return (a:arg =~? '^0x') ? a:arg + 0 : ('0x'.a:arg) + 0
endfunction

"
" Example: color_helper#hex_color_to_rgb('#0088FF')
" Returns: [0, 136, 255]
"
function! color_helper#hex_color_to_rgb(hex_color)
  let l:rgb = []

  if matchstr(a:hex_color, s:hex_color_pattern) == a:hex_color
    let l:red   = color_helper#hex_to_dec(strpart(a:hex_color, 1, 2))
    let l:green = color_helper#hex_to_dec(strpart(a:hex_color, 3, 2))
    let l:blue  = color_helper#hex_to_dec(strpart(a:hex_color, 5, 2))
    let l:rgb = [l:red, l:green, l:blue]
  end

  return l:rgb
endfunction

"
" Example: color_helper#rgb_color_to_hex([0, 136, 255])
" Returns: '#0088FF'
"
function! color_helper#rgb_color_to_hex(rgb_color)
  let l:hex_color  = '#'
  let l:hex_color .= color_helper#dec_to_hex(a:rgb_color[0], 2) " red
  let l:hex_color .= color_helper#dec_to_hex(a:rgb_color[1], 2) " green
  let l:hex_color .= color_helper#dec_to_hex(a:rgb_color[2], 2) " blue

  return l:hex_color
endfunction

"
" Example: color_helper#hex_color_brighten('#000000', 0.10)
" Returns: '#191919'
"
function! color_helper#hex_color_brighten(color, percent)
  let l:rgb = color_helper#hex_color_to_rgb(a:color)
  let l:rgb_brightened = []

  for decimal in l:rgb
    call add(l:rgb_brightened, float2nr(decimal * (a:percent + 1)))
  endfor

  return color_helper#rgb_color_to_hex(l:rgb_brightened)
endfunction

"
" Example: color_helper#hex_color_darken('#FFFFFF', 0.10)
" Returns: '#E5E5E5'
"
function! color_helper#hex_color_darken(color, percent)
  let l:rgb = color_helper#hex_color_to_rgb(a:color)
  let l:rgb_darkened = []

  for decimal in l:rgb
    call add(l:rgb_darkened, float2nr(decimal * (1 - a:percent)))
  endfor

  return color_helper#rgb_color_to_hex(l:rgb_darkened)
endfunction

