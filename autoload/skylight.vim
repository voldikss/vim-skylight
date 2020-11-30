" ============================================================================
" FileName: skylight.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#jumpto(filename, lnum, cmd) abort
  if &ft=='floaterm' | wincmd c | endif
  silent! execute printf('%s %s | %s',
    \ g:skylight_jump_command,
    \ a:filename,
    \ a:lnum > -1 ? a:lnum : a:cmd
    \ )
endfunction

function! skylight#preview(filename, lnum, cmd) abort
  call skylight#float#close()
  let bufnr = skylight#buffer#load_buf(a:filename)

  let config = {
    \ 'width': g:skylight_width,
    \ 'height': g:skylight_height,
    \ 'position': g:skylight_position,
    \ 'borderchars': g:skylight_borderchars,
    \ 'title': a:filename,
    \ }
  if type(config.width) == v:t_float
    let config.width *= &columns
    let config.width = float2nr(config.width)
  endif
  if type(config.height) == v:t_float
    let config.height *= (&lines - &cmdheight - 1)
    let config.height = float2nr(config.height)
  endif
  let title_width = strdisplaywidth(config.title)
  let capacity = config.width - 2
  if title_width > capacity
    let config.title = '...' . config.title[title_width-capacity+3:]
  endif
  let winid = skylight#float#open(bufnr, config)
  call skylight#float#locate(winid, a:lnum, a:cmd)
endfunction

function! skylight#start(action, visualmode, range) abort
  let text = ''
  if a:visualmode == 'v' && a:range == 2
    let text = skylight#util#get_selected_text()
  endif
  call skylight#search#start(text, a:action)
endfunction
