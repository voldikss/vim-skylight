" ============================================================================
" FileName: search.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#search#findfile() abort
  let fileinfo = {'filename': '', 'lnum': -1, 'cmd': ''}
  if s:search_as_file(fileinfo)
    " nop
  elseif s:search_as_tag(fileinfo)
    " still nop
  else
    call skylight#util#show_err('File or tag is not found', 'error')
  endif
  return [fileinfo.filename, fileinfo.lnum, fileinfo.cmd]
endfunction

function! s:search_as_tag(fileinfo) abort
  let pattern = expand('<cword>')
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

function! s:search_as_file(fileinfo) abort
  let save_isfname = &isfname
  set isfname+=(,)
  let filename = substitute(expand('<cfile>'), '^\zs\(\~\|\$HOME\)', $HOME, '')
  let &isfname = save_isfname
  let lnumstr = matchstr(getline('.'), filename . '\(:\||\)\zs\d\+\ze')
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
    let g:skylight_errmsg ='File is not found'
    return 0
  endif

  " TODO: more edge cases
  " remote `./` and `../`
  while filename =~ '^\(../\|./\)'
    let filename = substitute(filename, '^\(../\|./\)', '', 'g')
  endwhile
  " do search
  let filename = findfile(filename, '.,**5;' . skylight#path#get_root())
  if !empty(filename)
    let a:fileinfo['filename'] = fnamemodify(filename, ':p')
    let a:fileinfo['lnum'] = lnum
    return 1
  endif
endfunction
