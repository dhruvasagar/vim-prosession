function! prosession#ExecInDir(dir, cmd) "{{{1
  return system('cd ' . fnameescape(a:dir) . '; ' . a:cmd)
endfunction

function! prosession#GetCurrBranch(dir) "{{{1
  let branch = prosession#ExecInDir(a:dir, g:prosession_branch_cmd)
  if branch =~# "\n$" | let branch = branch[:-2] | endif
  return branch
endfunction
