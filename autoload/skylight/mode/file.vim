" ============================================================================
" FileName: file.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#mode#file#search(pattern) abort
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
    call skylight#search#callback([{'filename': filename, 'lnum': lnum, 'cmd': ''}])
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
        \ printf('let F = findfile("%s", "%s")', filename, path),
        \ printf('let arg = [#{filename: F, lnum: "%s", cmd: "%s"}]', -1, ''),
        \ 'call rpcrequest(1, "vim_call_function", "skylight#search#callback", [arg])',
        \ 'quit!'
        \ ]
  call vim.cmd(cmd, 1)
  call timer_start(5000, { -> s:stop_findfile() })
endfunction

function! s:stop_findfile() abort
  if skylight#search#get_status() != 1
    call skylight#util#show_msg('Stop searching due to timeout', 'info')
  endif
  call skylight#async#close()
endfunction
