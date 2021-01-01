" ============================================================================
" FileName: skylightmenu.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:menu_details = nvim_buf_get_var(bufnr(), 'menu_details')
let s:menu_live_preview = nvim_buf_get_var(bufnr(), 'menu_live_preview')
let s:menu_saved_winid = nvim_buf_get_var(bufnr(), 'menu_saved_winid')

let s:block_restore_cursor = v:false

augroup skylight_menu
  autocmd!
  autocmd CursorMoved <buffer>
        \ if s:menu_live_preview || len(s:menu_details) == 1 |
          \ call s:preview() |
        \ endif
  autocmd BufWipeout <buffer> call s:restore_cursor()
augroup END

mapclear <buffer>
nnoremap <nowait><buffer><silent> <Esc> :<C-u>call <SID>close()<CR>
nnoremap <nowait><buffer><silent> q     :<C-u>call <SID>close()<CR>
nnoremap <nowait><buffer><silent> h     :<C-u>call <SID>close()<CR>
nnoremap <nowait><buffer><silent> l     :<C-u>call <SID>close()<CR>

nnoremap <nowait><buffer><silent> j     :<C-u>call <SID>wrap_move('down')<CR>
nnoremap <nowait><buffer><silent> k     :<C-u>call <SID>wrap_move('up')<CR>

if s:menu_live_preview
  nnoremap <nowait><buffer><silent> <CR>  :<C-u>call <SID>jumpto()<CR>
  for idx in range(1, len(s:menu_details) + 1)
    execute printf('nmap <buffer><silent> %s :%s<CR>', idx, idx)
  endfor
  function! s:preview() abort
    call skylight#preview(s:get_selected_info())
  endfunction
  function! s:close() abort
    call skylight#float#close()
    call s:close_menu()
  endfunction
  function! s:jumpto() abort
    let s:block_restore_cursor = v:true
    let location = s:get_selected_info()
    call s:close()
    call skylight#jumpto(location)
  endfunction
else
  nnoremap <nowait><buffer><silent> <CR>  :<C-u>call <SID>preview()<CR>
  for idx in range(1, len(s:menu_details) + 1)
    execute printf('nmap <buffer><silent> %s :%s<CR><CR>', idx, idx)
  endfor
  function! s:preview() abort
    let location = s:get_selected_info()
    call s:close_menu()
    call skylight#preview(location)
  endfunction
  function! s:close() abort
    call s:close_menu()
  endfunction
endif

function! s:close_menu() abort
  call nvim_win_close(0, v:true)
endfunction

function! s:get_selected_info() abort
  let locations = s:menu_details
  let index = getpos('.')[1] - 1
  return locations[index]
endfunction

function! s:wrap_move(direction) abort
  let currlnum = line('.')
  let lastlnum = line('$')
  if winheight(0) == 1
    call s:close()
  elseif currlnum == lastlnum && a:direction == 'down'
    normal! 1gg
  elseif currlnum == 1 && a:direction == 'up'
    normal! G
  else
    if a:direction == 'down'
      normal! j
    else
      normal! k
    endif
  endif
endfunction

function! s:restore_cursor() abort
  if s:block_restore_cursor
    return
  endif
  function! s:restore() abort
    " noautocmd: prevent from closing skylight preview window
    " which is opened by executing `:Skylight` and type Enter
    noa call nvim_set_current_win(s:menu_saved_winid)
  endfunction
  if nvim_get_current_win() != s:menu_saved_winid
    call timer_start(10, { -> s:restore() })
  endif
endfunction
