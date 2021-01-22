" ============================================================================
" FileName: word.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function skylight#mode#word#search(pattern) abort
  let pattern = '\<' . expand('<cword>') . '\>'
  let filename = expand('%:p')
  let results = []
  let curpos = getpos('.')
  normal! gg0
  let first_match_pos = searchpos(pattern, 'w')
  call add(results, #{
        \ pattern: pattern,
        \ filename: filename,
        \ lnum: first_match_pos[0]
        \ })
  while v:true
    let pos = searchpos(pattern, 'w')
    if pos == first_match_pos
      break
    endif
    call add(results, #{
          \ pattern: pattern,
          \ filename: filename,
          \ lnum: pos[0]
          \ })
  endwhile
  call setpos('.', curpos)
  call skylight#search#callback(results)
endfunction
