" ============================================================================
" FileName: search.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let g:skylight#search#succeed = 0

function! skylight#search#start(pattern, bang, type) abort
  let g:skylight#search#succeed = 0

  if a:type == 'file'
    call skylight#mode#file#search(a:pattern, a:bang)
  elseif a:type == 'tag'
    call skylight#mode#tag#search(a:pattern, a:bang)
  elseif a:type == 'word'
    call skylight#mode#word#search(a:pattern, a:bang)
  endif
endfunction

function! skylight#search#callback(filename, lnum, cmd, bang) abort
  let g:skylight#search#succeed = 1

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
