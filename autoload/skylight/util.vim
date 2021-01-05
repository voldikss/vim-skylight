" ============================================================================
" FileName: util.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:echohl(group, msg) abort
  execute 'echohl ' . a:group
  echom '[vim-skylight] ' . a:msg
  echohl None
endfunction

function! skylight#util#show_msg(message, ...) abort
  if a:0 == 0
    let msgtype = 'info'
  else
    let msgtype = a:1
  endif

  if type(a:message) != v:t_string
    let message = string(a:message)
  else
    let message = a:message
  endif

  if msgtype ==# 'info'
    call s:echohl('MoreMsg', message)
  elseif msgtype ==# 'warning'
    call s:echohl('WarningMsg', message)
  elseif msgtype ==# 'error'
    call s:echohl('ErrorMsg', message)
  endif
endfunction

function! skylight#util#get_selected_text() abort
  let col1 = getpos("'<")[2]
  let col2 = getpos("'>")[2]
  let text = getline('.')
  if empty(text)
    call skylight#util#show_msg('No content', 'error')
    return ''
  endif
  let text = text[col1-1 : col2-1]
  return text
endfunction
