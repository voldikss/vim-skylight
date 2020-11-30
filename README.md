# vim-skylight

Search and preview file/symbol under cursor in the floating window.

- [Installation](#installation)
- [Commands](#commands)
- [Options](#options)
- [Functions](#functions)
- [Keymaps](#keymaps)
- [Highlights](#highlights)
- [Why](#why)
- [Screenshots](#screenshots)

## Rationale

File searching is initially inspired by vim's `gf`. It fundamentally works by
invoking the build-in function `findfile` but asynchronously. Therefore it
will never block your actions.

Symbol searching basically depends on pre-generated tag files. Other than
using tags, the plugin can also use LSP for searching symbols. Therefore it
would be better to have an LSP client (only support
[coc.nvim](https://github.com/neoclide/coc.nvim) by now) installed.

## Installation

```vim
Plug 'voldikss/vim-skylight'
```

Only works in NVIM >= 0.4.3

## Commands

- `:SkylightPreview`

- `:SkylightJumpTo`

NOTE: Both commands can also be in visual mode, e.g., `'<,'>:SkylightPreview`.

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

  Type `String`. The position of the floating window.

  Available: `'top'`, `'right'`, `'bottom'`, `'left'`, `'center'`, `'topleft'`,
  `'topright'`, `'bottomleft'`, `'bottomright'`, `'auto'(at the cursor place) `.

  Default: `'topright'`(recommended)

- **`g:skylight_borderchars`**

  Type `List` of `String`. Characters for the border.

  Default: `['─', '│', '─', '│', '╭', '╮', '╯', '╰']`

- **`g:skylight_jump_command`**

  Type `String`. Command used for `:SkylightJumpTo`.

  Available: `'edit'`, `'split'`, `'vsplit'`, `'tabe'`, `'drop'`.

  Default: `'edit'`

## Functions

- `skylight#float#has_scroll()`

- `skylight#float#scroll({forward}, [amount])`

## Keymaps

```vim
" Configuration example
nnoremap <silent>       go    :SkylightJumpTo<CR>
nnoremap <silent>       gp    :SkylightPreview<CR>
```

The following mappings can be used for scrolling floating widow.

```vim
nnoremap <silent><expr> <C-f> skylight#float#has_scroll() ? skylight#float#scroll(1)
nnoremap <silent><expr> <C-b> skylight#float#has_scroll() ? skylight#float#scroll(0)
```

## Highlights

`SkylightBorder`, which is linked to `Normal` by default, can be used to specify the border style.

```vim
" Configuration example
hi SkylightBorder guibg=orange guifg=cyan
```

## Why

For a long time I was hoping to preview file under cursor in a disposable
floating window without actually opening it. Then I dug into the web and
found some awesome projects, which, however, only support previewing files
that are listed in the quickfix window. What I want is to preview the file
that occurs anywhere in vim, even those in the builtin terminal window (when I am
using gdb's `bt` command).

The codes were initially buildup in my personal dotfiles. After the whole
feature was almost implemented, I decided to detach them from the dotfiles and
reorganize them into a plugin in case of someone who has the same requirement
needs it.

## Screenshots

- Preview files from quickfix window

![](https://user-images.githubusercontent.com/20282795/100506133-f4207780-31a7-11eb-9c69-30e8e254a2bb.gif)

- Preview symbol

![](https://user-images.githubusercontent.com/20282795/100506082-ef5bc380-31a7-11eb-9618-fd37ad03f7cb.gif)

- Preview files from terminal window

![](https://user-images.githubusercontent.com/20282795/100506148-f5ea3b00-31a7-11eb-820e-b2f6dcc3840e.gif)
