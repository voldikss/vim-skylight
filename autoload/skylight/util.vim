" ============================================================================
" FileName: util.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:echo(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echo a:msg
  echon ' '
  echohl NONE
endfunction

function! s:echon(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echon a:msg
  echon ' '
  echohl NONE
endfunction

function! skylight#util#show_msg(message, ...) abort
  if a:0 == 0
    let msg_type = 'info'
  else
    let msg_type = a:1
  endif

  if type(a:message) != 1
    let message = string(a:message)
  else
    let message = a:message
  endif

  call s:echo('Constant', '[vim-skylight]')

  if msg_type ==# 'info'
    call s:echon('Normal', message)
  elseif msg_type ==# 'warning'
    call s:echon('WarningMsg', message)
  elseif msg_type ==# 'error'
    call s:echon('Error', message)
  endif
endfunction

function! skylight#util#show_err(...) abort
  if exists('g:skylight_errmsg') && !empty(g:skylight_errmsg)
    call skylight#util#show_msg(g:skylight_errmsg, 'error')
  else
    let message = get(a:, 1, '')
    call skylight#util#show_msg(message, 'error')
  endif
  let g:skylight_errmsg = ''
endfunction
