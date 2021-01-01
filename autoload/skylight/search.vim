" ============================================================================
" FileName: search.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:success = 0
let s:live_preview = 0

function! skylight#search#get_status() abort
  return s:success
endfunction

function! skylight#search#set_status(status) abort
  let s:success = a:status
endfunction

function! skylight#search#start(pattern, type, live_preview) abort
  let s:live_preview = a:live_preview
  call skylight#search#set_status(0)

  if !empty(a:type)
    call skylight#mode#{a:type}#search(a:pattern)
  else
    call skylight#mode#file#search(a:pattern)
    call skylight#mode#tag#search(a:pattern)
  endif
endfunction

function! skylight#search#callback(locations) abort
  if skylight#search#get_status() == 1
    return
  endif
  call skylight#search#set_status(1)

  let locations = filter(copy(a:locations), { _,v -> !empty(v.filename) && filereadable(v.filename) })
  if empty(locations)
    call skylight#util#show_msg('File or tag not found')
    return
  endif

  let filenames = map(copy(locations), { _,v -> v['filename'] })
  let filenames = map(filenames, { _,v -> fnamemodify(v, ':~:.') })
  let maxwidth = max(map(copy(filenames), { _,v -> len(v) }))
  if maxwidth > &columns / 2
    call map(filenames, { _,v -> pathshorten(v) })
  endif
  call skylight#float#create_menu(filenames, s:live_preview, locations)
  call timer_start(10, { -> execute('doautocmd skylight_menu CursorMoved') })
endfunction
