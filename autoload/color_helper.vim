" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

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
" Converts a given hex color string into an rgb list (eg. [red, green, blue]).
"
" Example: color_helper#hex_color_to_rgb('#0088FF')
" Returns: [0, 136, 255]
"
function! color_helper#hex_color_to_rgb(hex_color)
  let l:rgb = []

  if a:hex_color =~ g:indent_guides_hex_color_pattern
    let l:red   = color_helper#hex_to_dec(strpart(a:hex_color, 1, 2))
    let l:green = color_helper#hex_to_dec(strpart(a:hex_color, 3, 2))
    let l:blue  = color_helper#hex_to_dec(strpart(a:hex_color, 5, 2))
    let l:rgb = [l:red, l:green, l:blue]
  end

  return l:rgb
endfunction

"
" Converts a given rgb list (eg. [red, green, blue]) into a hex color string.
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
" Returns a ligtened color using the given color and the percent to lighten it
" by.
"
" Example: color_helper#hex_color_lighten('#000000', 0.10)
" Returns: '#191919'
"
function! color_helper#hex_color_lighten(color, percent)
  let l:rgb = color_helper#hex_color_to_rgb(a:color)
  let l:rgb_lightened = []

  for i in l:rgb
    call add(l:rgb_lightened, float2nr(i + ((255 - i) * a:percent)))
  endfor

  return color_helper#rgb_color_to_hex(l:rgb_lightened)
endfunction

"
" Returns a darkened color using the given color and the percent to darken it
" by.
"
" Example: color_helper#hex_color_darken('#FFFFFF', 0.10)
" Returns: '#E5E5E5'
"
function! color_helper#hex_color_darken(color, percent)
  let l:rgb = color_helper#hex_color_to_rgb(a:color)
  let l:rgb_darkened = []

  for i in l:rgb
    call add(l:rgb_darkened, float2nr(i * (1 - a:percent)))
  endfor

  return color_helper#rgb_color_to_hex(l:rgb_darkened)
endfunction

