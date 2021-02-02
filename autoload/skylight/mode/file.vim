" ============================================================================
" FileName: file.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#mode#file#search(pattern) abort
  if skylight#search#get_status() == 1
    return
  endif

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

  if filename =~ '^/'
    if filereadable(filename)
      let result = #{filename: filename}
      if !empty(lnumstr)
        let result.lnum = str2nr(lnumstr)
      endif
      call skylight#search#callback([result])
      return
    else
      let filename = substitute(filename, '^\zs/\ze', '', '')
    endif
  endif

  if filereadable(filename)
    let result = #{filename: filename}
    if !empty(lnumstr)
      let result.lnum = str2nr(lnumstr)
    endif
    call skylight#search#callback([result])
    return
  endif

  if isdirectory(filename)
    call skylight#util#show_msg('Can not preview directory', 'warning')
    call skylight#search#set_status(1)
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
        \ printf('let F = findfile("%s", "%s", -1)', filename, path),
        \ 'let results = map(F, { _,v -> #{filename: v} })',
        \ 'call rpcrequest(1, "vim_call_function", "skylight#search#callback", [results])',
        \ 'quit!'
        \ ]
  call vim.cmd(cmd, 1)
  call timer_start(3000, { -> s:stop_findfile(vim) })
endfunction

function! s:stop_findfile(vim) abort
  if skylight#search#get_status() != 1
    call skylight#util#show_msg('Stop searching files due to timeout', 'info')
  endif
  call skylight#async#close(a:vim)
endfunction
