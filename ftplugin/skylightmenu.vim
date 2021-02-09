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
nnoremap <nowait><buffer><silent> <Plug>(close) :<C-u>call <SID>close()<CR>
nnoremap <nowait><buffer><silent> <Plug>(down)  :<C-u>call <SID>wrap_move('down')<CR>
nnoremap <nowait><buffer><silent> <Plug>(up)    :<C-u>call <SID>wrap_move('up')<CR>
if s:menu_live_preview
  nnoremap <nowait><buffer><silent> <Plug>(accept)  :<C-u>call <SID>jumpto()<CR>
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
  nnoremap <nowait><buffer><silent> <Plug>(accept)  :<C-u>call <SID>preview()<CR>
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
  if &filetype == 'skylightmenu'
    call nvim_win_close(0, v:true)
  endif
endfunction

function! s:get_selected_info() abort
  let locations = s:menu_details
  let index = getpos('.')[1] - 1
  return locations[index]
endfunction

function! s:wrap_move(direction) abort
  let currlnum = line('.')
  let lastlnum = line('$')
  if currlnum == lastlnum && a:direction == 'down'
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


" modified from coc/prompt.vim
"=============================================================================
function! s:prompt_getc() abort
  let c = getchar()
  return type(c) == type(0) ? nr2char(c) : c
endfunction

function! s:prompt_getchar() abort
  let input = s:prompt_getc()
  if 1 != &iminsert
    return input
  endif
  "a language keymap is activated, so input must be resolved to the ch values.
  let partial_keymap = mapcheck(input, "l")
  while partial_keymap !=# ""
    let full_keymap = maparg(input, "l")
    if full_keymap ==# "" && len(input) >= 3 "HACK: assume there are no keymaps longer than 3.
      return input
    elseif full_keymap ==# partial_keymap
      return full_keymap
    endif
    let c = s:prompt_getc()
    if c ==# "\<Esc>" || c ==# "\<CR>"
      "if the short sequence has a valid mapping, return that.
      if !empty(full_keymap)
        return full_keymap
      endif
      return input
    endif
    let input .= c
    let partial_keymap = mapcheck(input, "l")
  endwhile
  return input
endfunction

function! s:start_prompt()
  try
    while 1
      let ch = s:prompt_getchar()
      if ch ==# "\<FocusLost>" || ch ==# "\<FocusGained>" || ch ==# "\<CursorHold>"
        continue
      else
        if ch == "\<Esc>" || ch == "q"
          execute "normal \<Plug>(close)"
          return
        elseif ch == "\<CR>" || ch == "l" || ch == "h"
          execute "normal \<Plug>(accept)"
          return
        elseif ch == "j" || ch == "\<Down>"
          execute "normal \<Plug>(down)"
          doautocmd CursorMoved
          redraw
        elseif ch == "k" || ch == "\<Up>"
          execute "normal \<Plug>(up)"
          doautocmd CursorMoved
          redraw
        elseif index(range(1, 10), str2nr(ch)) > -1
          execute ch
          if !s:menu_live_preview
            execute "normal \<Plug>(accept)"
            return
          else
            doautocmd CursorMoved
            redraw
          endif
        elseif ch == "\<C-f>" || ch == "\<C-b>"
          autocmd CursorMoved <buffer> ++once redraw | call s:start_prompt()
          if ch == "\<C-f>"
            call skylight#float#scroll(1, 3)
          elseif ch == "\<C-b>"
            call skylight#float#scroll(0, 3)
          endif
          return
        elseif ch == "\<C-w>"
          autocmd CursorMoved <buffer> ++once redraw | call s:start_prompt()
          let suffix = s:prompt_getc()
          if suffix == "p"
            wincmd p
            return
          endif
        endif
      endif
    endwhile
  catch /^Vim:Interrupt$/
    return
  endtry
endfunction

nmap <nowait><buffer><silent> <CR>   <Plug>(accept)
nmap <nowait><buffer><silent> <Esc>  <Plug>(close)
nmap <nowait><buffer><silent> <Up>   <Plug>(up)
nmap <nowait><buffer><silent> <Down> <Plug>(down)
nmap <nowait><buffer><silent> q      <Plug>(close)
nmap <nowait><buffer><silent> k      <Plug>(up)
nmap <nowait><buffer><silent> j      <Plug>(down)

call timer_start(100, {->s:start_prompt()})
