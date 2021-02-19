" ============================================================================
" FileName: file.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#mode#file#search(pattern) abort
  if skylight#search#get_status() == 1
    return
  endif

  let lnumpat = '\(:\|(\||\|\s\+\)\zs\d\+\ze'
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

  if filereadable(filename)
    let result = #{filename: filename}
    if !empty(lnumstr)
      let result.lnum = str2nr(lnumstr)
    endif
    call skylight#search#callback([result])
    return
  elseif isdirectory(filename)
    call skylight#util#show_msg('Can not preview directory', 'warning')
    call skylight#search#set_status(1)
    return
  elseif filename =~ '^/'
    let filename = substitute(filename, '^\zs/\ze', '', '')
  else
    " pass
  endif

  if filereadable(filename)
    let result = #{filename: filename}
    if !empty(lnumstr)
      let result.lnum = str2nr(lnumstr)
    endif
    call skylight#search#callback([result])
    return
  elseif isdirectory(filename)
    call skylight#util#show_msg('Can not preview directory', 'warning')
    call skylight#search#set_status(1)
    return
  elseif filename =~ '^\(../\|./\)' 
    " remove `./` and `../`
    while filename =~ '^\(../\|./\)'
      let filename = substitute(filename, '^\(../\|./\)', '', 'g')
    endwhile
  else
    " pass
  endif

  let path = '.,**5'
  let root = skylight#path#get_root()
  if !empty(root)
    let path .= ';' . root
  endif

  let vim = skylight#async#new()
  let cmd = [
        \ printf('let F = findfile("%s", "%s", -1)', filename, path),
        \ printf('let results = map(F, { _,v -> #{filename: v} })'),
        \ printf('if !empty("%s")', lnumstr),
        \ printf('call map(results, { _,v -> #{filename: v.filename, lnum: %s} })', str2nr(lnumstr)),
        \ printf('endif'),
        \ printf('call rpcrequest(1, "vim_call_function", "skylight#search#callback", [results])'),
        \ printf('quit!')
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
