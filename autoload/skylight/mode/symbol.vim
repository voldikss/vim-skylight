" ============================================================================
" FileName: symbol.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#mode#symbol#search(pattern) abort
  if skylight#search#get_status() == 1
    return
  endif

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
        \ printf('let pattern = "%s"', pattern),
        \ printf('let taglists = taglist("%s")', pattern),
        \ 'call rpcrequest(1, "vim_call_function", "skylight#mode#symbol#tag_search_callback", [pattern, taglists])',
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

function! skylight#mode#symbol#tag_search_callback(pattern, taglists) abort
  let locations = []
  if !empty(a:taglists)
    for t in a:taglists
      let location = {
            \ 'pattern': a:pattern,
            \ 'filename': t.filename,
            \ 'cmd': t.cmd,
            \ }
      if location.cmd =~ '^\d\+$'
        let location.lnum = str2nr(cmd)
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
    silent! call CocActionAsync('jumpReferences')
  endif
endfunction

function! skylight#mode#symbol#on_coclocations_change() abort
  if s:override
    let locations = []
    for loc in g:coc_jump_locations
      call add(locations, #{
            \ filename: loc.filename,
            \ lnum: loc.lnum,
            \ range: loc.range
            \ })
    endfor
    call skylight#search#callback(locations)
  else
    let autocmd_count = (len(split(execute('autocmd User CocLocationsChange'), '\n')) - 1) / 3 
    if autocmd_count == 1
      CocList --normal --auto-preview location
    endif
  endif
  let s:override = v:false
endfunction
