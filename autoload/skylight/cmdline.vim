" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function skylight#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let candidates = ['file', 'tag', 'word']
  if a:arg_lead == ''
    return candidates
  else
    return filter(candidates, 'v:val[:len(a:arg_lead) - 1] == a:arg_lead')
endif
endfunction
