" ============================================================================
" FileName: tag.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! skylight#mode#tag#search(pattern) abort
  let pattern = empty(a:pattern) ? expand('<cword>') : a:pattern
  let pattern = '^' . pattern . '$'
  let taglists = taglist(pattern)
  let locations = []
  if !empty(taglists)
    for t in taglists
      let location = {}
      for k in ['filename', 'cmd']
        let location[k] = t[k]
      endfor
      if location['cmd'] =~ '^\d\+$'
        let location['lnum'] = str2nr(cmd)
      else
        let location['lnum'] = -1
      endif
      call add(locations, location)
    endfor
    call skylight#search#callback(locations)
    return
  endif

  if exists('g:did_coc_loaded')
    let taginfo = coc#rpc#request('getTagList', [])
    if taginfo isnot v:null
      let locations = []
      for t in taginfo
        let location = {}
        let location['filename'] = t['filename']
        let location['lnum'] = matchstr(t['cmd'], 'keepjumps \zs\d\+\ze')
        let location['cmd'] = t['cmd']
        call add(locations, location)
      endfor
      call skylight#search#callback(locations)
    endif
  endif
endfunction
