" ============================================================================
" FileName: skylight.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

if !exists('g:loaded_skylight')
  let g:loaded_skylight = 1
endif

let g:skylight_width        = get(g:, 'skylight_width', 0.5)
let g:skylight_height       = get(g:, 'skylight_height', 0.5)
let g:skylight_position     = get(g:, 'skylight_position', 'topright')
let g:skylight_borderchars  = get(g:, 'skylight_borderchars', ['─', '│', '─', '│', '╭', '╮', '╯', '╰'])
let g:skylight_jump_command = get(g:, 'skylight_jump_command', 'edit')

hi def link SkylightBorder Normal

command! -range -bang -nargs=* -complete=customlist,skylight#cmdline#complete
      \ Skylight call skylight#start(<bang>0, visualmode(), <range>, <q-args>)
