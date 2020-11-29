" ============================================================================
" FileName: cocf.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" Description: *F*unctions copied from coc.nvim *f*loat.vim
" ============================================================================

" max firstline of lines, height > 0, width > 0
function! s:max_firstline(lines, height, width) abort
  let max = len(a:lines)
  let remain = a:height
  for line in reverse(copy(a:lines))
    let w = max([1, strdisplaywidth(line)])
    let dh = float2nr(ceil(str2float(string(w))/a:width))
    if remain - dh < 0
      break
    endif
    let remain = remain - dh
    let max = max - 1
  endfor
  return min([len(a:lines), max + 1])
endfunction

function! s:content_height(bufnr, width, wrap) abort
  if !bufloaded(a:bufnr)
    return 0
  endif
  if !a:wrap
    return has('nvim') ? nvim_buf_line_count(a:bufnr) : len(getbufline(a:bufnr, 1, '$'))
  endif
  let lines = has('nvim') ? nvim_buf_get_lines(a:bufnr, 0, -1, 0) : getbufline(a:bufnr, 1, '$')
  let total = 0
  for line in lines
    let dw = max([1, strdisplaywidth(line)])
    let total += float2nr(ceil(str2float(string(dw))/a:width))
  endfor
  return total
endfunction

" Get best lnum by topline
function! s:get_cursorline(topline, lines, scrolloff, width, height) abort
  let lastline = len(a:lines)
  if a:topline == lastline
    return lastline
  endif
  let bottomline = a:topline
  let used = 0
  for lnum in range(a:topline, lastline)
    let w = max([1, strdisplaywidth(a:lines[lnum - 1])])
    let dh = float2nr(ceil(str2float(string(w))/a:width))
    let g:l = a:lines
    if used + dh >= a:height || lnum == lastline
      let bottomline = lnum
      break
    endif
    let used += dh
  endfor
  let cursorline = a:topline + a:scrolloff
  let g:b = bottomline
  let g:h = a:height
  if cursorline + a:scrolloff > bottomline
    " unable to satisfy scrolloff
    let cursorline = (a:topline + bottomline)/2
  endif
  return cursorline
endfunction

" Get firstline for full scroll
function! s:get_topline(topline, lines, forward, height, width) abort
  let used = 0
  let lnums = a:forward ? range(a:topline, len(a:lines)) : reverse(range(1, a:topline))
  let topline = a:forward ? len(a:lines) : 1
  for lnum in lnums
    let w = max([1, strdisplaywidth(a:lines[lnum - 1])])
    let dh = float2nr(ceil(str2float(string(w))/a:width))
    if used + dh >= a:height
      let topline = lnum
      break
    endif
    let used += dh
  endfor
  if topline == a:topline
    if a:forward
      let topline = min([len(a:lines), topline + 1])
    else
      let topline = max([1, topline - 1])
    endif
  endif
  return topline
endfunction

" topline content_height content_width
function! s:get_options(winid) abort
  if has('nvim')
    let width = nvim_win_get_width(a:winid)
    if getwinvar(a:winid, '&foldcolumn', 0)
      let width = width - 1
    endif
    let info = getwininfo(a:winid)[0]
    return {
      \ 'topline': info['topline'],
      \ 'height': nvim_win_get_height(a:winid),
      \ 'width': width
      \ }
  else
    let pos = popup_getpos(a:winid)
    return {
      \ 'topline': pos['firstline'],
      \ 'width': pos['core_width'],
      \ 'height': pos['core_height']
      \ }
  endif
endfunction

function! s:win_execute(winid, command) abort
  let curr = nvim_get_current_win()
  noa keepalt call nvim_set_current_win(a:winid)
  exec a:command
  noa keepalt call nvim_set_current_win(curr)
endfunction

function! s:win_setview(winid, topline, lnum) abort
  let cmd = 'call winrestview({"lnum":'.a:lnum.',"topline":'.a:topline.'})'
  call s:win_execute(a:winid, cmd)
  call timer_start(10, { -> skylight#cocf#refresh_scroll_bar(a:winid) })
endfunction

function! skylight#cocf#scroll_win(winid, forward, amount) abort
  let opts = s:get_options(a:winid)
  let lines = getbufline(winbufnr(a:winid), 1, '$')
  let maxfirst = s:max_firstline(lines, opts['height'], opts['width'])
  let topline = opts['topline']
  let height = opts['height']
  let width = opts['width']
  let scrolloff = getwinvar(a:winid, '&scrolloff', 0)
  if a:forward && topline >= maxfirst
    return
  endif
  if !a:forward && topline == 1
    return
  endif
  if a:amount == 0
    let topline = s:get_topline(opts['topline'], lines, a:forward, height, width)
  else
    let topline = topline + (a:forward ? a:amount : - a:amount)
  endif
  let topline = a:forward ? min([maxfirst, topline]) : max([1, topline])
  let lnum = s:get_cursorline(topline, lines, scrolloff, width, height)
  call s:win_setview(a:winid, topline, lnum)
  let top = s:get_options(a:winid)['topline']
  " not changed
  if top == opts['topline']
    if a:forward
      call s:win_setview(a:winid, topline + 1, lnum + 1)
    else
      call s:win_setview(a:winid, topline - 1, lnum - 1)
    endif
  endif
endfunction

function! skylight#cocf#refresh_scroll_bar(winid) abort
  let bufnr = nvim_win_get_buf(a:winid)
  let width = nvim_win_get_width(a:winid)
  let height = nvim_win_get_height(a:winid)
  let wrap = nvim_win_get_option(a:winid, 'wrap')
  let content_height = s:content_height(bufnr, width, wrap)
  if height >= content_height | return | endif

  let wininfo = getwininfo(a:winid)[0]
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

  let sb_winid = nvim_win_get_var(a:winid, 'scroll_winid')
  if !nvim_win_is_valid(sb_winid) | return | endif
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
