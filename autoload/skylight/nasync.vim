" ============================================================================
" FileName: skylight#nasync.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:do_rpc(async, id, method, args)
  if a:async == 0
    let rpc = 'rpcrequest'
  else
    let rpc = 'rpcnotify'
  end
  return call(rpc, [a:id, a:method] + a:args)
endfunction

let s:vim = {}
let s:vim.id = -1
let s:vim.async = 1

function s:vim.request(method, ...) dict
  return s:do_rpc(0, self.id, a:method, a:000)
endfunction

function s:vim.notify(method, ...) dict
  return s:do_rpc(1, self.id, a:method, a:000)
endfunction

function s:vim.cmd(cmd, async) dict
  if type(a:cmd) == v:t_list
    let cmd = join(a:cmd, ' | ')
  else
    let cmd = a:cmd
  endif
  if a:async == 1
    call self.notify('vim_command', cmd)
  else
    call self.request('vim_command', cmd)
  endif
endfunction

function! s:vim.isvalid() abort
  return jobwait([self.id], 0)[0] == -1
endfunction

function s:vim.close() dict
  call jobstop(self.id)
endfunction

function! skylight#nasync#new()
  let s:vim.id = jobstart(v:progpath . ' --embed', {'rpc': v:true})
  let s:vim.async = 1
  return s:vim
endfunction

function! skylight#nasync#close() abort
  if s:vim.isvalid()
    call s:vim.close()
  endif
endfunction
