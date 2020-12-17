" ============================================================================
" FileName: tag.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#mode#tag#search(pattern, bang) abort
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
      call skylight#search#callback(filename, lnum, cmd, a:bang)
    endif
  endif

  if exists('g:did_coc_loaded')
    let taginfo = coc#rpc#request('getTagList', [])
    if taginfo isnot v:null
      let filename = taginfo[0]['filename']
      let lnum = matchstr(taginfo[0]['cmd'], 'keepjumps \zs\d\+\ze')
      call skylight#search#callback(filename, lnum, '', a:bang)
    endif
  endif
endfunction
