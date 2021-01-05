" ============================================================================
" FileName: symbol.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#mode#symbol#search(pattern) abort
  let pattern = empty(a:pattern) ? expand('<cword>') : a:pattern

  " use coc-action jumpReferences
  call s:coc_search()

  " use builtin taglist function
  call s:tag_search(pattern)
endfunction

function! s:tag_search(pattern) abort
  let pattern = '^' . a:pattern . '$'
  let vim = skylight#async#new()
  let cmd = [
        \ 'set tags=./tags,tags,.tags,.vim/tags,.vim/.tags',
        \ printf('let taglists = taglist("%s")', pattern),
        \ 'call rpcrequest(1, "vim_call_function", "skylight#mode#symbol#tag_search_callback", [taglists])',
        \ 'quit!'
        \ ]
  call vim.cmd(cmd, 1)
  call timer_start(5000, { -> s:stop_taglist(vim) })
endfunction

function! s:stop_taglist(vim) abort
  if skylight#search#get_status() != 1
    call skylight#util#show_msg('Stop searching tags due to timeout', 'info')
  endif
  call skylight#async#close(a:vim)
endfunction

function! skylight#mode#symbol#tag_search_callback(taglists) abort
  let locations = []
  if !empty(a:taglists)
    for t in a:taglists
      let location = {}
      for k in ['filename', 'cmd']
        let location[k] = t[k]
      endfor
      if location['cmd'] =~ '^\d\+$'
        let location['lnum'] = str2nr(cmd)
      else
        let location['lnum'] = -1
      endif
      call add(locations, location)
    endfor
    call skylight#search#callback(locations)
  endif
endfunction

let s:override = v:false
function! s:coc_search() abort
  if exists('g:did_coc_loaded')
    let s:override = v:true
    call CocActionAsync('jumpReferences')
  endif
endfunction

function! skylight#mode#symbol#on_coclocations_change() abort
  if s:override
    let locations = map(g:coc_jump_locations, {_, v -> #{filename: v.filename, lnum: v.lnum, cmd: ''} })
    call skylight#search#callback(locations)
  else
    CocList --normal --auto-preview location
  endif
  let s:override = v:false
endfunction
