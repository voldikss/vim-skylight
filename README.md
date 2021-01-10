# vim-skylight

Search asynchronously and preview file/symbol/word under cursor in the floating window.

![](https://user-images.githubusercontent.com/20282795/103437535-c2497780-4c63-11eb-8e21-82a9c23ec29b.png)

- [Installation](#installation)
- [Commands](#commands)
- [Options](#options)
- [Functions](#functions)
- [Keymaps](#keymaps)
- [Highlights](#highlights)
- [Why](#why)
- [More demos](#demos)

## Rationale

File searching is initially inspired by vim's `gf`. It fundamentally works by
invoking the build-in function `findfile()` to perform upward (up to the root
directory) and downward searching but asynchronously. It will never block your
actions.

Symbol searching basically invokes `taglist()` function asynchronously to
search for the pattern from pre-generated tag files. In addition, the plugin
can also use LSP for searching symbols (both definition and references).
Therefore it would be better to have an LSP client (only support [coc.nvim][1]
by now) installed.

Word searching will search for the `<cword>` in the current buffer (not
implemented yet).

## Installation

```vim
Plug 'voldikss/vim-skylight'
```

Only works in NVIM >= 0.4.3

## Usage

#### `:Skylight[!] [...]` search and open a drop-down menu to display the results

- If `!` is given, perform live previewing for multiple entries
- If use with an optional argument:
  - `:Skylight file` regard the text under cursor as a filepath and search
  - `:Skylight symbol` regard the text under cursor as a symbol and search
- If without arguments (i.e., `:Skylight`), it firstly suppose the text is a
  filename and search. If failing to search then treat the text as a symbol
  and search again

- In the drop-down menu, you can use:
  - `j` or `k` to move (and perform live previewing if the menu is opened by `: Skylight!`)
  - `<CR>` for previewing or jumping to if the menu is opened by `: Skylight!`)
  - `<Esc>` or `q` for closing
  - `h` or `l` to close the menu quickly
  - `j` or `k` will close the menu if there is only one entry
  - number keys(`1`, `2`, ...) to quickly jump to the corresponding entry

This command can also be used with a range, e.g., visual select and `'<,'>:Skylight! file`.

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

  Type `String`. Command used for jumping to

  Available: `'edit'`, `'split'`, `'vsplit'`, `'tabe'`, `'drop'`.

  Default: `'edit'`

## Functions

- `skylight#float#has_scroll()`

- `skylight#float#scroll({forward}, [amount])`

## Keymaps

```vim
" Configuration example
nnoremap <silent>       gp    :Skylight!<CR>
vnoremap <silent>       gp    :Skylight!<CR>
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
floating window without actually opening it. Then I dug into the web and found
some awesome projects, which, however, only support previewing files that are
listed only in the quickfix window. What I want is to preview the file that is
given by either relative or absolute path and occurs anywhere in vim, even
those in the builtin terminal window (when I am using gdb's `bt` command).

The codes were initially buildup in my personal dotfiles. After the whole
feature was almost implemented, I decided to detach them from the dotfiles and
reorganize them into a plugin in case of someone who has the same requirement
needs it.

## Known issues

Sometimes can not find the files in the hidden folders when performing
downward searching. That is because vim's file searching doesn't include
hidden directories, I am considering using another suitable file-finder cli
tool for the plugin but this will not come out in the short term.

Note that the plugin is developed with pure vimscript. Therefore, until the
whole file content has been loaded into memory could it be previewed in the
skylight window, so it's not recommended to perform `:Skylight[!]` on large
size files as it will cost more time for nvim to open that file.

## Demos

- with live preview
  ![](https://user-images.githubusercontent.com/20282795/103435742-47299680-4c4e-11eb-8428-a76a254a9935.gif)

- without live preview
  ![](https://user-images.githubusercontent.com/20282795/103435744-498bf080-4c4e-11eb-8aad-c4ee58923dad.gif)

- quickfix
  ![](https://user-images.githubusercontent.com/20282795/103435745-4a248700-4c4e-11eb-943f-4aa78fb801f9.gif)

- terminal
  ![](https://user-images.githubusercontent.com/20282795/103435599-d7b2a780-4c4b-11eb-94c6-a05398145c2f.gif)

[1]: (https://github.com/neoclide/coc.nvim)
