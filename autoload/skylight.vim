" ============================================================================
" FileName: skylight.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#jumpto() abort
  let [filename, lnum, cmd] = skylight#search#findfile()
  if empty(filename) | return | endif
  if &ft=='floaterm' | wincmd c | endif
  silent! execute printf('%s %s | %s',
    \ g:skylight_jump_command,
    \ filename,
    \ lnum > -1 ? lnum : cmd
    \ )
endfunction

function! skylight#preview() abort
  let [filename, lnum, cmd] = skylight#search#findfile()
  if empty(filename) || !filereadable(filename)
    call skylight#util#show_err('File or tag not found')
    return
  endif
  if getfsize(filename) / (1024*1024) > 10
    call skylight#util#show_msg('File too large', 'error')
    return
  endif

  call skylight#float#close()
  let bufnr = skylight#buffer#load_buf(filename)

  let config = {
    \ 'width': g:skylight_width,
    \ 'height': g:skylight_height,
    \ 'position': g:skylight_position,
    \ 'borderchars': g:skylight_borderchars,
    \ 'title': filename,
    \ }
  if type(config.width) == v:t_float
    let config.width *= &columns
    let config.width = float2nr(config.width)
  endif
  if type(config.height) == v:t_float
    let config.height *= (&lines - &cmdheight - 1)
    let config.height = float2nr(config.height)
  endif
  if strdisplaywidth(config.title) > config.width - 2
    let config.title = config.title[:-4] . '...'
  endif
  let [winid, _] = skylight#float#open(bufnr, config)
  call skylight#float#locate(winid, lnum, cmd)
endfunction
