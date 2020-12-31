# vim-skylight

Search and preview file/symbol/word under cursor in the floating window.

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
invoking the build-in function `findfile` to perform upward (up to the root directory)
and downward searching but asynchronously. So it will never block your actions.

Symbol searching basically depends on pre-generated tag files. Besides, the plugin
can also use LSP for searching symbols. Therefore it would be better to have an LSP
client (only support [coc.nvim](https://github.com/neoclide/coc.nvim) by now) installed.

Word searching will search for the `<cword>` in the current buffer (not implemented yet).

## Installation

```vim
Plug 'voldikss/vim-skylight'
```

Only works in NVIM >= 0.4.3

## Commands

- `:Skylight [...]` search and open a drop-down menu to display the results
  - `:Skylight file` regard the text under cursor as a filepath and search
  - `:Skylight tag` regard the text under cursor as a symbol and search
  - `:Skylight` firstly regard the text as a filepath, if failing to search
    then treat it as a symbol and preview again

In the drop-down menu, you can use:

- `j` or `k` to move and perform live previewing
- `<CR>` for jumping to
- `<Esc>` or `q` for closing
- `h` or `l` to close the menu quickly
- `j` or `k` to close the menu quickly if there is only one entry

NOTE: this command can also be used with a range, e.g., visual select and `'<,'>:Skylight! file`.

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

  Type `String`. Command used for `:Skylight!`.

  Available: `'edit'`, `'split'`, `'vsplit'`, `'tabe'`, `'drop'`.

  Default: `'edit'`

## Functions

- `skylight#float#has_scroll()`

- `skylight#float#scroll({forward}, [amount])`

## Keymaps

```vim
" Configuration example
nnoremap <silent>       gp    :Skylight file<CR>
vnoremap <silent>       gp    :Skylight file<CR>
nnoremap <silent>       go    :Skylight! file<CR>
vnoremap <silent>       go    :Skylight! file<CR>
```

The following mappings can be used for scrolling floating widow.

```vim
nnoremap <silent><expr> <C-f> skylight#float#has_scroll() ? skylight#float#scroll(1) : "\<C-f>"
nnoremap <silent><expr> <C-b> skylight#float#has_scroll() ? skylight#float#scroll(0) : "\<C-b>"
```

## Highlights

`SkylightBorder`, which is linked to `Normal` by default, can be used to
specify the border style.

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

## Known issues

Sometimes can not find the files in the hidden folders when performing
downward searching. That is because vim's file searching doesn't include
hidden directories, I am considering using another suitable file-finder cli
tool for the plugin but this will not come out in the short term.

## Screenshots

Notice: some gifs might be outdated (e.g., the commands `:SkylightPreview`
displayed in some gifs).

- Demo

![](https://user-images.githubusercontent.com/20282795/103416345-341cb500-4bc1-11eb-8010-fd4daef594b9.gif)

- Preview files from quickfix window

![](https://user-images.githubusercontent.com/20282795/100506133-f4207780-31a7-11eb-9c69-30e8e254a2bb.gif)

- Preview symbol

![](https://user-images.githubusercontent.com/20282795/100506082-ef5bc380-31a7-11eb-9618-fd37ad03f7cb.gif)

- Preview files from terminal window

![](https://user-images.githubusercontent.com/20282795/100506148-f5ea3b00-31a7-11eb-820e-b2f6dcc3840e.gif)
