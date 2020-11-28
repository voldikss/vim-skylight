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

function! s:register_autocmd() abort
  augroup close_skylight_float
    autocmd!
    autocmd CursorMoved * call timer_start(100, { -> skylight#float#close() })
  augroup END
endfunction

function! skylight#float#close(...) abort
  if win_getid() == s:winid | return | endif
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
let s:bd_winid = -1
function! skylight#float#open(bufnr, configs) abort
  let [row, col, anchor] = s:calculate_float_pos(
    \ a:configs.width,
    \ a:configs.height,
    \ a:configs.position
    \ )

  let options = {
    \ 'relative': 'editor',
    \ 'anchor': anchor,
    \ 'row': row + (anchor[0] == 'N' ? 1 : -1),
    \ 'col': col + (anchor[1] == 'W' ? 1 : -1),
    \ 'width': a:configs.width - 2,
    \ 'height': a:configs.height - 2,
    \ 'style':'minimal',
    \ }
  let winid = nvim_open_win(a:bufnr, v:false, options)
  call nvim_win_set_option(winid, 'number', v:true)

  call timer_start(10, { -> s:nvim_create_scroll_win(winid) })

  let bd_options = {
    \ 'relative': 'editor',
    \ 'anchor': anchor,
    \ 'row': row,
    \ 'col': col,
    \ 'width': a:configs.width,
    \ 'height': a:configs.height,
    \ 'focusable': v:false,
    \ 'style':'minimal',
    \ }
  let bd_bufnr = skylight#buffer#create_border(a:configs)
  let bd_winid = nvim_open_win(bd_bufnr, v:false, bd_options)
  call nvim_win_set_option(bd_winid, 'winhl', 'Normal:SkylightBorder')
  call timer_start(100, { -> s:register_autocmd() })
  let s:winid = winid
  let s:bd_winid = bd_winid
  return [winid, bd_winid]
endfunction

function! skylight#float#exists() abort
  return s:win_exists(s:winid)
endfunction

function! skylight#float#scroll(forward) abort
  let winid = s:winid
  if !s:win_exists(winid)
    call skylight#util#show_msg('No skylight windows')
    return ''
  endif
  let bufnr = nvim_win_get_buf(winid)
  let rowcnt = nvim_buf_line_count(bufnr)
  let height = nvim_win_get_height(winid)
  if rowcnt < height | return '' | endif
  let pos = nvim_win_get_cursor(winid)
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
  call s:nvim_win_execute(winid, cmd)
  call s:nvim_refresh_scroll_bar()
  return "\<Ignore>"
endfunction

function! s:nvim_refresh_scroll_bar() abort
  let [winid, sb_winid] = [s:winid, s:sb_winid]
  let bufnr = nvim_win_get_buf(winid)
  let width = nvim_win_get_width(winid)
  let height = nvim_win_get_height(winid)
  let wrap = nvim_win_get_option(winid, 'wrap')
  let content_height = s:content_height(bufnr, width, wrap)
  if height >= content_height
    return
  endif

  let wininfo = getwininfo(winid)[0]
  let thumb_start = 0
  let thumb_length = max([1, float2nr(floor(height * (height + 0.0)/content_height))])
  if wininfo['topline'] != 1
    let linecount = nvim_buf_line_count(bufnr)
    let topline = wininfo['topline']
    let botline = wininfo['botline']
    if botline >= linecount
      let thumb_start = height - thumb_length
    else
      let thumb_start = max([1, float2nr(round((height - thumb_length + 0.0)*(topline - 1.0)/(content_height - height)))])
    endif
  endif

  let sb_bufnr = nvim_win_get_buf(sb_winid)
  call nvim_buf_clear_namespace(sb_bufnr, -1, 0, -1)
  for idx in range(0, height - 1)
    if idx >= thumb_start && idx < thumb_start + thumb_length
      call nvim_buf_add_highlight(sb_bufnr, -1, 'PmenuThumb', idx, 0, 1)
    else
      call nvim_buf_add_highlight(sb_bufnr, -1, 'PmenuSbar', idx, 0, 1)
    endif
  endfor
endfunction

function! s:content_height(bufnr, width, wrap) abort
  if !a:wrap
    return nvim_buf_line_count(a:bufnr)
  endif
  let lines = nvim_buf_get_lines(a:bufnr, 0, -1, 0)
  let total = 0
  for line in lines
    let dw = max([1, strdisplaywidth(line)])
    let total += float2nr(ceil(str2float(string(dw))/a:width))
  endfor
  return total
endfunction

let s:sb_winid = -1
function! s:nvim_create_scroll_win(winid) abort
  " move the content window
  let config = nvim_win_get_config(a:winid)
  let config.width -= 1
  let config.col -= 1
  " NOTE: this will cause flicker problem and reset `number`
  " call nvim_win_set_config(a:winid, config)

  " create the scroll window
  let [row, col] = nvim_win_get_position(a:winid)
  let options = {
    \ 'relative': 'editor',
    \ 'row': row,
    \ 'col': col + config.width,
    \ 'width': 1,
    \ 'height': config.height,
    \ 'focusable': v:false,
    \ 'style': 'minimal',
    \ }
  let sb_bufnr = skylight#buffer#create_scratch_buf(repeat([' '], config.height))
  let sb_winid = nvim_open_win(sb_bufnr, v:false, options)
  let s:sb_winid = sb_winid
  call s:nvim_refresh_scroll_bar()
  return sb_winid
endfunction
