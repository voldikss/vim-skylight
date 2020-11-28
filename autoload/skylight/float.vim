" ============================================================================
" FileName: float.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:calculate_float_pos(width, height, pos) abort
  if a:pos == 'topright'
    let row = 1
    let col = &columns
    let anchor = 'NE'
  elseif a:pos == 'topleft'
    let row = 1
    let col = 0
    let anchor = 'NW'
  elseif a:pos == 'bottomright'
    let row = &lines - &cmdheight - 1
    let col = &columns
    let anchor = 'SE'
  elseif a:pos == 'bottomleft'
    let row = &lines - &cmdheight - 1
    let col = 0
    let anchor = 'SW'
  elseif a:pos == 'top'
    let row = 1
    let col = (&columns - a:width)/2
    let anchor = 'NW'
  elseif a:pos == 'right'
    let row = (&lines - a:height)/2
    let col = &columns
    let anchor = 'NE'
  elseif a:pos == 'bottom'
    let row = &lines - &cmdheight - 1
    let col = (&columns - a:width)/2
    let anchor = 'SW'
  elseif a:pos == 'left'
    let row = (&lines - a:height)/2
    let col = 0
    let anchor = 'NW'
  elseif a:pos == 'center'
    let row = (&lines - a:height)/2
    let col = (&columns - a:width)/2
    let anchor = 'NW'
    if row < 0
      let row = 0
    endif
    if col < 0
      let col = 0
    endif
  else " at the cursor place
    let winpos = win_screenpos(0)
    let row = winpos[0] - 1 + winline()
    let col = winpos[1] - 1 + wincol()
    if row + a:height <= &lines - &cmdheight - 1
      let vert = 'N'
    else
      let vert = 'S'
      let row -= 1
    endif
    if col + a:width <= &columns
      let hor = 'W'
    else
      let hor = 'E'
    endif
    let anchor = vert . hor
  endif
  if !has('nvim')
    let anchor = substitute(anchor, '\CN', 'top', '')
    let anchor = substitute(anchor, '\CS', 'bot', '')
    let anchor = substitute(anchor, '\CW', 'left', '')
    let anchor = substitute(anchor, '\CE', 'right', '')
  endif
  return [row, col, anchor]
endfunction

function! s:win_exists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction

function! s:nvim_win_execute(winid, command) abort
  let curr = nvim_get_current_win()
  noa keepalt call nvim_set_current_win(a:winid)
  exec a:command
  noa keepalt call nvim_set_current_win(curr)
endfunction

function! s:register_autocmd(...) abort
  augroup close_skylight_float
    autocmd!
    autocmd CursorMoved * call timer_start(100, function('skylight#float#close'))
  augroup END
endfunction

function! skylight#float#close(...) abort
  if win_getid() == s:winid | return | endif
  call skylight#buffer#clear_highlight()
  if s:win_exists(s:winid)
    call nvim_win_close(s:winid, v:true)
    let s:winid = -1
  endif
  if s:win_exists(s:border_winid)
    call nvim_win_close(s:border_winid, v:true)
    let s:border_winid = -1
  endif
  if exists('#close_skylight_float')
    autocmd! close_skylight_float
  endif
endfunction

function! skylight#float#locate(winid, lnum, cmd) abort
  noautocmd call win_gotoid(a:winid)
  execute 'doautocmd filetypedetect BufNewFile'
  if a:lnum > -1 || !empty(a:cmd)
    if a:lnum > -1
      noautocmd execute 'keepjumps ' . a:lnum
    else
      silent! execute a:cmd
    endif
    let lnum = line('.')
    call skylight#buffer#add_highlight(a:lnum)
  endif
  noautocmd wincmd p
endfunction

let s:winid = -1
let s:border_winid = -1
function! skylight#float#open(bufnr, configs) abort
  let [row, col, anchor] = s:calculate_float_pos(
    \ a:configs.width,
    \ a:configs.height,
    \ a:configs.position
    \ )
  let border_options = {
    \ 'relative': 'editor',
    \ 'anchor': anchor,
    \ 'row': row,
    \ 'col': col,
    \ 'width': a:configs.width,
    \ 'height': a:configs.height,
    \ 'style':'minimal'
    \ }

  let options = deepcopy(border_options)
  let options.row += (options.anchor[0] == 'N' ? 1 : -1)
  let options.col += (options.anchor[1] == 'W' ? 1 : -1)
  let options.width -= 2
  let options.height -= 2
  let s:winid = nvim_open_win(a:bufnr, v:false, options)
  call nvim_win_set_option(s:winid, 'number', v:true)

  let border_bufnr = skylight#buffer#create_border(a:configs)
  let s:border_winid = nvim_open_win(border_bufnr, v:false, border_options)
  call nvim_win_set_option(s:border_winid, 'winhl', 'Normal:SkylightBorder')
  call timer_start(100, function('s:register_autocmd'))
  return [s:winid, s:border_winid]
endfunction

function! skylight#float#exists() abort
  return s:win_exists(s:winid)
endfunction

function! skylight#float#scroll(forward) abort
  if !s:win_exists(s:winid)
    call skylight#util#show_msg('No skylight windows')
    return ''
  endif
  let bufnr = nvim_win_get_buf(s:winid)
  let rowcnt = nvim_buf_line_count(bufnr)
  let height = nvim_win_get_height(s:winid)
  if rowcnt < height | return '' | endif
  let pos = nvim_win_get_cursor(s:winid)
  if a:forward
    if pos[0] == 1
      let pos[0] += 3 * height / 4
    elseif pos[0] + height / 2 + 1 < rowcnt
      let pos[0] += height / 2 + 1
    else
      let pos[0] = rowcnt
    endif
  else
    if pos[0] == rowcnt
      let pos[0] -= 3 * height / 4
    elseif pos[0] - height / 2 + 1  > 1
      let pos[0] -= height / 2 + 1
    else
      let pos[0] = 1
    endif
  endif
  let cmd = printf('call winrestview({"lnum": %s})', pos[0])
  call s:nvim_win_execute(s:winid, cmd)
  return "\<Ignore>"
endfunction
