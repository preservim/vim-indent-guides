# Indent Guides
Indent Guides is a plugin for visually displaying indent levels in vim.

## Features:
* Can detect both tab and space indent styles.
* Automatically inspects your colorscheme and picks appropriate colors (gvim only).
* Will highlight indent levels with alternating colors.
* Full support for gvim and basic support for terminal vim.
* Seems to work on Windows gvim 7.3 (haven't done any extensive tests though).

## Requirements
* vim 7.2+

## Installation
To install the plugin just copy `autoload`, `plugin`, `doc` directories into your `.vim` directory.

Alternatively if you have [Pathogen](http://www.vim.org/scripts/script.php?script_id=2332) installed, just clone this repo into a subdirectory of your `.vim/bundle` directory like so:

    cd ~/.vim/bundle
    git clone git://github.com/nathanaelkane/vim-indent-guides.git

## Usage
The default mapping to toggle the plugin is `<Leader>ig`

### Setting custom indent colors
Here's an example of how to define custom colors instead using of the ones the plugin automatically generates for you. Add this to your `.vimrc` file:

    let g:indent_guides_auto_colors = 0
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4

### Terminal Vim
At the moment Terminal Vim only has basic support. This means is that colors won't be automatically calculated based on your colorscheme. Instead, some preset colors are used depending on whether `background` is set to `dark` or `light`.

When `set background=dark` is used, the following highlight colors will be defined:

    hi IndentGuidesEven ctermbg=darkgrey
    hi IndentGuidesOdd  ctermbg=black

Alternatively, when `set background=light` is used, the following highlight colors will be defined:

    hi IndentGuidesEven ctermbg=lightgrey
    hi IndentGuidesOdd  ctermbg=white

If for some reason it's incorrectly defining light highlight colors instead of dark ones or vice versa, the first thing you should check is that the `background` value is being set correctly for your colorscheme. Sometimes it's best to manually set the `background` value in your `.vimrc`, for example:

    colorscheme desert256
    set background=dark

Alternatively you can manually setup the highlight colors yourself, see `:help indent_guides_auto_colors` for an example.

## Help
`:help indent-guides`

## Screenshots
<img src="https://dl.dropbox.com/u/1019520/vim-indent-guides/rdark.png" width="400" height="400" alt="Indent Guides screenshot: rdark" />
<img src="https://dl.dropbox.com/u/1019520/vim-indent-guides/bclear.png" width="400" height="400" alt="Indent Guides screenshot: bclear" />
<img src="https://dl.dropbox.com/u/1019520/vim-indent-guides/clarity.png" width="400" height="400" alt="Indent Guides screenshot: clarity" />
<img src="https://dl.dropbox.com/u/1019520/vim-indent-guides/moss.png" width="400" height="400" alt="Indent Guides screenshot: moss" />

