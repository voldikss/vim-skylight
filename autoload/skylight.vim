" ============================================================================
" FileName: skylight.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:jumpto(filename, lnum, cmd) abort
  if &ft=='floaterm' | wincmd c | endif
  silent! execute printf('%s %s | %s',
    \ g:skylight_jump_command,
    \ a:filename,
    \ a:lnum > -1 ? a:lnum : a:cmd
    \ )
endfunction

function! s:preview(filename, lnum, cmd) abort
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
  if strdisplaywidth(config.title) > config.width - 2
    let config.title = config.title[:-4] . '...'
  endif
  let [winid, _] = skylight#float#open(bufnr, config)
  call skylight#float#locate(winid, a:lnum, a:cmd)
endfunction

function! skylight#start(action, visualmode, range) abort
  let text = ''
  if a:visualmode == 'v' && a:range == 2
    let text = skylight#util#get_selected_text()
  endif

  let [filename, lnum, cmd] = skylight#search#findfile(text)
  if empty(filename) || !filereadable(filename)
    call skylight#util#show_err('File or tag not found')
    return
  endif
  if getfsize(filename) / (1024*1024) > 10
    call skylight#util#show_msg('File too large', 'error')
    return
  endif

  if a:action == 'jumpto'
    call s:jumpto(filename, lnum, cmd)
  elseif a:action == 'preview'
    call s:preview(filename, lnum, cmd)
  endif
endfunction
