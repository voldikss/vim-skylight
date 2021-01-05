" ============================================================================
" FileName: skylight#async.vim
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

function! skylight#async#new() abort
  let vim = {}
  let vim.id = jobstart([v:progpath, '--embed'], {'rpc': v:true})
  let vim.async = 1

  function! vim.request(method, ...) dict
    return s:do_rpc(0, self.id, a:method, a:000)
  endfunction

  function! vim.notify(method, ...) dict
    return s:do_rpc(1, self.id, a:method, a:000)
  endfunction

  function! vim.cmd(cmd, async) dict
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

  function! vim.isvalid() abort
    return jobwait([self.id], 0)[0] == -1
  endfunction

  function! vim.close() dict
    call jobstop(self.id)
  endfunction

  return vim
endfunction

function! skylight#async#close(vim) abort
  if a:vim.isvalid()
    call a:vim.close()
  endif
endfunction
