# vim-skylight

Preview file/symbol under cursor in the floating window.

- [Requirements](#requirements)
- [Installation](#installation)
- [Commands](#commands)
- [Options](#options)
- [Functions](#functions)
- [Keymaps](#keymaps)
- [Highlights](#highlights)
- [Why](#why)
- [Screenshots](#screenshots)

## Requirements

Only works in NVIM >= 0.4.3

Other than using tags, the plugin can also use LSP for searching symbols.
Therefore it would be better to have an LSP client (only support
[coc.nvim](https://github.com/neoclide/coc.nvim) by now) installed.

## Installation

```vim
Plug 'voldikss/vim-skylight'
```

## Commands

- `:SkylightPreview`

- `:SkylightJumpTo`

## Options

- **`g:skylight_width`**

  Type `Number` (number of columns) or `Float` (between 0 and 1). If `Float`,
  the width is relative to `&columns`.

  Default: `0.5`

- **`g:skylight_height`**

  Type `Number` (number of lines) or `Float` (between 0 and 1). If `Float`, the
  height is relative to `&lines`.

  Default: `0.5`

- **`g:skylight_position`**

  Type `String`. The position of the floating window. Available:

  `'top'`, `'right'`, `'bottom'`, `'left'`, `'center'`, `'topleft'`,
  `'topright'`, `'bottomleft'`, `'bottomright'`, `'auto'(at the cursor place)`.

  Default: `'topright'`(recommended)

- **`g:skylight_borderchars`**

  Type `List` of `String`. Characters for the border.

  Default: `['─', '│', '─', '│', '╭', '╮', '╯', '╰']`

- **`g:skylight_jump_command`**

  Type `String`. Command used for `:SkylightJumpTo`.

  Available: `'edit'`, `'split'`, `'vsplit'`, `'tabe'`, `'drop'`. Default: `'edit'`

## Functions

- `skylight#float#exists()`

- `skylight#float#scroll({forward})`

## Keymaps

```vim
" Configuration **example**
nnoremap <silent>       go    :SkylightJumpTo<CR>
nnoremap <silent>       gp    :SkylightPreview<CR>
```

The following mappings can be used for scrolling floating widow.

```vim
nnoremap <silent><expr> <C-f> skylight#float#scroll(1)
nnoremap <silent><expr> <C-b> skylight#float#scroll(0)
```

NOTE: The [scrolling mappings](https://github.com/neoclide/coc.nvim/#example-vim-configuration)
of coc.nvim also works for this plugin, so if you are using coc you don't have
to use the above scroll mappings.

## Highlights

`SkylightBorder`, which is linked to `Normal` by default, can be used to specify the border style.

```vim
" Configuration example
hi SkylightBorder guibg=orange guifg=cyan
```

## Why

For a long time I was hoping to preview file under cursor in a disposable
floating window without actually opening it. Therefore I dug into the web and
found some awesome projects, which, however, only supports previewing from the
quickfix window. What I want is to preview from the filename that occurs in
any window, even the terminal window (when I am using gdb's `bt` command).

The codes were initially buildup in my personal dotfiles. After nearly the
whole feature was implemented, I decided to detach them from the dotfiles and
reorganize them into a plugin in case of someone who has the same requirements
needs it.

The file searching in the plugin would not be always accurate but it works
fine most of the time.

## Screenshots

- Preview files from quickfix window

![](https://user-images.githubusercontent.com/20282795/100463666-29c15400-3107-11eb-9889-1b9f8d987f87.gif)

- Preview files from terminal window

![](https://user-images.githubusercontent.com/20282795/100463681-2e860800-3107-11eb-9d7f-e77de5f4f386.gif)

- Preview symbol

![](https://user-images.githubusercontent.com/20282795/100463656-262dcd00-3107-11eb-9d89-c309b60062fa.gif)
