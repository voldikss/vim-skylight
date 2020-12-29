" ============================================================================
" FileName: search.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:success = 0

function! skylight#search#get_status() abort
  return s:success
endfunction

function! skylight#search#set_status(status) abort
  let s:success = a:status
endfunction

function! skylight#search#start(pattern, bang, type) abort
  call skylight#search#set_status(0)

  if !empty(a:type)
    call skylight#mode#{a:type}#search(a:pattern, a:bang)
  else
    call skylight#mode#file#search(a:pattern, a:bang)
    call skylight#mode#tag#search(a:pattern, a:bang)
  endif
endfunction

function! skylight#search#callback(filename, lnum, cmd, bang) abort
  if skylight#search#get_status() == 1
    return
  endif
  call skylight#search#set_status(1)

  if empty(a:filename) || !filereadable(a:filename)
    call skylight#util#show_msg('File or tag not found')
    return
  endif

  if getfsize(a:filename) / (1024*1024) > 10
    call skylight#util#show_msg('File too large', 'error')
    return
  endif

  if a:bang
    call skylight#jumpto(a:filename, a:lnum, a:cmd)
  else
    call skylight#preview(a:filename, a:lnum, a:cmd)
  endif
endfunction
