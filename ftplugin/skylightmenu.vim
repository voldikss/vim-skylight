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
let s:char_map = {
      \ "\<Plug>": '<plug>',
      \ "\<Esc>": '<esc>',
      \ "\<Tab>": '<tab>',
      \ "\<S-Tab>": '<s-tab>',
      \ "\<bs>": '<bs>',
      \ "\<right>": '<right>',
      \ "\<left>": '<left>',
      \ "\<up>": '<up>',
      \ "\<down>": '<down>',
      \ "\<home>": '<home>',
      \ "\<end>": '<end>',
      \ "\<cr>": '<cr>',
      \ "\<PageUp>":'<PageUp>' ,
      \ "\<PageDown>":'<PageDown>' ,
      \ "\<FocusGained>":'<FocusGained>' ,
      \ "\<ScrollWheelUp>": '<ScrollWheelUp>',
      \ "\<ScrollWheelDown>": '<ScrollWheelDown>',
      \ "\<LeftMouse>": '<LeftMouse>',
      \ "\<LeftDrag>": '<LeftDrag>',
      \ "\<LeftRelease>": '<LeftRelease>',
      \ "\<2-LeftMouse>": '<2-LeftMouse>',
      \ "\<C-a>": '<C-a>',
      \ "\<C-b>": '<C-b>',
      \ "\<C-c>": '<C-c>',
      \ "\<C-d>": '<C-d>',
      \ "\<C-e>": '<C-e>',
      \ "\<C-f>": '<C-f>',
      \ "\<C-g>": '<C-g>',
      \ "\<C-h>": '<C-h>',
      \ "\<C-j>": '<C-j>',
      \ "\<C-k>": '<C-k>',
      \ "\<C-l>": '<C-l>',
      \ "\<C-n>": '<C-n>',
      \ "\<C-o>": '<C-o>',
      \ "\<C-p>": '<C-p>',
      \ "\<C-q>": '<C-q>',
      \ "\<C-r>": '<C-r>',
      \ "\<C-s>": '<C-s>',
      \ "\<C-t>": '<C-t>',
      \ "\<C-u>": '<C-u>',
      \ "\<C-v>": '<C-v>',
      \ "\<C-w>": '<C-w>',
      \ "\<C-x>": '<C-x>',
      \ "\<C-y>": '<C-y>',
      \ "\<C-z>": '<C-z>',
      \ "\<A-a>": '<A-a>',
      \ "\<A-b>": '<A-b>',
      \ "\<A-c>": '<A-c>',
      \ "\<A-d>": '<A-d>',
      \ "\<A-e>": '<A-e>',
      \ "\<A-f>": '<A-f>',
      \ "\<A-g>": '<A-g>',
      \ "\<A-h>": '<A-h>',
      \ "\<A-i>": '<A-i>',
      \ "\<A-j>": '<A-j>',
      \ "\<A-k>": '<A-k>',
      \ "\<A-l>": '<A-l>',
      \ "\<A-m>": '<A-m>',
      \ "\<A-n>": '<A-n>',
      \ "\<A-o>": '<A-o>',
      \ "\<A-p>": '<A-p>',
      \ "\<A-q>": '<A-q>',
      \ "\<A-r>": '<A-r>',
      \ "\<A-s>": '<A-s>',
      \ "\<A-t>": '<A-t>',
      \ "\<A-u>": '<A-u>',
      \ "\<A-v>": '<A-v>',
      \ "\<A-w>": '<A-w>',
      \ "\<A-x>": '<A-x>',
      \ "\<A-y>": '<A-y>',
      \ "\<A-z>": '<A-z>',
      \ }

function! s:prompt_getc() abort
  let c = getchar()
  return type(c) == type(0) ? nr2char(c) : c
endfunction

function! s:prompt_getchar() abort
  let input = s:prompt_getc()
  if 1 != &iminsert
    return input
  endif
  "a language keymap is activated, so input must be resolved to the mapped values.
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
        let mapped = get(s:char_map, ch, ch)
        if mapped == '<esc>' || mapped == 'q'
          execute "normal \<Plug>(close)"
          return
        elseif mapped == '<cr>' || mapped == 'l' || mapped == 'h'
          execute "normal \<Plug>(accept)"
          return
        elseif mapped == 'j' || mapped == '<down>'
          execute "normal \<Plug>(down)"
          doautocmd CursorMoved
          redraw
        elseif mapped == 'k' || mapped == '<up>'
          execute "normal \<Plug>(up)"
          doautocmd CursorMoved
          redraw
        elseif index(range(1, 10), str2nr(mapped)) > -1
          execute mapped
          if !s:menu_live_preview
            execute "normal \<Plug>(accept)"
            return
          else
            doautocmd CursorMoved
            redraw
          endif
        elseif mapped == '<c-f>' || mapped == '<c-b>'
          autocmd CursorMoved <buffer> ++once redraw | call s:start_prompt()
          if mapped == '<c-f>'
            call skylight#float#scroll(1, 3)
          elseif mapped == '<c-b>'
            call skylight#float#scroll(0, 3)
          endif
          return
        endif
      endif
    endwhile
  catch /^Vim:Interrupt$/
    return
  endtry
endfunction

nmap <nowait><buffer><silent> <Esc>  <Plug>(close)
nmap <nowait><buffer><silent> <Up>   <Plug>(up)
nmap <nowait><buffer><silent> <Down> <Plug>(down)
nmap <nowait><buffer><silent> q      <Plug>(close)
nmap <nowait><buffer><silent> k      <Plug>(up)
nmap <nowait><buffer><silent> j      <Plug>(down)

call timer_start(100, {->s:start_prompt()})
