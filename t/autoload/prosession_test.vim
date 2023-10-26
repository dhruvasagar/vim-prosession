let s:test_dir = "/tmp/tmp"
function! s:setup() abort
  call mkdir(s:test_dir, 'p')
endfunction

function! s:teardown() abort
  call delete(s:test_dir, 'rf')
endfunction

function! s:TestProsessionExecInDir()
  let cmd = "ls -altr ."
  let out = prosession#ExecInDir(s:test_dir, cmd)
  call testify#assert#equals(split(out, "\n")[0], 'total 0')
endfunction
call testify#setup(function('s:setup'))
call testify#it('ProsessionExecInDir should work', function('s:TestProsessionExecInDir'))
call testify#teardown(function('s:teardown'))

function! s:TestGetCurrBranch()
  let out = prosession#GetCurrBranch(".")
  call testify#assert#equals(out, "master")
endfunction
call testify#it('prosession#GetCurBranch should get the current git branch', function('s:TestGetCurrBranch'))
