" ============================================================================
" FileName: skylight.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#jumpto(location) abort
  echom string(a:location)
  if has_key(a:location, 'lnum')
    let cmd = a:location.lnum
  elseif has_key(a:location, 'cmd')
    let cmd = a:location.cmd
  else
    let cmd = 'normal! gg0'
  endif
  silent! execute printf('%s %s | %s',
    \ g:skylight_jump_command,
    \ a:location.filename,
    \ cmd
    \ )
endfunction

function! skylight#preview(location) abort
  call skylight#float#close()
  let bufnr = skylight#buffer#load_buf(a:location.filename)

  let config = {
    \ 'width': g:skylight_width,
    \ 'height': g:skylight_height,
    \ 'position': g:skylight_position,
    \ 'borderchars': g:skylight_borderchars,
    \ 'title': a:location.filename,
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
  let maxwidth = (config.width - 2) / 2
  if title_width > maxwidth
    let config.title = '...' . config.title[title_width-maxwidth+3:]
  endif
  let winid = skylight#float#open(bufnr, config)
  call skylight#float#locate(winid, a:location)
endfunction

function! skylight#start(type, visualmode, range, live_preview) abort
  let text = ''
  if a:visualmode == 'v' && a:range == 2
    let text = skylight#util#get_selected_text()
  endif
  call skylight#search#start(text, a:type, a:live_preview)
endfunction
