" ============================================================================
" FileName: float.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:get_float_pos(width, height, pos) abort
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
    " `- 1`: subtract the coordination of the window itself
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

function! skylight#float#open(bufnr, width, height, pos, title) abort
  let [row, col, anchor] = s:get_float_pos(a:width, a:height, a:pos)
  let border_options = {
    \ 'relative': 'editor',
    \ 'anchor': anchor,
    \ 'row': row,
    \ 'col': col,
    \ 'width': a:width,
    \ 'height': a:height,
    \ 'style':'minimal'
    \ }
  let options = deepcopy(border_options)
  let options.row += (options.anchor[0] == 'N' ? 1 : -1)
  let options.col += (options.anchor[1] == 'W' ? 1 : -1)
  let options.width -= 2
  let options.height -= 2
  let winid = nvim_open_win(a:bufnr, v:false, options)
  let [c_top, c_right, c_bottom, c_left, c_topleft, c_topright, c_botright, c_botleft] = g:skylight_borderchars
  let repeat_top = (border_options.width - strwidth(c_topleft) - strwidth(c_topright) - strwidth(a:title)) / strwidth(c_top)
  let repeat_mid = (border_options.width - strwidth(c_left) - strwidth(c_right))
  let repeat_bot = (border_options.width - strwidth(c_botleft) - strwidth(c_botright)) / strwidth(c_bottom)
  let content = [c_topleft . a:title . repeat(c_top, repeat_top) . c_topright]
  let content += repeat([c_left . repeat(' ', repeat_mid) . c_right], border_options.height-2)
  let content += [c_botleft . repeat(c_bottom, repeat_bot) . c_botright]
  let border_buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(border_buf, 0, -1, v:true, content)
  call nvim_buf_set_option(border_buf, 'bufhidden', 'wipe')
  let border_winid = nvim_open_win(border_buf, v:false, border_options)
  call nvim_win_set_option(border_winid, 'winhl', 'Normal:FloatermBorder')
  return [winid, border_winid]
endfunction
