" ============================================================================
" FileName: buffer.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:bufnr = -1
function! skylight#buffer#load_buf(filename) abort
  if bufloaded(a:filename)
    let s:bufnr = bufnr(a:filename)
  else
    let s:bufnr = bufadd(a:filename)
    call nvim_buf_set_option(s:bufnr, 'bufhidden', 'wipe')
    call nvim_buf_set_option(s:bufnr, 'buflisted', v:false)
  endif
  return s:bufnr
endfunction

let s:ns_id = -1
function! skylight#buffer#add_highlight(lnum) abort
  let s:ns_id = nvim_create_namespace('skylight')
  let rowcnt = nvim_buf_line_count(s:bufnr)
  let lnum = a:lnum - 1
  if lnum < 1 || lnum > rowcnt | return | endif
  call nvim_buf_add_highlight(s:bufnr, s:ns_id, 'Search', lnum, 0, -1)
endfunction

function! skylight#buffer#clear_highlight() abort
  if s:ns_id == -1 | return | endif
  if !bufexists(s:bufnr) | return | endif
  call nvim_buf_clear_namespace(s:bufnr, s:ns_id, 0, -1)
  let s:ns_id = -1
endfunction

function! skylight#buffer#create_border(configs) abort
  let repeat_width = a:configs.width - 2
  let title_width = strdisplaywidth(a:configs.title)
  let [c_top, c_right, c_bottom, c_left, c_topleft, c_topright, c_botright, c_botleft] = a:configs.borderchars
  let content = [c_topleft . a:configs.title . repeat(c_top, repeat_width - title_width) . c_topright]
  let content += repeat([c_left . repeat(' ', repeat_width) . c_right], a:configs.height-2)
  let content += [c_botleft . repeat(c_bottom, repeat_width) . c_botright]
  return skylight#buffer#create_scratch_buf(content)
endfunction

function! skylight#buffer#create_scratch_buf(...) abort
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  call nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  call nvim_buf_set_option(bufnr, 'swapfile', v:false)
  call nvim_buf_set_option(bufnr, 'undolevels', -1)
  let lines = get(a:, 1, v:null)
  if type(lines) != 7
    call nvim_buf_set_option(bufnr, 'modifiable', v:true)
    call nvim_buf_set_lines(bufnr, 0, -1, v:false, lines)
    call nvim_buf_set_option(bufnr, 'modifiable', v:false)
  endif
  return bufnr
endfunction
