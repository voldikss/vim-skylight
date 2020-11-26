" ============================================================================
" FileName: skylight.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:float_winid = -1
let s:float_bufnr = -1
let s:border_winid = -1
let s:ns_id = -1

function! s:winexists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction

function! s:register_autocmd(...) abort
  augroup close_skylight_float
    autocmd!
    autocmd CursorMoved * call timer_start(200, function('s:close_float_win'))
  augroup END
endfunction

function! s:close_float_win(...) abort
  if win_getid() == s:float_winid
    return
  endif
  if s:ns_id != -1
    call nvim_buf_clear_namespace(s:float_bufnr, s:ns_id, 0, -1)
    let s:ns_id = -1
  endif
  if s:winexists(s:float_winid)
    call nvim_win_close(s:float_winid, v:true)
    let s:float_winid = -1
  endif
  if s:winexists(s:border_winid)
    call nvim_win_close(s:border_winid, v:true)
    let s:border_winid = -1
  endif
  autocmd! close_skylight_float
endfunction

" TODO: more edge cases
function! s:get_filepath() abort
  let fpath = substitute(expand('<cfile>'), '^\zs\(\~\|\$HOME\)', $HOME, '')
  let lnum = matchstr(getline('.'), fpath . '\(:\||\)\zs\d\+\ze')

  if isdirectory(fpath)
    call skylight#util#show_msg('Can not preview directory', 'error')
    let fpath = ''
  elseif fpath =~ '^/' && !filereadable(fpath)
    call skylight#util#show_msg('File was not found', 'error')
    let fpath = ''
  else
    if !filereadable(fpath)
      " remote `./` and `../`
      while fpath =~ '^\(../\|./\)'
        let fpath = substitute(fpath, '^\(../\|./\)', '', 'g')
      endwhile
      " do search
      let fpath = findfile(fpath, '.,**5;' . skylight#path#get_root())
      if !empty(fpath)
        let fpath = fnamemodify(fpath, ':p')
      elseif exists('g:did_coc_loaded')
        let taginfo = coc#rpc#request('getTagList', [])
        if taginfo isnot v:null
          let fpath = taginfo[0]['filename']
          let lnum = matchstr(taginfo[0]['cmd'], 'keepjumps \zs\d\+\ze')
        else
          call skylight#util#show_msg('File was not found', 'error')
        endif
      endif
    endif
  endif
  return [fpath, lnum]
endfunction

function! skylight#jumpto(stay) abort
  if &ft=='floaterm'
    hide
  endif
  let [fpath, lnum] = s:get_filepath()
  if empty(fpath)
    return
  endif
  let prev_winid = win_getid()
  execute printf('%s %s %s', g:skylight_jump_command, empty(lnum) ? '' : '+'.lnum, fpath)
  echom prev_winid . ' ' . winnr()
  if a:stay && win_getid() != prev_winid
    wincmd p
  endif
endfunction

function! skylight#preview(enter) abort
  let [fpath, lnum] = s:get_filepath()
  if empty(fpath)
    return
  endif
  if bufloaded(fpath)
    let s:float_bufnr = bufnr(fpath)
  else
    let s:float_bufnr = bufadd(fpath)
    call nvim_buf_set_option(s:float_bufnr, 'bufhidden', 'wipe')
  endif
  let [winid, border_winid] = skylight#float#open(s:float_bufnr, 80, 20, 'topright', fpath)
  call nvim_win_set_option(winid, 'number', v:true)
  noautocmd call win_gotoid(winid)
  execute 'doautocmd filetypedetect BufNewFile'
  if !empty(lnum)
    let s:ns_id = nvim_create_namespace('skylight')
    call nvim_buf_add_highlight(s:float_bufnr, s:ns_id, 'Search', str2nr(lnum)-1, 0, -1)
    call win_gotoid(winid)
    noautocmd execute 'keepjumps ' . lnum
  endif
  if !a:enter
    noautocmd wincmd p
  endif
  let s:float_winid = winid
  let s:border_winid = border_winid
  call timer_start(100, function('s:register_autocmd'))
endfunction
