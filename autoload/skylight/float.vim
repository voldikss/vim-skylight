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

function! s:register_autocmd() abort
  augroup close_skylight_float
    autocmd!
    autocmd CursorMoved * call timer_start(100, { -> skylight#float#close() })
  augroup END
endfunction

function! skylight#float#close() abort
  if nvim_get_current_win() == s:winid | return | endif
  call skylight#buffer#clear_highlight()
  if s:win_exists(s:winid)
    call nvim_win_close(s:winid, v:true)
    let s:winid = -1
  endif
  if s:win_exists(s:bd_winid)
    call nvim_win_close(s:bd_winid, v:true)
    let s:bd_winid = -1
  endif
  if s:win_exists(s:sb_winid)
    call nvim_win_close(s:sb_winid, v:true)
    let s:sb_winid = -1
  endif
  if exists('#close_skylight_float')
    autocmd! close_skylight_float
  endif
  if exists('#refresh_scroll_bar')
    autocmd! refresh_scroll_bar
  endif
endfunction

function! skylight#float#locate(winid, lnum, cmd) abort
  noautocmd call nvim_set_current_win(a:winid)
  execute 'doautocmd filetypedetect BufNewFile'
  if a:lnum > -1 || !empty(a:cmd)
    noautocmd execute 'silent keepjumps ' . (a:lnum > -1 ? a:lnum : a:cmd)
    let lnum = line('.')
    call skylight#buffer#add_highlight(lnum)
  endif
  augroup refresh_scroll_bar
    autocmd!
    execute printf(
          \ 'autocmd CursorMoved <buffer=%s> call skylight#cocf#refresh_scroll_bar(%s)',
          \ nvim_win_get_buf(a:winid),
          \ a:winid
          \ )
  augroup END
  noautocmd wincmd p
endfunction

function! skylight#float#open(bufnr, configs) abort
  let [
        \ a:configs.row,
        \ a:configs.col,
        \ a:configs.anchor
        \ ] = s:calculate_float_pos(
        \ a:configs.width,
        \ a:configs.height,
        \ a:configs.position
        \ )
  let winid = s:nvim_create_skylight_win(a:bufnr, a:configs)
  call s:nvim_create_scroll_win(winid, a:configs)
  call s:nvim_create_border_win(winid, a:configs)
  call timer_start(100, { -> s:register_autocmd() })
  return winid
endfunction

let s:winid = -1
function! s:nvim_create_skylight_win(bufnr, configs) abort
  let options = {
        \ 'relative': 'editor',
        \ 'anchor': a:configs.anchor,
        \ 'row': a:configs.row + (a:configs.anchor[0] == 'N' ? 1 : -1),
        \ 'col': a:configs.col + (a:configs.anchor[1] == 'W' ? 1 : -2),
        \ 'width': a:configs.width - 3,
        \ 'height': a:configs.height - 2,
        \ 'style':'minimal',
        \ }
  let winid = nvim_open_win(a:bufnr, v:false, options)
  call nvim_win_set_option(winid, 'number', v:true)
  call nvim_win_set_option(winid, 'signcolumn', 'no')
  let s:winid = winid
  return winid
endfunction

let s:bd_winid = -1
function! s:nvim_create_border_win(winid, configs) abort
  let bd_options = {
        \ 'relative': 'editor',
        \ 'anchor': a:configs.anchor,
        \ 'row': a:configs.row,
        \ 'col': a:configs.col,
        \ 'width': a:configs.width,
        \ 'height': a:configs.height,
        \ 'focusable': v:false,
        \ 'style':'minimal',
        \ }
  let bd_bufnr = skylight#buffer#create_border(a:configs)
  let bd_winid = nvim_open_win(bd_bufnr, v:false, bd_options)
  call nvim_win_set_option(bd_winid, 'winhl', 'Normal:SkylightBorder')
  call nvim_win_set_var(a:winid, 'border_winid', bd_winid)
  let s:bd_winid = bd_winid
  return bd_winid
endfunction

let s:sb_winid = -1
function! s:nvim_create_scroll_win(winid, configs) abort
  let options = {
        \ 'relative': 'editor',
        \ 'anchor': a:configs.anchor,
        \ 'row': a:configs.row + (a:configs.anchor[0] == 'N' ? 1 : -1),
        \ 'col': a:configs.col + (a:configs.anchor[1] == 'W' ? (a:configs.width-2) : -1),
        \ 'width': 1,
        \ 'height': a:configs.height - 2,
        \ 'style': 'minimal',
        \ }
  let sb_bufnr = skylight#buffer#create_scratch_buf(repeat([' '], a:configs.height - 2))
  let sb_winid = nvim_open_win(sb_bufnr, v:false, options)
  call nvim_win_set_var(a:winid, 'scroll_winid', sb_winid)
  call skylight#cocf#refresh_scroll_bar(a:winid)
  let s:sb_winid = sb_winid
  return sb_winid
endfunction

function! skylight#float#has_scroll() abort
  return s:win_exists(s:winid) && s:win_exists(s:sb_winid)
endfunction

function! skylight#float#scroll(forward, ...) abort
  let amount = get(a:, 1, 0)
  if !s:win_exists(s:winid)
    call skylight#util#show_msg('No skylight windows', 'error')
  else
    call skylight#cocf#scroll_win(s:winid, a:forward, amount)
  endif
  return mode() =~ '^i' || mode() ==# 'v' ? "" : "\<Ignore>"
endfunction

function! skylight#float#create_menu(lines, live_preview, details) abort
  call map(a:lines, { k,v -> printf('%s. %s', k+1, v) })
  let bufnr = skylight#buffer#create_scratch_buf(a:lines)
  call nvim_buf_set_var(bufnr, 'menu_live_preview', a:live_preview)
  call nvim_buf_set_var(bufnr, 'menu_details', a:details)
  call nvim_buf_set_var(bufnr, 'menu_saved_winid', nvim_get_current_win())
  call nvim_buf_set_option(bufnr, 'filetype', 'skylightmenu')
  call nvim_buf_set_option(bufnr, 'buftype', 'nofile')

  let options = {
        \ 'width': max(map(copy(a:lines), { _,v -> len(v) })) + 1,
        \ 'height': len(a:lines),
        \ 'relative': 'editor',
        \ 'style': 'minimal',
        \}
  let [
        \ options.row,
        \ options.col,
        \ options.anchor
        \ ] = s:calculate_float_pos(
        \ options.width,
        \ options.height,
        \ 'auto'
        \ )
  let winid = nvim_open_win(bufnr, v:true, options)
  call nvim_win_set_option(winid, 'foldcolumn', '1')
  call nvim_win_set_option(winid, 'cursorline', v:true)
  call nvim_win_set_option(winid, 'winhl', 'FoldColumn:PmenuSel,Normal:Pmenu,CursorLine:PmenuSel')
  call nvim_win_set_cursor(winid, [1, 0])
endfunction
