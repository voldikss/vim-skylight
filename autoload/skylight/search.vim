" ============================================================================
" FileName: search.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:succeed = 0

function! s:search_as_file(pattern, action) abort
  let lnumpat = '\(:\|(\||\)\zs\d\+\ze'
  if !empty(a:pattern)
    let pattern = a:pattern
    let lnumstr = matchstr(pattern, lnumpat)
    if empty(lnumstr)
      let lnumstr = matchstr(getline('.'), pattern . lnumpat)
    endif
  else
    let pattern = expand('<cfile>')
    let lnumstr = matchstr(getline('.'), pattern . lnumpat)
  endif
  let filename = substitute(pattern, '^\zs\(\~\|\$HOME\)', $HOME, '')
  let lnum = empty(lnumstr) ? -1 : str2nr(lnumstr)

  if filereadable(filename)
    call skylight#search#callback(filename, lnum, '', a:action)
    return
  endif

  if isdirectory(filename)
    call skylight#util#show_msg('Can not preview directory')
    return
  endif

  if filename =~ '^/' && !filereadable(filename)
    call skylight#util#show_msg('File not found')
    return
  endif

  " remove `./` and `../`
  while filename =~ '^\(../\|./\)'
    let filename = substitute(filename, '^\(../\|./\)', '', 'g')
  endwhile

  let path = '.,**5'
  let root = skylight#path#get_root()
  if !empty(root)
    let path .= ';' . root
  endif

  let vim = skylight#async#new()
  let cmd = [
            \ printf(
              \ 'let F = { -> findfile("%s", "%s")}',
              \ filename,
              \ path
              \ ),
            \ printf(
              \ 'call rpcnotify(1, "vim_call_function", "skylight#search#callback", [F(), "%s", "%s", "%s"])',
              \ -1,
              \ '',
              \ a:action
              \ ),
            \ 'quit!'
          \ ]
  call vim.cmd(cmd, 1)
  call timer_start(5000, { -> s:stop_findfile() })
endfunction

function! s:stop_findfile() abort
  if !s:succeed
    call skylight#util#show_msg('Stop searching due to timeout', 'info')
  endif
  call skylight#async#close()
endfunction

function! s:search_as_tag(pattern, action) abort
  let pattern = empty(a:pattern) ? expand('<cword>') : a:pattern
  let pattern = '^' . pattern . '$'
  let taglists = taglist(pattern)
  if !empty(taglists)
    let filename = taglists[0]['filename']
    if filereadable(filename)
      let lnum = -1
      let cmd = taglists[0]['cmd']
      " transform to lnum to add highlight
      if cmd =~ '^\d\+$'
        let lnum = str2nr(cmd)
      else
        let cmd = cmd
      endif
      call skylight#search#callback(filename, lnum, cmd, a:action)
    endif
  endif

  if exists('g:did_coc_loaded')
    let taginfo = coc#rpc#request('getTagList', [])
    if taginfo isnot v:null
      let filename = taginfo[0]['filename']
      let lnum = matchstr(taginfo[0]['cmd'], 'keepjumps \zs\d\+\ze')
      call skylight#search#callback(filename, lnum, '', a:action)
    endif
  endif
endfunction

function! skylight#search#start(pattern, action) abort
  let s:succeed = 0

  call s:search_as_file(a:pattern, a:action)

  call s:search_as_tag(a:pattern, a:action)
endfunction

function! skylight#search#callback(filename, lnum, cmd, action) abort
  if s:succeed | return |endif
  let s:succeed = 1

  if empty(a:filename) || !filereadable(a:filename)
    call skylight#util#show_msg('File or tag not found')
    return
  endif

  if getfsize(a:filename) / (1024*1024) > 10
    call skylight#util#show_msg('File too large', 'error')
    return
  endif

  if a:action == 'jumpto'
    call skylight#jumpto(a:filename, a:lnum, a:cmd)
  elseif a:action == 'preview'
    call skylight#preview(a:filename, a:lnum, a:cmd)
  endif
endfunction
