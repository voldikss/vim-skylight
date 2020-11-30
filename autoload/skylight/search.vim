" ============================================================================
" FileName: search.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#search#findfile(pattern) abort
  let fileinfo = {'filename': '', 'lnum': -1, 'cmd': ''}
  if s:search_as_file(fileinfo, a:pattern)
    " nop
  elseif s:search_as_tag(fileinfo, a:pattern)
    " still nop
  endif
  return [fileinfo.filename, fileinfo.lnum, fileinfo.cmd]
endfunction

function! s:search_as_tag(fileinfo, pattern) abort
  let pattern = empty(a:pattern) ? expand('<cword>') : a:pattern
  let pattern = '^' . pattern . '$'
  let taglists = taglist(pattern)
  if !empty(taglists)
    let filename = taglists[0]['filename']
    if filereadable(filename)
      let a:fileinfo['filename'] = filename
      let cmd = taglists[0]['cmd']
      " transform to lnum to add highlight
      if cmd =~ '^\d\+$'
        let a:fileinfo['lnum'] = str2nr(cmd)
      else
        let a:fileinfo['cmd'] = cmd
      endif
      return 1
    endif
  endif

  if exists('g:did_coc_loaded')
    let taginfo = coc#rpc#request('getTagList', [])
    if taginfo isnot v:null
      let a:fileinfo['filename'] = taginfo[0]['filename']
      let a:fileinfo['lnum'] = matchstr(taginfo[0]['cmd'], 'keepjumps \zs\d\+\ze')
      return 1
    endif
  endif
endfunction

function! s:search_as_file(fileinfo, pattern) abort
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
    let a:fileinfo['filename'] = filename
    let a:fileinfo['lnum'] = lnum
    return 1
  endif

  if isdirectory(filename)
    let g:skylight_errmsg ='Can not preview directory'
    return 0
  endif

  if filename =~ '^/' && !filereadable(filename)
    let g:skylight_errmsg ='File not found'
    return 0
  endif

  " TODO: more edge cases
  " remote `./` and `../`
  while filename =~ '^\(../\|./\)'
    let filename = substitute(filename, '^\(../\|./\)', '', 'g')
  endwhile
  " do search
  let path = '.,**5'
  let root = skylight#path#get_root()
  if !empty(root)
    let path .= ';' . root
  endif
  let filename = findfile(filename, path)
  if !empty(filename)
    let a:fileinfo['filename'] = fnamemodify(filename, ':p')
    let a:fileinfo['lnum'] = lnum
    return 1
  endif
endfunction
