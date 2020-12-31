" ============================================================================
" FileName: skylightmenu.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

mapclear <buffer>
nnoremap <nowait><buffer><silent> <CR>  :<C-u>call <SID>jumpto()<CR>
nnoremap <nowait><buffer><silent> <Esc> :<C-u>call <SID>close()<CR>
nnoremap <nowait><buffer><silent> q     :<C-u>call <SID>close()<CR>
nnoremap <nowait><buffer><silent> h     :<C-u>call <SID>close()<CR>
nnoremap <nowait><buffer><silent> l     :<C-u>call <SID>close()<CR>

if len(nvim_buf_get_var(bufnr(), 'skylight_menu_details')) == 1
  nnoremap <nowait><buffer><silent> j   :<C-u>call <SID>close()<CR>
  nnoremap <nowait><buffer><silent> k   :<C-u>call <SID>close()<CR>
endif

augroup skylight_menu
  autocmd!
  autocmd CursorMoved <buffer> call s:preview()
augroup END

function! s:preview() abort
  call skylight#preview(s:get_selected_info())
endfunction

function! s:close() abort
  call skylight#float#close()
  call nvim_win_close(0, v:true)
endfunction

function! s:jumpto() abort
  let location = s:get_selected_info()
  call s:close()
  call skylight#jumpto(location)
endfunction

function! s:get_selected_info() abort
  let locations = nvim_buf_get_var(bufnr(), 'skylight_menu_details')
  let index = getpos('.')[1] - 1
  return locations[index]
endfunction
