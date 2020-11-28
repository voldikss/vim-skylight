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
  if a:visualmode == 'v' && a:range == 2
    let col1 = getpos("'<")[2]
    let col2 = getpos("'>")[2]
    let text = getline('.')
    if empty(text)
      call skylight#util#show_msg('No content', 'error')
      return
    endif
    let text = text[col1-1 : col2-1]
    let [filename, lnum, cmd] = skylight#search#findfile(text)
  else
    let [filename, lnum, cmd] = skylight#search#findfile('')
  endif

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
